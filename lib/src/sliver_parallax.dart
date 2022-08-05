import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Determines whether a [ParallaxScrollCenter] is relative or absolute.
///
/// See [ParallaxScrollCenter].
enum ParallaxOffsetType {
  relativePixels,
  absolutePixels,
}

/// Defines when a [SliverParallax] hits center in the scrollview.
///
/// A [SliverParallax] has a "neutral" position which defaults to (0, 0) but is
/// configurable via it's `offset`. As the user scrolls, the [SliverParallax]
/// either faster or slower than the rest of the scrollview, (and perhaps in
/// the cross axis direction). The [SliverParallax] will hit the "neutral"
/// position at some scroll amount. This class defines that scroll amount.
///
/// For convenience in designing parallax UIs, a relative offset is allowed,
/// which is based on the scroll position the sliver would have if it were
/// not a special parallax effect.
///
/// However, an absolute offset is also allowed. This is especially useful as
/// a means of setting a background at scroll position 0, since slivers are
/// painted in reverse order. If the last sliver has a scroll center of 0 then
/// it will be painted below all others but still aligned with the top of the
/// scroll.
class ParallaxScrollCenter {
  final double value;
  final ParallaxOffsetType type;

  /// Construct a [ParallaxScrollCenter] from values.
  ParallaxScrollCenter(
    this.value,
    this.type,
  );

  /// Construct a [ParallaxScrollCenter] with an absolute pixel offset.
  ParallaxScrollCenter.absolutePx(
    this.value,
  ) : type = ParallaxOffsetType.absolutePixels;

  /// Construct a [ParallaxScrollCenter] with an absolute pixel offset.
  ParallaxScrollCenter.relativePx(
    this.value,
  ) : type = ParallaxOffsetType.relativePixels;

  /// Get the pixel offset of the scroll center.
  ///
  /// The [precedingScroll] allows relative scroll centers to use their natural
  /// scroll offset as a base.
  double centerPixelValue(double precedingScroll) {
    switch (type) {
      case ParallaxOffsetType.relativePixels:
        return precedingScroll + value;
      case ParallaxOffsetType.absolutePixels:
        return value;
    }
  }
}

/// A sliver that scrolls faster or slower than other scroll contents.
///
/// Often used to create a depth effect, but also creates a visual surprise
/// when contents unexpectedly line up in interesting ways while scrolling.
///
/// Provide a child for the widget that will move at a parallax. Then to
/// reduce its scroll rate, provide a `mainAxisFactor` less than `1.0`. To
/// make it scroll faster, provide a factor greater than `1.0` or make it
/// scroll the opposite direction with a negative factor. You can also give
/// a `crossAxisFactor` to make it move perpendicular to the scroll direction.
///
/// By default, this paints the child at (0, 0) when the next sliver in the
/// scrollview is scrolled to the top of the view. This is the "neutral"
/// position of this [SliverParallax] and can be adjusted in two ways.
///
/// To change the amount of scrolling required to hit "neutral" position, see
/// [ParallaxScrollCenter], and provide a custom relative or absolute offset.
///
/// To change where on the screen this widget is painted at the neutral scroll
/// amount, provide an `Offset`.
class SliverParallax extends SingleChildRenderObjectWidget {
  final Widget child;
  final double mainAxisFactor;
  final double crossAxisFactor;
  final double scrollExtent;
  final Offset offset;
  final ParallaxScrollCenter center;

  /// Create a [SliverParallax].
  ///
  /// `child`: the widget that will move at a parallax.
  ///
  /// `mainAxisFactor`: Adjust scroll rate. To reduce scroll rate, this should
  /// be less than `1.0`. To increase it, this should be greater than `1.0`. A
  /// negative value will scroll in the opposite direction. 
  ///
  /// `crossAxisFactor`: Move perpendicular to the scroll direction.
  ///
  /// `center`: Optional. Sets the amount of scrolling required to hit "neutral"
  /// position. See [ParallaxScrollCenter]. Defaults to a relative 0px offset.
  ///
  /// `offset`: Optional. Where to paint this at the "neutral" scroll position.
  /// Defaults to (0, 0).
  ///
  /// `scrollExtent`: Optional. Set the scroll extent on the sliver geometry
  /// for this sliver. This has the effect of stopping other widgets from
  /// scrolling temporarily when this sliver hits the top of the scroll view.
  SliverParallax({
    this.mainAxisFactor = 1.0,
    this.crossAxisFactor = 0.0,
    this.scrollExtent = 0.0,
    this.offset = const Offset(0, 0),
    ParallaxScrollCenter? center,
    required this.child,
  })
    : center = center ?? ParallaxScrollCenter.relativePx(0.0);

