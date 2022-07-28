import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SliverParallax extends SingleChildRenderObjectWidget {

  final Widget child;
  final double mainAxisFactor;
  final double crossAxisFactor;
  final double scrollExtent;
  final double layoutExtent;
  final Offset offset;

  SliverParallax({
    this.mainAxisFactor = 1.0,
    this.crossAxisFactor = 0.0,
    this.scrollExtent = 0.0,
    this.layoutExtent = 0.0,
    this.offset = const Offset(0, 0),
    required this.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context)
      => RenderSliverParallax(
           mainAxisFactor: mainAxisFactor,
           crossAxisFactor: crossAxisFactor,
           scrollExtent: scrollExtent,
           layoutExtent: layoutExtent,
           scrollable: Scrollable.of(context)!,
           offset: offset,
         );

  @override
  void updateRenderObject(BuildContext context, RenderSliverParallax renderObject) {
    renderObject.mainAxisFactor = mainAxisFactor;
    renderObject.crossAxisFactor = crossAxisFactor;
    renderObject.scrollExtent = scrollExtent;
    renderObject.layoutExtent = layoutExtent;
    renderObject.scrollable = Scrollable.of(context)!;
    renderObject.offset = offset;
  }
 
}

class RenderSliverParallax extends RenderSliverSingleBoxAdapter {
  double _mainAxisFactor;
  double _crossAxisFactor;
  double _scrollExtent;
  double _layoutExtent;
  ScrollableState _scrollable;
  Offset _offset;

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

  RenderSliverParallax({
    required double mainAxisFactor,
    required double crossAxisFactor,
    required double scrollExtent,
    required double layoutExtent,
    required ScrollableState scrollable,
    required Offset offset,
  }) :
    _mainAxisFactor = mainAxisFactor,
    _crossAxisFactor = crossAxisFactor,
    _scrollExtent = scrollExtent,
    _layoutExtent = layoutExtent,
    _scrollable = scrollable,
    _offset = offset
    {
    _scrollable.position.addListener(markNeedsLayout);
  }

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
    //final double paintedChildSize = calculatePaintOffset(constraints, from: 0.0, to: childExtent);
    final double cacheExtent = calculateCacheOffset(constraints, from: 0.0, to: childExtent);

    //assert(paintedChildSize.isFinite);
    //assert(paintedChildSize >= 0.0);
    geometry = SliverGeometry(
      layoutExtent: layoutExtent,
      scrollExtent: scrollExtent,
      paintExtent: childExtent,
      cacheExtent: cacheExtent,
      maxPaintExtent: childExtent,
      hitTestExtent: childExtent,
      hasVisualOverflow: childExtent > constraints.remainingPaintExtent || constraints.scrollOffset > 0.0,
    );
    setChildParentData(child!, constraints, geometry!);
  }

  void setChildParentData(RenderObject child, SliverConstraints constraints, SliverGeometry geometry) {
    final SliverPhysicalParentData childParentData = child.parentData! as SliverPhysicalParentData;
    assert(constraints.axisDirection != null);
    assert(constraints.growthDirection != null);

    final scaleableScrollAmount = scrollable.position.pixels - constraints.precedingScrollExtent;
    final scaledScrollMainAxis = scaleableScrollAmount * mainAxisFactor;

    final scaledScrollCrossAxis = scaleableScrollAmount * crossAxisFactor;// + constraints.precedingScrollExtent;

    switch (applyGrowthDirectionToAxisDirection(constraints.axisDirection, constraints.growthDirection)) {
      case AxisDirection.up:
        childParentData.paintOffset = Offset(0.0, -(geometry.scrollExtent - (geometry.paintExtent + constraints.scrollOffset)));
        break;
      case AxisDirection.right:
        childParentData.paintOffset = Offset(-constraints.scrollOffset, 0.0);
        break;
      case AxisDirection.down:
        childParentData.paintOffset = Offset(scaledScrollCrossAxis, scaledScrollMainAxis - constraints.scrollOffset);
        break;
      case AxisDirection.left:
        childParentData.paintOffset = Offset(-(geometry.scrollExtent - (geometry.paintExtent + constraints.scrollOffset)), 0.0);
        break;
    }
    assert(childParentData.paintOffset != null);
    childParentData.paintOffset += offset;

    if (geometry.paintExtent > constraints.remainingPaintExtent) {
      this.geometry = SliverGeometry.zero;
      childParentData.paintOffset += Offset(0, 0);
    }
  }
}
