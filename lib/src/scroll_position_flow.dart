import 'package:flutter/widgets.dart';
import 'package:scroll_animate/src/parent_offset_flow.dart';
import 'package:scroll_animate/src/scroll_range.dart';

/// Performantly repaint a widget to animate based on scroll progress.
///
/// Much like the core flutter [Flow] widget, this will only let you animate
/// matrix transforms and opacity of the child widget. This allows flutter to
/// skip the layout stage of render for this subtree even as it animates.
///
/// Transformation matrices allow you to scale, rotate, and reposition the
/// child and more. Factory constructors [ScrollPositionFlow.animateScale] and
/// [ScrollPositionFlow.animateTranslate] can build these matrices for you.
///
/// The next most useful factory constructor is [ScrollPositionFlow.animate],
/// which takes a [Tween] for the transform and the opacity, and the scroll
/// progress will be used (along with an optional [Curve]) to get the opacity
/// and transform from these tweens.
///
/// By default, when the widget has barely appeared on screen the animation is
/// started at 0% progress, and reaches 100% progress when it is fully scrolled
/// off the top of the scroll view. To customize this behavior, provide a
/// [ScrollRange].
///
/// Different [ScrollRange]s can change the top to 100% and the bottom to 0%,
/// or they can make part of the middle 100% while the top and bottom are 0%,
/// and they can change what's considered the top and bottom. There are existing
/// [ScrollRange]s defined and they have methods to tweak them, or you can write
/// your own from scratch.
///
/// Note that the translations do not effect the layout of this component and do
/// not affect how the [ScrollRange] progress is calculated.
///
/// All constructors also take an [Alignment] to determine the center point of
/// the transformation. This defaults to the center of the child. They also take
/// a [Clip] behavior.
///
/// The default constructor takes a pair of functions to arbitrarily build any
/// opacity or transforms based on scroll progress, instead of [Tween]s.
class ScrollPositionFlow extends StatelessWidget {
  final Matrix4 Function(double)? buildTransform;
  final double Function(double)? buildOpacity;
  final Curve curve;
  final Clip clipBehavior;
  final ScrollRange scrollRange;
  final Alignment transformAlignment;
  final Widget child;

  /// Create a [ScrollPositionFlow] with completely custom calculations.
  ///
  /// Generally, it is preferred to use one of the factory constructors such as
  /// [ScrollPositionFlow.animate].
  const ScrollPositionFlow({
    Key? key,
    this.buildTransform,
    this.buildOpacity,
    Curve? curve,
    Clip? clipBehavior,
    ScrollRange? scrollRange,
    Alignment? transformAlignment,
    required this.child,
  })
    : curve = curve ?? Curves.linear
    , clipBehavior = clipBehavior ?? Clip.none
    , transformAlignment = transformAlignment ?? Alignment.center
    , scrollRange = scrollRange ?? const FullScrollRange()
    , super(key: key);

  /// Create a [ScrollPositionFlow] with tweens for opacity & transformation.
  ///
  /// If the [transformTween] is performing a scale operation or translation,
  /// consider using [ScrollPositionFlow.animateScale] or
  /// [ScrollPositionFlow.animateTranslate]. Note that these constructors can
  /// still animate opacity as well.
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
  /// `scrollRange`: Optional. Used to determine the scroll progress based on this
  /// widget's size and position within the scroll viewport. Defaults to the full
  /// scroll range. See [ScrollRange] for more.
  ///
  /// `child`: The child to animate at paint time.
  factory ScrollPositionFlow.animate({
    Key? key,
    Animatable<Matrix4>? transformTween,
    Animatable<double>? opacityTween,
    Curve? curve,
    Clip? clipBehavior,
    Alignment? transformAlignment,
    ScrollRange? scrollRange,
    required Widget child,
  }) {
    return ScrollPositionFlow(
      key: key,
      buildTransform: (progress) => transformTween?.transform(progress) ?? Matrix4.identity(),
      buildOpacity: (progress) => opacityTween?.transform(progress) ?? 1.0,
      curve: curve,
      clipBehavior: clipBehavior,
      transformAlignment: transformAlignment,
      scrollRange: scrollRange,
      child: child,
    );
  }

