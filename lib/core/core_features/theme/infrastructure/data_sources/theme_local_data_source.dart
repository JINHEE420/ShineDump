import '../../../../infrastructure/error/app_exception.dart';
import '../../../../infrastructure/local/shared_preferences_facade.dart';
import '../../../../presentation/utils/riverpod_framework.dart';

part 'theme_local_data_source.g.dart';

/// Provides an instance of [ThemeLocalDataSource] for dependency injection.
///
/// This provider is kept alive for the entire application lifecycle to ensure
/// consistent theme handling across the app.
@Riverpod(keepAlive: true)
ThemeLocalDataSource themeLocalDataSource(Ref ref) {
  return ThemeLocalDataSource(
    sharedPreferences: ref.watch(sharedPreferencesFacadeProvider),
  );
}

/// Manages the persistence and retrieval of application theme settings.
///
/// This data source handles the local storage operations for theme preferences
/// using [SharedPreferencesFacade]. It provides methods to get the current theme
/// mode from local storage and to cache a new theme mode selection.
class ThemeLocalDataSource {
  /// Creates a new [ThemeLocalDataSource] instance.
  ///
  /// Requires a [SharedPreferencesFacade] instance for handling local storage operations.
  ThemeLocalDataSource({required this.sharedPreferences});

  /// The [SharedPreferencesFacade] used for local storage operations.
  final SharedPreferencesFacade sharedPreferences;

  /// The key used to store and retrieve the theme mode in local storage.
  static const String appThemeKey = 'app_theme';

  /// Retrieves the currently stored theme mode from local storage.
  ///
  /// Returns the theme mode as a [String].
  ///
  /// Throws a [CacheException] if no theme mode is found in local storage.
  String getAppThemeMode() {
    final theme = sharedPreferences.restoreData<String>(appThemeKey);
    if (theme != null) {
      return theme;
    } else {
      throw const CacheException(
        type: CacheExceptionType.notFound,
        message: 'Cache Not Found',
      );
    }
  }

  /// Saves the provided theme mode to local storage.
  ///
  /// [themeString] - The theme mode to be saved as a string representation.
  ///
  /// Returns a [Future] that completes when the save operation is finished.
  Future<void> cacheAppThemeMode(String themeString) async {
    await sharedPreferences.saveData(
      value: themeString,
      key: appThemeKey,
    );
  }
}
