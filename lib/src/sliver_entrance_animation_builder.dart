import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:scroll_animate/src/sliver_enter_exit_callback.dart';
import 'package:scroll_animate/src/entrance_policy.dart';

class SliverEntranceAnimationBuilder extends StatelessWidget {

  AnimationController controller;
  EntrancePolicy? entrancePolicy;
  Widget Function(BuildContext, Widget?) builder;
  Widget? child;

  SliverEntranceAnimationBuilder({
    required this.controller,
    required this.builder,
    this.entrancePolicy,
    this.child,
  });

  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return SliverEnterExitCallback(
          entrancePolicy: entrancePolicy,
          onEnter: () {
            controller.forward();
          },
          onExit: () {
            controller.reverse();
          },
          child: builder(context, child),
        );
      },
      child: child,
    );
  }
}
