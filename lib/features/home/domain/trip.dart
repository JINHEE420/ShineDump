import 'package:freezed_annotation/freezed_annotation.dart';

part 'trip.freezed.dart';
part 'trip.g.dart';

@freezed
class Trip with _$Trip {
  const factory Trip({
    @JsonKey(name: 'trip_id') required int tripId,
    @JsonKey(name: 'project_name') required String projectName,
    @JsonKey(name: 'driver_name') required String driverName,
    @JsonKey(name: 'loading_area') required AreaTrip loadingArea,
    @JsonKey(name: 'unloading_area') required AreaTrip unloadingArea,
    @JsonKey(name: 'material') required String material,
    @JsonKey(name: 'title') required String title,
    @JsonKey(name: 'status') required String status,
  }) = _Trip;

  // Factory constructor for JSON serialization
  factory Trip.fromJson(Map<String, dynamic> json) => _$TripFromJson(json);
}

@freezed
class AreaTrip with _$AreaTrip {
  const factory AreaTrip({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'area_name') String? areaName,
    @JsonKey(name: 'area_address') String? areaAddress,
    @JsonKey(name: 'latitude') double? latitude,
    @JsonKey(name: 'longitude') double? longitude,
    @JsonKey(name: 'radius') @Default(50) double radius,
  }) = _AreaTrip;

  // Factory constructor for JSON serialization
  factory AreaTrip.fromJson(Map<String, dynamic> json) =>
      _$AreaTripFromJson(json);
}
