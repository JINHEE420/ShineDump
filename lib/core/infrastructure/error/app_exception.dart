import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_exception.freezed.dart';
part 'cache_exception_type.dart';
part 'server_exception_type.dart';

/// An exception class representing application-wide errors.
///
/// This class is implemented using Freezed to create an immutable, union type
/// that can represent different categories of application exceptions.
/// It can be used with pattern matching to handle different error types.
///
/// Example usage:
/// ```dart
/// try {
///   // Some operation that might throw
/// } catch (e) {
///   if (e is AppException) {
///     e.when(
///       serverException: (type, message, code) {
///         // Handle server exception
///       },
///       cacheException: (type, message, code) {
///         // Handle cache exception
///       },
///     );
///   }
/// }
/// ```
@freezed
class AppException with _$AppException implements Exception {
  /// Creates an exception for server-related errors.
  ///
  /// [type] specifies the category of server error (e.g., network error, auth error).
  /// [message] provides a human-readable description of the error.
  /// [code] is an optional error code that can be used for more specific error handling.
  const factory AppException.serverException({
    required ServerExceptionType type,
    required String message,
    int? code,
  }) = ServerException;

  /// Creates an exception for cache-related errors.
  ///
  /// [type] specifies the category of cache error (e.g., not found, expired).
  /// [message] provides a human-readable description of the error.
  /// [code] is an optional error code that can be used for more specific error handling.
  const factory AppException.cacheException({
    required CacheExceptionType type,
    required String message,
    int? code,
  }) = CacheException;
}
