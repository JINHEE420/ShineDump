import 'package:shared_preferences/shared_preferences.dart';

import '../../presentation/utils/riverpod_framework.dart';
import 'extensions/local_error_extension.dart';

part 'shared_preferences_facade.g.dart';

@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPrefsAsync(Ref ref) async {
  return SharedPreferences.getInstance();
}

@Riverpod(keepAlive: true)
SharedPreferences _sharedPrefs(Ref ref) {
  return ref.watch(sharedPrefsAsyncProvider).requireValue;
}

@Riverpod(keepAlive: true)
SharedPreferencesFacade sharedPreferencesFacade(Ref ref) {
  return SharedPreferencesFacade(
    sharedPrefs: ref.watch(_sharedPrefsProvider),
  );
}

/// A facade for Flutter's SharedPreferences that provides type-safe operations
/// with standardized error handling.
///
/// This class wraps the standard SharedPreferences functionality, adding:
/// - Type-safe data storage and retrieval
/// - Consistent error handling through custom exceptions
/// - Support for common data types (String, int, double, bool, List<String>)
///
/// Access this class through the provided Riverpod provider:
/// ```dart
/// final facade = ref.watch(sharedPreferencesFacadeProvider);
/// ```
class SharedPreferencesFacade {
  /// Creates a new [SharedPreferencesFacade] with the provided SharedPreferences instance.
  ///
  /// This constructor is typically not called directly. Instead, use the
  /// [sharedPreferencesFacadeProvider] to get an instance.
  SharedPreferencesFacade({required this.sharedPrefs});

  /// The underlying SharedPreferences instance.
  final SharedPreferences sharedPrefs;

  /// Saves data to SharedPreferences with automatic type detection.
  ///
  /// Supports the following types:
  /// - String
  /// - int
  /// - double
  /// - bool
  /// - List<String>
  ///
  /// Parameters:
  ///   [key] - The key under which to store the value
  ///   [value] - The value to store (must be one of the supported types)
  ///
  /// Returns:
  ///   A [Future<bool>] that completes with true if the operation was successful
  ///
  /// Throws:
  ///   A cache exception if the operation fails or if an unsupported type is provided
  ///
  /// Example:
  /// ```dart
  /// await facade.saveData(key: 'username', value: 'JohnDoe');
  /// await facade.saveData(key: 'is_logged_in', value: true);
  /// ```
  Future<bool> saveData({
    required String key,
    required Object value,
  }) async {
    return _futureErrorHandler(
      () async {
        return switch (value) {
          final String value => sharedPrefs.setString(key, value),
          final int value => sharedPrefs.setInt(key, value),
          final double value => sharedPrefs.setDouble(key, value),
          final bool value => sharedPrefs.setBool(key, value),
          final List<String> value => sharedPrefs.setStringList(key, value),
          _ => throw UnsupportedError(
              'The type of this value is not supported. '
              'All supported types are: String | int | double | bool | List<String>.',
            ),
        };
      },
    );
  }

  /// Retrieves data from SharedPreferences with automatic type casting.
  ///
  /// The generic type T must be one of:
  /// - String
  /// - int
  /// - double
  /// - bool
  /// - List<String>
  ///
  /// Parameters:
  ///   [key] - The key from which to retrieve the value
  ///
  /// Returns:
  ///   The value of type T if found, or null if the key doesn't exist
  ///
  /// Throws:
  ///   A cache exception if an unsupported type is requested or if retrieval fails
  ///
  /// Example:
  /// ```dart
  /// final username = facade.restoreData<String>('username');
  /// final isLoggedIn = facade.restoreData<bool>('is_logged_in') ?? false;
  /// ```
  T? restoreData<T>(String key) {
    return _errorHandler(
      () {
        return switch (T) {
          String => sharedPrefs.getString(key) as T?,
          int => sharedPrefs.getInt(key) as T?,
          double => sharedPrefs.getDouble(key) as T?,
          bool => sharedPrefs.getBool(key) as T?,
          const (List<String>) => sharedPrefs.getStringList(key) as T?,
          _ => throw UnsupportedError(
              'The generic type is not supported. '
              'All supported types are: String | int | double | bool | List<String>.',
            ),
        };
      },
    );
  }

  /// Clears all data stored in SharedPreferences.
  ///
  /// Returns:
  ///   A [Future<bool>] that completes with true if the operation was successful
  ///
  /// Throws:
  ///   A cache exception if the operation fails
  ///
  /// Example:
  /// ```dart
  /// await facade.clearAll(); // Removes all stored preferences
  /// ```
  Future<bool> clearAll() async {
    return _futureErrorHandler(
      () async {
        return sharedPrefs.clear();
      },
    );
  }

  /// Removes a specific key-value pair from SharedPreferences.
  ///
  /// Parameters:
  ///   [key] - The key to remove
  ///
  /// Returns:
  ///   A [Future<bool>] that completes with true if the operation was successful
  ///
  /// Throws:
  ///   A cache exception if the operation fails
  ///
  /// Example:
  /// ```dart
  /// await facade.clearKey('username'); // Removes only the username value
  /// ```
  Future<bool> clearKey(String key) async {
    return _futureErrorHandler(
      () async {
        return sharedPrefs.remove(key);
      },
    );
  }

  /// Internal helper for handling synchronous operations with standardized error handling.
  ///
  /// Converts any thrown errors to appropriate cache exceptions using [localErrorToCacheException].
  T _errorHandler<T>(T Function() body) {
    try {
      return body.call();
    } catch (e, st) {
      final error = e.localErrorToCacheException();
      throw Error.throwWithStackTrace(error, st);
    }
  }

  /// Internal helper for handling asynchronous operations with standardized error handling.
  ///
  /// Converts any thrown errors to appropriate cache exceptions using [localErrorToCacheException].
  Future<T> _futureErrorHandler<T>(Future<T> Function() body) async {
    try {
      return await body.call();
    } catch (e, st) {
      final error = e.localErrorToCacheException();
      throw Error.throwWithStackTrace(error, st);
    }
  }
}
