import 'dart:ffi';

import 'package:scidart/numdart.dart';
import 'package:scidart/scidart.dart';
import 'package:flutter/material.dart';

List<double> conPhosphate = [0, 0.5, 1, 2, 3];
List<double> conNitrate = [0, 0.1, 0.5, 1, 2.5, 5];
List<double> conPotaasium = [0, 5, 10, 20, 30];

Set<Object> calculate(List<double> x, List<double> y, List<double> RGBcode) {
  List<double> result = [];
  // print(x.length);
  // print(y.length);
  var equation = PolyFit(Array(x), Array(y), 1);
  // print(equation);
  RGBcode.forEach((code) {
    result.add(equation.predict(code));
  });
  // print(result);
  return {equation,result};
}
