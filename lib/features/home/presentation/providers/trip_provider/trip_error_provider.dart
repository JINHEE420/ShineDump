import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'trip_error_provider.g.dart';

/// A Riverpod provider class to manage the error state of a trip.
///
/// This class uses the `TripErrorStatus` model to represent the error state,
/// which includes the error message and the timestamp when the error occurred.
@Riverpod(keepAlive: true)
class TripError extends _$TripError {
  /// Initializes the error state to `null`.
  @override
  TripErrorStatus? build() => null;

  /// Sets the error state with a given status message.
  ///
  /// The `status` parameter is a string describing the error.
  /// The method also records the current timestamp.
  void setErrorStatus(String status) {
    state = TripErrorStatus(status: status, timestamp: DateTime.now());
  }

  /// Clears the error state by setting it to `null`.
  void clear() {
    state = null;
  }
}

/// A model class representing the error state of a trip.
///
/// This class contains the error message and the timestamp when the error occurred.
class TripErrorStatus {
  /// Creates a new instance of `TripErrorStatus`.
  ///
  /// The `status` parameter is the error message, and the `timestamp` parameter
  /// is the time when the error occurred.
  TripErrorStatus({required this.status, required this.timestamp});

  /// The error message.
  final String status;

  /// The timestamp when the error occurred.
  final DateTime timestamp;
}
