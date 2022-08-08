import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';
import 'package:scroll_animate/scroll_animate.dart';
import 'package:example/rounded_box.dart';
import 'package:example/demo_all.dart';
import 'package:example/demo_launcher.dart';
import 'package:example/single_widget_demo.dart';

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
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 150,
            backgroundColor: colors[0],
            flexibleSpace: FlexibleSpaceBar(
              title: Text("Scroll Animate gallery"),
            ),
          ),
          _demoLauncher(
            text: "Demo all",
            builder: (context) => DemoAll(),
          ),
          _singleWidgetLauncher(_demoSliverEntranceAnimation()),
          _singleWidgetLauncher(_demoSliverSuspendedAnimation()),
          _demoLauncher(
             text: "SliverParallax",
             builder: (context) => _demoSliverParallax(context),
          ),
          _singleWidgetLauncher(_demoSliverFittedParallax()),
          _singleWidgetLauncher(_demoSliverSuspendedSlide()),
          _singleWidgetLauncher(_demoSliverSuspendedFade()),
          _singleWidgetLauncher(_demoSliverSuspendedResize()),
          _singleWidgetLauncher(_demoSliverSuspend()),
        ],
      ),
    );
  }

  Widget _singleWidgetLauncher(SingleWidgetDemo demo) {
    return _demoLauncher(
      text: demo.text,
      builder: (context) => demo,
    );
  }

  bool isEven = true;
  Widget _demoLauncher({required String text, required Widget Function(BuildContext) builder}) {
    isEven = !isEven;
    return DemoLauncher(
      text: text,
      isEven: isEven,
      builder: builder,
    );
  }

  SingleWidgetDemo _demoSliverEntranceAnimation() {
    return SingleWidgetDemo(
      text: "SliverEntranceAnimation",
      spacersBefore: 0,
      examplesCount: 10,
      spacersAfter: 0,
      useHero: false,
      height: 150,
      code: """
SliverEntranceAnimation<double>(
  duration: Duration(seconds: 1),
  tween: Tween(begin: MediaQuery.of(context).size.width, end: 0),
  curve: Curves.ease,
  builder: (context, slide) {
    return Transform.translate(
      offset: Offset(-slide, 0),
      child: RoundedBox(text: "SliverSuspendedSlideTransition", ...),
    );
  },
)
""",
      builder: (context, child) {
        final width = MediaQuery.of(context).size.width;
        return SliverEntranceAnimation<double>(
          duration: Duration(seconds: 1),
          tween: Tween(begin: width, end: 0.0),
          curve: Curves.ease,
          builder: (context, slide, _) {
            return Transform.translate(
              offset: Offset(-slide, 0),
              child: child,
            );
          },
        );
      },
    );
  }

  SingleWidgetDemoScaffold _demoSliverParallax(BuildContext context) {
    final palette = Palette();
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final random = Random();
    return SingleWidgetDemoScaffold(
      text: "SliverParallax",
      appBarColor: palette.nextColor(),
      code: """
SliverParallax(
  mainAxisFactor: random.nextDouble(),
  crossAxisFactor: random.nextDouble() * 2 - 1,
  center: ParallaxScrollCenter.absolutePx(screenHeight/2),
  offset: Offset(0, index * 200),
  child: RoundedBox(...),
),
""",
      slivers: <Widget>[
        for (int i = 0; i < 6; ++i)
          SliverParallax(
            mainAxisFactor: random.nextDouble(),
            crossAxisFactor: random.nextDouble() * 2 - 1,
            center: ParallaxScrollCenter.absolutePx(height/2),
            offset: Offset(0, i * 200),
            child: RoundedBox(
              height: 150,
              width: width,
              color: palette.nextColor(),
              text: "SliverParallax",
            ),
          ),
        SliverToBoxAdapter(
          child: Container(height: height * 2),
        ),
      ],
    );
  }

  SingleWidgetDemo _demoSliverFittedParallax() {
    return SingleWidgetDemo(
      text: "SliverFittedParallax",
      spacersBefore: 10,
      spacersAfter: 0,
      useHero: false,
      height: 150,
      code: """
// As the last sliver in CustomScrollView
SliverFittedParallax(
  child: Image.asset(
    "...",
  ),
),
""",
      builder: (context, child) {
        return SliverFittedParallax(
          child: Image.asset(
            "assets/fluttercodeimg.jpeg",
            color: Color(0xffb0b0b0),
            colorBlendMode: BlendMode.screen,
          ),
        );
      },
    );
  }


  SingleWidgetDemo _demoSliverSuspendedSlide() {
    return SingleWidgetDemo(
      text: "SliverSuspendedSlideTransition",
      spacersBefore: 1,
      spacersAfter: 5,
      code: """
SliverSuspendedSlideTransition(
  duration: 600,
  curve: Curves.ease,
  height: 250,
  first: RoundedBox(text: "SliverSuspendedSlideTransition", ...),
  second: RoundedBox(text: "New Content", ...),
),
""",
      builder: (context, child) {
        return SliverSuspendedSlideTransition(
          duration: 600,
          height: 250,
          first: child,
          curve: Curves.ease,
          second: RoundedBox(
            text: "New Content",
            color: colors[0],
          ),
        );
      },
    );
  }

  SingleWidgetDemo _demoSliverSuspendedFade() {
    return SingleWidgetDemo(
      text: "SliverSuspendedFadeTransition",
      spacersBefore: 1,
      spacersAfter: 5,
      code: """
SliverSuspendedFadeTransition(
  duration: 600,
  height: 250 
  curve: Curves.ease,
  first: RoundedBox(text: "SliverSuspendedFadeTransition", ...),
  second: RoundedBox(text: "New Content", ...),
)
""",
      builder: (context, child) {
        return SliverSuspendedFadeTransition(
          duration: 600,
          first: child,
          curve: Curves.ease,
          second: RoundedBox(
            text: "New Content",
            color: colors[0],
            height: 250,
          ),
        );
      },
    );
  }

  SingleWidgetDemo _demoSliverSuspendedResize() {
    return SingleWidgetDemo(
      text: "SliverSuspendedResize",
      spacersBefore: 1,
      spacersAfter: 5,
      code: """
SliverSuspendedResize(
  duration: 600,
  mainAxisExtentTween: Tween(begin: 250, end: 500),
  curve: Curves.ease,
  child: RoundedBox(text: "SliverSuspendedResize", ...),
)
""",
      builder: (context, child) {
        return SliverSuspendedResize(
          duration: 600,
          mainAxisExtentTween: Tween(begin: 250, end: 500),
          curve: Curves.ease,
          child: child,
        );
      },
    );
  }

  SingleWidgetDemo _demoSliverSuspendedAnimation() {
    return SingleWidgetDemo(
      text: "SliverSuspendedAnimation",
      spacersBefore: 0,
      spacersAfter: 5,
      code: """
SliverSuspendedAnimation<double>(
  duration: 800,
  tween: Tween(begin: 0.0, end: 2*pi),
  builder: (context, angle) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        ....
        Transform.rotate(
          angle: angle,
          child: ...
        ),
      ],
    );
  },
)
""",
      builder: (context, child) {
        return SliverSuspendedAnimation<double>(
          duration: 800,
          tween: Tween(begin: 0.0, end: 2*pi),
          builder: (context, angle) {
            return Stack(
              alignment: Alignment.center,
              children: <Widget>[
                RoundedBox(
                  color: colors[0],
                  height: 350,
                ),
                Transform.rotate(
                  angle: angle,
                  child: Container(
                    width: 300,
                    height: 300,
                    child: child,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  SingleWidgetDemo _demoSliverSuspend() {
    return SingleWidgetDemo(
      text: "SliverSuspend",
      spacersBefore: 1,
      spacersAfter: 5,
      code: """
SliverSuspend(
  duration: 600,
  child: RoundedBox(...),
)
""",
      builder: (context, child) {
        return SliverSuspend(
          duration: 600,
          child: child,
        );
      },
    );
  }
}
