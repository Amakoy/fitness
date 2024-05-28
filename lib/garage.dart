
// List<int> _getRSSValues() {
//     String mantap = '';
//     if (accessPoints.isEmpty) {
//       print("Empty Wifi List");
//       throw ErrorDescription("WiFi List Empty!");
//     }
//     List<String> apBssid = [
//       // "f8:75:88:c4:c5:a4", //Sibayak
//       // "b6:15:e6:39:b6:59", //SMA IT
//       // "76:cf:18:0b:ae:b9", //Redmi 9
//       // "82:8f:c8:09:86:80", //Note 11
//       // "66:48:4d:10:ae:d5", //Redmi Note 11
//       "b0:4e:26:9f:94:42", //GF I New
//       // "2c:73:a0:0f:01:ae" //UGM-Secure Depan N203
//       // "2c:73:a0:0f:26:ae" //UGM-Secure Lab Eldas
//     ];

//     List<String> test = ["00:13:10:85:fe:01"];
//     // print(apBssid.length);
//     var mantapp = <WiFiAccessPoint>[];
//     var rssValue = <int>[];
//     // print(apBssid[2]);
//     // print(apBssid.length);

//     try {
//       for (int i = 0; i < apBssid.length; i++) {
//         // print("$i ======== mantapp");
//         print(apBssid[i]);
//         mantap = apBssid[i];
//         mantapp.add(
//             secureAPs.firstWhere((element) => element.bssid == apBssid[i]));
//         // accessPoints.firstWhere((element) => element.bssid == test[0]));
//         // print("accesspoints loop");
//       }
//       //TESTING
//       mantapp.add(mantapp[0]);
//       mantapp.add(mantapp[0]);
//       //TESTING
//     } catch (e) {
//       print("error while getting RSS Values");
//       throw Exception(mantap);
//     }

//     // try{
//     //   for(int i = 0; i<accessPoints.length;i++){
//     //     if ()
//     //   }
//     // }catch(e){
//     //   throw Exception (e);
//     // }

//     for (int i = 0; i < 3; i++) {
//       // print(mantapp[i].level);
//       // print("rssValue");
//       rssValue.add(mantapp[i].level);
//       // print(rssValue);
//     }
//     // rssValue = [-58, -56, -67]; //For Testing
//     // print(rssValue);

//     // var testValues = <int>[];
//     // return testValues;
//     return rssValue;
//   }

// Future<List<mrx.Vector>> _countTrila(mrx.Vector p1, mrx.Vector p2,
//       mrx.Vector p3, num r1, num r2, num r3) async {
//     mrx.Vector point1 = mrx.Vector.fromList([0, 0, 0]);
//     mrx.Vector point2 =
//         mrx.Vector.fromList([p2[0] - p1[0], p2[1] - p1[1], p2[2] - p1[2]]);
//     mrx.Vector point3 =
//         mrx.Vector.fromList([p3[0] - p1[0], p3[1] - p1[1], p3[2] - p1[2]]);
//     mrx.Vector v1 = point2 - point1;
//     mrx.Vector v2 = point3 - point1;

//     mrx.Vector xn = (v1) / v1.norm();

//     mrx.Vector tmp = v1.cross(v2);

//     mrx.Vector zn = tmp / tmp.norm();

//     mrx.Vector yn = xn.cross(zn);

//     var i = xn.dot(v2);
//     var d = xn.dot(v1);
//     var j = yn.dot(v2);

//     var x = (pow(r1, 2) - pow(r2, 2) + pow(d, 2)) / (2 * d);
//     var y = ((pow(r1, 2) - pow(r3, 2) + pow(i, 2) + pow(j, 2)) / (2 * j)) -
//         ((i / j) * x);
//     var z1 = sqrt(max(0, pow(r1, 2) - pow(x, 2) - pow(y, 2)));
//     var z2 = -z1;

//     mrx.Vector k1 = p1 + xn * x + yn * y + zn * z1;
//     mrx.Vector k2 = p1 + xn * x + yn * y - zn * z2;

//     // print(k1);
//     // print(k2);

//     return [k1, k2];
//   }

// Data Section

//   Future<void> _convertData(BuildContext context) async {
//     // ini nanti aja
//     var sheetObject = excel['Data'];
//     var dataObject = excelData['Data'];

//     var column = docColumn + 1;
//     var row = 1;

//     // print("test");

