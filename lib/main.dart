import 'dart:async';
import 'dart:math';
import 'dart:io';

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
  StreamSubscription<List<WiFiAccessPoint>>? subscription;
  bool shouldCheckCan = true;
  bool get isStreaming => subscription != null;

  String message = 'Press create, enter real coordinates, Get Data, then Save';
  List<double> realCoordinate = [0, 0];

  int docColumn = 0;
  int lastCol = 0;

  var excel = Excel.createExcel();

  void _excelCreate(BuildContext context) async {
    excel.rename('Sheet1', 'Data');
    setState(() => message = "Excel Created (not saved)");
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
    }
    var fileBytes = excel.save();
    var directory = 'storage/emulated/0/Download/Trilateration_Data.xlsx';

    setState(() => message = "Saved! in $directory");

    File(directory)
      ..createSync(recursive: true)
      ..writeAsBytesSync(fileBytes!);
  }

  List<mrx.Vector> _countTrila(
      mrx.Vector p1, mrx.Vector p2, mrx.Vector p3, num r1, num r2, num r3) {
    mrx.Vector point1 = mrx.Vector.fromList([0, 0, 0]);
    mrx.Vector point2 =
        mrx.Vector.fromList([p2[0] - p1[0], p2[1] - p1[1], p2[2] - p1[2]]);
    mrx.Vector point3 =
        mrx.Vector.fromList([p3[0] - p1[0], p2[1] - p3[1], p3[2] - p1[2]]);
    mrx.Vector v1 = point2 - point1;
    mrx.Vector v2 = point3 - point1;

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
    mrx.Vector k2 = point1 + xn * x + yn * y - zn * z2;

    // print(k1);
    // print(k2);

    return [k1, k2];
  }

  List<num> _rssConvert(List<num> rss) {
    var nice = <num>[];
    for (int i = 0; i < rss.length; i++) {
      nice.add(pow(e, (rss[i] + 36.03007262) / -9.73267397));
    }
    return nice;
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

  Future<List<mrx.Vector>> _getScannedResults(BuildContext context) async {
    if (await _canGetScannedResults(context)) {
      // get scanned results
      final results = await WiFiScan.instance.getScannedResults();
      setState(() => accessPoints = results);
      List<num> values = _getRSSValues();
      // print(values);
      values = _rssConvert(values);
      // print(values);

      // print("Getscanned");

      var p1 = mrx.Vector.fromList([0, 0, 0]);
      var p2 = mrx.Vector.fromList([10, 0, 0]);
      var p3 = mrx.Vector.fromList([5.097, 5, 0]);
      // double r1 = 1;
      // double r2 = 2;
      // double r3 = 1.5;

      List<mrx.Vector> target =
          _countTrila(p1, p2, p3, values[0], values[1], values[0]);

      // print(target);
      return target;
    } else {
      throw Error();
    }
  }

  void _nextColumn() {
    setState(() => docColumn += 7);
  }

  void _prevColumn() {
    setState(() => docColumn -= 7);
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
    sheetObject
        .cell(CellIndex.indexByColumnRow(
            columnIndex: docColumn + 3, rowIndex: row - 1))
        .value = const TextCellValue("x");
    sheetObject
        .cell(CellIndex.indexByColumnRow(
            columnIndex: docColumn + 4, rowIndex: row - 1))
        .value = const TextCellValue("y");

    List<mrx.Vector> target = [
      mrx.Vector.fromList([0, 0, 0])
    ];

    int counter = 0;
    int limit = 22;
    // print("first counterr $counter");

    await Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1, milliseconds: 50));
      if (counter == limit) {
        // print("limitttt");
        return false;
      }

      setState(() => message = counter.toString());

      _startScan(context).then((value) => _getScannedResults(context)
              .then((value) => target = value)
              .then((value) {
            // print(target);
            sheetObject
                .cell(CellIndex.indexByColumnRow(
                    columnIndex: column, rowIndex: row))
                .value = DoubleCellValue(target[0][0].toDouble());
            sheetObject
                .cell(CellIndex.indexByColumnRow(
                    columnIndex: column + 1, rowIndex: row))
                .value = DoubleCellValue(target[0][1].toDouble());
            sheetObject
                .cell(CellIndex.indexByColumnRow(
                    columnIndex: column + 2, rowIndex: row))
                .value = DoubleCellValue(target[1][0].toDouble());
            sheetObject
                .cell(CellIndex.indexByColumnRow(
                    columnIndex: column + 3, rowIndex: row))
                .value = DoubleCellValue(target[1][1].toDouble());
            sheetObject
                .cell(CellIndex.indexByColumnRow(
                    columnIndex: column + 4, rowIndex: row))
                .value = TextCellValue(_getRSSValues()[2].toString());
            setState(() => lastCol = column + 4);
          }).then((value) {
            row++;
          }));

      counter++;
      // print("continueee");
      return true;
    });
    _nextColumn();
  }

  Future<void> _testLoop(BuildContext context) async {
    List<int> test = [1, 2, 3];
    for (int i = 0; i < 3; i++) {
      print("$i ==========");
      print(test[i]);
    }
  }

  // Future<void> _startListeningToScanResults(BuildContext context) async {
  //   if (await _canGetScannedResults(context)) {
  //     subscription = WiFiScan.instance.onScannedResultsAvailable
  //         .listen((result) => setState(() => accessPoints = result));
  //   }
  // }

  // void _stopListeningToScanResults() {
  //   subscription?.cancel();
  //   setState(() => subscription = null);
  // }

  List<int> _getRSSValues() {
    if (accessPoints.isEmpty) {
      print("Empty Wifi List");
      throw ErrorDescription("WiFi List Empty!");
    }
    List<String> apBssid = [
      "f8:75:88:c4:c5:a4", //Sibayak
      "82:8f:c8:09:86:80", //Note 11
      "66:48:4d:10:ae:d5", //Redmi Note 11
      // 'test'
    ];
    print(apBssid.length);
    var mantapp = <WiFiAccessPoint>[];
    var rssValue = <int>[];
    // print(apBssid[2]);
    // print(apBssid.length);

    for (int i = 0; i < apBssid.length; i++) {
      // print("$i ======== mantapp");
      // print(apBssid[i]);
      mantapp.add(
          accessPoints.firstWhere((element) => element.bssid == apBssid[2]));
    }

    for (int i = 0; i < apBssid.length; i++) {
      // print(mantapp[i].level);
      rssValue.add(mantapp[i].level);
      // print(rssValue);
    }
    return rssValue;
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
                IconButton(
                  onPressed: () => _getRSSValues(),
                  icon: const Icon(Icons.texture_sharp),
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
                        onPressed: _prevColumn,
                        child: const Text("Prev Point")),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Current Column Data: $docColumn"),
                        Text("Last Data Column: $lastCol"),
                      ],
                    ),
                    TextButton(
                        onPressed: _nextColumn,
                        child: const Text("Next Point")),
                  ],
                ),
                Text(message),
                Flexible(
                  child: Center(
                    child: accessPoints.isEmpty
                        ? const Text("NO SCANNED RESULTS")
                        : ListView.builder(
                            itemCount: accessPoints.length,
                            itemBuilder: (context, i) =>
                                _AccessPointTile(accessPoint: accessPoints[i])),
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
    final signalIcon = accessPoint.level >= -80
        ? Icons.signal_wifi_4_bar
        : Icons.signal_wifi_0_bar;
    return ListTile(
      visualDensity: VisualDensity.compact,
      leading: Icon(signalIcon),
      title: Text(title),
      subtitle: Text(accessPoint.level.toString()),
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
