import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';
import 'package:scroll_animate/scroll_animate.dart';
import 'package:example/rounded_box.dart';

class DemoAll extends StatelessWidget {
  const DemoAll({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int colorIndex = 0;
    Color nextColor() => colors[colorIndex++];
    
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 150,
            backgroundColor: nextColor(),
            flexibleSpace: FlexibleSpaceBar(
              title: Text("SliverAppBar"),
            ),
          ),
          SliverSuspendedSlideTransition(
            duration: 400,
            height: 150,
            curve: Curves.ease,
            first: RoundedBox(
              color: nextColor(),
              text: "SliverSuspendedSlideTransition",
            ),
            second: RoundedBox(
              color: nextColor(),
              text: "...",
            ),
          ),
          SliverSuspendedFadeTransition(
            duration: 400,
            height: 150,
            curve: Curves.ease,
            first: RoundedBox(
              color: nextColor(),
              text: "SliverSuspendedFadeTransition",
            ),
            second: RoundedBox(
              color: nextColor(),
              text: "...",
            ),
          ),
          SliverSuspendedAnimation<double>(
            duration: 800,
            curve: Curves.ease,
            tween: Tween(begin: 0.0, end: 2*pi),
            builder: (context, angle) {
              return Stack(
                children: <Widget>[
                  RoundedBox(
                    color: colors[0],
                    height: 300,
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(50),
                    child: Transform.rotate(
                      angle: angle,
                      child: RoundedBox(
                        color: colors[1],
                        width: 200,
                        height: 200,
                        text: "SliverSuspendedAnimation",
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          SliverSuspendedResize(
            duration: 800,
            curve: Curves.ease,
            mainAxisExtentTween: TweenSequence<double>(
              <TweenSequenceItem<double>>[
                TweenSequenceItem<double>(
                  tween: Tween(
                    begin: 150.0,
                    end: 350.0,
                  ),
                  weight: 1,
                ),
                TweenSequenceItem<double>(
                  tween: ConstantTween<double>(350.0),
                  weight: 2,
                ),
                TweenSequenceItem<double>(
                  tween: Tween(
                    begin: 350.0,
                    end: 150.0,
                  ),
                  weight: 1,
                ),
              ],
            ),
            child: RoundedBox(
              color: nextColor(),
              text: "SliverSuspendedResize",
            ),
          ),
          SliverEntranceAnimation<double>(
            duration: Duration(seconds: 1),
            curve: Curves.ease,
            tween: Tween(begin: 0.0, end: 1.0),
            entrancePolicy: EntrancePolicy.scrollBeyondBottomEdge(),
            builder: (context, opacity, _) {
              return Opacity(
                opacity: opacity,
                child: RoundedBox(
                  color: colors[2],
                  height: 150,
                  text: "SliverEntranceAnimation",
                ),
              );
            },
          ),
          SliverEntranceAnimation<double>(
            duration: Duration(seconds: 1),
            curve: Curves.ease,
            tween: Tween(begin: 0.0, end: 1.0),
            entrancePolicy: EntrancePolicy.scrollBeyondBottomEdge(),
            sliverBuilder: (context, opacity, _) {
              return SliverOpacity(
                opacity: opacity,
                sliver: SliverSuspendedSlideTransition(
                  duration: 400,
                  height: 150,
                  curve: Curves.ease,
                  first: RoundedBox(
                    color: colors[3],
                      text: "SliverEntranceAnimation",
                  ),
                  second: RoundedBox(
                    color: colors[4],
                    text: "... with SliverSuspendedSlideTransition",
                  ),
                ),
              );
            },
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return RoundedBox(
                  height: 150 - 32,
                  color: colors[index],
                  text: "SliverList item",
                );
              },
              childCount: 10,
            ),
          ),
          SliverToBoxAdapter(
            child: RoundedBox(
              color: nextColor(),
              height: 150,
              text: "Parallax Below Here",
            ),
          ),
          SliverParallax(
            mainAxisFactor: 0.5,
            crossAxisFactor: -0.4,
            center: ParallaxScrollCenter.relativePx(-100),
            offset: Offset(0, 100),
            child: RoundedBox(
              height: 150,
              color: nextColor(),
              text: "SliverParallax",
            ),
          ),
          SliverParallax(
            mainAxisFactor: -0.2,
            crossAxisFactor: 0.4,
            offset: Offset(0, 100 + 150 + 32),
            center: ParallaxScrollCenter.relativePx(-100),
            child: RoundedBox(
              height: 150,
              color: nextColor(),
              text: "SliverParallax",
            ),
          ),
          SliverParallax(
            mainAxisFactor: 0.7,
            crossAxisFactor: -0.7,
            offset: Offset(0, 100 + (150 + 32) * 2),
            center: ParallaxScrollCenter.relativePx(-100),
            child: RoundedBox(
              height: 150,
              color: nextColor(),
              text: "SliverParallax",
            ),
          ),
          SliverToBoxAdapter(
            child: Container(height: (150+16*2)*3),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return RoundedBox(
                  height: 150,
                  color: colors[index],
                  text: "SliverList item",
                );
              },
              childCount: 10,
            ),
          ),
          SliverParallax(
            center: ParallaxScrollCenter.absolutePx(0.0),
            mainAxisFactor: 0.05,
            child: Container(
              height: MediaQuery.of(context).size.height*2,
              width: MediaQuery.of(context).size.width,
              child: Image.asset(
                "assets/fluttercodeimg.jpeg",
                fit: BoxFit.cover,
                color: Color(0xffe0e0e0),
                colorBlendMode: BlendMode.screen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
