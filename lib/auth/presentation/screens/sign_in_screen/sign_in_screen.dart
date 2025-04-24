import 'package:flutter/material.dart';

import '../../../../core/core_features/local_storage/local_storage_manager.dart';
import '../../../../core/presentation/utils/riverpod_framework.dart';
import '../../../../core/presentation/widgets/responsive_widgets/responsive_layouts.dart';
import '../../providers/sign_in_provider.dart';
import '../policy_screen/policy_screen.dart';
import 'sign_in_screen_compact.dart';

/// A screen widget that handles user sign-in functionality.
///
/// This widget serves as the entry point for user authentication in the app.
/// It includes the following features:
/// * Monitors sign-in state changes through [signInStateProvider]
/// * Checks if this is the first app installation to show policy acceptance
///   screen when needed
/// * Implements responsive layouts to adapt to different screen sizes
///
/// The widget uses local storage to determine if the app is being launched
/// for the first time, directing users to the [PolicyScreen] for first-time
/// installations. For regular use, it displays the sign-in interface
/// through [SignInScreenCompact].
class SignInScreen extends HookConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.easyListen(signInStateProvider);

    useEffect(
      () {
        final localStorage = ref.watch(localStorageManagerProvider);
        localStorage.getValue<bool>(LocalStorageKeys.isFirstInstall).then((v) {
          if (!(v ?? false)) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const PolicyScreen(),
              ),
            );
          }
        });
        return null;
      },
      [],
    );

    return WindowClassLayout(
      compact: (_) => OrientationLayout(
        portrait: (_) => const SignInScreenCompact(),
      ),
    );
  }
}
