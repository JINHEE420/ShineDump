import '../../../../presentation/utils/riverpod_framework.dart';
import '../data_sources/locale_local_data_source.dart';

part 'locale_repo.g.dart';

/// Provides a singleton instance of [LocaleRepo].
///
/// This provider is kept alive to ensure the locale state is maintained
/// throughout the application lifecycle.
@Riverpod(keepAlive: true)
LocaleRepo localeRepo(Ref ref) {
  return LocaleRepo(
    localDataSource: ref.watch(localeLocalDataSourceProvider),
  );
}

/// Repository responsible for managing application locale settings.
///
/// This repository acts as an intermediary between the application's UI and
/// the local data source that stores locale preferences. It provides methods
/// to retrieve and update the application's locale settings.
class LocaleRepo {
  /// Creates a new [LocaleRepo] instance.
  ///
  /// Requires a [LocaleLocalDataSource] to handle the actual storage and
  /// retrieval of locale data.
  LocaleRepo({required this.localDataSource});

  /// The data source used to interact with local storage.
  final LocaleLocalDataSource localDataSource;

  /// Retrieves the currently selected application locale.
  ///
  /// Returns the language code as a [String] (e.g., 'en', 'es', 'fr').
  /// This value is used to set the application's locale on startup.
  String getAppLocale() => localDataSource.getAppLocale();

  /// Saves the specified locale preference to local storage.
  ///
  /// [languageCode] A string representing the language code (e.g., 'en', 'es', 'fr').
  ///
  /// Returns a [Future] that completes when the operation is done.
  Future<void> cacheAppLocale(String languageCode) =>
      localDataSource.cacheAppLocale(languageCode);
}
