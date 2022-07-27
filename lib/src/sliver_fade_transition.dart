import 'package:flutter/material.dart';
import 'package:scroll_animate/src/sliver_freeze_animation.dart';

class SliverFadeTransition extends StatelessWidget {
  final Widget first;
  final Widget second;
  final double duration;
  final Curve? curve;

  final Key? key;
  final double? height;
  final double? width;
  final BoxConstraints? constraints;
  final AlignmentGeometry? alignment;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  SliverFadeTransition({
    required this.duration,
    required this.first,
    required this.second,
    this.curve,
    this.key,
    this.height,
    this.width,
    this.constraints,
    this.alignment,
    this.padding,
    this.margin,
  });

  Widget build(BuildContext context) {
    return SliverFreezeAnimation<double>(
      key: key,
      duration: duration,
      curve: curve,
      tween: Tween<double>(begin: 1.0, end: 0.0),
      builder: (BuildContext, opacity) {
        return Container(
          height: height,
          width: width,
          constraints: constraints,
          alignment: alignment,
          padding: padding,
          margin: margin,
          child: Stack(
            children: <Widget>[
              if (opacity != 1.0)
                second,
              Opacity(
                opacity: opacity,
                child: first,
              ),
            ],
          ),
        );
      },
    );
  }
}

