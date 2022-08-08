# scroll_animate

A library to provide fancy scroll effects such as parallax and animation.

![22-08-07-01-47-44_AdobeExpress](https://user-images.githubusercontent.com/1627771/183283024-190b5d3b-8bdf-49bf-a32d-8a94b0f75b9c.gif)

## Usage

Most of the widgets in this library are implemented as Slivers. This means they will work in
infinite scroll contexts and alongside other fancy scrolling widgets such as Fluter's
`SliverAppBar`. All you have to do is put them into a `CustomScrollView` and that will work!

```dart
Widget build(BuildContext context) {
  return CustomScrollView(
    slivers: <Widget>[
      // Any scroll_animate widgets that start with `Sliver` here!
      SliverEntranceAnimation(...),
      SliverSuspendedAnimation(...),
    ],
  );
}
```

These can be mixed with any other slivers, such as the core Flutter slivers.


```dart
    slivers: <Widget>[
      // Any core flutter slivers such as a SliverAppBar
      SliverAppBar(...),
      SliverPadding(...),

      // Normal lists & grids. Note, these do NOT currently support
      // animating their children, due to API limitations.
      SliverList(...),
      SliverGrid(...)

      // Don't forget SliverToBoxAdapter, which allows you to put
      // regular (non-sliver) widgets in the scrollview too!
      SliverToBoxAdapter(
        child: ... // any regular, non-sliver flutter widget
      ),
    ],
```

## Widgets

### SliverEnterExitCallback

_Note: If your goal is to simply animate a widget on enter / exit, see
`SliverEntranceAnimation`._

Provide callbacks to perform when a widget enters or exits the scroll view.

By default, it will fire callbacks whenever any part of the widget becomes
visible, or the entire widget is offscreen. To change this behavior, use a
different `EntrancePolicy`.

```dart
SliverEnterExitCallback(
  onEnter: () { ... },
  onExit: () { ... },
  child: Container(...),
)
```

The child widget must be a normal box widget. To use this on another sliver, use
`SliverEnterExitCallbackWrapper`.

### SliverEnterExitCallbackWrapper

A version of `SliverEnterExitCallback` which accepts a `Sliver` as a child.

```dart
SliverEnterExitCallbackWrapper(
  onEnter: () { ... },
  onExit: () { ... },
  child: SliverList(...),
)
```

### SliverEntranceAnimation

![sliver_entrance_animation_demo_AdobeExpress](https://user-images.githubusercontent.com/1627771/183282592-29cb1ec9-c2a1-4975-911e-4527a80db0bf.gif)

Perform an animation when a sliver enters/exits the scrollview. All you need to
do is specify a type parameter (for instance, `double` for animating opacity, or
`Color` for animating colors), a tween for the animation, and a `builder` to
build your widget with the current animation value.

By default, it will begin animations whenever any part of the widget becomes
visible, or the entire widget is offscreen. To change this behavior, use a
different `EntrancePolicy`.

```dart
// Provide a type argument for what you're animating.
SliverEntranceAnimation<double>(
  duration: const Duration(seconds: 1),
  curve: Curves.ease, // Optional

  // Provide a builder function for the current animation value.
  builder: (BuildContext context, double opacity, Widget? _) {
    return Opacity(
      opacity: opacity,
      child: ...,
    );
  },

  // Provide a Tween for the animation value range
  tween: Tween(
    begin: 0.0, // Transparent before scrolled into view
    end: 1.0, // Opaque after scrolled into view
  ),

  // Optional: provide an EntrancePolicy
  entrancePolicy: EntrancePolicy.completelyVisible(),
)
```

For performance reasons, you may specify a `child` widget which is not rebuilt
on animation. This is then passed into the `builder` callback.

To wrap another sliver (instead of a non-sliver Box widget)  with an entrance
animation, provide a `sliverBuilder` callback instead of a `builder` callback.

If you wish to provide your own `AnimationController`, see
`SliverEntranceAnimationBuilder`.

If you wish to perform arbitrary behavior on enter / exit, see
`SliverEnterExitCallback`.

### SliverEntranceAnimationBuilder

A lighter weight version of `SliverEntranceAnimation`, which takes an existing
`AnimationController` rather than managing its own. For most cases, you probably
want to use 'SliverEntranceAnimation`.

Drives the inner `AnimationController` with `.forward()` and `.reverse()` when
the contents are scrolled into and out of view. By default, it will begin
animations whenever any part of the widget becomes visible, or the entire widget
is offscreen. To change this behavior, use a different `EntrancePolicy`.

Rebuilds the child widget via the `builder` function when notified of a change
by the `AnimationController`.

```dart
class MyState extends State<MyWidget> {
  AnimationController controller;

  ...

  Widget build() {
    return CustomScrollView(
      slivers: <Widget>[
        SliverEntranceAnimationBuilder(
          controller: controller,
          builder: (context, _) {
            return Opacity(
              opacity: controller.value,
              child: ...
            );
          },
        ),
      ],
    );
  }
}
```

For performance reasons, you may specify a `child` widget which is not rebuilt
on animation. This is then passed into the `builder` callback.

### SliverSuspendedAnimation

A sliver that suspends in place and begins an animation when it reaches the top
of a scroll view, and then continues to scroll when the animation is complete.

![sliver_suspended_animation_demo_AdobeExpress](https://user-images.githubusercontent.com/1627771/183282789-291a8a0e-33c2-4162-8215-089f3f824166.gif)

Can be an especially nice effect when the widget is set to match the size of
the screen, creating a sort of `PageView` effect, with feedback between
"pages."

The type parameter `T` refers to the type of the value that is being
animated. For instance, to animate opacity you would construct a
`SliverSuspendedAnimation<double>`.

The value will be animated through a range based on the provided tween,
and as the value changes, the [builder] function will be invoked with the
current value to create the widget that is rendered.

The duration of the suspension is specified in pixels the user will have to
scroll before it becomes revitalized and scrolls again.

```dart
// Provide a type argument for what you're animating.
SliverSuspendedAnimation<Color?>(
  duration: 200.0, // specified in pixels of scroll
  curve: Curves.ease, // Optional

  // Provide a builder function for the current animation value.
  builder: (BuildContext context, double opacity) {
    return Opacity(
      opacity: opacity,
      child: Container(...),
    );
  },

  // Provide a Tween for the animation value range
  tween: ColorTween(
    begin: Colors.red, // Red before scrolled to top
    end: Colors.blue, // Animates to blue before scrolling again
  ),
)
```

### SliverSuspend

A sliver which suspends in place once it is scrolled to the top of the page. It
will stay suspended in the top of the scroll view until the user has continued
to scroll a specified amount.

![sliver_suspend_demo_AdobeExpress](https://user-images.githubusercontent.com/1627771/183282800-99e9b87e-d19d-467a-bf7f-8af39646da95.gif)

This can be a useful effect, especially when the child is the size of the
screen, creating an effect similar to a `PageView`. This is usually best done
with a `SliverSuspendedAnimation`.

```dart
SliverSuspend(
  duration: 200.0, // specified in pixels of scroll
  child: Container(...)
)
```

### SliverSuspendedResize

A sliver that suspends in place and then resizes when scrolled to the top of
screen, before continuing to scroll.

![sliver_suspended_resize_demo_AdobeExpress](https://user-images.githubusercontent.com/1627771/183282822-a2fa9118-6717-43bf-8000-389311e0d283.gif)

The size transition is defined by the `mainAxisExtentTween`, which determines
the size of the widget in the scrolling axis direction.

The child widget will be put in a `SizedBox` which changes size during scroll.

Remember that with the right [Curve] and/or [Tween] it is possible to create
some highly dynamic effects, for instance, [TweenSequence].

The duration of the suspension is specified in pixels the user will have to
scroll before it becomes revitalized and scrolls again.

```dart
SliverSuspendedResize(
  duration: 200.0, // specified in pixels of scroll
  curve: Curves.ease, // Optional

  child: Container(...),

  // Provide a Tween for the size transition
  tween: Tween(
    begin: 200.0, // Height before scrolled to top
    end: 100.0, // Then will shrink to this height before resuming scroll
  ),
)
```

### SliverSuspendedFadeTransition

A sliver that suspends in place at the top of the scrollview and crossfades
between two widgets before continuing to scroll.

![sliver_suspended_fade_transition_demo_AdobeExpress](https://user-images.githubusercontent.com/1627771/183282835-4cc2b682-8566-40f3-ba41-b970b35f4f5c.gif)

The minimum necessary to use this widget is to provide two children; the [first]
and [second], and a duration. However, there may be issues sizing the children,
and for this reason there are a variety of sizing parameters available as well.

The duration of the fade is specified in pixels the user will have to scroll
before it completes and scrolls again.

```dart
SliverSuspendedFadeTransition(
  duration: 200.0, // specified in pixels of scroll
  curve: Curves.ease, // Optional

  first: Text("This shows up first"),
  second: Text("This fades in instead at the top of the scroll."),
)
```

### SliverSuspendedSlideTransition

A sliver that suspends in place at the top of the scrollview and performs a
swipe/slide type transition between two widgets before continuing to scroll.

![sliver_suspended_slide_transition_demo_AdobeExpress](https://user-images.githubusercontent.com/1627771/183282850-30f60e90-b6c0-476c-b6ac-ee8b2f8ce606.gif)

The minimum necessary to use this widget is to provide two children; the [first]
and [second], and a duration. However, there may be issues sizing the children,
and for this reason there are a variety of sizing parameters available as well.

The duration of the slide is specified in pixels the user will have to scroll
before it becomes revitalized and scrolls again.

```dart
SliverSuspendedSlideTransition(
  duration: 200.0, // specified in pixels of scroll
  curve: Curves.ease, // Optional

  first: Text("This shows up first"),
  second: Text("This swipes in at the top of the scroll."),
)
```

### SliverParallax

Makes a widget scrolls faster or slower than other scroll contents, creating a
"parallax" effect. Often used to imitate 3D/depth, but also can be used to
create a visual surprise when contents unexpectedly line up in interesting ways
while scrolling.

![sliver_parallax_demo_AdobeExpress](https://user-images.githubusercontent.com/1627771/183282856-02fc5968-282c-49b5-9f10-8541ad6814e6.gif)

For background parallax effects, and/or for parallax usage where size and scroll
speed are logically coupled, see `SliverFittedParallax`.

Simply provide a child for the widget that will move at a parallax, and a
`mainAxisFactor` that changes the scroll rate.

To reduce this widget's scroll rate, provide a `mainAxisFactor` less than
`1.0`. To make it scroll faster, provide a factor greater than `1.0` or make it
scroll the opposite direction with a negative factor. You can also give a
`crossAxisFactor` to make it move perpendicular to the scroll direction.

By default, the child paints at `(0, 0)` when the next sliver in the scrollview
is scrolled to the top of the view. This is the "neutral" position of this
[SliverParallax] and can be adjusted in two ways.

To change the amount of scrolling required to hit "neutral" position, see
`ParallaxScrollCenter`. You can provide a custom relative or absolute offset.

To change where on the screen this widget is painted at the neutral scroll
amount, you can provide your own `Offset`.

```dart
SliverParallax(
  // provide a mainAxisFactor and/or a crossAxisFactor
  mainAxisFactor: 0.8,

  // provide a child
  child: Text("Hovering, slower scrolling text"),

  // optionally provide an offset
  offset: Offset(0, MediaQuery.of(context).size.width / 2),

  // and optionally change the scroll center
  center: ParallaxScrollCenter.relativePx(-200),
),
```

### SliverFittedParallax

Very useful for parallax style backgrounds. Like `SliverParallax`, makes a
widget scrolls faster or slower than other scroll contents, creating a
"parallax" effect. However, a `FittedParallax` will either fits its scroll speed
to its child's size, or fit its child's size to its scroll.

Intended for a parallax child which is larger than its scroll container and
should always be visible within a certain scroll range (typically, from the
beginning to end of the scroll view). This widget will constrain the child size
OR set the scroll speed such that the edges of this widget are not visible when
the user is scrolling through that range.

When `mainAxisFactor` is not null, the child widget's size in the main scroll
axis (ie, height in a vertical scroll) will be constrained so that the widget is
still in view when scrolled to within the range. If `mainAxisFactor` is `null`,
then a `mainAxisFactor` will be chosen that maintains this property instead. It
will do the same for `crossAxisFactor` and the scroll axis size (ie, width in a
vertical scroll).

Rather than using a [ParallaxScrollCenter] to determine a "neutral" position,
this takes a `start` and `end` scroll offset. These default to an absolute 0px
start and a relative 0px end -- this means if it is the last sliver in the
scroll view it will function as a background for the whole scroll view.

![sliver_fitted_parallax_demo](https://storage.googleapis.com/scroll_animate_videos/sliver_fitted_parallax_demo.gif)

```dart
CustomScrollView(
  slivers: <Widget>[
    // *ALL* other slivers go *FIRST*.
    ...

    // For a scroll rate inferred from the image size
    SliverFittedParallax(
      child: Image.asset(...),
    ),

    // OR

    // For an exact scroll rate, sizing the image accordingly.
    SliverFittedParallax(
      mainAxisFactor: 0.3,
      child: Image.asset(
        ...,
        fit: BoxFit.cover,
      ),
    ),
  ],
)
```
## Other Classes

### ParallaxScrollCenter

Defines when a `SliverParallax` hits center in the scrollview.

A `SliverParallax` has a "neutral" position which defaults to `(0, 0)` but is
configurable via it's `offset`. As the user scrolls, the `SliverParallax` either
faster or slower than the rest of the scrollview, (and perhaps in the cross axis
direction). The `SliverParallax` will hit the "neutral" position at some scroll
amount. This class defines that scroll amount.

For convenience in designing parallax UIs, a relative offset is allowed, which
is based on the scroll position the sliver would have if it were not a special
parallax effect.

However, an absolute offset is also allowed. This is especially useful as a
means of setting a background at scroll position 0, since slivers are painted in
reverse order. If the last sliver has a scroll center of 0 then it will be
painted below all others but still aligned with the top of the scroll.

```dart
ParallaxScrollCenter.relativePx(100),
// or
ParallaxScrollCenter.absolutePx(100),
```

### EntrancePolicy

Used to determine sliver visibility, in order to determine when to animate a
`SliverEntranceAnimation`, or when to fire the callbacks of a
`SliverEnterExitCallback`. An interface may wish, for instance, to begin an
animation when the widget is partially visible, fully visible, or something else
entirely.

There are also a few reasonable preset behaviors you can use:

- `EntrancePolicy.anythingVisible()`: Any part of the sliver is visible.
- `EntrancePolicy.completelyVisible()`: All of the sliver is visible.
- `EntrancePolicy.topEdgeVisible()`: The top of the sliver is visible.
- `EntrancePolicy.bottomEdgeVisible()`: The bottom of the sliver is visible.
- `EntrancePolicy.scrolledBeyondBottomEdge()`: The scroll view includes, or has
  scrolled past, the bottom of this sliver. This intentionally considers the
  sliver visible while the user has scrolled past it; in a
  [SliverEntranceAnimation] this means the animation does not occur when the
  user scrolls back up to this sliver, only when they scroll down to it.
- `EntrancePolicy.scrolledBeyondTopEdge()`: The scroll view includes, or has
  scrolled past, the top of this sliver. This intentionally considers the sliver
  visible while the user has scrolled past it; in a [SliverEntranceAnimation]
  this means the animation does not occur when the user scrolls back up to this
  sliver, only when they scroll down to it.

If these behaviors don't do what you wante, you can write your own behavior by
analyzing the `SliverConstraints` and `SliverGeometry` of the sliver:

```dart
class MyEntrancePolicy implements EntrancePolicy {
  bool visible(SliverConstraints constraints, SliverGeometry geometry) {
    return ...
  }
}
```
