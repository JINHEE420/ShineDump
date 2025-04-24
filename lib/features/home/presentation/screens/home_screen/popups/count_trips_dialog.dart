import 'package:flutter/material.dart';
import 'package:fpdart/src/extension/option_extension.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../../core/infrastructure/network/network_info.dart';
import '../../../../../../core/infrastructure/services/connection_stream_service.dart';
import '../../../../../../core/presentation/helpers/localization_helper.dart';
import '../../../../../../core/presentation/widgets/custom_elevated_button.dart';
import '../../../../../../core/presentation/widgets/dialogs.dart';
import '../../../../../../core/presentation/widgets/toasts.dart';
import '../../../../../../gen/assets.gen.dart';
import '../../../../../../utils/style.dart';
import '../../../../domain/area.dart';
import '../../../../infrastructure/data_sources/gps_remote_data_source.dart';
import '../../../providers/area_provider/area_provider.dart';
import '../../../providers/trip_provider/trip_provider.dart';

/// A widget that displays a dialog for ending the current trip operation.
///
/// The dialog provides options to confirm or cancel the operation.
/// It checks for network connectivity before proceeding with the trip-ending
/// operation and handles any errors that may occur during the process.
class CountTrips extends StatelessWidget {
  const CountTrips({super.key});

  /// Handles the logic for ending the trip.
  ///
  /// This method checks for network connectivity, invokes the trip-ending
  /// operation, and handles any errors that may arise. If the operation is
  /// successful, it closes the dialog and returns a success response.
  ///
  /// [context] - The build context of the widget.
  /// [ref] - The Riverpod widget reference for accessing providers.
  Future<void> _onEndTrip(BuildContext context, WidgetRef ref) async {
    try {
      final endTripMessage = tr(context).endTripMessage;
      // check if network is available
      if (!await ref.read(networkInfoProvider).hasInternetConnection) {
        if (context.mounted) {
          Toasts.showConnectionToast(
            context,
            connectionStatus: ConnectionStatus.disconnected,
          );
        }
        return;
      }

      final tripProvider = ref.read(tripManagerProvider.notifier);
      await tripProvider.endTrip(message: endTripMessage);

      if (context.mounted) context.pop(true);
    } catch (e) {
      if (context.mounted) {
        await _handleTripEndingError(e, context);
      }
    }
  }

  /// Handles errors that occur during the trip-ending operation.
  ///
  /// If the error is a [ForceEndTripException], it extracts and displays
  /// the error message in a dialog.
  ///
  /// [error] - The error that occurred.
  /// [context] - The build context of the widget.
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
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final areaLoading =
            ref.read(areaLoadingStateProvider).getOrElse(Area.blank);
        return Container(
          height: 200,
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr(context).operationType,
                style: gpsTextStyle(
                  weight: FontWeight.w700,
                  fontSize: 20,
                  lineHeight: 21,
                ),
              ),
              Container(
                alignment: Alignment.center,
                height: 45,
                margin: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 20,
                ),
                child: Text(
                  tr(context).endTodaysOperationForSite(areaLoading.name),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: CustomElevatedButton(
                      buttonColor: Colors.white,
                      borderColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 15,
                      ),
                      onPressed: () async {
                        context.pop();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Assets.icons.icCloseSquare.image(width: 20),
                          Text(
                            tr(context).no,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 30),
                  Expanded(
                    child: CustomElevatedButton(
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 15,
                      ),
                      onPressed: () => _onEndTrip(context, ref),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Assets.icons.icChecked.image(width: 20),
                          Text(
                            tr(context).yes,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
