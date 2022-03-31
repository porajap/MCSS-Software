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

import 'package:scidart/numdart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../utils/PlateConfig.dart';
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
  }

  selectImage(List<File> file) {
    List<File> selected = [];
    // print(plate.pnpSample);
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
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var report = widget.report;

    Future.delayed(Duration(seconds: 20));

    return Scaffold(
        key: UniqueKey(),
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () {
                // extractColors();
              },
              icon: Icon(Icons.save_alt),
            )
          ],
          title: Text(
            'Report',
          ),
        ),
        body: SingleChildScrollView(
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
                        enable: true, tooltipPosition: TooltipPosition.pointer),
                    title: ChartTitle(
                      text: 'Standard Linear Regression',
                    ),
                    primaryXAxis: widget.report.evaluate == 'Potassium'
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
              Container(
                child: _showResult(),
              ),
            ],
          ),
        ));
  }

  Widget _colorCheck() {
    return Container(
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
    var con = widget.report.con[widget.report.evaluate];
    con = con! + con;
    var row1 = List.generate(10, (index) => index + 38);
    var row2 = List.generate(10, (index) => index + 50);
    var row3 = List.generate(10, (index) => index + 62);
    var row4 = List.generate(10, (index) => index + 74);
    Map<String, List<int>> sample = {
      'D': row1,
      'E': row2,
      'F': row3,
      'G': row4
    };
    int i = 0;
    int j = 0;

    file = selectImage(file!);
    setState(() {});
    // print(file!.length);
    return file == null
        ? CircularProgressIndicator()
        : GridView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
            itemCount: file!.length,
            itemBuilder: (BuildContext ctx, index) {
              if (index < plate.pnpStandard.length) {
                var conStandard = con![i];
                i++;
                return Column(
                  children: [
                    Text('Stanard'),
                    Image.file(file![index]),
                    Text('$conStandard')
                  ],
                );
              } else {
                var conSample = result[j].toStringAsFixed(2);
                j++;
                // var label = sample.keys.firstWhere((element) => element==38);
                // var number = sample[label]?.indexOf(index);
                // print(label);
                // print(number);
                return Column(
                  children: [
                    Text('aA'),
                    Image.file(file![index]),
                    Text('$conSample')
                  ],
                );
              }
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
    Future.delayed(Duration(seconds: 20));
    var con = widget.report.con[widget.report.evaluate];
    setState(() {
      equation = calRsquare(widget.report.calStandard(), con! + con);
    });
    // print(widget.report.calStandard());
    return getData(con! + con, widget.report.calStandard());
  }

  List<ChartData> calLine() {
    Future.delayed(Duration(seconds: 20));
    var con = widget.report.con[widget.report.evaluate];

    equation = calRsquare(widget.report.calStandard(), con! + con);
    var zero = -equation.coefficient(0) / equation.coefficient(1);
    // print(zero);
    List<double> sample = [for (double i = 180; i <= zero; i++) i];
    result = calConcentrate(equation, sample);

    // print(result.length);
    return getData(result, sample);
  }

  List<ChartData> calScatter2() {
    Future.delayed(Duration(seconds: 20));
    var con = widget.report.con[widget.report.evaluate];
    equation = calRsquare(widget.report.calStandard(), con! + con);

    result = calConcentrate(equation, widget.report.calSample());
    setState(() {});
    // print(result.length);
    return getData(result, widget.report.calSample());
  }
}
