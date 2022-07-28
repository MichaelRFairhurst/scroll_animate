import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/animation.dart';
import 'package:scroll_animate/src/sliver_freeze_animation.dart';

class SliverFreezeResize extends StatelessWidget {
  final Animatable<double> mainAxisExtentTween;
  final Widget? child;
  final double duration;
  final Curve? curve;
  final Key? key;

  SliverFreezeResize({
    required this.duration,
    required this.mainAxisExtentTween,
    this.child,
    this.curve,
    this.key,
  });

  Widget build(BuildContext context) {
    return SliverFreezeAnimation<double>(
      key: key,
      duration: duration,
      curve: curve,
      tween: mainAxisExtentTween,
      builder: (context, extent) {
        return SizedBox(
          height: extent,
          width: extent,
          child: child,
        );
      },
    );
  }
}
