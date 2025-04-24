import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_in_with_vehicle_info.freezed.dart';

@freezed
class SignInWithVehicleInfo with _$SignInWithVehicleInfo {
  const factory SignInWithVehicleInfo({
    // Note: You should consider using separate value object (with its validator method)
    // for these values if they're used in other entities.
    required String name,
    required String vehicleNumber,
    required String phoneNumber,
  }) = _SignInWithVehicleInfo;
}
