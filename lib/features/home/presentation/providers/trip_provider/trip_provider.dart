import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';

import '../../../../../auth/infrastructure/repos/auth_repo.dart';
import '../../../../../core/core_features/pip_service.dart';
import '../../../../../core/infrastructure/network/network_info.dart';
import '../../../../../core/infrastructure/services/local_notifications_service.dart';
import '../../../../../core/presentation/utils/fp_framework.dart';
import '../../../../../core/presentation/utils/riverpod_framework.dart';
import '../../../../../utils/logger.dart';
import '../../../../../utils/mertial-v.dart';
import '../../../domain/area.dart';
import '../../../domain/history_trip.dart';
import '../../../domain/latest_trip.dart';
import '../../../domain/move_status.dart';
import '../../../domain/moving_state.dart';
import '../../../domain/project.dart';
import '../../../domain/trip.dart';
import '../../../infrastructure/data_sources/trips_local_data_source.dart';
import '../../../infrastructure/data_sources/trips_remote_date_source.dart';
import '../../services/background_locator_service.dart';
import '../area_provider/area_provider.dart';
import '../project_provider/project_provider.dart';
import '../site_provider/site_provider.dart';
import 'trip_error_provider.dart';
import 'trip_state.dart';

part 'trip_provider.g.dart';

/// Manages the state and operations related to trips.
///
/// This class handles the lifecycle of a trip, including starting, updating,
/// and ending trips. It also manages synchronization with the server and
/// provides utility methods for interacting with trip-related data.
///
/// Key responsibilities:
/// - Managing the current trip state.
/// - Synchronizing trip status with the server.
/// - Handling trip lifecycle events (start, update, end).
/// - Interacting with related providers for areas, projects, and sites.
/// - Initializing and managing location tracking services.
@Riverpod(keepAlive: true)
class TripManager extends _$TripManager {
  // ======== Core State Management ========

  /// Builds the initial state of the trip manager.
  ///
  /// Returns an empty state (`None`) by default.
  @override
  Option<TripState> build() => const None();

  /// Retrieves the current trip state or `null` if not set.
  TripState? get tripState => state.toNullable();

  /// Retrieves the current trip or `null` if not set.
  Trip? get trip => state.toNullable()?.trip;

  /// Timer used for periodic synchronization with the server.
  Timer? _syncTimer;

  /// Interval for synchronizing trip status with the server.
  static const syncInterval = Duration(seconds: 5);

  // ======== Basic Trip State Operations ========

  /// Sets a new trip and updates the state.
  ///
  /// - [trip]: The trip to set.
  /// - [startTime]: Optional start time for the trip. Defaults to the current time.
  /// - [distance]: Optional initial distance for the trip. Defaults to `0.0`.
  void setNewTrip(Trip trip, {DateTime? startTime, double? distance}) {
    logger.log('TripState#setNewTrip: $trip');
    state = Some(
      TripState(
        trip: trip,
        startTime: startTime ?? DateTime.now(),
        distance: distance ?? 0.0,
      ),
    );
  }

  /// Clears the current trip and resets related state.
  ///
  /// This method also clears related providers for site, project, and area
  /// states, and removes the latest incomplete trip from local storage.
  void clearCurrentTrip() {
    state = const None();

    // Clear related providers
    ref.read(siteStateProvider.notifier).clearCurrentSite();
    ref.read(projectStateProvider.notifier).clearCurrentProject();
    ref.read(areaLoadingStateProvider.notifier).clearCurrentArea();
    ref.read(areaUnLoadingStateProvider.notifier).clearCurrentArea();

    // clear latest trip from local storage
    final driver = ref.read(authRepoProvider).getLatestSS();
    if (driver != null) {
      ref.read(tripsLocalDataSourceProvider).saveLatestUncompleteTrip(
            driver.id,
            null,
          );
    }
  }

  // ======== Trip Lifecycle Operations ========

