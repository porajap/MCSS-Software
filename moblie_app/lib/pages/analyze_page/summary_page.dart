import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:image_pixels/image_pixels.dart';
import 'package:moblie_app/utils/text_config.dart';
import 'package:scidart/numdart.dart';

import '../../models/report_info.dart';
import '../../my_app.dart';
import '../../utils/color_config.dart';
import '../../utils/constants.dart';
import 'components/graph_generator.dart';
import 'components/pdf_print_generate.dart';
import 'components/plate_rgb_extractor.dart';
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
    super.initState();
    fileImage = FileImage(widget.imageFile!);
    // Start after first frame so the Loading spinner can paint/animate.
    WidgetsBinding.instance.addPostFrameCallback((_) => _runAnalysis());
  }

  Future<void> _yieldUi() async {
    await SchedulerBinding.instance.endOfFrame;
    await Future<void>.delayed(Duration.zero);
  }

  Future<void> _runAnalysis() async {
    try {
      await _yieldUi();

      final Uint8List imageBytes = await widget.imageFile!.readAsBytes();
      await _yieldUi();

      // Heavy decode/sample off the UI isolate; returns plain ints (cheap to transfer).
      final PlateRgbData rgb = await compute(extractPixelsRgb, imageBytes);
      red = rgb.red;
      green = rgb.green;
      blue = rgb.blue;
      widget.report.red = red;
      widget.report.green = green;
      widget.report.blue = blue;

      await _yieldUi();
      _fitStandard();

      // Warm image decode before hiding spinner to avoid a second stall.
      if (mounted) {
        await precacheImage(fileImage, context);
      }
    } catch (e, st) {
      logger.e('Fail: SummaryPage analysis', error: e, stackTrace: st);
    }

    if (!mounted) return;
    setState(() {
      waiting = false;
    });
  }

  List<double> calCon() {
    List<double> values = [];
    for (double i in widget.report.con[widget.report.evaluate]!) {
      for (int j = 0; j < 5; j++) {
        values.add(i);
      }
    }
    return values + values.toList();
  }

  void _fitStandard() {
    con = widget.report.con[widget.report.evaluate]!;
    final List<double> standardIntensity = widget.report.calStandard();
    equation = calRsquare(calCon(), standardIntensity);
    logger.d(equation);
  }

  double calConcentrate(PolyFit equation, Color colorCode) {
    try {
      final r = colorChannel8(colorCode, 'red').toDouble();
      final g = colorChannel8(colorCode, 'green').toDouble();
      final b = colorChannel8(colorCode, 'blue').toDouble();
      double intensity = 0;
      if (widget.report.evaluate == PreferenceKey.phosphate) {
        intensity = r;
      }
      if (widget.report.evaluate == PreferenceKey.nitrate) {
        intensity = g;
      }
      if (widget.report.evaluate == PreferenceKey.potassium) {
        intensity = (r + g + b) / 3.0;
      }
      result = predictConcentration(equation, intensity);
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
