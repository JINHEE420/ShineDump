import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vibration/vibration.dart';

import '../../../../core/infrastructure/services/local_notifications_service.dart';
import '../../../../core/presentation/utils/riverpod_framework.dart';
import '../../../../utils/distance_compute.dart';
import '../../../../utils/logger.dart';
import '../../domain/drive_mode.dart';
import '../../domain/move_status.dart';
import '../../domain/moving_state.dart';
import '../../infrastructure/data_sources/gps_local_data_source.dart';
import '../../infrastructure/data_sources/gps_remote_data_source.dart';
import '../providers/drive_mode_provider/drive_mode_provider.dart';
import '../providers/trip_provider/trip_provider.dart';
import 'background_service_helper.dart';
import 'gps_optimizer.dart';

part 'background_locator_service.g.dart';

const buffer = 50; // meters

@Riverpod(keepAlive: true)
BackgroundLocatorService backgroundTaskService(Ref ref) {
  return BackgroundLocatorService(ref: ref);
}

/// `BackgroundLocatorService` is a service that manages background location tracking
/// and processing for the application. It is responsible for:
///
/// - Continuously tracking the user's location in the background.
/// - Monitoring proximity to specific points of interest (e.g., loading and unloading destinations).
/// - Sending location data to the server in batches for optimized performance.
/// - Notifying the user when they arrive at specific destinations via notifications, sound, and vibration.
/// - Handling platform-specific configurations for location tracking.
///
/// ### Key Features:
/// - **Location Tracking**: Uses `Geolocator` to track the user's location in real-time.
/// - **Proximity Alerts**: Checks the user's distance to predefined points and triggers notifications when within range.
/// - **Data Synchronization**: Batches and sends GPS data to the server periodically.
/// - **Audio and Vibration Alerts**: Plays a sound and vibrates the device to notify the user of important events.
/// - **Battery Optimization Handling**: Requests exemptions from battery optimizations on Android devices.
/// - **Error Recovery**: Automatically attempts to recover from location stream errors or interruptions.
///
/// ### Key Methods:
/// - `initTask`: Initializes the service with trip details and destination points.
/// - `startLocationTracking`: Starts the location tracking service.
/// - `stopLocationTracking`: Stops the location tracking service and cleans up resources.
/// - `_checkProximityToPoints`: Checks the user's proximity to loading and unloading destinations.
/// - `_syncGpsDataIfNeeded`: Synchronizes GPS data with the server when necessary.
/// - `_handleLocationUpdate`: Processes location updates and triggers relevant actions.
/// - `_startPeriodicChecks`: Periodically ensures the location stream is active and functioning.
/// - `_updateTripDistance`: Recalculates the trip distance using optimized GPS data.
///
/// ### Usage:
/// This service is designed to be used with Riverpod for state management. It can be
/// instantiated using the `backgroundTaskService` provider and integrated into the app's
/// lifecycle to ensure continuous background location tracking.
///
/// Example:
/// ```dart
/// final backgroundService = ref.read(backgroundTaskServiceProvider);
/// await backgroundService.initTask(
///   tripId: 123,
///   loadingDestination: loadingState,
///   unloadingDestination: unloadingState,
/// );
/// await backgroundService.startLocationTracking();
/// ```
class BackgroundLocatorService with BackgroundServiceHelper {
  BackgroundLocatorService({required this.ref});

  final Ref ref;

  // Audio
  final _player = AudioPlayer();

  // Service state variables
  StreamSubscription<Position>? _positionStreamSubscription;
  Position? oldPoint;
  bool isSyncing = false;
  DateTime? _lastUpdateTime;
  Timer? _periodicTimer;

  late int tripId;

  /// Trip state variables
  // tracking the loading destination
  late MovingState loadingDestination;
  // It's used to track the unloading destination in the background location service.
  // The code uses this variable to determine when a vehicle is approaching or has arrived at the final unloading location.
  // When the user gets close enough to this point, the app shows notifications and updates UI elements accordingly.
  late MovingState unloadingDestination;

