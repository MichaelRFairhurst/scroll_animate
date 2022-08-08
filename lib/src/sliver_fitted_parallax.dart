import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:scroll_animate/src/parallax_scroll_center.dart';
import 'package:scroll_animate/src/render_sliver_parallax.dart';

/// A [SliverParallax] that fits its scroll speed to its size or size to scroll.
///
/// Intended for a parallax child which is larger than its scroll container and
/// should always be visible within a certain scroll range (typically, from the
/// beginning to end of the scroll view). This widget will constrain the child
/// size OR set the scroll speed such that the edges of this widget are not
/// visible when the user is scrolling through that range.
///
/// When `mainAxisFactor` is not null, the child widget's size in the main
/// scroll axis (ie, height in a vertical scroll) will be constrained so that
/// the widget is still in view when scrolled to within the range. If
/// `mainAxisFactor` is `null`, then a `mainAxisFactor` will be chosen that
/// maintains this property instead. It will do the same for `crossAxisFactor`
/// and the scroll axis size (ie, width in a vertical scroll).
///
/// Rather than using a [ParallaxScrollCenter] to determine a "neutral"
/// position, this takes a `start` and `end` scroll offset. These default to
/// an absolute 0px start and a relative 0px end -- this means if it is the last
/// sliver in the scroll view it will function as a background for the whole
/// scroll view.
class SliverFittedParallax extends SingleChildRenderObjectWidget {
  final Widget child;
  final double? mainAxisFactor;
  final double? crossAxisFactor;
  final double scrollExtent;
  final ParallaxScrollCenter start;
  final ParallaxScrollCenter end;

  /// Create a [SliverFittedParallax].
  ///
  /// `child`: the widget that will move at a parallax.
  ///
  /// `mainAxisFactor`: Set an exact scroll rate. To reduce scroll rate, this
  /// should be less than `1.0`. To increase it, this should be greater than
  /// `1.0`. A negative value will scroll in the opposite direction. Defaults to
  /// `null`, letting child size determine scroll rate.
  ///
  /// `crossAxisFactor`: Move perpendicular to the scroll direction. Defaults to
  /// `0.0`, setting the child to fill the viewport and disabling cross axis
  /// scroll.
  ///
  /// `start`: Optional. Sets the beginning over the scroll area that this
  /// widget should fit to. See [ParallaxScrollCenter]. Defaults to an absolute
  /// 0px offset, or, the very beginning of the scroll.
  ///
  /// `end`: Optional. Sets the end over the scroll area that this widget should
  /// fit to. See [ParallaxScrollCenter]. Defaults to a relative 0px offset, or,
  /// this sliver's scroll offset. Usually, this should be left to the default
  /// AND this sliver should be the last in its scroll view's sliver list.
  ///
  /// `scrollExtent`: Optional. Set the scroll extent on the sliver geometry
  /// for this sliver. This has the effect of stopping other widgets from
  /// scrolling temporarily when this sliver hits the top of the scroll view.
  SliverFittedParallax({
    this.mainAxisFactor,
    this.crossAxisFactor = 0.0,
    this.scrollExtent = 0.0,
    ParallaxScrollCenter? start,
    ParallaxScrollCenter? end,
    required this.child,
  })
    : start = start ?? ParallaxScrollCenter.absolutePx(0.0)
    , end = end ?? ParallaxScrollCenter.relativePx(0.0);

  @override
  RenderObject createRenderObject(BuildContext context)
      => _RenderSliverFittedParallax(
           widgetMainAxisFactor: mainAxisFactor,
           widgetCrossAxisFactor: crossAxisFactor,
           scrollExtent: scrollExtent,
           scrollable: Scrollable.of(context)!,
           start: start,
           end: end,
         );

  @override
  void updateRenderObject(BuildContext context, _RenderSliverFittedParallax renderObject) {
    renderObject.widgetMainAxisFactor = mainAxisFactor;
    renderObject.widgetCrossAxisFactor = crossAxisFactor;
    renderObject.scrollExtent = scrollExtent;
    renderObject.scrollable = Scrollable.of(context)!;
    renderObject.start = start;
    renderObject.end = end;
  }
}

class _RenderSliverFittedParallax extends RenderSliverParallaxBase {
  double? _widgetMainAxisFactor;
  double? _widgetCrossAxisFactor;

  ParallaxScrollCenter _start;
  ParallaxScrollCenter _end;

  @override
  double mainAxisFactor = 0.0;

  @override
  double crossAxisFactor = 0.0;

  @override
  Offset offset = Offset(0, 0);