//     sheetObject
//             .cell(CellIndex.indexByColumnRow(columnIndex: docColumn, rowIndex: row))
//             .value =
//         dataObject
//             .cell(CellIndex.indexByColumnRow(
//                 columnIndex: docColumn, rowIndex: row))
//             .value;
//     sheetObject
//             .cell(CellIndex.indexByColumnRow(
//                 columnIndex: docColumn, rowIndex: row + 1))
//             .value =
//         dataObject
//             .cell(CellIndex.indexByColumnRow(
//                 columnIndex: docColumn, rowIndex: row + 1))
//             .value;
//     sheetObject
//         .cell(CellIndex.indexByColumnRow(
//             columnIndex: docColumn + 1, rowIndex: row - 1))
//         .value = const TextCellValue("x");
//     sheetObject
//         .cell(CellIndex.indexByColumnRow(
//             columnIndex: docColumn + 2, rowIndex: row - 1))
//         .value = const TextCellValue("y");

//     List<mrx.Vector> target = [
//       mrx.Vector.fromList([0, 0])
//     ];
//     List<List<mrx.Vector>> recent = [];

//     int counter = 0;
//     int limit = 32;
//     // print("first counterr $counter");

//     await Future.doWhile(() async {
//       await Future.delayed(const Duration(milliseconds: 50));
//       if (counter == limit) {
//         // print("limitttt");
//         return false;
//       }

//       setState(() => message = (counter + 1).toString());

//       convertComponent(column, row).then((value) {
//         target = value;
//         print(target);
//         sheetObject
//             .cell(CellIndex.indexByColumnRow(
//                 columnIndex: column, rowIndex: row)) //IMPORTANT
//             .value = DoubleCellValue(target[0][0].toDouble()); //IMPORTANT
//         sheetObject //IMPORTANT
//             .cell(CellIndex.indexByColumnRow(
//                 columnIndex: column + 1, rowIndex: row))
//             .value = DoubleCellValue(target[0][1].toDouble());
//         // sheetObject
//         //     .cell(CellIndex.indexByColumnRow(
//         //         columnIndex: column + 4, rowIndex: row))
//         //     .value = TextCellValue(_getRSSValues()[0].toString());
//         // sheetObject
//         //     .cell(CellIndex.indexByColumnRow(
//         //         columnIndex: column + 5, rowIndex: row))
//         //     .value = TextCellValue(_getRSSValues()[1].toString());
//         // sheetObject
//         //     .cell(CellIndex.indexByColumnRow(
//         //         columnIndex: column + 6, rowIndex: row))
//         //     .value = TextCellValue(_getRSSValues()[2].toString());
//         row++;
//         // print(sheetObject
//         //     .cell(CellIndex.indexByColumnRow(
//         //         columnIndex: column + 6, rowIndex: row))
//         //     .value);
//         // recent.add(target);
//         // recents = recent.reversed.toList().getRange(0, 1).toString();
//       }).catchError((e) {
//         print(e);
//         row++;
//       });
//       counter++;
//       // print("continueee");
//       return true;
//     });
//     // print(target);
//     setState(() => lastCol = column + 6);
//     _nextColumn();
//   }

//   Future<List<mrx.Vector>> convertComponent(int column, int row) async {
//     // ini nanti aja
//     try {
//       var sheetObject = excelData['Data'];
//       List<num> values = [0, 0, 0];
//       List<mrx.Vector> target = [
//         mrx.Vector.fromList([0, 0, 0])
//       ];

//       values[0] = num.parse(sheetObject
//           .cell(CellIndex.indexByColumnRow(
//               columnIndex: column + 4, rowIndex: row))
//           .value
//           .toString());
//       values[1] = num.parse(sheetObject
//           .cell(CellIndex.indexByColumnRow(
//               columnIndex: column + 5, rowIndex: row))
//           .value
//           .toString());
//       values[2] = num.parse(sheetObject
//           .cell(CellIndex.indexByColumnRow(
//               columnIndex: column + 6, rowIndex: row))
//           .value
//           .toString());

//       rssConvert(values);

//       // target = await _countTrila(p1, p2, p3, values[0], values[1], values[2]);

//       return target;
//     } on Exception catch (e) {
//       throw Exception(e);
//     }
//   }

  // Convert Data End



  // void _nextColumn() {
  //   setState(() => docColumn += filteredAPs.length + 3);
  // }

  // void _prevColumn() {
  //   setState(() => docColumn -= 6);
  // }

  
  // List<num> rssConvert(List<num> rss) {
  //   var nice = <num>[];

  //   for (int i = 0; i < rss.length; i++) {
  //     nice.add(pow(e, (rss[i] + 36.5) / -13.63755));
  //   }

  //   return nice;
  // }