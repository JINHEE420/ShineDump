import 'package:freezed_annotation/freezed_annotation.dart';

import '../infrastructure/dtos/area_dto.dart';
import '../infrastructure/dtos/project_dto.dart';

part 'latest_trip.freezed.dart';
part 'latest_trip.g.dart';

/// Represents a trip with its GPS tracking data and related information.
///
/// This model stores information about a specific trip, including tracking points,
/// trip identifiers, material being transported, trip status, timing information,
/// and associated location data.
@freezed
class LatestTrip with _$LatestTrip {
  const factory LatestTrip({
    /// GPS tracking data points collected during the trip
    @JsonKey(name: 'gps_tracking_response')
    required List<GpsTrackingResponse> gpsTrackingResponse,

    /// Unique identifier for the trip
    @JsonKey(name: 'trip_id') int? tripId,

    /// Type of material being transported
    @JsonKey(name: 'material') String? material,

    /// Current status of the trip (e.g., "in_progress", "completed")
    @JsonKey(name: 'status') String? status,

    /// Timestamp when the trip started
    @JsonKey(name: 'start_time') String? startTime,

    /// Timestamp when the trip ended
    @JsonKey(name: 'end_time') String? endTime,

    /// Information about the project associated with this trip
    @JsonKey(name: 'project_info') ProjectDto? projectInfo,

    /// Information about the area where materials were loaded
    @JsonKey(name: 'loading_area_info') AreaDto? loadingAreaInfo,

    /// Information about the area where materials were unloaded
    @JsonKey(name: 'unloading_area_info') AreaDto? unloadingAreaInfo,
  }) = _LatestTrip;

  factory LatestTrip.fromJson(Map<String, dynamic> json) =>
      _$LatestTripFromJson(json);
}

/// Represents a single GPS tracking data point.
///
/// This model stores information about a specific location captured during
/// trip tracking, including position coordinates, timestamp, speed, and distance.
@freezed
class GpsTrackingResponse with _$GpsTrackingResponse {
  const factory GpsTrackingResponse({
    /// Unique identifier for the GPS tracking point
    required int id,

    /// Geographic latitude coordinate
    required double latitude,

    /// Geographic longitude coordinate
    required double longitude,

    /// Timestamp when the GPS data was recorded
    required String time,

    /// Vehicle speed at the time of recording (if available)
    double? speed,

    /// Distance traveled at this point (if available)
    double? distance,
  }) = _GpsTrackingResponse;

  factory GpsTrackingResponse.fromJson(Map<String, dynamic> json) =>
      _$GpsTrackingResponseFromJson(json);
}
