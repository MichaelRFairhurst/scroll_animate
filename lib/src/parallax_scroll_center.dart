/// Determines whether a [ParallaxScrollCenter] is relative or absolute.
///
/// See [ParallaxScrollCenter].
enum ParallaxOffsetType {
  relativePixels,
  absolutePixels,
}

/// Defines when a [SliverParallax] hits center in the scrollview.
///
/// A [SliverParallax] has a "neutral" position which defaults to (0, 0) but is
/// configurable via it's `offset`. As the user scrolls, the [SliverParallax]
/// either faster or slower than the rest of the scrollview, (and perhaps in
/// the cross axis direction). The [SliverParallax] will hit the "neutral"
/// position at some scroll amount. This class defines that scroll amount.
///
/// For convenience in designing parallax UIs, a relative offset is allowed,
/// which is based on the scroll position the sliver would have if it were
/// not a special parallax effect.
///
/// However, an absolute offset is also allowed. This is especially useful as
/// a means of setting a background at scroll position 0, since slivers are
/// painted in reverse order. If the last sliver has a scroll center of 0 then
/// it will be painted below all others but still aligned with the top of the
/// scroll.
class ParallaxScrollCenter {
  final double value;
  final ParallaxOffsetType type;

  /// Construct a [ParallaxScrollCenter] from values.
  ParallaxScrollCenter(
    this.value,
    this.type,
  );

  /// Construct a [ParallaxScrollCenter] with an absolute pixel offset.
  ParallaxScrollCenter.absolutePx(
    this.value,
  ) : type = ParallaxOffsetType.absolutePixels;

  /// Construct a [ParallaxScrollCenter] with an absolute pixel offset.
  ParallaxScrollCenter.relativePx(
    this.value,
  ) : type = ParallaxOffsetType.relativePixels;

  /// Get the pixel offset of the scroll center.
  ///
  /// The [precedingScroll] allows relative scroll centers to use their natural
  /// scroll offset as a base.
  double centerPixelValue(double precedingScroll) {
    switch (type) {
      case ParallaxOffsetType.relativePixels:
        return precedingScroll + value;
      case ParallaxOffsetType.absolutePixels:
        return value;
    }
  }
}
