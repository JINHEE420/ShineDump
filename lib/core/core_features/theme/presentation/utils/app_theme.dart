import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../presentation/styles/styles.dart';
import 'custom_colors.dart';
import 'app_colors.dart';

enum AppThemeMode {
  light,
  dark;

  const AppThemeMode();

  ThemeData getThemeData(String fontFamily,
      {required bool supportsEdgeToEdge}) {
    return AppTheme(themeMode: this, supportsEdgeToEdge: supportsEdgeToEdge)
        .getThemeData(fontFamily);
  }

  ThemeData get _baseTheme {
    return switch (this) {
      AppThemeMode.light => ThemeData.light(),
      AppThemeMode.dark => ThemeData.light(),
    };
  }

  AppColors get _colorsPalette {
    return switch (this) {
      AppThemeMode.light => AppColorsLight(),
      AppThemeMode.dark => AppColorsLight(),
    };
  }

  ColorScheme get _baseColorScheme {
    return switch (this) {
      AppThemeMode.light => const ColorScheme.light(),
      AppThemeMode.dark => const ColorScheme.light(),
    };
  }

  SystemUiOverlayStyle overlayStyle({
    required Color statusBarColor,
    required bool supportsEdgeToEdge,
    required Color systemNavBarColor,
    required Color olderAndroidSystemNavBarColor,
  }) {
    return _baseOverlayStyle.copyWith(
      //For Android
      statusBarColor: statusBarColor,
      // Not using transparent color for old android versions to avoid hidden navigation bar icons:
      // https://github.com/flutter/flutter/issues/105716
      systemNavigationBarColor: supportsEdgeToEdge
          ? systemNavBarColor
          : olderAndroidSystemNavBarColor,
      systemNavigationBarDividerColor: systemNavBarColor,
      // Fixes navigation bar can't be transparent:
      // https://github.com/flutter/flutter/issues/119465#issuecomment-1518007538
      systemNavigationBarContrastEnforced: false,
    );
  }

