import 'package:flutter/material.dart';

class InputDecorations {
  static InputDecoration inputDec({required String hintText}) =>
      InputDecoration(
        hintText: hintText,
        focusColor: Colors.purple,
        alignLabelWithHint: true,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.purple, width: 1),
        ),
        contentPadding: const EdgeInsets.all(8),
        enabledBorder: const OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            const Radius.circular(10),
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      );
}
