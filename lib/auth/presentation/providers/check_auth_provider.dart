import 'dart:async';

import '../../../auth/infrastructure/repos/auth_repo.dart';
import '../../../auth/presentation/providers/auth_state_provider.dart';
import '../../../auth/presentation/providers/sign_out_provider.dart';
import '../../../core/presentation/utils/fp_framework.dart';
import '../../../core/presentation/utils/riverpod_framework.dart';
import '../../domain/driver.dart';

part 'check_auth_provider.g.dart';

/// A provider that checks and manages authentication state.
///
/// This provider serves as the central authentication coordinator, responsible for:
/// 1. Retrieving the current authentication state when the app initializes
/// 2. Listening to auth state changes and reacting accordingly
/// 3. Handling authentication errors by triggering sign-out flow
///
/// The provider automatically integrates with [authStateProvider] for auth state changes
/// and [signOutStateProvider] for handling authentication failures.
///
/// Returns:
/// * A [Driver] object when the user is authenticated
/// * `null` when no user is authenticated
///
/// Usage:
/// ```dart
/// final driverAsync = ref.watch(checkAuthProvider);
///
/// driverAsync.when(
///   data: (driver) => driver != null ? AuthenticatedView() : LoginView(),
///   loading: () => LoadingView(),
///   error: (error, stack) => ErrorView(),
/// );
/// ```
@riverpod
Future<Driver?> checkAuth(CheckAuthRef ref) async {
  final sub = ref.listen(authStateProvider.notifier, (prev, next) {});
  ref.listenSelf((previous, next) {
    next.whenOrNull(
      data: (user) =>
          user == null ? const None() : sub.read().authenticateUser(user),
      error: (err, st) => ref.read(signOutStateProvider.notifier).signOut(),
    );
  });

  final latestSS = ref.watch(authRepoProvider).getLatestSS();
  return latestSS;
}
