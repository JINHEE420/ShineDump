import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/area.dart';

part 'area_dto.freezed.dart';
part 'area_dto.g.dart';

@freezed
class AreaDto with _$AreaDto {
  const factory AreaDto({
    @JsonKey(name: 'id') required int id,
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'address') required String address,
    @JsonKey(name: 'type_function') required String typeFunction,
    @JsonKey(name: 'hotline') String? hotline,
    @JsonKey(name: 'description') String? description,
    @JsonKey(name: 'latitude') num? latitude,
    @JsonKey(name: 'longitude') num? longitude,
    @JsonKey(name: 'radius') double? radius,
  }) = _AreaDto;

  const AreaDto._();

  // Factory method to create an AreaDto object from JSON
  factory AreaDto.fromJson(Map<String, dynamic> json) =>
      _$AreaDtoFromJson(json);

  Area toDomain() {
    return Area(
      id: id,
      name: name,
      address: address,
      typeFunction: typeFunction,
      hotline: hotline ?? '',
      description: description ?? '',
      lat: latitude?.toDouble() ?? 0.0,
      lon: longitude?.toDouble() ?? 0.0,
      radius: radius ?? 50,
    );
  }
}
