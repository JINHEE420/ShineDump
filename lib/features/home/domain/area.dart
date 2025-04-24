import 'package:freezed_annotation/freezed_annotation.dart';

part 'area.freezed.dart';

/// Represents a geographical area or location in the application.
///
/// This immutable data class contains information about locations such as
/// disposal sites, collection points, or other relevant areas in the waste
/// management system.
@freezed
class Area with _$Area {
  /// Creates a new [Area] instance with the specified properties.
  ///
  /// [id] - Unique identifier for the area.
  /// [name] - Name of the area.
  /// [address] - Physical address of the location.
  /// [typeFunction] - Function or type of the area (e.g., "recycling center", "landfill").
  /// [hotline] - Contact number for the area.
  /// [description] - Detailed description of the area and its services.
  /// [lat] - Latitude coordinate of the area.
  /// [lon] - Longitude coordinate of the area.
  /// [radius] - Optional radius in meters defining the area's coverage zone.
  const factory Area({
    required int id,
    required String name,
    required String address,
    required String typeFunction,
    required String hotline,
    required String description,
    required double lat,
    required double lon,
    double? radius,
  }) = _Area;

  const Area._();

  /// Creates an empty [Area] instance with default values.
  ///
  /// Useful for initializing area data before populating with actual values
  /// or as a placeholder in the UI.
  static Area blank() => const Area(
        id: 0,
        name: '',
        address: '',
        typeFunction: '',
        hotline: '',
        description: '',
        lat: 0,
        lon: 0,
      );
}
