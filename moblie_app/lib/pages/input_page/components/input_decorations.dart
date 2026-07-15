import 'package:flutter/material.dart';

import '../../../utils/color_config.dart';

class InputDecorations {
  static InputDecoration inputDec({required String hintText}) => InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hintText,
        hintStyle: TextStyle(color: ColorCode.textMuted.withValues(alpha: 0.7), fontSize: 14),
        alignLabelWithHint: true,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: ColorCode.accentPurple.withValues(alpha: 0.45), width: 1),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: ColorCode.accentPurple, width: 1.5),
        ),
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: ColorCode.accentPurple.withValues(alpha: 0.45), width: 1),
        ),
      );
}
