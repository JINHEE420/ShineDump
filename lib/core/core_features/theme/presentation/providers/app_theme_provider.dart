import '../../../../presentation/utils/riverpod_framework.dart';
import '../../infrastructure/repos/theme_repo.dart';
import '../utils/app_theme.dart';

part 'app_theme_provider.g.dart';

/// A Riverpod controller that manages the application's theme mode.
///
/// This controller is kept alive throughout the app's lifecycle and provides
/// functionality to retrieve, change and persist the user's theme preference.
/// It interacts with [ThemeRepo] to store and retrieve theme settings.
@Riverpod(keepAlive: true)
class AppThemeController extends _$AppThemeController {
  /// Initializes the controller by retrieving the user's stored theme preference.
  ///
  /// Returns the [AppThemeMode] that was previously saved, or the default if none exists.
  @override
  FutureOr<AppThemeMode> build() {
    return _getUserStoredTheme();
  }

  /// Retrieves the user's stored theme preference from persistent storage.
  ///
  /// Uses [ThemeRepo] to get the stored theme string and converts it to an [AppThemeMode].
  /// Returns the corresponding [AppThemeMode] enum value.
  AppThemeMode _getUserStoredTheme() {
    final storedTheme = ref.watch(themeRepoProvider).getAppThemeMode();
    return AppThemeMode.values.byName(storedTheme);
  }

  /// Changes the application theme to the specified [AppThemeMode].
  ///
  /// Updates the controller state and persists the new theme preference.
  ///
  /// Parameters:
  ///   [appTheme] - The new theme mode to apply to the application.
  Future<void> changeTheme(AppThemeMode appTheme) async {
    state = AsyncData(appTheme);
    await ref.watch(themeRepoProvider).cacheAppThemeMode(appTheme.name);
  }

  /// Re-caches the current theme setting to persistent storage.
  ///
  /// This is useful when the storage needs to be synchronized with the current state.
  /// Only takes action if the state contains a valid theme value.
  Future<void> reCacheTheme() async {
    switch (state) {
      case AsyncData(:final value):
        await ref.read(themeRepoProvider).cacheAppThemeMode(value.name);
    }
  }
}
