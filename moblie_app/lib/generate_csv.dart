// import 'dart:html';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:path_provider/path_provider.dart';

import 'generate_all_csv.dart';
import 'load_data_csv.dart';

class CSV extends StatefulWidget {
  CSV({Key? key}) : super(key: key);

  @override
  State<CSV> createState() => _CSVState();
}

class _CSVState extends State<CSV> {
  @override
  void initState() {
    FlutterNativeSplash.remove();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("generate csv"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            MaterialButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => AllCsvFilesScreen()));
              },
              color: Colors.cyanAccent,
              child: Text("Load all csv form phone storage"),
            ),
            MaterialButton(
              onPressed: () {
                loadCsvFromStorage();
              },
              color: Colors.cyanAccent,
              child: Text("Load csv form phone storage"),
            ),
            MaterialButton(
              onPressed: () {
                generateCsv();
              },
              color: Colors.cyanAccent,
              child: Text("Load Created csv"),
            ),
          ],
        ),
      ),
    );
  }

  generateCsv() async {
    List<List<String>> data = [
      ["No.", "Name", "Roll No."],
      ["1", "A", "100"],
      ["2", "B", "200"],
      ["3", "C", "300"]
    ];
    String csvData = ListToCsvConverter().convert(data);
    final String directory = (await getExternalStorageDirectory())!.path;
    final path = "$directory/m-css-${DateTime.now()}.csv";
    print(path);
    final File file = File(path);
    await file.writeAsString(csvData);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          return LoadCsvDataScreen(path: path);
        },
      ),
    );
  }

  loadCsvFromStorage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowedExtensions: ['csv'],
      type: FileType.custom,
    );
    String? path = result!.files.first.path;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          return LoadCsvDataScreen(path: path!);
        },
      ),
    );
  }
}
