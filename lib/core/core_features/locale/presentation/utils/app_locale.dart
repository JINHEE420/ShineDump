import 'package:flutter/material.dart';

import '../../../../../gen/my_assets.dart';
import '../../../../presentation/helpers/localization_helper.dart';
import '../../../../presentation/styles/styles.dart';

/// Represents the supported locales in the application.
///
/// This enum provides language code, flag icon path, and font family
/// information for each supported locale. It also provides methods
/// to retrieve localized language names.
enum AppLocale {
  /// English locale with 'en' code
  english('en', MyAssets.ASSETS_ICONS_LANGUAGES_ICONS_ENGLISH_PNG,
      FontStyles.familyPoppins),

  /// Korean locale with 'ko' code
  korean('ko', MyAssets.ASSETS_ICONS_LANGUAGES_ICONS_ENGLISH_PNG,
      FontStyles.familyPoppins);

  /// Creates an instance of [AppLocale].
  ///
  /// [code] is the ISO language code (e.g., 'en', 'ko').
  /// [flag] is the asset path to the flag icon.
  /// [fontFamily] is the font family to be used for this locale.
  const AppLocale(this.code, this.flag, this.fontFamily);

  /// The ISO language code for this locale (e.g., 'en', 'ko').
  final String code;

  /// Asset path to the flag icon representing this locale.
  final String flag;

  /// The font family to be used for text in this locale.
  final String fontFamily;

  /// Returns the localized name of this language.
  ///
  /// Uses the app's translation system to get the appropriate
  /// language name based on the current context.
  ///
  /// [context] is used to access the localized strings.
  String getLanguageName(BuildContext context) {
    return switch (this) {
      AppLocale.korean => tr(context).korean,
      AppLocale.english => tr(context).english,
    };
  }
}
