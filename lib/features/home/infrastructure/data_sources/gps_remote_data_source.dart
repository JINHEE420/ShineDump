import '../../../../core/infrastructure/network/apis/apis.dart';
import '../../../../core/infrastructure/network/apis/dtos/update_gps_request_dto.dart';
import '../../../../core/presentation/utils/riverpod_framework.dart';
import 'gps_local_data_source.dart';

part 'gps_remote_data_source.g.dart';

@Riverpod(keepAlive: true)
GpsRemoteDataSource gpsRemoteDataSource(Ref ref) {
  return GpsRemoteDataSource(
    ref,
    gpsService: ref.read(apiServiceProvider).client.getService<GpsService>(),
  );
}

/// Represents a single GPS data point.
class GPSData {
  /// Creates an instance of [GPSData].
  ///
  /// [lat] is the latitude of the GPS point.
  /// [long] is the longitude of the GPS point.
  /// [distanceMoving] is the distance moved since the last GPS point.
  /// [speed] is the speed at the time of the GPS point (optional).
  /// [timeStamp] is the timestamp of the GPS point.
  GPSData({
    required this.lat,
    required this.long,
    required this.distanceMoving,
    required this.speed,
    required this.timeStamp,
  });

  final double lat;
  final double long;
  final double distanceMoving;
  final double? speed;
  final String timeStamp;
}

/// A data source responsible for handling GPS-related operations with the remote server.
/// This class interacts with the `GpsService` to upload GPS data and synchronize unsent data.
class GpsRemoteDataSource {
  /// Creates an instance of [GpsRemoteDataSource].
  ///
  /// [ref] is used to access other providers, and [gpsService] is the service
  /// used to communicate with the remote server.
  GpsRemoteDataSource(this.ref, {required this.gpsService});

  final Ref ref;
  final GpsService gpsService;

  /// Uploads GPS data to the remote server.
  ///
  /// [tripId] is the ID of the trip for which the GPS data is being uploaded.
  /// [data] is the list of GPS data to be uploaded.
  /// [isFull] determines whether to use the full upload endpoint.
  ///
  /// Returns `true` if the upload is successful or if the server responds with a 406 status code.
  /// Returns `false` otherwise.
  Future<bool> _uploadGps(
    int tripId,
    List<GPSData> data, {
    bool isFull = false,
  }) async {
    if (tripId != 0) {
      final request = UpdateGpsRequestDto(
        tripId: tripId,
        gpsPositionList: data
            .map(
              (e) => GpsRequestDto(
                tripId: tripId,
                latitude: e.lat,
                longitude: e.long,
                speed: e.speed ?? 0,
                distance: e.distanceMoving,
                timestamp: e.timeStamp,
              ),
            )
            .toList(),
      );
      final rs = isFull
          ? await gpsService.uploadGpsFull(request)
          : await gpsService.uploadGps(request);

      return rs.isSuccessful || rs.statusCode == 406;
    }
    return false;
  }

  /// Synchronizes unsent GPS data with the remote server.
  ///
  /// [tripId] is the ID of the trip for which the unsent GPS data is being synchronized.
  /// [isFull] determines whether to use the full upload endpoint.
  ///
  /// Retrieves unsynced GPS data from the local database, attempts to upload it to the server,
  /// and marks the data as synced if the upload is successful.
  ///
  /// Returns `true` if synchronization is successful or if there is no unsynced data.
  /// Returns `false` if the synchronization fails.
  Future<bool> syncUnsentGpsData(int tripId, {bool isFull = false}) async {
    if (tripId == 0) return false;

    // Get local data source
    final localDataSource = ref.read(gpsLocalDataSourceProvider);

    // Get unsynced data from local database
    final unsyncedData = await localDataSource.getUnsyncedGpsData(tripId);

    if (unsyncedData.isEmpty) return true;

    // Try to send to server
    final success = await _uploadGps(tripId, unsyncedData, isFull: isFull);

    if (success) {
      // Mark records as synced
      await localDataSource.markDataAsSynced(
        unsyncedData.map((data) => data.timeStamp).toList(),
      );
    }

    return success;
  }
}

/// An exception thrown when a trip is forcibly ended.
class ForceEndTripException implements Exception {
  /// Creates an instance of [ForceEndTripException].
  ///
  /// [message] is the error message describing the reason for the exception.
  ForceEndTripException(this.message);

  final String message;

  @override
  String toString() => message;
}
