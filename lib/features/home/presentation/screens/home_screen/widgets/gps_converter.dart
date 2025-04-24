import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../infrastructure/data_sources/gps_remote_data_source.dart';
import '../../../services/gps_optimizer.dart';

/// A widget that provides utilities for converting and copying GPS data.
///
/// This widget includes buttons to copy the original GPS data, optimized GPS data,
/// and GPS data filtered by a specific time range.
class GPSConverter extends StatelessWidget {
  const GPSConverter({super.key});

  /// The asset name for the GPS data file.
  static const gpsAssetName = 'assets/gps/1147.json';

  /// Loads GPS data from the asset file.
  Future<List<GPSData>> _loadGPSData() async {
    final str = await rootBundle.loadString(gpsAssetName);
    final json =
        (jsonDecode(str) as List<dynamic>).cast<Map<String, dynamic>>();
    return GpsOptimizer().fromJson(json);
  }

  /// Copies the original GPS data to the clipboard.
  Future<void> _copyOriginal(BuildContext context) async {
    final data = await _loadGPSData();
    final text = await _getGPSDataAsString(data);
    await Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied original GPS'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Copies the optimized GPS data to the clipboard.
  Future<void> _copyOptimized(BuildContext context) async {
    final data = await _loadGPSData();
    final optimizedData = GpsOptimizer().optimizeTrack(data);
    final text = await _getGPSDataAsString(optimizedData);
    await Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied optimized GPS'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Copies GPS data filtered by a specific time range to the clipboard.
  ///
  /// The time range is hardcoded for demonstration purposes.
  Future<void> _copyByTime(BuildContext context) async {
    final data = await _loadGPSData();
    final filteredData = GpsOptimizer().getGPSDataByTime(
      data,
      startTime: '2025-03-28 13:00:00',
      endTime: '2025-03-28 15:00:00',
    );
    final text = await _getGPSDataAsString(filteredData);
    await Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied GPS by time'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Converts a list of GPS data into a GeoJSON string.
  ///
  /// The GeoJSON format includes a `FeatureCollection` with a single `LineString`
  /// geometry representing the GPS track.
  Future<String> _getGPSDataAsString(List<GPSData> track) async {
    final geoJson = {
      'type': 'FeatureCollection',
      'features': [
        {
          'type': 'Feature',
          'properties': {},
          'geometry': {
            'coordinates': track.map((e) => [e.long, e.lat]).toList(),
            'type': 'LineString',
          },
        },
      ],
    };
    final jsonString = jsonEncode(geoJson);
    return jsonString;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('GPS Converter'),
        Row(
          children: [
            // copy button,
            Expanded(
              child: ElevatedButton(
                onPressed: () => _copyOriginal(context),
                child: const Text('Origin'),
              ),
            ),
            const SizedBox(width: 12),
            // copy button,
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () => _copyOptimized(context),
                child: const Text('Optimized'),
              ),
            ),
            const SizedBox(width: 12),
            // copy button,
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () => _copyByTime(context),
                child: const Text('Get GPS by time'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
