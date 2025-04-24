import 'package:flutter/material.dart';

import '../../../../presentation/helpers/theme_helper.dart';
import '../../../../presentation/providers/provider_utils.dart';
import '../../../../presentation/utils/riverpod_framework.dart';
import '../utils/app_theme.dart';
import 'app_theme_provider.dart';

part 'current_app_theme_provider.g.dart';

/// A Riverpod provider that monitors and exposes the device's platform brightness.
///
/// This provider is kept alive throughout the application lifecycle to ensure
/// consistent theme handling. It tracks the system's brightness setting
/// (light or dark mode) and notifies listeners of any changes.
///
/// The [NotifierUpdate] mixin allows the class to notify about brightness changes.
///
/// Returns:
///   [Brightness] - The current platform brightness (light or dark).
@Riverpod(keepAlive: true)
class PlatformBrightness extends _$PlatformBrightness with NotifierUpdate {
  @override
  // ignore: deprecated_member_use
  Brightness build() => WidgetsBinding.instance.window.platformBrightness;
}

/// Determines the current theme mode for the application based on user preference
/// and system settings.
///
/// This provider combines information from two sources:
/// 1. The user's explicit theme preference from [appThemeControllerProvider]
/// 2. The system's current brightness from [platformBrightnessProvider]
///
/// If the user has not set a theme preference, the function falls back to the
/// system theme determined by [getSystemTheme].
///
/// This provider is kept alive to maintain theme consistency across the app.
///
/// Returns:
///   [AppThemeMode] - The theme mode to be applied to the application.
@Riverpod(keepAlive: true)
AppThemeMode currentAppThemeMode(Ref ref) {
  final theme =
      ref.watch(appThemeControllerProvider.select((data) => data.valueOrNull));
  final platformBrightness = ref.watch(platformBrightnessProvider);
  return theme ?? getSystemTheme(platformBrightness);
}
