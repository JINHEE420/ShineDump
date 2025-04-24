import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/presentation/utils/riverpod_framework.dart';
import '../../../../utils/logger.dart';
import 'gps_remote_data_source.dart';

part 'gps_local_data_source.g.dart';

// GPS data table definition
class GpsDataTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get lat => real()();
  RealColumn get long => real()();
  RealColumn get distanceMoving => real()();
  RealColumn get speed => real().nullable()();
  TextColumn get timeStamp => text()();
  IntColumn get tripId => integer()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [GpsDataTable])
class GpsLocalDatabase extends _$GpsLocalDatabase {
  GpsLocalDatabase() : super(_openConnection());

  static Future<void> ensureInitialized() async {
    // Create database instance to trigger initialization
    final db = GpsLocalDatabase();

    // Optionally run migrations or verify connection
    await db.customStatement('PRAGMA journal_mode=WAL;');

    // Close this temporary instance - your app will use the provider
    await db.close();
  }

  @override
  int get schemaVersion => 1;

  // Store a GPS point
  Future<int> insertGpsPoint(GpsDataTableCompanion entry) {
    return into(gpsDataTable).insert(entry);
  }

  // Batch store multiple GPS points for performance
  Future<void> insertGpsPoints(List<GpsDataTableCompanion> entries) async {
    await batch((batch) {
      batch.insertAll(gpsDataTable, entries);
    });
  }

  // Get all unsynced data for a specific trip
  Future<List<GpsDataTableData>> getUnsyncedGpsData(int tripId) {
    return (select(gpsDataTable)
          ..where(
            (tbl) => tbl.tripId.equals(tripId) & tbl.isSynced.equals(false),
          )
          ..orderBy([(t) => OrderingTerm(expression: t.timeStamp)]))
        .get();
  }

  // Mark records as synced
  Future<int> markAsSynced(List<String> timestamps) {
    return (update(gpsDataTable)
          ..where((tbl) => tbl.timeStamp.isIn(timestamps)))
        .write(const GpsDataTableCompanion(isSynced: Value(true)));
  }

  // Get all data for a trip
  Future<List<GpsDataTableData>> getGpsDataForTrip(int tripId) {
    return (select(gpsDataTable)
          ..where((tbl) => tbl.tripId.equals(tripId))
          ..orderBy([(t) => OrderingTerm(expression: t.timeStamp)]))
        .get();
  }

  // Delete data for a specific trip
  Future<int> deleteGpsDataForTrip(int tripId) {
    return (delete(gpsDataTable)..where((tbl) => tbl.tripId.equals(tripId)))
        .go();
  }

  // Check if there's any unsynced data
  Future<bool> hasUnsyncedData() async {
    final unsyncedCount = await (select(gpsDataTable)
          ..where((t) => t.isSynced.equals(false)))
        .get()
        .then((data) => data.length);
    return unsyncedCount > 0;
  }

// Get list of trip IDs that have unsynced data
  Future<List<int>> getTripsWithUnsyncedData() async {
    final result = await (selectOnly(gpsDataTable)
          ..where(gpsDataTable.isSynced.equals(false))
          ..addColumns([gpsDataTable.tripId]))
        .map((row) => row.read(gpsDataTable.tripId)!)
        .get();

    return result.toSet().toList(); // Remove duplicates
  }

// Get count of unsynced items for a specific trip
  Future<int> getUnsyncedCountForTrip(int tripId) async {
    final unsyncedCount = await (select(gpsDataTable)
          ..where((t) => t.tripId.equals(tripId) & t.isSynced.equals(false)))
        .get()
        .then((data) => data.length);
    return unsyncedCount;
  }

  // Conversion utility - convert GPSData to table companion
  static GpsDataTableCompanion fromGPSData(GPSData data, int tripId) {
    return GpsDataTableCompanion(
      lat: Value(data.lat),
      long: Value(data.long),
      distanceMoving: Value(data.distanceMoving),
      speed: Value(data.speed),
      timeStamp: Value(data.timeStamp),
      tripId: Value(tripId),
    );
  }

  // Conversion utility - convert table data to GPSData
  static GPSData toGPSData(GpsDataTableData data) {
    return GPSData(
      lat: data.lat,
      long: data.long,
      distanceMoving: data.distanceMoving,
      speed: data.speed,
      timeStamp: data.timeStamp,
    );
  }
}

// Database connection helper
QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'gps_data.db',
    native: const DriftNativeOptions(
      databaseDirectory: getApplicationSupportDirectory,
    ),
  );
}

// Riverpod provider for the database
@Riverpod(keepAlive: true)
GpsLocalDatabase gpsLocalDatabase(Ref ref) {
  final db = GpsLocalDatabase();
  ref.onDispose(() {
    // Close the database connection when the provider is disposed
    logger.log(
      'Closing GPS local database connection',
      color: LogColor.yellow,
    );
    db.close();
  });
  return db;
}

/// A data source class that manages GPS data persistence in a local SQLite database.
///
/// This class provides an abstraction layer over the [GpsLocalDatabase] to handle
/// CRUD operations for GPS data points collected during trips. It's responsible for:
/// - Storing individual and batched GPS points
/// - Retrieving unsynced data for server synchronization
/// - Marking data as synced after successful server upload
/// - Retrieving trip-specific GPS data
/// - Managing data cleanup
///
/// The class is typically accessed through its Riverpod provider [gpsLocalDataSourceProvider].
class GpsLocalDataSource {
  /// Creates a new instance with the specified database connection.
  ///
  /// @param _db The drift database instance to use for data operations
  GpsLocalDataSource(this._db);

