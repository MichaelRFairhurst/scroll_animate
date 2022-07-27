import 'package:flutter/material.dart';
import 'package:scroll_animate/src/sliver_freeze_animation.dart';

class SliverSlideTransition extends StatelessWidget {
  final Widget first;
  final Widget second;
  final double duration;

  SliverSlideTransition({
    required this.duration,
    required this.first,
    required this.second,
  });

  Widget build(BuildContext context) {
    return SliverFreezeAnimation(
      duration: duration,
      builder: (context, progress) {
        return Container(height: 150, child: Flow(
          delegate: SliverSlideTransitionFlowDelegate(
            progress,
          ),
          children: <Widget>[
            first,
            second,
          ],
        ));
      },
    );
  }
}

class SliverSlideTransitionFlowDelegate extends FlowDelegate {
  final double progress;

  SliverSlideTransitionFlowDelegate(this.progress);

  @override
  void paintChildren(FlowPaintingContext context) {
    final width = context.size.width;
    context.paintChild(0, transform: Matrix4.translationValues(-width * progress, 0, 0));
    context.paintChild(1, transform: Matrix4.translationValues(width -width * progress, 0, 0));
  }

  @override
  bool shouldRepaint(SliverSlideTransitionFlowDelegate newDelegate)
      => newDelegate.progress != progress;
}
