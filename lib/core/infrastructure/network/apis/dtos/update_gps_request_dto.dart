import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_gps_request_dto.g.dart';

@JsonSerializable(
  explicitToJson: true,
  genericArgumentFactories: true,
  fieldRename: FieldRename.snake,
)
class UpdateGpsRequestDto {
  // Constructor
  UpdateGpsRequestDto({
    required this.tripId,
    required this.gpsPositionList,
  });

  // Factory constructor for deserializing from JSON
  factory UpdateGpsRequestDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateGpsRequestDtoFromJson(json);
  final int tripId;
  final List<GpsRequestDto> gpsPositionList;

  // Method for serializing to JSON
  Map<String, dynamic> toJson() => _$UpdateGpsRequestDtoToJson(this);
}

@JsonSerializable(
  explicitToJson: true,
  genericArgumentFactories: true,
  fieldRename: FieldRename.snake,
)
class GpsRequestDto {
  // Constructor
  GpsRequestDto({
    required this.tripId,
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.distance,
    required this.timestamp,
  });

  // Factory constructor for deserializing from JSON
  factory GpsRequestDto.fromJson(Map<String, dynamic> json) =>
      _$GpsRequestDtoFromJson(json);
  final int tripId;
  final double latitude;
  final double longitude;
  final double speed;
  final double distance;
  final String timestamp;

  // Method for serializing to JSON
  Map<String, dynamic> toJson() => _$GpsRequestDtoToJson(this);
}
