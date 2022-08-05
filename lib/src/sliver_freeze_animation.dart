import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/animation.dart';
import 'package:scroll_animate/src/sliver_freeze.dart';

/// A sliver that animates while frozen at the top of screen during scroll.
///
/// Can be an especially nice effect when the widget is set to match the size of
/// the screen, creating a sort of `PageView` effect, with feedback between
/// "pages."
///
/// The type parameter [T] refers to the type of the value that is being
/// animated. For instance, to animate opacity you would construct a
/// `SliverFreezeAnimation<double>`.
///
/// The value will be animated through a range based on the provided tween,
/// and as the value changes, the [builder] function will be invoked with the
/// current value to create the widget that is rendered.
///
/// The duration of the freeze is specified in pixels the user will have to
/// scroll before it becomes unfrozen.
class SliverFreezeAnimation<T> extends StatelessWidget {
  final Widget Function(BuildContext, T) builder;
  final double duration;
  final Animatable<T> tween;
  final Curve curve;

  /// Create a [SliverFreezeAnimation].
  ///
  /// `builder`: Build the rendered contents with the latest animation value.
  ///
  /// `duration`: The animation duration. This is specified in pixels that the
  /// user will have to scroll before the animation completes and the child
  /// widget is unfrozen.
  ///
  /// `tween`: A tween to set the range of the animation value. The begin value
  /// of the tween is used before the widget hits the top of the scroll view. As
  /// it is frozen it will animate to the end value of this tween before
  /// unfreezing.
  ///
  /// `curve`: Optional. Set the animation curve, which is applied to animation
  /// progress just like a timed animation, except powered by scroll. Defaults
  /// to a linear curve.
  SliverFreezeAnimation({
    required this.duration,
    required this.builder,
    required this.tween,
    Curve? curve,
    Key? key,
  }) :
    curve = curve ?? Curves.linear,
    super(key: key);

  /// Transform the scroll offset into progress which is transformed be the tween
  /// and the curve to get the animation value.
  T getValue(SliverConstraints constraints) {
    final baseProgress = constraints.scrollOffset.clamp(0.0, duration) / duration;
    return tween.transform(curve.transform(baseProgress));
  }

  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        return SliverFreeze(
          duration: duration,
          child: builder(context, getValue(constraints)),
        );
      },
    );
  }
}
