import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:scroll_animate/src/parallax_scroll_center.dart';

class RenderSliverParallax extends RenderSliverParallaxBase {
  double _mainAxisFactor;
  double _crossAxisFactor;

  RenderSliverParallax({
    required double mainAxisFactor,
    required double crossAxisFactor,
    required double scrollExtent,
    required ScrollableState scrollable,
    required Offset offset,
    required ParallaxScrollCenter center,
  })
    : _mainAxisFactor = mainAxisFactor
    , _crossAxisFactor = crossAxisFactor
    , super(
        scrollExtent: scrollExtent,
        scrollable: scrollable,
        offset: offset,
        center: center,
      );

  void set mainAxisFactor(double mainAxisFactor) {
    if (mainAxisFactor != _mainAxisFactor) {
      markNeedsLayout();
    }
    _mainAxisFactor = mainAxisFactor;
  }

  @override
  double get mainAxisFactor => _mainAxisFactor;

  void set crossAxisFactor(double crossAxisFactor) {
    if (crossAxisFactor != _crossAxisFactor) {
      markNeedsLayout();
    }
    _crossAxisFactor = crossAxisFactor;
  }

  @override
  double get crossAxisFactor => _crossAxisFactor;
    
  @override
  void layoutChild(SliverConstraints constraints) {
    switch (constraints.axis) {
      case Axis.horizontal:
        child!.layout(BoxConstraints(maxHeight: constraints.crossAxisExtent), parentUsesSize: true);
        break;
      case Axis.vertical:
        child!.layout(BoxConstraints(maxWidth: constraints.crossAxisExtent), parentUsesSize: true);
        break;
    }
  }
}

abstract class RenderSliverParallaxBase extends RenderSliverSingleBoxAdapter {
  double _scrollExtent;
  ScrollableState _scrollable;
  Offset _offset;
  ParallaxScrollCenter _center;

  double get mainAxisFactor;
  double get crossAxisFactor;

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

  RenderSliverParallaxBase({
    required double scrollExtent,
    required ScrollableState scrollable,
    required Offset offset,
    required ParallaxScrollCenter center,
  }) :
    _scrollExtent = scrollExtent,
    _scrollable = scrollable,
    _offset = offset,
    _center = center
    {
    _scrollable.position.addListener(markNeedsLayout);
  }

  Offset _paintOffset = Offset(0, 0);

  void layoutChild(SliverConstraints constraints);

  @override
  void performLayout() {
    if (child == null) {
      geometry = SliverGeometry.zero;
      return;
    }

    final SliverConstraints constraints = this.constraints;
    layoutChild(constraints);

    final centralOffset = center.centerPixelValue(constraints.precedingScrollExtent);
    final scaleableScrollAmount = scrollable.position.pixels - centralOffset;

    final directionFactor;
    switch (constraints.normalizedGrowthDirection) {
      case GrowthDirection.forward:
        directionFactor = 1.0;
      break;
      case GrowthDirection.reverse:
        directionFactor = -1.0;
      break;
    }

    final scaledScrollMainAxis = scaleableScrollAmount * -mainAxisFactor * directionFactor;
    final scaledScrollCrossAxis = scaleableScrollAmount * crossAxisFactor * directionFactor;

    switch (constraints.axis) {
      case Axis.horizontal:
        _paintOffset = Offset(scaledScrollMainAxis, scaledScrollCrossAxis);
        break;
      case Axis.vertical:
        _paintOffset = Offset(scaledScrollCrossAxis, scaledScrollMainAxis);
        break;
    }

    geometry = SliverGeometry(
      paintOrigin: 0.0,
      layoutExtent: 0.0,
      scrollExtent: scrollExtent,
      paintExtent: 0.0,
      cacheExtent: 0.0,
      maxPaintExtent: 0.0,
      hitTestExtent: 0.0,
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
