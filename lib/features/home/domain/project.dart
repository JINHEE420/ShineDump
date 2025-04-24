import 'package:freezed_annotation/freezed_annotation.dart';

part 'project.freezed.dart';

@freezed
class Project with _$Project {
  const factory Project({
    required int id,
    required String siteName,
    required String name,
    required String address,
    required String fullName,
    required String description,
    required String phone,
  }) = _Project;

  const Project._();

  static Project blank() => const Project(
        id: 0,
        siteName: '',
        name: '',
        address: '',
        fullName: '',
        description: '',
        phone: '',
      );
}
