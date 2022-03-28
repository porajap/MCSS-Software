import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as imageLib;

const String keyPalette = 'palette';
const String keyNoOfItems = 'noIfItems';

int noOfPixelsPerAxisX = 12;
int noOfPixelsPerAxisY = 8;

Color getAverageColor(List<Color> colors) {
  int r = 0, g = 0, b = 0;

  for (int i = 0; i < colors.length; i++) {
    r += colors[i].red;
    g += colors[i].green;
    b += colors[i].blue;
  }

  r = r ~/ colors.length;
  g = g ~/ colors.length;
  b = b ~/ colors.length;

  return Color.fromRGBO(r, g, b, 1);
}

Color abgrToColor(int argbColor) {
  int r = (argbColor >> 16) & 0xFF;
  int b = argbColor & 0xFF;
  int hex = (argbColor & 0xFF00FF00) | (b << 16) | r;
  return Color(hex);
}

List<Color> sortColors(List<Color> colors) {
  List<Color> sorted = [];

  sorted.addAll(colors);
  sorted.sort((a, b) => b.computeLuminance().compareTo(a.computeLuminance()));

  return sorted;
}

List<Color> generatePalette(Map<String, dynamic> params) {
  List<Color> colors = [];
  List<Color> palette = [];

  colors.addAll(sortColors(params[keyPalette]));

  int noOfItems = params[keyNoOfItems];

  if (noOfItems <= colors.length) {
    int chunkSize = colors.length ~/ noOfItems;

    for (int i = 0; i < noOfItems; i++) {
      palette.add(
          getAverageColor(colors.sublist(i * chunkSize, (i + 1) * chunkSize)));
    }
  }

  return palette;
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
      if (i > 4 || j > 6) {
        pixel = image?.getPixel(xChunk2 * i - midX, yChunk2 * j - midY);
      } else {
        pixel = image?.getPixel(xChunk * i - midX, yChunk * j - midY);
      }

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
