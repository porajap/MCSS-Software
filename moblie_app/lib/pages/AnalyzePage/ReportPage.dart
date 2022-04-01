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

import '../../main.dart';
import '../../utils/Constants.dart';
import '../../utils/PlateConfig.dart';
import '../../utils/TextConfig.dart';
import 'cpmponents/Graphgenerator.dart';
import '../InputPage/components/RGBgenerator.dart';
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
  List<Color> colors = [];
  List<int> red = [];
  List<int> green = [];
  List<int> blue = [];
  late PolyFit equation;
  List<double> result = [];
  Uint8List? imageBytes;

  List<File>? file;

  Plate plate = Plate();

  @override
  void initState() {
    super.initState();
    extractColors();
    cropImage();
    // print(widget.report.evaluate);
  }

  conStandard() {
    var con = widget.report.con[widget.report.evaluate];
    return con! + con;
  }

  getEqualtion() {
    Future.delayed(Duration(seconds: 10));
    return calRsquare(widget.report.calStandard(), conStandard());
  }

  selectImage(List<File> file) {
    List<File> selected = [];
    for (int i = 1; i < file.length + 1; i++) {
      if (plate.pnpStandard.contains(i) || plate.pnpSample.contains(i)) {
        selected.add(file[i - 1]);
        // print(i);
      }
    }
    print(selected.length);
    return selected;
  }

  cropImage() async {
    file = await cropSquare(widget.imageFile!, true);
    var length = file!.length;
    print('#cropPerImage: $length');
    file = selectImage(file!);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var report = widget.report;

    Future.delayed(Duration(seconds: 30));

    return Scaffold(
        key: UniqueKey(),
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () {
                // extractColors();
                printScreen(_printKey);
              },
              icon: Icon(Icons.print_rounded),
            )
          ],
          title: Text(
            'Report',
          ),
        ),
        body: SingleChildScrollView(
          child: RepaintBoundary(
            key: _printKey,
            child: Column(
              children: [
                reportHeader(report.name, report.evaluate),
                Center(
                  child: Container(
                    // width: MediaQuery.of(context).size.width,
                    // height: MediaQuery.of(context).size.height * 0.3,
                    //Initialize chart
                    child: SfCartesianChart(
                      tooltipBehavior: TooltipBehavior(
                          enable: true,
                          tooltipPosition: TooltipPosition.pointer),
                      title: ChartTitle(
                        text: 'Standard Linear Regression',
                        textStyle: TextStyle(fontSize: 12),
                      ),
                      primaryXAxis: widget.report.evaluate ==
                              PreferenceKey.potassium
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
                            legendItemText: PreferenceKey.standard,
                            enableTooltip: true,
                            dataSource: calScatter(PreferenceKey.standard),
                            xValueMapper: (ChartData data, _) => data.x,
                            yValueMapper: (ChartData data, _) => data.y),
                        ScatterSeries<ChartData, double>(
                            legendItemText: PreferenceKey.sample,
                            enableTooltip: true,
                            dataSource: calScatter(PreferenceKey.sample),
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
                Container(child: _showResult()),
              ],
            ),
          ),
        ));
  }

  Widget _showResult() {
    var con = conStandard();

    int i = 0;
    int j = 0;
    var n = -1;

    return file == null
        ? CircularProgressIndicator()
        : GridView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
            itemCount: file!.length,
            itemBuilder: (BuildContext ctx, index) {
              String title;
              String concentrate;

              if (index < plate.pnpStandard.length) {
                title = PreferenceKey.standard;
                concentrate = con![i].toStringAsFixed(2);
                i++;
              } else {
                var number = index % 10;
                if (number == 0) n++;
                title = plate.label[n] + plate.no[number].toString();
                concentrate = result[j].toStringAsFixed(2);
                j++;
              }
              return Column(
                children: [
                  Text(title, style: StyleText.resultText),
                  Image.file(file![index]),
                  Text(
                    '$concentrate',
                    style: StyleText.resultText,
                  )
                ],
              );
            },
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
    Future.delayed(Duration(seconds: 10));

    equation = getEqualtion();
    result = calConcentrate(equation, widget.report.calSample());
    setState(() {});

    print('#calScatter of Standard complete');
    return getData(
        type == PreferenceKey.standard ? conStandard() : result,
        type == PreferenceKey.standard
            ? widget.report.calStandard()
            : widget.report.calSample());
  }

  List<ChartData> calLine() {
    Future.delayed(Duration(seconds: 10));

    equation = getEqualtion();
    var zero = -equation.coefficient(0) / equation.coefficient(1);
    // print(zero);
    List<double> sample = [for (double i = 180; i <= zero + 20; i++) i];
    result = calConcentrate(equation, sample);
    setState(() {});
    print('#calLine of Standard complete');
    return getData(result, sample);
  }
}
