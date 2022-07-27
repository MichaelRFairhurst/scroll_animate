import 'package:flutter/material.dart';
import 'package:scroll_animate/src/sliver_freeze_animation.dart';

class SliverSlideTransition extends StatelessWidget {
  final Widget first;
  final Widget second;
  final double duration;

  final Key? key;
  final double? height;
  final double? width;
  final BoxConstraints? constraints;
  final AlignmentGeometry? alignment;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  SliverSlideTransition({
    required this.duration,
    required this.first,
    required this.second,
    this.key,
    this.height,
    this.width,
    this.constraints,
    this.alignment,
    this.padding,
    this.margin,
  });

  Widget build(BuildContext context) {
    return SliverFreezeAnimation(
      duration: duration,
      builder: (context, progress) {
        return Container(
          height: height,
          width: width,
          constraints: constraints,
          alignment: alignment,
          padding: padding,
          margin: margin,
          child: Flow(
            delegate: SliverSlideTransitionFlowDelegate(
              progress,
            ),
            children: <Widget>[
              first,
              second,
            ],
          ),
        );
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
