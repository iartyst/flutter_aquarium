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
  Map<Fish, SlideTransition> _fishAndViewsMap = Map();

  Random _random = new Random();

  double _screenHeight;
  double _screenWidth;

  @override
  initState() {
    super.initState();
  }

  void _checkAreThereFishesAtSamePoint() {
    _fishAndViewsMap.removeWhere((currentFish, slide) =>
        _fishAndViewsMap.entries.any((nextFish) =>
            // Predator eats non-predator same or bigger size
            ((!currentFish.isPredator &&
                    nextFish.key.isPredator &&
                    currentFish.size <= nextFish.key.size + 1) ||
                // Predator eats predator less size
                (currentFish.isPredator &&
                    nextFish.key.isPredator &&
                    currentFish.size <= nextFish.key.size)) &&
            // Avoid self-compare
            nextFish.value.child.key != slide.child.key &&
            // Avoid init errors
            _getSlidePosition(slide) != null &&
            _getSlidePosition(nextFish.value) != null &&
            // Check views positions
            ((_getSlidePosition(slide).dx -
                        _getSlidePosition(nextFish.value).dx)
                    .abs() <=
                FISH_BASE_WIDTH) &&
            ((_getSlidePosition(slide).dy -
                        _getSlidePosition(nextFish.value).dy)
                    .abs() <=
                FISH_BASE_HEIGHT)));
  }

  Offset _getSlidePosition(SlideTransition slide) {
    final GlobalKey key = slide.child.key;
    final RenderBox renderBoxRed = key.currentContext?.findRenderObject();
    return renderBoxRed?.localToGlobal(Offset.zero);
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(() {
      final sizeBefore = _fishAndViewsMap.length;
      _checkAreThereFishesAtSamePoint();
      // Add fish in 15 secs
      if (sizeBefore > _fishAndViewsMap.length) {
        _createTimerToAddNewFish();
      }
    });
  }

  Animation<Offset> animate(int fishSize) {
    final AnimationController _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: fishSize * BASE_ANIMATION_DURATION),
    );

    _animationController.forward();

    _animationControllers.add(_animationController);

    final startOffset = _generateOffset(fishSize);

    final Tween<Offset> _tween =
        Tween<Offset>(begin: startOffset, end: _generateOffset(fishSize));

    return _tween.animate(_animationController)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _tween.begin = _tween.end;
          _animationController.reset();
          _tween.end = _generateOffset(fishSize);
          _animationController.forward();
        }
      });
  }

  Offset _generateOffset(int fishSize) {
    return Offset(_generateHorizontal(fishSize) * _random.nextDouble(),
        _generateVertical(fishSize) * _random.nextDouble());
  }

  // Max value
  double _generateHorizontal(int fishSize) {
    return ((_screenWidth - (fishSize * FISH_BASE_WIDTH)) /
        (fishSize * FISH_BASE_WIDTH));
  }

  // Max value
  double _generateVertical(int fishSize) {
    return ((_screenHeight - (fishSize * FISH_BASE_HEIGHT)) /
        (fishSize * FISH_BASE_HEIGHT));
  }

  @override
  Widget build(BuildContext context) {
    _screenHeight =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;
    _screenWidth = MediaQuery.of(context).size.width;

    if (_fishAndViewsMap.isEmpty) {
      while (_fishAndViewsMap.length < FISH_COUNT) {
        _createFish();
      }
    }

    return Scaffold(
      backgroundColor: Colors.blue,
      body: Stack(children: _fishAndViewsMap.values.toList()),
    );
  }

  @override
  void dispose() {
    _animationControllers.forEach((element) {
      element.dispose();
    });
    super.dispose();
  }

  void _createTimerToAddNewFish() {
    Future.delayed(
        const Duration(seconds: ADD_NEW_FISH_TIMER), () => _createFish());
  }

  void _createFish() {
    final Fish fish =
        Fish(_random.nextBool(), _random.nextInt(FISH_MAX_SIZE) + 1);
    // TODO maybe try with aligh
    final SlideTransition slideTransition = SlideTransition(
      position: animate(fish.size),
      child: Image.network(
        fish.imageUrl,
        key: GlobalKey(),
        width: fish.size * FISH_BASE_WIDTH,
        height: fish.size * FISH_BASE_HEIGHT,
      ),
    );
    _fishAndViewsMap[fish] = slideTransition;
  }
}
