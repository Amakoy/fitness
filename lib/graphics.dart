import 'package:flutter/material.dart';
import 'package:matrix_utils/matrix_utils.dart' as mrx
    hide MatrixFunctions, Column;

import './main.dart';

class HouseBlueprint extends StatelessWidget {
  List<WifiLocation> apLocationList;
  mrx.Matrix target;
  HouseBlueprint(
      {super.key, required this.apLocationList, required this.target});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(294, 254.5), // Specify the size of the canvas
      painter: BlueprintPainter(apLocationList, target),
    );
  }
}

class BlueprintPainter extends CustomPainter {
  List<WifiLocation> apLocationList;
  mrx.Matrix target;
  BlueprintPainter(this.apLocationList, this.target);

  List<List<double>> points = [
    [13, 13.1],
    [16.5, 17.7],
    [20, 17.8],
    [20.5, 4.8],
    [42.8, 13.1],
    [37.2, 16.6],
    [28.2, 24.4],
    [23.8, 31.8],
    [27.5, 43.2],
    [32.2, 43.8],
    [46.8, 43.8],
    [57.1, 40.8],
    [46.4, 36.8],
    [46.9, 32],
    [32.4, 32],
    [7, 10.2],
    [34.5, 11.5]
  ];

  @override
  void paint(Canvas canvas, Size size) {
    // Define your paint
    final paint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final paintWhite = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final paint2 = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;
    final paint3 = Paint()
      ..color = Colors.blue
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    final paintTarget = Paint()
      ..color = Colors.orange
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    //Kotak keliling, putih nutupin yang nggak perlu
    canvas.drawRect(const Rect.fromLTWH(0, 0, 294, 254.5), paint);
    canvas.drawLine(const Offset(0, 148.5), const Offset(0, 0), paintWhite);
    canvas.drawLine(const Offset(0, 0), const Offset(112, 0), paintWhite);
    canvas.drawLine(
        const Offset(294, 108.5), const Offset(294, 254.5), paintWhite);
    canvas.drawLine(
        const Offset(294, 254.5), const Offset(253, 254.5), paintWhite);
    // Selatan bawah
    canvas.drawRect(const Rect.fromLTWH(0, 290 - 95.5, 41, 60), paint);
    canvas.drawRect(const Rect.fromLTWH(41, 290 - 95.5, 36, 60), paint);
    canvas.drawRect(const Rect.fromLTWH(77, 290 - 95.5, 70, 60), paint);
    canvas.drawRect(const Rect.fromLTWH(147, 290 - 95.5, 37, 60), paint);
    canvas.drawRect(const Rect.fromLTWH(184, 290 - 95.5, 69, 60), paint);

    // Selatan atas
    canvas.drawRect(const Rect.fromLTWH(0, 244 - 95.5, 20, 35), paint);
    canvas.drawLine(
        const Offset(0, 244 - 95.5), const Offset(42, 244 - 95.5), paint);
    canvas.drawRect(const Rect.fromLTWH(42, 244 - 95.5, 47, 35), paint);
    canvas.drawRect(const Rect.fromLTWH(89, 244 - 95.5, 23, 35), paint);
    canvas.drawLine(
        const Offset(130, 279 - 95.5), const Offset(253, 279 - 95.5), paint);
    canvas.drawLine(
        const Offset(130, 279 - 95.5), const Offset(130, 244 - 95.5), paint);
    canvas.drawLine(
        const Offset(130, 244 - 95.5), const Offset(149.5, 244 - 95.5), paint);
    canvas.drawLine(const Offset(149.5, 244 - 95.5),
        const Offset(149.5, 226.5 - 95.5), paint);
    canvas.drawLine(const Offset(149.5, 226.5 - 95.5),
        const Offset(185.5, 226.5 - 95.5), paint);
    canvas.drawLine(const Offset(185.5, 226.5 - 95.5),
        const Offset(185.5, 278.5 - 95.5), paint);
    canvas.drawLine(
        const Offset(185.5, 226.5 - 95.5), const Offset(185.5, 108.5), paint);
    canvas.drawLine(const Offset(209.5, 244 - 95.5),
        const Offset(209.5, 278.5 - 95.5), paint);
    canvas.drawLine(
        const Offset(185.5, 244 - 95.5), const Offset(253, 244 - 95.5), paint);
    canvas.drawLine(const Offset(219.5, 278.5 - 95.5),
        const Offset(219.5, 289.5 - 95.5), paint);
    canvas.drawLine(
        const Offset(253, 148.5), const Offset(253, 290 - 95.5), paint);

    //Tengah
    canvas.drawLine(
        const Offset(112, 244 - 95.5), const Offset(112, 161 - 95.5), paint);

    //Utara atas
    canvas.drawLine(const Offset(111.5, 66), const Offset(294, 66), paint);
    canvas.drawLine(const Offset(112, 66), const Offset(112, 0), paint);
    // canvas.drawLine(
    //     const Offset(149.5, 66), const Offset(149.5, 0), paint2);
    // canvas.drawLine(const Offset(171, 66), const Offset(171, 0), paint2);
    canvas.drawLine(const Offset(189.5, 66), const Offset(189.5, 0), paint);
    // canvas.drawLine(const Offset(207, 66), const Offset(207, 0), paint2);
    canvas.drawLine(const Offset(253.5, 66), const Offset(253.5, 0), paint);
    canvas.drawLine(const Offset(274.5, 66), const Offset(274.5, 0), paint);

    //Utara bawah
    canvas.drawLine(const Offset(129.5, 76), const Offset(252.5, 76), paint);
    canvas.drawLine(
        const Offset(129.5, 108.5), const Offset(252.5, 108.5), paint);
    canvas.drawLine(const Offset(129.5, 108.5), const Offset(129.5, 76), paint);
    canvas.drawLine(const Offset(170, 108.5), const Offset(170, 76), paint);
    canvas.drawLine(const Offset(218.5, 108.5), const Offset(218.5, 76), paint);
    canvas.drawLine(const Offset(252.5, 108.5), const Offset(252.5, 76), paint);
    canvas.drawLine(const Offset(274, 108.5), const Offset(274, 76), paint);
    canvas.drawLine(const Offset(274, 76), const Offset(294, 76), paint);
    canvas.drawLine(
        const Offset(252.5, 108.5), const Offset(294, 108.5), paint);

    // Access Points
    for (var element in points) {
      canvas.drawCircle(
          Offset((element[0] * 10 / 2) + 1, (254.5 - (element[1] * 10 / 2))),
          2,
          paint2);
    }
    apLocationList.forEach((element) {
      canvas.drawCircle(
          Offset((element.location[0] * 10 / 2) + 1,
              (254.5 - (element.location[1] * 10 / 2))),
          element.distance!.toDouble() * 10 / 2,
          paint3);
    });
    if (target[0][0] != 0) {
      // print(target.toList());
      canvas.drawCircle(
          Offset(
              (target[0][0] * 10 / 2) + 1, (254.5 - (target[1][0] * 10 / 2))),
          2,
          paint2..color = Colors.orange);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
