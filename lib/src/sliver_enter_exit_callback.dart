import 'package:flutter/rendering.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:scroll_animate/src/entrance_policy.dart';

class SliverEnterExitCallback extends SingleChildRenderObjectWidget {
  void Function() onEnter;
  void Function() onExit;
  EntrancePolicy entrancePolicy;

  SliverEnterExitCallback({
    Key? key,
    Widget? child,
    required this.onEnter,
    required this.onExit,
    EntrancePolicy? entrancePolicy,
  })
     : entrancePolicy = entrancePolicy ?? EntrancePolicy.anythingVisible()
     , super(key: key, child: child);

  @override
  RenderSliverEnterExitCallback createRenderObject(BuildContext context)
    => RenderSliverEnterExitCallback(onEnter: onEnter, onExit: onExit, entrancePolicy: entrancePolicy);

  void updateRenderObject(BuildContext context, RenderSliverEnterExitCallback oldObject) {
    oldObject.onEnter = onEnter;
    oldObject.onExit = onExit;
    oldObject.entrancePolicy = entrancePolicy;
  }
}

class RenderSliverEnterExitCallback extends RenderSliver with RenderObjectWithChildMixin<RenderSliver> {
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

  RenderSliverEnterExitCallback({
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
