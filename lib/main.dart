import 'package:flutter/material.dart' hide SliverFadeTransition;
import 'package:flutter/animation.dart';
import 'package:scroll_animate/src/sliver_fade_transition.dart';
import 'package:scroll_animate/src/sliver_slide_transition.dart';
import 'package:scroll_animate/src/sliver_freeze.dart';
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

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = <Color>[
      Color(0xFF028E9E),
      Color(0xFF59163E),
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
      appBar: AppBar(
        title: Text('Parallax Demo'),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 150,
            backgroundColor: Colors.white,
            flexibleSpace: RoundedBox(
              color: nextColor(),
              text: "SliverAppBar",
            ),
          ),
          SliverSlideTransition(
            duration: 500,
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
          SliverFreezeResize(
            duration: 800,
            curve: Curves.ease,
            sizeTween: TweenSequence<Size?>(
              <TweenSequenceItem<Size?>>[
                TweenSequenceItem<Size?>(
                  tween: SizeTween(
                    begin: Size(0, 150),
                    end: Size(0, 350),
                  ),
                  weight: 1,
                ),
                TweenSequenceItem<Size?>(
                  tween: ConstantTween<Size?>(Size(0, 350)),
                  weight: 1,
                ),
                TweenSequenceItem<Size?>(
                  tween: SizeTween(
                    begin: Size(0, 350),
                    end: Size(0, 150),
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
          SliverParallax(
            mainAxisFactor: 0.5,
            crossAxisFactor: 0.1,
            offset: Offset(50, 500),
            child: RoundedBox(
              height: 50,
              width: 100 - 16,
              color: nextColor(),
              text: "SliverParallax",
            ),
          ),
          SliverParallax(
            mainAxisFactor: -0.2,
            crossAxisFactor: 0.2,
            offset: Offset(150, 500),
            child: RoundedBox(
              height: 50,
              width: 100 - 16,
              color: nextColor(),
              text: "SliverParallax",
            ),
          ),
          SliverParallax(
            mainAxisFactor: 0.7,
            crossAxisFactor: -0.05,
            offset: Offset(250, 500),
            child: RoundedBox(
              height: 50,
              width: 100 - 16,
              color: nextColor(),
              text: "SliverParallax",
            ),
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
        ],
      ),
    );
  }
}
