import 'dart:io';
import 'dart:math';

import 'package:floating/floating.dart';

import '../../utils/logger.dart';
import '../presentation/utils/riverpod_framework.dart';

part 'pip_service.g.dart';

@riverpod
PipService pipService(Ref ref) => PipService(ref: ref);

/// A service that handles Picture-in-Picture (PiP) functionality for the application.
///
/// This service primarily targets Android devices as iOS has limited PiP support.
/// It uses the `floating` package to manage the PiP lifecycle.
///
/// Usage:
/// ```dart
/// final pipService = ref.read(pipServiceProvider);
///
/// // Check if PiP is available
/// final isAvailable = await pipService.isAvailable();
///
/// // Enable PiP mode
/// if (isAvailable) {
///   pipService.enable();
/// }
/// ```
class PipService {
  /// Creates a new instance of [PipService].
  ///
  /// Requires a [Ref] from Riverpod to access other providers if needed.
  PipService({required this.ref});

  /// The Riverpod reference to access other providers.
  final Ref ref;

  /// Indicates whether PiP mode is currently running.
  bool isRunning = false;

  /// The floating instance used to interact with the device's PiP capabilities.
  final floating = Floating();

  /// Enables Picture-in-Picture mode with specified dimensions.
  ///
  /// Only works on Android devices. On iOS, this method returns `null`.
  ///
  /// Parameters:
  /// - [width]: Width of the PiP window in logical pixels. Defaults to 250.
  /// - [height]: Height of the PiP window in logical pixels. Defaults to 500.
  ///
  /// Returns:
  /// - `true` if PiP mode was successfully enabled.
  /// - `false` if enabling PiP mode failed.
  /// - `null` if the platform doesn't support PiP (e.g., iOS).
  Future<bool?> enable({
    double width = 250,
    double height = 500,
  }) async {
    if (!Platform.isAndroid) return null;

    final arguments = OnLeavePiP(
      aspectRatio: const Rational.vertical(),
      sourceRectHint: Rectangle<int>(
        210,
        100,
        width.toInt(),
        height.toInt(),
      ),
    );

    logger.log('Enable picture in picture mode');
    final status = await floating.enable(arguments);

    return status == PiPStatus.enabled;
  }

  /// Checks if the device supports Picture-in-Picture functionality.
  ///
  /// Returns `false` on iOS devices as they have limited support.
  /// On Android, delegates to the underlying floating package to determine availability.
  ///
  /// Returns:
  /// - `true` if PiP is available on the current device.
  /// - `false` otherwise.
  Future<bool> isAvailable() async {
    if (Platform.isIOS) {
      return false;
    }
    return floating.isPipAvailable;
  }

  /// Toggles between PiP mode and normal mode.
  ///
  /// This method has no effect on iOS devices.
  ///
  /// Parameters:
  /// - [enabled]: Whether to enable (`true`) or disable (`false`) PiP mode. Defaults to `true`.
  void toggle({bool enabled = true}) {
    if (Platform.isIOS) {
      return;
    }
    if (enabled) {
      enable();
    } else {
      disable();
    }
  }

  /// Exits Picture-in-Picture mode and returns to normal display mode.
  ///
  /// This method has no effect on iOS devices.
  void disable() {
    if (Platform.isIOS) {
      return;
    }
    logger.log('Restore to normal mode');
    floating.cancelOnLeavePiP();
  }
}
