import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SliverFreeze extends SingleChildRenderObjectWidget {

  final Widget child;
  final double duration;

  SliverFreeze({
    required this.duration,
    required this.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context)
      => RenderSliverFreeze(duration: duration);
 
}

class RenderSliverFreeze extends RenderSliverSingleBoxAdapter {

  final double duration;

  RenderSliverFreeze({required this.duration});

  @override
  void performLayout() {
    if (child == null) {
      geometry = SliverGeometry.zero;
      return;
    }
    final SliverConstraints constraints = this.constraints;
    child!.layout(constraints.asBoxConstraints(), parentUsesSize: true);
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

    final paintedChildSize = (childExtent + min(0.0, -constraints.scrollOffset + duration)).clamp(0.0, constraints.remainingPaintExtent);

    assert(paintedChildSize.isFinite);
    geometry = SliverGeometry(
      scrollExtent: childExtent + duration,
      layoutExtent: paintedChildSize,
      paintExtent: paintedChildSize,
      maxPaintExtent: paintedChildSize,
    );
    setChildParentData(child!, constraints, geometry!);
  }

  void setChildParentData(RenderObject child, SliverConstraints constraints, SliverGeometry geometry) {
    final SliverPhysicalParentData childParentData = child.parentData! as SliverPhysicalParentData;
    assert(constraints.axisDirection != null);
    assert(constraints.growthDirection != null);
    switch (applyGrowthDirectionToAxisDirection(constraints.axisDirection, constraints.growthDirection)) {
      case AxisDirection.up:
        childParentData.paintOffset = Offset(0.0, -(geometry.scrollExtent - (geometry.paintExtent + constraints.scrollOffset)));
        break;
      case AxisDirection.right:
        childParentData.paintOffset = Offset(min(0.0, -constraints.scrollOffset + duration), 0.0);
        break;
      case AxisDirection.down:
        childParentData.paintOffset = Offset(0.0, min(0.0, -constraints.scrollOffset + duration));
        break;
      case AxisDirection.left:
        childParentData.paintOffset = Offset(-(geometry.scrollExtent - (geometry.paintExtent + constraints.scrollOffset)), 0.0);
        break;
    }
    assert(childParentData.paintOffset != null);
  }
}
