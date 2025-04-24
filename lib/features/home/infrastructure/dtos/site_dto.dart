import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/site.dart';

part 'site_dto.freezed.dart';
part 'site_dto.g.dart';

@freezed
class SiteDto with _$SiteDto {
  const factory SiteDto({
    required int id,
    String? name,
    String? address,
    String? phone,
  }) = _SiteDto;

  const SiteDto._();

  // Factory constructor to handle the conversion from JSON to BaseResponse
  factory SiteDto.fromJson(Map<String, dynamic> json) =>
      _$SiteDtoFromJson(json);

  Site toDomain() {
    return Site(
      id: id,
      name: name,
      phone: phone,
      address: address,
    );
  }
}
