import 'package:flutter/material.dart';

import '../../../../core/presentation/helpers/localization_helper.dart';

/// Represents different types of location-related errors that can occur in the application.
enum LocationError {
  /// Indicates that the location service is not enabled on the device.
  notEnabledLocation,

  /// Indicates that the user has not granted location permissions.
  notGrantedLocationPermission,

  /// Indicates that there was a timeout while trying to retrieve the location.
  getLocationTimeout;

  /// Constructor for the `LocationError` enum.
  const LocationError();

  /// Returns a localized error message based on the type of location error.
  ///
  /// The error message is retrieved using the `tr` function, which provides
  /// localization support. The `context` parameter is used to access the
  /// localization resources.
  ///
  /// - [context]: The `BuildContext` used to retrieve localization strings.
  ///
  /// Returns a `String` containing the localized error message.
  String getErrorText(BuildContext context) {
    return switch (this) {
      LocationError.notEnabledLocation =>
        tr(context).please_enable_location_service,
      LocationError.notGrantedLocationPermission =>
        tr(context).location_permission_required,
      LocationError.getLocationTimeout => tr(context).location_timeout_error,
    };
  }
}
