import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../utils/TextConfig.dart';

final date = DateTime.now();

Widget reportHeader(String name, String evaluate) {
  return Padding(
    padding: EdgeInsets.all(8.0),
    child: Column(children: [
      Text(
        'รายงานผลการวิเคราะห์ธาตุอาหารในดินจากภาพถ่าย',
        style: StyleText.headerText,
        textAlign: TextAlign.center,
      ),
      Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Text('Report name: ', style: StyleText.headerText),
        name != ''
            ? Text(name, style: StyleText.normalText)
            : Text('Demo', style: StyleText.normalText)
      ]),
      Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Text('Evaluate: ', style: StyleText.headerText),
        Text(evaluate, style: StyleText.normalText)
      ]),
      Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Text('Date: ', style: StyleText.headerText),
        Text(DateFormat.yMd().add_jm().format(date),
            style: StyleText.normalText)
      ])
    ]),
  );
}
