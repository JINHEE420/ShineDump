import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';

import '../../../../presentation/utils/riverpod_framework.dart';

part 'guard_interceptor.g.dart';

/// Provides a [GuardInterceptor] instance through Riverpod.
///
/// Use this provider to get access to the [GuardInterceptor] for network request logging.
@riverpod
GuardInterceptor guardInteceptor(Ref ref) => GuardInterceptor();

/// A logging interceptor for Chopper HTTP requests.
///
/// This interceptor logs information about outgoing HTTP requests and their responses
/// for debugging purposes. It outputs the request method, URL, headers, body, and
/// any error responses to the debug console.
///
/// Usage:
/// ```dart
/// final chopper = ChopperClient(
///   interceptors: [
///     GuardInterceptor(),
///     // other interceptors...
///   ],
/// );
/// ```
class GuardInterceptor implements Interceptor {
  /// Intercepts HTTP requests and responses for logging purposes.
  ///
  /// This method logs details about the request including method, URL, headers,
  /// and body. It also logs error information if the response status code is not 200.
  ///
  /// Parameters:
  ///   * [chain]: The request chain that allows inspection and modification of
  ///              the request/response cycle.
  ///
  /// Returns:
  ///   A [Response] object containing the response data from the server.
  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(
    Chain<BodyType> chain,
  ) async {
    debugPrint(
      '============ ${chain.request.method}: ${chain.request.url} ============',
    );

    if (chain.request.headers.isNotEmpty) {
      debugPrint('${chain.request.headers}');
    }
    if (chain.request.body != null) {
      debugPrint('Request Body: ${chain.request.body}');
    }
    final response = await chain.proceed(chain.request);

    if (response.statusCode != 200) {
      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.error}');
    }

    return response;
  }
}