  @override
  RenderObject createRenderObject(BuildContext context)
      => _RenderSliverParallax(
           mainAxisFactor: mainAxisFactor,
           crossAxisFactor: crossAxisFactor,
           scrollExtent: scrollExtent,
           scrollable: Scrollable.of(context)!,
           offset: offset,
           center: center,
         );

  @override
  void updateRenderObject(BuildContext context, _RenderSliverParallax renderObject) {
    renderObject.mainAxisFactor = mainAxisFactor;
    renderObject.crossAxisFactor = crossAxisFactor;
    renderObject.scrollExtent = scrollExtent;
    renderObject.scrollable = Scrollable.of(context)!;
    renderObject.offset = offset;
    renderObject.center = center;
  }
 
}

class _RenderSliverParallax extends RenderSliverSingleBoxAdapter {
  double _mainAxisFactor;
  double _crossAxisFactor;
  double _scrollExtent;
  ScrollableState _scrollable;
  Offset _offset;
  ParallaxScrollCenter _center;

  void set mainAxisFactor(double mainAxisFactor) {
    if (mainAxisFactor != _mainAxisFactor) {
      markNeedsLayout();
    }
    _mainAxisFactor = mainAxisFactor;
  }

  double get mainAxisFactor => _mainAxisFactor;

  void set crossAxisFactor(double crossAxisFactor) {
    if (crossAxisFactor != _crossAxisFactor) {
      markNeedsLayout();
    }
    _crossAxisFactor = crossAxisFactor;
  }

  double get crossAxisFactor => _crossAxisFactor;

  void set scrollExtent(double scrollExtent) {
    if (scrollExtent != _scrollExtent) {
      markNeedsLayout();
    }
    _scrollExtent = scrollExtent;
  }

  double get scrollExtent => _scrollExtent;

  void set scrollable(ScrollableState scrollable) {
    if (!identical(scrollable, _scrollable)) {
      scrollable.position.removeListener(markNeedsLayout);
      markNeedsLayout();
    }
    _scrollable = scrollable;
    scrollable.position.addListener(markNeedsLayout);
  }

  ScrollableState get scrollable => _scrollable;

  void set offset(Offset offset) {
    if (offset != _offset) {
      markNeedsLayout();
    }
    _offset = offset;
  }

  Offset get offset => _offset;

  void set center(ParallaxScrollCenter center) {
    if (center.type != _center.type || center.value != _center.value) {
      markNeedsLayout();
    }
    _center = center;
  }

  ParallaxScrollCenter get center => _center;

  _RenderSliverParallax({
    required double mainAxisFactor,
    required double crossAxisFactor,
    required double scrollExtent,
    required ScrollableState scrollable,
    required Offset offset,
    required ParallaxScrollCenter center,
  }) :
    _mainAxisFactor = mainAxisFactor,
    _crossAxisFactor = crossAxisFactor,
    _scrollExtent = scrollExtent,
    _scrollable = scrollable,
    _offset = offset,
    _center = center
    {
    _scrollable.position.addListener(markNeedsLayout);
  }

  Offset _paintOffset = Offset(0, 0);

  @override
  void performLayout() {
    if (child == null) {
      geometry = SliverGeometry.zero;
      return;
    }
    final SliverConstraints constraints = this.constraints;
    child!.layout(BoxConstraints(maxWidth: constraints.crossAxisExtent), parentUsesSize: true);
    final double childExtent;
    switch (constraints.axis) {
      case Axis.horizontal:
        childExtent = child!.size.width;
        break;
      case Axis.vertical:
        childExtent = child!.size.height;
        break;
    }
    assert(childExtent != null);

    final centralOffset = center.centerPixelValue(constraints.precedingScrollExtent);
    final scaleableScrollAmount = scrollable.position.pixels - centralOffset;

    final scaledScrollMainAxis = scaleableScrollAmount * -mainAxisFactor;
    final scaledScrollCrossAxis = scaleableScrollAmount * crossAxisFactor;
    _paintOffset = Offset(scaledScrollCrossAxis, scaledScrollMainAxis);

    geometry = SliverGeometry(
      paintOrigin: 0.0,
      layoutExtent: 0.0,
      scrollExtent: scrollExtent,
      paintExtent: 0.0,
      cacheExtent: 0.0,
      maxPaintExtent: 0.0,
      hitTestExtent: 0.0,//childExtent,
      visible: true,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null && geometry!.visible) {
      context.paintChild(child!, _paintOffset + this.offset);
    }
  }
}
