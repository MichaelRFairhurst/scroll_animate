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
 
}

class RenderSliverParallax extends RenderSliverSingleBoxAdapter {
  final double mainAxisFactor;
  final double crossAxisFactor;
  final double scrollExtent;
  final double layoutExtent;
  final ScrollableState scrollable;
  final Offset offset;

  RenderSliverParallax({
    required this.mainAxisFactor,
    required this.crossAxisFactor,
    required this.scrollExtent,
    required this.layoutExtent,
    required this.scrollable,
    required this.offset,
  }) {
    scrollable.position.addListener(() {
      markNeedsLayout();
    });
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
