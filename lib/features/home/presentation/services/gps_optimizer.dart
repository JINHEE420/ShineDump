import 'dart:math';

import '/features/home/infrastructure/data_sources/gps_remote_data_source.dart';
import '/utils/logger.dart';

/// The `GpsOptimizer` class provides a set of utilities for optimizing GPS data.
/// It includes methods for path simplification, smoothing, duplicate removal,
/// and distance calculation. The class is designed to process GPS tracks and
/// improve their quality for further analysis or visualization.
///
/// Key Features:
/// - **Path Simplification**: Implements the Douglas-Peucker algorithm to reduce
///   the number of points in a GPS track while preserving its shape.
/// - **Smoothing**: Applies a moving average to smooth the GPS track.
/// - **Duplicate Removal**: Removes duplicate points based on timestamps.
/// - **Zero-Speed Filtering**: Filters out points with zero speed while retaining
///   the first point.
/// - **Distance Calculation**: Computes the total distance of a GPS track using
///   the Haversine formula.
/// - **Time-Based Filtering**: Retrieves GPS data within a specified time range.
/// - **JSON Conversion**: Converts JSON data into a list of `GPSData` objects.
///
/// This class is implemented as a singleton to ensure a single instance is used
/// throughout the application.
///
/// Example Usage:
/// ```dart
/// final optimizer = GpsOptimizer();
/// final optimizedTrack = optimizer.optimizeTrack(originalTrack);
/// final distance = optimizer.calculateDistance(optimizedTrack);
/// ```
class GpsOptimizer {
  factory GpsOptimizer() => _instance;
  GpsOptimizer._();

  static final _instance = GpsOptimizer._();

  // Douglas-Peucker algorithm for path simplification
  List<GPSData> simplifyTrack(List<GPSData> points, double epsilon) {
    if (points.length <= 2) return List.from(points);

    // Find the point with max distance
    var indexMax = 0;
    double dmax = 0;

    for (var i = 1; i < points.length - 1; i++) {
      final d = perpendicularDistance(points[i], points.first, points.last);
      if (d > dmax) {
        indexMax = i;
        dmax = d;
      }
    }

    // If max distance > epsilon, recursively simplify
    var results = <GPSData>[];
    if (dmax > epsilon) {
      // Recursive call
      final recResults1 =
          simplifyTrack(points.sublist(0, indexMax + 1), epsilon);
      final recResults2 = simplifyTrack(points.sublist(indexMax), epsilon);

      // Build the result list
      results = [
        ...recResults1.sublist(0, recResults1.length - 1),
        ...recResults2,
      ];
    } else {
      results = [points.first, points.last];
    }

    return results;
  }

  // Calculate perpendicular distance from point to line
  double perpendicularDistance(
    GPSData point,
    GPSData lineStart,
    GPSData lineEnd,
  ) {
    // Convert degrees to radians for calculation
    final latRad1 = radians(lineStart.lat);
    final lonRad1 = radians(lineStart.long);
    final latRad2 = radians(lineEnd.lat);
    final lonRad2 = radians(lineEnd.long);
    final latRadP = radians(point.lat);
    final lonRadP = radians(point.long);

    // Calculate using the Haversine formula
    if (lonRad1 == lonRad2 && latRad1 == latRad2) {
      return haversineDistance(latRadP, lonRadP, latRad1, lonRad1) *
          1000; // Convert to meters
    }

    // Math to find perpendicular distance
    final bearingA = bearing(latRad1, lonRad1, latRad2, lonRad2);
    final bearingB = bearing(latRad1, lonRad1, latRadP, lonRadP);
    final dist =
        haversineDistance(latRad1, lonRad1, latRadP, lonRadP) * 1000; // meters

    return dist * sin(bearingB - bearingA).abs();
  }