  _RenderSliverFittedParallax({
    required double? widgetMainAxisFactor,
    required double? widgetCrossAxisFactor,
    required double scrollExtent,
    required ScrollableState scrollable,
    required ParallaxScrollCenter start,
    required ParallaxScrollCenter end,
  })
    : _widgetMainAxisFactor = widgetMainAxisFactor
    , _widgetCrossAxisFactor = widgetCrossAxisFactor
        ?? (widgetMainAxisFactor != null ? 1.0 : null)
    , _start = start
    , _end = end
    , super(
        scrollExtent: scrollExtent,
        scrollable: scrollable,
        offset: Offset(0, 0),
        center: start,
      );

  void set widgetMainAxisFactor(double? widgetMainAxisFactor) {
    if (widgetMainAxisFactor != _widgetMainAxisFactor) {
      markNeedsLayout();
    }
    _widgetMainAxisFactor = widgetMainAxisFactor;
  }

  void set widgetCrossAxisFactor(double? widgetCrossAxisFactor) {
    if (widgetCrossAxisFactor != _widgetCrossAxisFactor) {
      markNeedsLayout();
    }
    _widgetCrossAxisFactor = widgetCrossAxisFactor;
  }

  void set start(ParallaxScrollCenter start) {
    if (start != _start) {
      center = start;
      markNeedsLayout();
    }
    _start = start;
  }

  void set end(ParallaxScrollCenter end) {
    if (end != _end) {
      markNeedsLayout();
    }
    _end = end;
  }

  void layoutChild(SliverConstraints constraints) {
    final startOffset = _start.centerPixelValue(constraints.precedingScrollExtent);
    final endOffset = _end.centerPixelValue(constraints.precedingScrollExtent);
    final scrollDistance = endOffset - startOffset;

    double? inferredMainAxisExtent;
    double? inferredCrossAxisExtent;

    final widgetMainAxisFactor = _widgetMainAxisFactor;
    if (widgetMainAxisFactor != null) {
      inferredMainAxisExtent = scrollDistance * widgetMainAxisFactor.abs()
          + constraints.viewportMainAxisExtent;
      mainAxisFactor = widgetMainAxisFactor;
    }

    final widgetCrossAxisFactor = _widgetCrossAxisFactor;
    if (widgetCrossAxisFactor != null) {
      inferredCrossAxisExtent = scrollDistance * widgetCrossAxisFactor.abs()
          + constraints.crossAxisExtent;
      crossAxisFactor = widgetCrossAxisFactor;
    }

    final BoxConstraints childConstraints;
    switch (constraints.axis) {
      case Axis.vertical:
        childConstraints = BoxConstraints(
          minHeight: inferredMainAxisExtent ?? 0.0,
          maxHeight: inferredMainAxisExtent ?? double.infinity,
          minWidth: inferredCrossAxisExtent ?? 0.0,
          maxWidth: double.infinity,
        );
        break;
      case Axis.horizontal:
        childConstraints = BoxConstraints(
          minWidth: inferredMainAxisExtent ?? 0.0,
          maxWidth: double.infinity,
          minHeight: inferredCrossAxisExtent ?? 0.0,
          maxHeight: inferredCrossAxisExtent ?? double.infinity,
        );
        break;
      default:
        throw "Unexpected axis type ${constraints.axis}";
    }

    child!.layout(childConstraints, parentUsesSize: true);

    final size = child!.size;
    final double mainAxisExtent;
    final double crossAxisExtent;

    switch (constraints.axis) {
      case Axis.vertical:
        mainAxisExtent = size.height;
        crossAxisExtent = size.width;
        break;
      case Axis.horizontal:
        mainAxisExtent = size.width;
        crossAxisExtent = size.height;
        break;
      default:
        throw "Unexpected axis type ${constraints.axis}";
    }

    if (widgetMainAxisFactor == null) {
      mainAxisFactor = (mainAxisExtent - constraints.viewportMainAxisExtent) / scrollDistance;
    }

    if (widgetCrossAxisFactor == null) {
      crossAxisFactor = (crossAxisExtent - constraints.crossAxisExtent) / scrollDistance;
    }

    double mainAxisOffset = 0;
    double crossAxisOffset = 0;

    if (mainAxisFactor < 0.0) {
      mainAxisOffset = constraints.viewportMainAxisExtent - mainAxisExtent;
    }
    if (crossAxisFactor > 0.0) {
      crossAxisOffset = constraints.crossAxisExtent - crossAxisExtent;
    }

    switch (constraints.axis) {
      case Axis.vertical:
        offset = Offset(crossAxisOffset, mainAxisOffset);
        break;
      case Axis.horizontal:
        offset = Offset(mainAxisOffset, crossAxisOffset);
        break;
    }
  }

}