  final GpsLocalDatabase _db;

  /// Saves a single GPS data point to the local database.
  ///
  /// @param lat Latitude coordinate in decimal degrees
  /// @param long Longitude coordinate in decimal degrees
  /// @param distanceMoving Distance moved in meters since tracking started
  /// @param timeStamp ISO-8601 formatted timestamp of when the point was recorded
  /// @param tripId The ID of the trip this GPS point belongs to
  /// @param speed Optional current speed in meters per second
  /// @return The ID of the inserted record
  /// @throws Exception if the database operation fails
  Future<int> saveGpsPoint({
    required double lat,
    required double long,
    required double distanceMoving,
    required String timeStamp,
    required int tripId,
    double? speed,
  }) async {
    try {
      return await _db.insertGpsPoint(
        GpsDataTableCompanion(
          lat: Value(lat),
          long: Value(long),
          distanceMoving: Value(distanceMoving),
          speed: Value(speed),
          timeStamp: Value(timeStamp),
          tripId: Value(tripId),
        ),
      );
    } catch (e) {
      logger.log('Error saving GPS point: $e', color: LogColor.red);
      rethrow;
    }
  }

  /// Saves a single [GPSData] object to the local database.
  ///
  /// @param data The GPS data object to save
  /// @param tripId The ID of the trip this GPS point belongs to
  /// @return The ID of the inserted record
  /// @throws Exception if the database operation fails
  Future<int> saveGPSData({
    required GPSData data,
    required int tripId,
  }) async {
    return saveGpsPoint(
      lat: data.lat,
      long: data.long,
      distanceMoving: data.distanceMoving,
      speed: data.speed,
      timeStamp: data.timeStamp,
      tripId: tripId,
    );
  }

  /// Saves multiple GPS data points in a batch operation for better performance.
  ///
  /// Use this method when you have several points to save at once.
  ///
  /// @param dataPoints List of GPS data objects to save
  /// @param tripId The ID of the trip these points belong to
  /// @throws Exception if the database operation fails
  Future<void> saveGpsPoints({
    required List<GPSData> dataPoints,
    required int tripId,
  }) async {
    try {
      final entries = dataPoints
          .map((data) => GpsLocalDatabase.fromGPSData(data, tripId))
          .toList();

      await _db.insertGpsPoints(entries);
    } catch (e) {
      logger.log('Error batch saving GPS points: $e', color: LogColor.red);
      rethrow;
    }
  }

  /// Retrieves all GPS data points for a trip that haven't been synced to the server.
  ///
  /// @param tripId The ID of the trip to get unsynced data for
  /// @return List of unsynced GPS data points, or empty list if none found or on error
  Future<List<GPSData>> getUnsyncedGpsData(int tripId) async {
    try {
      final records = await _db.getUnsyncedGpsData(tripId);
      return records.map(GpsLocalDatabase.toGPSData).toList();
    } catch (e) {
      logger.log('Error getting unsynced GPS data: $e', color: LogColor.red);
      return [];
    }
  }

  /// Retrieves all GPS data points for a specific trip.
  ///
  /// @param tripId The ID of the trip to get data for
  /// @return List of all GPS data points for the trip, or empty list if none found or on error
  Future<List<GPSData>> getGpsDataForTrip(int tripId) async {
    try {
      final records = await _db.getGpsDataForTrip(tripId);
      return records.map(GpsLocalDatabase.toGPSData).toList();
    } catch (e) {
      logger.log('Error getting GPS data for trip: $e', color: LogColor.red);
      return [];
    }
  }

  /// Marks specific GPS data points as synced with the server.
  ///
  /// @param timestamps List of timestamps identifying the records to mark as synced
  /// @return true if any records were updated, false otherwise
  Future<bool> markDataAsSynced(List<String> timestamps) async {
    try {
      final updated = await _db.markAsSynced(timestamps);
      return updated > 0;
    } catch (e) {
      logger.log('Error marking data as synced: $e', color: LogColor.red);
      return false;
    }
  }

  /// Deletes all GPS data for a specific trip.
  ///
  /// Useful when a trip is cancelled or needs to be purged from the database.
  ///
  /// @param tripId The ID of the trip whose data should be deleted
  /// @return true if any records were deleted, false otherwise
  Future<bool> deleteDataForTrip(int tripId) async {
    try {
      final deleted = await _db.deleteGpsDataForTrip(tripId);
      return deleted > 0;
    } catch (e) {
      logger.log('Error deleting GPS data for trip: $e', color: LogColor.red);
      return false;
    }
  }

  /// Checks if there are any unsynced GPS data points in the database.
  ///
  /// @return true if there are unsynced points, false otherwise
  Future<bool> hasUnsyncedData() {
    return _db.hasUnsyncedData();
  }

  /// Gets a list of trip IDs that have unsynced GPS data points.
  ///
  /// @return List of trip IDs with unsynced data
  Future<List<int>> getTripsWithUnsyncedData() {
    return _db.getTripsWithUnsyncedData();
  }
}

// Provider for the data source
@riverpod
GpsLocalDataSource gpsLocalDataSource(Ref ref) {
  final db = ref.watch(gpsLocalDatabaseProvider);
  return GpsLocalDataSource(db);
}
