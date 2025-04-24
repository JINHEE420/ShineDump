import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/driver.dart';

part 'driver_dto.g.dart';
part 'driver_dto.freezed.dart';

@freezed
class DriverDto with _$DriverDto {
  const factory DriverDto({
    required int id,
    required String name,
    @JsonKey(name: 'vehicle_number') required String vehicleNumber,
    @JsonKey(name: 'phone') required String phoneNumber,
  }) = _DriverDto;

  const DriverDto._();

  factory DriverDto.fromJson(Map<String, dynamic> json) =>
      _$DriverDtoFromJson(json);

  factory DriverDto.fromDomain(Driver driver) {
    return DriverDto(
      id: driver.id,
      name: driver.name,
      vehicleNumber: driver.vehicleNumber,
      phoneNumber: driver.phoneNumber,
    );
  }

  Driver toDomain() {
    return Driver(
      id: id,
      name: name,
      vehicleNumber: vehicleNumber,
      phoneNumber: phoneNumber,
    );
  }
}
