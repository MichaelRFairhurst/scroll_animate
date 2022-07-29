import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:scroll_animate/src/sliver_enter_exit_callback.dart';
import 'package:scroll_animate/src/sliver_entrance_animation_builder.dart';
import 'package:scroll_animate/src/entrance_policy.dart';

class SliverEntranceAnimation<T> extends StatefulWidget {

  EntrancePolicy? entrancePolicy;
  Widget Function(BuildContext, T animationValue, Widget?) builder;
  Widget? child;
  Duration duration;
  Animatable<T> tween;
  Curve curve;

  SliverEntranceAnimation({
    required this.builder,
    this.entrancePolicy,
    required this.duration,
    required this.tween,
    this.curve = Curves.linear,
    this.child,
  });

  SliverEntranceAnimationState<T> createState() => SliverEntranceAnimationState<T>();
}

class SliverEntranceAnimationState<T> extends State<SliverEntranceAnimation<T>> with SingleTickerProviderStateMixin {

  late final AnimationController _animationController;
  late final Animation<T> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = widget.tween.animate(CurvedAnimation(
        parent: _animationController,
        curve: widget.curve
      ));
  }

  @override
  void dispose() {
    _animationController.dispose();
  }

  @override
  bool didUpdateWidget(SliverEntranceAnimation oldWidget) {
    return widget.duration != oldWidget.duration
        || widget.tween != oldWidget.tween
        || widget.curve != oldWidget.curve;
  }

  @override
  Widget build(BuildContext context) {
    return SliverEntranceAnimationBuilder(
      controller: _animationController,
      entrancePolicy: widget.entrancePolicy,
      builder: (context, child) {
        return widget.builder(context, _animation.value, child);
      },
      child: widget.child,
    );
  }
}
