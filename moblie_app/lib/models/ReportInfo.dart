import 'dart:core';

class ReportInfo {
  late String name = 'Demo';
  late String evaluate;
  late List<int> red;
  late List<int> green;
  late List<int> blue;
  List<double> standard = [];
  List<double> sample = [];
  Map<String, List<double>> con = {
    'Phosphate': [0, 0.5, 1, 2, 3],
    'Nitrate': [0, 0.5, 1, 2.5, 5],
    'Potaasium': [0, 5, 10, 20, 30]
  };

  String get info_evaluate {
    return evaluate;
  }

  String get info_name {
    return name;
  }

  List<double> calStandard() {
    var pp = [14, 15, 16, 17, 18, 26, 27, 28, 29, 30];
    var n = [14, 15, 16, 17, 18, 19, 26, 27, 28, 29, 30, 31];
    this.standard = [];
    // print(this.evaluate);
    if (this.evaluate == 'Phosphate' || this.evaluate == 'Potaasium') {
      for (int i = 1; i < red.length; i++) {
        if (pp.contains(i)) {
          // print(i);
          standard.add(red[i - 1].toDouble());
        }
      }
    } else if (this.evaluate == 'Nitrate') {
      for (int i = 1; i < green.length; i++) {
        if (pp.contains(i)) {
          // print(i);
          standard.add(green[i - 1].toDouble());
        }
      }
    }
    // print(standard);
    return standard;
  }

  List<double> calSample() {
    var pnp = [
      38,
      39,
      40,
      41,
      42,
      43,
      44,
      45,
      46,
      47,
      50,
      51,
      52,
      53,
      54,
      55,
      56,
      57,
      58,
      59,
      62,
      63,
      64,
      65,
      66,
      67,
      68,
      69,
      70,
      71,
      74,
      75,
      76,
      77,
      78,
      79,
      80,
      81,
      82,
      83
    ];
    this.sample = [];
    if (this.evaluate == 'Phosphate' || this.evaluate == 'Potaasium') {
      for (int i = 1; i < red.length; i++) {
        if (pnp.contains(i)) {
          // print(i);
          sample.add(red[i - 1].toDouble());
        }
      }
    } else if (this.evaluate == 'Nitrate') {
      for (int i = 1; i < green.length; i++) {
        if (pnp.contains(i)) {
          // print(i);
          sample.add(green[i - 1].toDouble());
        }
      }
    }
    // print(sample);
    return sample;
  }
}
