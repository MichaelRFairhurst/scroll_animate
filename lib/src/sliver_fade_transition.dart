import 'package:flutter/material.dart';
import 'package:scroll_animate/src/sliver_freeze_animation.dart';

class SliverFadeTransition extends StatelessWidget {
  final Widget first;
  final Widget second;
  final double duration;

  SliverFadeTransition({
    required this.duration,
    required this.first,
    required this.second,
  });

  Widget build(BuildContext context) {
    return SliverFreezeAnimation(
      duration: duration,
      builder: (BuildContext, progress) {
        return Stack(
          children: <Widget>[
            if (progress != 0.0)
              Positioned.fill(
                child: second,
              ),
            Opacity(
              opacity: 1.0 - progress,
              child: first,
            ),
          ],
        );
      },
    );
  }
}

