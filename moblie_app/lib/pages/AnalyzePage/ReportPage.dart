import 'dart:io';
import 'dart:ui';
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:moblie_app/models/ReportInfo.dart';
import 'package:moblie_app/pages/AnalyzePage/cpmponents/Capturegenerator.dart';
import 'package:moblie_app/pages/AnalyzePage/cpmponents/PDFprintgenerate.dart';

import 'package:scidart/numdart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../myApp.dart';
import '../../utils/ColorConfig.dart';
import '../../utils/Constants.dart';
import '../../utils/PlateConfig.dart';
import '../../utils/TextConfig.dart';
import 'cpmponents/Graphgenerator.dart';
import 'cpmponents/RGBgenerator.dart';
import '../../models/ReportInfo.dart';
import 'cpmponents/reportHeader.dart';

class ReportPage extends StatefulWidget {
  final File? imageFile;
  ReportInfo report;

  ReportPage({this.imageFile, required this.report});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final GlobalKey<State<StatefulWidget>> _printKey = GlobalKey();
  bool waiting = true;
  Map<String, List<Color>>? colors;
  List<int> red = [];
  List<int> green = [];
  List<int> blue = [];
  late PolyFit equation;
  List<double> result = [];
  Uint8List? imageBytes;
  List<double> con = [];

  List<File> file = [];

  Plate plate = Plate();

  @override
  void initState() {
    delay();
    logger.d({
      'report name: ${widget.report.name}',
      'report evaluate: ${widget.report.evaluate}'
    });
    super.initState();
  }

  delay() async {
    await Future.delayed(const Duration(seconds: 10));
    await extractColors();
    await conStandard();
    await cropImage();
    waiting = false;
    setState(() {});
  }

  calCon() {
    List<double> con = [];
    for (double i in widget.report.con[widget.report.evaluate]!) {
      for (int j = 0; j < 5; j++) {
        con.add(i);
      }
    }
    return con = con + con.toList();
  }

  conStandard() async {
    // print(con);
    con = widget.report.con[widget.report.evaluate]!;

    List<double> standard = widget.report.calStandard();
    equation = calRsquare(standard, calCon());
    logger.d(equation);
  }

  selectImage(List<File> file) {
    List<File> selected = [];
    for (int i = 1; i < file.length + 1; i++) {
      if (Plate.pnpStandard.contains(i) || Plate.pnpSample!.contains(i)) {
        selected.add(file[i - 1]);
        // print(i);
      }
    }
    print('#selectedCrop: ${selected.length}');
    return selected;
  }

  cropImage() async {
    file = await cropSquare(widget.imageFile!, false);
    var length = file.length;
    print('#cropPerImage: $length');
    file = selectImage(file);
  }

  Future<void> extractColors() async {
    imageBytes = await _readFileByte(widget.imageFile);
    // print(imageBytes);
    colors = await compute(extractPixelsColors, imageBytes);
    colors!.forEach((key, value) {
      red.addAll(getColorValue(colors![key]!, 'red'));
      green.addAll(getColorValue(colors![key]!, 'green'));
      blue.addAll(getColorValue(colors![key]!, 'blue'));
    });
    // print(red.length);
    widget.report.red = red;
    widget.report.green = green;
    widget.report.blue = blue;
  }

