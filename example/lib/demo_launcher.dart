import 'package:flutter/material.dart';
import 'package:example/demo_hero.dart';
import 'package:scroll_animate/scroll_animate.dart';

class DemoLauncher extends StatelessWidget {
  final String text;
  final bool isEven;
  Widget Function(BuildContext) builder;

  DemoLauncher({
    required this.text,
    required this.isEven,
    required this.builder,
  });

  Widget build(BuildContext context) {
    return SliverEntranceAnimation<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, opacity, _) {
        return Opacity(
          opacity: opacity,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: builder,
                ),
              );
            },
            child: DemoHero(
              text: text,
              height: 80,
              color: isEven ? Colors.grey[200]! : Colors.grey[100]!,
            ),
          ),
        );
      },
    );
  }
}
