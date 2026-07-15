import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:moblie_app/utils/color_config.dart';
import 'package:moblie_app/utils/text_config.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class LoadCsvDataScreen extends StatefulWidget {
  final String path;
  final String title;

  const LoadCsvDataScreen({super.key, required this.path, required this.title});

  @override
  State<LoadCsvDataScreen> createState() => _LoadCsvDataScreenState();
}

class _LoadCsvDataScreenState extends State<LoadCsvDataScreen> {
  late final Future<List<List<dynamic>>> _csvFuture;
  List<List<dynamic>>? _rows;

  @override
  void initState() {
    super.initState();
    _csvFuture = loadingCsvData(widget.path);
  }

  String get _fileName {
    final base = widget.title.trim().isEmpty ? 'm-css-report' : widget.title.trim();
    final safe = base.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    return 'm-css-$safe.csv';
  }

  Future<List<List<dynamic>>> loadingCsvData(String path) async {
    final csvFile = File(path).openRead();
    final rows = await csvFile
        .transform(utf8.decoder)
        .transform(const CsvToListConverter())
        .toList();
    _rows = rows;
    return rows;
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _shareCsv() async {
    final file = File(widget.path);
    if (!await file.exists()) {
      _toast('CSV file not found');
      return;
    }
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(widget.path, mimeType: 'text/csv', name: _fileName)],
        subject: _fileName,
        text: 'M-CSS CSV export',
      ),
    );
  }

  Future<void> _saveToDownloads() async {
    try {
      final bytes = await File(widget.path).readAsBytes();

      // Prefer system save dialog (SAF) when available.
      final savedPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save CSV',
        fileName: _fileName,
        type: FileType.custom,
        allowedExtensions: const ['csv'],
        bytes: bytes,
      );

      if (savedPath != null) {
        // Some platforms write via [bytes]; others only return a path.
        final out = File(savedPath);
        if (!await out.exists() || await out.length() == 0) {
          await out.writeAsBytes(bytes, flush: true);
        }
        _toast('Saved: $savedPath');
        return;
      }

      // Fallback: copy into public Downloads when possible.
      final downloadDir = await _resolveDownloadDirectory();
      if (downloadDir == null) {
        _toast('Save cancelled');
        return;
      }
      await downloadDir.create(recursive: true);
      final dest = File(p.join(downloadDir.path, _fileName));
      await dest.writeAsBytes(bytes, flush: true);
      _toast('Saved to Downloads: ${dest.path}');
    } catch (e) {
      _toast('Could not save CSV. Try Share instead.');
    }
  }

  Future<Directory?> _resolveDownloadDirectory() async {
    if (Platform.isAndroid) {
      final publicDownload = Directory('/storage/emulated/0/Download');
      if (await publicDownload.exists()) {
        return publicDownload;
      }
      final dirs = await getExternalStorageDirectories(type: StorageDirectory.downloads);
      if (dirs != null && dirs.isNotEmpty) {
        return dirs.first;
      }
    }
    if (Platform.isIOS) {
      return getApplicationDocumentsDirectory();
    }
    final downloads = await getDownloadsDirectory();
    return downloads;
  }

  Future<void> _printCsv() async {
    final rows = _rows;
    if (rows == null || rows.isEmpty) {
      _toast('No CSV data to print');
      return;
    }

    await Printing.layoutPdf(
      name: _fileName,
      onLayout: (PdfPageFormat format) async {
        final doc = pw.Document();
        final headers = rows.first.map((e) => e.toString()).toList();
        final data = rows
            .skip(1)
            .map((row) => List.generate(headers.length, (i) => i < row.length ? row[i].toString() : ''))
            .toList();

        doc.addPage(
          pw.MultiPage(
            pageFormat: format.landscape,
            margin: const pw.EdgeInsets.all(24),
            build: (context) => [
              pw.Text(
                'M-CSS CSV — ${widget.title}',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 12),
              pw.TableHelper.fromTextArray(
                headers: headers,
                data: data,
                headerStyle: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                cellStyle: const pw.TextStyle(fontSize: 7),
                cellAlignment: pw.Alignment.center,
                headerDecoration: const pw.BoxDecoration(color: PdfColors.brown100),
                border: pw.TableBorder.all(color: PdfColors.grey500, width: 0.4),
                columnWidths: {
                  for (int i = 0; i < headers.length; i++)
                    i: const pw.FlexColumnWidth(),
                },
              ),
            ],
          ),
        );
        return doc.save();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$title.csv', style: StyleText.appBar),
        actions: [
          IconButton(
            tooltip: 'Print',
            color: ColorCode.iconsAppBar,
            onPressed: _printCsv,
            icon: const Icon(Icons.print_rounded),
          ),
          IconButton(
            tooltip: 'Share',
            color: ColorCode.iconsAppBar,
            onPressed: _shareCsv,
            icon: const Icon(Icons.share_rounded),
          ),
          IconButton(
            tooltip: 'Save',
            color: ColorCode.iconsAppBar,
            onPressed: _saveToDownloads,
            icon: const Icon(Icons.download_rounded),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _csvFuture,
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.separated(
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
                        style: isHeader ? StyleText.labelText : StyleText.resultText,
                      ),
                    );
                  }),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String get title => widget.title;
}
