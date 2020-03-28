import 'dart:async';
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
        title: 'Flutter Aquarium',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Container(child: FlutterAquarium()));
  }
}

class FlutterAquarium extends StatefulWidget {
  @override
  FlutterAquariumState createState() => FlutterAquariumState();
}

// TODO add architecture
class FlutterAquariumState extends State<FlutterAquarium>
    with TickerProviderStateMixin {
  List<AnimationController> _animationControllers = new List();

  Random random = new Random();
  Map<Fish, SlideTransition> fishAndViewsMap = Map();

  @override
  initState() {
    super.initState();
  }

  void checkAreThereFishesAtSamePoint() {
    fishAndViewsMap.removeWhere((fish, slide) => fishAndViewsMap.entries.any(
        (entry) =>
            // Predator eats non-predator same or bigger size
            ((!fish.isPredator &&
                    entry.key.isPredator &&
                    fish.size - 1 <= entry.key.size) ||
                // Predator eats predator same or less size
                (fish.isPredator &&
                    entry.key.isPredator &&
                    fish.size < entry.key.size)) &&
            // Avoid self-compare
            entry.value.child.key != slide.child.key &&
            // Avoid init errors
            getSlidePosition(slide) != null &&
            getSlidePosition(entry.value) != null &&
            // Check views positions
            ((getSlidePosition(slide).dx - getSlidePosition(entry.value).dx)
                    .abs() <=
                FISH_BASE_WIDTH) &&
            ((getSlidePosition(slide).dy - getSlidePosition(entry.value).dy)
                    .abs() <=
                FISH_BASE_HEIGHT)));
  }

  Offset getSlidePosition(SlideTransition slide) {
    GlobalKey key = slide.child.key;
    final RenderBox renderBoxRed = key.currentContext?.findRenderObject();
    Offset offset = renderBoxRed?.localToGlobal(Offset.zero);
    return offset;
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(() {
      int sizeBefore = fishAndViewsMap.length;
      checkAreThereFishesAtSamePoint();
      // Add fish in 15 secs
      if (sizeBefore > fishAndViewsMap.length) {
        createTimerToAddNewFish();
      }
    });
  }

  Animation<Offset> animate(int fishSize) {
    AnimationController _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: fishSize * BASE_ANIMATION_DURATION),
    );

    _animationController.forward();

    _animationControllers.add(_animationController);

    var startOffset = Offset(
        generateNewOffsetValue(fishSize), generateNewOffsetValue(fishSize));

    final Tween<Offset> _tween = Tween<Offset>(
        begin: startOffset,
        end: Offset(generateNewOffsetValue(fishSize),
            generateNewOffsetValue(fishSize)));

    return _tween.animate(_animationController)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _tween.begin = _tween.end;
          _animationController.reset();
          _tween.end = Offset(generateNewOffsetValue(fishSize),
              generateNewOffsetValue(fishSize));
          _animationController.forward();
        }
      });
  }

  double generateNewOffsetValue(int fishSize) {
    var generated =
        random.nextInt(generateTop(fishSize).toInt() + 1).toDouble();
    if (generated > 1) generated -= 1;
    return generated;
  }

  // Max value
  double generateTop(int fishSize) {
    // Get the screen size
    final Size screenSize = MediaQuery.of(context).size;

    final double offset =
        (screenSize.height / (fishSize * FISH_BASE_HEIGHT) / 2).ceilToDouble();

    return offset;
  }

  @override
  Widget build(BuildContext context) {
    if (fishAndViewsMap.isEmpty) {
      setFishes();
    }

    return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      Container(
        color: Colors.blue[700],
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(children: fishAndViewsMap.values.toList()),
      )
    ]);
  }

  @override
  void dispose() {
    _animationControllers.forEach((element) {
      element.dispose();
    });
    super.dispose();
  }

  void setFishes() {
    while (fishAndViewsMap.length < FISH_COUNT) {
      createFish();
    }
  }

  void createTimerToAddNewFish() {
    new Future.delayed(
        const Duration(seconds: ADD_NEW_FISH_TIMER), () => setFishes());
  }

  void createFish() {
    Fish fish = Fish.init(random.nextBool(), random.nextInt(3) + 1);
    Animation<Offset> animation = animate(fish.size);
    SlideTransition slideTransition = SlideTransition(
      position: animation,
      child: Container(
        key: GlobalKey(),
        width: fish.size * FISH_BASE_WIDTH,
        height: fish.size * FISH_BASE_HEIGHT,
        child: Container(
          child: Image.network(
            fish.getImageUrl(),
          ),
        ),
      ),
    );
    fishAndViewsMap[fish] = slideTransition;
    setState(() {});
  }
}
