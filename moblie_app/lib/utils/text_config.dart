import 'package:flutter/material.dart';

import 'color_config.dart';

class StyleText {
  static TextStyle appBar = const TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w600,
    fontSize: 18,
    letterSpacing: 0.2,
  );

  static TextStyle normalText = const TextStyle(
    color: Colors.black87,
    fontSize: 14,
    height: 1.35,
    fontWeight: FontWeight.w400,
  );

  static TextStyle headerText = const TextStyle(
    color: Colors.black87,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  static TextStyle labelText = TextStyle(
    color: ColorCode.textMuted,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
  );

  static TextStyle buttonText = const TextStyle(
    color: Colors.white,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
  );

  static TextStyle resultText = const TextStyle(
    color: Colors.black87,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static TextStyle titleText = const TextStyle(
    color: Colors.black87,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );
}
