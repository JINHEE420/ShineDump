part of '../home_screen_compact.dart';

/// A widget that displays a section of action panels in the home screen.
///
/// This widget consists of two action panels:
/// 1. A panel for setting up or modifying the loading area, which is enabled
///    based on the time difference between the current time and the trip's start time.
/// 2. A panel for viewing recent operation history, which displays the number
///    of operations currently in progress.
///
/// The widget uses Riverpod for state management to watch and interact with
/// providers such as `areaLoadingStateProvider`, `tripManagerProvider`, and
/// `historiesTripProvider`.
///
/// Key Features:
/// - Dynamically updates the state of the action panels based on provider values.
/// - Displays dialogs for setup information and trip history when the respective
///   panels are tapped.
///
/// This widget is designed to be used as part of the home screen's compact layout.
class ActionPanelsSection extends ConsumerWidget {
  const ActionPanelsSection({required this.ref, super.key});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLoadingArea =
        ref.watch(areaLoadingStateProvider).getOrElse(Area.blank);
    final tripProvider = ref.watch(tripManagerProvider);
    final tripHistoryProvider =
        ref.watch(historiesTripProvider.select((s) => s.value));

    return Column(
      children: [
        ActionPanel(
          enable: (tripProvider
                      .toNullable()
                      ?.startTime
                      ?.difference(DateTime.now())
                      .inSeconds ??
                  0) <
              300,
          callback: () =>
              _handleSetupTap(context, ref.read(tripManagerProvider.notifier)),
          title: _getLoadingAreaTitle(
            context,
            ref.read(tripManagerProvider.notifier),
            selectedLoadingArea,
          ),
        ),
        const SizedBox(height: Sizes.marginH28),
        ActionPanel(
          title: tr(context).recentOperationHistory,
          subTitle: tr(context)
              .operationsInProgress(tripHistoryProvider?.length ?? 0),
          callback: () => _showTripHistory(context),
        ),
      ],
    );
  }

  String _getLoadingAreaTitle(
    BuildContext context,
    TripManager tripManager,
    Area selectedLoadingArea,
  ) {
    return tripManager.trip?.loadingArea.areaName ??
        (selectedLoadingArea.name.isEmpty
            ? tr(context).selectSiteAndCargo
            : selectedLoadingArea.name);
  }

  Future<void> _handleSetupTap(
    BuildContext context,
    TripManager tripManager,
  ) async {
    final timeElapsed = -(tripManager.tripState?.startTime
            ?.difference(DateTime.now())
            .inSeconds ??
        0);

    if (timeElapsed > 300) {
      await Toasts.showBackgroundMessageToast(
        context,
        message: tr(context).modifyUnloadingLocationTimeLimit,
      );
      return;
    }

    await AppDialog.showDialog(
      context,
      const SetupInfoWidget(),
      maxHeight: MediaQuery.of(context).size.height * .6,
      isShowClose: false,
      barrierDismissible: true,
    );
  }

  void _showTripHistory(BuildContext context) {
    AppDialog.showDialog(
      context,
      const HistoriesTripWidget(),
      maxHeight: MediaQuery.of(context).size.height * .55,
      isShowClose: false,
    );
  }
}
