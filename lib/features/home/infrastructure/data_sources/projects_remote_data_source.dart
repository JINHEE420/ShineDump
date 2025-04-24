import '../../../../core/infrastructure/network/apis/apis.dart';
import '../../../../core/presentation/utils/riverpod_framework.dart';
import '../dtos/project_dto.dart';

part 'projects_remote_data_source.g.dart';

/// A Riverpod provider for [ProjectsRemoteDataSource].
/// Keeps the instance alive throughout the app lifecycle.
@Riverpod(keepAlive: true)
ProjectsRemoteDataSource projectsRemoteDataSource(Ref ref) {
  return ProjectsRemoteDataSource(
    ref,
    projectService:
        ref.read(apiServiceProvider).client.getService<ProjectsService>(),
  );
}

/// A data source class responsible for interacting with the remote API
/// to fetch project-related data.
class ProjectsRemoteDataSource {
  /// Creates an instance of [ProjectsRemoteDataSource].
  ///
  /// Requires a [Ref] for dependency injection and a [ProjectsService]
  /// to perform API calls.
  ProjectsRemoteDataSource(this.ref, {required this.projectService});

  /// A reference to the Riverpod [Ref] for accessing dependencies.
  final Ref ref;

  /// The service used to make API calls for project-related operations.
  final ProjectsService projectService;

  /// Fetches all projects associated with a specific site.
  ///
  /// [siteId] - The ID of the site for which projects are to be fetched.
  ///
  /// Returns a list of [ProjectDto] objects representing the projects.
  /// If the response is null, an empty list is returned.
  Future<List<ProjectDto>> getAllProjectBySite(int siteId) async {
    final response = (await projectService.getProjectBySite(siteId)).body;

    return response?.data ?? [];
  }
}
