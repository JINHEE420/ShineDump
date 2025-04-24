import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fpdart/src/extension/option_extension.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/core_features/pip_service.dart';
import '../../../../../../core/infrastructure/services/local_notifications_service.dart';
import '../../../../../../core/presentation/helpers/localization_helper.dart';
import '../../../../../../core/presentation/screens/nested_screen_scaffold.dart';
import '../../../../../../core/presentation/utils/riverpod_framework.dart';
import '../../../../../../core/presentation/widgets/loading_widgets.dart';
import '../../../../domain/area.dart';
import '../../../../domain/move_status.dart';
import '../../../../domain/project.dart';
import '../../../../domain/site.dart';
import '../../../components/retry_again_component.dart';
import '../../../providers/area_provider/area_provider.dart';
import '../../../providers/project_provider/project_provider.dart';
import '../../../providers/site_provider/site_provider.dart';
import '../../../providers/trip_provider/trip_provider.dart';

/// A screen that facilitates trip creation and enables background services.
///
/// This widget is responsible for:
/// * Creating a new trip with selected site, project, and areas
/// * Enabling picture-in-picture mode for background operation
/// * Setting up local notifications for trip status updates
/// * Handling error states with retry capability
///
/// The screen shows different UI states:
/// * Loading indicator during trip creation
/// * Error with retry option when creation fails
/// * Automatically enables PiP mode and returns to previous screen on success
///
/// This screen uses a [PopScope] to prevent accidental navigation during the process.
class TripCreationScreen extends HookConsumerWidget {
  const TripCreationScreen({super.key});

  /// Enables background services required for trip tracking.
  ///
  /// This method:
  /// * Shows a notification that the trip is now moving
  /// * Enables picture-in-picture mode with dimensions relative to screen size
  /// * Navigates back to the previous screen after a brief delay
  /// * Handles any errors that occur during service initialization
  ///
  /// @param context The BuildContext for UI operations
  /// @param ref The WidgetRef to access providers
  Future<void> _enableServices(BuildContext context, WidgetRef ref) async {
    try {
      final size = MediaQuery.of(context).size;

      // Show notification that the trip is now moving
      await ref
          .read(localNotificationsServiceProvider)
          .showNotification(MoveStatus.moving.display());

      // Enable picture-in-picture mode with size based on screen dimensions
      final pip = ref.read(pipServiceProvider);
      await pip.enable(width: size.width * .4, height: size.height * .25);

      // Wait a moment to allow services to initialize, then navigate back
      await Future.delayed(const Duration(seconds: 1), () {
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      });

      // Log success
      debugPrint('Services enabled: notifications and PiP');
    } catch (e) {
      // Log errors but don't block the UI
      debugPrint('Error enabling services: $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSite = ref.read(siteStateProvider).getOrElse(Site.blank);
    final selectedProject =
        ref.read(projectStateProvider).getOrElse(Project.blank);
    final selectedAreaLoading =
        ref.read(areaLoadingStateProvider).getOrElse(Area.blank);
    final selectedAreaUnLoading =
        ref.read(areaUnLoadingStateProvider).getOrElse(Area.blank);

    // Watch the create trip provider
    final createTrip = ref.watch(
      createTripStateProvider.call(
        selectedSite.id,
        selectedProject.id,
        selectedAreaLoading.id,
        selectedAreaUnLoading.id,
      ),
    );

    return PopScope(
      canPop: false,
      child: NestedScreenScaffold(
        body: Scaffold(
          appBar: AppBar(
            leading: GestureDetector(
              onTap: () {
                context.pop();
              },
              child: const Icon(
                Icons.arrow_back_ios_new_outlined,
                color: Colors.black,
              ),
            ),
          ),
          body: createTrip.when(
            skipLoadingOnReload: true,
            skipLoadingOnRefresh: !createTrip.hasError,
            loading: () => const TitledLoadingIndicator(message: ''),
            error: (error, st) => RetryAgainComponent(
              description: tr(context).tripCreationFailed,
              onPressed: () {
                // Invalidate the provider to trigger a refresh
                ref.invalidate(
                  createTripStateProvider(
                    selectedSite.id,
                    selectedProject.id,
                    selectedAreaLoading.id,
                    selectedAreaUnLoading.id,
                  ),
                );
              },
            ),
            data: (_) {
              // Enable notification and PiP services first
              unawaited(_enableServices(context, ref));

              // Show a subtle success indicator while we wait
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
