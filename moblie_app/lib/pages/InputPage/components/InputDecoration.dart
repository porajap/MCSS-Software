import 'package:flutter/material.dart';

class InputDecorations {
  static InputDecoration inputDec({required String hintText}) =>
      InputDecoration(
        fillColor: Color.fromARGB(255, 159, 49, 178),
        hintText: hintText,
        // focusColor: Colors.purple,
        alignLabelWithHint: true,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.purple, width: 1),
        ),
        contentPadding: const EdgeInsets.all(8),
      );
}
