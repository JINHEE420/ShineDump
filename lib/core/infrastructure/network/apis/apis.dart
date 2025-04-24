import 'package:chopper/chopper.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../auth/infrastructure/dtos/driver_dto.dart';
import '../../../../config.dart';
import '../../../../features/base/base_response.dart';
import '../../../../features/home/domain/history_trip.dart';
import '../../../../features/home/domain/latest_trip.dart';
import '../../../../features/home/domain/trip.dart';
import '../../../../features/home/infrastructure/dtos/area_dto.dart';
import '../../../../features/home/infrastructure/dtos/project_dto.dart';
import '../../../../features/home/infrastructure/dtos/site_dto.dart';
import 'base/ison_to_type_converter.dart';
import 'dtos/trip_request_dto.dart';
import 'dtos/update_gps_request_dto.dart';
import 'interceptors/guard_interceptor.dart';

part 'apis.chopper.dart';
part 'apis.g.dart';

@Riverpod(keepAlive: true)
ApiService apiService(Ref ref) {
  return ApiService.create(ref);
}

@ChopperApi()
abstract class ApiService extends ChopperService {
  static ApiService create(Ref ref) {
    final client = ChopperClient(
      baseUrl: Uri.parse(urlApi),
      interceptors: [ref.read(guardInteceptorProvider)],
      services: [
        _$ApiService(),
        _$TripsService(),
        _$SiteService(),
        _$ProjectsService(),
        _$AreaService(),
        _$DriverService(),
        _$GpsService(),
      ],
      converter: const JsonToTypeConverter({
        SiteDto: SiteDto.fromJson,
        DriverDto: DriverDto.fromJson,
        ProjectDto: ProjectDto.fromJson,
        AreaDto: AreaDto.fromJson,
        Trip: Trip.fromJson,
        HistoryTrip: HistoryTrip.fromJson,
        LatestTrip: LatestTrip.fromJson,
      }),
      errorConverter: const JsonConverter(),
    );

    return _$ApiService(client);
  }
}

@ChopperApi()
abstract class TripsService extends ChopperService {
  @POST(path: '/trips')
  Future<Response<BaseResponse<Trip>>> createTrip(
    @Body() TripRequestDto request,
  );

  @PUT(path: '/trips/{id}')
  Future<Response<BaseResponse<Trip>>> updateTrip(
    @Path() int id,
    @Body() TripRequestDto request,
  );

  @GET(path: '/trips/{tripId}')
  Future<Response<BaseResponse<Trip>>> getTripStatus(@Path() int tripId);

  @GET(path: '/trips/complete/{id}')
  Future<Response<BaseResponse<dynamic>>> endTrip(@Path() int id);

  @GET(path: '/trips/uncompleted/{id}')
  Future<Response<BaseResponse<LatestTrip?>>> latestUncomplete(@Path() int id);

  @POST(path: '/trips/force/{tripId}')
  Future<Response<BaseResponse<LatestTrip?>>> forceEnd(
    @Path() int tripId,
    @Body() Map<String, dynamic> body,
  );

  @GET(path: '/trips/histories/drivers/{id}')
  Future<Response<BaseResponse<List<HistoryTrip>>>> histories(
    @Path() int id, {
    @QueryMap() Map<String, dynamic> queryParams = const {},
  });
}

@ChopperApi()
abstract class SiteService extends ChopperService {
  @GET(path: '/sites')
  Future<Response<BaseResponse<List<SiteDto>>>> getSites();
}

@ChopperApi()
// @Path('projectId')
abstract class ProjectsService extends ChopperService {
  @GET(path: '/projects/by-site/{siteId}')
  Future<Response<BaseResponse<List<ProjectDto>>>> getProjectBySite(
    @Path() int siteId,
  );
}

/// Service for handling area-related API operations.
/// Provides methods to fetch loading and unloading areas by project.
@ChopperApi()
abstract class AreaService extends ChopperService {
  /// Retrieves loading areas associated with a specific project.
  ///
  /// [projectId] The ID of the project to get loading areas for.
  /// Returns a response containing a list of [AreaDto] objects.
  @GET(path: '/areas/by-project/{projectId}/loading')
  Future<Response<BaseResponse<List<AreaDto>>>> getLoadingAreasByProject(
    @Path() int projectId,
  );

  /// Retrieves unloading areas associated with a specific project.
  ///
  /// [projectId] The ID of the project to get unloading areas for.
  /// Returns a response containing a list of [AreaDto] objects.
  @GET(path: '/areas/by-project/{projectId}/unloading')
  Future<Response<BaseResponse<List<AreaDto>>>> getUnloadingAreasByProject(
    @Path() int projectId,
  );
}

/// Service for handling driver authentication and related operations.
@ChopperApi()
abstract class DriverService extends ChopperService {
  /// Signs in a driver with their vehicle.
  ///
  /// [driverData] Map containing driver authentication data.
  /// Returns a response containing a [DriverDto] object with driver information.
  @POST(path: '/drivers')
  Future<Response<BaseResponse<DriverDto>>> signInVehicle(
    @Body() Map<String, dynamic> driverData,
  );
}

/// Service for handling GPS data uploads.
@ChopperApi()
abstract class GpsService extends ChopperService {
  /// Uploads GPS data to the server.
  ///
  /// [driverData] DTO containing GPS update information.
  /// Returns a base response indicating success or failure.
  @POST(path: '/gps')
  Future<Response<BaseResponse<dynamic>>> uploadGps(
    @Body() UpdateGpsRequestDto driverData,
  );

  /// Uploads complete GPS data to the server.
  ///
  /// [driverData] DTO containing complete GPS update information.
  /// Returns a base response indicating success or failure.
  @POST(path: '/gps/full')
  Future<Response<BaseResponse<dynamic>>> uploadGpsFull(
    @Body() UpdateGpsRequestDto driverData,
  );
}
