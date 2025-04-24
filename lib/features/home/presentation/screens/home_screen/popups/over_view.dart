import 'package:flutter/material.dart';

import '../../../../../../core/presentation/helpers/localization_helper.dart';
import '../../../../../../core/presentation/utils/fp_framework.dart';
import '../../../../../../core/presentation/utils/riverpod_framework.dart';
import '../../../../../../core/presentation/widgets/app_dialog.dart';
import '../../../../../../core/presentation/widgets/custom_elevated_button.dart';
import '../../../../../../core/presentation/widgets/gps_dropdown.dart';
import '../../../../../../gen/assets.gen.dart';
import '../../../../../../utils/mertial-v.dart';
import '../../../../domain/area.dart';
import '../../../../domain/project.dart';
import '../../../../domain/site.dart';
import '../../../providers/area_provider/area_provider.dart';
import '../../../providers/project_provider/project_provider.dart';
import '../../../providers/site_provider/site_provider.dart';
import '../../../providers/trip_provider/trip_provider.dart';
import 'setting_area.dart';
import 'setting_area_unloading.dart';

/// A widget that provides an overview of the loading and unloading areas,
/// along with the ability to select materials and manage trips.
///
/// The `OverViewWidget` is designed to display and manage the following:
/// - Loading and unloading areas, allowing users to select or update them.
/// - Material selection using a dropdown menu.
/// - Trip management, including confirming or canceling trips.
///
/// ### Parameters:
/// - [siteId]: The ID of the site associated with the widget.
/// - [projectId]: The ID of the project associated with the widget.
/// - [loadingAreaId]: The ID of the loading area.
/// - [unLoadingAreaId]: The ID of the unloading area.
/// - [callback]: An optional callback function triggered after confirming.
///
/// ### Usage:
/// ```dart
/// OverViewWidget(
///   siteId: 1,
///   projectId: 2,
///   loadingAreaId: 3,
///   unLoadingAreaId: 4,
///   callback: () {
///     // Perform actions after confirmation
///   },
/// )
/// ```
class OverViewWidget extends HookConsumerWidget {
  const OverViewWidget({
    required this.siteId,
    required this.projectId,
    required this.loadingAreaId,
    required this.unLoadingAreaId,
    super.key,
    this.callback,
  });

  final int siteId;
  final int projectId;
  final int loadingAreaId;
  final int unLoadingAreaId;

  final VoidCallback? callback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;

    final site = ref.watch(siteStateProvider).getOrElse(Site.blank);

    final project = ref.watch(projectStateProvider).getOrElse(Project.blank);

    final selectedAreaLoading =
        ref.watch(areaLoadingStateProvider).getOrElse(Area.blank);

    final selectedAreaUnLoading =
        ref.watch(areaUnLoadingStateProvider).getOrElse(Area.blank);
    return Container(
      constraints: BoxConstraints(
        minHeight: size.height * .3,
        minWidth: size.width * .7,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildTitle(tr(context).loadingPlace),
                  buildOption(
                    selectedAreaLoading.name,
                    callback: () {
                      AppDialog.showDialog(
                        context,
                        SettingAreaWidget(
                          callback: (v) {
                            ref
                                .read(areaLoadingStateProvider.notifier)
                                .setArea(v);
                            AppDialog.closeDialog(context);
                          },
                          projectId: projectId,
                          title: tr(context).selectLoadingPlace,
                        ),
                        maxHeight: size.height * .5,
                        isShowClose: false,
                      );
                    },
                  ),
                  buildTitle(tr(context).unloadingPlace),
                  buildOption(
                    selectedAreaUnLoading.name,
                    callback: () {
                      AppDialog.showDialog(
                        context,
                        SettingAreaUnloadingWidget(
                          callback: (v) {
                            ref
                                .read(areaUnLoadingStateProvider.notifier)
                                .setArea(v);
                            AppDialog.closeDialog(context);
                          },
                          projectId: projectId,
                          title: tr(context).selectUnloadingPlace,
                        ),
                        maxHeight: size.height * .5,
                        isShowClose: false,
                      );
                    },
                  ),
                  buildTitle(tr(context).cargo),
                  GpsDropDown(
                    items: MaterialV.values,
                    displayStringForOption: (e) => e?.display() ?? '',
                    textPadding: const EdgeInsets.all(10),
                    value: selectedMaterial,
                    onChanged: (value) {
                      if (value != null) {
                        selectedMaterial = value;
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
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
                  onPressed: () {
                    AppDialog.closeDialog(context);
                    final moving = ref.watch(
                      tripManagerProvider
                          .select((s) => s.toNullable()?.trip != null),
                    );
                    if (moving) {
                      return;
                    }
                    ref.read(tripManagerProvider.notifier).clearCurrentTrip();
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
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 15,
                  ),
                  onPressed: () async {
                    AppDialog.closeDialog(context);
                    final tripProvider = ref.read(tripManagerProvider.notifier);
                    if (tripProvider.trip != null) {
                      await tripProvider.updateTrip(
                        site.id,
                        project.id,
                        selectedAreaLoading.id,
                        selectedAreaUnLoading.id,
                      );
                    }

                    if (callback != null) {
                      callback?.call();
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Assets.icons.icChecked.image(width: 20),
                      Text(
                        tr(context).confirmButton,
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
          const SizedBox(height: 5),
        ],
      ),
    );
  }

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

  Widget buildTitle(String title) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
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
