import 'dart:io';

import 'ReportPage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReportParameter {
  String elevation;
  String name;
  List<Color> color;
  List<double> concentrate;

  ReportParameter(this.elevation, this.name, this.color, this.concentrate);
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController reportName = TextEditingController();

  @override
  void initState() {
    super.initState();
    // print("use init State");
  }

  String dropdownValue = "Phosphate";
  File? imageFile;
  File? _image;
  // late ReportParameter report;

  static const normalText = TextStyle(color: Colors.black, fontSize: 20);
  static const headerText =
      TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold);

  void _showImageDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              "Please choose an option",
              style: headerText,
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
        aspectRatioPresets: [
          CropAspectRatioPreset.ratio4x3,
        ],
        androidUiSettings: AndroidUiSettings(
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

  @override
  Widget build(BuildContext context) {
    // print("use build State");

    return Scaffold(
      appBar: AppBar(
        title: Text("Modern-CSS v.1"),
      ),
      body: Column(
        // mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Report Name :", style: headerText),
                    TextFormField(
                      controller: reportName,
                      onChanged: (context) => {
                        print(context),
                        //  report.name = reportName.toString()
                      },
                      decoration: InputDecoration(
                          hintText: "Report name...",
                          enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)))),
                      style: normalText,
                    ),
                    Text("Evaluate Profile :", style: headerText),
                    InputDecorator(
                        decoration: InputDecoration(
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            contentPadding: EdgeInsets.all(8)),
                        child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                          value: dropdownValue,
                          icon: const Icon(Icons.arrow_drop_down),
                          isExpanded: true,
                          elevation: 16,
                          style: normalText,
                          onChanged: (String? newValue) {
                            // report.elevation = dropdownValue;
                            setState(() {
                              dropdownValue = newValue!;
                            });
                            print(dropdownValue);
                          },
                          items: [
                            'Phosphate',
                            'Nitrate',
                            'Potassium',
                            'Blue_2',
                            'FE1',
                            'Dye3',
                            'Blue',
                            'S1_2'
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ))),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Image :",
                        style: headerText,
                      ),
                      Spacer(),
                      imageFile == null
                          ? ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                textStyle: normalText,
                              ),
                              onPressed: _showImageDialog,
                              child: Text(
                                "Browse image",
                              ),
                            )
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  textStyle: normalText),
                              onPressed: _showImageDialog,
                              child: Text(
                                "Change image",
                              ),
                            )
                    ],
                  ),
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width,
                      // maxWidth: 300,
                      // maxHeight: MediaQuery.of(context).size.height,
                      maxHeight: 252,
                    ),
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      // border: Border.all(
                      //   color: Colors.black,
                      // ),
                      // image: imageFile != null
                      //     ? DecorationImage(image: FileImage(imageFile!))
                      //     : DecorationImage(
                      //         image:
                      //             AssetImage('assets/images/water.jpg'))
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
                                  style: normalText,
                                  textAlign: TextAlign.center,
                                ),
                                widthFactor: double.infinity,
                                heightFactor: double.infinity,
                              ),
                        GridView.count(
                          shrinkWrap: true,
                          // physics: NeverScrollableScrollPhysics(),
                          crossAxisCount: 12,
                          // childAspectRatio: 0.67,
                          children: List.generate(96,
                              (index) => _checkBox(dropdownValue, index + 1)),
                        )
                      ],
                    ),
                  ),
                ]),

                //   child: Center(
                //       child: Text("No image selected",
                //           style: normalText)),
                //   decoration: BoxDecoration(
                //     border: Border.all(color: Colors.grey),
                //   ),
                //   width: MediaQuery.of(context).size.width, //360
                //   height: 270,
                // ),
                // )
                // SizedBox(
                //     child: GridView.count(
                //     shrinkWrap: true,
                //     physics: NeverScrollableScrollPhysics(),
                //     crossAxisCount: 12,
                //     // childAspectRatio: 0.67,
                //     children: List.generate(
                //         96,
                //         (index) => Container(
                //               decoration: BoxDecoration(
                //                 border: Border.all(color: Colors.grey),
                //               ),
                //             )),
                //   ))
                // : Padding(
                //     padding: const EdgeInsets.all(8.0),
                //     child: Container(
                //       child: GestureDetector(
                //         // onTap: () {
                //         //   _showImageDialog();
                //         // },
                //         child: Image.file(
                //           imageFile!,
                //           semanticLabel: "96-well plates",
                //         ),
                //       ),
                //     ),
                //   )
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    textStyle: normalText,
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                ReportPage(imageFile: _image)));
                  },
                  child: Text(
                    "Analyze",
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
