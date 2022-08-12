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

  static const String h_well_index = 'well_index';
  static const String h_std_smp = 'STD/SMP';
  static const String h_color_R = 'color_R';
  static const String h_color_G = 'color_G';
  static const String h_color_B = 'color_B';
  static const String h_HSV = 'HSV';
  static const String h_saturation = 'Saturation';

  static const String reportTitle =
      'รายงานผลการวิเคราะห์ธาตุอาหารในดินจากภาพถ่าย';
  static const String nameTitle = 'ชื่อการทดลอง: ';
  static const String evaluateTitle = 'ธาตุอาหารในดิน: ';
  static const String dateTitle = 'วันที่ส่งภาพเพื่อวิเคราะห์: ';

  static const String inputForm = 'select evaluate';
  static const String noti = 'กรุณากรอกข้อมูลให้ครบ';
  static const String analyzTap = 'วิเคราะห์แบบคลิ๊กเลือก';
  static const String analyzAll = 'วิเคราะห์แบบรวม';
  static const String imageTitle = 'รูปภาพที่วิเคราะห์: ';
}
