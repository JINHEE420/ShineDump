part of 'app_exception.dart';

/// Defines various types of cache-related exceptions that can occur in the application.
///
/// This enum is used to categorize the specific reason for cache failures,
/// allowing for appropriate handling based on the exception type.
enum CacheExceptionType {
  /// Represents an unspecified or unidentified cache exception.
  unknown,

  /// Represents a general cache-related exception that doesn't fit other categories.
  general,

  /// Thrown when requested data is not found in the cache or the cache is empty.
  notFound,

  /// Thrown when cached data has exceeded its time-to-live and is no longer valid.
  expired;
}
