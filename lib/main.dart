import 'dart:async';
import 'dart:ffi';
import 'dart:math';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:matrix_utils/matrix_utils.dart' as mrx;
import 'package:excel/excel.dart' hide Border;
import 'package:permission_handler/permission_handler.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wifi_scan/wifi_scan.dart';

void main() {
  runApp(const MyApp());
}

/// Example app for wifi_scan plugin.
class MyApp extends StatefulWidget {
  /// Default constructor for [MyApp] widget.
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<WiFiAccessPoint> accessPoints = <WiFiAccessPoint>[];
  List<WiFiAccessPoint> secureAPs = <WiFiAccessPoint>[];
  List<WifiLocation> filteredAPs = <WifiLocation>[];
  StreamSubscription<List<WiFiAccessPoint>>? subscription;
  bool shouldCheckCan = true;
  bool get isStreaming => subscription != null;

  String message = 'Press create, enter real coordinates, Get Data, then Save';
  String recents = '';
  List<double> realCoordinate = [0, 0];
  String filter = '';

  int docColumn = 0;
  int lastCol = 0;

  var p1 = mrx.Vector.fromList([8, 9, 0]); //Indihome
  var p2 = mrx.Vector.fromList([5, 5.5, 0]); //Redmi 9
  var p3 = mrx.Vector.fromList([11, 4, 0]); //RN11

  List<String> savedAPs = [
    'b0:4e:26:9f:94:42',
    'b0:4e:26:9f:98:c2',
    '84:F1:47:8b:88:ee'
        '24:36:da:9c:f9:8e', // Lorong selatan barat  1
    '2c:73:a0:0f:28:2e', // S210                  2
    '2c:73:a0:0f:21:0e', // S211                  3
    '2c:73:a0:0f:1e:2e', // Lab IF                4
    '24:36:da:a3:52:6e', // Lorong selatan timur  5
    '24:36:da:9c:fb:0e', // S202                  6
    '24:36:da:a3:0b:ae', // Depan akademik        7
    '6c:b2:ae:69:94:ae', // Depan ElDas           8
    '2c:73:a0:0f:21:ae', // Eldas                 9
    '84:F1:47:8b:88:ee', // Samping Eldas         10
    '2c:73:a0:0f:26:ae', // LisDas                11
    '2c:73:a0:0f:28:0e', // N205                  12
    '2c:73:a0:0f:01:ae', // Lorong utara timur    13
    '24:36:da:9c:F4:ee', // N203                  14
    '24:36:da:9d:45:4e', // N201                  15
    //S208                                        16
    //S205                                        17
  ];