  /// Ends the current trip.
  ///
  /// - [message]: The message to display in the notification.
  /// - Retries up to 3 times if the server call fails.
  Future<void> endTrip({required String message}) async {
    // Check if trip is already in the process of ending
    if (tripState != null && tripState!.isEnding) {
      logger.log(
        'Trip is already in the process of ending, ignoring duplicate request',
      );
      return;
    }

    // Mark the trip as ending
    if (tripState != null) {
      state = Option.of(tripState!.copyWith(isEnding: true));
    }

    // End trip on server with retry logic
    final remoteData = ref.read(tripsRemoteDataSourceProvider);
    var success = false;
    if (trip != null && trip?.tripId != 0) {
      var attempts = 0;

      while (!success && attempts < 3) {
        attempts++;
        try {
          await remoteData.endTrip(tripId: trip!.tripId);
          success = true;
          logger.log('Successfully ended trip on attempt $attempts');
        } catch (e) {
          if (attempts >= 3) {
            logger.log(
              'Failed to end trip after 3 attempts: $e',
              color: LogColor.red,
            );
          } else {
            logger.log('Retrying end trip (attempt $attempts): $e');
            // Add delay between retries
            await Future<void>.delayed(const Duration(seconds: 2));
          }
        }
      }
    }

    if (!success) {
      // restore state
      state = Option.of(tripState!.copyWith(isEnding: false));
      logger.log('Failed to end trip, aborting');
      return;
    }

    // Re-initialize the histories trip provider
    // This is necessary to ensure that the latest trip is not shown in the history
    ref.invalidate(historiesTripProvider);

    // Stop tracking services
    await ref.read(backgroundTaskServiceProvider).stopLocationTracking();

    // push notification
    await ref.read(localNotificationsServiceProvider).showNotification(message);

    stopSynchronization();

    // Reset state (isEnding is already set to default)
    clearCurrentTrip();
    // Disable PiP and clear state
    ref.read(pipServiceProvider).disable();
  }

  /// Forces the end of the current trip with a reason.
  ///
  /// - [reason]: The reason for force-ending the trip.
  /// - [unloadingAreaId]: Optional ID of the unloading area.
  Future<void> forceEndTrip(String reason, {int? unloadingAreaId}) async {
    final remoteData = ref.read(tripsRemoteDataSourceProvider);

    // End trip on server
    await remoteData.endTripForce(
      trip!.tripId,
      reason,
      unloadingAreaId ?? trip!.unloadingArea.id!,
    );

    // Reset and clean up state
    await ref.read(backgroundTaskServiceProvider).stopLocationTracking();

    // reset trip state
    ref.invalidate(historiesTripProvider);

    ref.read(pipServiceProvider).disable();
    clearCurrentTrip();
    stopSynchronization();
  }

  /// Updates the trip details on the server.
  ///
  /// - [siteId]: The ID of the site.
  /// - [projectId]: The ID of the project.
  /// - [areaId]: The ID of the loading area.
  /// - [unloadAreaId]: The ID of the unloading area.
  ///
  /// Returns `true` if the update was successful, otherwise `false`.
  Future<bool> updateTrip(
    int siteId,
    int projectId,
    int areaId,
    int unloadAreaId,
  ) async {
    final remoteData = ref.read(tripsRemoteDataSourceProvider);

    final tripUpdated = await remoteData.updateTrip(
      tripId: trip!.tripId,
      siteId: siteId,
      projectId: projectId,
      areeaId: areaId,
      unloadingAreaId: unloadAreaId,
    );

    if (tripUpdated != null) {
      state = Option.of(
        tripState!.copyWith(
          trip: tripUpdated,
        ),
      );
      return true;
    }

    return false;
  }

  // ======== Trip Retrieval and History ========

  /// Retrieves the latest incomplete trip and sets up the state accordingly.
  ///
  /// Returns the latest incomplete trip or `null` if no such trip exists.
  Future<LatestTrip?> getLatestTripUncomplete() async {
    if (tripState != null) {
      logger.log('TripState#getLatestTripUncomplete: Trip already set');
      return null;
    }

    final remoteData = ref.read(tripsRemoteDataSourceProvider);
    final driver = ref.read(authRepoProvider).getLatestSS();
    final data = await remoteData.latestUncomplete(driver?.id ?? 0);

    // Return if no data or trip is already completed
    if (data == null || data.status != 'UNCOMPLETED') {
      ref.read(pipServiceProvider).disable();
      return null;
    }

    await ref.read(pipServiceProvider).enable();

    setNewTrip(
      Trip(
        tripId: data.tripId!,
        status: data.status!,
        loadingArea: AreaTrip.fromJson(data.loadingAreaInfo!.toJson()),
        unloadingArea: AreaTrip.fromJson(data.unloadingAreaInfo!.toJson()),
        projectName: data.projectInfo!.name,
        driverName: driver?.name ?? '',
        material: data.material ?? '',
        title: '',
      ),
      distance: data.gpsTrackingResponse.firstOrNull?.distance,
      startTime: data.startTime != null
          ? DateFormat('yyyy-MM-dd HH:mm').parse(data.startTime!)
          : null,
    );
    _setupTripAreas(
      project: data.projectInfo?.toDomain(),
      loadingArea: data.loadingAreaInfo?.toDomain(),
      unloadingArea: data.unloadingAreaInfo?.toDomain(),
      distance: data.gpsTrackingResponse.firstOrNull?.distance,
      startTime: data.startTime,
    );

    // Initialize location services
    await _initializeLocationServices(data);
    synchronizeTripState();

    return data;
  }

