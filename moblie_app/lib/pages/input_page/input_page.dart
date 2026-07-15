import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:moblie_app/models/report_info.dart';
import 'package:moblie_app/my_app.dart';
import 'package:moblie_app/pages/analyze_page/summary_page.dart';
import 'package:moblie_app/utils/color_config.dart';
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
  ReportInfo report = ReportInfo('', PreferenceKey.inputForm, [], [], []);

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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text('Please choose an option', style: StyleText.titleText),
          contentPadding: const EdgeInsets.fromLTRB(8, 12, 8, 16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_camera_outlined, color: ColorCode.appBarColor),
                title: Text('Camera', style: StyleText.normalText),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                onTap: _getFromCamera,
              ),
              ListTile(
                leading: Icon(Icons.image_outlined, color: ColorCode.appBarColor),
                title: Text('Gallery', style: StyleText.normalText),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                onTap: _getFromGallery,
              ),
            ],
          ),
        );
      },
    );
  }

  void _getFromGallery() async {
    XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, maxHeight: 1080, maxWidth: 1080);
    if (!mounted) return;
    Navigator.pop(context);
    if (pickedFile == null) return;
    await _cropImage(pickedFile.path);
  }

  void _getFromCamera() async {
    XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.camera, maxHeight: 1080, maxWidth: 1080);
    if (!mounted) return;
    Navigator.pop(context);
    if (pickedFile == null) return;
    await _cropImage(pickedFile.path);
  }

  Future<void> _cropImage(String filePath) async {
    final CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: filePath,
      maxHeight: 1080,
      maxWidth: 1080,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop image',
          toolbarColor: ColorCode.appBarColor,
          toolbarWidgetColor: Colors.white,
          statusBarLight: false,
          activeControlsWidgetColor: ColorCode.appBarColor,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
          hideBottomControls: false,
          cropGridRowCount: 7,
          cropGridColumnCount: 11,
        ),
        IOSUiSettings(
          title: 'Crop image',
          doneButtonTitle: 'Done',
          cancelButtonTitle: 'Cancel',
        ),
      ],
    );

    if (croppedFile == null || !mounted) return;

    final File cropped = File(croppedFile.path);
    setState(() {
      imageFile = cropped;
    });
    await _saveImage(cropped);
  }

  Future<void> _saveImage(File source) async {
    final Directory imagePath = await getApplicationDocumentsDirectory();
    final File newImage = await source.copy('${imagePath.path}/image1.png');
    if (!mounted) return;
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
          Icons.circle,
          size: 10,
          color: Colors.green,
        );
      }
      if (Plate.pnpSample!.contains(index)) {
        isIcon = const Icon(
          Icons.circle,
          size: 10,
          color: Colors.red,
        );
      }
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: ColorCode.borderSubtle.withValues(alpha: 0.7), width: 0.5),
      ),
      alignment: Alignment.center,
      child: isIcon,
    );
  }

  Widget _analyzeTap() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
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
      ),
    );
  }

  Widget _analyzeAll() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: ColorCode.appBarColor,
          side: BorderSide(color: ColorCode.appBarColor.withValues(alpha: 0.7)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
        child: Text(
          PreferenceKey.analyzeAll,
          style: StyleText.buttonText.copyWith(color: ColorCode.appBarColor),
        ),
      ),
    );
  }

  Widget _inputReportName() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(PreferenceKey.nameTitle, style: StyleText.labelText),
        const SizedBox(height: 8),
        TextFormField(
          controller: reportName,
          onChanged: (context) => setState(() {
            report.name = context;
          }),
          decoration: InputDecorations.inputDec(hintText: 'example'),
          style: StyleText.normalText,
        ),
        const SizedBox(height: 20),
        Text(PreferenceKey.evaluateTitle, style: StyleText.labelText),
        const SizedBox(height: 8),
        InputDecorator(
          decoration: InputDecorations.inputDec(hintText: ''),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              isExpanded: true,
              isDense: true,
              hint: Text('Select nutrient', style: StyleText.normalText.copyWith(color: ColorCode.textMuted)),
              value: dropdownValue,
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: ColorCode.appBarColor),
              elevation: 2,
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

  Widget _imageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(PreferenceKey.imageTitle, style: StyleText.labelText),
            ),
            TextButton(
              onPressed: _showImageDialog,
              style: TextButton.styleFrom(
                foregroundColor: ColorCode.appBarColor,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: ColorCode.appBarColor.withValues(alpha: 0.35)),
                ),
              ),
              child: Text(
                imageFile == null ? 'Upload image' : 'Change image',
                style: StyleText.normalText.copyWith(
                  color: ColorCode.appBarColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          height: 252,
          width: double.infinity,
          decoration: BoxDecoration(
            color: ColorCode.surfaceMuted,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: ColorCode.divider),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              imageFile != null
                  ? Image.file(
                      imageFile!,
                      semanticLabel: '96-well plates',
                      fit: BoxFit.fill,
                    )
                  : Center(
                      child: Text(
                        'No image selected',
                        style: StyleText.normalText.copyWith(color: ColorCode.textMuted),
                        textAlign: TextAlign.center,
                      ),
                    ),
              GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                crossAxisCount: 12,
                children: List.generate(96, (index) => _checkBox(dropdownValue, index + 1)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('M-CSS Soil Nutrient Analyzer', style: StyleText.appBar),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _inputReportName(),
              const SizedBox(height: 24),
              const Divider(height: 1, color: ColorCode.divider),
              const SizedBox(height: 20),
              _imageSection(),
              const SizedBox(height: 28),
              _analyzeTap(),
              const SizedBox(height: 10),
              _analyzeAll(),
            ],
          ),
        ),
      ),
    );
  }
}
