import 'dart:core';

import '../my_app.dart';
import '../utils/constants.dart';
import '../utils/plate_config.dart';

class ReportInfo {
  String name;
  String evaluate;

  List<int> red;
  List<int> green;
  List<int> blue;
  ReportInfo(this.name, this.evaluate, this.red, this.green, this.blue);

  List<double> standard = [];
  List<double> sample = [];
  Map<String, List<double>> con = {
    PreferenceKey.phosphate: [0, 0.5, 1, 2, 3],
    // PreferenceKey.nitrate: [0, 0.1, 0.5, 1, 2.5], // for testing only
    PreferenceKey.nitrate: [0, 0.5, 1, 2.5, 5],
    PreferenceKey.potassium: [0, 5, 10, 20, 30]
  };

  Plate plate = Plate();

  /// Intensity channel used as Y for regression / chart.
  /// Phosphate → red, Nitrate → green, Potassium → gray (R+G+B)/3.
  double intensityAt(int index) {
    final r = red[index].toDouble();
    final g = green[index].toDouble();
    final b = blue[index].toDouble();
    if (evaluate == PreferenceKey.phosphate) {
      return r;
    }
    if (evaluate == PreferenceKey.nitrate) {
      return g;
    }
    if (evaluate == PreferenceKey.potassium) {
      return (r + g + b) / 3.0;
    }
    return 0;
  }

  List<double> calStandard() {
    standard = [];
    try {
      for (int i = 0; i < 50; i++) {
        standard.add(intensityAt(i));
      }
    } catch (e) {
      logger.e('Fail: calculate standard value');
    }
    return standard;
  }

  List<double> calSample() {
    sample = [];
    try {
      for (int i = 50; i < red.length; i++) {
        sample.add(intensityAt(i));
      }
    } catch (e) {
      logger.e('Fail: calculate sample value');
    }
    return sample;
  }
}
