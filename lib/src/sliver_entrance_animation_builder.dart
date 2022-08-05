import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:scroll_animate/src/sliver_enter_exit_callback_wrapper.dart';
import 'package:scroll_animate/src/entrance_policy.dart';

/// A widget that drives an [AnimationController] when scrolling into view.
///
/// You must provide an [AnimationController]. This widget will listen to
/// that controller to know when to rebuild its contents based on the
/// provided `builder` function. When that widget enters and exits the
/// scrollview, it will drive the animation by calling `forward()` and
/// `reverse()` on that controller.
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
class SliverEntranceAnimationBuilder extends StatelessWidget {

  final AnimationController controller;
  final EntrancePolicy? entrancePolicy;
  final Widget Function(BuildContext, Widget?)? builder;
  final Widget Function(BuildContext, Widget?)? sliverBuilder;
  final Widget? child;

  /// Create a [SliverEntranceAnimationBuilder].
  ///
  /// `builder`: Build a regular (non-sliver) child with the latest animation
  /// value. Either `builder` or `sliverBuilder` must be provided.
  ///
  /// `sliverBuilder`: Build a sliver child with the latest animation value.
  /// Either `builder` or `sliverBuilder` must be provided.
  ///
  /// `entrancePolicy`: Optional. Sets the criteria for when a widget is
  /// considered to have entered or exited view. See [EntrancePolicy]. Defaults
  /// to firing whenever any part of the child is visible.
  ///
  /// `child`: Optional. This child will not be rebuilt when the animation value
  /// changes. Instead it will be passed into `builder` or `sliverBuilder`.
  SliverEntranceAnimationBuilder({
    required this.controller,
    this.builder,
    this.sliverBuilder,
    this.entrancePolicy,
    this.child,
  }) :
    assert(builder != null || sliverBuilder != null, "Must provide either a builder or sliver builder"),
    assert(builder == null || sliverBuilder == null, "Cannot provide both a builder and a sliver builder at the same time");

  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return SliverEnterExitCallbackWrapper(
          entrancePolicy: entrancePolicy,
          onEnter: () {
            controller.forward();
          },
          onExit: () {
            controller.reverse();
          },
          sliver: builder == null
            ? SliverToBoxAdapter(
                child: builder!(context, child),
              )
            : sliverBuilder!(context, child)
        );
      },
      child: child,
    );
  }
}
