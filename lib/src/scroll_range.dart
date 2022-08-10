import 'package:flutter/widgets.dart';

/// The range used to determine progress in a scroll progress animation.
///
/// The default implementations are available via factor constructors:
///
/// - `ScrollRange.fullRange`: Use this to animate from the moment the widget
///   appears at the bottom to the moment it disappears at the top.
/// - `ScrollRange.fullyVisibleRange`: Use this to animate from the moment the
///   widget is fully visible at the bottom to the moment it is fully visible at
///   the top.
/// - `ScrollRange.topVisibleRange`: Use this to animate from the moment the top
///   of the widget is visible at the bottom of the page to the moment the top
///   of the widget passes the top of the scroll view.
/// - `ScrollRange.centerVisibleRange`: Use this to animate from the moment the
///   center of the widget is visible at the bottom of the page to the moment
///   the center of the widget passes the top of the scroll view.
/// - `ScrollRange.bottomVisibleRange`: Use this to animate from the moment the
///   bottom of the widget is visible at the bottom of the page to the moment
///   the bottom of widget passes the top of the scroll view.
///
/// To set the middle of a range to be 100% progress, use [distanceFrom].
///
/// This class also has methods to refine a scroll range. See [inverse],
/// [subrange], [offset], [withScrollPadding], and [withChildMargin].
///
/// You can use one of these implementations and methods to create your scroll
/// range, or you can create your own entirely custom behavior by extending this
/// class and overriding the behavior of the [progress] method.
abstract class ScrollRange {

  /// Calculate a `progress` value between `0.0` and `1.0` based on offset/size.
  ///
  /// The child size and scroll view size are necessary in order to change
  /// behavior based on not just scroll amount, but also child clipping.
  ///
  /// Clients are allowed to override this method to create their own behavior.
  double progress({
     required double offset,
     required double childExtent,
     required double viewportExtent
  });

  const ScrollRange();

  /// Animations using this will be running from the moment the widget appears
  /// at the bottom of the page to the moment the widget disappears at the top.
  factory ScrollRange.fullRange() => const FullScrollRange();

  /// Animations using this will be running from the moment the widget is fully
  /// visible at the bottom of the page to the moment the widget is fully
  /// visible at the top.
  factory ScrollRange.fullyVisibleRange() => const FullyVisibleScrollRange();

  /// Animations using this will be running from the moment the top of the
  /// widget is visible at the bottom of the page to the moment the top of the
  /// widget passes the top of the scroll view.
  factory ScrollRange.topVisibleRange() => const TopVisibleScrollRange();

  /// Animations using this will be running from the moment the center of the
  /// widget is visible at the bottom of the page to the moment the center of
  /// the widget passes the top of the scroll view.
  factory ScrollRange.centerVisibleRange() => const CenterVisibleScrollRange();

  /// Animations using this will be running from the moment the bottom of the
  /// widget is visible at the bottom of the page to the moment the bottom of
  /// the widget passes the top of the scroll view.
  factory ScrollRange.bottomVisibleRange() => const BottomVisibleScrollRange();

  /// Get a new [ScrollRange] that has the current behavior but is flipped.
  ///
  /// The default [ScrollRange] implementations set progress to 0% at the bottom
  /// of their range, and 100% at the top. For any [ScrollRange], you can get
  /// inverse using this getter.
  ScrollRange get inverse => InverseScrollRange(this);

  /// Get a subrange of this [ScrollRange] with lower and upper thresholds.
  ///
  /// Progress will go from 0% at the bottom of the range, and stay at 0% until
  /// hitting [lowerBound], at which point it begins to rise. It will hit 100%
  /// at [upperBound] and stay there to the top of the range.
  ScrollRange subrange(double lowerBound, double upperBound)
      => SubScrollRange(this, lowerBound, upperBound);

  /// Adjust the offset of the child before evaluating progress.
  ScrollRange offsetChild(double offset) => OffsetScrollRange(this, -offset);

  /// Adjust the offset before evaluating progress.
  ScrollRange offset(double offset) => OffsetScrollRange(this, offset);

  /// Adjust the scroll view's size by subtracting padding, before calculating.
  ScrollRange withScrollViewPadding({double top = 0.0, double bottom = 0.0})
      => ScrollRangeParentPadding(this, top, bottom);

  /// Adjust the child's size by adding padding, before calculating progress.
  ScrollRange withChildMargin({double top = 0.0, double bottom = 0.0})
      => ScrollRangeChildMargin(this, top, bottom);

  /// Evaluate progress as a function of distance from a middle range.
  ///
  /// The new progress will go from 0% at the bottom of the range, to 100% at
  /// [lowerBound], stay at 100% until [upperBound], and then go to 0% at [top].
  ScrollRange distanceFrom(
      double lowerBound,
      double upperBound,
      {double bottom = 0.0, double top = 1.0}
  ) => DistanceFromScrollRange(this,
    top: top,
    upperBound: upperBound,
    lowerBound: lowerBound,
    bottom: bottom,
  );

}

class FullScrollRange extends ScrollRange {
  const FullScrollRange();

