import 'package:flutter/material.dart';

import '../../../../../../core/presentation/helpers/localization_helper.dart';
import '../../../../../../core/presentation/utils/riverpod_framework.dart';
import '../../../../../../core/presentation/widgets/app_dialog.dart';
import '../../../../../../utils/logger.dart';
import '../../../../../../utils/setup_job_step.dart';
import '../../../providers/area_provider/area_provider.dart';
import '../../../providers/project_provider/project_provider.dart';
import '../../../providers/site_provider/site_provider.dart';
import 'over_view.dart';
import 'setting_area.dart';
import 'setting_area_unloading.dart';
import 'setting_project.dart';
import 'setting_site.dart';

/// A widget that guides the user through a multi-step setup process.
///
/// The `SetupInfoWidget` is a `HookConsumerWidget` that manages the state and
/// navigation between different setup steps, including selecting a site,
/// project, loading area, and unloading area. Each step is represented by a
/// specific widget, and the user progresses through the steps sequentially.
///
/// ### Steps:
/// 1. **Site Selection**: The user selects a site using `SettingSiteWidget`.
/// 2. **Project Selection**: The user selects a project using `SettingProjectWidget`.
/// 3. **Loading Area Selection**: The user selects a loading area using `SettingAreaWidget`.
/// 4. **Unloading Area Selection**: The user selects an unloading area using `SettingAreaUnloadingWidget`.
///
/// Once all steps are completed, an overview dialog is displayed summarizing
/// the selected options.
///
/// ### Parameters:
/// - `callback`: An optional callback function that is triggered after the
///   setup process is completed.
///
/// ### State Management:
/// The widget uses `useState` hooks to manage the state of the selected IDs
/// (`siteId`, `projectId`, `areaId`, `unloadingAreaId`) and the current step
/// (`settingStep`). It also interacts with Riverpod state providers to update
/// the global state for the selected site, project, and areas.
///
/// ### Example Usage:
/// ```dart
/// SetupInfoWidget(
///   callback: () {
///     // Perform actions after setup is complete
///   },
/// )
/// ```
///
/// This widget is designed to be used in scenarios where a hierarchical setup
/// process is required, such as configuring a project or selecting locations.
class SetupInfoWidget extends HookConsumerWidget {
  const SetupInfoWidget({super.key, this.callback});

  final VoidCallback? callback;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final siteId = useState(0);
    final projectId = useState(0);
    final areaId = useState(0);
    final unloadingAreaId = useState(0);
    final settingStep = useState(SetupInfoStep.site);

    Widget currentStepWidget;

    if (settingStep.value == SetupInfoStep.site) {
      currentStepWidget = SettingSiteWidget(
        callback: (v) {
          siteId.value = v.id;
          ref.read(siteStateProvider.notifier).setCurrentSite(v);
          settingStep.value = SetupInfoStep.project;
        },
        title: tr(context).selectHeadquarters,
      );
    } else if (settingStep.value == SetupInfoStep.project) {
      currentStepWidget = SettingProjectWidget(
        siteId: siteId.value,
        callback: (v) {
          projectId.value = v.id;
          ref.read(projectStateProvider.notifier).setCurrentProject(v);
          settingStep.value = SetupInfoStep.area;
        },
        title: tr(context).selectProject,
        onBack: () {
          settingStep.value = SetupInfoStep.site;
        },
      );
    } else if (settingStep.value == SetupInfoStep.area) {
      currentStepWidget = SettingAreaWidget(
        projectId: projectId.value,
        callback: (v) {
          areaId.value = v.id;
          ref.read(areaLoadingStateProvider.notifier).setArea(v);
          settingStep.value = SetupInfoStep.unloadingArea;
        },
        title: tr(context).selectLoadingPlace,
        onBack: () {
          settingStep.value = SetupInfoStep.project;
        },
      );
    } else {
      currentStepWidget = SettingAreaUnloadingWidget(
        projectId: projectId.value,
        title: tr(context).selectUnloadingPlace,
        onBack: () {
          settingStep.value = SetupInfoStep.area;
        },
        callback: (v) {
          unloadingAreaId.value = v.id;
          ref.read(areaUnLoadingStateProvider.notifier).setArea(v);
          AppDialog.closeDialog(context);

          Future.delayed(
            const Duration(milliseconds: 500),
            () {
              AppDialog.showDialog(
                context,
                OverViewWidget(
                  siteId: siteId.value,
                  projectId: projectId.value,
                  loadingAreaId: areaId.value,
                  unLoadingAreaId: unloadingAreaId.value,
                  callback: callback,
                ),
                maxHeight: MediaQuery.of(context).size.height * .55,
                isShowClose: false,
              );
            },
          );
        },
      );
    }

    return InteractiveViewer(
      minScale: 0.8,
      maxScale: 2.5,
      panEnabled: true,
      scaleEnabled: true,
      child: SingleChildScrollView(
        child: currentStepWidget,
      ),
    );
  }
}
