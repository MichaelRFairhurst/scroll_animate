import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

/// A widget that animates its child based on its position in a scroll view.
///
/// The type parameter [T] refers to the type of the value that is being
/// animated. For instance, to animate opacity you would construct a
/// `SliverPositionAnimation<double>`.
///
/// The value will be animated through a range based on the provided tween,
/// and as the value changes, the [builder] function will be invoked with the
/// current value to create the widget that is rendered. The begin value
/// is used when the widget is at the bottom of the screen, and end value is
/// used when the sliver is at the top of the screen.
class SliverPositionAnimation<T> extends RenderObjectWidget {
  final Widget Function(BuildContext, double)? builder;
  final Widget Function(BuildContext, double)? sliverBuilder;

  final Curve curve;
  final Tween<T> tween;

  SliverPositionAnimation({
    Key? key,
    this.curve = Curves.linear,
    required this.tween,
    Widget Function(BuildContext, double)? builder,
    Widget Function(BuildContext, double)? sliverBuilder,
  })
    : builder = builder
    , sliverBuilder = sliverBuilder
    , assert(builder != null || sliverBuilder != null, "Must provide either a builder or a sliver builder.")
    , assert(builder == null || sliverBuilder == null, "Cannot provide both a builder and a sliver builder at once.")
    , super(key: key);

  @override
  SliverPositionAnimationElement createElement() => SliverPositionAnimationElement(this);

  Widget _doBuild(BuildContext context, double layoutOffset, SliverConstraints constraints) {
    final scrollable = Scrollable.of(context)!;
    final viewportExtent = constraints.viewportMainAxisExtent;
    final precedingExtent = constraints.precedingScrollExtent;
    final localOffset = (precedingExtent - scrollable.position.pixels - layoutOffset).clamp(0, viewportExtent);
    final progress = 1.0 - localOffset / viewportExtent;

    final animationValue = tween.transform(curve.transform(progress));

    if (builder != null) {
      return SliverToBoxAdapter(
        child: builder!(context, progress),
      );
    } else {
      return sliverBuilder!(context, progress);
    }
  }

  @override
  RenderSliverPositionAnimation createRenderObject(BuildContext context) {
    return RenderSliverPositionAnimation(
      scrollable: Scrollable.of(context)!,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderSliverPositionAnimation renderObj) {
    renderObj.scrollable = Scrollable.of(context)!;
  }
}

class SliverPositionAnimationElement extends RenderObjectElement {
  SliverPositionAnimationElement(
    SliverPositionAnimation widget
  ) : super(widget);

  @override
  RenderSliverPositionAnimation get renderObject => super.renderObject as RenderSliverPositionAnimation;

  Element? _child;

  @override
  void visitChildren(ElementVisitor visitor) {
    if (_child != null)
      visitor(_child!);
  }

  @override
  void forgetChild(Element child) {
    assert(child == _child);
    _child = null;
    super.forgetChild(child);
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot); // Creates the renderObject.
    renderObject.layoutCallback = layoutCallback;
  }

  @override
  void update(SliverPositionAnimation newWidget) {
    assert(widget != newWidget);
    super.update(newWidget);
    assert(widget == newWidget);

    renderObject.layoutCallback = layoutCallback;
    // Force the callback to be called, even if the layout constraints are the
    // same, because the logic in the callback might have changed.
    renderObject.markNeedsBuild();
  }

  @override
  void performRebuild() {
    // This gets called if markNeedsBuild() is called on us.
    // That might happen if, e.g., our builder uses Inherited widgets.

    // Force the callback to be called, even if the layout constraints are the
    // same. This is because that callback may depend on the updated widget
    // configuration, or an inherited widget.
    renderObject.markNeedsBuild();
    super.performRebuild(); // Calls widget.updateRenderObject (a no-op in this case).
  }

  @override
  void unmount() {
    renderObject.layoutCallback = null;
    super.unmount();
  }

  void layoutCallback(double layoutOffset) {
    void buildCallback() {
      Widget built;
      try {
        built = (widget as SliverPositionAnimation)._doBuild(this, layoutOffset, renderObject.constraints as SliverConstraints);
      } catch (e, stack) {
        built = ErrorWidget.builder(
          FlutterErrorDetails(
            exception: e,
            context: ErrorDescription('building $widget'),
            stack: stack,
            library: "scroll_animate",
          ),
        );
      }
      try {
        _child = updateChild(_child, built, null);
        assert(_child != null);
      } catch (e, stack) {
        built = ErrorWidget.builder(
          FlutterErrorDetails(
            exception: e,
            context: ErrorDescription('building $widget'),
            stack: stack,
            library: "scroll_animate",
          ),
        );
        _child = updateChild(null, built, slot);
      }
    }

    visitAncestorElements((element) {
      assert(element is RenderObjectElement, "Unexpected parent element $element");
      if (element is RenderObjectElement) {
        element.renderObject.invokeLayoutCallback((constraints) {
          element.owner!.buildScope(this, buildCallback);
        });
      }
      return false;
    });
  }

  @override
  void insertRenderObjectChild(RenderObject child, Object? slot) {
    final RenderObjectWithChildMixin<RenderObject> renderObject = this.renderObject;
    assert(slot == null);
    assert(renderObject.debugValidateChild(child));
    renderObject.child = child;
    assert(renderObject == this.renderObject);
  }

  @override
  void moveRenderObjectChild(RenderObject child, Object? oldSlot, Object? newSlot) {
    assert(false);
  }

  @override
  void removeRenderObjectChild(RenderObject child, Object? slot) {
    final renderObject = this.renderObject;
    assert(renderObject.child == child);
    renderObject.child = null;
    assert(renderObject == this.renderObject);
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
  void Function(double)? _layoutCallback;
  ScrollableState _scrollable;
  bool _needsBuild = true;
  double previousLayoutOffset = 0.0;

  RenderSliverPositionAnimation({
    required ScrollableState scrollable,
  }) : _scrollable = scrollable {
    scrollable.position.addListener(markNeedsBuild);
  }

  void set layoutCallback(void Function(double)? callback) {
    if (callback == _layoutCallback) {
      return;
    }
    _layoutCallback = callback;
    markNeedsLayout();
  }

  void set scrollable(ScrollableState scrollable) {
    if (!identical(scrollable, _scrollable)) {
      scrollable.position.removeListener(markNeedsBuild);
      markNeedsBuild();
    }
    _scrollable = scrollable;
    scrollable.position.addListener(markNeedsBuild);
  }

  ScrollableState get scrollable => _scrollable;

  void markNeedsBuild() {
    _needsBuild = true;
    markNeedsLayout();
  }

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
      rebuildIfNecessary(0.0);
      return;
    }

    final constraints = this.constraints as SliverConstraints;
    final scrollPosition = scrollable.position.pixels;

    final expected = constraints.precedingScrollExtent - scrollPosition;
    final layoutOffset = expected - value;
    
    rebuildIfNecessary(layoutOffset);
  }

  void rebuildIfNecessary(double layoutOffset) {
    if (_needsBuild || previousLayoutOffset != layoutOffset) {
      _needsBuild = false;
      previousLayoutOffset = layoutOffset;
      _layoutCallback!(layoutOffset);
    }
  }

  @override
  void performLayout() {
    rebuildIfNecessary(previousLayoutOffset);
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
