import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as imageLib;

const String keyPalette = 'palette';
const String keyNoOfItems = 'noIfItems';

int noOfPixelsPerAxisX = 12;
int noOfPixelsPerAxisY = 8;

Color abgrToColor(int argbColor) {
  int r = (argbColor >> 16) & 0xFF;
  int b = argbColor & 0xFF;
  int hex = (argbColor & 0xFF00FF00) | (b << 16) | r;
  return Color(hex);
}

List<Color> extractPixelsColors(Uint8List? bytes) {
  List<Color> colors = [];

  List<int> values = bytes!.buffer.asUint8List();
  imageLib.Image? image = imageLib.decodeImage(values);

  List<int?> pixels = [];

  int? width = image?.width;
  int? height = image?.height;

  print('w: $width, h: $height');

  int xChunk = width! ~/ (noOfPixelsPerAxisX);
  int yChunk = height! ~/ (noOfPixelsPerAxisY);

  int xChunk2 = xChunk + 1;
  int yChunk2 = yChunk + 1;

  int midX = xChunk ~/ 2;
  int midY = yChunk ~/ 2;
  // print(midX);
  // print(midY);

  for (int j = 1; j < noOfPixelsPerAxisY + 1; j++) {
    for (int i = 1; i < noOfPixelsPerAxisX + 1; i++) {
      int? pixel;
      // if (i > 4 || j > 6) {
      //   pixel = image?.getPixel(xChunk2 * i - midX, yChunk2 * j - midY);
      // } else {
      pixel = image?.getPixel(xChunk * i - midX, yChunk * j - midY);
      // }

      pixels.add(pixel);
      Color c = abgrToColor(pixel!);
      colors.add(c);
    }
  }
  // print(colors.length);

  return colors;
}

List<int> getColorValue(List<Color> c, String color) {
  List<int> value = [];

  if (color == 'red') {
    c.forEach((c) => value.add(c.red));
  }
  if (color == 'green') {
    c.forEach((c) => value.add(c.green));
  }
  if (color == 'blue') {
    c.forEach((c) => value.add(c.blue));
  }
  return value;
}
