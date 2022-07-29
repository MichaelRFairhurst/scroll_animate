import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

enum ParallaxOffsetType {
  relativePixels,
  absolutePixels,
  //relativeScaledToViewport,
  //absoluteScaledToViewports,
}

class ParallaxScrollCenter {
  final double value;
  final ParallaxOffsetType type;

  ParallaxScrollCenter(
    this.value,
    {ParallaxOffsetType? type}
  ) : type = type ?? ParallaxOffsetType.absolutePixels;

  double centerPixelValue(double precedingScroll) {
    switch (type) {
      case ParallaxOffsetType.relativePixels:
        return precedingScroll + value;
      case ParallaxOffsetType.absolutePixels:
        return value;
    }
  }
}

class SliverParallax extends SingleChildRenderObjectWidget {

  final Widget child;
  final double mainAxisFactor;
  final double crossAxisFactor;
  final double scrollExtent;
  final double layoutExtent;
  final Offset offset;
  final ParallaxScrollCenter center;

  SliverParallax({
    this.mainAxisFactor = 1.0,
    this.crossAxisFactor = 0.0,
    this.scrollExtent = 0.0,
    this.layoutExtent = 0.0,
    this.offset = const Offset(0, 0),
    ParallaxScrollCenter? center,
    required this.child,
  })
    : center = center ?? ParallaxScrollCenter(0.0, type: ParallaxOffsetType.relativePixels);

  @override
  RenderObject createRenderObject(BuildContext context)
      => RenderSliverParallax(
           mainAxisFactor: mainAxisFactor,
           crossAxisFactor: crossAxisFactor,
           scrollExtent: scrollExtent,
           layoutExtent: layoutExtent,
           scrollable: Scrollable.of(context)!,
           offset: offset,
           center: center,
         );

  @override
  void updateRenderObject(BuildContext context, RenderSliverParallax renderObject) {
    renderObject.mainAxisFactor = mainAxisFactor;
    renderObject.crossAxisFactor = crossAxisFactor;
    renderObject.scrollExtent = scrollExtent;
    renderObject.layoutExtent = layoutExtent;
    renderObject.scrollable = Scrollable.of(context)!;
    renderObject.offset = offset;
    renderObject.center = center;
  }
 
}

class RenderSliverParallax extends RenderSliverSingleBoxAdapter {
  double _mainAxisFactor;
  double _crossAxisFactor;
  double _scrollExtent;
  double _layoutExtent;
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

  void set layoutExtent(double layoutExtent) {
    if (layoutExtent != _layoutExtent) {
      markNeedsLayout();
    }
    _layoutExtent = layoutExtent;
  }

  double get layoutExtent => _layoutExtent;

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

  RenderSliverParallax({
    required double mainAxisFactor,
    required double crossAxisFactor,
    required double scrollExtent,
    required double layoutExtent,
    required ScrollableState scrollable,
    required Offset offset,
    required ParallaxScrollCenter center,
  }) :
    _mainAxisFactor = mainAxisFactor,
    _crossAxisFactor = crossAxisFactor,
    _scrollExtent = scrollExtent,
    _layoutExtent = layoutExtent,
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
    child!.layout(BoxConstraints(), parentUsesSize: true);
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
    final scaledScrollMainAxis = scaleableScrollAmount * mainAxisFactor;
    final scaledScrollCrossAxis = scaleableScrollAmount * crossAxisFactor;

    _paintOffset = Offset(scaledScrollCrossAxis, -scaledScrollMainAxis);
    //final double paintedChildSize = calculatePaintOffset(constraints, from: 0.0, to: childExtent);
    //final double cacheExtent = calculateCacheOffset(constraints, from: 0.0, to: childExtent);

    //assert(paintedChildSize.isFinite);
    //assert(paintedChildSize >= 0.0);
    geometry = SliverGeometry(
      layoutExtent: layoutExtent,
      scrollExtent: scrollExtent,
      paintExtent: 0.0,
      cacheExtent: 0.0,
      maxPaintExtent: 0.0,//childExtent,
      hitTestExtent: 0.0,//childExtent,
      visible: true,
    );
    //final SliverPhysicalParentData childParentData = child!.parentData! as SliverPhysicalParentData;
    //childParentData.paintOffset = Offset(0.0, 0.0);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null && geometry!.visible) {
      context.paintChild(child!, _paintOffset + this.offset);
    }
  }
}
