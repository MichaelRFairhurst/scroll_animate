import 'package:flutter/material.dart';
import 'package:example/rounded_box.dart';

class DemoHero extends StatelessWidget {
  final String text;
  final double height;
  final Color color;

  DemoHero({
    required this.text,
    required this.height,
    required this.color,
  });

  Widget build(BuildContext context) {
    return Hero(
      tag: text,
      child: Material(
        type: MaterialType.transparency,
        child: RoundedBox(
          text: text,
          height: height,
          color: color,
        ),
      ),
    );
  }
}