  // Haversine formula to calculate distance between GPS coordinates
  double haversineDistance(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371; // Earth radius in kilometers
    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  // Calculate bearing between two points
  double bearing(double lat1, double lon1, double lat2, double lon2) {
    final dLon = lon2 - lon1;
    final y = sin(dLon) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    return atan2(y, x);
  }

  double radians(double degrees) => degrees * (pi / 180);

  // Moving average for smoother paths
  List<GPSData> applyMovingAverage(List<GPSData> points, int windowSize) {
    if (points.length <= windowSize) return List.from(points);

    final smoothedPoints = <GPSData>[];

    // Keep first point
    smoothedPoints.add(points.first);

    // Process middle points with moving average
    for (var i = windowSize ~/ 2; i < points.length - windowSize ~/ 2; i++) {
      double sumLat = 0, sumLon = 0;

      // Calculate window average
      for (var j = i - windowSize ~/ 2; j <= i + windowSize ~/ 2; j++) {
        sumLat += points[j].lat;
        sumLon += points[j].long;
      }

      final smoothedPoint = GPSData(
        lat: sumLat / windowSize,
        long: sumLon / windowSize,
        speed: points[i].speed,
        distanceMoving: points[i].distanceMoving,
        timeStamp: points[i].timeStamp,
      );

      smoothedPoints.add(smoothedPoint);
    }

    // Keep last point
    smoothedPoints.add(points.last);

    return smoothedPoints;
  }

  // Remove duplicate points by time
  List<GPSData> removeDuplicatesByTime(List<GPSData> points) {
    if (points.length <= 1) return points;

    final uniquePoints = <GPSData>[];
    final seenTimes = <String>{};

    for (final point in points) {
      final timeKey = point.timeStamp;
      if (!seenTimes.contains(timeKey)) {
        seenTimes.add(timeKey);
        uniquePoints.add(point);
      }
    }

    return uniquePoints;
  }

  // Remove points with speed 0 but keep first point
  List<GPSData> removeZeroSpeedPoints(List<GPSData> points) {
    if (points.isEmpty) return [];

    final result = <GPSData>[points.first]; // Always keep first point

    // Filter the remaining points
    for (var i = 1; i < points.length; i++) {
      if ((points[i].speed ?? 0) > 0) {
        result.add(points[i]);
      }
    }

    // If all points were removed except first, return original first point
    return result.isEmpty ? [points.first] : result;
  }

  // Complete optimization pipeline
  List<GPSData> optimizeTrack(List<GPSData> originalTrack) {
    // Step 1: Remove points with speed 0
    var optimizedTrack = removeZeroSpeedPoints(originalTrack);
    logger.log(
      'After removing zero speed points: ${optimizedTrack.length} points',
    );

    // Step 2: Remove duplicates by time
    // optimizedTrack = removeDuplicatesByTime(optimizedTrack);
    // logger.log(
    //   'After removing duplicates: ${optimizedTrack.length} points',
    // );

    // Continue with the rest of your pipeline...
    optimizedTrack = applyMovingAverage(optimizedTrack, 3);
    optimizedTrack = simplifyTrack(optimizedTrack, 0.00005);

    logger.log('Final optimized track: ${optimizedTrack.length} points');
    logger.log(
      'Total reduction: ${((originalTrack.length - optimizedTrack.length) / originalTrack.length * 100).toStringAsFixed(2)}%',
    );

    return optimizedTrack;
  }

  double calculateDistance(List<GPSData> track) {
    if (track.length <= 1) return 0;

    double distance = 0;
    for (var i = 1; i < track.length; i++) {
      distance += haversineDistance(
        radians(track[i - 1].lat),
        radians(track[i - 1].long),
        radians(track[i].lat),
        radians(track[i].long),
      );
    }

    return distance;
  }

  // get all gps data that has time equal "2025-03-28 09:25:56"
  List<GPSData> getGPSDataByTime(
    List<GPSData> gpsData, {
    required String startTime,
    required String endTime,
  }) {
    return gpsData.where((element) {
      final time = DateTime.parse(element.timeStamp);
      final start = DateTime.parse(startTime);
      final end = DateTime.parse(endTime);
      return time.isAfter(start) && time.isBefore(end);
    }).toList();
  }

  // create method to convert JSON to GPSData
  // For example: [{"id":539915,"latitude":37.5113419,"longitude":127.0639871,"status":"FORCE","speed":4.0856594569049776E-4,"distance":0.0,"time":"2025-03-28 09:05:42"}
  List<GPSData> fromJson(List<Map<String, dynamic>> json) {
    return json
        .map(
          (e) => GPSData(
            lat: e['latitude'] as double,
            long: e['longitude'] as double,
            speed: e['speed'] as double,
            distanceMoving: e['distance'] as double,
            timeStamp: e['time'] as String,
          ),
        )
        .toList();
  }
}
