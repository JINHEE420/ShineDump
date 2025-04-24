import 'package:freezed_annotation/freezed_annotation.dart';

part 'driver.freezed.dart';
part 'driver.g.dart';

@freezed
class Driver with _$Driver {
  const factory Driver({
    required int id,
    required String name,
    required String vehicleNumber,
    required String phoneNumber,
  }) = _Driver;
  const Driver._();

  factory Driver.fromJson(Map<String, dynamic> json) => _$DriverFromJson(json);
}
