import 'dart:io';
import 'dart:async';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moblie_app/load_data_csv.dart';

import 'package:moblie_app/models/report_info.dart';
import 'package:moblie_app/pages/analyze_page/components/capture_generator.dart';
import 'package:moblie_app/pages/analyze_page/components/pdf_print_generate.dart';
import 'package:path_provider/path_provider.dart';

import 'package:scidart/numdart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../my_app.dart';
import '../../utils/color_config.dart';
import '../../utils/constants.dart';
import '../../utils/plate_config.dart';
import '../../utils/text_config.dart';
import 'components/graph_generator.dart';
import 'components/rgb_generator.dart';
import 'components/report_header.dart';

class ReportPage extends StatefulWidget {
  final File? imageFile;
  final ReportInfo report;

  const ReportPage({super.key, this.imageFile, required this.report});

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

  List<File> croppedFiles = [];

  Plate plate = Plate();

  late double minimum;
  late double maximum;

  @override
  void initState() {
    delay();
    logger.d({'report name: ${widget.report.name}', 'report evaluate: ${widget.report.evaluate}'});
    super.initState();
  }

  delay() async {
    await Future.delayed(const Duration(seconds: 10));
    await extractColors();
    await conStandard();
    await cropImage();
    minimum = widget.report.calSample().reduce(min);
    maximum = widget.report.calSample().reduce(max);
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
    con = widget.report.con[widget.report.evaluate]!;

    List<double> standard = widget.report.calStandard();
    equation = calRsquare(standard, calCon());
    logger.d(equation);
  }

  selectImage(List<File> images) {
    List<File> selected = [];
    for (int i = 1; i < images.length + 1; i++) {
      if (Plate.pnpStandard.contains(i) || Plate.pnpSample!.contains(i)) {
        selected.add(images[i - 1]);
      }
    }
    logger.d('#selectedCrop: ${selected.length}');
    return selected;
  }

  cropImage() async {
    croppedFiles = await cropSquare(widget.imageFile!, false);
    var length = croppedFiles.length;
    logger.d('#cropPerImage: $length');
    croppedFiles = selectImage(croppedFiles);
  }

  Future<void> extractColors() async {
    imageBytes = await _readFileByte(widget.imageFile);
    colors = await compute(extractPixelsColors, imageBytes);
    colors!.forEach((key, value) {
      red.addAll(getColorValue(colors![key]!, 'red'));
      green.addAll(getColorValue(colors![key]!, 'green'));
      blue.addAll(getColorValue(colors![key]!, 'blue'));
    });
    widget.report.red = red;
    widget.report.green = green;
    widget.report.blue = blue;
  }

  Future<Uint8List> _readFileByte(File? filePath) async {
    File audioFile = filePath!;
    Uint8List bytes = (await rootBundle.load('lib/assets/images/water.jpg')).buffer.asUint8List();
    await audioFile.readAsBytes().then((value) {
      bytes = Uint8List.fromList(value);
      logger.d('reading of bytes is completed');
    }).catchError((onError) {
      logger.e('Exception Error while reading audio from path: $onError');
    });
    return bytes;
  }

  List<ChartData> calScatter(String type) {
    result = calConcentrate(equation, widget.report.calSample());
    logger.d('#calScatter complete');
    return getData(type == PreferenceKey.standard ? calCon() : result, type == PreferenceKey.standard ? widget.report.calStandard() : widget.report.calSample());
  }

  List<ChartData> calLine() {
    List<double> sample = [for (double i = minimum; i <= maximum; i++) i];
    result = calConcentrate(equation, sample);

    logger.d('#calLine complete');
    return getData(result, sample);
  }

