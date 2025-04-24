part of 'app_exception.dart';

/// Represents various types of server exceptions that can occur in the application.
///
/// This enum is used to categorize different error scenarios that may happen during
/// server communication or authentication processes, allowing for consistent
/// error handling throughout the app.
enum ServerExceptionType {
  /// General business logic errors not covered by other specific types
  general,

  /// 401 Unauthorized - Authentication is required but has failed or not been provided
  /// The client MUST authenticate itself to get the requested response
  unauthorized,

  /// 403 Forbidden - The client does not have access rights to the content
  /// Authentication won't help, the client is not allowed to access the resource
  forbidden,

  /// 404 Not Found - The requested resource could not be found on the server
  /// Different from 405 (Method Not Allowed) where the resource exists but the method is not allowed
  notFound,

  /// 409 Conflict - Request conflicts with the current state of the server
  /// Often occurs with PUT requests when updating a resource that has been modified since the client last fetched it
  conflict,

  /// 500 Internal Server Error - A generic error message when an unexpected condition was encountered
  /// Indicates a problem on the server side, not the client's request
  internal,

  /// 503 Service Unavailable - The server is not ready to handle the request
  /// Common causes include server maintenance or overload
  serviceUnavailable,

  /// Request exceeded the defined timeout period
  /// Occurs when the server takes too long to respond to a request
  timeOut,

  /// Device has no internet connection
  /// Indicates that the client cannot reach the server due to connectivity issues
  noInternet,

  /// Unknown server exception that doesn't match any defined types
  /// Used as a fallback when the error doesn't fit other categories
  unknown,

  /// Firebase Auth: The email address is not valid
  /// Occurs during sign-in, sign-up, or password reset operations
  authInvalidEmail,

  /// Firebase Auth: The password is incorrect for the given email
  /// Occurs during sign-in attempts
  authWrongPassword,

  /// Firebase Auth: No user found for the provided email
  /// Occurs during sign-in or password reset operations
  authUserNotFound,

  /// Firebase Auth: The user account has been disabled by an administrator
  /// The user cannot perform any actions until their account is re-enabled
  authUserDisabled;
}
