import '../../../core/infrastructure/network/network_info.dart';
import '../../../core/presentation/utils/riverpod_framework.dart';
import '../../domain/driver.dart';
import '../../domain/sign_in_with_vehicle_info.dart';
import '../../domain/user.dart';
import '../data_sources/auth_local_data_source.dart';
import '../data_sources/auth_remote_data_source.dart';

part 'auth_repo.g.dart';

/// Provides an instance of [AuthRepo] through Riverpod.
/// The provider is kept alive throughout the app's lifecycle.
@Riverpod(keepAlive: true)
AuthRepo authRepo(Ref ref) {
  return AuthRepo(
    networkInfo: ref.watch(networkInfoProvider),
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    localDataSource: ref.watch(authLocalDataSourceProvider),
  );
}

/// Repository responsible for handling authentication operations.
///
/// This class manages authentication-related operations, including user data retrieval,
/// driver sign-in with vehicle information, and caching operations. It serves as a mediator
/// between remote and local data sources for authentication functionality.
class AuthRepo {
  /// Creates an instance of [AuthRepo].
  ///
  /// Requires [networkInfo] for checking network connectivity,
  /// [remoteDataSource] for server interactions, and
  /// [localDataSource] for local caching operations.
  AuthRepo({
    required this.networkInfo,
    required this.remoteDataSource,
    required this.localDataSource,
  });

  /// Provides information about network connectivity.
  final NetworkInfo networkInfo;

  /// Handles remote authentication operations with the server.
  final AuthRemoteDataSource remoteDataSource;

  /// Manages local storage of authentication data.
  final AuthLocalDataSource localDataSource;

  /// Retrieves user data for a specific user ID.
  ///
  /// [uid] The unique identifier of the user.
  ///
  /// Returns a [User] object containing user information.
  /// Currently returns a placeholder user - implementation pending.
  Future<User> getUserData(String uid) async {
    return const User(
      id: 'id',
      email: 'email',
      name: 'name',
      phone: 'phone',
      image: 'image',
    );
  }

  /// Authenticates a driver using vehicle information.
  ///
  /// [params] The vehicle information used for authentication.
  ///
  /// Returns a [Driver] object if authentication is successful, null otherwise.
  /// Also caches the driver data locally on successful authentication.
  Future<Driver?> signInWithVehicleInfo(SignInWithVehicleInfo params) async {
    final data = await remoteDataSource.signInWithVehicleInfo(params);
    if (data != null) {
      await localDataSource.cacheDriverData(data.toDomain());

      return data.toDomain();
    }
    return null;
  }

  /// Retrieves the cached driver data from local storage.
  ///
  /// Returns the stored [Driver] object or null if no data is cached.
  Driver? getLatestSS() {
    return localDataSource.getDriver();
  }

  /// Clears the cached driver data from local storage.
  Future<void> clearSS() async {
    return localDataSource.clearDriver();
  }
}
