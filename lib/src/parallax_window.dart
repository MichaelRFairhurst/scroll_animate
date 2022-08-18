import 'package:flutter/widgets.dart';
import 'package:scroll_animate/src/parent_offset_flow.dart';
import 'package:scroll_animate/src/scroll_range.dart';

/// A widget that looks like a window into a background view, via parallax.
///
/// The child widget provided will be layouted without constraints at its
/// "natural" size. Usually, this should result in a child widget that's larger
/// than this widget's parent. Then the child widget will be only partially
/// painted, in order to fit.
///
/// The offset of how the child widget is painted to fit will change over time
/// as the user scrolls. This behavior can be customized by providing a custom
/// [Alignment] tween, controlling which part shows at the end of scroll vs the
/// beginning of scroll. It can also be curved via an animation [Curve], and the
/// scrolling range can be tweaked by providing custom [ScrollRange]s -- though
/// these may not work the way you expect.
///
/// The alignment tween along with the [ScrollRange] is used to position the
/// child widget during scroll. For a standard vertical scroll, the `begin`
/// value refers to the part that's shown when the widget is at the bottom, and
/// `end` refers to the part shown when the widget is at the top. Note that the
/// default (and usually desired) [ScrollRange] is the [FullScrollRange]. This
/// means the parallax effect is continued for the entirety of the time the
/// widget is even partially visible, and the `begin`/`end` values of the
/// alignment tween are used when the widget is out of screen.
class ParallaxWindow extends StatelessWidget {
  final Animatable<Alignment> alignmentTween;
  final Curve curve;
  final Widget child;
  final ScrollRange scrollRange;

  /// Create a [ParallaxWindow].
  ///
  /// `alignmentTween`: Optional. Change where the child will be aligned at the
  /// beginning and end of scroll. The begin parameter is used when the child
  /// has begun to scroll into view (usually, from the bottom) and end is used
  /// when it has scrolled out the other side (usually, the top). Defaults to
  /// animating from the bottom center to the top center.
  ///
  /// `curve`: Optional. Apply a curve to the animation between alignments.
  ///
  /// `scrollRange`: Optional. Set the range that is used to determine where in
  /// the scroll corresponds to what progress of the alignment animation effect.
  /// See [ScrollRange] for more, but note that usually the default is what is
  /// desired. Defaults to [FullScrollRange].
  ///
  /// `child`: The inner widget to be parallaxed. This will be layouted without
  /// constraints, and usually, should have a size larger than the parallax
  /// parent, in order to create the right effect.
  ParallaxWindow({
    Key? key,
    this.curve = Curves.linear,
    Animatable<Alignment>? alignmentTween,
    required this.child,
    this.scrollRange = const FullScrollRange(),
  })
    : alignmentTween = alignmentTween ?? AlignmentTween(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter)
    , super(key: key);

  @override
  Widget build(BuildContext context) {
    final scrollable = Scrollable.of(context)!;
    return Builder(
      builder: (context) {
        return ParentOffsetFlow(
          childBoxConstraints: const BoxConstraints(),
          repaint: scrollable.position,
          clipBehavior: Clip.antiAlias,
          parentContext: scrollable.context,
          buildTransform: (offset, {required childSize, required parentSize}) {
            final windowObject = context.findRenderObject() as RenderBox;
            final windowSize = windowObject.size;

            final progress = scrollRange.progress(
                offset: offset.dy,
                childExtent: windowSize.height,
                viewportExtent: parentSize.height,
            );

            final alignment
                = alignmentTween.transform(curve.transform(progress));

            Rect alignedBox = alignment.inscribe(
              windowSize,
              const Offset(0,0) & childSize,
            );

            return Matrix4.translationValues(
              -alignedBox.left,
              -alignedBox.top,
              0,
            );
          },
          child: child,
        );
      }
    );
  }
}
