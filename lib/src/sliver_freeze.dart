import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// A sliver that temporarily freezes at the top of screen during scroll.
///
/// This makes most sense when the widget is fullscreen and/or has an animation
/// of some kind (see [SliverFreezeAnimation]), allowing you to create a sort of
/// scroll-navigation effect between pages, similar to a `PageView`.
///
/// The duration of the fade is specified in pixels the user will have to scroll
/// before it becomes unfrozen.
class SliverFreeze extends SingleChildRenderObjectWidget {

  final Widget child;
  final double duration;

  /// Create a [SliverFreeze].
  ///
  /// `duration`: This is specified in pixels that the user will have to scroll
  /// before the child widget is unfrozen.
  ///
  /// `child`: the contents of this sliver.
  SliverFreeze({
    required this.duration,
    required this.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context)
      => _RenderSliverFreeze(duration: duration);

  @override
  void updateRenderObject(BuildContext context, _RenderSliverFreeze renderObject) {
    renderObject.duration = duration;
  }
}

class _RenderSliverFreeze extends RenderSliverSingleBoxAdapter {

  double _duration;

  void set duration(double duration) {
    markNeedsLayout();
    _duration = duration;
  }

  double get duration => _duration;

  _RenderSliverFreeze({required double duration}) : _duration = duration;

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
