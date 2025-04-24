import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/project.dart';

part 'project_dto.freezed.dart';
part 'project_dto.g.dart';

@freezed
class ProjectDto with _$ProjectDto {
  const factory ProjectDto({
    @JsonKey(name: 'id') required int id,
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'address') required String address,
    @JsonKey(name: 'site_name') String? siteName,
    @JsonKey(name: 'full_name') String? fullName,
    @JsonKey(name: 'description') String? description,
    @JsonKey(name: 'phone') String? phone,
  }) = _ProjectDto;

  const ProjectDto._();

  factory ProjectDto.fromJson(Map<String, dynamic> json) =>
      _$ProjectDtoFromJson(json);

  Project toDomain() {
    return Project(
      id: id,
      siteName: siteName ?? '',
      name: name,
      address: address,
      fullName: fullName ?? '',
      description: description ?? '',
      phone: phone ?? '',
    );
  }
}
