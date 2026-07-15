import 'package:flutter/material.dart';

Map<int, Color> primarySwatchShades = {
  50: const Color.fromRGBO(136, 14, 79, .1),
  100: const Color.fromRGBO(136, 14, 79, .2),
  200: const Color.fromRGBO(136, 14, 79, .3),
  300: const Color.fromRGBO(136, 14, 79, .4),
  400: const Color.fromRGBO(136, 14, 79, .5),
  500: const Color.fromRGBO(136, 14, 79, .6),
  600: const Color.fromRGBO(136, 14, 79, .7),
  700: const Color.fromRGBO(136, 14, 79, .8),
  800: const Color.fromRGBO(136, 14, 79, .9),
  900: const Color.fromRGBO(136, 14, 79, 1),
};

class ColorCode {
  static MaterialColor appBarColor = MaterialColor(0xFF795548, primarySwatchShades);
  static Color iconsAppBar = Colors.white;

  /// Existing purple used by input borders.
  static const Color accentPurple = Color.fromARGB(255, 159, 49, 178);

  /// Soft neutrals for minimal layout (not brand accents).
  static const Color divider = Color(0xFFE8E4E1);
  static const Color surfaceMuted = Color(0xFFF7F5F4);
  static const Color textMuted = Color(0xFF6B6560);
  static const Color borderSubtle = Color(0xFFD6D0CC);
}
