import 'package:freezed_annotation/freezed_annotation.dart';

part 'site.freezed.dart';

@freezed
class Site with _$Site {
  const factory Site({
    required int id,
    required String? name,
    required String? address,
    required String? phone,
  }) = _Site;

  const Site._();

  static Site blank() => const Site(
        id: 0,
        name: '',
        address: '',
        phone: '',
      );
}
