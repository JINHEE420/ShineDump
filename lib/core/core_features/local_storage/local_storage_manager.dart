import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../infrastructure/local/shared_preferences_facade.dart';
import '../../presentation/utils/riverpod_framework.dart';

part 'local_storage_manager.g.dart';

/// Keys used for storing and retrieving data from local storage.
enum LocalStorageKeys {
  id,
  name,
  phoneNumber,
  vehicleNumber,
  distanceMoving,
  isFoceground,
  isFirstInstall,
  settingOverlay,
  alarmsPermissionDenied,
}

/// Abstract class that defines the interface for managing local storage.
///
/// Provides methods to check if keys exist, get and set values,
/// and delete keys from both secure and non-secure storage.
abstract class LocalStorageManager {
  /// Checks if a key exists in storage.
  ///
  /// [key] The key to check for existence.
  /// [isSecure] Whether to check in secure storage (true) or shared preferences (false).
  /// Returns a Future<bool> that completes with true if the key exists, false otherwise.
  Future<bool> keyExists(LocalStorageKeys key, {bool isSecure = false});

  /// Retrieves a value from storage.
  ///
  /// [key] The key to retrieve the value for.
  /// [fromJson] Optional function to convert JSON to an object of type T.
  /// [isSecure] Whether to retrieve from secure storage (true) or shared preferences (false).
  /// Returns a Future that completes with the retrieved value, or null if not found.
  Future<T?> getValue<T>(
    LocalStorageKeys key, {
    T Function(Map<String, dynamic>)? fromJson,
    bool isSecure = false,
  });

  /// Stores a value in storage.
  ///
  /// [key] The key to store the value under.
  /// [value] The value to store.
  /// [isSecure] Whether to store in secure storage (true) or shared preferences (false).
  void setValue<T>(LocalStorageKeys key, T value, {bool isSecure = false});

  /// Deletes a key and its associated value from storage.
  ///
  /// [key] The key to delete.
  /// [isSecure] Whether to delete from secure storage (true) or shared preferences (false).
  void deleteKey(LocalStorageKeys key, {bool isSecure = false});
}

/// A Riverpod provider that creates and maintains a singleton instance of [LocalStorageManager].
///
/// This provider is kept alive for the entire lifecycle of the app.
@Riverpod(keepAlive: true)
LocalStorageManager localStorageManager(Ref ref) {
  final prefs = ref.watch(sharedPrefsAsyncProvider).value;
  const secureStorage = FlutterSecureStorage();
  return LocalStorageManagerImpl(ref, prefs!, secureStorage);
}

/// Implementation of [LocalStorageManager] that uses SharedPreferences for regular storage
/// and FlutterSecureStorage for secure storage.
class LocalStorageManagerImpl extends LocalStorageManager {
  /// Creates a new [LocalStorageManagerImpl] instance.
  ///
  /// [ref] The Riverpod ref for dependency injection.
  /// [_prefs] The SharedPreferences instance for regular storage.
  /// [_secureStorage] The FlutterSecureStorage instance for secure storage.
  LocalStorageManagerImpl(this.ref, this._prefs, this._secureStorage);
  final Ref ref;
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;

  @override
  Future<bool> keyExists(LocalStorageKeys key, {bool isSecure = false}) async {
    // if (isSecure) {
    //   return await _secureStorage.containsKey(
    //     key: key.name,
    //     aOptions: _getAndroidOptions(),
    //   );
    // } else {
    //   return _prefs.containsKey(key.name);
    // }
    return true;
  }

  @override
  Future<T?> getValue<T>(
    LocalStorageKeys key, {
    T Function(Map<String, dynamic>)? fromJson,
    bool isSecure = false,
  }) async {
    // final _prefs = ref.read(sharedPrefsAsyncProvider).value!;
    if (isSecure) {
      // return (await _secureStorage.read(
      //   key: key.name,
      //   aOptions: _getAndroidOptions(),
      // )).asOrNull<T?>();
    } else {
      print(_prefs.getKeys());
      switch (T) {
        case int:
          return _prefs.getInt(key.name) as T?;
        case double:
          return _prefs.getDouble(key.name) as T?;
        case String:
          final a = _prefs.getString(key.name);
          return a as T?;
        case bool:
          final a = _prefs.getBool(key.name) as T?;
          return _prefs.getBool(key.name) as T?;
        case DateTime:
          final milliseconds = _prefs.getInt(key.name);
          if (milliseconds == null) {
            return null;
          }
          final d = DateTime.fromMillisecondsSinceEpoch(milliseconds);
          return d as T?;
        default:
          if (fromJson != null) {
            final stringObject = _prefs.getString(key.name);
            if (stringObject == null) {
              return null;
            }
            final jsonObject = jsonDecode(stringObject) as Map<String, dynamic>;
            return fromJson(jsonObject);
          }
      }
    }

    return null;
  }

  @override
  Future<void> setValue<T>(
    LocalStorageKeys key,
    T value, {
    bool isSecure = false,
  }) async {
    if (isSecure) {
      // return await _secureStorage.write(
      //   key: key.name,
      //   value: value.toString(),
      //   aOptions: _getAndroidOptions(),
      // );
    } else {
      switch (T) {
        case int:
          _prefs.setInt(key.name, value as int);
        case double:
          _prefs.setDouble(key.name, value as double);
        case String:
          _prefs.setString(key.name, value as String);
        case bool:
          _prefs.setBool(key.name, value as bool);
        case DateTime:
          _prefs.setInt(key.name, (value as DateTime).millisecondsSinceEpoch);

        default:
          final stringObject = jsonEncode(value);
          _prefs.setString(key.name, stringObject);
      }
    }
  }

  @override
  Future<void> deleteKey(LocalStorageKeys key, {bool isSecure = false}) async {
    if (isSecure) {
      // await _secureStorage.delete(
      //   key: key.name,
      //   aOptions: _getAndroidOptions(),
      // );
    } else {
      _prefs.remove(key.name);
    }
  }

  /// Returns Android-specific encryption options for secure storage.
  ///
  /// Uses encryptedSharedPreferences for secure data persistence on Android devices.
  AndroidOptions _getAndroidOptions() => const AndroidOptions(
        encryptedSharedPreferences: true,
      );
}
