import 'package:flutter/material.dart';

/// Equivalent to the former Color.red / Color.green / Color.blue (0–255).
int colorChannel8(Color c, String channel) {
  switch (channel) {
    case 'red':
      return (c.r * 255.0).round() & 0xff;
    case 'green':
      return (c.g * 255.0).round() & 0xff;
    case 'blue':
      return (c.b * 255.0).round() & 0xff;
    default:
      return 0;
  }
}
