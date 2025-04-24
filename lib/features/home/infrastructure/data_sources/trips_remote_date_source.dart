import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:intl/intl.dart';

import '../../../../auth/presentation/providers/auth_state_provider.dart';
import '../../../../core/infrastructure/network/apis/apis.dart';
import '../../../../core/infrastructure/network/apis/dtos/trip_request_dto.dart';
import '../../../../core/presentation/utils/riverpod_framework.dart';
import '../../../../utils/logger.dart';
import '../../../../utils/mertial-v.dart';
import '../../domain/history_trip.dart';
import '../../domain/latest_trip.dart';
import '../../domain/trip.dart';
import '../../presentation/providers/trip_provider/trip_provider.dart';
import '../dtos/area_dto.dart';
import '../dtos/project_dto.dart';
import 'gps_remote_data_source.dart';
import 'trips_local_data_source.dart';

part 'trips_remote_date_source.g.dart';

@Riverpod(keepAlive: true)
TripsRemoteDataSource tripsRemoteDataSource(Ref ref) {
  return TripsRemoteDataSource(
    ref,
    tripService: ref.read(apiServiceProvider).client.getService<TripsService>(),
  );
}

/// The `TripsRemoteDataSource` class is responsible for managing remote API interactions
/// related to trips. It provides methods to create, update, and retrieve trip data,
/// as well as handle caching of trip information locally for fallback purposes.
///
/// This class interacts with the `TripsService` API client to perform operations such as:
/// - Creating a new trip
/// - Updating an existing trip
/// - Ending a trip (both normal and forced)
/// - Fetching trip histories
/// - Retrieving the latest uncompleted trip
/// - Checking the state of a trip
///
/// Additionally, it includes helper methods to cache trip data locally and validate
/// cached data based on specific conditions (e.g., within the last 12 hours).
///
/// Key Features:
/// - Ensures fallback to local cache when remote API calls fail.
/// - Logs important events and errors for debugging purposes.
/// - Uses Riverpod for dependency injection and state management.
///
/// Example Usage:
/// ```dart
/// final tripsRemoteDataSource = ref.read(tripsRemoteDataSourceProvider);
/// final newTrip = await tripsRemoteDataSource.createNewTrip(
///   siteId: 1,
///   projectId: 2,
///   areeaId: 3,
///   unloadingAreaId: 4,
/// );
/// ```
class TripsRemoteDataSource {
  TripsRemoteDataSource(this.ref, {required this.tripService});

  final Ref ref;
  final TripsService tripService;

  Future<Trip?> createNewTrip({
    required int siteId,
    required int projectId,
    required int areeaId,
    required int unloadingAreaId,
  }) async {
    final driver = ref.read(authStateProvider.select((s) => s.toNullable()));
    if (driver == null) {
      throw Exception('Driver not found');
    }
    final response = (await tripService.createTrip(
      TripRequestDto(
        driverId: driver.id,
        material: selectedMaterial.display(),
        loadingAreaId: areeaId,
        unloadingAreaId: unloadingAreaId,
        projectId: projectId,
      ),
    ))
        .body;

    final trip = response?.data;

    // Cache the newly created trip if successful
    if (trip != null) {
      final latestTrip = convertTripToLatestTrip(trip);

      // Use existing cache method
      await _saveLatestTripLocally(driver.id, latestTrip);

      logger.log('Trip created and cached locally', color: LogColor.green);
    }
    return trip;
  }

  // convert trip to latest trip
  LatestTrip convertTripToLatestTrip(Trip trip) {
    // Convert Trip to LatestTrip for caching
    final now = DateTime.now()
        .toUtc()
        .add(const Duration(hours: 9)); // Korea Standard Time (UTC+9)
    // Format the datetime as yyyy-MM-dd HH:mm
    final dateTimeStr = DateFormat('yyyy-MM-dd HH:mm').format(now);

    return LatestTrip(
      tripId: trip.tripId,
      projectInfo: ProjectDto(
        id: 0,
        name: trip.projectName,
        address: '',
      ),
      status: trip.status,
      startTime: dateTimeStr,
      gpsTrackingResponse: [],
      material: trip.material,
      loadingAreaInfo: AreaDto(
        id: trip.loadingArea.id ?? 0,
        name: trip.loadingArea.areaName ?? '',
        address: trip.loadingArea.areaAddress ?? '',
        typeFunction: '',
        latitude: trip.loadingArea.latitude,
        longitude: trip.loadingArea.longitude,
        radius: trip.loadingArea.radius,
      ),
      unloadingAreaInfo: AreaDto(
        id: trip.unloadingArea.id ?? 0,
        name: trip.unloadingArea.areaName ?? '',
        address: trip.unloadingArea.areaAddress ?? '',
        typeFunction: '',
        latitude: trip.unloadingArea.latitude,
        longitude: trip.unloadingArea.longitude,
        radius: trip.unloadingArea.radius,
      ),
    );
  }

