import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../utils/color_config.dart';
import '../../../utils/constants.dart';
import '../../../utils/text_config.dart';

final DateTime reportDate = DateTime.now();

Widget buildReportHeader(String name, String evaluate) {
  Widget metaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: StyleText.labelText),
          ),
          Expanded(
            child: Text(value, style: StyleText.normalText),
          ),
        ],
      ),
    );
  }

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
    decoration: const BoxDecoration(
      border: Border(
        bottom: BorderSide(color: ColorCode.divider, width: 1),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          PreferenceKey.reportTitle,
          style: StyleText.titleText,
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 14),
        metaRow(PreferenceKey.nameTitle, name != '' ? name : '-'),
        metaRow(PreferenceKey.evaluateTitle, evaluate),
        metaRow(PreferenceKey.dateTitle, DateFormat.yMd().add_jm().format(reportDate)),
      ],
    ),
  );
}
