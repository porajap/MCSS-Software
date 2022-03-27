import 'dart:ffi';

import 'package:scidart/numdart.dart';
import 'package:scidart/scidart.dart';
import 'package:flutter/material.dart';

List<double> conPhosphate = [0, 0.5, 1, 2, 3];
List<double> conNitrate = [0, 0.1, 0.5, 1, 2.5, 5];
List<double> conPotaasium = [0, 5, 10, 20, 30];

class ChartData {
  ChartData(this.x, this.y);
  final double x;
  final double y;
}

PolyFit calRsquare(List<double> x, List<double> y) {
  // print(x.length);
  // print(y.length);
  var equation = PolyFit(Array(x), Array(y), 1);
  // print(equation);
  return equation;
}

List<double> calConcentrate(PolyFit equation, List<double> sample) {
  List<double> result = [];
  sample.forEach((code) {
    result.add(equation.predict(code));
  });
  print(result.length);
  return result;
}

List<ChartData> getData(List<double> result, List<double> rgbCode) {
  List<ChartData> data = [];
  // print(result);
  // print(rgbCode);
  for (int i = 0; i < result.length; i++) {
    data.add(ChartData(result[i], rgbCode[i]));
  }
  return data;
}
