import 'package:flutter/material.dart';
import 'package:scroll_animate/src/sliver_freeze_animation.dart';


/// A sliver that crossfades contents while frozen at the top of a scrollview.
///
/// The minimum necessary to use this widget is to provide two children; the
/// [first] and [second], and a duration. However, there may be issues sizing
/// the children, and for this reason there are a variety of sizing parameters
/// available as well.
///
/// The duration of the freeze is specified in pixels the user will have to
/// scroll before it becomes unfrozen.
class SliverFadeTransition extends StatelessWidget {
  final Widget first;
  final Widget second;
  final double duration;
  final Curve? curve;

  final Key? key;
  final double? height;
  final double? width;
  final BoxConstraints? constraints;
  final AlignmentGeometry? alignment;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  /// Create a [SliverFadeTransition].
  ///
  /// `duration`: The animation duration. This is specified in pixels that the
  /// user will have to scroll before the animation completes and the child
  /// widget is unfrozen.
  ///
  /// `first`: The first child shown before the widget is scrolled to the top
  /// of the scrollview.
  ///
  /// `second`: The child that will fade in when the widget is scrolled to the top
  /// of the scrollview, and replace `first`.
  ///
  /// `curve`: Optional. Set the animation curve, which is applied to animation
  /// progress just like a timed animation, except powered by scroll. Defaults
  /// to a linear curve.
  ///
  /// `height`: Optional. Used to constrain the size of both children at once.
  ///
  /// `width`: Optional. Used to constrain the size of both children at once.
  ///
  /// `constraints`: Optional. Used to constrain the size of both children at
  /// once.
  ///
  /// `alignment`: Optional. Align correctly when sizing parameters are used.
  ///
  /// `padding`: Optional. Provide padding to both children at once.
  ///
  /// `margin`: Optional. Provide padding to both children at once.
  SliverFadeTransition({
    required this.duration,
    required this.first,
    required this.second,
    this.curve,
    this.key,
    this.height,
    this.width,
    this.constraints,
    this.alignment,
    this.padding,
    this.margin,
  }) : super(key: key);

  Widget _contain(Widget child) => Container(
    height: height,
    width: width,
    constraints: constraints,
    alignment: alignment,
    padding: padding,
    margin: margin,
    child: child,
  );

  Widget build(BuildContext context) {
    return SliverFreezeAnimation<double>(
      duration: duration,
      curve: curve,
      tween: Tween<double>(begin: 1.0, end: 0.0),
      builder: (BuildContext, opacity) {
        return Stack(
          children: <Widget>[
            if (opacity != 1.0)
              _contain(second),
            Opacity(
              opacity: opacity,
              child: _contain(first),
            ),
          ],
        );
      },
    );
  }
}