  Future<Trip?> updateTrip({
    required int tripId,
    required int siteId,
    required int projectId,
    required int areeaId,
    required int unloadingAreaId,
  }) async {
    final driver = ref.read(authStateProvider.select((s) => s.toNullable()));
    if (driver == null) {
      throw Exception('Driver not found');
    }
    final response = (await tripService.updateTrip(
      tripId,
      TripRequestDto(
        driverId: driver.id,
        material: selectedMaterial.display(),
        loadingAreaId: areeaId,
        unloadingAreaId: unloadingAreaId,
        projectId: projectId,
      ),
    ))
        .body;

    final trip = response?.data;
    if (trip != null) {
      final latestTrip = convertTripToLatestTrip(trip);

      // Use existing cache method
      await _saveLatestTripLocally(driver.id, latestTrip);

      logger.log('Trip updated and cached locally', color: LogColor.green);
    }
    return trip;
  }

  Future<bool?> endTrip({
    required int tripId,
  }) async {
    final response = await tripService.endTrip(tripId);

    if (!response.isSuccessful) {
      throw ForceEndTripException(' ${response.error}');
    }

    return response.body?.data != null;
  }

  Future<List<HistoryTrip>?> historiesTrip(
    int driverId, {
    Map<String, dynamic> params = const {},
  }) async {
    final data =
        (await tripService.histories(driverId, queryParams: params)).body;

    return data?.data ?? [];
  }

  Future<LatestTrip?> latestUncomplete(int driverId) async {
    try {
      // Try to fetch from remote API first
      final response = await tripService.latestUncomplete(driverId);
      final data = response.body?.data;

      // If successful, save to local storage for future fallback
      await _saveLatestTripLocally(driverId, data);
      return data;
    } catch (e) {
      logger.log(
        'Failed to fetch latest uncompleted trip: $e',
        color: LogColor.yellow,
      );

      // Fallback to local data (with 12-hour validation)
      final localTrip = await _getLatestTripFromLocal(driverId);

      if (localTrip == null) return null;

      if (_isTripWithin12Hours(localTrip)) {
        return localTrip;
      } else {
        logger.log(
          "Found cached trip but it's older than 12 hours (started: ${localTrip.startTime})",
          color: LogColor.yellow,
        );
        await FirebaseAnalytics.instance.logEvent(
          name: 'trip_cache_expired',
          parameters: {
            'trip_id': localTrip.tripId ?? 0,
            'start_time': localTrip.startTime ?? 'unknown',
          },
        );
      }
      return null;
    }
  }

  // Helper method to check if trip started within the last 12 hours
  bool _isTripWithin12Hours(LatestTrip trip) {
    if (trip.startTime == null) return false;

    try {
      // Parse time in format "yyyy-MM-dd HH:mm"
      final startTime =
          DateTime.parse("${trip.startTime!.replaceAll(' ', 'T')}:00Z");

      final now = DateTime.now()
          .toUtc()
          .add(const Duration(hours: 9)); // Korea Standard Time (UTC+9)
      final diff = now.difference(startTime);

      // Return true if trip started less than 12 hours ago
      return diff.inHours < 12;
    } catch (e) {
      logger.log('Error parsing trip start time: $e');
      return false; // If we can't determine start time, reject the trip
    }
  }

  // Helper method to save trip data locally
  Future<void> _saveLatestTripLocally(int driverId, LatestTrip? trip) async {
    try {
      final localStorage = ref.read(tripsLocalDataSourceProvider);
      await localStorage.saveLatestUncompleteTrip(driverId, trip);
      logger.log('Latest trip data cached locally', color: LogColor.green);
    } catch (e) {
      logger.log('Failed to save trip data locally: $e');
    }
  }

// Helper method to retrieve local trip data
  Future<LatestTrip?> _getLatestTripFromLocal(int driverId) async {
    try {
      final localStorage = ref.read(tripsLocalDataSourceProvider);
      final cachedTrip = await localStorage.getLatestUncompleteTrip(driverId);

      if (cachedTrip != null) {
        logger.log('Using cached trip data', color: LogColor.blue);
      } else {
        logger.log('No cached trip data available', color: LogColor.yellow);
      }

      return cachedTrip;
    } catch (e) {
      logger.log('Error retrieving cached trip: $e');
      return null;
    }
  }

  Future<Trip?> getTripState(int tripId) async {
    final data = (await tripService.getTripStatus(tripId)).body;

    return data?.data;
  }

  Future<void> endTripForce(
    int tripId,
    String reason,
    int unloadingAreaId,
  ) async {
    await tripService.forceEnd(tripId, {
      'reason': reason,
      'unloading_area_id': unloadingAreaId,
    });
  }
}
