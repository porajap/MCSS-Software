import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:moblie_app/models/report_info.dart';
import 'package:moblie_app/my_app.dart';
import 'package:moblie_app/pages/analyze_page/summary_page.dart';
import 'package:moblie_app/utils/text_config.dart';

import '../../utils/constants.dart';
import '../../utils/plate_config.dart';
import 'components/input_decorations.dart';
import '../analyze_page/report_page.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController reportName = TextEditingController();
  String dropdownValue = PreferenceKey.inputForm;
  File? imageFile;
  File? _image;
  ReportInfo report = ReportInfo('', '', [], [], []);

  @override
  void initState() {
    FlutterNativeSplash.remove();
    super.initState();
    reportName.clear();
  }

  void _showImageDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              "Please choose an option",
              style: StyleText.headerText,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {
                    _getFromCamera();
                  },
                  child: const Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        "Camera",
                        style: TextStyle(color: Colors.grey),
                      )
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    _getFromGallery();
                  },
                  child: const Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.image,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        "Gallery",
                        style: TextStyle(color: Colors.grey),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }

  void _getFromGallery() async {
    XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, maxHeight: 1080, maxWidth: 1080);
    if (pickedFile == null) return;
    _cropImage(pickedFile.path);
    if (!mounted) return;
    Navigator.pop(context);
  }

  void _getFromCamera() async {
    XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.camera, maxHeight: 1080, maxWidth: 1080);
    if (pickedFile == null) return;
    _cropImage(pickedFile.path);
    if (!mounted) return;
    Navigator.pop(context);
  }

  void _cropImage(filePath) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: filePath,
      maxHeight: 1080,
      maxWidth: 1080,
      uiSettings: [
        AndroidUiSettings(
          cropGridRowCount: 7,
          cropGridColumnCount: 11,
        ),
      ],
    );

    if (croppedFile != null) {
      _saveImage();
      setState(() {
        imageFile = File(croppedFile.path);
      });
    }
  }

  Future _saveImage() async {
    Directory imagePath = await getApplicationDocumentsDirectory();
    String path = imagePath.path;
    File newImage = await imageFile!.copy('$path/image1.png');
    setState(() {
      _image = newImage;
    });
    logger.d('imagePath: $_image');
  }

  Widget _checkBox(String evaluate, int index) {
    Widget? isIcon;
    if (evaluate == 'Phosphate' || evaluate == 'Nitrate' || evaluate == 'Potassium') {
      if (Plate.pnpStandard.contains(index)) {
        isIcon = const Icon(
          Icons.check_circle_outline_outlined,
          color: Colors.green,
        );
      }
      if (Plate.pnpSample!.contains(index)) {
        isIcon = const Icon(
          Icons.check_circle_outline_outlined,
          color: Colors.red,
        );
      }
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
      ),
      child: isIcon,
    );
  }

  Widget _analyzeTap() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        textStyle: StyleText.normalText,
        minimumSize: const Size.fromHeight(50),
      ),
      onPressed: () {
        imageFile == null || report.evaluate == PreferenceKey.inputForm
            ? BotToast.showText(text: PreferenceKey.noti)
            : Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => SummaryPage(
                          imageFile: _image,
                          report: report,
                        )));
      },
      child: Text(PreferenceKey.analyzeTap, style: StyleText.buttonText),
    );
  }

  Widget _analyzeAll() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        textStyle: StyleText.normalText,
        minimumSize: const Size.fromHeight(50),
      ),
      onPressed: () {
        imageFile == null || report.evaluate == PreferenceKey.inputForm
            ? BotToast.showText(text: PreferenceKey.noti)
            : Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => ReportPage(
                    imageFile: _image,
                    report: report,
                  ),
                ),
              );
      },
      child: Text(PreferenceKey.analyzeAll, style: StyleText.buttonText),
    );
  }

  Widget _inputReportName() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(PreferenceKey.nameTitle, style: StyleText.headerText),
        const SizedBox(
          height: 5,
        ),
        TextFormField(
          controller: reportName,
          onChanged: (context) => setState(() {
            report.name = context;
          }),
          decoration: InputDecorations.inputDec(hintText: 'example'),
          style: StyleText.normalText,
        ),
        const SizedBox(
          height: 10,
        ),
        Text(PreferenceKey.evaluateTitle, style: StyleText.headerText),
        const SizedBox(
          height: 5,
        ),
        InputDecorator(
          decoration: InputDecorations.inputDec(hintText: ''),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              hint: const Text('เลือกธาตุอาหาร'),
              value: dropdownValue,
              icon: const Icon(Icons.arrow_drop_down),
              elevation: 4,
              style: StyleText.normalText,
              onChanged: (String? newValue) {
                setState(() {
                  dropdownValue = newValue!;
                  report.name = reportName.text.toString();
                  report.evaluate = dropdownValue;
                });
              },
              items: PreferenceKey.evaluate.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: StyleText.normalText),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("M-CSS v.1.1", style: StyleText.appBar),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                    const SizedBox(
                      height: 10,
                    ),
                    _inputReportName(),
                    const SizedBox(
                      height: 10,
                    ),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            PreferenceKey.imageTitle,
                            style: StyleText.headerText,
                          ),
                          const Spacer(),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              textStyle: StyleText.normalText,
                            ),
                            onPressed: _showImageDialog,
                            child: Text(
                              imageFile == null ? "Upload image" : "Change image",
                              style: StyleText.buttonText,
                            ),
                          )
                        ],
                      ),
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width,
                          maxHeight: 252,
                        ),
                        decoration: const BoxDecoration(
                          shape: BoxShape.rectangle,
                        ),
                        child: Stack(
                          children: [
                            imageFile != null
                                ? Image.file(imageFile!, width: double.infinity, height: double.infinity, semanticLabel: "96-well plates", fit: BoxFit.fill)
                                : Center(
                                    widthFactor: double.infinity,
                                    heightFactor: double.infinity,
                                    child: Text(
                                      "No image selected",
                                      style: StyleText.normalText,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                            GridView.count(
                              shrinkWrap: true,
                              crossAxisCount: 12,
                              children: List.generate(96, (index) => _checkBox(dropdownValue, index + 1)),
                            ),
                          ],
                        ),
                      ),
                    ]),
                    const SizedBox(
                      height: 10,
                    ),
                    _analyzeTap(),
                    const SizedBox(
                      height: 10,
                    ),
                    _analyzeAll()
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
