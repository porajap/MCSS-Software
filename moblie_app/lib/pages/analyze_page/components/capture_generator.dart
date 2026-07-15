import 'dart:io';

import 'package:image/image.dart' as image_lib;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../../../utils/constants.dart';

Future cropSquare(File imageFile, bool flip) async {
  List<File> crop = [];
  var bytes = await imageFile.readAsBytes();
  image_lib.Image? src = image_lib.decodeImage(bytes);

  var cropSizeX = src!.width ~/ GridConfig.noOfPixelsPerAxisX;
  var cropSizeY = src.height ~/ GridConfig.noOfPixelsPerAxisY;

  for (int i = 0; i < GridConfig.noOfPixelsPerAxisY; i++) {
    for (int j = 0; j < GridConfig.noOfPixelsPerAxisX; j++) {
      image_lib.Image destImage = image_lib.copyCrop(
        src,
        x: j * cropSizeX,
        y: i * cropSizeY,
        width: cropSizeX,
        height: cropSizeY,
      );

      if (flip) {
        destImage = image_lib.flipVertical(destImage);
      }

      var jpg = image_lib.encodeJpg(destImage);

      Directory imagePath = await getApplicationDocumentsDirectory();

      File file = File(join(imagePath.path, '${DateTime.now().toUtc().toIso8601String()}.png'));
      file.writeAsBytesSync(jpg);
      crop.add(file);
    }
  }

  return crop;
}
