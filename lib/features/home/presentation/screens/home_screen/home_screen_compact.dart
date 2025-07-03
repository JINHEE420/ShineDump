import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fpdart/fpdart.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '/core/presentation/screens/nested_screen_scaffold.dart';
import '/core/presentation/styles/styles.dart';
import '/core/presentation/utils/riverpod_framework.dart';
import '/core/presentation/widgets/app_dialog.dart';
import '/core/presentation/widgets/custom_elevated_button.dart';
import '/core/presentation/widgets/dialogs.dart';
import '/core/presentation/widgets/toasts.dart';
import '/features/home/domain/area.dart';
import '/features/home/presentation/providers/area_provider/area_provider.dart';
import '/features/home/presentation/providers/trip_provider/trip_provider.dart';
import '/gen/assets.gen.dart';
import '/utils/constant.dart';
import '/utils/style.dart';
import '../../../../../core/presentation/helpers/localization_helper.dart';
import '../../../../../utils/logger.dart';
import '../../../domain/drive_mode.dart';
import '../../providers/drive_mode_provider/drive_mode_provider.dart';
import '../../providers/project_provider/project_provider.dart';
import '../../providers/trip_provider/trip_error_provider.dart';
import '../../providers/trip_provider/trip_state.dart';
import 'popups/after_end_trip_dialog.dart';
import 'popups/force_close_popup.dart';
import 'popups/histories_trips.dart';
import 'popups/setup_info.dart';
import 'widgets/action_panel.dart';
import 'widgets/home_app_bar.dart';
import 'widgets/trip_creation_screen.dart';
import 'widgets/unsynced_data_banner.dart';

part 'widgets/action_panels_section.dart';
part 'widgets/drive_mode_panel.dart';
part 'widgets/force_close_button.dart';
part 'widgets/status_message_section.dart';

const platform = MethodChannel('android_app_retain');

/// A compact version of the Home Screen that manages the trip lifecycle,
/// displays trip-related information, and provides GPS data utilities.
///
/// This screen is implemented as a `StatefulHookConsumerWidget` to leverage
/// Riverpod for state management and hooks for lifecycle handling.
class HomeScreenCompact extends StatefulHookConsumerWidget {
  /// Creates a new instance of [HomeScreenCompact].
  const HomeScreenCompact({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _HomeScreenCompactState();
}

/// The state class for [HomeScreenCompact].
///
/// This class handles app lifecycle events, initializes services, listens for
/// trip error status changes, and provides the main UI for the compact home screen.
class _HomeScreenCompactState extends ConsumerState<HomeScreenCompact> {
  /// Controller for the origin input field.
  final originController = TextEditingController();

  /// Controller for the new input field.
  final newController = TextEditingController();

  @override
  void initState() {
    super.initState();
    logger.log('home_screen_compat#initState');
    _initializeServices();
  }

  /// Initializes necessary services, such as fetching the latest incomplete trip
  /// and loading history trips data.
  void _initializeServices() {
    ref.read(tripManagerProvider.notifier).getLatestTripUncomplete();
    // Initialize history trips data for first launch
    ref.read(historiesTripProvider);
  }

  /// Sends the app to the background on Android devices.
  ///
  /// This method uses a platform channel to invoke the `sendToBackground` method
  /// on the native Android side.
  Future<void> _sendToBackground() async {
    if (!Platform.isAndroid) return;
    try {
      await platform.invokeMethod('sendToBackground');
    } on Exception catch (e) {
      debugPrint('Error sending app to background: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for error status changes (강제종료 부분)
    ref.listen<TripErrorStatus?>(tripErrorProvider, (previous, current) {
      if (current != null) {
        // Only show dialog if it's a recent error (within last 10 seconds)
        final isRecent =
            DateTime.now().difference(current.timestamp).inSeconds < 10;

        if (isRecent && mounted) {
          final message = current.status == 'FORCE'
              ? tr(context).forceTripMsg
              : tr(context).cancelTripMsg;

          Dialogs.showErrorDialog(context, message: message);

          // Clear the error status after showing dialog
          ref.read(tripErrorProvider.notifier).clear();
        }
      }
    });

    final moving = ref
        .watch(tripManagerProvider.select((s) => s.toNullable()?.trip != null));

    logger.log('HomeScreenCompact build');

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _sendToBackground();
      },
      child: NestedScreenScaffold(
        body: Scaffold(
          appBar: HomeAppBar(ref: ref),
          body: InteractiveViewer(
            minScale: 0.5,
            maxScale: 3.0,
            child: Column(
              children: [
                const SizedBox(height: 10),
                // Show toggle button for switching mode
                //const SizedBox(height: 16),
                const DriveModePanel(), // 운행 모드
                // Use the already extracted ActionPanelsSection
                ActionPanelsSection(ref: ref), // 현장 및 화물 선택, 최근 운행 내역
                const SizedBox(height: Sizes.marginH16),
                // Extract status message section
                const StatusMessageSection(), // 상태메세지 부분
                // Extract force close button
                if (moving) const ForceCloseButton(),

                if (!moving) ...[
                  const SizedBox(height: 20),
                  const UnsyncedDataBanner(), // 인터넷 안되도 서버로 넣을수 있게 하는 부분.
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
