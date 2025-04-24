import 'package:flutter/material.dart';

import '../../../core/presentation/utils/fp_framework.dart';
import '../../../core/presentation/utils/riverpod_framework.dart';
import '../../domain/driver.dart';
import '../../infrastructure/repos/auth_repo.dart';

part 'auth_state_provider.g.dart';

/// A persistent provider that manages the authentication state of the application.
///
/// This provider stores the currently authenticated [Driver] as an [Option] type,
/// which can be either [Some] containing a driver when authenticated, or [None]
/// when no user is authenticated.
///
/// The provider automatically attempts to restore the authentication state from
/// local storage when first initialized.
@Riverpod(keepAlive: true)
class AuthState extends _$AuthState {
  @override

  /// Builds the initial authentication state by attempting to restore from local storage.
  ///
  /// Returns [Some] containing a [Driver] if found in storage, or [None] if no user is found.
  Option<Driver> build() {
    // Try to restore auth state immediately when provider is created
    final driver = ref.read(authRepoProvider).getLatestSS();
    if (driver != null) {
      debugPrint('AuthState: Found user in local storage');
      return Some(driver);
    }
    debugPrint('AuthState: No user found in local storage, returning None');
    return const None();
  }

  /// Updates the authentication state to reflect a successful user authentication.
  ///
  /// @param user The authenticated [Driver] object to store in the state.
  void authenticateUser(Driver user) {
    state = Some(user);
  }

  /// Clears the authentication state when a user logs out or authentication becomes invalid.
  ///
  /// Sets the state to [None], indicating no authenticated user.
  void unAuthenticateUser() {
    state = const None();
  }

  /// Updates the currently authenticated user's information or clears it.
  ///
  /// @param data The updated [Driver] data. If null, clears the authentication state.
  void updateUser(Driver? data) {
    if (data == null) {
      state = const None();
      state.fold(
        None.new,
        (_) => {},
      );
    } else {
      state = Some(data);
      state.fold(
        () {},
        (user) => state = Some(data),
      );
    }
  }
}
