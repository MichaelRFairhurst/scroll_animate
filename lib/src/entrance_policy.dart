import 'package:flutter/rendering.dart';

/// Defines the criteria for determining sliver visibility.
///
/// Used by the entrance animation slivers in this library. An interface may
/// wish to begin an animation when the widget is partially visible, fully
/// visible, or something else entirely.
///
/// This is done by analyzing the [SliverConstraints] and [SliverGeometry] of
/// the child. Any behavior based on these values is possible by implementing
/// this interface.
///
/// There are also a few reasonable preset behaviors here via factory
/// constructors:
/// - `EntrancePolicy.anythingVisible()`: Any part of the sliver is visible.
/// - `EntrancePolicy.completelyVisible()`: All of the sliver is visible.
/// - `EntrancePolicy.topEdgeVisible()`: The top of the sliver is visible.
/// - `EntrancePolicy.bottomEdgeVisible()`: The bottom of the sliver is visible.
/// - `EntrancePolicy.scrolledBeyondBottomEdge()`: The scroll view includes, or
///   has scrolled past, the bottom of this sliver. This intentionally considers
///   the sliver visible while the user has scrolled past it; in a
///   [SliverEntranceAnimation] this means the animation does not occur when the
///   user scrolls back up to this sliver, only when they scroll down to it.
/// - `EntrancePolicy.scrolledBeyondTopEdge()`: The scroll view includes, or
///   has scrolled past, the top of this sliver. This intentionally considers
///   the sliver visible while the user has scrolled past it; in a
///   [SliverEntranceAnimation] this means the animation does not occur when the
///   user scrolls back up to this sliver, only when they scroll down to it.
abstract class EntrancePolicy {
  /// Check that any part of the sliver is visible.
  factory EntrancePolicy.anythingVisible() => AnythingVisiblePolicy();

  /// Check that the user has scrolled down to the point where the bottom edge
  /// became visible. This intentionally considers the sliver visible while the
  /// user has scrolled past it; in a [SliverEntranceAnimation] this means the
  /// animation does not occur when the user scrolls back up to this sliver,
  /// only when they scroll down to it.
  factory EntrancePolicy.scrollBeyondBottomEdge() => ScrolledBeyondBottomEdgePolicy();

  /// Check that the user has scrolled down to the point where the bottom edge
  /// became visible. This intentionally considers the sliver visible while the
  /// user has scrolled past it; in a [SliverEntranceAnimation] this means the
  /// animation does not occur when the user scrolls back up to this sliver,
  /// only when they scroll down to it.
  factory EntrancePolicy.scrollBeyondTopEdge() => ScrolledBeyondTopEdgePolicy();

  /// Check that the top of this sliver is visible.
  factory EntrancePolicy.topEdgeVisible() => TopEdgeVisiblePolicy();

  /// Check that the bottom of this sliver is visible.
  factory EntrancePolicy.bottomEdgeVisible() => BottomEdgeVisiblePolicy();

  /// Check that all parts of this sliver is visible.
  factory EntrancePolicy.completelyVisible()
      => BooleanAndPolicy(BottomEdgeVisiblePolicy(), TopEdgeVisiblePolicy());

  /// Whether the sliver is deemed visible by this policy.
  bool visible(SliverConstraints constraints, SliverGeometry geometry);

}

/// An [EntrancePolicy] that checks two inner policies are both satisfied.
class BooleanAndPolicy implements EntrancePolicy {
  final EntrancePolicy a;
  final EntrancePolicy b;

  BooleanAndPolicy(this.a, this.b);

  bool visible(SliverConstraints constraints, SliverGeometry geometry)
      => a.visible(constraints, geometry) && b.visible(constraints, geometry);
}

/// An [EntrancePolicy] that checks that any part of the sliver is visible.
class AnythingVisiblePolicy implements EntrancePolicy {
  bool visible(SliverConstraints constraints, SliverGeometry geometry) {
    return geometry.paintExtent > 0.0;
  }
}

/// Checks that the user has scrolled down to or past the sliver's bottom edge.
///
/// This intentionally considers the sliver visible while the user has scrolled
/// past it; in a [SliverEntranceAnimation] this means the animation does not
/// occur when the user scrolls back up to this sliver, only when they scroll
/// down to it.
class ScrolledBeyondBottomEdgePolicy implements EntrancePolicy {
  bool visible(SliverConstraints constraints, SliverGeometry geometry) {
    return geometry.paintExtent < constraints.remainingPaintExtent;
  }
}

/// An [EntrancePolicy] that checks that the bottom of the sliver is visible.
class BottomEdgeVisiblePolicy implements EntrancePolicy {
  bool visible(SliverConstraints constraints, SliverGeometry geometry) {
    return geometry.paintExtent < constraints.remainingPaintExtent && geometry.paintExtent > 0.0;
  }
}

/// An [EntrancePolicy] that checks that the top of the sliver is visible.
class TopEdgeVisiblePolicy implements EntrancePolicy {
  bool visible(SliverConstraints constraints, SliverGeometry geometry) {
    return geometry.paintExtent > 0.0 && constraints.scrollOffset == 0.0;
  }
}

/// Checks that the user has scrolled down to or past the sliver's top edge.
///
/// This intentionally considers the sliver visible while the user has scrolled
/// past it; in a [SliverEntranceAnimation] this means the animation does not
/// occur when the user scrolls back up to this sliver, only when they scroll
/// down to it.
class ScrolledBeyondTopEdgePolicy implements EntrancePolicy {
  bool visible(SliverConstraints constraints, SliverGeometry geometry) {
    return geometry.paintExtent > 0.0 || constraints.scrollOffset > 0.0;
  }
}

