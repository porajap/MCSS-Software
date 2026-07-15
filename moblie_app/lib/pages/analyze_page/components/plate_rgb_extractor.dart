import 'dart:typed_data';

import 'package:image/image.dart' as image_lib;
import 'package:moblie_app/utils/constants.dart';
import 'package:moblie_app/utils/plate_config.dart';

/// Plain RGB lists for isolate transfer (no Flutter imports).
class PlateRgbData {
  PlateRgbData({
    required this.red,
    required this.green,
    required this.blue,
  });

  final List<int> red;
  final List<int> green;
  final List<int> blue;
}

/// Top-level for [compute]: decode plate image and sample standard then sample wells.
/// Standard wells contribute 5 pixels each; sample wells contribute 1 center pixel.
PlateRgbData extractPixelsRgb(Uint8List bytes) {
  final red = <int>[];
  final green = <int>[];
  final blue = <int>[];

  final image_lib.Image? image = image_lib.decodeImage(bytes);
  if (image == null) {
    return PlateRgbData(red: red, green: green, blue: blue);
  }

  final int width = image.width;
  final int height = image.height;
  final int xChunk = width ~/ GridConfig.noOfPixelsPerAxisX;
  final int yChunk = height ~/ GridConfig.noOfPixelsPerAxisY;

  final int left = xChunk - 1;
  final int right = xChunk + 1;
  final int top = yChunk + 1;
  final int down = yChunk - 1;
  final int midX = (xChunk ~/ 2) + 1;
  final int midY = (yChunk ~/ 2) + 1;

  final stdRed = <int>[];
  final stdGreen = <int>[];
  final stdBlue = <int>[];
  final smpRed = <int>[];
  final smpGreen = <int>[];
  final smpBlue = <int>[];

  void addTo(List<int> r, List<int> g, List<int> b, image_lib.Pixel pixel) {
    r.add(pixel.r.toInt());
    g.add(pixel.g.toInt());
    b.add(pixel.b.toInt());
  }

  int no = 1;
  for (int j = 1; j < GridConfig.noOfPixelsPerAxisY + 1; j++) {
    for (int i = 1; i < GridConfig.noOfPixelsPerAxisX + 1; i++) {
      if (Plate.pnpStandard.contains(no)) {
        addTo(stdRed, stdGreen, stdBlue, image.getPixel(xChunk * i - midX, yChunk * j - midY));
        addTo(stdRed, stdGreen, stdBlue, image.getPixel(left * i - midX, down * j - midY));
        addTo(stdRed, stdGreen, stdBlue, image.getPixel(right * i - midX, down * j - midY));
        addTo(stdRed, stdGreen, stdBlue, image.getPixel(left * i - midX, top * j - midY));
        addTo(stdRed, stdGreen, stdBlue, image.getPixel(right * i - midX, top * j - midY));
      } else if (Plate.pnpSample!.contains(no)) {
        addTo(smpRed, smpGreen, smpBlue, image.getPixel(xChunk * i - midX, yChunk * j - midY));
      }
      no++;
    }
  }

  // Preserve previous order: Standard pixels, then Sample pixels.
  red
    ..addAll(stdRed)
    ..addAll(smpRed);
  green
    ..addAll(stdGreen)
    ..addAll(smpGreen);
  blue
    ..addAll(stdBlue)
    ..addAll(smpBlue);

  return PlateRgbData(red: red, green: green, blue: blue);
}
