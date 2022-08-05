import 'package:flutter/rendering.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:scroll_animate/src/entrance_policy.dart';

/// A Sliver that provides callbacks for when an inner sliver enters and exits.
///
/// Provide callbacks to perform when a sliver enters or exits the scroll view.
/// Use this within a `CustomScrollView` or other widget that renders slivers.
/// 
/// To change the criteria for when a widget is considered to have entered, see
/// [EntrancePolicy]. By default, it will fire callbacks when any part of the
/// child becomes visible.
/// 
/// The child widget must be another sliver. To use this on a regular (non-
/// -sliver), use [SliverEnterExitCallback].
class SliverEnterExitCallbackWrapper extends SingleChildRenderObjectWidget {

  final void Function() onEnter;
  final void Function() onExit;
  final EntrancePolicy entrancePolicy;

  /// Create a [SliverEnterExitCallbackWrapper].
  ///
  /// `onEnter`: Callback to perform when the sliver enters view.
  ///
  /// `onExit`: Callback to perform when the sliver exits view.
  ///
  /// `sliver`: A sliver child widget. To get the same behavior on a regular
  ///  (non-sliver) child widget, use [SliverEnterExitCallback].
  ///
  /// `entrancePolicy`: Optional. Sets the criteria for when a widget is
  /// considered to have entered or exited view. See [EntrancePolicy]. Defaults
  /// to animating whenever any part of the child becomes visible.
  SliverEnterExitCallbackWrapper({
    Key? key,
    Widget? sliver,
    required this.onEnter,
    required this.onExit,
    EntrancePolicy? entrancePolicy,
  })
     : entrancePolicy = entrancePolicy ?? EntrancePolicy.anythingVisible()
     , super(key: key, child: sliver);

  @override
  _RenderSliverEnterExitCallback createRenderObject(BuildContext context)
    => _RenderSliverEnterExitCallback(onEnter: onEnter, onExit: onExit, entrancePolicy: entrancePolicy);

  void updateRenderObject(BuildContext context, _RenderSliverEnterExitCallback oldObject) {
    oldObject.onEnter = onEnter;
    oldObject.onExit = onExit;
    oldObject.entrancePolicy = entrancePolicy;
  }
}

class _RenderSliverEnterExitCallback extends RenderSliver with RenderObjectWithChildMixin<RenderSliver> {
  void Function() onEnter;
  void Function() onExit;
  EntrancePolicy entrancePolicy;

  bool? wasVisible = false;

  void handleVisibility(bool visible) {
    if (wasVisible != null) {
      if (wasVisible! && !visible) {
        onExit();
      } else if (!wasVisible! && visible) {
        onEnter();
      }
    }
    wasVisible = visible;
  }

  _RenderSliverEnterExitCallback({
    required this.onEnter,
    required this.onExit,
    required this.entrancePolicy,
  });

  @override
  void performLayout() {
    if (child == null) {
      geometry = SliverGeometry.zero;
      handleVisibility(false);
      return;
    }
    final SliverConstraints constraints = this.constraints;
    child!.layout(constraints, parentUsesSize: true);
    geometry = child!.geometry!;

    handleVisibility(entrancePolicy.visible(constraints, geometry!));
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {
    assert(child != null);
    assert(child == this.child);
    final SliverPhysicalParentData childParentData = child.parentData! as SliverPhysicalParentData;
    childParentData.applyPaintTransform(transform);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null && child!.geometry!.visible) {
      final SliverPhysicalParentData childParentData = child!.parentData! as SliverPhysicalParentData;
      context.paintChild(child!, offset + childParentData.paintOffset);
    }
  }

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! SliverPhysicalParentData)
      child.parentData = SliverPhysicalParentData();
  }

}