  /// Initialize the background locator service and set up communication
  Future<void> initTask({
    required int tripId,
    required MovingState loadingDestination,
    required MovingState unloadingDestination,
  }) async {
    this.tripId = tripId;
    this.loadingDestination = loadingDestination;
    this.unloadingDestination = unloadingDestination;

    // Reset tracking state
    isSyncing = false;
    _lastUpdateTime = null;
    oldPoint = null;
  }

  /// Start location tracking
  /// If [point] is provided, it will be used as the starting point
  Future<void> startLocationTracking({Position? point}) async {
    // Cancel any existing subscription first
    if (_positionStreamSubscription != null) {
      debugPrint('Stopping location service');
      await _positionStreamSubscription!.cancel();
      _positionStreamSubscription = null;
    }

    oldPoint = point;

    // Use position stream for continuous updates - this is the recommended approach
    try {
      // Test if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled');
        await FirebaseAnalytics.instance
            .logEvent(name: 'location_services_disabled');
        return;
      }

      // Check permissions
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        await FirebaseAnalytics.instance.logEvent(name: '$permission');
        debugPrint('Location permissions are permanently denied');
        return;
      }

      // Request battery optimization exemption
      if (Platform.isAndroid) {
        final batteryOptStatus =
            await Permission.ignoreBatteryOptimizations.status;
        if (!batteryOptStatus.isGranted) {
          await Permission.ignoreBatteryOptimizations.request();
        }
        final isGranted = await Permission.ignoreBatteryOptimizations.isGranted;
        if (!isGranted) {
          debugPrint('Battery optimization is not ignored');
          await FirebaseAnalytics.instance
              .logEvent(name: 'battery_optimization_not_ignored');
        }
      }

      // Start periodic checks
      _startPeriodicChecks();