  Future<Uint8List> _readFileByte(File? filePath) async {
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

  List<ChartData> calScatter(String type) {
    result = calConcentrate(equation, widget.report.calSample());
    print('#calScatter complete');
    return getData(
        type == PreferenceKey.standard ? calCon() : result,
        type == PreferenceKey.standard
            ? widget.report.calStandard()
            : widget.report.calSample());
  }

  List<ChartData> calLine() {
    var minimum = widget.report.calSample().reduce(min);
    var zero = -equation.coefficient(0) / equation.coefficient(1);
    // print(zero);
    List<double> sample = [for (double i = minimum; i <= zero + 20; i++) i];
    result = calConcentrate(equation, sample);

    print('#calLine complete');
    return getData(result, sample);
  }

  Widget _showChart() {
    var minimum = widget.report.calSample().reduce(min);
    var maximum = widget.report.calSample().reduce(max);

    return Center(
      child: waiting
          ? CircularProgressIndicator()
          : Container(
              height: 400,
              //Initialize chart
              child: SfCartesianChart(
                tooltipBehavior: TooltipBehavior(
                    enable: true,
                    tooltipPosition: TooltipPosition.pointer,
                    borderColor: Colors.red,
                    borderWidth: 5,
                    color: Colors.lightBlue),
                title: ChartTitle(
                  text: 'Standard Linear Regression',
                  textStyle: TextStyle(fontSize: 12),
                ),
                primaryXAxis: widget.report.evaluate == PreferenceKey.potassium
                    ? NumericAxis(minimum: 0, interval: 10, maximum: 30)
                    : NumericAxis(minimum: 0, interval: 0.5, maximum: 5),
                legend: Legend(
                    isVisible: true,
                    position: LegendPosition.bottom,
                    overflowMode: LegendItemOverflowMode.wrap),
                primaryYAxis: NumericAxis(
                    minimum: minimum, maximum: maximum, interval: 5),
                // widget.report.evaluate == PreferenceKey.potassium
                //     ? NumericAxis(minimum: 200, maximum: 255, interval: 5)
                //     : NumericAxis(minimum: 160, maximum: 255, interval: 5),
                series: <CartesianSeries>[
                  ScatterSeries<ChartData, double>(
                      legendItemText: PreferenceKey.standard,
                      enableTooltip: true,
                      dataSource: calScatter(PreferenceKey.standard),
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
                      yValueMapper: (ChartData data, _) => data.y),
                  ScatterSeries<ChartData, double>(
                      legendItemText: PreferenceKey.sample,
                      enableTooltip: true,
                      dataSource: calScatter(PreferenceKey.sample),
                      xValueMapper: (ChartData data, _) => data.x,
                      yValueMapper: (ChartData data, _) => data.y),
                ],
              ),
            ),
    );
  }

  _showImage() {
    return result.isEmpty
        ? CircularProgressIndicator()
        : Stack(children: [
            Container(
              height: 300,
              child: Image.file(widget.imageFile!,
                  semanticLabel: "96-well plates", fit: BoxFit.fill),
            ),
            for (int i = 1; i < 6; i++)
              Positioned(
                  child: Tooltip(
                    triggerMode: TooltipTriggerMode.tap,
                    preferBelow: false,
                    padding: EdgeInsets.all(8.0),
                    message:
                        con.isEmpty ? "xx.xx" : con[i - 1].toStringAsFixed(2),
                    child: Icon(Icons.check_circle_outline_outlined,
                        color: Colors.green),
                  ),
                  top: 18.75 * 3,
                  left: (MediaQuery.of(context).size.width * i / 12.0) + 3),
            for (int i = 1; i < 6; i++)
              Positioned(
                  child: Tooltip(
                    triggerMode: TooltipTriggerMode.tap,
                    preferBelow: false,
                    padding: EdgeInsets.all(8.0),
                    message:
                        con.isEmpty ? "xx.xx" : con[i - 1].toStringAsFixed(2),
                    child: Icon(Icons.check_circle_outline_outlined,
                        color: Colors.green),
                  ),
                  top: 18.75 * 5,
                  left: (MediaQuery.of(context).size.width * i / 12.0) + 3),
            for (int i = 1; i < 11; i++)
              Positioned(
                  child: Tooltip(
                    triggerMode: TooltipTriggerMode.tap,
                    preferBelow: false,
                    padding: EdgeInsets.all(8.0),
                    message: result.isEmpty
                        ? "xx.xx"
                        : (result[i - 1] * 2).toStringAsFixed(2),
                    child: Icon(Icons.check_circle_outline_outlined,
                        color: Colors.red),
                  ),
                  top: 18.75 * 7,
                  left: (MediaQuery.of(context).size.width * i / 12.0) + 3),
            for (int i = 1; i < 11; i++)
              Positioned(
                  child: Tooltip(
                    triggerMode: TooltipTriggerMode.tap,
                    preferBelow: false,
                    padding: EdgeInsets.all(8.0),
                    message: result.isEmpty
                        ? "xx.xx"
                        : (result[i + 10 - 1] * 2).toStringAsFixed(2),
                    child: Icon(Icons.check_circle_outline_outlined,
                        color: Colors.red),
                  ),
                  top: 18.75 * 9,
                  left: (MediaQuery.of(context).size.width * i / 12.0) + 3),
            for (int i = 1; i < 11; i++)
              Positioned(
                  child: Tooltip(
                    triggerMode: TooltipTriggerMode.tap,
                    preferBelow: false,
                    padding: EdgeInsets.all(8.0),
                    message: result.isEmpty
                        ? "xx.xx"
                        : (result[i + 20 - 1] * 2).toStringAsFixed(2),
                    child: Icon(Icons.check_circle_outline_outlined,
                        color: Colors.red),
                  ),
                  top: 18.75 * 11,
                  left: (MediaQuery.of(context).size.width * i / 12.0) + 3),
            for (int i = 1; i < 11; i++)
              Positioned(
                  child: Tooltip(
                    triggerMode: TooltipTriggerMode.tap,
                    preferBelow: false,
                    padding: EdgeInsets.all(8.0),
                    message: result.isEmpty
                        ? "xx.xx"
                        : (result[i + 30 - 1] * 2).toStringAsFixed(2),
                    child: Icon(Icons.check_circle_outline_outlined,
                        color: Colors.red),
                  ),
                  top: 18.75 * 13,
                  left: (MediaQuery.of(context).size.width * i / 12.0) + 3)
          ]);
  }

  Widget _showResult() {
    con = con + con;

    int i = 0;
    int j = 0;
    int n = -1;

    return file.length == 0
        ? CircularProgressIndicator()
        : GridView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
            ),
            itemCount: file.length,
            itemBuilder: (BuildContext ctx, index) {
              String title;
              String concentrate;
              String rgbCode;

              if (index < Plate.pnpStandard.length) {
                title = 'Std';
                concentrate = con[i].toStringAsFixed(2);
                rgbCode = widget.report.standard[i * 5].toStringAsFixed(0);
                i++;
              } else {
                var number = index % 10;
                if (number == 0) n++;
                title = plate.label[n] + plate.no[number].toString();
                concentrate = (result[j] * 2).toStringAsFixed(2);
                rgbCode = widget.report.sample[j].toStringAsFixed(0);
                j++;
              }
              return Container(
                child: Column(
                  children: [
                    Text(title + '=' + '$concentrate',
                        style: StyleText.resultText),
                    Image.file(
                      file[index],
                      fit: BoxFit.contain,
                      height: 40,
                      width: 50,
                    ),
                    Text(
                      rgbCode,
                      style: StyleText.resultText,
                    )
                  ],
                ),
              );
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    var report = widget.report;

    return Scaffold(
        key: UniqueKey(),
        appBar: AppBar(
          actions: [
            IconButton(
              color: ColorCode.iconsAppBar,
              onPressed: () {
                printScreen(_printKey);
              },
              icon: Icon(
                Icons.print_rounded,
              ),
            )
          ],
          title: Text('รายงานผลวิเคราะห์', style: StyleText.appBar),
        ),
        body: SingleChildScrollView(
          child: RepaintBoundary(
            key: _printKey,
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  reportHeader(report.name, report.evaluate),
                  _showChart(),
                  // SizedBox(height: 10),
                  // _showImage(),
                  SizedBox(height: 10),
                  Container(child: _showResult()),
                ],
              ),
            ),
          ),
        ));
  }
}
