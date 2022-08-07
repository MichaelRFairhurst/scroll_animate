import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/animation.dart';
import 'package:scroll_animate/src/sliver_suspended_animation.dart';

/// A sliver that resizes while suspended at the top of screen during scroll.
///
/// The size transition is defined by the `mainAxisExtentTween`, which
/// determines the size of the widget in the scrolling axis direction.
///
/// The child widget will be put in a `SizedBox` which changes size during
/// scroll.
///
/// Remember that with the right [Curve] and/or [Tween] it is possible to
/// create some highly dynamic effects, for instance, [TweenSequence].
///
/// The duration of the suspension is specified in pixels the user will have to
/// scroll before it becomes revitalized and scrolls again.
class SliverSuspendedResize extends StatelessWidget {

  final Animatable<double> mainAxisExtentTween;
  final Widget? child;
  final double duration;
  final Curve? curve;
  final Key? key;

  /// Create a [SliverSuspendedResize].
  ///
  /// `duration`: The animation duration. This is specified in pixels that the
  /// user will have to scroll before the animation completes and the child
  /// widget is revitalized and continues scrolling.
  ///
  /// `tween`: A tween to set the size of the child along the scroll axis. The
  /// begin value of the tween is used before the widget hits the top of the
  /// scroll view. There it will begin resizing to the end value before
  /// continuing to scroll off screen.
  ///
  /// `curve`: Optional. Set the animation curve, which is applied to animation
  /// progress just like a timed animation, except powered by scroll. Defaults
  /// to a linear curve.
  SliverSuspendedResize({
    required this.duration,
    required this.mainAxisExtentTween,
    this.child,
    this.curve,
    this.key,
  });

  Widget build(BuildContext context) {
    return SliverSuspendedAnimation<double>(
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
