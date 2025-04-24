import 'dart:convert';

import '../../../core/core_features/locale/presentation/providers/app_locale_provider.dart';
import '../../../core/core_features/theme/presentation/providers/app_theme_provider.dart';
import '../../../core/infrastructure/error/app_exception.dart';
import '../../../core/infrastructure/local/shared_preferences_facade.dart';
import '../../../core/presentation/extensions/future_extensions.dart';
import '../../../core/presentation/utils/riverpod_framework.dart';
import '../../domain/driver.dart';

part 'auth_local_data_source.g.dart';

/// Provides access to the AuthLocalDataSource through a Riverpod provider.
/// This provider is kept alive to maintain a single instance throughout the app lifecycle.
@Riverpod(keepAlive: true)
AuthLocalDataSource authLocalDataSource(Ref ref) {
  return AuthLocalDataSource(ref);
}

/// Manages local storage operations for authentication-related data.
///
/// This class is responsible for caching and retrieving user authentication data
/// (primarily Driver objects) using SharedPreferences. It provides methods to
/// store, retrieve, and clear user and driver data in the local storage.
class AuthLocalDataSource {
  /// Creates an instance of [AuthLocalDataSource] with the given [ref].
  AuthLocalDataSource(this.ref);

  /// The Riverpod reference used to access other providers.
  final Ref ref;

  /// Provides access to the SharedPreferences wrapper.
  SharedPreferencesFacade get sharedPreferences =>
      ref.read(sharedPreferencesFacadeProvider);

  /// Key used for storing the main user data in SharedPreferences.
  static const String userDataKey = 'user_data';

  /// Key used for storing driver-specific data in SharedPreferences.
  static const String driverData = 'driver_data';

  /// Caches the provided user data in local storage.
  ///
  /// This method serializes the [data] object to JSON and stores it using
  /// the [userDataKey]. If [data] is null, the method returns without action.
  ///
  /// Parameters:
  ///   [data] - The Driver object to be cached. Can be null.
  Future<void> cacheUserData(Driver? data) async {
    if (data == null) {
      return;
    }
    final jsonString = json.encode(data.toJson());
    await sharedPreferences.saveData(
      key: userDataKey,
      value: jsonString,
    );
  }

  /// Retrieves the cached user data from local storage.
  ///
  /// This method deserializes the JSON data stored under [userDataKey] and
  /// returns a Driver object. If no data is found, it throws a [CacheException].
  ///
  /// Returns:
  ///   A [Driver] object representing the user data.
  ///
  /// Throws:
  ///   [CacheException] if no user data is found in local storage.
  Driver getUserData() {
    final jsonString = sharedPreferences.restoreData<String>(userDataKey);
    if (jsonString != null) {
      final userDriver =
          Driver.fromJson(json.decode(jsonString) as Map<String, dynamic>);
      return userDriver;
    } else {
      throw const CacheException(
        type: CacheExceptionType.notFound,
        message: 'Cache Not Found',
      );
    }
  }

  /// Caches driver-specific data in local storage.
  ///
  /// This method serializes the [data] object to JSON and stores it using
  /// the [driverData] key. If [data] is null, the method returns without action.
  ///
  /// Parameters:
  ///   [data] - The Driver object to be cached. Can be null.
  Future<void> cacheDriverData(Driver? data) async {
    if (data == null) {
      return;
    }
    final jsonString = json.encode(data);
    await sharedPreferences.saveData(
      key: driverData,
      value: jsonString,
    );
  }

  /// Retrieves the cached driver data from local storage.
  ///
  /// This method deserializes the JSON data stored under [driverData] and
  /// returns a Driver object. If no data is found, it returns null.
  ///
  /// Returns:
  ///   A [Driver] object representing the driver data, or null if no data exists.
  Driver? getDriver() {
    final jsonString = sharedPreferences.restoreData<String>(driverData);
    if (jsonString != null) {
      final userDriver =
          Driver.fromJson(json.decode(jsonString) as Map<String, dynamic>);
      return userDriver;
    } else {
      return null;
    }
  }

  /// Removes driver data from local storage.
  ///
  /// This method clears the data stored under the [driverData] key.
  Future<void> clearDriver() async {
    await sharedPreferences.clearKey(driverData);
  }

  /// Recaches locale and theme settings without clearing other user data.
  ///
  /// Despite the name, this method doesn't actually clear all user data. Instead,
  /// it ensures that locale and theme settings are preserved by recaching them.
  Future<void> clearUserData() async {
    // await sharedPreferences.clearAll();
    await ref
        .read(appLocaleControllerProvider.notifier)
        .reCacheLocale()
        .suppressError();
    await ref
        .read(appThemeControllerProvider.notifier)
        .reCacheTheme()
        .suppressError();
  }
}
