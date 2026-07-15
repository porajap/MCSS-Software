import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as image_lib;
import 'package:moblie_app/utils/plate_config.dart';
import '../../../my_app.dart';
import '../../../utils/constants.dart';

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

Color pixelToFlutterColor(image_lib.Pixel pixel) {
  return Color.fromARGB(
    pixel.a.toInt(),
    pixel.r.toInt(),
    pixel.g.toInt(),
    pixel.b.toInt(),
  );
}

Map<String, List<Color>> extractPixelsColors(Uint8List? bytes) {
  Map<String, List<Color>> colorCode = {};

  try {
    image_lib.Image? image = image_lib.decodeImage(bytes!);
    List<Color> colorOfStandard = [];
    List<Color> colorOfSample = [];
    List<image_lib.Pixel?> pixels = [];

    int? width = image?.width;
    int? height = image?.height;

    int xChunk = width! ~/ (GridConfig.noOfPixelsPerAxisX);
    int yChunk = height! ~/ (GridConfig.noOfPixelsPerAxisY);

    int left = xChunk - 1;
    int right = xChunk + 1;
    int top = yChunk + 1;
    int down = yChunk - 1;

    int midX = xChunk ~/ 2;
    int midY = yChunk ~/ 2;
    int no = 1;
    midX = midX + 1;
    midY = midY + 1;
    for (int j = 1; j < GridConfig.noOfPixelsPerAxisY + 1; j++) {
      for (int i = 1; i < GridConfig.noOfPixelsPerAxisX + 1; i++) {
        image_lib.Pixel? pixel;
        if (Plate.pnpStandard.contains(no)) {
          Color pixel1 = pixelToFlutterColor((image?.getPixel(xChunk * i - midX, yChunk * j - midY))!);
          var pixel2 = pixelToFlutterColor((image?.getPixel(left * i - midX, down * j - midY))!);
          var pixel3 = pixelToFlutterColor((image?.getPixel(right * i - midX, down * j - midY))!);
          var pixel4 = pixelToFlutterColor((image?.getPixel(left * i - midX, top * j - midY))!);
          var pixel5 = pixelToFlutterColor((image?.getPixel(right * i - midX, top * j - midY))!);

          colorOfStandard.add(pixel1);
          colorOfStandard.add(pixel2);
          colorOfStandard.add(pixel3);
          colorOfStandard.add(pixel4);
          colorOfStandard.add(pixel5);
        } else if (Plate.pnpSample!.contains(no)) {
          pixel = image?.getPixel(xChunk * i - midX, yChunk * j - midY);
          pixels.add(pixel);
          Color c = pixelToFlutterColor(pixel!);
          colorOfSample.add(c);
        }
        no++;
      }
    }
    colorCode[PreferenceKey.standard] = colorOfStandard;
    colorCode[PreferenceKey.sample] = colorOfSample;
  } catch (e) {
    logger.e('Fail: can not get RGB code from image');
  }

  return colorCode;
}

List<int> getColorValue(List<Color> c, String color) {
  List<int> value = [];

  try {
    for (final item in c) {
      value.add(colorChannel8(item, color));
    }
  } catch (e) {
    logger.e('Fail: can not convert hexcode to rgbcode');
  }
  return value;
}