      final locationSettings = _getLocationSettings();
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).handleError((Object error) {
        logger.log('Location stream error: $error', color: LogColor.red);
        FirebaseAnalytics.instance.logEvent(name: 'location_stream_error');
        // Attempt recovery after a brief delay
        Future.delayed(const Duration(seconds: 5), () {
          if (_positionStreamSubscription != null) {
            // Restart location tracking with the last known point
            startLocationTracking(point: oldPoint);
          }
        });
      }).listen((position) async {
        try {
          _handleLocationUpdate(position);
        } catch (e) {
          debugPrint('Error processing location update: $e');
        }
      });

      // Create Android-specific wake locks for critical operations
      if (Platform.isAndroid) {
        await aquireWakeLock();
      }
    } catch (e) {
      debugPrint('Error starting location stream: $e');
    }
  }

  /// Stop location tracking
  Future<void> stopLocationTracking() async {
    oldPoint = null;
    _lastUpdateTime = null;
    unawaited(tryToSendGpsDataToServer(ref, tripId: tripId));

    debugPrint('Stopping location service');
    await _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;

    await releaseWakeLock();

    // Stop periodic checks
    _periodicTimer?.cancel();
    _periodicTimer = null;
    // Stop audio player
    await _player.stop();
  }

  /// Add GPS data to our stack for batched server updates
  void _addGpsDataToStack(Position location, double distance) {
    final gpsDataSource = ref.read(gpsLocalDataSourceProvider);
    gpsDataSource.saveGPSData(
      data: GPSData(
        distanceMoving: distance,
        lat: location.latitude,
        long: location.longitude,
        speed: location.speed,
        timeStamp: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      ),
      tripId: tripId,
    );
  }

  /// Send GPS data to server when needed based on count threshold or time interval
  /// Returns true if sync was successful or not needed, false if sync failed
  Future<bool> _syncGpsDataIfNeeded() async {
    if (isSyncing) return false;
    isSyncing = true;
    try {
      return syncGpsDataToServer(ref, tripId: tripId);
    } catch (e) {
      logger.log('Error during GPS sync: $e', color: LogColor.red);
      return false;
    } finally {
      isSyncing = false;
    }
  }

  /// Check proximity to loading/unloading points
  void _checkProximityToPoints(Position location) {
    final localNotifications = ref.read(localNotificationsServiceProvider);
    final distanceToLoadingDestination = Geolocator.distanceBetween(
      loadingDestination.lat,
      loadingDestination.long,
      location.latitude,
      location.longitude,
    );
    logger.log(
      '====> Distance to loading destination(${loadingDestination.lat}, ${loadingDestination.long}): ${distanceToLoadingDestination.toStringAsFixed(2)}m',
    );

    /// Check if we've arrived at the loading point, notify user via notification, voice
    if (!loadingDestination.isNotified &&
        distanceToLoadingDestination <= loadingDestination.radius + buffer) {
      logger.log('Arrived at loading point in ${loadingDestination.radius}m');
      loadingDestination = loadingDestination.copyWith(isNotified: true);
      unawaited(
        localNotifications.showNotification(MoveStatus.loading.display()),
      );
      _playSound();
    }

    /// Update distance to unloading point
    ref
        .read(tripManagerProvider.notifier)
        .updateDistanceToLoadingDestination(distanceToLoadingDestination);

    final distanceToUnloadingDestination = Geolocator.distanceBetween(
      unloadingDestination.lat,
      unloadingDestination.long,
      location.latitude,
      location.longitude,
    );
    logger.log(
      '====> Distance to unloading destination(${unloadingDestination.lat}, ${unloadingDestination.long}): ${distanceToUnloadingDestination.toStringAsFixed(2)}m',
    );

    /// Check if we're at the unloading point, notify user via notification, voice
    if (!unloadingDestination.isNotified &&
        distanceToUnloadingDestination <=
            unloadingDestination.radius + buffer) {
      logger
          .log('Arrived at unloading point in ${unloadingDestination.radius}m');
      unloadingDestination = unloadingDestination.copyWith(isNotified: true);
      unawaited(
        localNotifications.showNotification(MoveStatus.unloading.display()),
      );
      _playSound();
    }

    /// Check if we're at the unloading point, auto-unloading if enabled
    final driveMode = ref.read(driveModeStateProvider).toNullable();
    if (distanceToUnloadingDestination <=
            unloadingDestination.radius + buffer &&
        driveMode == DriveMode.smart) {
      _autoUnloading();
    }

    /// Update distance to unloading point
    ref
        .read(tripManagerProvider.notifier)
        .updateDistanceToUnloadingDestination(distanceToUnloadingDestination);
  }

  Future<void> _autoUnloading() async {
    final tripProvider = ref.read(tripManagerProvider.notifier);
    await tripProvider.endTrip(message: '운행이 종료되었습니다'); // Auto-unloading
  }

  void _playSound() {
    logger.log('Playing sound', color: LogColor.red);
    unawaited(
      Future.sync(() async {
        // Improved audio playback method
        try {
          // Release any previous resources
          await _player.stop();

          // Play audio with higher priority
          await _player.play(AssetSource('sounds/ting.mp3'), volume: 1);

          // Add vibration after sound
          if (Platform.isIOS) {
            if (WidgetsBinding.instance.lifecycleState?.name == 'resumed' &&
                await Vibration.hasVibrator()) {
              logger.log('Vibrating');
              await Vibration.vibrate(); // 500ms vibration
            }
          } else {
            if (await Vibration.hasVibrator()) {
              logger.log('Vibrating');
              await Vibration.vibrate(); // 500ms vibration
            }
          }
          debugPrint(
            'Playing audio from assets (background-enabled): ${WidgetsBinding.instance.lifecycleState?.name}',
          );
        } catch (e) {
          debugPrint('Error playing audio from assets: $e');
        }
      }),
    );
  }

  LocationSettings _getLocationSettings() {
    late LocationSettings locationSettings;

    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: kDebugMode ? 1 : 5, // Meters,
        intervalDuration: const Duration(seconds: 5),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationText:
              'App will continue to receive your location in background',
          notificationTitle: 'Location Tracking Active',
          enableWakeLock: true,
          notificationChannelName: 'Location updates',
          setOngoing: true,
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        activityType: ActivityType.automotiveNavigation,
        distanceFilter: kDebugMode ? 1 : 5, // Meters,
        showBackgroundLocationIndicator: true,
      );
    } else {
      throw UnsupportedError('Unsupported platform');
    }
    return locationSettings;
  }

  void _handleLocationUpdate(Position position) {
    final now = DateTime.now();
    _lastUpdateTime = now;

    final timestamp = DateFormat('HH:mm:ss').format(now);
    logger.log(
      'Location update: $timestamp $position',
      color: LogColor.red,
    );

    // Add GPS data to database
    final distance = _calculateDistance(position);
    _addGpsDataToStack(position, distance);

    /// Update trip distance with the optimized value
    // Read all gps data from local db and re-calculate the distance
    unawaited(_updateTripDistance());

    // Send GPS data to server in batches
    unawaited(_syncGpsDataIfNeeded());

    // Check proximity to points of interest
    // Sent by LocationServiceRepository
    _checkProximityToPoints(position);
  }

  void _startPeriodicChecks() {
    // Check every 30 seconds if location updates are still flowing
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      final now = DateTime.now();
      if (_lastUpdateTime != null &&
          now.difference(_lastUpdateTime!) > const Duration(seconds: 30)) {
        logger.log('No location updates in 45+ seconds, attempting recovery');

        // Send a heartbeat notification to keep service active
        if (Platform.isAndroid) {
          updateNotification('Trip in progress - ${DateTime.now()}');
        }

        // Force location update if too long since last update
        final now = DateTime.now();
        if (_lastUpdateTime != null &&
            now.difference(_lastUpdateTime!).inMinutes >= 2) {
          logger.log('No location updates for 2+ minutes, forcing update');
          _requestSingleLocationUpdate();
        }
      }
    });
  }

  Future<void> _requestSingleLocationUpdate() async {
    try {
      // Get a single location update to kickstart the stream if it's stalled
      final position = await Geolocator.getCurrentPosition(
        locationSettings: _getLocationSettings(),
      );

      logger.log('Forced location update: $position', color: LogColor.blue);

      // Process this location update
      _handleLocationUpdate(position);
    } catch (e) {
      logger.log(
        'Error getting single location update: $e',
        color: LogColor.red,
      );
    }
  }

  double _calculateDistance(Position location) {
    if (oldPoint == null) {
      // Save first point
      oldPoint = location;

      // send to _processLocationUpdate() of BackgroundLocatorService
      logger.log('send first point: $location', color: LogColor.red);

      return 0;
    }
    // Calculate distance between points
    final distance = haversine(
      oldPoint?.latitude ?? 0,
      oldPoint?.longitude ?? 0,
      location.latitude,
      location.longitude,
    );

    // Update old point
    oldPoint = location;

    return distance;
  }

  Future<void> _updateTripDistance() async {
    try {
      final gpsOptimizer = GpsOptimizer();
      final gpsDataSource = ref.read(gpsLocalDataSourceProvider);
      final originTrack = await gpsDataSource.getGpsDataForTrip(tripId);
      final optimizedTrack = gpsOptimizer.optimizeTrack(originTrack);
      final optimizedDistance =
          gpsOptimizer.calculateDistance(optimizedTrack) * 1000;
      ref.read(tripManagerProvider.notifier).updateDistance(optimizedDistance);
    } catch (e) {
      debugPrint('Error updating trip distance: $e');
    }
  }
}