  /// Synchronizes the trip status with the server periodically.
  ///
  /// This method sets up a timer to synchronize the trip state every
  /// [syncInterval] seconds.
  void synchronizeTripState() {
    if (_syncTimer != null) return;

    logger.log(
      'Starting trip status synchronization every ${syncInterval.inSeconds}s',
    );

    // Set up periodic sync
    _syncTimer = Timer.periodic(syncInterval, (_) async {
      // check internet connection
      if (!await ref.read(networkInfoProvider).hasInternetConnection) {
        logger.log('No internet connection, cannot synchronize trip status');
        return;
      }
      try {
        logger.log('Synchronizing trip status...');
        final updated = await _getTripState();
        if (updated) {
          // stop the timer if the trip is completed
          stopSynchronization();
        }
      } catch (e) {
        logger.log(
          'Error during trip synchronization: $e',
          color: LogColor.red,
        );
      }
    });
  }

  /// Stops the periodic synchronization of the trip state.
  void stopSynchronization() {
    _syncTimer?.cancel();
    _syncTimer = null;
    logger.log('Stopped trip status synchronization');
  }

  // ======== Private Helper Methods ========

  /// Sets up project and area information for the current trip.
  ///
  /// - [project]: The project associated with the trip.
  /// - [loadingArea]: The loading area for the trip.
  /// - [unloadingArea]: The unloading area for the trip.
  /// - [distance]: The distance for the trip.
  /// - [startTime]: The start time for the trip.
  void _setupTripAreas({
    Project? project,
    Area? loadingArea,
    Area? unloadingArea,
    double? distance,
    String? startTime,
  }) {
    if (project != null) {
      ref.read(projectStateProvider.notifier).setCurrentProject(project);
    }

    if (loadingArea != null) {
      ref.read(areaLoadingStateProvider.notifier).setArea(loadingArea);
    }

    if (unloadingArea != null) {
      ref.read(areaUnLoadingStateProvider.notifier).setArea(unloadingArea);
    }

    state = Option.of(
      tripState!.copyWith(
        distance: distance ?? 0,
        startTime: startTime != null
            ? DateFormat('yyyy-MM-dd HH:mm').parse(startTime)
            : null,
      ),
    );
  }

  /// Initializes location tracking services for the trip.
  ///
  /// - [data]: The latest trip data used to configure tracking.
  Future<void> _initializeLocationServices(LatestTrip data) async {
    final background = ref.read(backgroundTaskServiceProvider);

    final loadingPoint = MovingState(
      lat: (data.loadingAreaInfo?.latitude ?? 0).toDouble(),
      long: (data.loadingAreaInfo?.longitude ?? 0).toDouble(),
      state: MoveStatus.loading,
      radius: data.loadingAreaInfo?.radius ?? 50,
    );
    final unloadingPoint = MovingState(
      lat: (data.unloadingAreaInfo?.latitude ?? 0).toDouble(),
      long: (data.unloadingAreaInfo?.longitude ?? 0).toDouble(),
      state: MoveStatus.unloading,
      radius: data.unloadingAreaInfo?.radius ?? 50,
    );
    await background.initTask(
      tripId: data.tripId!,
      loadingDestination: loadingPoint,
      unloadingDestination: unloadingPoint,
    );
    await background.startLocationTracking();
  }

  /// Updates the distance to the unloading destination.
  ///
  /// - [distance]: The distance to the unloading destination.
  void updateDistanceToUnloadingDestination(double? distance) {
    // Update state with new Trip that includes updated distance
    // This will notify all listeners
    state = Option.of(
      tripState!.copyWith(
        distanceToUnloadingDestination: distance,
      ),
    );
  }

  /// Updates the distance to the loading destination.
  ///
  /// - [distance]: The distance to the loading destination.
  void updateDistanceToLoadingDestination(double? distance) {
    // Update state with new Trip that includes updated distance
    // This will notify all listeners
    state = Option.of(
      tripState!.copyWith(
        distanceToLoadingDestination: distance,
      ),
    );
  }

  /// Updates the total distance for the trip.
  ///
  /// - [distance]: The total distance for the trip.
  void updateDistance(double distance) {
    // Update state with new Trip that includes updated distance
    // This will notify all listeners
    state = Option.of(
      tripState!.copyWith(
        distance: distance,
      ),
    );
  }

