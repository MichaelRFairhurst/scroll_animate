import 'dart:math';
import 'package:flutter/material.dart';
import 'package:scroll_animate/scroll_animate.dart';
import 'package:example/demo_hero.dart';
import 'package:example/rounded_box.dart';

class SingleWidgetDemo extends StatelessWidget {
  final String text;
  final String code;
  final int spacersBefore;
  final int examplesCount;
  final int spacersAfter;
  final double height;
  final bool useHero;
  final Widget Function(BuildContext, Widget) builder;

  SingleWidgetDemo({
    required this.text,
    required this.code,
    this.spacersBefore = 0,
    this.examplesCount = 1,
    this.spacersAfter = 0,
    this.useHero = true,
    this.height = 250,
    required this.builder,
  });

  Widget build(BuildContext context) {
    final palette = Palette();

    final size = MediaQuery.of(context).size;

    return SingleWidgetDemoScaffold(
      text: text,
      code: code,
      appBarColor: palette.nextColor(),
      slivers: <Widget>[
        for (int i = 0; i < spacersBefore; ++i)
          SimpleSliverSpacer(palette.nextColor()),
        for (int i = 0; i < examplesCount; ++i)
          builder(
            context,
            useHero
              ? DemoHero(
                  text: text,
                  height: height,
                  color: palette.nextColor(),
                )
              : RoundedBox(
                  text: text,
                  height: height,
                  color: palette.nextColor(),
                ),
          ),
        for (int i = 0; i < spacersAfter; ++i)
          SimpleSliverSpacer(palette.nextColor()),
      ],
    );
  }
}

class SingleWidgetDemoScaffold extends StatelessWidget {
  final String text;
  final List<Widget> slivers;
  final String code;
  final Color appBarColor;

  SingleWidgetDemoScaffold({
    required this.appBarColor,
    required this.text,
    required this.code,
    required this.slivers,
  });

  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverParallax(
            mainAxisFactor: -0.5,
            child: Container(
              alignment: Alignment.bottomCenter,
              width: size.width,
              height: size.height,
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Material(elevation: 3.0, child: Container(
                color: Colors.white,
                padding: EdgeInsets.all(24.0),
                child: Text(
                  code,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12.0,
                  ),
                )),
              ),
            ),
          ),
          SliverAppBar(
            expandedHeight: 150,
            backgroundColor: appBarColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text("$text Demo"),
            ),
          ),
          ...slivers,
        ],
      ),
    );
  }
}

class SimpleSliverSpacer extends StatelessWidget {
  final Color color;

  SimpleSliverSpacer(this.color);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: RoundedBox(
        color: Color.alphaBlend(Color(0xb0ffffff), color),
        height: 150,
        text: "(simple spacer)",
      ),
    );
  }
}