  @override
  double progress({
     required double offset,
     required double childExtent,
     required double viewportExtent
  }) {
    final totalScroll = viewportExtent + childExtent;
    final netOffset = offset + childExtent;
    return 1.0 - (netOffset / totalScroll).clamp(0.0, 1.0);
  }
}

class FullyVisibleScrollRange extends ScrollRange {
  const FullyVisibleScrollRange();

  @override
  double progress({
     required double offset,
     required double childExtent,
     required double viewportExtent
  }) {
    final totalScroll = viewportExtent - childExtent;
    final netOffset = offset;
    return 1.0 - (netOffset / totalScroll).clamp(0.0, 1.0);
  }
}

class TopVisibleScrollRange extends ScrollRange {
  const TopVisibleScrollRange();

  @override
  double progress({
     required double offset,
     required double childExtent,
     required double viewportExtent
  }) {
    final totalScroll = viewportExtent;
    final netOffset = offset;
    return 1.0 - (netOffset / totalScroll).clamp(0.0, 1.0);
  }
}

class CenterVisibleScrollRange extends ScrollRange {
  const CenterVisibleScrollRange();

  @override
  double progress({
     required double offset,
     required double childExtent,
     required double viewportExtent
  }) {
    final totalScroll = viewportExtent;
    final netOffset = offset + childExtent / 2;
    return 1.0 - (netOffset / totalScroll).clamp(0.0, 1.0);
  }
}

class BottomVisibleScrollRange extends ScrollRange {
  const BottomVisibleScrollRange();

  @override
  double progress({
     required double offset,
     required double childExtent,
     required double viewportExtent
  }) {
    final totalScroll = viewportExtent;
    final netOffset = offset + childExtent;
    return 1.0 - (netOffset / totalScroll).clamp(0.0, 1.0);
  }
}

class InverseScrollRange extends ScrollRange {
  final ScrollRange inner;

  InverseScrollRange(this.inner);

  @override
  double progress({
     required double offset,
     required double childExtent,
     required double viewportExtent
  }) {
    return 1.0 - inner.progress(offset: offset, childExtent: childExtent,
        viewportExtent: viewportExtent);
  }
}

class ScrollRangeChildMargin extends ScrollRange {
  final double marginTop;
  final double marginBottom;
  final ScrollRange inner;

  ScrollRangeChildMargin(this.inner, this.marginTop, this.marginBottom);

  @override
  double progress({
     required double offset,
     required double childExtent,
     required double viewportExtent
  }) {
    return inner.progress(offset: offset - marginTop, childExtent: childExtent,
        viewportExtent: viewportExtent - marginBottom);
  }
}

class ScrollRangeParentPadding extends ScrollRange {
  final double paddingTop;
  final double paddingBottom;
  final ScrollRange inner;

  ScrollRangeParentPadding(this.inner, this.paddingTop, this.paddingBottom);

  @override
  double progress({
     required double offset,
     required double childExtent,
     required double viewportExtent
  }) {
    return inner.progress(offset: offset + paddingTop, childExtent: childExtent,
        viewportExtent: viewportExtent - paddingBottom);
  }
}

class OffsetScrollRange extends ScrollRange {
  final double offsetAdjustment;
  final ScrollRange inner;

  OffsetScrollRange(this.inner, this.offsetAdjustment);

  @override
  double progress({
     required double offset,
     required double childExtent,
     required double viewportExtent
  }) {
    return inner.progress(offset: offset - offsetAdjustment, childExtent: childExtent,
        viewportExtent: viewportExtent);
  }
}

class DistanceFromScrollRange extends ScrollRange {
  final double bottom;
  final double lowerBound;
  final double upperBound;
  final double top;
  final ScrollRange inner;

  DistanceFromScrollRange(this.inner, {
     required this.lowerBound,
     required this.upperBound,
     required this.top,
     required this.bottom,
  });

  @override
  double progress({
     required double offset,
     required double childExtent,
     required double viewportExtent
  }) {
    final innerProgress = inner.progress(offset: offset, childExtent: childExtent,
        viewportExtent: viewportExtent);

    if (innerProgress <= bottom || innerProgress >= top) {
      return 0.0;
    } else if (innerProgress >= lowerBound && innerProgress <= upperBound) {
      return 1.0;
    } else if (innerProgress < lowerBound) {
      final gap = lowerBound - bottom;
      return (innerProgress - bottom) / gap;
    } else {
      assert(innerProgress > upperBound);
      final gap = top - upperBound;
      return (top - innerProgress) / gap;
    }
  }
}

class SubScrollRange extends ScrollRange {
  final double lowerBound;
  final double upperBound;
  final ScrollRange inner;

  SubScrollRange(this.inner, this.lowerBound, this.upperBound);

  @override
  double progress({
     required double offset,
     required double childExtent,
     required double viewportExtent
  }) {
    final innerProgress = inner.progress(offset: offset, childExtent: childExtent,
        viewportExtent: viewportExtent);

    if (innerProgress <= lowerBound) {
      return 0.0;
    } else if (innerProgress >= upperBound) {
      return 1.0;
    } else {
      final gap = upperBound - lowerBound;
      return (innerProgress - lowerBound) / gap;
    }
  }
}

