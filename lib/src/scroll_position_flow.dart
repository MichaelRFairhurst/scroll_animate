import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

class ScrollPositionFlow extends StatelessWidget {
  final Matrix4 Function(Offset)? buildTransform;
  final double Function(Offset)? buildOpacity;
  final Clip clipBehavior;
  final Alignment transformAlignment;
  final Widget? child;

  const ScrollPositionFlow({
    Key? key,
    this.buildTransform,
    this.buildOpacity,
    this.clipBehavior = Clip.none,
    this.transformAlignment = Alignment.center,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (child == null) {
      return Container();
    }

    return _ScrollPositionFlowSubclass(
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

class EntranceAnimationFlow extends StatefulWidget {
  final Widget child;
  final Animatable<Matrix4> matrixTween;
  final Animatable<double> opacityTween;
  final Alignment transformAlignment;
  final Clip clipBehavior;

  const EntranceAnimationFlow({
    Key? key,
    required this.child,
    required this.opacityTween,
    required this.matrixTween,
    this.transformAlignment = Alignment.center,
    this.clipBehavior = Clip.none,
  }) : super(key: key);

  @override
  EntranceAnimationFlowState createState() => EntranceAnimationFlowState();
}

class EntranceAnimationFlowState extends State<EntranceAnimationFlow> with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return _ScrollPositionFlowSubclass(
      children: [widget.child],
      clipBehavior: widget.clipBehavior,
      delegate: EntranceAnimationFlowDelegate(
        matrixTween: widget.matrixTween,
        opacityTween: widget.opacityTween,
        transformAlignment: widget.transformAlignment,
        repaint: controller,
      ),
    );
  }
}

class EntranceAnimationFlowDelegate extends FlowDelegate {
  final Animatable<Matrix4> matrixTween;
  final Animatable<double> opacityTween;
  final Alignment transformAlignment;

  EntranceAnimationFlowDelegate({
    required this.matrixTween,
    required this.opacityTween,
    required this.transformAlignment,
    required Listenable repaint,
  }) : super(repaint: repaint);

  @override
  void paintChildren(FlowPaintingContext context) {
    // TODO: implement paintChildren
  }

  @override
  bool shouldRepaint(covariant FlowDelegate oldDelegate) {
    // TODO: implement shouldRepaint
    throw UnimplementedError();
  }


}

class _ScrollPositionFlowSubclass extends Flow {
  _ScrollPositionFlowSubclass({
    Key? key,
    required List<Widget> children,
    required FlowDelegate delegate,
    required Clip clipBehavior,
  }) : super(
    key: key,
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
    required this.scrollable,
    required this.buildTransform,
    required this.buildOpacity,
    required this.transformAlignment,
  }) : super(repaint: scrollable.position);

  // TODO: should this be false? Check build functions?
  @override
  bool shouldRepaint(ScrollPositionFlowDelegate oldDelegate) => true;

  @override
  Size getSize(BoxConstraints constraints) => const Size(0, 0);

  @override
  void paintChildren(FlowPaintingContext context) {
    final scrollPositionFlowRenderObject = this.context.findRenderObject() as RenderBox;
    final scrollableRenderObject = scrollable.context.findRenderObject();

    final offset = scrollPositionFlowRenderObject.localToGlobal(
        const Offset(0, 0),
        ancestor: scrollableRenderObject,
    );

    final size = context.getChildSize(0)!;
    final translation = transformAlignment.alongSize(size);
    final transform =
        Matrix4.translationValues(translation.dx, translation.dy, 0)
          ..multiply(buildTransform(offset))
          ..translate(-translation.dx, -translation.dy);

    context.paintChild(
        0,
        opacity: buildOpacity(offset),
        transform: transform,
    );
  }
}
