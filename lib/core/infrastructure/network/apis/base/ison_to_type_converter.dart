import 'dart:convert';

import 'package:chopper/chopper.dart';
import 'package:flutter/foundation.dart';

import '../../../../../features/base/base_response.dart';

/// A converter that transforms JSON HTTP responses into strongly typed objects.
///
/// This converter works with [BaseResponse] objects and supports both single items
/// and lists of items in the response data field.
///
/// Usage:
/// ```dart
/// final converter = JsonToTypeConverter({
///   User: (json) => User.fromJson(json),
///   Product: (json) => Product.fromJson(json),
/// });
///
/// final chopper = ChopperClient(
///   converter: converter,
///   // other parameters...
/// );
/// ```
class JsonToTypeConverter extends JsonConverter {
  /// Creates a new [JsonToTypeConverter].
  ///
  /// [typeToJsonFactoryMap] is a mapping from Types to factory functions that can
  /// convert JSON objects to instances of those Types. Each factory function should
  /// take a [Map<String, dynamic>] and return an instance of the corresponding Type.
  const JsonToTypeConverter(this.typeToJsonFactoryMap);

  /// A map of Types to factory functions that create instances of those Types from JSON.
  final Map<Type, Function(Map<String, dynamic> json)> typeToJsonFactoryMap;

  /// Converts an HTTP response to a strongly typed response object.
  ///
  /// This method handles two cases:
  /// 1. When the 'data' field in the response is a List, it converts each item in the list
  ///    to an instance of [InnerType] using the appropriate factory function from [typeToJsonFactoryMap].
  /// 2. When the 'data' field is a single object, it converts that object to an instance of [InnerType].
  ///
  /// [BodyType] is the type of the entire response body (typically BaseResponse<InnerType> or BaseResponse<List<InnerType>>)
  /// [InnerType] is the type of the data payload (or items in the data list)
  @override
  Response<BodyType> convertResponse<BodyType, InnerType>(
    Response<dynamic> response,
  ) {
    final dataDecoder = utf8.decode(response.bodyBytes);

    debugPrint(dataDecoder);

    final parseData = json.decode(dataDecoder);
    if (parseData['data'] is List) {
      return response.copyWith<BodyType>(
        body: BaseResponse<List<InnerType>>.fromJson(
          parseData as Map<String, dynamic>,
          (json) {
            return (json! as List)
                .map(
                  (e) => typeToJsonFactoryMap[InnerType]!
                      .call(e as Map<String, dynamic>) as InnerType,
                )
                .toList();
          },
        ) as BodyType,
      );
    }

    return response.copyWith<BodyType>(
      body: BaseResponse<InnerType>.fromJson(
        parseData as Map<String, dynamic>,
        (json) {
          return typeToJsonFactoryMap[InnerType]!
              .call(json! as Map<String, dynamic>) as InnerType;
        },
      ) as BodyType,
    );
  }
}
