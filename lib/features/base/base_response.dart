import 'package:freezed_annotation/freezed_annotation.dart';

part 'base_response.g.dart';

@JsonSerializable(
  explicitToJson: true,
  genericArgumentFactories: true,
  fieldRename: FieldRename.snake,
)
class BaseResponse<T> {
  const BaseResponse({this.message, this.data});

  final T? data;
  final String? message;

  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$BaseResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T) toJsonT) =>
      _$BaseResponseToJson(this, toJsonT);
}
