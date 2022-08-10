import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

/// Fixes the fact that Flow usually fills the constraints.
///
/// Instead, this takes a single child and sizes itself to that child.
///
/// This is not a complete, well thought-out implementation, but a bare
/// minimum useful to this library.
class ShrinkFlow extends Flow {

  ShrinkFlow({
    Key? key,
    required Widget child,
    required FlowDelegate delegate,
    required Clip clipBehavior,
  }) : super(
    key: key,
    children: <Widget>[child],
    delegate: delegate,
    clipBehavior: clipBehavior,
  );

  @override
  RenderShrinkFlow createRenderObject(BuildContext context) {
    return RenderShrinkFlow(delegate: delegate, clipBehavior: clipBehavior);
  }
}

class RenderShrinkFlow extends RenderFlow {

  RenderShrinkFlow({
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
