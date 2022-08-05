import 'package:flutter/material.dart';
import 'package:scroll_animate/src/sliver_freeze_animation.dart';

/// A sliver that swipes between contents while frozen at the top of a scroll.
///
/// The minimum necessary to use this widget is to provide two children; the
/// [first] and [second], and a duration. However, there may be issues sizing
/// the children, and for this reason there are a variety of sizing parameters
/// available as well.
///
/// The duration of the slide is specified in pixels the user will have to
/// scroll before it becomes unfrozen.
class SliverSlideTransition extends StatelessWidget {
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


  /// Create a [SliverSlideTransition].
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
  SliverSlideTransition({
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
  });

  Widget build(BuildContext context) {
    return SliverFreezeAnimation<double>(
      duration: duration,
      curve: curve,
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, progress) {
        return Container(
          height: height,
          width: width,
          constraints: constraints,
          alignment: alignment,
          padding: padding,
          margin: margin,
          child: Flow(
            delegate: _SliverSlideTransitionFlowDelegate(
              progress,
            ),
            children: <Widget>[
              first,
              second,
            ],
          ),
        );
      },
    );
  }
}

class _SliverSlideTransitionFlowDelegate extends FlowDelegate {
  final double progress;

  _SliverSlideTransitionFlowDelegate(this.progress);

  @override
  void paintChildren(FlowPaintingContext context) {
    final width = context.size.width;
    context.paintChild(0, transform: Matrix4.translationValues(-width * progress, 0, 0));
    context.paintChild(1, transform: Matrix4.translationValues(width -width * progress, 0, 0));
  }

  @override
  bool shouldRepaint(_SliverSlideTransitionFlowDelegate newDelegate)
      => newDelegate.progress != progress;
}
