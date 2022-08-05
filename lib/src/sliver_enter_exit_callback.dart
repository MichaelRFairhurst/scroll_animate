import 'package:flutter/rendering.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:scroll_animate/src/entrance_policy.dart';
import 'package:scroll_animate/src/sliver_enter_exit_callback_wrapper.dart';

/// A Sliver that renders a box with callbacks for when it enters and exits.
///
/// Provide callbacks to perform when a widget enters or exits the scroll view.
/// Use this within a `CustomScrollView` or other widget that renders slivers.
/// 
/// To change the criteria for when a widget is considered to have entered, see
/// [EntrancePolicy]. By default, it will fire callbacks when any part of the
/// child becomes visible.
/// 
/// The child widget must be a normal box widget. To use this on a sliver, use
/// [SliverEnterExitCallbackWrapper].
class SliverEnterExitCallback extends StatelessWidget {

  final Widget? child;
  final void Function() onEnter;
  final void Function() onExit;
  final EntrancePolicy? entrancePolicy;

  /// Create a [SliverEnterExitCallback].
  ///
  /// `onEnter`: Callback to perform when the widget enters view.
  ///
  /// `onExit`: Callback to perform when the widget exits view.
  ///
  /// `child`: A regular (non-sliver) child widget. To get the same behavior on
  ///  a sliver child widget, use [SliverEnterExitCallbackWrapper].
  ///
  /// `entrancePolicy`: Optional. Sets the criteria for when a widget is
  /// considered to have entered or exited view. See [EntrancePolicy]. Defaults
  /// to firing whenever any part of the child is visible.
  SliverEnterExitCallback({
    Key? key,
    this.child,
    required this.onEnter,
    required this.onExit,
    this.entrancePolicy,
  }) : super(key: key);

  Widget build(BuildContext context) {
    return SliverEnterExitCallbackWrapper(
      onEnter: onEnter,
      onExit: onExit,
      entrancePolicy: entrancePolicy,
      sliver: SliverToBoxAdapter(
        child: child,
      ),
    );
  }
}