  /// Create a [ScrollPositionFlow] with tweens for scale & opacity.
  ///
  /// `scaleTween`: Determines how much to scale this widget at paint time.
  ///
  /// `transformOpacity`: Optional. Determines, if provided, how opaque this
  /// widget should be when painted. By default, opacity is `1.0`.
  ///
  /// `curve`: Optional. Can be used to apply a curve to both the opacity and
  /// scale animations. Defaults to a linear curve.
  ///
  /// `clipBehavior`: Optional. Sets the clipping behavior at paint time.
  /// Defaults to none.
  ///
  /// `transformAlignment`: Optional. Sets the center of the scaling effect, if
  /// any. Defaults to the center of the child.
  ///
  /// `scrollRange`: Optional. Used to determine the scroll progress based on this
  /// widget's size and position within the scroll viewport. Defaults to the full
  /// scroll range. See [ScrollRange] for more.
  ///
  /// `child`: The child to animate at paint time.
  factory ScrollPositionFlow.animateScale({
    Key? key,
    required Animatable<double> scaleTween,
    Animatable<double>? opacityTween,
    Curve? curve,
    Clip? clipBehavior,
    Alignment? transformAlignment,
    ScrollRange? scrollRange,
    required Widget child,
  }) {
    return ScrollPositionFlow.animate(
      key: key,
      transformTween: WrapTween<Matrix4, double>(
        scaleTween,
        (scale) => Matrix4.identity()..scale(scale, scale),
      ),
      opacityTween: opacityTween,
      curve: curve,
      clipBehavior: clipBehavior,
      transformAlignment: transformAlignment,
      scrollRange: scrollRange,
      child: child,
    );
  }


  /// Create a [ScrollPositionFlow] with tweens for translation & opacity.
  ///
  /// `translateTween`: Determines where to translate this widget at paint time.
  ///
  /// `transformOpacity`: Optional. Determines, if provided, how opaque this
  /// widget should be when painted. By default, opacity is `1.0`.
  ///
  /// `curve`: Optional. Can be used to apply a curve to both the opacity and
  /// translation animations. Defaults to a linear curve.
  ///
  /// `clipBehavior`: Optional. Sets the clipping behavior at paint time.
  /// Defaults to none.
  ///
  /// `scrollRange`: Optional. Used to determine the scroll progress based on this
  /// widget's size and position within the scroll viewport. Defaults to the full
  /// scroll range. See [ScrollRange] for more.
  ///
  /// `child`: The child to animate at paint time.
  factory ScrollPositionFlow.animateTranslate({
    Key? key,
    required Animatable<Offset> translateTween,
    Animatable<double>? opacityTween,
    Curve? curve,
    Clip? clipBehavior,
    ScrollRange? scrollRange,
    required Widget child,
  }) {
    return ScrollPositionFlow.animate(
      key: key,
      transformTween: WrapTween<Matrix4, Offset>(
        translateTween,
        (offset) => Matrix4.translationValues(offset.dx, offset.dy, 0),
      ),
      opacityTween: opacityTween,
      curve: curve,
      clipBehavior: clipBehavior,
      scrollRange: scrollRange,
      child: child,
    );
  }

  double getProgress(
      Offset offset,
      ScrollableState scrollable,
      {required Size childSize, required Size parentSize}
  ) {
    final axis = scrollable.widget.axis;

    switch (axis) {
      case Axis.horizontal:
        return curve.transform(
          scrollRange.progress(
            offset: offset.dx,
            childExtent: childSize.width,
            viewportExtent: parentSize.width,
          ),
        );

      case Axis.vertical:
        return curve.transform(
          scrollRange.progress(
            offset: offset.dy,
            childExtent: childSize.height,
            viewportExtent: parentSize.height,
          ),
        );
    }
  }


  @override
  Widget build(BuildContext context) {
    final scrollable = Scrollable.of(context)!;
    return ParentOffsetFlow(
      child: child,
      parentContext: scrollable.context,
      clipBehavior: clipBehavior,
      buildTransform: (offset, {required childSize, required parentSize}) {
        if (buildTransform == null) {
          return Matrix4.identity();
        }
        return buildTransform!(getProgress(offset, scrollable,
            childSize: childSize, parentSize: parentSize));
      },
      buildOpacity: (offset, {required Size childSize, required Size parentSize}) {
        if (buildOpacity == null) {
          return 1.0;
        }
        return buildOpacity!(getProgress(offset, scrollable,
            childSize: childSize, parentSize: parentSize));
      },
      transformAlignment: transformAlignment,
      repaint: scrollable.position,
    );
  }
}

/// Wraps an Animatable into a transformed tween that preserves any curvature.
///
/// It's not enough to make a `Tween(begin: fn(innerTween.begin), ...)`, as the
/// resulting `Tween` would drop any potential curvature between beginning /
/// ending.
///
/// This calls the underlying animation and takes its value and turns that value
/// into the result via a provided function (`fn`).
class WrapTween<T, R> extends Tween<T> {
  final Animatable<R> innerTween;
  final T Function(R) fn;

  WrapTween(this.innerTween, this.fn)
    : super(
        begin: fn(innerTween.transform(0)),
        end: fn(innerTween.transform(1.0)),
      );

  @override
  T lerp(double t) => fn(innerTween.transform(t));
}