  List<WifiLocation> apLocationList = [
    WifiLocation(
        bssid: '24:36:da:9c:f9:8e',
        location: mrx.Vector.fromList([13, 13.1])), // Lorong selatan barat  1
    WifiLocation(
        bssid: '2c:73:a0:0f:28:2e',
        location: mrx.Vector.fromList([16.5, 17.7])), // S210                  2
    WifiLocation(
        bssid: '2c:73:a0:0f:21:0e',
        location: mrx.Vector.fromList([20, 17.8])), // S211                  3
    WifiLocation(
        bssid: '2c:73:a0:0f:1e:2e',
        location: mrx.Vector.fromList([20.5, 4.8])), // Lab IF                4
    WifiLocation(
        bssid: '24:36:da:a3:52:6e',
        location: mrx.Vector.fromList([42.8, 13.1])), // Lorong selatan timur  5
    WifiLocation(
        bssid: '24:36:da:9c:fb:0e',
        location: mrx.Vector.fromList([37.2, 16.6])), // S202                  6
    WifiLocation(
        bssid: '24:36:da:a3:0b:ae',
        location: mrx.Vector.fromList([28.2, 24.4])), // Depan akademik        7
    WifiLocation(
        bssid: '6c:b2:ae:69:94:ae',
        location: mrx.Vector.fromList([23.8, 31.8])), // Depan ElDas           8
    WifiLocation(
        bssid: '2c:73:a0:0f:21:ae',
        location: mrx.Vector.fromList([27.5, 43.2])), // Eldas                 9
    WifiLocation(
        bssid: '84:F1:47:8b:88:ee',
        location:
            mrx.Vector.fromList([32.2, 43.8])), // Samping Eldas         10
    WifiLocation(
        bssid: '2c:73:a0:0f:26:ae',
        location:
            mrx.Vector.fromList([46.8, 43.8])), // LisDas                11
    WifiLocation(
        bssid: '2c:73:a0:0f:28:0e',
        location:
            mrx.Vector.fromList([57.1, 40.8])), // N205                  12
    WifiLocation(
        bssid: '2c:73:a0:0f:01:ae',
        location: mrx.Vector.fromList(
            [9109201940918409184, 36.8])), // Lorong utara timur    13
    WifiLocation(
        bssid: '24:36:da:9c:F4:ee',
        location: mrx.Vector.fromList([44.9, 32])), // N203                  14
    WifiLocation(
        bssid: '24:36:da:9d:45:4e',
        location: mrx.Vector.fromList(
            [12198247198279, 32])), // N201                  15
    //WifiLocation(bssid: '', location: mrx.Vector.fromlist([7, 10.2]))   //S208                                                                     16
    //WifiLocation(bssid: '', location: mrx.Vector.fromlist([34.5, 11.5]))   //S205                                                                     17
    WifiLocation(
        bssid: 'b0:4e:26:9f:94:42', location: mrx.Vector.fromList([12, 13])),
    WifiLocation(
        bssid: 'b0:4e:26:9f:98:c2', location: mrx.Vector.fromList([10, 1])),
    WifiLocation(
        bssid: '84:F1:47:8b:88:ee', location: mrx.Vector.fromList([10, 15])),
  ];

  var excel = Excel.createExcel();
  var excelData = Excel.createExcel();

  void _excelCreate(BuildContext context) async {
    try {
      excel.rename('Sheet1', 'Data');
      setState(() => message = "Excel Created (not saved)");
      var file = 'storage/emulated/0/Download/Trilateration_Data.xlsx';
      var bytes = File(file).readAsBytesSync();
      excelData = Excel.decodeBytes(bytes);
    } on Exception catch (e) {
      print(e);
    }
  }

  void _changeReal(BuildContext context, int xOrY, String value) {
    if (value == '') {
      throw Error();
    }
    setState(() => realCoordinate[xOrY] = double.parse(value));
    setState(() => message = realCoordinate.toString());
  }

  Future<void> _startScan(BuildContext context) async {
    // check if "can" startScan
    if (shouldCheckCan) {
      // check if can-startScan
      final can = await WiFiScan.instance.canStartScan();
      // if can-not, then show error
      if (can != CanStartScan.yes) {
        if (mounted) kShowSnackBar(context, "Cannot start scan: $can");
        return;
      }
    }
    // print(mantap);
    // call startScan API
    final result = await WiFiScan.instance.startScan();
    if (mounted) kShowSnackBar(context, "startScan: $result");
    // reset access points.
    setState(() => accessPoints = <WiFiAccessPoint>[]);
  }

