import '../../../../infrastructure/local/shared_preferences_facade.dart';
import '../../../../presentation/utils/riverpod_framework.dart';

part 'locale_local_data_source.g.dart';

/// Provider for [LocaleLocalDataSource].
///
/// This provider creates and maintains a singleton instance of [LocaleLocalDataSource]
/// for accessing and modifying app locale settings in local storage.
@Riverpod(keepAlive: true)
LocaleLocalDataSource localeLocalDataSource(Ref ref) {
  return LocaleLocalDataSource(
    sharedPreferences: ref.watch(sharedPreferencesFacadeProvider),
  );
}

/// A data source responsible for handling app locale settings in local storage.
///
/// This class provides methods to get and save the app's locale preferences
/// using the [SharedPreferencesFacade] for persistence.
class LocaleLocalDataSource {
  /// Creates a new instance of [LocaleLocalDataSource].
  ///
  /// Requires [sharedPreferences] for accessing local storage.
  LocaleLocalDataSource({required this.sharedPreferences});

  /// The shared preferences facade used for storage operations.
  final SharedPreferencesFacade sharedPreferences;

  /// The key used to store and retrieve the app locale in shared preferences.
  static const String appLocaleKey = 'app_locale';

  /// Retrieves the currently saved app locale from local storage.
  ///
  /// Returns the stored locale language code as a string.
  /// If no locale is stored, returns an empty string.
  String getAppLocale() {
    final locale = sharedPreferences.restoreData<String>(appLocaleKey);
    if (locale != null) {
      return locale;
    } else {
      return '';
    }
  }

  /// Saves the provided language code as the app locale in local storage.
  ///
  /// [languageCode] The ISO language code to be saved (e.g., 'en', 'es', 'fr').
  Future<void> cacheAppLocale(String languageCode) async {
    await sharedPreferences.saveData(
      value: languageCode,
      key: appLocaleKey,
    );
  }
}
