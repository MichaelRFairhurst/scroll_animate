import 'package:flutter/widgets.dart';
import 'package:scroll_animate/src/shrink_flow.dart';

/// Performantly repaint a widget to animate after scrolling into view.
///
/// Much like the core flutter [Flow] widget, this will only let you animate
/// matrix transforms and opacity of the child widget. This allows flutter to
/// skip the layout stage of render for this subtree even as it animates.
///
/// Transformation matrices allow you to scale, rotate, and reposition the
/// child and more.
///
/// Takes a [Tween] for the transform and the opacity to determine the
/// animation, as well as a [Duration] and an optional [Curve]. The begin values
/// of the tween are used before the widget becomes visible, where it begins to
/// animate towards the end values.
///
/// Note that the translations do not effect the layout of this component and do
/// not affect how the visibility is checked.
///
/// Also takes an [Alignment] to determine the center point of the
/// transformation. This defaults to the center of the child. Also takes a
/// [Clip] behavior.
class EntranceAnimationFlow extends StatefulWidget {
  // TODO: support EntrancePolicy()
  final Widget child;
  final Animatable<Matrix4> transformTween;
  final Animatable<double> opacityTween;
  final Alignment transformAlignment;
  final Clip clipBehavior;
  final Duration duration;

  /// Create an [EntranceAnimationFlow] with tweens for opacity & transform.
  ///
  /// `transformTween`: Optional. Determines, if provided, how to transform this
  /// widget at paint time. By default no transformation is performed.
  ///
  /// `transformOpacity`: Optional. Determines, if provided, how opaque this
  /// widget should be when painted. By default, opacity is `1.0`.
  ///
  /// `curve`: Optional. Can be used to apply a curve to both the opacity and
  /// transformation animations. Defaults to a linear curve.
  ///
  /// `clipBehavior`: Optional. Sets the clipping behavior at paint time.
  /// Defaults to none.
  ///
  /// `transformAlignment`: Optional. Sets the center of the transformation, if
  /// any. Defaults to the center of the child.
  ///
  /// `duration`: Set the duration of the animation once the widget is visible.
  ///
  /// `child`: The child to animate at paint time.
  EntranceAnimationFlow({
    Key? key,
    required this.child,
    Animatable<double>? opacityTween,
    Animatable<Matrix4>? transformTween,
    required this.duration,
    this.transformAlignment = Alignment.center,
    this.clipBehavior = Clip.none,
  })
    : transformTween = transformTween ?? Matrix4Tween(begin: Matrix4.identity(), end: Matrix4.identity())
    , opacityTween = opacityTween ?? Tween(begin: 0.0, end: 1.0)
    , super(key: key);

  @override
  _EntranceAnimationFlowState createState() => _EntranceAnimationFlowState();
}

/// State for EntranceAnimationFlow which stores the animation controller.
///
/// This does *not* use setState(), as that would trigger rebuilds. The whole point
/// is to only perform repaints.
class _EntranceAnimationFlowState extends State<EntranceAnimationFlow> with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this);
  }

  void onPaint(BuildContext context, ScrollableState scrollable) {
    final scrollPositionFlowRenderObject = this.context.findRenderObject() as RenderBox;
    final scrollableRenderObject = scrollable.context.findRenderObject() as RenderBox;

    final offset = scrollPositionFlowRenderObject.localToGlobal(
        const Offset(0, 0),
        ancestor: scrollableRenderObject,
    );

    controller.duration = widget.duration;
    // TODO use EntrancePolicy
    if (offset.dy < -scrollPositionFlowRenderObject.size.height
        || offset.dy > scrollableRenderObject.size.height) {
      controller.reverse();
    } else {
      controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scrollable = Scrollable.of(context)!;
    return ShrinkFlow(
      child: widget.child,
      clipBehavior: widget.clipBehavior,
      delegate: _EntranceAnimationFlowDelegate(
        onPaint: () {
          onPaint(context, scrollable);
        },
        transformTween: widget.transformTween,
        opacityTween: widget.opacityTween,
        transformAlignment: widget.transformAlignment,
        animation: controller,
      ),
    );
  }
}

class _EntranceAnimationFlowDelegate extends FlowDelegate {
  final Animatable<Matrix4> transformTween;
  final Animatable<double> opacityTween;
  final Alignment transformAlignment;
  final Animation<double> animation;
  final void Function() onPaint;

  _EntranceAnimationFlowDelegate({
    required this.transformTween,
    required this.opacityTween,
    required this.transformAlignment,
    required this.animation,
    required this.onPaint,
  }) : super(repaint: animation);

  @override
  Size getSize(BoxConstraints constraints) => const Size(0, 0);

  @override
  void paintChildren(FlowPaintingContext context) {
    onPaint();
    context.paintChild(
      0,
      opacity: opacityTween.transform(animation.value),
      transform: transformTween.transform(animation.value),
    );
  }

  @override
  bool shouldRepaint(covariant FlowDelegate oldDelegate) {
    // TODO: is this right?
    return true;
  }
}

