import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/presentation/helpers/localization_helper.dart';
import '../../../../../../core/presentation/utils/riverpod_framework.dart';
import '../../../../../../core/presentation/widgets/loading_widgets.dart';
import '../../../../../../utils/style.dart';
import '../../../../domain/history_trip.dart';
import '../../../components/retry_again_component.dart';
import '../../../providers/trip_provider/trip_provider.dart';

/// A widget that displays a popup containing a list of historical trips grouped by project name.
///
/// This widget fetches trip data using the `historiesTripProvider` and groups the trips by their
/// project names. It displays the grouped data in a scrollable list, along with a confirm button
/// to close the popup.
///
/// Features:
/// - Displays a loading indicator while data is being fetched.
/// - Shows an error message with a retry option if data fetching fails.
/// - Groups trips by project name and displays the count of trips for each project.
/// - Provides a confirm button to close the popup.
class HistoriesTripWidget extends HookConsumerWidget {
  const HistoriesTripWidget({super.key});

  // The list is sorted before grouping
  Map<String, int> _groupHistories(List<HistoryTrip> trips) {
    final groupedData = <String, int>{};

    for (final trip in trips) {
      if (groupedData.containsKey(trip.projectName)) {
        groupedData[trip.projectName] = groupedData[trip.projectName]! + 1;
      } else {
        groupedData[trip.projectName] = 1;
      }
    }

    return groupedData;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;

    final historiesTrip = ref.watch(historiesTripProvider);

    return historiesTrip.when(
      skipLoadingOnReload: true,
      skipLoadingOnRefresh: !historiesTrip.hasError,
      loading: () => const TitledLoadingIndicator(message: ''),
      error: (error, st) => RetryAgainComponent(
        description: tr(context).systemErrorTryAgain,
        onPressed: () {
          ref.invalidate(historiesTripProvider);
        },
      ),
      data: (trips) {
        final sortedData = _groupHistories(trips);
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          height: size.height * .55,
          width: size.width * .8,
          child: Column(
            children: [
              // Title
              Container(
                margin: const EdgeInsets.only(top: 20),
                width: double.infinity,
                alignment: Alignment.center,
                child: Text(
                  tr(context).recentOperationHistory,
                  style: gpsTextStyle(weight: FontWeight.w700, fontSize: 18),
                ),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Divider(thickness: .5, color: Colors.grey),
              ),

              // List of trips
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemBuilder: (_, index) => HistoryItem(
                    title: sortedData.keys.elementAt(index),
                    count: tr(context)
                        .tripHistoryCount(sortedData.values.elementAt(index)),
                  ),
                  itemCount: sortedData.length,
                ),
              ),

              // Confirm button
              InkWell(
                onTap: () {
                  context.pop();
                },
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  height: 54,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E386D),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    tr(context).confirmButton,
                    style: gpsTextStyle(
                      weight: FontWeight.w700,
                      fontSize: 16,
                      lineHeight: 19,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A widget that represents a single item in the historical trips list.
///
/// This widget displays the project name and the count of trips associated with it.
/// It is designed to be used within a list in the `HistoriesTripWidget`.
///
/// Features:
/// - Displays the project name with ellipsis if it overflows.
/// - Shows the count of trips for the project.
/// - Provides a tappable container for potential future interactions.
class HistoryItem extends StatelessWidget {
  const HistoryItem({
    required this.title,
    required this.count,
    super.key,
  });
  final String title;
  final String count;

  @override
  Widget build(BuildContext context) {
    final style = gpsTextStyle(
      weight: FontWeight.w500,
      fontSize: 14,
      lineHeight: 19,
    );
    return InkWell(
      onTap: () async {},
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: style,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              count,
              style: style,
            ),
          ],
        ),
      ),
    );
  }
}
