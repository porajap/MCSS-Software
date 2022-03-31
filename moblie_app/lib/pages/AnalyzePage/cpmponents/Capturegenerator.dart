// import 'dart:convert';
// import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:image/image.dart' as imageLib;
// import 'package:path_provider/path_provider.dart';

import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';
import 'dart:typed_data';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

int noOfPerAxisX = 12;
int noOfPerAxisY = 8;

Future cropSquare(File imageFile, bool flip) async {
  List<File> crop = [];
  var bytes = await imageFile.readAsBytes();
  imageLib.Image? src = imageLib.decodeImage(bytes);

  var cropSize = min(src!.width, src.height);
  var cropSizeX = src.width ~/ noOfPerAxisX ;
  var cropSizeY = src.height ~/ noOfPerAxisY ;

  // int offsetX = (src.width - min(src.width, src.height)) ~/ 2;
  // int offsetY = (src.height - min(src.width, src.height)) ~/ 2;

  // imageLib.Image destImage =
  //     imageLib.copyCrop(src, offsetX, offsetY, cropSizeX, cropSizeY);
  for(int i = 0;i<noOfPerAxisY;i++){
    for(int j = 0;j<noOfPerAxisX;j++){
      imageLib.Image destImage =
      imageLib.copyCrop(src, j*cropSizeX, i*cropSizeY, cropSizeX, cropSizeY);

      if (flip) {
        destImage = imageLib.flipVertical(destImage);
      }

      var jpg = imageLib.encodeJpg(destImage);

      Directory imagePath = await getApplicationDocumentsDirectory();
      String path = imagePath.path;

      File file = File(join(imagePath.path,
          '${DateTime.now().toUtc().toIso8601String()}.png'));
      file.writeAsBytesSync(jpg);
      crop.add(file);
    }

  }

  return crop;

}

Future<String> getFilePath() async {
  Directory appDocumentsDirectory = await getApplicationDocumentsDirectory(); // 1
  String appDocumentsPath = appDocumentsDirectory.path; // 2
  String filePath = '$appDocumentsPath/2022-03-30T08:53:16.555051Z.png'; // 3

  return filePath;
}

void readFile() async {
  File file = File(await getFilePath()); // 1
  String fileContent = await file.readAsString(); // 2

  print('File Content: $fileContent');
}