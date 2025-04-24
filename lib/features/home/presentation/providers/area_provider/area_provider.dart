import '../../../../../core/presentation/utils/fp_framework.dart';
import '../../../../../core/presentation/utils/riverpod_framework.dart';
import '../../../domain/area.dart';
import '../../../infrastructure/data_sources/areas_remote_data_source.dart';

part 'area_provider.g.dart';

/// A provider that manages the loading state of an [Area].
/// It uses the Riverpod framework to maintain state across the application.
@Riverpod(keepAlive: true)
class AreaLoadingState extends _$AreaLoadingState {
  /// Initializes the state with no [Area] selected.
  @override
  Option<Area> build() => const None();

  /// Sets the current [Area] to the provided [site].
  void setArea(Area site) {
    state = Some(site);
  }

  /// Clears the current [Area], resetting the state to `None`.
  void clearCurrentArea() {
    state = const None();
  }
}

/// A provider that manages the unloading state of an [Area].
/// It uses the Riverpod framework to maintain state across the application.
@Riverpod(keepAlive: true)
class AreaUnLoadingState extends _$AreaUnLoadingState {
  /// Initializes the state with no [Area] selected.
  @override
  Option<Area> build() => const None();

  /// Sets the current [Area] to the provided [site].
  void setArea(Area site) {
    state = Some(site);
  }

  /// Clears the current [Area], resetting the state to `None`.
  void clearCurrentArea() {
    state = const None();
  }
}

/// A provider that fetches a list of loading areas for a given [id].
/// It retrieves data from the remote data source and maps it to domain objects.
@riverpod
Future<List<Area>> listAreaState(Ref ref, int id) async {
  final remoteData = ref.watch(areasRemoteDataSourceProvider);

  final data = await remoteData.getAllAreasLoading(id);

  return data.map((e) => e.toDomain()).toList();
}

/// A provider that fetches a list of unloading areas for a given [id].
/// It retrieves data from the remote data source and maps it to domain objects.
@riverpod
Future<List<Area>> listUnLoadingAreaState(Ref ref, int id) async {
  final remoteData = ref.watch(areasRemoteDataSourceProvider);

  final data = await remoteData.getAllAreasUnloading(id);

  return data.map((e) => e.toDomain()).toList();
}
