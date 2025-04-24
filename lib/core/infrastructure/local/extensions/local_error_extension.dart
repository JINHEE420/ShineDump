import '../../error/app_exception.dart';

/// Extension on [Object] that provides utility methods for converting
/// various errors into standardized [CacheException] types.
///
/// This extension helps in normalizing error handling for cache-related
/// operations throughout the application.
extension LocaleErrorExtension on Object {
  /// Converts the current object into a [CacheException].
  ///
  /// If the current object is already a [CacheException] with type
  /// [CacheExceptionType.general], it will be returned as is.
  /// Otherwise, a new [CacheException] with [CacheExceptionType.unknown]
  /// will be created with the string representation of this object as the message.
  ///
  /// Returns:
  ///   A [CacheException] representing the current error state.
  CacheException localErrorToCacheException() {
    final error = this;

    if (error is CacheException && error.type == CacheExceptionType.general) {
      return error;
    }

    return CacheException(
      type: CacheExceptionType.unknown,
      message: error.toString(),
    );
  }
}
