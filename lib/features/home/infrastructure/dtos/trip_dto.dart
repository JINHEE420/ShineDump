// import 'package:freezed_annotation/freezed_annotation.dart';

// import '../../domain/area.dart';

// part 'trip_dto.freezed.dart';

// part 'trip_dto.g.dart';

// @freezed
// class TripDto with _$TripDto {
//   const factory TripDto({
//     required int id,
//     required String name,
//     required String address,
//     @JsonKey(name: 'type_function') required String typeFunction,
//     String? hotline,
//     String? description,
//     num? lat,
//     num? lon,
//   }) = _TripDto;

//   const TripDto._();

//   // Factory method to create an TripDto object from JSON
//   factory TripDto.fromJson(Map<String, dynamic> json) =>
//       _$TripDtoFromJson(json);

//   Area toDomain() {
//     return Area(
//       id: id,
//       name: name,
//       address: address,
//       typeFunction: typeFunction,
//       hotline: hotline ?? '',
//       description: description ?? '',
//       lat: lat?.toDouble() ?? 0.0,
//       lon: lon?.toDouble() ?? 0.0,
//     );
//   }
// }