  SystemUiOverlayStyle get _baseOverlayStyle {
    return switch (this) {
      AppThemeMode.light => SystemUiOverlayStyle.dark.copyWith(
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      AppThemeMode.dark => SystemUiOverlayStyle.dark.copyWith(
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
    };
  }

  IconData get settingsIcon {
    return switch (this) {
      AppThemeMode.light => Icons.wb_sunny,
      AppThemeMode.dark => Icons.nights_stay,
    };
  }
}

class AppTheme {
  AppTheme({required AppThemeMode themeMode, required bool supportsEdgeToEdge})
      : _supportsEdgeToEdge = supportsEdgeToEdge,
        _themeMode = themeMode;

  final AppThemeMode _themeMode;

  final bool _supportsEdgeToEdge;

  late final ThemeData _baseTheme = _themeMode._baseTheme;

  late final AppColors _appColors = _themeMode._colorsPalette;

  late final Color _primaryColor = _appColors.primaryColor;

  late final ColorScheme _colorScheme = _themeMode._baseColorScheme.copyWith(
    primary: _appColors.primary,
    secondary: _appColors.secondary,
  );

  late final AppBarTheme _appBarTheme = AppBarTheme(
    systemOverlayStyle: _themeMode.overlayStyle(
      statusBarColor: _appColors.statusBarColor,
      supportsEdgeToEdge: _supportsEdgeToEdge,
      systemNavBarColor: _appColors.systemNavBarColor,
      olderAndroidSystemNavBarColor: _appColors.olderAndroidSystemNavBarColor,
    ),
    backgroundColor: _appColors.appBarBGColor,
    elevation: Sizes.appBarElevation,
  );

  late final Color _scaffoldBackgroundColor = _appColors.scaffoldBGColor;

  late final NavigationBarThemeData _navigationBarTheme =
      NavigationBarThemeData(
    backgroundColor: _appColors.navBarColor,
    surfaceTintColor: Colors.transparent,
    shadowColor: _appColors.navBarColor,
    indicatorColor: _appColors.navBarIndicatorColor,
    labelTextStyle: WidgetStatePropertyAll(
      TextStyles.navigationLabel(_appColors.customColors.font12Color!),
    ),
    elevation: Sizes.navBarElevation,
  );

  late final NavigationRailThemeData _navigationRailTheme =
      NavigationRailThemeData(
    backgroundColor: _appColors.navBarColor,
    elevation: Sizes.navBarElevation,
  );

  late final TextTheme _textTheme = _baseTheme.textTheme.copyWith(
    titleMedium: TextStyles.titleMedium(_appColors.textFieldSubtitle1Color),
  );

  late final TextTheme _primaryTextTheme = _baseTheme.primaryTextTheme;

  late final Color _hintColor = _appColors.textFieldHintColor;

  late final TextSelectionThemeData _textSelectionTheme =
      TextSelectionThemeData(
    cursorColor: _appColors.textFieldCursorColor,
  );

  late final InputDecorationTheme _inputDecorationTheme = InputDecorationTheme(
    contentPadding: Insets.inputDecorationContentPadding,
    isDense: true,
    filled: true,
    fillColor: _appColors.textFieldFillColor,
    hintStyle: TextStyles.inputDecorationHint(_appColors.textFieldHintColor),
    prefixIconColor: _appColors.textFieldPrefixIconColor,
    suffixIconColor: _appColors.textFieldSuffixIconColor,
    border: Borders.inputDecorationBorder(_appColors.textFieldBorderColor),
    enabledBorder:
        Borders.inputDecorationBorder(_appColors.textFieldEnabledBorderColor),
    focusedBorder: Borders.inputDecorationBorder(
        _appColors.textFieldFocusedBorderColor, 1.2),
    errorBorder:
        Borders.inputDecorationBorder(_appColors.textFieldErrorBorderColor),
    focusedErrorBorder:
        Borders.inputDecorationBorder(_appColors.textFieldErrorBorderColor),
    errorStyle:
        TextStyles.inputDecorationError(_appColors.textFieldErrorStyleColor),
  );

  late final IconThemeData _iconTheme =
      IconThemeData(color: _appColors.iconColor);

  late final ButtonThemeData _buttonTheme = ButtonThemeData(
    buttonColor: _appColors.buttonColor,
    disabledColor: _appColors.buttonDisabledColor,
  );

  late final ToggleButtonsThemeData _toggleButtonsTheme =
      ToggleButtonsThemeData(
    borderColor: _appColors.toggleButtonBorderColor,
    selectedColor: _appColors.toggleButtonSelectedColor,
    disabledColor: _appColors.toggleButtonDisabledColor,
  );

  late final CardTheme _cardTheme = CardTheme(
    color: _appColors.cardBGColor,
    shadowColor: _appColors.cardShadowColor,
  );

  late final DialogTheme _dialogTheme = DialogTheme(
    backgroundColor: _appColors.scaffoldBGColor,
    titleTextStyle:
        TextStyles.dialogTitle(_appColors.customColors.font18Color!),
    contentTextStyle:
        TextStyles.dialogContent(_appColors.customColors.font16Color!),
  );

  late final CustomColors _customColors = _appColors.customColors;

  // TODO(AHMED): useMaterial3
  ThemeData getThemeData(String fontFamily) {
    return _baseTheme.copyWith(
      // ignore: deprecated_member_use
      useMaterial3: false,
      primaryColor: _primaryColor,
      colorScheme: _colorScheme,
      appBarTheme: _appBarTheme,
      scaffoldBackgroundColor: _scaffoldBackgroundColor,
      navigationBarTheme: _navigationBarTheme,
      navigationRailTheme: _navigationRailTheme,
      textTheme: _textTheme.apply(fontFamily: fontFamily),
      primaryTextTheme: _primaryTextTheme.apply(fontFamily: fontFamily),
      hintColor: _hintColor,
      textSelectionTheme: _textSelectionTheme,
      inputDecorationTheme: _inputDecorationTheme,
      iconTheme: _iconTheme,
      buttonTheme: _buttonTheme,
      toggleButtonsTheme: _toggleButtonsTheme,
      cardTheme: _cardTheme,
      dialogTheme: _dialogTheme,
      extensions: [
        _customColors,
      ],
    );
  }
}
