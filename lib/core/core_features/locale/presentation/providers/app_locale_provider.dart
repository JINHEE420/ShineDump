import 'package:intl/date_symbol_data_local.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../presentation/utils/riverpod_framework.dart';
import '../../infrastructure/repos/locale_repo.dart';
import '../utils/app_locale.dart';

part 'app_locale_provider.g.dart';

/// A provider that manages the application's locale settings.
///
/// This controller is responsible for initializing locale-specific
/// functionality like date formatting and time-ago messages,
/// retrieving stored locale preferences, and handling locale changes.
/// It persists locale changes for app restarts.
@Riverpod(keepAlive: true)
class AppLocaleController extends _$AppLocaleController {
  /// Tracks whether this is the first build to avoid
  /// reinitializing locales multiple times.
  bool _firstBuild = true;

  /// Initializes and returns the current application locale.
  ///
  /// On the first build, this method initializes timeago locales
  /// and date formatting before retrieving the user's stored locale.
  /// Subsequent calls only retrieve the stored locale.
  ///
  /// Returns a [Future] that resolves to the current [AppLocale].
  @override
  FutureOr<AppLocale> build() {
    if (_firstBuild) {
      _setTimeAgoLocales();
      _initDateFormatting();
      _firstBuild = false;
    }
    return _getUserStoredLocale();
  }

  /// Configures localized messages for the timeago package.
  ///
  /// This sets up translations for relative time expressions
  /// (like "5 minutes ago") for different locales.
  /// English messages are loaded by default by the timeago package.
  void _setTimeAgoLocales() {
    //Note: en messages is loaded by default
    timeago.setLocaleMessages(AppLocale.korean.code, timeago.ArMessages());
  }

  /// Initializes the date formatting capabilities for all locales.
  ///
  /// This ensures that date and time formatting works correctly
  /// across different locales in the application.
  Future<void> _initDateFormatting() async {
    await initializeDateFormatting();
  }

  /// Retrieves the user's stored locale preference.
  ///
  /// If no locale is stored, the default locale will be returned
  /// based on the implementation of [LocaleRepo].
  ///
  /// Returns the current [AppLocale] based on stored preferences.
  AppLocale _getUserStoredLocale() {
    final storedLocale = ref.watch(localeRepoProvider).getAppLocale();
    return AppLocale.values.firstWhere((l) => l.code == storedLocale);
  }

  /// Changes the application locale and persists the change.
  ///
  /// Updates the current state to the new locale and saves it
  /// to persistent storage for future app launches.
  ///
  /// [appLocale] The new locale to set as the app's locale.
  Future<void> changeLocale(AppLocale appLocale) async {
    state = AsyncData(appLocale);
    await ref.read(localeRepoProvider).cacheAppLocale(appLocale.code);
  }

  /// Re-caches the current locale in persistent storage.
  ///
  /// This is useful when the cache might have been cleared
  /// but the app state still has the correct locale information.
  Future<void> reCacheLocale() async {
    switch (state) {
      case AsyncData(:final value):
        await ref.read(localeRepoProvider).cacheAppLocale(value.code);
    }
  }
}
