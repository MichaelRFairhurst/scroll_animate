import 'dart:math';
import 'package:flutter/material.dart';

final colors = <Color>[
  Color(0xFF028E9E),
  Color(0xFF7BCF55),
  Color(0xFFD17452),
  Color(0xFF34D8EB),
  Color(0xFFABA693),
  Color(0xFFB57D9F),
  Color(0xFFC9AA2C),
  Color(0xFF6F70B3),
  Color(0xFF8C4971),
  Color(0xFF4748A1),
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

