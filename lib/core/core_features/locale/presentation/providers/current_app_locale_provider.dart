import '../../../../presentation/utils/riverpod_framework.dart';
import '../utils/app_locale.dart';
import 'app_locale_provider.dart';

part 'current_app_locale_provider.g.dart';

/// Provides the current application locale.
///
/// This provider keeps track of the current locale setting for the application.
/// It watches the [appLocaleControllerProvider] for changes and returns the
/// selected locale.
///
/// If no locale has been explicitly set (returns null), it defaults to
/// [AppLocale.english].
///
/// This provider is kept alive for the entire application lifetime to maintain
/// consistent locale state.
///
/// Usage:
/// ```dart
/// final currentLocale = ref.watch(currentAppLocaleProvider);
/// ```
@Riverpod(keepAlive: true)
AppLocale currentAppLocale(Ref ref) {
  final locale =
      ref.watch(appLocaleControllerProvider.select((data) => data.valueOrNull));
  return locale ?? AppLocale.english;
}
