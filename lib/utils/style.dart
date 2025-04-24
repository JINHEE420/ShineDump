import 'package:flutter/widgets.dart';

TextStyle gpsTextStyle(
    {required FontWeight weight,
    required double fontSize,
    double? lineHeight,
    Color? color}) {
  return TextStyle(
    fontWeight: weight,
    fontSize: fontSize,
    color: color,
    height: fontSize / (lineHeight ?? fontSize),
  );
}
