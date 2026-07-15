import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../utils/constants.dart';
import '../../../utils/text_config.dart';

final DateTime reportDate = DateTime.now();

Widget buildReportHeader(String name, String evaluate) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(children: [
      Text(
        PreferenceKey.reportTitle,
        style: StyleText.headerText,
        textAlign: TextAlign.center,
      ),
      Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Text(PreferenceKey.nameTitle, style: StyleText.headerText),
        name != ''
            ? Text(name, style: StyleText.normalText)
            : Text('-', style: StyleText.normalText)
      ]),
      Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Text(PreferenceKey.evaluateTitle, style: StyleText.headerText),
        Text(evaluate, style: StyleText.normalText)
      ]),
      const SizedBox(height: 3),
      Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Text(PreferenceKey.dateTitle, style: StyleText.headerText),
        Text(DateFormat.yMd().add_jm().format(reportDate), style: StyleText.normalText)
      ])
    ]),
  );
}
