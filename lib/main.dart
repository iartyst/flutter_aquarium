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
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Container(child: RepeatingAnimationDemo()));
  }
}

class RepeatingAnimationDemo extends StatefulWidget {
  @override
  RepeatingAnimationDemoState createState() => RepeatingAnimationDemoState();
}

// TODO add architecture
class RepeatingAnimationDemoState extends State<RepeatingAnimationDemo>
    with TickerProviderStateMixin {
  List<AnimationController> _animationControllers = new List();

  Random random = new Random();

  Map<Fish, SlideTransition> someList = Map();

  @override
  initState() {
    super.initState();

    const oneSec = const Duration(seconds: 10);
    new Timer.periodic(oneSec, (Timer t) => setFishes());
  }

  void ololo() {
    print("--------------------");

    someList.values.forEach((element) {
      print(_getPositions(element));
    });

    var uniqDxs = Map();
    someList.values.map((e) => _getPositions(e).dx).forEach(
        (x) => uniqDxs[x] = !uniqDxs.containsKey(x) ? (1) : (uniqDxs[x] + 1));
    uniqDxs.removeWhere((key, value) => value < 2);

    var uniqDys = Map();
    someList.values.map((e) => _getPositions(e).dy).forEach(
        (x) => uniqDys[x] = !uniqDys.containsKey(x) ? (1) : (uniqDys[x] + 1));
    uniqDys.removeWhere((key, value) => value < 2);

    someList.removeWhere((fish, slide) =>
        uniqDxs.keys.any((element) =>
            (_getPositions(slide).dx - _getPositions(element).dx).abs() <=
            (fish.size * FISH_BASE_WIDTH)) &&
        uniqDys.keys.any((element) =>
            (_getPositions(slide).dy - _getPositions(element).dy).abs() <=
            (fish.size * FISH_BASE_HEIGHT)));
  }

  Offset _getPositions(SlideTransition slide) {
    GlobalKey key = slide.child.key;
    final RenderBox renderBoxRed = key.currentContext.findRenderObject();
    Offset offset = renderBoxRed.localToGlobal(Offset.zero);
    return offset;
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(() {});
    ololo();
  }

  Animation<Offset> animate(int fishSize) {
    AnimationController _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: fishSize * BASE_ANIMATION_DURATION),
    );

    _animationController.forward();

    _animationControllers.add(_animationController);

    List<double> generated = generate(fishSize);

    final Tween<Offset> _tween = Tween<Offset>(
        begin: Offset.zero, end: Offset(generated[0], generated[1]));

    return _tween.animate(_animationController)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          List<double> generated = generate(fishSize);

          _tween.begin = _tween.end;
          _animationController.reset();
          _tween.end = Offset(generated[0], generated[1]);
          _animationController.forward();
        }
      });
  }

  List<double> generate(int fishSize) {
    List<double> generated = [1, 2];

    if (random.nextBool()) {
      double ololo =
          random.nextInt(generateLeft(fishSize).toInt() + 1).toDouble();
      if (ololo > 1) ololo -= 1;
      generated[0] = ololo;
      generated[1] = generateTop(fishSize);
    } else {
      generated[0] = generateLeft(fishSize);
      double ololo =
          random.nextInt(generateTop(fishSize).toInt() + 1).toDouble();
      if (ololo > 1) ololo -= 1;
      generated[1] = ololo;
    }

    return generated;
  }

  // Max value
  double generateLeft(int fishSize) {
    // Get the screen size
    final Size screenSize = MediaQuery.of(context).size;

    final double offset =
        (screenSize.width / (fishSize * FISH_BASE_WIDTH) / 2).ceilToDouble();

    return offset;
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
    if (someList.isEmpty) {
      setFishes();
    }

    return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      Container(
        color: Colors.blue[700],
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(children: someList.values.toList()),
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
    while (someList.length < FISH_COUNT) {
      Fish fish = Fish.init(random.nextBool(), random.nextInt(2) + 1);
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
      someList[fish] = slideTransition;
    }
  }
}
