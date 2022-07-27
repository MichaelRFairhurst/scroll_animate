import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/animation.dart';
import 'package:scroll_animate/src/sliver_freeze_animation.dart';

class SliverFreezeResize extends StatelessWidget {
  final Animatable<Size?> sizeTween;
  final Widget? child;
  final double duration;
  final Curve? curve;
  final Key? key;

  SliverFreezeResize({
    required this.duration,
    required this.sizeTween,
    this.child,
    this.curve,
    this.key,
  });

  Widget build(BuildContext context) {
    return SliverFreezeAnimation<Size?>(
      key: key,
      duration: duration,
      curve: curve,
      tween: sizeTween,
      builder: (context, size) {
        return SizedBox(
          height: size!.height,
          width: size.width,
          child: child,
        );
      },
    );
  }
}
