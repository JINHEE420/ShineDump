import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/presentation/utils/riverpod_framework.dart';
import '../../../../utils/logger.dart';
import '../../domain/latest_trip.dart';

part 'trips_local_data_source.g.dart';

@riverpod
TripsLocalDataSource tripsLocalDataSource(Ref ref) {
  return TripsLocalDataSource(ref);
}

/// A local data source for managing trips data using shared preferences.
///
/// This class provides methods to save and retrieve the latest uncompleted trip
/// for a specific driver. It uses the `SharedPreferences` package to persist
/// data locally on the device.
class TripsLocalDataSource {
  TripsLocalDataSource(this.ref);

  /// A reference to the Riverpod [Ref] object.
  final Ref ref;

  /// An instance of [SharedPreferences] for local storage.
  final _storage = SharedPreferences.getInstance();

  /// Saves the latest uncompleted trip for a specific driver.
  ///
  /// If [trip] is `null`, the stored trip for the given [driverId] will be removed.
  /// Otherwise, the trip is serialized to JSON and stored locally.
  ///
  /// - [driverId]: The ID of the driver.
  /// - [trip]: The [LatestTrip] object to save, or `null` to remove the trip.
  Future<void> saveLatestUncompleteTrip(int driverId, LatestTrip? trip) async {
    final prefs = await _storage;
    final key = 'latest_trip_$driverId';
    if (trip == null) {
      await prefs.remove(key);
      return;
    }
    final json = jsonEncode(trip.toJson());
    await prefs.setString(key, json);
  }

  /// Retrieves the latest uncompleted trip for a specific driver.
  ///
  /// If no trip is found or if there is an error parsing the cached data,
  /// this method returns `null`.
  ///
  /// - [driverId]: The ID of the driver.
  /// - Returns: A [LatestTrip] object if found, or `null` otherwise.
  Future<LatestTrip?> getLatestUncompleteTrip(int driverId) async {
    final prefs = await _storage;
    final key = 'latest_trip_$driverId';
    final json = prefs.getString(key);

    if (json == null) return null;

    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return LatestTrip.fromJson(map);
    } catch (e) {
      logger.log('Error parsing cached trip: $e');
      return null;
    }
  }
}
