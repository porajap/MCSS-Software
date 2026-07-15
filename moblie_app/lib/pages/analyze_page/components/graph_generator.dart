import 'package:scidart/numdart.dart';

import '../../../my_app.dart';

class ChartData {
  ChartData(this.x, this.y);
  final double x;
  final double y;
}

/// Classical calibration: intensity (y) vs concentration (x).
/// Fit: intensity = b + m · concentration
PolyFit calRsquare(List<double> concentration, List<double> intensity) {
  return PolyFit(Array(concentration), Array(intensity), 1);
}

/// Inverse of intensity = b + m · concentration.
double predictConcentration(PolyFit equation, double intensity) {
  final double b = equation.coefficient(0);
  final double m = equation.coefficient(1);
  if (m.abs() < 1e-12) {
    return 0;
  }
  return (intensity - b) / m;
}

double predictIntensity(PolyFit equation, double concentration) {
  final double b = equation.coefficient(0);
  final double m = equation.coefficient(1);
  return b + m * concentration;
}

List<double> calConcentrate(PolyFit equation, List<double> sampleIntensity) {
  List<double> result = [];
  try {
    for (final intensity in sampleIntensity) {
      result.add(predictConcentration(equation, intensity));
    }
    logger.d('#concentrate: ${result.length}');
  } catch (e) {
    logger.e('Fail: cal concentrate');
  }
  return result;
}

List<ChartData> getData(List<double> concentration, List<double> intensity) {
  List<ChartData> data = [];
  try {
    for (int i = 0; i < concentration.length; i++) {
      data.add(ChartData(concentration[i], intensity[i]));
    }
  } catch (e) {
    logger.e('Fail: generate ChartData');
  }
  return data;
}
