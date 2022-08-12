import 'dart:core';

import 'package:flutter/foundation.dart';

import '../myApp.dart';
import '../utils/Constants.dart';
import '../utils/PlateConfig.dart';

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
  

  List<double> calStandard() {
    // print(Plate.pnpStandard);
    this.standard = [];
    // print(this.evaluate);
    try {
      if (this.evaluate == PreferenceKey.phosphate) {
        for (int i = 1; i < 51; i++) {
          standard.add(red[i - 1].toDouble());
        }
      } else if (this.evaluate == PreferenceKey.nitrate) {
        for (int i = 1; i < 51; i++) {
          standard.add(green[i - 1].toDouble());
        }
      } else if (this.evaluate == PreferenceKey.potassium) {
        for (int i = 1; i < 51; i++) {
          standard.add(blue[i - 1].toDouble());
        }
      }
    } catch (e) {
      logger.e('Fail: calculate standard value');
    }
    // print(standard);
    return standard;
  }

  List<double> calSample() {
    // print(Plate.php);
    this.sample = [];
    try {
      if (this.evaluate == PreferenceKey.phosphate) {
        for (int i = 51; i < red.length + 1; i++) {
          sample.add(red[i - 1].toDouble());
        }
      } else if (this.evaluate == PreferenceKey.nitrate) {
        for (int i = 51; i < green.length + 1; i++) {
          sample.add(green[i - 1].toDouble());
        }
      } else if (this.evaluate == PreferenceKey.potassium) {
        for (int i = 51; i < blue.length + 1; i++) {
          sample.add(blue[i - 1].toDouble());
        }
      }
    } catch (e) {
      logger.e('Fail: calculate sample value');
    }
    // print(sample);
    return sample;
  }
}
