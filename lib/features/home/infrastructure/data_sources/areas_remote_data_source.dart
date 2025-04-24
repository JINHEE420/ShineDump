import '../../../../core/infrastructure/network/apis/apis.dart';
import '../../../../core/presentation/utils/riverpod_framework.dart';
import '../dtos/area_dto.dart';

part 'areas_remote_data_source.g.dart';

/// Provides an instance of [AreasRemoteDataSource].
///
/// This provider is kept alive for the entire app lifecycle.
@Riverpod(keepAlive: true)
AreasRemoteDataSource areasRemoteDataSource(Ref ref) {
  return AreasRemoteDataSource(
    ref,
    areaService: ref.read(apiServiceProvider).client.getService<AreaService>(),
  );
}

/// Remote data source responsible for fetching area data from the API.
///
/// This class provides methods to retrieve loading and unloading areas
/// associated with a specific project site.
class AreasRemoteDataSource {
  /// Creates an instance of [AreasRemoteDataSource].
  ///
  /// Requires a [Ref] instance and an [AreaService] to make API calls.
  AreasRemoteDataSource(this.ref, {required this.areaService});

  /// The Riverpod ref used for dependency injection.
  final Ref ref;

  /// The service used to make API calls related to areas.
  final AreaService areaService;

  /// Fetches all loading areas for the specified project.
  ///
  /// [siteId] The ID of the project site.
  ///
  /// Returns a list of [AreaDto] objects representing loading areas.
  /// Returns an empty list if no data is available.
  Future<List<AreaDto>> getAllAreasLoading(int siteId) async {
    final response = (await areaService.getLoadingAreasByProject(siteId)).body;

    return response?.data ?? [];
  }

  /// Fetches all unloading areas for the specified project.
  ///
  /// [siteId] The ID of the project site.
  ///
  /// Returns a list of [AreaDto] objects representing unloading areas.
  /// Returns an empty list if no data is available.
  Future<List<AreaDto>> getAllAreasUnloading(int siteId) async {
    final response =
        (await areaService.getUnloadingAreasByProject(siteId)).body;

    return response?.data ?? [];
  }
}
