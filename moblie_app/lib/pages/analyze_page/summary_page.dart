import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

  Future<void> delay() async {
    // Run analysis immediately — no artificial wait.
    await extractColors();
    await conStandard();
    fileImage = FileImage(widget.imageFile!);
    if (!mounted) return;
    setState(() {
      waiting = false;
    });
  }

  Future<void> extractColors() async {
    imageBytes = await _readFileByte(widget.imageFile);
    colors = await compute(extractPixelsColors, imageBytes);
    for (final key in colors!.keys) {
      red.addAll(getColorValue(colors![key]!, 'red'));
      green.addAll(getColorValue(colors![key]!, 'green'));
      blue.addAll(getColorValue(colors![key]!, 'blue'));
    }
    widget.report.red = red;
    widget.report.green = green;
    widget.report.blue = blue;
  }

  Future<Uint8List> _readFileByte(File? filePath) async {
    try {
      final bytes = await filePath!.readAsBytes();
      logger.d('reading of bytes is completed');
      return bytes;
    } catch (onError) {
      logger.e('Exception Error while reading image from path: $onError');
      rethrow;
    }
  }

  List<double> calCon() {
    List<double> con = [];
    for (double i in widget.report.con[widget.report.evaluate]!) {
      for (int j = 0; j < 5; j++) {
        con.add(i);
      }
    }
    return con = con + con.toList();
  }

  Future<void> conStandard() async {
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

  void _onImageTap(Offset local, ImgDetails img, double scale) {
    final w = img.width ?? 1;
    final h = img.height ?? 1;
    final x = (local.dx / scale).floor().clamp(0, w - 1);
    final y = (local.dy / scale).floor().clamp(0, h - 1);
    final sampled = img.pixelColorAt!(x, y);

    setState(() {
      localPosition = local;
      color = sampled;
      calConcentrate(equation, sampled);
    });
    logger.d('position: $localPosition pixel: ($x, $y)');
  }

  Widget _buildImageArea() {
    if (waiting) {
      return const Center(
        child: CircularProgressIndicator(semanticsLabel: 'Loading...'),
      );
    }

    return ColoredBox(
      color: ColorCode.surfaceMuted,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ImagePixels(
            imageProvider: fileImage,
            builder: (BuildContext context, ImgDetails img) {
              final imgW = (img.width ?? 500).toDouble();
              final imgH = (img.height ?? 500).toDouble();
              final scale = math.min(
                constraints.maxWidth / imgW,
                constraints.maxHeight / imgH,
              );
              final displayW = imgW * scale;
              final displayH = imgH * scale;

              return Center(
                child: Listener(
                  onPointerDown: (PointerDownEvent details) {
                    _onImageTap(details.localPosition, img, scale);
                  },
                  child: SizedBox(
                    width: displayW,
                    height: displayH,
                    child: Image.file(
                      fileImage.file,
                      fit: BoxFit.fill,
                      filterQuality: FilterQuality.medium,
                      gaplessPlayback: true,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildResultPanel() {
    return Material(
      color: Colors.white,
      elevation: 0,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: ColorCode.surfaceMuted,
          border: Border(top: BorderSide(color: ColorCode.divider)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
        child: SafeArea(
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text('Color', style: StyleText.labelText),
                  const SizedBox(width: 12),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: ColorCode.borderSubtle),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'R ${colorChannel8(color, 'red')}  G ${colorChannel8(color, 'green')}  B ${colorChannel8(color, 'blue')}',
                    style: StyleText.normalText.copyWith(color: ColorCode.textMuted, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Coordinate  (${localPosition.dx.toStringAsFixed(2)}, ${localPosition.dy.toStringAsFixed(2)})',
                style: StyleText.normalText,
              ),
              const SizedBox(height: 12),
              Text(
                'Concentration of nutrient in Samples',
                style: StyleText.labelText,
              ),
              const SizedBox(height: 2),
              Text(
                '${(result * 2).toStringAsFixed(2)} mg/kg',
                style: StyleText.titleText.copyWith(color: ColorCode.appBarColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.report;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        actions: [
          IconButton(
            color: ColorCode.iconsAppBar,
            onPressed: () {
              printScreen(_printKey);
            },
            icon: const Icon(Icons.print_rounded),
          )
        ],
        title: Text('Analysis Report', style: StyleText.appBar),
      ),
      body: RepaintBoundary(
        key: _printKey,
        child: Column(
          children: [
            buildReportHeader(report.name, report.evaluate),
            Expanded(child: _buildImageArea()),
            _buildResultPanel(),
          ],
        ),
      ),
    );
  }
}
