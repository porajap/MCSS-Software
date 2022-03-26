import 'dart:io';
import 'dart:ui';
import 'dart:typed_data';
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_launcher_icons/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moblie_app/ReportInfo.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

import 'RGBgenerator.dart';
import 'Graphgenerator.dart';

class ReportPage extends StatefulWidget {
  final File? imageFile;
  ReportInfo report;
  ReportPage({this.imageFile, required this.report});
  // const ReportPage({Key? key}) : super(key: key);

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  List<Color> colors = [];
  List<int> red = [];
  List<int> green = [];
  List<int> blue = [];
  Set<Object> result = {};
  // ReportInfo report = widget.report;

  Uint8List? imageBytes;

  @override
  void initState() {
    super.initState();
    extractColors();
    // print(widget.imageFile);
    // print(widget.report.evaluate);
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
    imageBytes = null;

    setState(() {});

    imageBytes = await _readFileByte(widget.imageFile);
    // print(imageBytes);
    colors = await compute(extractPixelsColors, imageBytes);
    red = getColorValue(colors, 'red');
    green = getColorValue(colors, 'green');
    blue = getColorValue(colors, 'blue');

    widget.report.red = red;
    widget.report.green = green;
    widget.report.blue = blue;
    setState(() {});
    calGraph();
    // print(widget.report.red);
    // print(green);
    // print(blue);
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

  void calGraph() {
    var con = widget.report.con[widget.report.info_evaluate];
    // print(con! + con);
    // setState(() {});
    result = calculate(
        widget.report.calStandard(), con! + con, widget.report.calSample());
    // print(result);
    print(result.elementAt(0));
  }
}
