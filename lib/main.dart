import 'dart:async';

import 'dart:math';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:matrix_utils/matrix_utils.dart' as mrx hide MatrixFunctions;
import 'package:excel/excel.dart' hide Border;
import 'package:permission_handler/permission_handler.dart';

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
  bool collectConstants = false;
  bool get isStreaming => subscription != null;

  String message = 'Press create, enter real coordinates, Get Data, then Save';
  String recents = '';
  List<double> realCoordinate = [0, 0];
  String filter = '';

  int docColumn = 0;
  int lastCol = 0;
  int row = 1;

  List<String> savedAPs = [
    'b0:4e:26:9f:94:42', // GF I New
    'b0:4e:26:9f:98:c2', // GF I New
    '00:13:10:85:fe:01', // AndroidWifi (Emulator)
    '24:36:da:9c:f9:8e', // Lorong selatan barat  1
    '2c:73:a0:0f:28:2e', // S210                  2
    '2c:73:a0:0f:21:0e', // S211                  3
    '2c:73:a0:0f:1e:2e', // Lab IF                4
    '24:36:da:a3:52:6e', // Lorong selatan timur  5
    '24:36:da:9c:fb:0e', // S202                  6
    '24:36:da:a3:0b:ae', // Depan akademik        7
    '6c:b2:ae:69:94:ae', // Depan ElDas           8
    '2c:73:a0:0f:21:ae', // Eldas                 9
    '84:f1:47:8b:88:ee', // Samping Eldas         10
    '2c:73:a0:0f:26:ae', // LisDas                11
    '2c:73:a0:0f:28:0e', // N205                  12
    '2c:73:a0:0f:01:ae', // Lorong utara timur    13
    '24:36:da:9c:f4:ee', // N203                  14
    '24:36:da:9d:45:4e', // N201                  15
    '24:36:da:9d:56:8e', //S208                   16
    '84:f1:47:8b:91:8e', //S205                   17
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
        bssid: '84:f1:47:8b:88:ee',
        location:
            mrx.Vector.fromList([32.2, 43.8])), // Samping Eldas              10
    WifiLocation(
        bssid: '2c:73:a0:0f:26:ae',
        location:
            mrx.Vector.fromList([46.8, 43.8])), // LisDas                    11
    WifiLocation(
        bssid: '2c:73:a0:0f:28:0e',
        location:
            mrx.Vector.fromList([57.1, 40.8])), // N205                  12
    WifiLocation(
        bssid: '2c:73:a0:0f:01:ae',
        location:
            mrx.Vector.fromList([46.4, 36.8])), // Lorong utara timur       13
    WifiLocation(
        bssid: '24:36:da:9c:f4:ee',
        location: mrx.Vector.fromList([46.9, 32])), // N203                  14
    WifiLocation(
        bssid: '24:36:da:9d:45:4e',
        location: mrx.Vector.fromList([32.4, 32])), // N201                  15
    WifiLocation(
        bssid: '24:36:da:9d:56:8e',
        location: mrx.Vector.fromList([7, 10.2])), //S208                   16
    WifiLocation(
        bssid: '84:f1:47:8b:91:8e',
        location:
            mrx.Vector.fromList([34.5, 11.5])), //S205                      17
    WifiLocation(
        bssid: 'b0:4e:26:9f:94:42', location: mrx.Vector.fromList([12, 13])),
    WifiLocation(
        bssid: 'b0:4e:26:9f:98:c2', location: mrx.Vector.fromList([10, 1])),
    WifiLocation(
        bssid: '00:13:10:85:fe:01', location: mrx.Vector.fromList([123, 125])),
  ];

  var excel = Excel.createExcel();
  var excelData = Excel.createExcel();

  void _excelCreate(BuildContext context) async {
    try {
      excel.rename('Sheet1', 'Data');
      setState(() => message = "Excel Created (not saved)");

      // var file = 'storage/emulated/0/Download/Trilateration_Data.xlsx';
      // var bytes = File(file).readAsBytesSync();
      // excelData = Excel.decodeBytes(bytes);
    } on Exception catch (e) {
      print(e);
    }
  }

  void _changeReal(BuildContext context, int xOrY, String value) {
    // OK
    if (value == '') {
      throw Error();
    }
    setState(() => realCoordinate[xOrY] = double.parse(value));
    setState(() => message = realCoordinate.toString());
  }

  Future<bool> _canGetScannedResults(BuildContext context) async {
    // OK
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

  Future<void> _startScan(BuildContext context) async {
    // OK
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
    // call startScan API
    final result = await WiFiScan.instance.startScan();
    if (mounted) kShowSnackBar(context, "startScan: $result");
    // reset access points.
    setState(() => accessPoints = <WiFiAccessPoint>[]);
  }

  Future<void> savee(BuildContext context) async {
    // OK
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }

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

  //TEEEEESSTTTTTTTTT

  Future<mrx.Matrix> trilateration(
      mrx.Matrix locations, List<List<num>> radii) async {
    try {
      mrx.Matrix A = locations.scale(2);
      A.appendColumns(mrx.Column.fill(locations.length, 2));

      // print(A);
      mrx.Matrix b = locations.pow(2).row(0).column(0) +
          locations.pow(2).row(0).column(1) -
          mrx.Matrix([radii[0]]).pow(2);
      // print(b);

      print(locations);

      for (int i = 1; i < locations.length; i++) {
        print("======");
        b = b.appendRows(locations.row(i).column(0).pow(2) +
            locations.row(i).column(1).pow(2) -
            mrx.Matrix([radii[i]]).pow(2));
        print(b);
      }
      // print("TEST");
      mrx.Matrix ata = A.transpose() * A; //A^T * A
      mrx.SVD svd = mrx.SVD(ata); //Finding SV
      mrx.Matrix u = A * svd.V() * svd.S().pow(0.5).inverse(); //Finding U

      mrx.Matrix result =
          svd.V() * svd.S().pow(0.5).inverse() * u.transpose() * b;

      return result;
    } on Exception catch (e) {
      throw Exception(e);
    }
  }

  //TEEESSSTTTT EEEENNNNDDDDDD

  List<num> rssConvert(List<num> rss) {
    var nice = <num>[];
    for (int i = 0; i < rss.length; i++) {
      nice.add(pow(e, (rss[i] + 36.5) / -13.63755));
    }
    // print(nice); //For Testing
    return nice;
  }

  num rssConvertOne(int? rss) {
    // print(nice); //For Testing
    return pow(e, (rss! + 1.58308485) / -30.11054505);
  }

  Future<void> _getScannedResults(BuildContext context) async {
    // Kayaknya udah ok lah yang ini
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
                  (accessPoints[i].ssid == "Griya Firdaus I NEW") |
                  (accessPoints[i].ssid == "AndroidWifi")) &
              savedAPs.contains(accessPoints[i].bssid) &
              // (accessPoints[i].bssid == '2c:73:a0:0f:26:ae') &  ini Lisdas
              (accessPoints[i].standard == WiFiStandards.ac)) {
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
                rssConvertOne(cacheLocationAP[cacheLocationAP.length - 1].rssi);
          }
        }
        setState(() => secureAPs = cacheSecureAP);
        setState(() => filteredAPs = cacheLocationAP);
        if (filteredAPs.length < 3) {
          print("not enough AP!");
          throw const FormatException("not enough AP's scanned!");
        }

        // print(cacheLocationAP[cacheLocationAP.length - 1].location);
        // print(cacheLocationAP[cacheLocationAP.length - 1].rssi);
        // print(filteredAPs[filteredAPs.length - 1].location);
      } on Exception catch (e) {
        print(e);
        throw Exception(e);
      }
      // List<mrx.Vector> target =
      //     _countTrila(p1, p2, p3, values[0], values[1], values[2]);
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

  // Convert Data Section

  Future<void> _convertData(BuildContext context) async {
    // ini nanti aja
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
      mrx.Vector.fromList([0, 0])
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

      convertComponent(column, row).then((value) {
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

  Future<List<mrx.Vector>> convertComponent(int column, int row) async {
    // ini nanti aja
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

      rssConvert(values);

      // target = await _countTrila(p1, p2, p3, values[0], values[1], values[2]);

      return target;
    } on Exception catch (e) {
      throw Exception(e);
    }
  }

  // Convert Data End

  Future<void> _trilaterationSequence(BuildContext context) async {
    excel.rename('Sheet1', 'Data');
    var sheetObject = excel['Data'];

    var column = docColumn + 1;

    // Writing real coordinates and labels

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

    mrx.Matrix target = mrx.Matrix.fromList([
      [0, 0, 0]
    ]);
    List<int> lengths = [];

    int counter = 0;
    int limit = 32;

    //Looping to get data every 1.5 seconds

    await Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1, milliseconds: 50));
      if (counter == limit) {
        return false;
      }

      setState(() => message = (counter + 1).toString());

      _startScan(context)
          .then((value) => _getScannedResults(context).then((value) {
                //Mulai dari 0 di luar loop dulu biar dideclare
                if (filteredAPs.length < 3) {
                  throw Exception();
                }
                mrx.Matrix points =
                    mrx.Matrix.fromList([filteredAPs[0].location.toList()]);

                List<List<num>> radii = [
                  [filteredAPs[0].distance!]
                ];

                List<List<num>> rss = [
                  [filteredAPs[0].rssi!]
                ];

                for (int i = 1; i < filteredAPs.length; i++) {
                  points = points.appendRows(
                      mrx.Matrix.fromList([filteredAPs[i].location.toList()]));
                  radii.add([filteredAPs[i].distance!]);
                  rss.add([filteredAPs[i].rssi!]);
                }

                trilateration(points, radii).then((value) {
                  target = value;
                  print(target[0]);
                  lengths.add(filteredAPs.length);

                  sheetObject
                      .cell(CellIndex.indexByColumnRow(
                          columnIndex: column, rowIndex: row))
                      .value = TextCellValue(target[0][0].toString());
                  sheetObject
                      .cell(CellIndex.indexByColumnRow(
                          columnIndex: column + 1, rowIndex: row))
                      .value = TextCellValue(target[1][0].toString());

                  int columning = 0;
                  for (int i = 0; i < filteredAPs.length; i++) {
                    if (!collectConstants) {
                      sheetObject
                          .cell(CellIndex.indexByColumnRow(
                              columnIndex: column + 2 + columning,
                              rowIndex: row))
                          .value = TextCellValue(" ${filteredAPs[i].bssid}");
                      sheetObject
                          .cell(CellIndex.indexByColumnRow(
                              columnIndex: column + 3 + columning,
                              rowIndex: row))
                          .value = TextCellValue(" ${filteredAPs[i].rssi}");
                      columning += 2;
                    } else {
                      if (filteredAPs[i].bssid == '24:36:da:9c:f4:ee') {
                        sheetObject
                            .cell(CellIndex.indexByColumnRow(
                                columnIndex: column + 2, rowIndex: row))
                            .value = TextCellValue(" ${filteredAPs[i].bssid}");
                        sheetObject
                            .cell(CellIndex.indexByColumnRow(
                                columnIndex: column + 3, rowIndex: row))
                            .value = TextCellValue(" ${filteredAPs[i].rssi}");
                        columning += 2;
                      }
                    }
                    // TextCellValue(
                    //     "${filteredAPs[i].bssid} || ${filteredAPs[i].rssi}");
                  }

                  // recent.appendRows(target);
                  recents =
                      "${target[0][0].toString()} ${target[1][0].toString()}";

                  // setState(() => lastCol = column + 4);
                }).then((value) {
                  row++;
                }).catchError((e) {
                  print(e);

                  sheetObject
                      .cell(CellIndex.indexByColumnRow(
                          columnIndex: column, rowIndex: row))
                      .value = TextCellValue('${e} not found');
                  row++;
                });
              }));

      counter++;

      return true;
    });
    setState(() {
      row += 3;
    });
  }

  Future<void> _justScan(BuildContext context) async {
    _startScan(context)
        .then((value) => _getScannedResults(context))
        .catchError((e) => print(e))
        .then((value) {
      if (filteredAPs.length < 3) {
        throw Exception();
      }
      mrx.Matrix points =
          mrx.Matrix.fromList([filteredAPs[0].location.toList()]);

      List<List<num>> radii = [
        [filteredAPs[0].distance!]
      ];

      List<List<num>> rss = [
        [filteredAPs[0].rssi!]
      ];

      for (int i = 1; i < filteredAPs.length; i++) {
        points = points.appendRows(
            mrx.Matrix.fromList([filteredAPs[i].location.toList()]));
        // print("${mrx.Matrix.fromList([
        //       filteredAPs[i].location.toList()
        //     ])} MANTAPPP");
        // print(points);
        radii.add([filteredAPs[i].distance!]);
        rss.add([filteredAPs[i].rssi!]);
      }

      trilateration(points, radii)
          .then((value) => print(value[0][0]))
          .catchError((e) => print(e));
    });
  }

  //TEESTTTT AGAAAINNN

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

  // END TEESSTT AGAAIIINNN

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
                label: "Experiment?",
                value: collectConstants,
                onChanged: (v) => setState(() => collectConstants = v),
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
                        onPressed: () => print('a'),
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
                    // TextButton(
                    //     onPressed: _prevColumn, child: const Text("Prev")),
                    Row(
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Row: $row  ||   ${row ~/ 32}-th Data"),
                      ],
                    ),
                    // TextButton(
                    //     onPressed: _nextColumn, child: const Text("Next")),
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
    List<String> savedAPs = [
      'b0:4e:26:9f:94:42',
      'b0:4e:26:9f:98:c2',
      '00:13:10:85:fe:01', // AndroidWifi
      '24:36:da:9c:f9:8e', // Lorong selatan barat  1
      '2c:73:a0:0f:28:2e', // S210                  2
      '2c:73:a0:0f:21:0e', // S211                  3
      '2c:73:a0:0f:1e:2e', // Lab IF                4
      '24:36:da:a3:52:6e', // Lorong selatan timur  5
      '24:36:da:9c:fb:0e', // S202                  6
      '24:36:da:a3:0b:ae', // Depan akademik        7
      '6c:b2:ae:69:94:ae', // Depan ElDas           8
      '2c:73:a0:0f:21:ae', // Eldas                 9
      '84:f1:47:8b:88:ee', // Samping Eldas         10
      '2c:73:a0:0f:26:ae', // LisDas                11
      '2c:73:a0:0f:28:0e', // N205                  12
      '2c:73:a0:0f:01:ae', // Lorong utara timur    13
      '24:36:da:9c:f4:ee', // N203                  14
      '24:36:da:9d:45:4e', // N201                  15
      '24:36:da:9d:56:8e', //S208                   16
      '84:f1:47:8b:91:8e', //S205                   17
    ];

    final title = accessPoint.ssid.isNotEmpty ? accessPoint.ssid : "**EMPTY**";
    final signalIcon = accessPoint.level >= -68
        ? Icons.signal_wifi_4_bar
        : Icons.signal_wifi_0_bar;
    return ListTile(
      tileColor: savedAPs.contains(accessPoint.bssid)
          ? Colors.greenAccent
          : Colors.amber,
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
