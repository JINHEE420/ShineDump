import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:radio_group_v2/radio_group_v2.dart';

import '../../../../../../core/infrastructure/network/network_info.dart';
import '../../../../../../core/infrastructure/services/connection_stream_service.dart';
import '../../../../../../core/presentation/helpers/localization_helper.dart';
import '../../../../../../core/presentation/utils/fp_framework.dart';
import '../../../../../../core/presentation/widgets/app_dialog.dart';
import '../../../../../../core/presentation/widgets/custom_elevated_button.dart';
import '../../../../../../core/presentation/widgets/toasts.dart';
import '../../../../../../gen/assets.gen.dart';
import '../../../../domain/area.dart';
import '../../../../domain/project.dart';
import '../../../providers/area_provider/area_provider.dart';
import '../../../providers/project_provider/project_provider.dart';
import '../../../providers/trip_provider/trip_provider.dart';
import 'setting_area_unloading.dart';

/// A popup widget that allows the user to forcefully close a trip.
///
/// This widget provides options for the user to select a reason for force-closing
/// the trip and optionally specify an unloading area. It also handles network
/// connectivity checks and invokes a callback upon successful completion.
class ForceClosePopup extends StatefulHookConsumerWidget {
  /// Creates a [ForceClosePopup].
  ///
  /// The [callback] is invoked after the trip is forcefully closed.
  const ForceClosePopup({
    required this.callback,
    super.key,
  });

  /// A callback function that is executed after the trip is forcefully closed.
  final VoidCallback callback;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ForceClosePopupState();
}

class _ForceClosePopupState extends ConsumerState<ForceClosePopup> {
  final myController = RadioGroupController<String>();

  /// Forcefully ends the trip with the specified [reason] and optional [unloadingAreaId].
  ///
  /// This method checks for network connectivity before proceeding. If the network
  /// is unavailable, a toast message is displayed. Otherwise, it invokes the
  /// `forceEndTrip` method from the trip provider and executes the callback.
  Future<void> _forceEndTrip({
    required BuildContext context,
    required String reason,
    int? unloadingAreaId,
  }) async {
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
    await tripProvider.forceEndTrip(
      reason,
      unloadingAreaId: unloadingAreaId,
    );

    widget.callback();
    if (context.mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final project = ref.watch(projectStateProvider).getOrElse(Project.blank);

    final selectedAreaUnLoading =
        ref.watch(areaUnLoadingStateProvider).getOrElse(Area.blank);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildTitle(tr(context).forceCloseReason),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
            child: buildTitle(tr(context).unloadingPlace),
          ),
          buildOption(
            selectedAreaUnLoading.name,
            callback: () {
              AppDialog.showDialog(
                context,
                SettingAreaUnloadingWidget(
                  callback: (v) {
                    ref.read(areaUnLoadingStateProvider.notifier).setArea(v);
                    AppDialog.closeDialog(context);
                  },
                  projectId: project.id,
                  title: tr(context).selectUnloadingPlace,
                ),
                maxHeight: size.height * .5,
                isShowClose: false,
              );
            },
          ),
          const SizedBox(height: 10),
          RadioGroup<String>(
            controller: myController,
            values: [
              tr(context).reasonButtonNotPressed,
              tr(context).reasonCurrentLocationIsDestination,
              tr(context).reasonDeviceOrNetworkError,
              tr(context).reasonOther,
            ],
            indexOfDefault: 0,
            decoration: const RadioGroupDecoration(
              spacing: 10,
              labelStyle: TextStyle(
                color: Colors.black,
              ),
              activeColor: Color(0xFF1E386D),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Row(
              children: [
                Expanded(
                  child: CustomElevatedButton(
                    buttonColor: Colors.white,
                    borderColor: Colors.grey,
                    padding: const EdgeInsets.all(10),
                    onPressed: () {
                      AppDialog.closeDialog(context);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Assets.icons.icCloseSquare.image(width: 20),
                        Text(
                          tr(context).cancelButton,
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
                    padding: const EdgeInsets.all(10),
                    onPressed: () => _forceEndTrip(
                      context: context,
                      reason: myController.value ?? '',
                      unloadingAreaId: selectedAreaUnLoading.id,
                    ),
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
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  /// Builds a selectable option widget with the given [title].
  ///
  /// The [callback] is executed when the option is tapped.
  Widget buildOption(String title, {VoidCallback? callback}) {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 20,
      ),
      child: GestureDetector(
        onTap: callback,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF352555),
                  fontWeight: FontWeight.w400,
                  fontSize: 15,
                  height: 20.4 / 15,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Assets.icons.icForward.image(height: 15),
          ],
        ),
      ),
    );
  }

  /// Builds a title widget with the given [title].
  Widget buildTitle(String title) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      alignment: Alignment.topLeft,
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF352555),
          fontWeight: FontWeight.w700,
          fontSize: 15,
          height: 20.4 / 15,
        ),
      ),
    );
  }
}
