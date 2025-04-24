import 'package:freezed_annotation/freezed_annotation.dart';

part 'history_trip.freezed.dart';
part 'history_trip.g.dart';

/// Represents a historical record of a completed trip.
///
/// This immutable data class contains information about a trip including
/// the associated project, loading and unloading locations, and timing details.
/// It is used to display trip history information in the application.
@freezed
class HistoryTrip with _$HistoryTrip {
  const factory HistoryTrip({
    @JsonKey(name: 'project_id') required int projectId,
    @JsonKey(name: 'project_name') required String projectName,
    @JsonKey(name: 'loading_area') required String loadingArea,
    @JsonKey(name: 'unloading_area') required String unloadingArea,
    @JsonKey(name: 'start_time') required String startTime,
    @JsonKey(name: 'end_time') required String endTime,
  }) = _HistoryTrip;

  /// Creates a [HistoryTrip] instance from a JSON map.
  ///
  /// This factory constructor uses generated code to convert JSON data
  /// into a properly typed Dart object.
  factory HistoryTrip.fromJson(Map<String, dynamic> json) =>
      _$HistoryTripFromJson(json);
}
