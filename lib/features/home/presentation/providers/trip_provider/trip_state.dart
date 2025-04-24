import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/drive_mode.dart';
import '../../../domain/trip.dart';

part 'trip_state.freezed.dart';

/// Represents the state of a trip, including trip details and additional data.
@freezed
abstract class TripState with _$TripState {
  /// Constructs a [TripState].
  ///
  /// - [trip]: The trip object containing trip details.
  /// - [startTime]: The start time of the trip.
  /// - [distance]: The total distance traveled in meters (default is 0).
  /// - [distanceToUnloadingDestination]: The distance to the unloading destination in meters.
  /// - [distanceToLoadingDestination]: The distance to the loading destination in meters.
  /// - [isEnding]: Indicates if the trip is in the process of ending (default is false).
  const factory TripState({
    Trip? trip,

    /// The start time of the trip.
    DateTime? startTime,

    /// The total distance traveled in meters.
    @Default(0) double distance,

    /// The distance to the unloading destination in meters.
    double? distanceToUnloadingDestination,

    /// The distance to the loading destination in meters.
    double? distanceToLoadingDestination,

    /// Indicates if the trip is in the process of ending.
    @Default(false) bool isEnding,
  }) = _TripState;
}

/// Extension on [num] to provide utility methods.
extension NumX on num {
  /// Converts a distance in meters to kilometers.
  ///
  /// Returns the distance in kilometers as a [double].
  double toKm() => this / 1000;
}
