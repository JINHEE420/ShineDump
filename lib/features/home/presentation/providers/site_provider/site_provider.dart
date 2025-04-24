import '../../../../../core/presentation/utils/fp_framework.dart';
import '../../../../../core/presentation/utils/riverpod_framework.dart';
import '../../../domain/site.dart';
import '../../../infrastructure/data_sources/sites_remote_data_source.dart';

part 'site_provider.g.dart';

/// A Riverpod provider that manages the state of the current site.
///
/// The state is represented as an `Option<Site>`, where:
/// - `Some(Site)` indicates that a site is currently selected.
/// - `None()` indicates that no site is selected.
@Riverpod(keepAlive: true)
class SiteState extends _$SiteState {
  /// Initializes the state to `None`, indicating no site is selected.
  @override
  Option<Site> build() => const None();

  /// Sets the current site to the provided [site].
  ///
  /// This updates the state to `Some(site)`.
  void setCurrentSite(Site site) {
    state = Some(site);
  }

  /// Clears the current site.
  ///
  /// This updates the state to `None`.
  void clearCurrentSite() {
    state = const None();
  }
}

/// A Riverpod provider that fetches a list of sites asynchronously.
///
/// This function retrieves the list of sites from the remote data source
/// and maps them to their domain representation.
///
/// - [ref]: A reference to the Riverpod provider container.
/// - Returns: A `Future` containing a list of `Site` objects.
@riverpod
Future<List<Site>> listSiteState(Ref ref) async {
  final remoteData = ref.watch(sitesRemoteDataSourceProvider);

  final data = await remoteData.getListSites();

  return data.map((e) => e.toDomain()).toList();
}
