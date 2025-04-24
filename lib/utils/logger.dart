import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

final logger = LoggerPretty();

class LoggerPretty {
  // Create a logger instance
  final _logger = Logger(
    level:
        Level.debug, // Set logging level (verbose, debug, info, warning, error)
    printer: PrettyPrinter(
      methodCount: 4, // Limit method count for better readability
      errorMethodCount: 5, // More detail for error logs
    ), // Optional: Pretty print for better readability
  );

  String prettyPrintJsonString(String jsonString) {
    // Decode the JSON string to a Map
    final jsonObj = jsonDecode(jsonString);
    try {
      // Pretty-print the JSON object
      final prettyString = const JsonEncoder.withIndent('  ').convert(jsonObj);

      return prettyString;
    } catch (e) {
      return jsonString;
    }
  }

  void log(String msg, {String color = LogColor.cyan, String? tag}) {
    if (!kDebugMode) return;
    developer.log(LogColor.wrap(msg, color), name: tag ?? 'Logger');
  }

  void e(String v) {
    _logger.e(v);
  }

  void d(String v) {
    _logger.d(v);
  }

  void i(String v) {
    _logger.i(v);
  }

  void f(String v) {
    _logger.f(v);
  }
}

/// Color utility class for console logs
class LogColor {
  static const String reset = '\x1B[0m';
  static const String black = '\x1B[30m';
  static const String red = '\x1B[31m';
  static const String green = '\x1B[32m';
  static const String yellow = '\x1B[33m';
  static const String blue = '\x1B[34m';
  static const String magenta = '\x1B[35m';
  static const String cyan = '\x1B[36m';
  static const String white = '\x1B[37m';
  static const String bold = '\x1B[1m';
  static const String underline = '\x1B[4m';

  /// Wraps text with the specified color
  static String wrap(String text, String color) {
    return '$color$text$reset';
  }

  /// Returns text in red
  static String error(String text) => wrap(text, red);

  /// Returns text in green
  static String success(String text) => wrap(text, green);

  /// Returns text in yellow
  static String warning(String text) => wrap(text, yellow);

  /// Returns text in cyan
  static String info(String text) => wrap(text, cyan);

  /// Returns text in magenta
  static String highlight(String text) => wrap(text, magenta);
}
