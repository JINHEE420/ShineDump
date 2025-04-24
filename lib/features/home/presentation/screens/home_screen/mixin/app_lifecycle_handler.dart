import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/core/presentation/utils/riverpod_framework.dart';

/// A mixin that provides lifecycle handling for a [ConsumerStatefulWidget].
///
/// This mixin implements [WidgetsBindingObserver] to listen to app lifecycle
/// events and provides hooks for handling specific states such as when the app
/// is resumed. It is designed to be used with a [ConsumerState] to integrate
/// with Riverpod's state management.
///
/// ### Usage
/// To use this mixin, include it in your [ConsumerStatefulWidget] class:
///
/// ```dart
/// class MyWidget extends ConsumerStatefulWidget {
///   @override
///   ConsumerState<MyWidget> createState() => _MyWidgetState();
/// }
///
/// class _MyWidgetState extends ConsumerState<MyWidget> with AppLifecycleHandler {
///   @override
///   void onResumed() {
///     // Handle app resumed logic here
///   }
/// }
/// ```
///
/// ### Lifecycle Methods
/// - `onResumed`: Override this method to handle logic when the app is resumed.
///
/// ### Notes
/// - The mixin automatically adds itself as a [WidgetsBindingObserver] in
///   `initState` and removes itself in `dispose`.
/// - It ignores certain lifecycle states such as `hidden`, `detached`, and `paused`.
mixin AppLifecycleHandler<T extends ConsumerStatefulWidget> on ConsumerState<T>
    implements WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
      case AppLifecycleState.paused:
        // ignore these states because they happen when the app is not visible
        break;
      case AppLifecycleState.inactive:
        if (!mounted) return;

      case AppLifecycleState.resumed:
        if (!mounted) return;
        onResumed();
    }
  }

  /// Called when the app is resumed.
  ///
  /// Override this method to handle any logic that should occur when the app
  /// returns to the foreground.
  void onResumed();

  @override
  void didChangeAccessibilityFeatures() {}

  @override
  void didChangeLocales(List<Locale>? locales) {}

  @override
  void didChangeMetrics() {}

  @override
  void didChangePlatformBrightness() {}

  @override
  void didChangeTextScaleFactor() {}

  @override
  void didHaveMemoryPressure() {}

  @override
  Future<bool> didPopRoute() async => false;

  @override
  Future<bool> didPushRoute(String route) async => false;

  @override
  Future<bool> didPushRouteInformation(
    RouteInformation routeInformation,
  ) async =>
      false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Future<AppExitResponse> didRequestAppExit() async => AppExitResponse.cancel;

  @override
  void didChangeViewFocus(ViewFocusEvent event) {}

  @override
  void handleCancelBackGesture() {}

  @override
  void handleCommitBackGesture() {}

  @override
  bool handleStartBackGesture(PredictiveBackEvent backEvent) {
    return false;
  }

  @override
  void handleUpdateBackGestureProgress(PredictiveBackEvent backEvent) {}
}
