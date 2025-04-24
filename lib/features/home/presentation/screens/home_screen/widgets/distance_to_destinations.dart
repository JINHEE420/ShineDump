import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../providers/trip_provider/trip_provider.dart';
import '../../../providers/trip_provider/trip_state.dart';

/// A widget that displays the distances to the loading and unloading destinations.
///
/// This widget listens to the `tripManagerProvider` to fetch the distances
/// to the loading and unloading destinations. If the distances are available,
/// they are displayed in kilometers with two decimal precision. Otherwise, "N/A" is shown.
class DistanceToDestinations extends HookConsumerWidget {
  const DistanceToDestinations({super.key});

  /// Builds the widget tree for displaying the distances to destinations.
  ///
  /// The widget uses Riverpod's `ref.watch` to observe changes in the
  /// `tripManagerProvider` and updates the UI accordingly.
  ///
  /// - `distanceToLoadingDestination`: The distance to the loading destination.
  /// - `distanceToUnloadingDestination`: The distance to the unloading destination.
  ///
  /// Returns a `Container` widget with the distances displayed in a column layout.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final distanceToLoadingDestination = ref.watch(
      tripManagerProvider
          .select((s) => s.toNullable()?.distanceToLoadingDestination),
    );
    final distanceToUnloadingDestination = ref.watch(
      tripManagerProvider
          .select((s) => s.toNullable()?.distanceToUnloadingDestination),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Distance to destinations:'),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Loading: '),
              const SizedBox(width: 8),
              Text(
                distanceToLoadingDestination != null
                    ? '${distanceToLoadingDestination.toKm().toStringAsFixed(2)}km'
                    : 'N/A',
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Text('Unloading: '),
              const SizedBox(width: 8),
              Text(
                distanceToUnloadingDestination != null
                    ? '${distanceToUnloadingDestination.toKm().toStringAsFixed(2)}km'
                    : 'N/A',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
