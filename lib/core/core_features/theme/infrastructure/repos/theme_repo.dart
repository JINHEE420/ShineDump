import '../../../../presentation/utils/riverpod_framework.dart';
import '../data_sources/theme_local_data_source.dart';

part 'theme_repo.g.dart';

/// Provides a Riverpod provider for the [ThemeRepo] class.
///
/// This provider has [keepAlive] set to true, meaning the instance
/// will persist for the entire application lifecycle.
@Riverpod(keepAlive: true)
ThemeRepo themeRepo(Ref ref) {
  return ThemeRepo(
    localDataSource: ref.watch(themeLocalDataSourceProvider),
  );
}

/// Repository responsible for managing theme-related operations.
///
/// This repository acts as an intermediary layer between the domain layer
/// and the data sources. It delegates theme storage and retrieval operations
/// to the [ThemeLocalDataSource].
class ThemeRepo {
  /// Creates a new instance of [ThemeRepo].
  ///
  /// Requires a [ThemeLocalDataSource] to handle the actual data operations.
  ThemeRepo({required this.localDataSource});

  /// The data source handling local storage operations for theme settings.
  final ThemeLocalDataSource localDataSource;

  /// Retrieves the current application theme mode.
  ///
  /// Returns a string representation of the current theme mode.
  /// This value can be used to determine if the app should use
  /// light mode, dark mode, or system default.
  String getAppThemeMode() => localDataSource.getAppThemeMode();

  /// Stores the specified theme mode in local storage.
  ///
  /// This method allows changing the application's theme setting.
  ///
  /// [themeString] - A string representing the theme mode to be saved.
  /// Common values might include "light", "dark", or "system".
  ///
  /// Returns a [Future] that completes when the operation is done.
  Future<void> cacheAppThemeMode(String themeString) =>
      localDataSource.cacheAppThemeMode(themeString);
}
