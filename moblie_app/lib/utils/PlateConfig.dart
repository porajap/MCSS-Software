//sample
List<int> row1 = List.generate(10, (index) => index + 38);
List<int> row2 = List.generate(10, (index) => index + 50);
List<int> row3 = List.generate(10, (index) => index + 62);
List<int> row4 = List.generate(10, (index) => index + 74);

class Plate {
  var label = ['D', 'E', 'F', 'G'];
  var no = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11];

  //standard
  static List<int> pnpStandard = [14, 15, 16, 17, 18, 26, 27, 28, 29, 30];

  //Phosphate,Nitrate,Potassium
  static List<int>? pnpSample = row1 + row2 + row3 + row4;
  // [
  //   38,
  //   39,
  //   40,
  //   41,
  //   42,
  //   43,
  //   44,
  //   45,
  //   46,
  //   47,
  //   50,
  //   51,
  //   52,
  //   53,
  //   54,
  //   55,
  //   56,
  //   57,
  //   58,
  //   59,
  //   62,
  //   63,
  //   64,
  //   65,
  //   66,
  //   67,
  //   68,
  //   69,
  //   70,
  //   71,
  //   74,
  //   75,
  //   76,
  //   77,
  //   78,
  //   79,
  //   80,
  //   81,
  //   82,
  //   83
  // ];
}
