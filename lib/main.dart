import 'dart:math';

import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

import 'model/Config.dart';
import 'model/Fish.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RepeatingAnimationDemo(),
    );
  }
}

class RepeatingAnimationDemo extends StatefulWidget {
  @override
  RepeatingAnimationDemoState createState() => RepeatingAnimationDemoState();
}

class RepeatingAnimationDemoState extends State<RepeatingAnimationDemo>
    with TickerProviderStateMixin {
  List<AnimationController> _animationControllers = new List();

  Random random = new Random();

  Animation<Offset> animate(double top, double left, int fishSize) {
    AnimationController _animationController = AnimationController(
        duration: Duration(seconds: BASE_ANIMATION_DURATION * fishSize),
        vsync: this)
      ..forward();
    _animationControllers.add(_animationController);

    Tween<Offset> _tween = Tween<Offset>(
      begin: Offset(top, left),
      end: Offset(generateTop(), generateLeft()),
    );

    return _tween.animate(_animationController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _tween.begin = _tween.end;
          _animationController.reset();
          _tween.end = Offset(generateTop(), generateLeft());
          _animationController.forward();
        }
      });
  }

  double generateLeft() {
    return random.nextInt(10).toDouble() + 1;
  }

  double generateTop() {
    return random.nextInt(5).toDouble() + 1;
  }

  @override
  Widget build(BuildContext context) {
    List<Fish> someList = List();

    for (int i = 0; i <= FISH_COUNT; i++) {
      someList.add(Fish.init(random.nextBool(), random.nextInt(2) + 1));
    }

    List<Widget> _createChildren() {
      return new List<Widget>.generate(someList.length, (int index) {
        Fish fish = someList[index];
        double top = generateTop();
        double left = generateLeft();
        Animation<Offset> animation = animate(top, left, fish.size);
        return SlideTransition(
            position: animation,
            child: Positioned(
                top: top,
                left: left,
                child: Image.network(fish.getImageUrl(),
                    width: fish.size * FISH_BASE_WIDTH,
                    height: fish.size * FISH_BASE_HEIGHT)));
      });
    }

    return Stack(children: _createChildren());
  }

  @override
  void dispose() {
    _animationControllers.forEach((element) {
      element.dispose();
    });
    super.dispose();
  }
}
