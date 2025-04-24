import '../../../../core/infrastructure/network/apis/apis.dart';
import '../../../../core/presentation/utils/riverpod_framework.dart';
import '../dtos/site_dto.dart';

part 'sites_remote_data_source.g.dart';

@Riverpod(keepAlive: true)
SitesRemoteDataSource sitesRemoteDataSource(Ref ref) {
  return SitesRemoteDataSource(
    ref,
    siteService: ref.read(apiServiceProvider).client.getService<SiteService>(),
  );
}

/// A data source class responsible for fetching site-related data from a remote API.
class SitesRemoteDataSource {
  /// Creates an instance of [SitesRemoteDataSource].
  ///
  /// The [ref] is used for dependency injection, and [siteService] is the service
  /// used to interact with the remote API.
  SitesRemoteDataSource(this.ref, {required this.siteService});

  /// A reference to the Riverpod [Ref] for dependency injection.
  final Ref ref;

  /// The service used to interact with the remote API for site-related operations.
  final SiteService siteService;

  /// Fetches a list of sites from the remote API.
  ///
  /// Returns a [Future] containing a list of [SiteDto] objects. If the response
  /// from the API is null, an empty list is returned.
  Future<List<SiteDto>> getListSites() async {
    final response = (await siteService.getSites()).body;

    return response?.data ?? [];
  }
}
