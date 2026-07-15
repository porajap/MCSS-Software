import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:image_pixels/image_pixels.dart';
import 'package:moblie_app/utils/text_config.dart';
import 'package:scidart/numdart.dart';

import '../../models/report_info.dart';
import '../../my_app.dart';
import '../../utils/color_config.dart';
import '../../utils/constants.dart';
import 'components/graph_generator.dart';
import 'components/pdf_print_generate.dart';
import 'components/rgb_generator.dart';
import 'components/report_header.dart';

class SummaryPage extends StatefulWidget {
  final File? imageFile;
  final ReportInfo report;

  const SummaryPage({super.key, this.imageFile, required this.report});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  final GlobalKey<State<StatefulWidget>> _printKey = GlobalKey();
  bool waiting = true;
  late final FileImage fileImage;
  Uint8List? imageBytes;
  Map<String, List<Color>>? colors;
  List<int> red = [];
  List<int> green = [];
  List<int> blue = [];
  List<double> con = [];
  late PolyFit equation;
  double result = 0;

  Offset localPosition = const Offset(0, 0);
  Color color = const Color(0x00000000);

  @override
  void initState() {
    FlutterNativeSplash.remove();
    delay();
    super.initState();
  }

  delay() async {
    await Future.delayed(const Duration(seconds: 10));
    await extractColors();
    await conStandard();
    fileImage = FileImage(widget.imageFile!);
    waiting = false;
    setState(() {});
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

  double calConcentrate(PolyFit equation, Color colorCode) {
    double sample = 0;
    try {
      if (widget.report.evaluate == PreferenceKey.phosphate) {
        sample = colorChannel8(colorCode, 'red').toDouble();
      }
      if (widget.report.evaluate == PreferenceKey.nitrate) {
        sample = colorChannel8(colorCode, 'green').toDouble();
      }
      if (widget.report.evaluate == PreferenceKey.potassium) {
        sample = colorChannel8(colorCode, 'blue').toDouble();
      }
      result = equation.predict(sample);
    } catch (e) {
      logger.e('Fail: cal concentrate');
      result = 0;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    var report = widget.report;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
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
      body: SizedBox.expand(
        child: RepaintBoundary(
          key: _printKey,
          child: Column(
            children: [
              buildReportHeader(report.name, report.evaluate),
              Expanded(
                  flex: 4,
                  child: waiting
                      ? const Center(
                          child: CircularProgressIndicator(
                          semanticsLabel: "Loading...",
                        ))
                      : Padding(
                          padding: const EdgeInsets.all(0),
                          child: Center(
                              child: Container(
                            color: Colors.white,
                            child: Listener(
                              onPointerDown: (PointerDownEvent details) {
                                setState(() {
                                  localPosition = details.localPosition;
                                  logger.d("position: $localPosition");
                                });
                              },
                              child: ImagePixels(
                                  imageProvider: fileImage,
                                  builder: (BuildContext context, ImgDetails img) {
                                    int w = img.width != null ? img.width! : 500;
                                    int h = img.height != null ? img.height! : 500;
                                    double scaleW = MediaQuery.of(context).size.width / w;

                                    color = img.pixelColorAt!((localPosition.dx / scaleW).toInt(), (localPosition.dy).toInt());

                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      setState(() {});
                                    });
                                    calConcentrate(equation, color);
                                    return SizedBox(
                                      height: h.toDouble(),
                                      width: MediaQuery.of(context).size.width,
                                      child: Image.file(
                                        fileImage.file,
                                        fit: BoxFit.fill,
                                      ),
                                    );
                                  }),
                            ),
                          )))),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Colors: ", style: StyleText.normalText),
                        const SizedBox(
                          width: 10,
                        ),
                        Container(width: 100, height: 55, color: color),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text("Coordinate (x,y) : (${localPosition.dx.toStringAsFixed(2)},${localPosition.dy.toStringAsFixed(2)})", style: StyleText.normalText),
                        Text("R: ${colorChannel8(color, 'red')}", style: StyleText.normalText),
                        Text("G: ${colorChannel8(color, 'green')}", style: StyleText.normalText),
                        Text("B: ${colorChannel8(color, 'blue')}", style: StyleText.normalText),
                        const SizedBox(
                          width: 10,
                        ),
                        Text("Concentration of nutrient in Samples: ${(result * 2).toStringAsFixed(2)} mg/kg", style: StyleText.headerText)
                      ]),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
