import '../../../core/infrastructure/network/apis/apis.dart';
import '../../../core/presentation/utils/riverpod_framework.dart';
import '../../domain/sign_in_with_vehicle_info.dart';
import '../dtos/driver_dto.dart';

part 'auth_remote_data_source.g.dart';

/// Provides a singleton instance of [AuthRemoteDataSource].
///
/// This provider is kept alive for the entire application lifecycle.
@Riverpod(keepAlive: true)
AuthRemoteDataSource authRemoteDataSource(Ref ref) {
  return AuthRemoteDataSource(
    ref,
    driverService:
        ref.watch(apiServiceProvider).client.getService<DriverService>(),
  );
}

/// Handles remote authentication operations for drivers.
///
/// This data source is responsible for communicating with the backend
/// authentication services, specifically for driver authentication
/// using vehicle information.
class AuthRemoteDataSource {
  /// Creates an instance of [AuthRemoteDataSource].
  ///
  /// Requires a Riverpod [ref] for state management and access to other providers,
  /// and a [driverService] to make API calls related to driver authentication.
  AuthRemoteDataSource(
    this.ref, {
    required this.driverService,
  });

  /// The Riverpod ref used for accessing other providers.
  final Ref ref;

  /// Service for making API calls related to driver operations.
  final DriverService driverService;

  /// Authenticates a driver using vehicle information.
  ///
  /// Takes [SignInWithVehicleInfo] parameters containing the driver's name,
  /// phone number, and vehicle number.
  ///
  /// Returns a [DriverDto] if authentication is successful, otherwise null.
  Future<DriverDto?> signInWithVehicleInfo(SignInWithVehicleInfo params) async {
    final rs = await driverService.signInVehicle({
      'name': params.name,
      'phone': params.phoneNumber,
      'vehicle_number': params.vehicleNumber,
    });

    return rs.body?.data;
  }
}
