import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../../core/presentation/helpers/localization_helper.dart';
import '../../../../../../utils/logger.dart';
import '../../../../infrastructure/data_sources/gps_local_data_source.dart';
import '../../../../infrastructure/data_sources/gps_remote_data_source.dart';

part 'unsynced_data_banner.g.dart';

// Define a provider to track sync state
@riverpod
class SyncState extends _$SyncState {
  @override
  AsyncValue<bool> build() {
    return const AsyncValue.data(false); // Initially not syncing
  }

  Future<void> syncData() async {
    // Set loading state
    state = const AsyncValue.loading();

    try {
      final gpsRemote = ref.read(gpsRemoteDataSourceProvider);
      final gpsLocalDataSource = ref.read(gpsLocalDataSourceProvider);
      final trips = await gpsLocalDataSource.getTripsWithUnsyncedData();

      if (trips.isEmpty) {
        state =
            const AsyncValue.data(true); // No data to sync, consider success
        return;
      }

      var allSuccess = true;

      for (final tripId in trips) {
        final success = await gpsRemote.syncUnsentGpsData(tripId);

        if (!success) {
          allSuccess = false;
        } else {
          // If sync was successful, delete local data
          await gpsLocalDataSource.deleteDataForTrip(tripId);
        }
      }

      logger.log(
        'Sync completed, ${allSuccess ? "all succeeded" : "some failed"}',
        color: allSuccess ? LogColor.green : LogColor.yellow,
      );

      // Check if we still have unsynced data after the sync attempt
      final hasRemaining = await gpsLocalDataSource.hasUnsyncedData();

      // If no data remains, consider success even if some operations failed
      state = AsyncValue.data(!hasRemaining);
    } catch (e, st) {
      logger.log('Error during data sync: $e', color: LogColor.red);
      state = AsyncValue.error(e, st);
    }
  }
}

@riverpod
Future<bool> hasUnsyncedData(Ref ref) async {
  logger.log('Checking for unsynced data', color: LogColor.blue);
  final result = await ref.watch(gpsLocalDataSourceProvider).hasUnsyncedData();
  logger.log('Unsynced data check result: $result', color: LogColor.green);
  return result;
}

/// A widget that displays a banner to notify the user about unsynced data
/// and provides options to sync the data.
///
/// This widget listens to the `SyncState` provider to determine the current
/// sync status and displays appropriate UI based on the state:
/// - A loading indicator when syncing is in progress.
/// - An error message with a retry button if syncing fails.
/// - A success message when syncing completes successfully.
/// - A banner prompting the user to sync if unsynced data is detected.
///
/// The widget also uses the `hasUnsyncedData` provider to check for the
/// presence of unsynced data and updates the UI accordingly.
class UnsyncedDataBanner extends ConsumerWidget {
  const UnsyncedDataBanner({super.key});

  /// Builds the widget based on the current sync state.
  ///
  /// - Displays a loading banner when syncing is in progress.
  /// - Displays an error banner with retry functionality if syncing fails.
  /// - Displays a success banner briefly when syncing completes successfully.
  /// - Displays an unsynced data banner with a sync button if unsynced data is detected.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch for changes in sync state
    final syncState = ref.watch(syncStateProvider);

    // Handle different sync states first
    return syncState.when(
      loading: () => _buildLoadingBanner(context),
      error: (error, stackTrace) => _buildErrorBanner(context, error, ref),
      data: (syncSuccess) {
        // If we're showing sync success, display that regardless
        if (syncSuccess) {
          // Auto-dismiss after 3 seconds
          _scheduleDismiss(context, ref);
          return _buildSuccessBanner(context);
        }

        // Use StreamProvider for continuous updates of unsynced data status
        final hasUnsynced = ref.read(hasUnsyncedDataProvider);
        // Otherwise handle based on whether we have unsynced data
        return hasUnsynced.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (hasUnsynced) {
            if (hasUnsynced) {
              return _buildUnsyncedBanner(context, ref);
            } else {
              return const SizedBox.shrink();
            }
          },
        );
      },
    );
  }

  /// Schedules the dismissal of the success banner after 3 seconds.
  ///
  /// This method ensures that the success banner is only displayed briefly
  /// before being automatically dismissed.
  void _scheduleDismiss(BuildContext context, WidgetRef ref) {
    // Show success banner briefly, then automatically dismiss
    Future.delayed(const Duration(seconds: 3), () {
      // Only update if the widget is still mounted
      if (ref.read(syncStateProvider) is AsyncData<bool>) {
        ref.read(syncStateProvider.notifier).state = const AsyncData(false);
      }
    });
  }

  /// Builds a banner prompting the user to sync unsynced data.
  ///
  /// Includes a button that triggers the sync process when pressed.
  Widget _buildUnsyncedBanner(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.surface),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(tr(context).unsyncedDataBannerTitle),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () => ref.read(syncStateProvider.notifier).syncData(),
            icon: const Icon(Icons.sync),
            label: Text(tr(context).unsyncedDataBannerSyncButton),
          ),
        ],
      ),
    );
  }

  /// Builds a loading banner to indicate that syncing is in progress.
  Widget _buildLoadingBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text(tr(context).unsyncedDataBannerLoading),
        ],
      ),
    );
  }

  /// Builds an error banner with a retry button.
  ///
  /// Displays the error message and allows the user to retry the sync process.
  Widget _buildErrorBanner(BuildContext context, Object error, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${tr(context).unsyncedDataBannerErrorPrefix} ${error.toString().split('\n').first}',
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => ref.read(syncStateProvider.notifier).syncData(),
            icon: const Icon(Icons.refresh),
            label: Text(tr(context).unsyncedDataBannerRetryButton),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a success banner to indicate that syncing completed successfully.
  ///
  /// The banner is displayed briefly before being automatically dismissed.
  Widget _buildSuccessBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 8),
          Text(tr(context).unsyncedDataBannerSuccessMessage),
        ],
      ),
    );
  }
}
