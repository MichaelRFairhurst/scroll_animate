import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

class ScrollPositionFlow extends StatelessWidget {
  Matrix4 Function(Offset)? buildTransform;
  double Function(Offset)? buildOpacity;
  final Clip clipBehavior;
  final Alignment transformAlignment;
  Widget? child;

  ScrollPositionFlow({
    this.buildTransform,
    this.buildOpacity,
    this.clipBehavior = Clip.none,
    this.transformAlignment = Alignment.center,
    this.child,
  });

  Widget build(BuildContext context) {
    if (child == null) {
      return Container();
    }

    return ScrollPositionFlowSubclass(
      children: <Widget>[child!],
      clipBehavior: clipBehavior,
      delegate: ScrollPositionFlowDelegate(
        context: context,
        scrollable: Scrollable.of(context)!,
        buildTransform: buildTransform ?? (_) => Matrix4.identity(),
        buildOpacity: buildOpacity ?? (_) => 1.0,
        transformAlignment: transformAlignment,
      ),
    );
  }
}

class ScrollPositionFlowSubclass extends Flow {
  ScrollPositionFlowSubclass({
    required List<Widget> children,
    required FlowDelegate delegate,
    required Clip clipBehavior,
  }) : super(
    children: children,
    delegate: delegate,
    clipBehavior: clipBehavior,
  );

  @override
  RenderScrollPositionFlow createRenderObject(BuildContext context) {
    return RenderScrollPositionFlow(delegate: delegate, clipBehavior: clipBehavior);
  }
}

class RenderScrollPositionFlow extends RenderFlow {

  RenderScrollPositionFlow({
    List<RenderBox>? children,
    required FlowDelegate delegate,
    required Clip clipBehavior,
  }) : super(children: children, delegate: delegate, clipBehavior: clipBehavior);

  @override
  void performLayout() {
    super.performLayout();

    if (firstChild != null) {
      size = firstChild!.size;
    }
  }
}

class ScrollPositionFlowDelegate extends FlowDelegate {
  BuildContext context;
  ScrollableState scrollable;
  Matrix4 Function(Offset) buildTransform;
  double Function(Offset) buildOpacity;
  Alignment transformAlignment;

  ScrollPositionFlowDelegate({
    required this.context,
    required ScrollableState scrollable,
    required this.buildTransform,
    required this.buildOpacity,
    required this.transformAlignment,
  }) : scrollable = scrollable
    , super(repaint: scrollable.position);

  // TODO: should this be false? Check build functions?
  @override
  bool shouldRepaint(ScrollPositionFlowDelegate oldDelegate) => true;

  @override
  Size getSize(BoxConstraints constraints) => Size(0, 0);

  @override
  void paintChildren(FlowPaintingContext context) {
    final scrollPositionFlowRenderObject = this.context.findRenderObject() as RenderBox;
    final scrollableRenderObject = scrollable.context.findRenderObject();

    final offset = scrollPositionFlowRenderObject.localToGlobal(
        Offset(0, 0),
        ancestor: scrollableRenderObject,
    );

    final size = context.getChildSize(0)!;
    final translation = transformAlignment.alongSize(size);
    final transform =
        Matrix4.translationValues(translation.dx, translation.dy / 2, 0)
          ..multiply(buildTransform(offset))
          ..translate(-translation.dx, -translation.dy);
  
    context.paintChild(
        0,
        opacity: buildOpacity(offset),
        transform: transform,
    );
  }
}