  /// Retrieves the trip state from the server and handles forced or canceled trips.
  ///
  /// Returns `true` if the trip state was updated, otherwise `false`.
  Future<bool> _getTripState() async {
    if (trip == null || trip!.tripId == 0) {
      return false;
    }

    final remoteData = ref.read(tripsRemoteDataSourceProvider);
    final data = await remoteData.getTripState(trip!.tripId);
    final status = data?.status;

    // Store the status for UI components to react to
    if (status == 'FORCE' || status == 'CANCEL') {
      // Update state with an error status
      ref.read(tripErrorProvider.notifier).setErrorStatus(status!);

      // Handle notifications without needing BuildContext
      final notificationMsg =
          status == 'FORCE' ? '관리자가 운행을 강제종료하였습니다' : '관리자가 운행을 반려하였습니다.';

      await ref
          .read(localNotificationsServiceProvider)
          .showNotification(notificationMsg);
      await ref.read(backgroundTaskServiceProvider).stopLocationTracking();
      ref.invalidate(historiesTripProvider);
      ref.read(pipServiceProvider).disable();
      clearCurrentTrip();
      return true;
    }

    return false;
  }
}

/// Create a new trip and initialize tracking
@riverpod
Future<Trip?> createTripState(
  Ref ref,
  int siteId,
  int projectId,
  int areaId,
  int unloadAreaId,
) async {
  logger.log(
    'Creating new trip with siteId: $siteId, projectId: $projectId, areaId: $areaId, unloadAreaId: $unloadAreaId',
    color: LogColor.red,
  );

  final remoteData = ref.read(tripsRemoteDataSourceProvider);

  final data = await remoteData.createNewTrip(
    siteId: siteId,
    areeaId: areaId,
    unloadingAreaId: unloadAreaId,
    projectId: projectId,
  );

  if (data == null) {
    await FirebaseCrashlytics.instance.recordError('create_trip_error', null);
    return null;
  }

  // Set up loading and unloading points
  final loadingPoint = MovingState(
    lat: data.loadingArea.latitude ?? 0,
    long: data.loadingArea.longitude ?? 0,
    state: MoveStatus.loading,
    radius: data.loadingArea.radius,
  );

  final unloadingPoint = MovingState(
    lat: data.unloadingArea.latitude ?? 0,
    long: data.unloadingArea.longitude ?? 0,
    state: MoveStatus.unloading,
    radius: data.unloadingArea.radius,
  );

  // Set up location tracking
  final background = ref.read(backgroundTaskServiceProvider);
  await background.initTask(
    tripId: data.tripId,
    loadingDestination: loadingPoint,
    unloadingDestination: unloadingPoint,
  );
  await background.startLocationTracking();

  // Reset distance and update state
  ref.read(tripManagerProvider.notifier).setNewTrip(data);
  ref.read(tripManagerProvider.notifier).synchronizeTripState();

  return data;
}

// Rest of providers remain unchanged
@riverpod
Future<List<HistoryTrip>> historiesTrip(Ref ref) async {
  final remoteData = ref.read(tripsRemoteDataSourceProvider);
  final driver = ref.read(authRepoProvider).getLatestSS();

  if (driver == null || driver.id == 0) {
    logger.log('Driver ID is null or zero, cannot fetch trip histories');
    return [];
  }

  // Format today's date as "yyyy-MM-dd" in UTC+9 timezone
  final today = DateFormat('yyyy-MM-dd')
      .format(DateTime.now().toUtc().add(const Duration(hours: 9)));

  final data = await remoteData.historiesTrip(
    driver.id,
    params: {
      'date': today,
    },
  );

  // sort by project & start time.
  // For example:
  // [{"project_name":"A","start_time":"2025-01-01 12:00"},
  //  {"project_name":"C","start_time":"2025-01-01 12:30"},
  //  {"project_name":"B","start_time":"2025-01-01 13:00"},
  //  {"project_name":"D","start_time":"2025-01-01 13:30"},
  //  {"project_name":"A","start_time":"2025-01-01 14:00"}
  //  {"project_name":"C","start_time":"2025-01-01 14:30"}
  //  {"project_name":"B","start_time":"2025-01-01 15:00"}]
  // Returns sorted data by start_time descending

  data?.sort(
    (a, b) {
      final aStartTime = DateFormat('yyyy-MM-dd HH:mm').parse(a.startTime);
      final bStartTime = DateFormat('yyyy-MM-dd HH:mm').parse(b.startTime);
      return bStartTime.compareTo(aStartTime);
    },
  );

  return data ?? [];
}

@riverpod
MaterialV selectedMaterial = MaterialV.cancer;
