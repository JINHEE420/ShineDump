import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/presentation/utils/fp_framework.dart';
import '../../../../../core/presentation/utils/riverpod_framework.dart';
import '../../../domain/drive_mode.dart';

part 'drive_mode_provider.g.dart';

/// Key used for storing drive mode in SharedPreferences
const String _kDriveModeKey = 'drive_mode';

@Riverpod(keepAlive: true)
class DriveModeState extends _$DriveModeState {
  /// Initializes the state with the drive mode from local storage or default.
  @override
  Option<DriveMode> build() {
    // Initialize with a default and load from SharedPreferences later
    _loadSavedMode();
    return const Some(DriveMode.normal);
  }

  /// Loads the saved drive mode from SharedPreferences.
  Future<void> _loadSavedMode() async {
    final prefs = await SharedPreferences.getInstance();
    final storedMode = prefs.getString(_kDriveModeKey);

    if (storedMode != null) {
      try {
        final mode = DriveMode.values.firstWhere(
          (e) => e.name == storedMode,
          orElse: () => DriveMode.normal,
        );
        state = Some(mode);
      } catch (_) {
        // Keep the default state if there's an error
      }
    }
  }

  /// Sets the current drive mode to the provided [mode] and saves it to local storage.
  Future<void> setDriveMode(DriveMode mode) async {
    // Save to local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kDriveModeKey, mode.name);

    // Update the state
    state = Some(mode);
  }
}