  Future<void> savee(BuildContext context) async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
      // await Permission.manageExternalStorage.request();
    }
    // status = await Permission.manageExternalStorage.status;
    // if (!status.isGranted) {
    //   // await Permission.storage.request();
    //   await Permission.manageExternalStorage.request();
    // }
    var fileBytes = excel.save();
    var directory =
        'storage/emulated/0/Skripsi/Trilateration_Data_Processed.xlsx';

    try {
      File(directory)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes!);
      setState(() => message = "Saved! in $directory");
    } on Exception catch (e) {
      setState(() => message = "Error! $e");
    }
  }

  List<mrx.Vector> _lsqTrila(List<WifiLocation> apList) {
    return [
      mrx.Vector.fromList([1])
    ];
  }

  List<mrx.Vector> _countTrila(
      mrx.Vector p1, mrx.Vector p2, mrx.Vector p3, num r1, num r2, num r3) {
    mrx.Vector point1 = mrx.Vector.fromList([0, 0, 0]);
    mrx.Vector point2 =
        mrx.Vector.fromList([p2[0] - p1[0], p2[1] - p1[1], p2[2] - p1[2]]);
    mrx.Vector point3 =
        mrx.Vector.fromList([p3[0] - p1[0], p3[1] - p1[1], p3[2] - p1[2]]);
    mrx.Vector v1 = point2 - point1;
    mrx.Vector v2 = point3 - point1;

    // print("$p1 $p2 $p3");
    // print("p2 = $point2");
    // print("p3 = $point3");
    // print("v1 = $v1");
    // print("v2 = $v2");

    mrx.Vector xn = (v1) / v1.norm();

    mrx.Vector tmp = v1.cross(v2);

    mrx.Vector zn = tmp / tmp.norm();

    mrx.Vector yn = xn.cross(zn);

    var i = xn.dot(v2);
    var d = xn.dot(v1);
    var j = yn.dot(v2);

    var x = (pow(r1, 2) - pow(r2, 2) + pow(d, 2)) / (2 * d);
    var y = ((pow(r1, 2) - pow(r3, 2) + pow(i, 2) + pow(j, 2)) / (2 * j)) -
        ((i / j) * x);
    var z1 = sqrt(max(0, pow(r1, 2) - pow(x, 2) - pow(y, 2)));
    var z2 = -z1;

    mrx.Vector k1 = p1 + xn * x + yn * y + zn * z1;
    mrx.Vector k2 = p1 + xn * x + yn * y - zn * z2;

    // print(k1);
    // print(k2);

    return [k1, k2];
  }

  List<num> _rssConvert(List<num> rss) {
    var nice = <num>[];
    for (int i = 0; i < rss.length; i++) {
      nice.add(pow(e, (rss[i] + 36.5) / -13.63755));
    }
    // print(nice); //For Testing
    return nice;
  }

  num _rssConvertOne(int? rss) {
    // print(nice); //For Testing
    return pow(e, (rss! + 35.72650048) / -7.58672643);
  }

  Future<bool> _canGetScannedResults(BuildContext context) async {
    if (shouldCheckCan) {
      // check if can-getScannedResults
      final can = await WiFiScan.instance.canGetScannedResults();
      // if can-not, then show error
      if (can != CanGetScannedResults.yes) {
        if (mounted) kShowSnackBar(context, "Cannot get scanned results: $can");
        accessPoints = <WiFiAccessPoint>[];
        return false;
      }
    }
    return true;
  }

  Future<List<mrx.Vector>> _convertComponent(int column, int row) async {
    try {
      var sheetObject = excelData['Data'];
      List<num> values = [0, 0, 0];
      List<mrx.Vector> target = [
        mrx.Vector.fromList([0, 0, 0])
      ];

      values[0] = num.parse(sheetObject
          .cell(CellIndex.indexByColumnRow(
              columnIndex: column + 4, rowIndex: row))
          .value
          .toString());
      values[1] = num.parse(sheetObject
          .cell(CellIndex.indexByColumnRow(
              columnIndex: column + 5, rowIndex: row))
          .value
          .toString());
      values[2] = num.parse(sheetObject
          .cell(CellIndex.indexByColumnRow(
              columnIndex: column + 6, rowIndex: row))
          .value
          .toString());

      _rssConvert(values);

      target = await _countTrila(p1, p2, p3, values[0], values[1], values[2]);

      return target;
    } on Exception catch (e) {
      throw Exception(e);
    }
  }

  Future<List<mrx.Vector>> _getScannedResultsAll(BuildContext context) async {
    //Only for seeing all Wifi
    if (await _canGetScannedResults(context)) {
      // get scanned results
      final results = await WiFiScan.instance.getScannedResults();
      setState(() => accessPoints = results);

      List<WiFiAccessPoint> cacheSecureAP = <WiFiAccessPoint>[];
      List<WifiLocation> cacheLocationAP = <WifiLocation>[];

      try {
        print(accessPoints.length);
        for (int i = 0; i < accessPoints.length; i++) {
          // print(i);
          print(accessPoints[i].bssid);
          if (((accessPoints[i].ssid == "UGM-Secure") |
                  (accessPoints[i].ssid == "Griya Firdaus I NEW")) &
              // savedAPs.contains(accessPoints[i].bssid) &
              (accessPoints[i].standard == WiFiStandards.n)) {
            print(accessPoints[i].bssid + "=======");
            cacheSecureAP.add(accessPoints[i]);
            cacheLocationAP.add(apLocationList.firstWhere(
                (element) => element.bssid == accessPoints[i].bssid,
                orElse: () => WifiLocation(
                    bssid: '-1', location: mrx.Vector.fromList([-1]))));
            print(cacheLocationAP[cacheLocationAP.length - 1].bssid + "!!!!");
            // print(cacheSecureAP[cacheSecureAP.length - 1].bssid + "!!!!!!!");
          }
        }
        setState(() => secureAPs = cacheSecureAP);
      } on Exception catch (e) {
        print(e);
      }

      // try {
      //   for (int i = 0; i < cacheSecureAP.length; i++) {
      //     cacheLocationAP.add(apLocationList.firstWhere(
      //         (element) => element.bssid == cacheSecureAP[i].bssid,
      //         orElse: () => WifiLocation(
      //             bssid: '-1', location: mrx.Vector.fromList([-1]))));
      //     print(cacheLocationAP[cacheLocationAP.length - 1].bssid);
      //   }
      // } on Exception catch (e) {
      //   print(e);
      // }

      // List<num> values = _getRSSValues();
      // print(values);
      // values = _rssConvert(values);

      // List<mrx.Vector> target =
      //     _countTrila(p1, p2, p3, values[0], values[1], values[2]);

      List<mrx.Vector> target = [
        mrx.Vector.fromList([1]),
        mrx.Vector.fromList([1])
      ];

      print(cacheLocationAP[cacheLocationAP.length - 1].bssid);
      return target;
    } else {
      throw Exception();
    }
  }

  Future<List<mrx.Vector>> _getScannedResults(BuildContext context) async {
    if (await _canGetScannedResults(context)) {
      // get scanned results
      final results = await WiFiScan.instance.getScannedResults();
      setState(() => accessPoints = results);

      List<WiFiAccessPoint> cacheSecureAP = <WiFiAccessPoint>[];
      List<WifiLocation> cacheLocationAP = <WifiLocation>[];

      try {
        for (int i = 0; i < accessPoints.length; i++) {
          //Filtering for only saved APs
          if (((accessPoints[i].ssid == "UGM-Secure") |
                  (accessPoints[i].ssid == "Griya Firdaus I NEW")) &
              savedAPs.contains(accessPoints[i].bssid) &
              // (accessPoints[i].level < 90) &
              (accessPoints[i].standard == WiFiStandards.n)) {
            //Add AP points to filtered list
            cacheSecureAP.add(accessPoints[i]);
            cacheLocationAP.add(apLocationList.firstWhere(
                (element) => element.bssid == accessPoints[i].bssid,
                orElse: () => WifiLocation(
                    bssid: '-1', location: mrx.Vector.fromList([-1]))));
            //RSSI and Conversion
            cacheLocationAP[cacheLocationAP.length - 1].rssi =
                accessPoints[i].level;
            cacheLocationAP[cacheLocationAP.length - 1].distance =
                _rssConvertOne(
                    cacheLocationAP[cacheLocationAP.length - 1].rssi);
          }
        }
        setState(() => secureAPs = cacheSecureAP);
        setState(() => filteredAPs = cacheLocationAP);
      } on Exception catch (e) {
        print(e);
      }

      // List<mrx.Vector> target =
      //     _countTrila(p1, p2, p3, values[0], values[1], values[2]);

      List<mrx.Vector> target = [
        mrx.Vector.fromList([1, 2]),
        mrx.Vector.fromList([3, 3])
      ];

      print(cacheLocationAP[cacheLocationAP.length - 1].location);
      print(cacheLocationAP[cacheLocationAP.length - 1].rssi);
      print(filteredAPs[filteredAPs.length - 1].location);
      print(target[0][1]);
      return target;
    } else {
      throw Exception();
    }
  }

  void _nextColumn() {
    setState(() => docColumn += filteredAPs.length + 3);
  }

  void _prevColumn() {
    setState(() => docColumn -= 6);
  }

  Future<void> _convertData(BuildContext context) async {
    var sheetObject = excel['Data'];
    var dataObject = excelData['Data'];

    var column = docColumn + 1;
    var row = 1;

    // print("test");

    sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: docColumn, rowIndex: row))
            .value =
        dataObject
            .cell(CellIndex.indexByColumnRow(
                columnIndex: docColumn, rowIndex: row))
            .value;
    sheetObject
            .cell(CellIndex.indexByColumnRow(
                columnIndex: docColumn, rowIndex: row + 1))
            .value =
        dataObject
            .cell(CellIndex.indexByColumnRow(
                columnIndex: docColumn, rowIndex: row + 1))
            .value;
    sheetObject
        .cell(CellIndex.indexByColumnRow(
            columnIndex: docColumn + 1, rowIndex: row - 1))
        .value = const TextCellValue("x");
    sheetObject
        .cell(CellIndex.indexByColumnRow(
            columnIndex: docColumn + 2, rowIndex: row - 1))
        .value = const TextCellValue("y");

    List<mrx.Vector> target = [
      mrx.Vector.fromList([0, 0, 0])
    ];
    List<List<mrx.Vector>> recent = [];

    int counter = 0;
    int limit = 32;
    // print("first counterr $counter");

    await Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 50));
      if (counter == limit) {
        // print("limitttt");
        return false;
      }

      setState(() => message = (counter + 1).toString());

      _convertComponent(column, row).then((value) {
        target = value;
        print(target);
        sheetObject
            .cell(CellIndex.indexByColumnRow(
                columnIndex: column, rowIndex: row)) //IMPORTANT
            .value = DoubleCellValue(target[0][0].toDouble()); //IMPORTANT
        sheetObject //IMPORTANT
            .cell(CellIndex.indexByColumnRow(
                columnIndex: column + 1, rowIndex: row))
            .value = DoubleCellValue(target[0][1].toDouble());
        // sheetObject
        //     .cell(CellIndex.indexByColumnRow(
        //         columnIndex: column + 4, rowIndex: row))
        //     .value = TextCellValue(_getRSSValues()[0].toString());
        // sheetObject
        //     .cell(CellIndex.indexByColumnRow(
        //         columnIndex: column + 5, rowIndex: row))
        //     .value = TextCellValue(_getRSSValues()[1].toString());
        // sheetObject
        //     .cell(CellIndex.indexByColumnRow(
        //         columnIndex: column + 6, rowIndex: row))
        //     .value = TextCellValue(_getRSSValues()[2].toString());
        row++;
        // print(sheetObject
        //     .cell(CellIndex.indexByColumnRow(
        //         columnIndex: column + 6, rowIndex: row))
        //     .value);
        // recent.add(target);
        // recents = recent.reversed.toList().getRange(0, 1).toString();
      }).catchError((e) {
        print(e);
        row++;
      });
      counter++;
      // print("continueee");
      return true;
    });
    // print(target);
    setState(() => lastCol = column + 6);
    _nextColumn();
  }

  Future<void> _trilaterationSequence(BuildContext context) async {
    excel.rename('Sheet1', 'Data');
    var sheetObject = excel['Data'];

    var column = docColumn + 1;
    var row = 1;

    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: docColumn, rowIndex: row))
        .value = DoubleCellValue(realCoordinate[0]);
    sheetObject
        .cell(CellIndex.indexByColumnRow(
            columnIndex: docColumn, rowIndex: row + 1))
        .value = DoubleCellValue(realCoordinate[1]);
    sheetObject
        .cell(CellIndex.indexByColumnRow(
            columnIndex: docColumn + 1, rowIndex: row - 1))
        .value = const TextCellValue("x");
    sheetObject
        .cell(CellIndex.indexByColumnRow(
            columnIndex: docColumn + 2, rowIndex: row - 1))
        .value = const TextCellValue("y");

    List<mrx.Vector> target = [
      mrx.Vector.fromList([0, 0])
    ];
    List<List<mrx.Vector>> recent = [];
    List<int> lengths = [];

    int counter = 0;
    int limit = 32;
    // print("first counterr $counter");

    await Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1, milliseconds: 50));
      if (counter == limit) {
        // print("limitttt");
        return false;
      }

      setState(() => message = (counter + 1).toString());

      _startScan(context)
          .then((value) => _getScannedResults(context)
                  .then((value) => target = value)
                  .then((value) {
                print(target[0][0]);
                lengths.add(filteredAPs.length);

                sheetObject
                        .cell(CellIndex.indexByColumnRow(
                            columnIndex: column, rowIndex: row)) //IMPORTANT
                        .value =
                    DoubleCellValue(target[0][0].toDouble()); //IMPORTANT
                sheetObject //IMPORTANT
                    .cell(CellIndex.indexByColumnRow(
                        columnIndex: column + 1, rowIndex: row))
                    .value = DoubleCellValue(target[0][1].toDouble());
                for (int i = 0; i < filteredAPs.length; i++) {
                  sheetObject
                          .cell(CellIndex.indexByColumnRow(
                              columnIndex: column + 2 + i, rowIndex: row))
                          .value =
                      TextCellValue(
                          "${filteredAPs[i].bssid} || ${filteredAPs[i].rssi}");
                }
                // sheetObject
                //     .cell(CellIndex.indexByColumnRow(
                //         columnIndex: column + 2, rowIndex: row))
                //     .value = DoubleCellValue(target[1][0].toDouble());
                // sheetObject
                //     .cell(CellIndex.indexByColumnRow(
                //         columnIndex: column + 3, rowIndex: row))
                //     .value = DoubleCellValue(target[1][1].toDouble());
                // sheetObject
                //     .cell(CellIndex.indexByColumnRow(
                //         columnIndex: column + 2, rowIndex: row))
                //     .value = TextCellValue(_getRSSValues()[0].toString());
                // sheetObject
                //     .cell(CellIndex.indexByColumnRow(
                //         columnIndex: column + 3, rowIndex: row))
                //     .value = TextCellValue(_getRSSValues()[1].toString());
                // sheetObject
                //     .cell(CellIndex.indexByColumnRow(
                //         columnIndex: column + 4, rowIndex: row))
                //     .value = TextCellValue(_getRSSValues()[2].toString());
                // print(sheetObject
                //     .cell(CellIndex.indexByColumnRow(
                //         columnIndex: column + 6, rowIndex: row))
                //     .value);
                recent.add(target);
                recents = recent.reversed.toList().getRange(0, 1).toString();

                // setState(() => lastCol = column + 4);
              }).then((value) {
                row++;
              }))
          .catchError((e) {
        // _trueReturn(e);
        print('${e} not found');
        // print("huh weird");
        sheetObject
            .cell(
                CellIndex.indexByColumnRow(columnIndex: column, rowIndex: row))
            .value = TextCellValue('${e} not found');
        row++;
      });

      counter++;
      // print("continueee");
      return true;
    });
    // print(target);
    setState(() =>
        lastCol = column + (lengths.isEmpty ? 3 : lengths.reduce(max) + 2));
    setState(() =>
        docColumn = column + (lengths.isEmpty ? 4 : lengths.reduce(max) + 3));
  }

  List<int> _getRSSValues() {
    String mantap = '';
    if (accessPoints.isEmpty) {
      print("Empty Wifi List");
      throw ErrorDescription("WiFi List Empty!");
    }
    List<String> apBssid = [
      // "f8:75:88:c4:c5:a4", //Sibayak
      // "b6:15:e6:39:b6:59", //SMA IT
      // "76:cf:18:0b:ae:b9", //Redmi 9
      // "82:8f:c8:09:86:80", //Note 11
      // "66:48:4d:10:ae:d5", //Redmi Note 11
      "b0:4e:26:9f:94:42", //GF I New
      // "2c:73:a0:0f:01:ae" //UGM-Secure Depan N203
      // "2c:73:a0:0f:26:ae" //UGM-Secure Lab Eldas
    ];

    List<String> test = ["00:13:10:85:fe:01"];
    // print(apBssid.length);
    var mantapp = <WiFiAccessPoint>[];
    var rssValue = <int>[];
    // print(apBssid[2]);
    // print(apBssid.length);

    try {
      for (int i = 0; i < apBssid.length; i++) {
        // print("$i ======== mantapp");
        print(apBssid[i]);
        mantap = apBssid[i];
        mantapp.add(
            secureAPs.firstWhere((element) => element.bssid == apBssid[i]));
        // accessPoints.firstWhere((element) => element.bssid == test[0]));
        // print("accesspoints loop");
      }
      //TESTING
      mantapp.add(mantapp[0]);
      mantapp.add(mantapp[0]);
      //TESTING
    } catch (e) {
      print("error while getting RSS Values");
      throw Exception(mantap);
    }

    // try{
    //   for(int i = 0; i<accessPoints.length;i++){
    //     if ()
    //   }
    // }catch(e){
    //   throw Exception (e);
    // }

    for (int i = 0; i < 3; i++) {
      // print(mantapp[i].level);
      // print("rssValue");
      rssValue.add(mantapp[i].level);
      // print(rssValue);
    }
    // rssValue = [-58, -56, -67]; //For Testing
    // print(rssValue);

    // var testValues = <int>[];
    // return testValues;
    return rssValue;
  }

  Future<void> _justScan(BuildContext context) async {
    _startScan(context).then((value) => _getScannedResults(context));
  }

  void _bssidTest(BuildContext context, String value) async {
    List<WiFiAccessPoint> cacheFilteredAP = <WiFiAccessPoint>[];

    if (value.isEmpty) {
      _getScannedResults(context);
      return;
    }

    try {
      print(accessPoints.length);
      for (int i = 0; i < accessPoints.length; i++) {
        print(i);
        print(accessPoints[i].bssid);
        if ((accessPoints[i].bssid == value)) {
          // print(accessPoints[i].bssid + "=======");
          cacheFilteredAP.add(accessPoints[i]);
          // print(cacheFilteredAP[cacheFilteredAP.length - 1].bssid + "!!!!!!!");
        }
      }
      setState(() => secureAPs = cacheFilteredAP);
    } on Exception catch (e) {
      print(e);
    }
  }

  // build toggle with label
  Widget _buildToggle({
    String? label,
    bool value = false,
    ValueChanged<bool>? onChanged,
    Color? activeColor,
  }) =>
      Row(
        children: [
          if (label != null) Text(label),
          Switch(value: value, onChanged: onChanged, activeColor: activeColor),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Wifi Trilateration app'),
          actions: [
            _buildToggle(
                label: "Check can?",
                value: shouldCheckCan,
                onChanged: (v) => setState(() => shouldCheckCan = v),
                activeColor: Colors.purple)
          ],
        ),
        body: Builder(
          builder: (context) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                        onPressed: () async => _excelCreate(context),
                        icon: const Icon(Icons.edit_document),
                        label: const Text('Make Excel')),
                    ElevatedButton.icon(
                      icon: const Icon(
                        Icons.gps_fixed_sharp,
                      ),
                      label: const Text('Get Data'),
                      onPressed: () async => _trilaterationSequence(context),
                    ),
                    IconButton(
                      onPressed: () async => savee(context),
                      icon: const Icon(Icons.save),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () async => _convertData(context),
                        icon:
                            const Icon(Icons.precision_manufacturing_outlined),
                      ),
                      IconButton(
                          onPressed: () async => _justScan(context),
                          icon: const Icon(Icons.wifi)),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: "Filter by BSSID",
                              contentPadding: EdgeInsets.fromLTRB(8, 3, 8, 3)),
                          onSubmitted: (value) => _bssidTest(context, value),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Berapa x?",
                          contentPadding: EdgeInsets.all(5),
                        ),
                        onSubmitted: (text) => _changeReal(context, 0, text),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Berapa y?",
                          contentPadding: EdgeInsets.all(5),
                        ),
                        onSubmitted: (text) => _changeReal(context, 1, text),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                        onPressed: _prevColumn, child: const Text("Prev")),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Current Column Data: $docColumn"),
                        Text("Last Data Column: $lastCol"),
                      ],
                    ),
                    TextButton(
                        onPressed: _nextColumn, child: const Text("Next")),
                  ],
                ),
                Text(message),
                Text(recents),
                Flexible(
                  child: Center(
                    child: accessPoints.isEmpty
                        ? const Text("NO SCANNED RESULTS")
                        : ListView.builder(
                            itemCount: secureAPs.length,
                            itemBuilder: (context, i) =>
                                _AccessPointTile(accessPoint: secureAPs[i])),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Show tile for AccessPoint.
///
/// Can see details when tapped.
class _AccessPointTile extends StatelessWidget {
  final WiFiAccessPoint accessPoint;

  const _AccessPointTile({Key? key, required this.accessPoint})
      : super(key: key);

  // build row that can display info, based on label: value pair.
  Widget _buildInfo(String label, dynamic value) => Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey)),
        ),
        child: Row(
          children: [
            Text(
              "$label: ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(child: Text(value.toString()))
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final title = accessPoint.ssid.isNotEmpty ? accessPoint.ssid : "**EMPTY**";
    final signalIcon = accessPoint.level >= -68
        ? Icons.signal_wifi_4_bar
        : Icons.signal_wifi_0_bar;
    return ListTile(
      visualDensity: VisualDensity.compact,
      leading: Icon(signalIcon),
      title: Text(title),
      subtitle: Text(
          "${accessPoint.level.toString()} || ${accessPoint.bssid.toString()} || ${accessPoint.frequency} || ${accessPoint.standard}"),
      onTap: () => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfo("BSSDI", accessPoint.bssid),
              _buildInfo("Capability", accessPoint.capabilities),
              _buildInfo("frequency", "${accessPoint.frequency}MHz"),
              _buildInfo("level", accessPoint.level),
              _buildInfo("standard", accessPoint.standard),
              _buildInfo(
                  "centerFrequency0", "${accessPoint.centerFrequency0}MHz"),
              _buildInfo(
                  "centerFrequency1", "${accessPoint.centerFrequency1}MHz"),
              _buildInfo("channelWidth", accessPoint.channelWidth),
              _buildInfo("isPasspoint", accessPoint.isPasspoint),
              _buildInfo(
                  "operatorFriendlyName", accessPoint.operatorFriendlyName),
              _buildInfo("venueName", accessPoint.venueName),
              _buildInfo("is80211mcResponder", accessPoint.is80211mcResponder),
            ],
          ),
        ),
      ),
    );
  }
}

/// Show snackbar.
void kShowSnackBar(BuildContext context, String message) {
  if (kDebugMode) print(message);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

class WifiLocation {
  String bssid;
  mrx.Vector location;
  late int? rssi;
  late num? distance;

  WifiLocation(
      {required this.bssid, required this.location, this.rssi, this.distance});
}
