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
    'Blue_2',
    'FE1',
    'Dye3',
    'Blue',
    'S1_2'
  ];
  static const String standard = 'Standard';
  static const String sample = 'Sample';
  static const String phosphate = 'Phosphate';
  static const String nitrate = 'Nitrate';
  static const String potassium = 'Potassium';

  static const String reportTitle =
      'รายงานผลการวิเคราะห์ธาตุอาหารในดินจากภาพถ่าย';
  static const String nameTitle = 'ชื่อการทดลอง: ';
  static const String evaluateTitle = 'ธาตุอาหารในดิน: ';
  static const String dateTitle = 'วันที่ส่งภาพเพื่อวิเคราะห์: ';

  static const String inputForm = 'select evaluate';
  static const String noti = 'กรุณากรอกข้อมูลให้ครบ';
  static const String analyzButton = 'วิเคราะห์';
  static const String imageTitle = 'รูปภาพที่วิเคราะห์: ';
}
