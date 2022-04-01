import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:moblie_app/models/ReportInfo.dart';
import 'package:moblie_app/utils/TextConfig.dart';

import '../../utils/Constants.dart';
import 'components/InputDecoration.dart';
import '../AnalyzePage/ReportPage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/ReportInfo.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

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
    super.initState();
    reportName.clear();
    // report.evaluate = dropdownValue;
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
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
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
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
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
    XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery, maxHeight: 1080, maxWidth: 1080);
    _cropImage(pickedFile!.path);
    Navigator.pop(context);
  }

  void _getFromCamera() async {
    XFile? pickedFile = await ImagePicker()
        .pickImage(source: ImageSource.camera, maxHeight: 1080, maxWidth: 1080);
    _cropImage(pickedFile!.path);
    Navigator.pop(context);
  }

  void _cropImage(filePath) async {
    File? croppedFile = await ImageCropper().cropImage(
        sourcePath: filePath,
        maxHeight: 1080,
        maxWidth: 1080,
        // aspectRatioPresets: [
        //   CropAspectRatioPreset.original,
        // ],
        androidUiSettings: const AndroidUiSettings(
          cropGridRowCount: 7,
          cropGridColumnCount: 11,
        ));

    if (croppedFile != null) {
      _saveImage();
      setState(() {
        imageFile = croppedFile;
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
    print(_image);
  }

  Widget _checkBox(String evaluate, int index) {
    Widget? isIcon;
    Map<int, String> label = {
      2: '1',
      3: '2',
      4: '3',
      5: '4',
      6: '5',
      7: '6',
      8: '7',
      9: '8',
      10: '9',
      11: '10',
      12: '11',
      13: '12',
      14: 'A',
      27: 'B',
      40: 'C',
      53: 'D',
      66: 'E',
      79: 'F',
      92: 'G',
      105: 'H'
    };
    List<int> standard = [14, 15, 16, 17, 18, 26, 27, 28, 29, 30];
    List<int> sample = [];
    var row1 = List.generate(10, (index) => index + 38);
    var row2 = List.generate(10, (index) => index + 50);
    var row3 = List.generate(10, (index) => index + 62);
    var row4 = List.generate(10, (index) => index + 74);
    sample = row1 + row2 + row3 + row4;
    // if (label.containsKey(index)) {
    //   return Container(
    //     alignment: Alignment.center,
    //     // decoration: BoxDecoration(
    //     //   border: Border.all(color: Colors.grey),
    //     // ),
    //     child: Text(label[index]!),
    //   );
    // }
    if (evaluate == 'Phosphate' ||
        evaluate == 'Nitrate' ||
        evaluate == 'Potassium') {
      //standard
      if (standard.contains(index)) {
        isIcon = Icon(
          Icons.check_circle_outline_outlined,
          color: Colors.green,
        );
      }
      //sample
      if (sample.contains(index)) {
        isIcon = Icon(
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

  Widget _analyzButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          textStyle: StyleText.normalText,
          minimumSize: const Size.fromHeight(50)),
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
      child: Text(PreferenceKey.analyzButton, style: StyleText.buttonText),
    );
  }

  Widget _inputReportName() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(PreferenceKey.nameTitle, style: StyleText.headerText),
        SizedBox(
          height: 0.5,
        ),
        TextFormField(
          controller: reportName,
          onChanged: (context) => setState(() {
            report.name = context;
          }),
          decoration: InputDecorations.inputDec(hintText: 'example'),
          style: StyleText.normalText,
        ),
        SizedBox(
          height: 10,
        ),
        Text(PreferenceKey.evaluateTitle, style: StyleText.headerText),
        SizedBox(
          height: 0.5,
        ),
        InputDecorator(
          decoration: InputDecorations.inputDec(hintText: ''),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              value: dropdownValue,
              icon: const Icon(Icons.arrow_drop_down),
              elevation: 12,
              style: StyleText.normalText,
              onChanged: (String? newValue) {
                setState(() {
                  dropdownValue = newValue!;
                  report.name = reportName.text.toString();
                  report.evaluate = dropdownValue;
                });
              },
              items: PreferenceKey.evaluate
                  .map<DropdownMenuItem<String>>((String value) {
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
    // print("use build State");

    return Scaffold(
      appBar: AppBar(
        title: Text("Modern-CSS v.1"),
      ),
      body: SingleChildScrollView(
        child: Column(
          // mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _inputReportName(),
                      SizedBox(
                        height: 20,
                      ),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  PreferenceKey.imageTitle,
                                  style: StyleText.headerText,
                                ),
                                Spacer(),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    textStyle: StyleText.normalText,
                                  ),
                                  onPressed: _showImageDialog,
                                  child: Text(
                                    imageFile == null
                                        ? "Browse image"
                                        : "Change image",
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
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                              ),
                              child: Stack(
                                children: [
                                  imageFile != null
                                      ? Image.file(imageFile!,
                                          width: double.infinity,
                                          height: double.infinity,
                                          semanticLabel: "96-well plates",
                                          fit: BoxFit.fill)
                                      : Center(
                                          child: Text(
                                            "No image selected",
                                            style: StyleText.normalText,
                                            textAlign: TextAlign.center,
                                          ),
                                          widthFactor: double.infinity,
                                          heightFactor: double.infinity,
                                        ),
                                  GridView.count(
                                    shrinkWrap: true,
                                    // physics: NeverScrollableScrollPhysics(),
                                    crossAxisCount: 12,
                                    children: List.generate(
                                        96,
                                        (index) => _checkBox(
                                            dropdownValue, index + 1)),
                                  )
                                ],
                              ),
                            ),
                          ]),
                      SizedBox(
                        height: 10,
                      ),
                      _analyzButton()
                    ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
