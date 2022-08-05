import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:scroll_animate/src/sliver_enter_exit_callback.dart';
import 'package:scroll_animate/src/sliver_entrance_animation_builder.dart';
import 'package:scroll_animate/src/entrance_policy.dart';

/// A Widget that performs an animation when it enters/exits a scroll view.
///
/// The type parameter [T] refers to the type of the value that is being
/// animated. For instance, to animate opacity you would construct a
/// `SliverEntranceAnimation<double>`.
///
/// The value will be animated through a range based on the provided tween,
/// and as the value changes, the [builder] function will be invoked with the
/// current value to create the widget that is rendered.
/// 
/// To change the criteria for when a widget is considered to have entered, see
/// `EntrancePolicy`. Defaults to animating whenever any part of the child has
/// become visible.
/// 
/// For performance reasons, you may specify a `child` widget which is not
/// rebuilt on animation. This is then passed into the `builder` callback.
/// 
/// To wrap another sliver (instead of a non-sliver Box widget)  with an
/// entrance animation, provide a `sliverBuilder` callback instead of a
/// `builder` callback.
///
/// To use your own animation controller, use [SliverEntranceAnimationBuilder].
class SliverEntranceAnimation<T> extends StatefulWidget {

  final EntrancePolicy? entrancePolicy;
  final Widget Function(BuildContext, T animationValue, Widget?)? builder;
  final Widget Function(BuildContext, T animationValue, Widget?)? sliverBuilder;
  final Widget? child;
  final Duration duration;
  final Animatable<T> tween;
  final Curve curve;

  /// Create a [SliverEntranceAnimation].
  ///
  /// `builder`: Build a regular (non-sliver) child with the latest animation
  /// value. Either `builder` or `sliverBuilder` must be provided.
  ///
  /// `sliverBuilder`: Build a sliver child with the latest animation value.
  /// Either `builder` or `sliverBuilder` must be provided.
  ///
  /// `duration`: The animation duration.
  ///
  /// `tween`: A tween to set the range of the animation value. The begin value
  /// of the tween is used before the widget enters. On enter it will animate
  /// to the end value of this tween.
  ///
  /// `curve`: Optional. Set the animation curve. Defaults to a linear curve.
  ///
  /// `entrancePolicy`: Optional. Sets the criteria for when a widget is
  /// considered to have entered or exited view. See [EntrancePolicy]. Defaults
  /// to firing whenever any part of the child is visible.
  ///
  /// `child`: Optional. This child will not be rebuilt when the animation value
  /// changes. Instead it will be passed into `builder` or `sliverBuilder`.
  SliverEntranceAnimation({
    this.builder,
    this.sliverBuilder,
    this.entrancePolicy,
    required this.duration,
    required this.tween,
    this.curve = Curves.linear,
    this.child,
  }) :
    assert(builder != null || sliverBuilder != null, "Must provide either a builder or sliver builder"),
    assert(builder == null || sliverBuilder == null, "Cannot provide both a builder and a sliver builder at the same time");

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
        if (widget.builder != null) {
          return SliverToBoxAdapter(
            child: widget.builder!(context, _animation.value, child)
          );
        } else {
          return widget.sliverBuilder!(context, _animation.value, child);
        }
      },
      child: widget.child,
    );
  }
}
