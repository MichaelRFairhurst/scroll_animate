import 'package:flutter/material.dart' hide SliverFadeTransition;
import 'package:scroll_animate/src/sliver_fade_transition.dart';
import 'package:scroll_animate/src/sliver_slide_transition.dart';
import 'package:scroll_animate/src/sliver_freeze.dart';

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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: CustomScrollView(
        controller: scrollController,
        slivers: <Widget>[
          SliverFadeTransition(
            duration: 400,
            first: Container(
              height: 150,
              color: Colors.red,
            ),
            second: Container(
              height: 150,
              color: Colors.blue,
            ),
          ),
          SliverSlideTransition(
            duration: 400,
            first: Container(
              height: 150,
              color: Colors.green,
            ),
            second: Container(
              height: 150,
              color: Colors.red,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Image.asset(
                  "fluttercodeimg.jpeg",
                  key: ValueKey(index),
                  fit: BoxFit.cover,
                );
              },
              childCount: 10,
            ),
          ),
          SliverFreeze(
            duration: 400,
            child: Container(
              color: Color.fromARGB(0x80, 0x00, 0xFF, 0x00),
              height: 150,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Image.asset(
                  "fluttercodeimg.jpeg",
                  key: ValueKey(index),
                  fit: BoxFit.cover,
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
