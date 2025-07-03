import '../../../core/infrastructure/network/network_info.dart'; // 네트워크 상태 확인
import '../../../core/presentation/utils/riverpod_framework.dart'; // Riverpod 관련 설정
import '../../domain/driver.dart'; //Driver 도메인 모델
import '../../domain/sign_in_with_vehicle_info.dart'; // 차량정보 기반 로그인 요청 모델
import '../../domain/user.dart'; // 사용자(User) 모델
import '../data_sources/auth_local_data_source.dart'; // 로컬 데이터 관련 클래스
import '../data_sources/auth_remote_data_source.dart'; // 서버 통신 관련 클래스

part 'auth_repo.g.dart'; //@Riverpod를 통해 코드 생성을 할 수 있도록 .g.dart 파일을 포함시킴

/// 이 코드는 Riverpod에서 AuthRepo 인스턴스를 제공하는 provider를 선언합니다
/// keepAlive: true → 앱이 종료되지 않는 이상 상태가 계속 유지됩니다.
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
  /// 로컬 저장소에 저장된 드라이버 데이터를 불러옵니다.
  Driver? getLatestSS() {
    return localDataSource.getDriver();
  }

  /// Clears the cached driver data from local storage.
  /// 로컬 저장소에 있는 드라이버 정보를 삭제합니다.
  Future<void> clearSS() async {
    return localDataSource.clearDriver();
  }
}
