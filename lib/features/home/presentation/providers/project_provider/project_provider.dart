import '../../../../../core/presentation/utils/fp_framework.dart';
import '../../../../../core/presentation/utils/riverpod_framework.dart';
import '../../../domain/project.dart';
import '../../../infrastructure/data_sources/projects_remote_data_source.dart';

part 'project_provider.g.dart';

/// A Riverpod provider that manages the state of the current project.
///
/// This provider uses an [Option] to represent the current project, which can
/// either be `Some(Project)` if a project is selected or `None` if no project
/// is selected.
@Riverpod(keepAlive: true)
class ProjectState extends _$ProjectState {
  /// Initializes the state with no project selected.
  @override
  Option<Project> build() => const None();

  /// Sets the current project to the provided [site].
  ///
  /// This method updates the state to `Some(site)`, indicating that a project
  /// is now selected.
  void setCurrentProject(Project site) {
    state = Some(site);
  }

  /// Clears the current project.
  ///
  /// This method updates the state to `None`, indicating that no project is
  /// currently selected.
  void clearCurrentProject() {
    state = const None();
  }
}

/// A Riverpod provider that fetches a list of projects for a given site.
///
/// This asynchronous function retrieves all projects associated with the site
/// identified by the provided [id]. It uses the [projectsRemoteDataSourceProvider]
/// to fetch the data and maps the results to their domain representation.
///
/// - [ref]: A reference to the Riverpod provider.
/// - [id]: The ID of the site for which to fetch projects.
///
/// Returns a list of [Project] objects.
@riverpod
Future<List<Project>> listProjectState(Ref ref, int id) async {
  final remoteData = ref.watch(projectsRemoteDataSourceProvider);

  final data = await remoteData.getAllProjectBySite(id);

  return data.map((e) => e.toDomain()).toList();
}
