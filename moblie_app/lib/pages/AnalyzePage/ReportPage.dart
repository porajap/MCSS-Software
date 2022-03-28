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
import 'package:intl/intl.dart';
import 'package:moblie_app/models/ReportInfo.dart';
import 'package:scidart/numdart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

import 'cpmponents/Graphgenerator.dart';
import '../InputPage/components/RGBgenerator.dart';
import '../../models/ReportInfo.dart';

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
  late PolyFit equation;
  List<double> result = [];
  Uint8List? imageBytes;
  final date = DateTime.now();

  static const headerText =
      TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold);
  static const normalText = TextStyle(color: Colors.black, fontSize: 20);

  @override
  void initState() {
    super.initState();
    extractColors();
    // print(date);
    // print(widget.imageFile);
    // print(widget.report.info_name);
  }

  @override
  Widget build(BuildContext context) {
    // print(widget.report.info_name);
    return Scaffold(
      key: UniqueKey(),
      appBar: AppBar(
        // actions: [
        //   IconButton(
        //       onPressed: () {
        //         extractColors();
        //       },
        //       icon: Icon(Icons.refresh))
        // ],
        title: Text(
          'Report',
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  Text('Report name: ', style: headerText),
                  // Spacer(),
                  widget.report.name == null
                      ? Text(widget.report.name, style: normalText)
                      : Text('Demo', style: normalText)
                ]),
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  Text('Evaluate: ', style: headerText),
                  // Spacer(),
                  Text(widget.report.evaluate, style: normalText)
                ]),
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  Text('Date: ', style: headerText),
                  // Spacer(),
                  Text(DateFormat.yMd().add_jm().format(date),
                      style: normalText)
                ])
              ],
            ),
          ),
          Center(
            child: Container(
              // width: MediaQuery.of(context).size.width,
              // height: MediaQuery.of(context).size.height * 0.3,
              //Initialize chart
              child: SfCartesianChart(
                tooltipBehavior: TooltipBehavior(
                    enable: true, tooltipPosition: TooltipPosition.pointer),
                title: ChartTitle(
                  text: 'Standard Linear Regression',
                ),
                primaryXAxis: widget.report.info_evaluate == 'Potassium'
                    ? NumericAxis(minimum: 0, interval: 10, maximum: 30)
                    : NumericAxis(minimum: 0, interval: 0.5, maximum: 5),
                legend: Legend(
                    isVisible: true,
                    position: LegendPosition.bottom,
                    overflowMode: LegendItemOverflowMode.wrap),
                primaryYAxis:
                    NumericAxis(minimum: 180, maximum: 260, interval: 10),
                series: <CartesianSeries>[
                  ScatterSeries<ChartData, double>(
                      legendItemText: 'standard',
                      enableTooltip: true,
                      dataSource: calScatter(),
                      xValueMapper: (ChartData data, _) => data.x,
                      yValueMapper: (ChartData data, _) => data.y),
                  ScatterSeries<ChartData, double>(
                      legendItemText: 'sample',
                      enableTooltip: true,
                      dataSource: calScatter2(),
                      xValueMapper: (ChartData data, _) => data.x,
                      yValueMapper: (ChartData data, _) => data.y),
                  LineSeries<ChartData, double>(
                      legendItemText: 'y = ' +
                          equation.coefficient(1).toStringAsFixed(3) +
                          'x' +
                          '+' +
                          equation.coefficient(0).toStringAsFixed(3) +
                          ' (R^2 =' +
                          equation.R2().toStringAsFixed(3) +
                          ')',
                      enableTooltip: true,
                      dataSource: calLine(),
                      xValueMapper: (ChartData data, _) => data.x,
                      yValueMapper: (ChartData data, _) => data.y)
                ],
              ),
            ),
          ),
          Center(child: _showResult())
        ],
      ),
    );
  }

  Widget _colorCheck() {
    return Container(
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
    );
  }

  Widget _showResult() {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
        // maxWidth: 300,
        // maxHeight: MediaQuery.of(context).size.height,
        maxHeight: 252,
      ),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        // border: Border.all(
        //   color: Colors.black,
        // ),
        // image: imageFile != null
        //     ? DecorationImage(image: FileImage(imageFile!))
        //     : DecorationImage(
        //         image:
        //             AssetImage('assets/images/water.jpg'))
      ),
      child: Stack(
        children: [
          widget.imageFile != null
              ? Image.file(widget.imageFile!,
                  width: double.infinity,
                  height: double.infinity,
                  semanticLabel: "96-well plates",
                  fit: BoxFit.fill)
              : Center(
                  child: Text(
                    "No image selected",
                    style: normalText,
                    textAlign: TextAlign.center,
                  ),
                  widthFactor: double.infinity,
                  heightFactor: double.infinity,
                ),
          GridView.count(
            shrinkWrap: true,
            // physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 12,
            // childAspectRatio: 0.67,
            children: List.generate(
              96,
              (index) => _printResult(result, index),
            ),
          )
        ],
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
    // calScatter();
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
    Uint8List bytes = (await rootBundle.load('lib/assets/images/water.jpg'))
        .buffer
        .asUint8List();
    await audioFile.readAsBytes().then((value) {
      bytes = Uint8List.fromList(value);
      print('reading of bytes is completed');
    }).catchError((onError) {
      print('Exception Error while reading audio from path:' +
          onError.toString());
    });
    return bytes;
  }

  List<ChartData> calScatter() {
    var con = widget.report.con[widget.report.info_evaluate];

    setState(() {
      equation = calRsquare(widget.report.calStandard(), con! + con);
    });
    print(widget.report.calStandard());
    return getData(con! + con, widget.report.calStandard());
  }

  List<ChartData> calLine() {
    var con = widget.report.con[widget.report.info_evaluate];

    equation = calRsquare(widget.report.calStandard(), con! + con);
    var zero = -equation.coefficient(0) / equation.coefficient(1);
    // print(zero);
    List<double> sample = [for (double i = 180; i <= zero; i++) i];
    result = calConcentrate(equation, sample);

    // print(result.length);
    return getData(result, sample);
  }

  List<ChartData> calScatter2() {
    var con = widget.report.con[widget.report.info_evaluate];
    equation = calRsquare(widget.report.calStandard(), con! + con);

    result = calConcentrate(equation, widget.report.calSample());
    setState(() {});
    // print(result.length);
    return getData(result, widget.report.calSample());
  }
}

_printResult(List<double> result, int index) {}
