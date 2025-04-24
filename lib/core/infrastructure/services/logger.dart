import 'dart:developer' as dev;

import 'package:logging/logging.dart';

/// A callback generator for logging messages with optional formatting.
///
/// This function returns a callback that can be used with the [Logger] class
/// to handle [LogRecord] instances. It supports customizing the log output
/// with a prefix and colorization.
///
/// Parameters:
/// - [prefix]: Optional string to prepend to each log message
/// - [logColor]: Optional [LogColor] to colorize the log message
///
/// Returns a function that processes [LogRecord] objects for logging,
/// or null if no processing is needed.
///
/// Example:
/// ```dart
/// final logger = Logger('MyLogger');
/// logger.onRecord.listen(loggerOnDataCallback(
///   prefix: '[APP] ',
///   logColor: LogColor.green,
/// ));
/// ```
void Function(LogRecord)? loggerOnDataCallback(
    {String prefix = '', LogColor? logColor}) {
  return (record) {
    final message = logColor?.colorize(record.message) ?? record.message;
    dev.log(
      '$prefix$message',
      time: record.time,
      sequenceNumber: record.sequenceNumber,
      level: record.level.value,
      name: record.loggerName,
      zone: record.zone,
      error: record.error,
      stackTrace: record.stackTrace,
    );
  };
}

/// ANSI color codes for console log colorization.
///
/// This enum provides a set of colors that can be used to format log messages
/// in the terminal or console output. Each enum value corresponds to a specific
/// ANSI color code.
///
/// Use the [colorize] method to apply the color to a string message.
///
/// Note: Colors will only be visible in environments that support ANSI color codes,
/// such as most terminal emulators. They will not affect the appearance in
/// environments that don't support ANSI colors.
enum LogColor {
  /// Black text color
  black('\x1B[30m'),

  /// White text color
  white('\x1B[37m'),

  /// Red text color, typically used for errors
  red('\x1B[31m'),

  /// Green text color, typically used for success messages
  green('\x1B[32m'),

  /// Yellow text color, typically used for warnings
  yellow('\x1B[33m'),

  /// Blue text color
  blue('\x1B[34m'),

  /// Cyan text color
  cyan('\x1B[36m');

  /// Creates a [LogColor] with the specified ANSI color code.
  const LogColor(this._code);

  /// The ANSI code for this color.
  final String _code;

  /// The ANSI reset code to return to default formatting.
  static const _resetCode = '\x1B[0m';

  /// Applies this color to the provided message string.
  ///
  /// This method wraps each line of the message with the appropriate
  /// color codes, ensuring proper colorization of multi-line strings.
  ///
  /// Parameter:
  /// - [msg]: The string message to colorize
  ///
  /// Returns the colorized string that will display with this color
  /// when shown in compatible terminals.
  String colorize(String msg) => _multiLineColor(msg);

  /// Internal helper to colorize each line of a multi-line string.
  ///
  /// Ensures that each line of a multi-line string gets properly colorized
  /// by applying the color code at the start of each line and the reset
  /// code at the end.
  String _multiLineColor(String msg) {
    final pattern = RegExp(r'(^.*$)', multiLine: true);
    return msg.replaceAllMapped(
        pattern, (match) => '$_code${match.group(0)}$_resetCode');
  }
}
