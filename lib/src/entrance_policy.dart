import 'package:flutter/rendering.dart';

abstract class EntrancePolicy {
  bool visible(SliverConstraints constraints, SliverGeometry geometry);

  EntrancePolicy();
  factory EntrancePolicy.anythingVisible() => AnythingVisiblePolicy();
  factory EntrancePolicy.scrollBeyondBottomEdge() => ScrolledBeyondBottomEdgePolicy();
  factory EntrancePolicy.scrollBeyondTopEdge() => ScrolledBeyondTopEdgePolicy();
  factory EntrancePolicy.topEdgeVisible() => TopEdgeVisiblePolicy();
  factory EntrancePolicy.bottomEdgeVisible() => BottomEdgeVisiblePolicy();
  factory EntrancePolicy.completelyVisible()
      => BooleanAndPolicy(BottomEdgeVisiblePolicy(), TopEdgeVisiblePolicy());
}

class BooleanAndPolicy extends EntrancePolicy {
  final EntrancePolicy a;
  final EntrancePolicy b;

  BooleanAndPolicy(this.a, this.b);

  bool visible(SliverConstraints constraints, SliverGeometry geometry)
      => a.visible(constraints, geometry) && b.visible(constraints, geometry);
}

class AnythingVisiblePolicy extends EntrancePolicy {
  bool visible(SliverConstraints constraints, SliverGeometry geometry) {
    return geometry.paintExtent > 0.0;
  }
}

class ScrolledBeyondBottomEdgePolicy extends EntrancePolicy {
  bool visible(SliverConstraints constraints, SliverGeometry geometry) {
    return geometry.paintExtent < constraints.remainingPaintExtent;
  }
}

class BottomEdgeVisiblePolicy extends EntrancePolicy {
  bool visible(SliverConstraints constraints, SliverGeometry geometry) {
    return geometry.paintExtent < constraints.remainingPaintExtent && geometry.paintExtent > 0.0;
  }
}

class TopEdgeVisiblePolicy extends EntrancePolicy {
  bool visible(SliverConstraints constraints, SliverGeometry geometry) {
    return geometry.paintExtent > 0.0 && constraints.scrollOffset == 0.0;
  }
}

class ScrolledBeyondTopEdgePolicy extends EntrancePolicy {
  bool visible(SliverConstraints constraints, SliverGeometry geometry) {
    return geometry.paintExtent > 0.0 || constraints.scrollOffset > 0.0;
  }
}

