import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/infrastructure/network/network_info.dart';
import '../../../../utils/logger.dart';
import '../../infrastructure/data_sources/gps_local_data_source.dart';
import '../../infrastructure/data_sources/gps_remote_data_source.dart';

// Define max gps stack size to send to server
const maxGpsStackSize = 10;

/// A mixin that provides utility methods for managing background services
/// in the application. This includes handling wake locks, updating
/// notifications, and syncing GPS data to the server.
///
/// Key Features:
/// - Acquire and release wake locks to keep the CPU awake during background tasks.
/// - Update notifications for background services on Android.
/// - Sync GPS data to the server with retry mechanisms and exponential backoff.
///
/// Methods:
/// - `aquireWakeLock`: Acquires a wake lock to prevent the CPU from sleeping.
/// - `updateNotification`: Updates the notification text for the background service.
/// - `releaseWakeLock`: Releases the wake lock to allow the CPU to sleep.
/// - `syncGpsDataToServer`: Syncs GPS data to the server based on a threshold.
/// - `tryToSendGpsDataToServer`: Attempts to send GPS data to the server with retries.
///
/// Dependencies:
/// - `networkInfoProvider`: Checks for internet connectivity.
/// - `gpsRemoteDataSourceProvider`: Handles remote GPS data syncing.
/// - `gpsLocalDataSourceProvider`: Manages local GPS data storage.
///
/// Usage:
/// This mixin is intended to be used in classes that require background
/// service management, such as syncing GPS data or managing notifications.
mixin BackgroundServiceHelper {
  static const serviceId = 'com.ys.shinedump.background_service';

  Future<void> aquireWakeLock() async {
    // Acquire a wake lock to keep the CPU awake
    try {
      // Use method channel to create a partial wake lock
      const platform = MethodChannel(serviceId);
      await platform.invokeMethod('acquireWakeLock');
    } catch (e) {
      logger.log('Error acquiring wake lock: $e');
    }
  }

  Future<void> updateNotification(String text) async {
    try {
      if (Platform.isAndroid) {
        const platform = MethodChannel(serviceId);
        await platform.invokeMethod('updateNotification', {'text': text});
      }
    } catch (e) {
      logger.log('Error updating notification: $e');
    }
  }

  Future<void> releaseWakeLock() async {
    // Release the wake lock
    try {
      const platform = MethodChannel(serviceId);
      await platform.invokeMethod('releaseWakeLock');
    } catch (e) {
      logger.log('Error releasing wake lock: $e');
    }
  }

  Future<bool> syncGpsDataToServer(Ref ref, {required int tripId}) async {
    // Get dependencies
    final network = ref.read(networkInfoProvider);
    final gpsRemote = ref.read(gpsRemoteDataSourceProvider);
    final gpsDataSource = ref.read(gpsLocalDataSourceProvider);

    // Skip sync attempt if no internet (optimize by checking connection first)
    if (!await network.hasInternetConnection) {
      logger.log(
        'Skipping GPS sync - no internet connection',
        color: LogColor.yellow,
      );
      return true; // Not an error, just skipping
    }

    // Get unsynced data count
    final dataList = await gpsDataSource.getUnsyncedGpsData(tripId);
    final unsyncedCount = dataList.length;

    // Decide whether to sync based on count threshold or last sync time
    final shouldSync = unsyncedCount >= maxGpsStackSize;

    if (shouldSync) {
      logger.log(
        'Syncing $unsyncedCount GPS points to server',
        color: LogColor.blue,
      );
      final syncSuccess = await gpsRemote.syncUnsentGpsData(tripId);

      if (syncSuccess) {
        logger.log('GPS data successfully synced', color: LogColor.green);
        return true;
      } else {
        logger.log('Failed to sync GPS data', color: LogColor.red);
        return false;
      }
    }

    return true; // No sync needed
  }

  Future<bool> tryToSendGpsDataToServer(Ref ref, {required int tripId}) async {
    // Send GPS data to server with retry attempts
    const maxAttempts = 5;
    var attempts = 0;
    var syncSuccess = false;

    // Get dependencies
    final gpsRemote = ref.read(gpsRemoteDataSourceProvider);
    final network = ref.read(networkInfoProvider);
    final gpsDataSource = ref.read(gpsLocalDataSourceProvider);

    try {
      // Get all unsynced data for this trip
      final unsyncedData = await gpsDataSource.getUnsyncedGpsData(tripId);

      if (unsyncedData.isEmpty) {
        logger.log('No GPS data to sync', color: LogColor.green);
        return true;
      }

      logger.log(
        'Attempting to sync ${unsyncedData.length} GPS points before stopping',
        color: LogColor.blue,
      );

      // Try with exponential backoff
      while (!syncSuccess && attempts < maxAttempts) {
        // Check for internet before attempting sync
        if (await network.hasInternetConnection) {
          // Use the syncUnsentGpsData method that handles both sync and marking as synced
          syncSuccess = await gpsRemote.syncUnsentGpsData(tripId);

          if (syncSuccess) {
            logger.log(
              'Successfully synced ${unsyncedData.length} GPS points',
              color: LogColor.green,
            );
            break;
          }
        } else {
          logger.log(
            'No internet connection for sync (attempt ${attempts + 1}/$maxAttempts)',
            color: LogColor.yellow,
          );
        }

        // Increment attempts and wait with exponential backoff
        attempts++;
        if (attempts < maxAttempts) {
          final backoffSeconds = attempts * 2; // 2, 4, 6, 8 seconds
          logger.log(
            'Sync failed, retrying in $backoffSeconds seconds (attempt $attempts/$maxAttempts)',
            color: LogColor.yellow,
          );
          await Future<void>.delayed(Duration(seconds: backoffSeconds));
        }
      }

      // Log if we failed to send all GPS data
      if (!syncSuccess) {
        logger.log(
          'Failed to sync ${unsyncedData.length} GPS points after $maxAttempts attempts',
          color: LogColor.red,
        );
        await FirebaseAnalytics.instance.logEvent(name: 'gps_sync_failed');
      } else {
        // delete all data after sync
        await gpsDataSource.deleteDataForTrip(tripId);
      }

      return syncSuccess;
    } catch (e) {
      logger.log('Error during final GPS sync: $e', color: LogColor.red);
      return false;
    }
  }
}
