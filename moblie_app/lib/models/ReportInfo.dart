import 'dart:core';

import 'package:flutter/foundation.dart';

import '../main.dart';
import '../utils/PlateConfig.dart';

class ReportInfo {
  String name;
  String evaluate;

  List<int> red;
  List<int> green;
  List<int> blue;
  List<double> standard = [];
  List<double> sample = [];
  Map<String, List<double>> con = {
    'Phosphate': [0, 0.5, 1, 2, 3],
    'Nitrate': [0, 0.5, 1, 2.5, 5],
    'Potaasium': [0, 5, 10, 20, 30]
  };
  Plate plate = Plate();
  ReportInfo(this.name, this.evaluate, this.red, this.green, this.blue);

  List<double> calStandard() {
    // print(Plate.pnpStandard);
    this.standard = [];
    // print(this.evaluate);
    try {
      if (this.evaluate == 'Phosphate' || this.evaluate == 'Potaasium') {
        for (int i = 1; i < red.length; i++) {
          if (plate.pnpStandard.contains(i)) {
            // print(i);
            standard.add(red[i - 1].toDouble());
          }
        }
      } else if (this.evaluate == 'Nitrate') {
        for (int i = 1; i < green.length; i++) {
          if (plate.pnpStandard.contains(i)) {
            // print(i);
            standard.add(green[i - 1].toDouble());
          }
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
      if (this.evaluate == 'Phosphate' || this.evaluate == 'Potaasium') {
        for (int i = 1; i < red.length; i++) {
          if (plate.pnpSample.contains(i)) {
            // print(i);
            sample.add(red[i - 1].toDouble());
          }
        }
      } else if (this.evaluate == 'Nitrate') {
        for (int i = 1; i < green.length; i++) {
          if (plate.pnpSample.contains(i)) {
            // print(i);
            sample.add(green[i - 1].toDouble());
          }
        }
      }
    } catch (e) {
      logger.e('Fail: calculate sample value');
    }
    // print(sample);
    return sample;
  }
}