  Widget _showChart() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Center(
        child: waiting
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: CircularProgressIndicator(),
              )
            : SizedBox(
                height: 380,
                child: SfCartesianChart(
                  plotAreaBorderWidth: 0,
                  tooltipBehavior: TooltipBehavior(
                    enable: true,
                    tooltipPosition: TooltipPosition.pointer,
                    borderColor: ColorCode.appBarColor,
                    borderWidth: 1,
                    color: ColorCode.appBarColor,
                  ),
                  title: ChartTitle(
                    text: 'Standard Linear Regression',
                    textStyle: StyleText.labelText,
                  ),
                  primaryXAxis: widget.report.evaluate == PreferenceKey.potassium
                      ? NumericAxis(minimum: 0, interval: 10, maximum: 30, majorGridLines: const MajorGridLines(width: 0.4))
                      : NumericAxis(minimum: 0, interval: 0.5, maximum: 5, majorGridLines: const MajorGridLines(width: 0.4)),
                  legend: Legend(
                    isVisible: true,
                    position: LegendPosition.bottom,
                    overflowMode: LegendItemOverflowMode.wrap,
                    textStyle: StyleText.resultText,
                  ),
                  primaryYAxis: NumericAxis(
                    minimum: minimum,
                    maximum: maximum,
                    interval: 5,
                    majorGridLines: const MajorGridLines(width: 0.4),
                  ),
                  series: <CartesianSeries>[
                    ScatterSeries<ChartData, double>(
                      legendItemText: PreferenceKey.standard,
                      enableTooltip: true,
                      color: Colors.green,
                      markerSettings: const MarkerSettings(isVisible: true, height: 7, width: 7),
                      dataSource: calScatter(PreferenceKey.standard),
                      xValueMapper: (ChartData data, _) => data.x,
                      yValueMapper: (ChartData data, _) => data.y,
                    ),
                    LineSeries<ChartData, double>(
                      legendItemText:
                          'y = ${equation.coefficient(1).toStringAsFixed(3)}x+${equation.coefficient(0).toStringAsFixed(3)} (R^2 =${equation.R2().toStringAsFixed(3)})',
                      enableTooltip: true,
                      color: ColorCode.appBarColor,
                      width: 1.5,
                      dataSource: calLine(),
                      xValueMapper: (ChartData data, _) => data.x,
                      yValueMapper: (ChartData data, _) => data.y,
                    ),
                    ScatterSeries<ChartData, double>(
                      legendItemText: PreferenceKey.sample,
                      enableTooltip: true,
                      color: Colors.red,
                      markerSettings: const MarkerSettings(isVisible: true, height: 7, width: 7),
                      dataSource: calScatter(PreferenceKey.sample),
                      xValueMapper: (ChartData data, _) => data.x,
                      yValueMapper: (ChartData data, _) => data.y,
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // Kept for optional overlay UI (currently unused in build).
  // ignore: unused_element
  Widget _showImage() {
    return result.isEmpty
        ? const CircularProgressIndicator()
        : Stack(children: [
            SizedBox(
              height: 300,
              child: Image.file(widget.imageFile!, semanticLabel: "96-well plates", fit: BoxFit.fill),
            ),
            for (int i = 1; i < 6; i++)
              Positioned(
                  top: 18.75 * 3,
                  left: (MediaQuery.of(context).size.width * i / 12.0) + 3,
                  child: Tooltip(
                    triggerMode: TooltipTriggerMode.tap,
                    preferBelow: false,
                    padding: const EdgeInsets.all(8.0),
                    message: con.isEmpty ? "xx.xx" : con[i - 1].toStringAsFixed(2),
                    child: const Icon(Icons.check_circle_outline_outlined, color: Colors.green),
                  )),
            for (int i = 1; i < 6; i++)
              Positioned(
                  top: 18.75 * 5,
                  left: (MediaQuery.of(context).size.width * i / 12.0) + 3,
                  child: Tooltip(
                    triggerMode: TooltipTriggerMode.tap,
                    preferBelow: false,
                    padding: const EdgeInsets.all(8.0),
                    message: con.isEmpty ? "xx.xx" : con[i - 1].toStringAsFixed(2),
                    child: const Icon(Icons.check_circle_outline_outlined, color: Colors.green),
                  )),
            for (int i = 1; i < 11; i++)
              Positioned(
                  top: 18.75 * 7,
                  left: (MediaQuery.of(context).size.width * i / 12.0) + 3,
                  child: Tooltip(
                    triggerMode: TooltipTriggerMode.tap,
                    preferBelow: false,
                    padding: const EdgeInsets.all(8.0),
                    message: result.isEmpty ? "xx.xx" : (result[i - 1] * 2).toStringAsFixed(2),
                    child: const Icon(Icons.check_circle_outline_outlined, color: Colors.red),
                  )),
            for (int i = 1; i < 11; i++)
              Positioned(
                  top: 18.75 * 9,
                  left: (MediaQuery.of(context).size.width * i / 12.0) + 3,
                  child: Tooltip(
                    triggerMode: TooltipTriggerMode.tap,
                    preferBelow: false,
                    padding: const EdgeInsets.all(8.0),
                    message: result.isEmpty ? "xx.xx" : (result[i + 10 - 1] * 2).toStringAsFixed(2),
                    child: const Icon(Icons.check_circle_outline_outlined, color: Colors.red),
                  )),
            for (int i = 1; i < 11; i++)
              Positioned(
                  top: 18.75 * 11,
                  left: (MediaQuery.of(context).size.width * i / 12.0) + 3,
                  child: Tooltip(
                    triggerMode: TooltipTriggerMode.tap,
                    preferBelow: false,
                    padding: const EdgeInsets.all(8.0),
                    message: result.isEmpty ? "xx.xx" : (result[i + 20 - 1] * 2).toStringAsFixed(2),
                    child: const Icon(Icons.check_circle_outline_outlined, color: Colors.red),
                  )),
            for (int i = 1; i < 11; i++)
              Positioned(
                  top: 18.75 * 13,
                  left: (MediaQuery.of(context).size.width * i / 12.0) + 3,
                  child: Tooltip(
                    triggerMode: TooltipTriggerMode.tap,
                    preferBelow: false,
                    padding: const EdgeInsets.all(8.0),
                    message: result.isEmpty ? "xx.xx" : (result[i + 30 - 1] * 2).toStringAsFixed(2),
                    child: const Icon(Icons.check_circle_outline_outlined, color: Colors.red),
                  ))
          ]);
  }

  List<List<String>> smp = [];

  Widget _showResult() {
    con = con + con;

    int i = 0;
    int j = 0;
    int n = -1;

    return croppedFiles.isEmpty
        ? const SizedBox(height: 10)
        : Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 8,
                crossAxisSpacing: 6,
                childAspectRatio: 0.78,
              ),
              itemCount: croppedFiles.length,
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
                  smp.add([title, "SMP", "${widget.report.red[50 + j]}", "${widget.report.green[50 + j]}", "${widget.report.blue[50 + j]}", "-", concentrate]);
                  j++;
                }
                return Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: ColorCode.surfaceMuted,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: ColorCode.divider),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('$title=$concentrate', style: StyleText.resultText, textAlign: TextAlign.center),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.file(
                          croppedFiles[index],
                          fit: BoxFit.contain,
                          height: 36,
                          width: 44,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(rgbCode, style: StyleText.resultText.copyWith(color: ColorCode.textMuted)),
                    ],
                  ),
                );
              },
            ),
          );
  }

  Widget _showExportButton() {
    return waiting
        ? const SizedBox()
        : Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.green),
                    ),
                  ),
                  onPressed: generateCsv,
                  icon: const Icon(Icons.upload_file_outlined, size: 18),
                  label: Text('CSV', style: StyleText.normalText.copyWith(color: Colors.green, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          );
  }

  Future generateCsv() async {
    List<List<String>> std = [];
    int j = 0;
    while (j < widget.report.standard.length) {
      List label = ['B', 'C'];
      int x = j ~/ 5;
      for (int i = 0; i < 5; i++) {
        std.add(["${x < 5 ? label[0] : label[1]}${plate.no[x % 5]}", "STD", "${widget.report.red[j]}", "${widget.report.green[j]}", "${widget.report.blue[j]}", "-", con[x].toStringAsFixed(2)]);
        j++;
      }
    }

    List<List<String>> data = [
          ["well_index", "STD/SMP", "color_R", "color_G", "color_B", "HSV", "saturation"]
        ] +
        std.toList() +
        smp.toList();
    String csvData = ListToCsvConverter().convert(data);
    final String directory = (await getExternalStorageDirectory())!.path;
    final path = "$directory/m-css-${widget.report.name}-${DateTime.now()}.csv";
    final File csvFile = File(path);
    await csvFile.writeAsString(csvData);
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          return LoadCsvDataScreen(title: widget.report.name, path: path);
        },
      ),
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
              icon: const Icon(
                Icons.print_rounded,
              ),
            )
          ],
          title: Text('Analysis Report', style: StyleText.appBar),
        ),
        body: SingleChildScrollView(
          child: RepaintBoundary(
            key: _printKey,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  buildReportHeader(report.name, report.evaluate),
                  _showChart(),
                  _showExportButton(),
                  _showResult(),
                ],
              ),
            ),
          ),
        ));
  }
}
