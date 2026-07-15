import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:moblie_app/utils/color_config.dart';
import 'package:moblie_app/utils/text_config.dart';

class LoadCsvDataScreen extends StatelessWidget {
  final String path;
  final String title;

  const LoadCsvDataScreen({super.key, required this.path, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$title.csv', style: StyleText.appBar),
      ),
      body: FutureBuilder(
        future: loadingCsvData(path),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          return snapshot.hasData
              ? ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  itemCount: snapshot.data!.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: ColorCode.divider),
                  itemBuilder: (context, index) {
                    final data = snapshot.data![index];
                    final isHeader = index == 0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: List.generate(7, (i) {
                          return Expanded(
                            child: Text(
                              data[i].toString(),
                              textAlign: TextAlign.center,
                              style: isHeader
                                  ? StyleText.labelText
                                  : StyleText.resultText,
                            ),
                          );
                        }),
                      ),
                    );
                  },
                )
              : const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Future<List<List<dynamic>>> loadingCsvData(String path) async {
    final csvFile = File(path).openRead();
    return await csvFile
        .transform(utf8.decoder)
        .transform(
          CsvToListConverter(),
        )
        .toList();
  }
}
