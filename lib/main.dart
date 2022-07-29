import 'dart:math';
import 'package:flutter/material.dart' hide SliverFadeTransition;
import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';
import 'package:scroll_animate/src/entrance_policy.dart';
import 'package:scroll_animate/src/sliver_entrance_animation_builder.dart';
import 'package:scroll_animate/src/sliver_fade_transition.dart';
import 'package:scroll_animate/src/sliver_slide_transition.dart';
import 'package:scroll_animate/src/sliver_freeze.dart';
import 'package:scroll_animate/src/sliver_freeze_animation.dart';
import 'package:scroll_animate/src/sliver_freeze_resize.dart';
import 'package:scroll_animate/src/sliver_parallax.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class RoundedBox extends StatelessWidget {
  final double? height;
  final double? width;
  final Color color;
  final String? text;

  RoundedBox({this.height, this.width, required this.color, this.text});

  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      margin: EdgeInsets.all(16.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
      ),
      child: Center(
        child: Text(
          text ?? "",
          style: TextStyle(fontSize: 16)),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {

  late AnimationController _controller;
  late AnimationController _controller2;
  late Animation<double> _opacityAnimation;
  late Animation<double> _opacityAnimation2;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(_controller);

    _controller2 = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _opacityAnimation2 = Tween(begin: 0.0, end: 1.0).animate(_controller2);
  }

  @override
  Widget build(BuildContext context) {
    final colors = <Color>[
      Color(0xFF028E9E),
      //Color(0xFF59163E),
      Color(0xFF7BCF55),
      Color(0xFF4748A1),
      Color(0xFFD17452),
      Color(0xFF34D8EB),
      Color(0xFFABA693),
      Color(0xFFB57D9F),
      Color(0xFFC9AA2C),
      Color(0xFF6F70B3),
      Color(0xFF8C4971),
    ];

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
          SliverSlideTransition(
            duration: 400,
            height: 150,
            curve: Curves.ease,
            first: RoundedBox(
              color: nextColor(),
              text: "SliverSlideTransition",
            ),
            second: RoundedBox(
              color: nextColor(),
              text: "...",
            ),
          ),
          SliverFadeTransition(
            duration: 400,
            height: 150,
            curve: Curves.ease,
            first: RoundedBox(
              color: nextColor(),
              text: "SliverFadeTransition",
            ),
            second: RoundedBox(
              color: nextColor(),
              text: "...",
            ),
          ),
          SliverFreezeAnimation<double>(
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
                        text: "SliverFreezeAnimation",
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          SliverFreezeResize(
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
              text: "SliverFreezeResize",
            ),
          ),
          SliverEntranceAnimationBuilder(
            controller: _controller,
            entrancePolicy: EntrancePolicy.scrollBeyondBottomEdge(),
            builder: (context, _) {
              return SliverToBoxAdapter(
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: RoundedBox(
                    color: colors[2],
                    height: 150,
                    text: "SliverEntranceAnimationBuilder",
                  ),
                ),
              );
            },
          ),
          SliverEntranceAnimationBuilder(
            controller: _controller2,
            entrancePolicy: EntrancePolicy.scrollBeyondBottomEdge(),
            builder: (context, _) {
              return SliverOpacity(
                opacity: _opacityAnimation2.value,
                sliver: SliverSlideTransition(
                  duration: 400,
                  height: 150,
                  curve: Curves.ease,
                  first: RoundedBox(
                    color: colors[3],
                      text: "SliverEntranceAnimationBuilder",
                  ),
                  second: RoundedBox(
                    color: colors[4],
                    text: "withSliverSlideTransition",
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
                "fluttercodeimg.jpeg",
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
