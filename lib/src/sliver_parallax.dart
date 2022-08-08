import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:scroll_animate/src/parallax_scroll_center.dart';
import 'package:scroll_animate/src/render_sliver_parallax.dart';

/// A sliver that scrolls faster or slower than other scroll contents.
///
/// Often used to create a depth effect, but also creates a visual surprise
/// when contents unexpectedly line up in interesting ways while scrolling.
///
/// Provide a child for the widget that will move at a parallax. Then to
/// reduce its scroll rate, provide a `mainAxisFactor` less than `1.0`. To
/// make it scroll faster, provide a factor greater than `1.0` or make it
/// scroll the opposite direction with a negative factor. You can also give
/// a `crossAxisFactor` to make it move perpendicular to the scroll direction.
///
/// By default, this paints the child at (0, 0) when the next sliver in the
/// scrollview is scrolled to the top of the view. This is the "neutral"
/// position of this [SliverParallax] and can be adjusted in two ways.
///
/// To change the amount of scrolling required to hit "neutral" position, see
/// [ParallaxScrollCenter], and provide a custom relative or absolute offset.
///
/// To change where on the screen this widget is painted at the neutral scroll
/// amount, provide an `Offset`.
class SliverParallax extends SingleChildRenderObjectWidget {
  final Widget child;
  final double mainAxisFactor;
  final double crossAxisFactor;
  final double scrollExtent;
  final Offset offset;
  final ParallaxScrollCenter center;

  /// Create a [SliverParallax].
  ///
  /// `child`: the widget that will move at a parallax.
  ///
  /// `mainAxisFactor`: Adjust scroll rate. To reduce scroll rate, this should
  /// be less than `1.0`. To increase it, this should be greater than `1.0`. A
  /// negative value will scroll in the opposite direction. 
  ///
  /// `crossAxisFactor`: Move perpendicular to the scroll direction.
  ///
  /// `center`: Optional. Sets the amount of scrolling required to hit "neutral"
  /// position. See [ParallaxScrollCenter]. Defaults to a relative 0px offset.
  ///
  /// `offset`: Optional. Where to paint this at the "neutral" scroll position.
  /// Defaults to (0, 0).
  ///
  /// `scrollExtent`: Optional. Set the scroll extent on the sliver geometry
  /// for this sliver. This has the effect of stopping other widgets from
  /// scrolling temporarily when this sliver hits the top of the scroll view.
  SliverParallax({
    this.mainAxisFactor = 1.0,
    this.crossAxisFactor = 0.0,
    this.scrollExtent = 0.0,
    this.offset = const Offset(0, 0),
    ParallaxScrollCenter? center,
    required this.child,
  })
    : center = center ?? ParallaxScrollCenter.relativePx(0.0);

  @override
  RenderObject createRenderObject(BuildContext context)
      => RenderSliverParallax(
           mainAxisFactor: mainAxisFactor,
           crossAxisFactor: crossAxisFactor,
           scrollExtent: scrollExtent,
           scrollable: Scrollable.of(context)!,
           offset: offset,
           center: center,
         );

  @override
  void updateRenderObject(BuildContext context, RenderSliverParallax renderObject) {
    renderObject.mainAxisFactor = mainAxisFactor;
    renderObject.crossAxisFactor = crossAxisFactor;
    renderObject.scrollExtent = scrollExtent;
    renderObject.scrollable = Scrollable.of(context)!;
    renderObject.offset = offset;
    renderObject.center = center;
  }
 
}

