import 'package:flutter/widgets.dart';
import 'package:scroll_animate/src/shrink_flow.dart';

/// Paint a widget based on its offset relative to a parent context.
///
/// Allows the same transformations as the [Flow] widget, so transforms
/// and opacity.
///
/// Note that the offset and size will be the layouted offset & size,
/// so scaling/translating the child does not affect these offsets, making
/// performant renders tractable.
class ParentOffsetFlow extends StatelessWidget {
  final Matrix4 Function(Offset, {required Size childSize, required Size parentSize})? buildTransform;
  final double Function(Offset, {required Size childSize, required Size parentSize})? buildOpacity;
  final Clip clipBehavior;
  final Alignment transformAlignment;
  final Widget child;
  final Listenable? repaint;
  final BuildContext parentContext;
  final BoxConstraints? childBoxConstraints;

  const ParentOffsetFlow({
    Key? key,
    this.buildTransform,
    this.buildOpacity,
    this.clipBehavior = Clip.none,
    this.transformAlignment = Alignment.center,
    required this.child,
    this.childBoxConstraints,
    this.repaint,
    required this.parentContext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShrinkFlow(
      child: child,
      clipBehavior: clipBehavior,
      delegate: _ParentOffsetFlowDelegate(
        context: context,
        parentContext: parentContext,
        buildTransform: buildTransform ?? (_, {Size? childSize, Size? parentSize}) => Matrix4.identity(),
        buildOpacity: buildOpacity ?? (_, {Size? childSize, Size? parentSize}) => 1.0,
        transformAlignment: transformAlignment,
        childBoxConstraints: childBoxConstraints,
        repaint: repaint,
      ),
    );
  }
}

class _ParentOffsetFlowDelegate extends FlowDelegate {
  final BuildContext context;
  final BuildContext parentContext;
  final Matrix4 Function(Offset, {required Size childSize, required Size parentSize}) buildTransform;
  final double Function(Offset, {required Size childSize, required Size parentSize}) buildOpacity;
  final Alignment transformAlignment;
  final BoxConstraints? childBoxConstraints;

  _ParentOffsetFlowDelegate({
    required this.context,
    required this.parentContext,
    required this.buildTransform,
    required this.buildOpacity,
    required this.transformAlignment,
    this.childBoxConstraints,
    Listenable? repaint,
  }) : super(repaint: repaint);

  // TODO: should this be false? Check build functions?
  @override
  bool shouldRepaint(_ParentOffsetFlowDelegate oldDelegate) => true;

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints outer) {
    return childBoxConstraints ?? outer;
  }

  @override
  Size getSize(BoxConstraints constraints) => const Size(0, 0);

  @override
  void paintChildren(FlowPaintingContext context) {
    final flowRenderObject = this.context.findRenderObject() as RenderBox;
    final parentRenderObject = parentContext.findRenderObject() as RenderBox;

    final offset = flowRenderObject.localToGlobal(
        const Offset(0, 0),
        ancestor: parentRenderObject,
    );

    final size = context.getChildSize(0)!;
    final translation = transformAlignment.alongSize(size);
    final transform =
        Matrix4.translationValues(translation.dx, translation.dy, 0)
          ..multiply(buildTransform(offset, childSize: size, parentSize: parentRenderObject.size))
          ..translate(-translation.dx, -translation.dy);

    context.paintChild(
        0,
        opacity: buildOpacity(offset, childSize: size, parentSize: parentRenderObject.size),
        transform: transform,
    );
  }
}
