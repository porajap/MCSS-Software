List<int> genRow(int noRow, List<int> rowStart) {
  var rows;
  for (int i in rowStart) {
    rows = List.generate(noRow, (index) => index + i);
    rows = rows+rows;
  }

  return rows;
}

class Plate {
  //Phosphate,Nitrate,Potassium
  var pnpStandard = [14, 15, 16, 17, 18, 26, 27, 28, 29, 30];
  // var pnpSample = genRow(10, [38,50,62,84]);
  var pnpSample = [
    38,
    39,
    40,
    41,
    42,
    43,
    44,
    45,
    46,
    47,
    50,
    51,
    52,
    53,
    54,
    55,
    56,
    57,
    58,
    59,
    62,
    63,
    64,
    65,
    66,
    67,
    68,
    69,
    70,
    71,
    74,
    75,
    76,
    77,
    78,
    79,
    80,
    81,
    82,
    83
  ];
}
