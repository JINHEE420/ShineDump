import '../../../core/presentation/utils/fp_framework.dart';
import '../../../core/presentation/utils/riverpod_framework.dart';
import '../../domain/driver.dart';
import '../../domain/sign_in_with_vehicle_info.dart';
import '../../infrastructure/repos/auth_repo.dart';
import 'auth_state_provider.dart';

part 'sign_in_provider.g.dart';

/// A Riverpod provider state class that manages the authentication workflow.
///
/// This class handles driver sign-in, sign-out operations, and loading driver data
/// from persistent storage. It uses [Option] to represent the authentication state,
/// where [None] indicates the unauthenticated/idle state and [Some] indicates
/// a successful authentication with a [Driver] object.
@riverpod
class SignInState extends _$SignInState {
  /// Builds the initial state of the authentication.
  ///
  /// Returns [None] to represent the unauthenticated/idle state.
  @override
  FutureOr<Option<Driver>> build() => const None();

  /// Signs in a driver using vehicle information.
  ///
  /// Sets the state to [AsyncLoading] during the sign-in process.
  /// Updates the [authStateProvider] with the signed-in driver if successful.
  ///
  /// Parameters:
  ///   - [params]: The vehicle information required for authentication.
  ///
  /// Returns a future that completes when the sign-in attempt is finished.
  Future<void> signIn(SignInWithVehicleInfo params) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () async {
        final authRepo = ref.read(authRepoProvider);
        final user = await authRepo.signInWithVehicleInfo(params);

        if (user == null) {
          return const None();
        } else {
          ref.read(authStateProvider.notifier).updateUser(user);
          return Some(user);
        }
      },
    );
  }

  /// Loads the saved driver data from secure storage.
  ///
  /// Returns the [Driver] object if available, otherwise null.
  Future<Driver?> loadDataDriver() async {
    final authRepo = ref.read(authRepoProvider);
    return authRepo.getLatestSS();
  }

  /// Signs out the current driver.
  ///
  /// Clears the secure storage and updates the auth state to reflect
  /// that no user is currently authenticated.
  Future<void> signout() async {
    final authRepo = ref.read(authRepoProvider);
    await authRepo.clearSS();
    ref.read(authStateProvider.notifier).updateUser(null);
  }
}
