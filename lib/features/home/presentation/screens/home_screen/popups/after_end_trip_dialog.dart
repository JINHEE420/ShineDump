import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/infrastructure/network/network_info.dart';
import '../../../../../../core/infrastructure/services/connection_stream_service.dart';
import '../../../../../../core/presentation/helpers/localization_helper.dart';
import '../../../../../../core/presentation/utils/riverpod_framework.dart';
import '../../../../../../core/presentation/widgets/app_dialog.dart';
import '../../../../../../core/presentation/widgets/custom_elevated_button.dart';
import '../../../../../../core/presentation/widgets/dialogs.dart';
import '../../../../../../core/presentation/widgets/toasts.dart';
import '../../../../../../utils/constant.dart';
import '../../../../../../utils/style.dart';
import '../../../../infrastructure/data_sources/gps_remote_data_source.dart';
import '../../../providers/trip_provider/trip_provider.dart';
import 'count_trips_dialog.dart';

/// A widget that provides options for the user after ending a trip.
///
/// This widget displays two main options:
/// - Continue to the next operation.
/// - Complete today's operation and end the trip.
///
/// It also handles the logic for ending the trip, including network checks
/// and error handling.
///
/// The widget uses a [ValueNotifier] to manage the state of the selected option.
class AfterEndTripWidgetOptions extends HookConsumerWidget {
  const AfterEndTripWidgetOptions({super.key});

  /// Handles the logic for ending the trip based on the selected option.
  ///
  /// If the "end now" option is selected, it checks for an internet connection
  /// and attempts to end the trip. If an error occurs, it handles the error
  /// appropriately.
  ///
  /// If the "complete today's operation" option is selected, it shows a dialog
  /// to confirm the action.
  ///
  /// - [context]: The [BuildContext] of the widget.
  /// - [ref]: The [WidgetRef] for accessing providers.
  /// - [endNow]: A [ValueNotifier] indicating the selected option.
  Future<void> _onEndTrip(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<bool> endNow,
  ) async {
    if (endNow.value) {
      // check if network is available
      final endTripMessage = tr(context).endTripMessage;
      if (!await ref.read(networkInfoProvider).hasInternetConnection) {
        if (context.mounted) {
          Toasts.showConnectionToast(
            context,
            connectionStatus: ConnectionStatus.disconnected,
          );
        }
        return;
      }

      try {
        await ref.read(tripManagerProvider.notifier).endTrip(
              message: endTripMessage,
            );

        if (context.mounted) {
          context.pop();
        }
      } catch (e) {
        if (context.mounted) {
          await _handleTripEndingError(e, context);
        }
      }
    } else {
      final result = await AppDialog.showDialog(
        context,
        const CountTrips(),
        maxHeight: 250,
      );
      if (result == true && context.mounted) {
        context.pop();
      }
    }
  }

  /// Handles errors that occur during the trip-ending process.
  ///
  /// If the error is a [ForceEndTripException], it extracts and cleans the error
  /// message and displays it in an error dialog.
  ///
  /// - [error]: The error that occurred.
  /// - [context]: The [BuildContext] of the widget.
  Future<void> _handleTripEndingError(
    dynamic error,
    BuildContext context,
  ) async {
    if (error is ForceEndTripException) {
      final cleanMessage = error.message
          .replaceAll('message:', '')
          .replaceAll('}', '')
          .replaceAll('{', '');

      await Dialogs.showErrorDialog(
        context,
        message: cleanMessage,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;

    final endNow = useState(true);

    return Container(
      constraints: BoxConstraints(
        minHeight: size.height * .2,
        maxHeight: size.height * .4,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            height: 54,
            margin: const EdgeInsets.symmetric(
              horizontal: defaultPadding,
              vertical: 20,
            ),
            child: Row(
              children: [
                Checkbox(
                  value: endNow.value == true,
                  onChanged: (value) {
                    endNow.value = true;
                  },
                  activeColor: const Color(0xFF1E386D),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: SizedBox(
                    height: double.infinity,
                    child: CustomElevatedButton(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      borderRadius: BorderRadius.circular(10),
                      buttonColor: const Color(0xFF1E386D),
                      onPressed: () async {
                        endNow.value = true;
                        return;
                      },
                      child: Text(
                        tr(context).continueToNextOperation,
                        style: gpsTextStyle(
                          weight: FontWeight.w700,
                          fontSize: 14,
                          lineHeight: 19,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 54,
            margin: const EdgeInsets.symmetric(
              horizontal: defaultPadding,
              vertical: 10,
            ),
            child: Row(
              children: [
                Checkbox(
                  value: endNow.value == false,
                  onChanged: (value) {
                    endNow.value = false;
                  },
                  activeColor: const Color(0xFF1E386D),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: CustomElevatedButton(
                    padding: const EdgeInsets.all(10),
                    borderRadius: BorderRadius.circular(10),
                    buttonColor: const Color(0xFFF48724),
                    onPressed: () async {
                      endNow.value = false;
                      return;
                    },
                    child: Column(
                      children: [
                        Text(
                          tr(context).completeTodaysOperation,
                          textAlign: TextAlign.center,
                          style: gpsTextStyle(
                            weight: FontWeight.w700,
                            fontSize: 14,
                            lineHeight: 19,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          tr(context).noMoreOperations,
                          textAlign: TextAlign.center,
                          style: gpsTextStyle(
                            weight: FontWeight.w700,
                            fontSize: 14,
                            lineHeight: 19,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: () => _onEndTrip(context, ref, endNow),
            child: Container(
              width: double.infinity,
              alignment: Alignment.center,
              height: 50,
              color: const Color(0xFF1E386D),
              child: Text(
                tr(context).confirmButton,
                style: gpsTextStyle(
                  weight: FontWeight.w700,
                  fontSize: 14,
                  lineHeight: 19,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
