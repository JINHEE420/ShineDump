import 'dart:async';

import '../../../core/presentation/utils/fp_framework.dart';
import '../../../core/presentation/utils/riverpod_framework.dart';

part 'sign_out_provider.g.dart';

/// A provider that manages the sign-out process state.
///
/// This provider tracks the state of the sign-out operation and provides
/// functionality to sign out the current user. The state is represented as
/// an [Option] of [Unit], where:
/// - [None] indicates no sign-out operation has been attempted or completed
/// - [Some] with [Unit] value indicates a successful sign-out operation
@riverpod
class SignOutState extends _$SignOutState {
  /// Initializes the sign-out state to [None], indicating no sign-out
  /// operation has been performed.
  ///
  /// Returns an [Option] of [Unit] representing the initial state.
  @override
  FutureOr<Option<Unit>> build() => const None();

  /// Initiates the sign-out process for the current user.
  ///
  /// This method should handle the authentication service's sign-out operation
  /// and update the state accordingly.
  ///
  /// Returns a [Future] that completes when the sign-out operation finishes.
  Future<void> signOut() async {}
}
