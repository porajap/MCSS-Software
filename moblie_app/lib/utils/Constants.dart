class GridConfig {
  static int noOfPixelsPerAxisX = 12;
  static int noOfPixelsPerAxisY = 8;
}

class PreferenceKey {
  static const List<String> evaluate = [
    'select evaluate',
    'Phosphate',
    'Nitrate',
    'Potassium',
  ];
  static const String standard = 'Standard';
  static const String sample = 'Sample';
  static const String phosphate = 'Phosphate';
  static const String nitrate = 'Nitrate';
  static const String potassium = 'Potassium';

  static const String hWellIndex = 'well_index';
  static const String hStdSmp = 'STD/SMP';
  static const String hColorR = 'color_R';
  static const String hColorG = 'color_G';
  static const String hColorB = 'color_B';
  static const String hHsv = 'HSV';
  static const String hSaturation = 'Saturation';

  static const String reportTitle = 'Image-Based Soil Nutrient Analysis Report';
  static const String nameTitle = 'Experiment Name: ';
  static const String evaluateTitle = 'Soil Nutrient: ';
  static const String dateTitle = 'Analysis Date: ';

  static const String inputForm = 'Select evaluate';
  static const String noti = 'Please fill in all information';
  static const String analyzeTap = 'Point Analysis';
  static const String analyzeAll = 'Area Analysis';
  static const String imageTitle = 'Image to analyze: ';
}
