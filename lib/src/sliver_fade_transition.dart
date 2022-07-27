import 'package:flutter/material.dart';
import 'package:scroll_animate/src/sliver_freeze_animation.dart';

class SliverFadeTransition extends StatelessWidget {
  final Widget first;
  final Widget second;
  final double duration;

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
    this.key,
    this.height,
    this.width,
    this.constraints,
    this.alignment,
    this.padding,
    this.margin,
  });

  Widget build(BuildContext context) {
    return SliverFreezeAnimation(
      key: key,
      duration: duration,
      builder: (BuildContext, progress) {
        return Container(
          height: height,
          width: width,
          constraints: constraints,
          alignment: alignment,
          padding: padding,
          margin: margin,
          child: Stack(
            children: <Widget>[
              if (progress != 0.0)
                second,
              Opacity(
                opacity: 1.0 - progress,
                child: first,
              ),
            ],
          ),
        );
      },
    );
  }
}

