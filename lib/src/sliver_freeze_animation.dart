import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/animation.dart';
import 'package:scroll_animate/src/sliver_freeze.dart';

class SliverFreezeAnimation extends StatelessWidget {
  final Widget Function(BuildContext, double) builder;
  final double duration;
  final Curve curve;
  final Key? key;

  SliverFreezeAnimation({
    required this.duration,
    required this.builder,
    Curve? curve,
    this.key,
  }) :
    curve = curve ?? Curves.linear;

  double getProgress(SliverConstraints constraints) {
    return curve.transform(constraints.scrollOffset.clamp(0.0, duration) / duration);
  }

  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      key: key,
      builder: (context, constraints) {
        return SliverFreeze(
          duration: duration,
          child: builder(context, getProgress(constraints)),
        );
      },
    );
  }
}
