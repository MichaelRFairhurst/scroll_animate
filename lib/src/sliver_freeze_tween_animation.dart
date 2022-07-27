import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/animation.dart';
import 'package:scroll_animate/src/sliver_freeze.dart';

class SliverFreezeTweenAnimation<T> extends StatelessWidget {
  final Widget Function(BuildContext, T) builder;
  final double duration;
  final Animatable<T> tween;
  final Curve curve;
  final Key? key;

  SliverFreezeAnimation({
    required this.duration,
    required this.builder,
    required this.tween,
    Curve? curve,
    this.key,
  }) :
    curve = curve ?? Curves.linear;

  T getValue(SliverConstraints constraints) {
    final baseProgress = constraints.scrollOffset.clamp(0.0, duration) / duration;
    return tween.transform(curve.transform(baseProgress));
  }

  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      key: key,
      builder: (context, constraints) {
        return SliverFreeze(
          duration: duration,
          child: builder(context, getValue(constraints)),
        );
      },
    );
  }
}
