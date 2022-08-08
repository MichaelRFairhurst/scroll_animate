import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

class SliverPositionAnimation extends StatefulWidget {

  final Widget Function(BuildContext, double) builder;

  SliverPositionAnimation({
    required this.builder
  });

  State createState() => SliverPositionAnimationState();
}

class SliverPositionAnimationState extends State<SliverPositionAnimation> {
  final layoutOffsetStreamController = StreamController<double>();

  Widget build(BuildContext context) {
    final scrollable = Scrollable.of(context)!;

    return SliverPositionAnimationBase(
      scrollable: scrollable,
      setLayoutOffset: (double newValue) {
        layoutOffsetStreamController.sink.add(newValue);
        //(context as Element).rebuild();
      },
      child: SliverLayoutBuilder(
        builder: (context, constraints) {
          return StreamBuilder<double>(
            stream: layoutOffsetStreamController.stream,
            builder: (context, snapshot) {
              final layoutOffset = snapshot.data ?? 0.0;
              final viewportExtent = constraints.viewportMainAxisExtent;
              final precedingExtent = constraints.precedingScrollExtent;
              final localOffset = (precedingExtent - scrollable.position.pixels - layoutOffset).clamp(0, viewportExtent);
              return SliverToBoxAdapter(
                child: widget.builder(context, localOffset / viewportExtent),
              );
            },
          );
        },
      ),
    );
  }
}

class SliverPositionAnimationBase extends SingleChildRenderObjectWidget {
  final void Function(double) setLayoutOffset;
  final ScrollableState scrollable;

  const SliverPositionAnimationBase({
    required this.setLayoutOffset,
    required this.scrollable,
    Key? key,
    Widget? child,
  }) : super(key: key, child: child);

  @override
  RenderSliverPositionAnimation createRenderObject(BuildContext context) {
    return RenderSliverPositionAnimation(
      scrollable: scrollable,
      setLayoutOffset: setLayoutOffset,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderSliverPositionAnimation renderObj) {
    renderObj.setLayoutOffset = setLayoutOffset;
    renderObj.scrollable = scrollable;
  }
}

class SliverLogicalContainerParentDataListener extends SliverLogicalContainerParentData {
  RenderSliverPositionAnimation renderSliver;
  SliverLogicalContainerParentDataListener(this.renderSliver);

  @override
  void set layoutOffset(double? value) {
    super.layoutOffset = value;
    renderSliver.parentDataLayoutOffsetChange(value);
  }
}

class SliverPhysicalContainerParentDataListener extends SliverPhysicalContainerParentData {
  RenderSliverPositionAnimation renderSliver;
  SliverPhysicalContainerParentDataListener(this.renderSliver);

  @override
  void set paintOffset(Offset offset) {
    super.paintOffset = offset;
    renderSliver.parentDataLayoutOffsetChange(offset.dy);
  }
}

class RenderSliverPositionAnimation extends RenderSliver with RenderObjectWithChildMixin<RenderSliver> {
  void Function(double) setLayoutOffset;
  ScrollableState scrollable;

  RenderSliverPositionAnimation({
    required this.setLayoutOffset,
    required this.scrollable,
  });

  void set parentData(ParentData? data) {
    if (data is SliverLogicalContainerParentData) {
      super.parentData = SliverLogicalContainerParentDataListener(this);
    } else if (data is SliverPhysicalContainerParentData) {
      super.parentData = SliverPhysicalContainerParentDataListener(this);
    } else {
      super.parentData = data;
    }
  }

  void parentDataLayoutOffsetChange(double? value) {
    if (value == null) {
      setLayoutOffset(0);
      return;
    }

    final constraints = this.constraints as SliverConstraints;
    final scrollPosition = scrollable.position.pixels;

    final expected = constraints.precedingScrollExtent - scrollPosition;
    final layoutOffset = expected - value;
    
    setLayoutOffset(layoutOffset);
  }

  @override
  void performLayout() {
    if (child == null) {
      geometry = SliverGeometry.zero;
      return;
    }
    final SliverConstraints constraints = this.constraints;
    child!.layout(constraints, parentUsesSize: true);
    geometry = child!.geometry!;
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

  @override
  bool hitTestChildren(SliverHitTestResult result, {required double mainAxisPosition, required double crossAxisPosition}) {
    return child != null
      && child!.geometry!.hitTestExtent > 0
      && child!.hitTest(
        result,
        mainAxisPosition: mainAxisPosition,
        crossAxisPosition: crossAxisPosition,
      );
  }
}
