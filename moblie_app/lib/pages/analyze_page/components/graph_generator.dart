import 'package:scidart/numdart.dart';

import '../../../my_app.dart';

class ChartData {
  ChartData(this.x, this.y);
  final double x;
  final double y;
}

PolyFit calRsquare(List<double> x, List<double> y) {
  var equation = PolyFit(Array(x), Array(y), 1);
  return equation;
}

List<double> calConcentrate(PolyFit equation, List<double> sample) {
  List<double> result = [];
  try {
    for (final code in sample) {
      result.add(equation.predict(code));
    }

    var length = result.length;
    logger.d('#concentrate: $length');
  } catch (e) {
    logger.e('Fail: cal concentrate');
  }
  return result;
}

List<ChartData> getData(List<double> result, List<double> rgbCode) {
  List<ChartData> data = [];
  try {
    for (int i = 0; i < result.length; i++) {
      data.add(ChartData(result[i], rgbCode[i]));
    }
  } catch (e) {
    logger.e('Fail: generate ChartData');
  }
  return data;
}
