// sample
List<int> sampleRow1 = List.generate(10, (index) => index + 38);
List<int> sampleRow2 = List.generate(10, (index) => index + 50);
List<int> sampleRow3 = List.generate(10, (index) => index + 62);
List<int> sampleRow4 = List.generate(10, (index) => index + 74);

class Plate {
  List<String> label = ['D', 'E', 'F', 'G'];
  List<int> no = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11];

  // standard
  static List<int> pnpStandard = [14, 15, 16, 17, 18, 26, 27, 28, 29, 30];

  // Phosphate, Nitrate, Potassium
  static List<int>? pnpSample = sampleRow1 + sampleRow2 + sampleRow3 + sampleRow4;
}
