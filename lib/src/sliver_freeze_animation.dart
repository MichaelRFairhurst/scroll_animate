import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:scroll_animate/src/sliver_freeze.dart';

class SliverFreezeAnimation extends StatelessWidget {
  final Widget Function(BuildContext, double) builder;
  final double duration;

  SliverFreezeAnimation({
    required this.duration,
    required this.builder,
  });

  double getProgress(SliverConstraints constraints) {
    return constraints.scrollOffset.clamp(0.0, duration) / duration;
  }

  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        return SliverFreeze(
          duration: duration,
          child: builder(context, getProgress(constraints)),
        );
      },
    );
  }
}
