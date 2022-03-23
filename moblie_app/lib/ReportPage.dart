import 'dart:io';
import 'dart:ui';
import 'dart:typed_data';

import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_launcher_icons/utils.dart';
import 'package:image_picker/image_picker.dart';

import 'RGBgenerator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void _printRGB() async {
  final Uint8List inputImg =
      (await rootBundle.load("assets/images/water.jpg")).buffer.asUint8List();
  // final decoder = imageLib.JpegDecoder();
  // imageLib.Image? decodedImg = decoder.decodeImage(inputImg);
  // final decodedBytes = decodedImg?.getBytes(format: imageLib.Format.rgb);
  // // imageLib.Image? decodedImage;
  // // print(decodedImage);
  // int? width = decodedImg?.width;
  // int? height = decodedImg?.height;

  // print(decodedImg);

  // List<List<List<int>>> imgArr = [];
  // for (int y = 0; y < height!; y++) {
  //   imgArr.add([]);
  //   for (int x = 0; x < width!; x++) {
  //     int red = decodedBytes![(y * width * 3) + x * 3];
  //     int green = decodedBytes[(y * width * 3 + x * 3) + 1];
  //     int blue = decodedBytes[y * width * 3 + x * 3 + 2];
  //     imgArr[y].add([red, green, blue]);
  //   }
  // }
  // return print(imgArr);
}

class ReportPage extends StatefulWidget {
  final File? imageFile;
  ReportPage({this.imageFile});
  // const ReportPage({Key? key}) : super(key: key);

  @override
  State<ReportPage> createState() => _ReportPageState();
}

int noOfPaletteColors = 4;
String photo = '';

class _ReportPageState extends State<ReportPage> {
  List<Color> colors = [];
  List<int> red = [];
  List<int> green = [];
  List<int> blue = [];

  // List<Color> sortedColors = [];
  // List<Color> palette = [];

  // Color primary = Colors.blueGrey;
  // Color primaryText = Colors.black;
  // Color background = Colors.white;

  // late Random random;
  Uint8List? imageBytes;

  @override
  void initState() {
    super.initState();
    // random = Random();
    extractColors();
    // print(widget.imageFile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: UniqueKey(),
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                extractColors();
              },
              icon: Icon(Icons.refresh))
        ],
        title: Text(
          'Report',
        ),
      ),
      body: Container(
        // decoration: BoxDecoration(
        //     gradient: palette.isEmpty
        //         ? null
        //         : LinearGradient(
        //             begin: Alignment.bottomCenter,
        //             end: Alignment.topCenter,
        //             stops: [0.01, 0.6, 1],
        //             colors: [
        //               palette.first.withOpacity(0.3),
        //               palette[palette.length ~/ 2],
        //               palette.last.withOpacity(0.9),
        //             ],
        //           )),
        child: ListView(
          children: [
            SizedBox(
              height: 20,
            ),
            SizedBox(
              child: imageBytes != null && imageBytes!.length > 0
                  ? Image.file(
                      widget.imageFile!,
                      fit: BoxFit.fill,
                    )
                  : Center(child: CircularProgressIndicator()),
              // height: 250,
            ),
            SizedBox(
              height: 10,
            ),
            _getGrids(),
          ],
        ),
      ),
    );
  }

  Future<void> extractColors() async {
    colors = [];
    // sortedColors = [];
    // palette = [];
    imageBytes = null;

    setState(() {});

    // noOfPaletteColors = random.nextInt(4) + 2;
    // photo = photos[random.nextInt(photos.length)];

    // imageBytes = (await NetworkAssetBundle(Uri.parse(photo)).load(photo))
    //     .buffer
    //     .asUint8List();

    imageBytes = await _readFileByte(widget.imageFile);
    // print(imageBytes);
    colors = await compute(extractPixelsColors, imageBytes);
    red = getColorValue(colors, 'red');
    green = getColorValue(colors, 'green');
    blue = getColorValue(colors, 'blue');
    setState(() {});
    // sortedColors = await compute(sortColors, colors);
    // setState(() {});
    // palette = await compute(
    //     generatePalette, {keyPalette: colors, keyNoOfItems: noOfPaletteColors});
    // primary = palette.last;
    // primaryText = palette.first;
    // background = palette.first.withOpacity(0.5);
    // setState(() {});

    print(red);
    print(green);
    print(blue);
  }

  Widget _getGrids() {
    return SizedBox(
      // height: 200,
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: colors.isEmpty
                ? Container(
                    child: CircularProgressIndicator(),
                    alignment: Alignment.center,
                    height: 200,
                  )
                : Column(
                    children: [
                      Text(
                        'Extracted Pixels',
                        style: TextStyle(color: Colors.black),
                      ),
                      SizedBox(height: 10),
                      GridView.builder(
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: noOfPixelsPerAxisX),
                          itemCount: colors.length,
                          itemBuilder: (BuildContext ctx, index) {
                            return Container(
                              alignment: Alignment.center,
                              child: Container(
                                color: colors[index],
                              ),
                              decoration: BoxDecoration(
                                  border: Border.all(width: 1),
                                  color: Colors.grey),
                            );
                          }),
                    ],
                  ),
          )
        ],
      ),
    );
  }

  // Widget _getPalette() {
  //   return SizedBox(
  //     height: 50,
  //     child: palette.isEmpty
  //         ? Container(
  //             child: CircularProgressIndicator(),
  //             alignment: Alignment.center,
  //             height: 100,
  //           )
  //         : ListView.builder(
  //             shrinkWrap: true,
  //             scrollDirection: Axis.horizontal,
  //             itemCount: palette.length,
  //             itemBuilder: (BuildContext context, int index) => Container(
  //               color: palette[index],
  //               height: 50,
  //               width: 50,
  //             ),
  //           ),
  //   );
  // }

  Future<Uint8List> _readFileByte(File? filePath) async {
    // Uri myUri = Uri.parse(filePath);
    // File audioFile = new File.fromUri(myUri);
    File audioFile = filePath!;
    Uint8List bytes =
        (await rootBundle.load('assets/images/water.jpg')).buffer.asUint8List();
    await audioFile.readAsBytes().then((value) {
      bytes = Uint8List.fromList(value);
      print('reading of bytes is completed');
    }).catchError((onError) {
      print('Exception Error while reading audio from path:' +
          onError.toString());
    });
    return bytes;
  }
}
