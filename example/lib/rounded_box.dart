import 'dart:math';
import 'package:flutter/material.dart';

final colors = <Color>[
  //Color(0xFFD97E98),
  //Color(0xFFB47ED9),
  //Color(0xFF797BD9),
  //Color(0xFF7CBAD9),
  //Color(0xFF77D9CD),
  //Color(0xFFB0D4B0),
  //Color(0xFF7FD977),
  //Color(0xFF6DC773),
  //Color(0xFFCFD979),
  //Color(0xFFD9A464),
  //Color(0xFFD67776),

  Color(0xFF7CBAD9),
  Color(0xFFCFD979),
  Color(0xFF77D9CD),
  //Color(0xFFD97E98),
  Color(0xFF797BD9),
  Color(0xFFD9A464),
  Color(0xFF6DC773),
  Color(0xFFD67776),
  Color(0xFFB47ED9),
  Color(0xFFB0D4B0),
  Color(0xFF7FD977),
];

class Palette {
  final Random random = Random();
  late int colorIndex;

  Palette() {
    colorIndex = random.nextInt(colors.length);
  }

  Color nextColor() => colors[colorIndex++ % colors.length];
}

class RoundedBox extends StatelessWidget {
  final double? height;
  final double? width;
  final double? fontSize;
  final Color color;
  final String? text;

  RoundedBox({
    this.height,
    this.width,
    required this.color,
    this.text,
    this.fontSize,
  });

  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      margin: EdgeInsets.all(16.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
      ),
      child: Center(
        child: Text(
          text ?? "",
          style: TextStyle(fontSize: fontSize ?? 16, fontFamily: "monospace"),
        ),
      ),
    );
  }
}

