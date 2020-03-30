import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

import 'bloc/fishbloc.dart';
import 'model/Config.dart';
import 'model/Fish.dart';
import 'repo/fishrepo.dart';

void main() {
  runApp(_MyApp());
}

class _MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Aquarium',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Container(child: _FlutterAquarium(FishRepository())));
  }
}

class _FlutterAquarium extends StatefulWidget {
  _FlutterAquarium(this._repository);

  final FishRepository _repository;

  @override
  _FlutterAquariumState createState() => _FlutterAquariumState();
}

class _FlutterAquariumState extends State<_FlutterAquarium>
    with TickerProviderStateMixin {
  FishBloc _fishBloc;

  Map<Fish, SlideTransition> _fishAndViewsMap = Map();
  List<AnimationController> _animationControllers = new List();

  double _screenHeight;
  double _screenWidth;

  @override
  initState() {
    super.initState();
    _fishBloc = FishBloc(widget._repository);
    _fishBloc.loadFishesData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: SafeArea(
        child: StreamBuilder<DataState>(
          stream: _fishBloc.fish,
          initialData: FishInitState(),
          builder: (context, snapshot) {
            switch (snapshot.data.runtimeType) {
              case FishInitState:
                {
                  return _buildInitial();
                }
              case FishesDataState:
                {
                  FishesDataState state = snapshot.data;
                  _createFishesViews(state.fishes);
                  return _buildContent();
                }
              case FishDataState:
                {
                  FishDataState state = snapshot.data;
                  _createFishView(state.fish);
                  return _buildContent();
                }
              case FishLoadingState:
                return _buildLoading();
              default:
                return _buildContent();
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fishBloc.dispose();
    _animationControllers.forEach((animationController) {
      animationController.dispose();
    });
    super.dispose();
  }

  //region Widget states
  Widget _buildInitial() {
    _setScreenData();
    return const Center(
      child: CircularProgressIndicator(backgroundColor: Colors.white),
    );
  }

  Widget _buildContent() {
    return Stack(children: _fishAndViewsMap.values.toList());
  }

  Widget _buildLoading() {
    return Stack(
      children: <Widget>[
        const Center(
          child: Text("One fish just ate another!"),
        ),
        _buildContent()
      ],
    );
  }

  //endregion

  //region Work with views
  /// Once after screen is created need to set values
  void _setScreenData() {
    _screenHeight =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;
    _screenWidth = MediaQuery.of(context).size.width;
  }

  void _createFishesViews(final List<Fish> fishes) {
    fishes.forEach((fish) {
      _createFishView(fish);
    });
  }

  /// Create fish view and add it into map
  void _createFishView(final Fish fish) {
    final SlideTransition slideTransition = SlideTransition(
      position: _animate(fish.size),
      child: Image.network(
        fish.imageUrl,
        key: GlobalKey(),
        width: fish.size * FISH_BASE_WIDTH,
        height: fish.size * FISH_BASE_HEIGHT,
      ),
    );
    _fishAndViewsMap[fish] = slideTransition;
  }

  //endregion

  //region Work with Offset and Animation
  Animation<Offset> _animate(final int fishSize) {
    final AnimationController _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: fishSize * BASE_ANIMATION_DURATION),
    );

    _animationController.forward();
    _animationControllers.add(_animationController);

    final Tween<Offset> _tween = Tween<Offset>(
        begin: _generateOffset(fishSize), end: _generateOffset(fishSize));

    return _tween.animate(_animationController)
      ..addListener(() {
        /**
         * To check the intersection of the views at each tick of the animation
         * go through the algorithm
         * */
        _checkViews();
      })
      ..addStatusListener((status) {
        /**
         * Make the movement animation endless by constantly updating from and to
         */
        if (status == AnimationStatus.completed) {
          _tween.begin = _tween.end;
          _animationController.reset();
          _tween.end = _generateOffset(fishSize);
          _animationController.forward();
        }
      });
  }

  Offset _generateOffset(int fishSize) {
    return Offset(
        _generateHorizontal(fishSize) * _fishBloc.getRandom().nextDouble(),
        _generateVertical(fishSize) * _fishBloc.getRandom().nextDouble());
  }

  /// Max width value
  double _generateHorizontal(int fishSize) {
    return ((_screenWidth - (fishSize * FISH_BASE_WIDTH)) /
        (fishSize * FISH_BASE_WIDTH));
  }

  /// Max height value
  double _generateVertical(int fishSize) {
    return ((_screenHeight - (fishSize * FISH_BASE_HEIGHT)) /
        (fishSize * FISH_BASE_HEIGHT));
  }

//endregion

  //region Check Fish views on the screen
  void _checkViews() {
    final sizeBefore = _fishAndViewsMap.length;
    _checkAreThereFishesAtSamePoint();

    /// If there are fewer fish, start the timer to add a new
    if (sizeBefore > _fishAndViewsMap.length) {
      _fishBloc.loadFishData();
    }
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

  /// Get the view position on the screen.
  Offset _getSlidePosition(SlideTransition slide) {
    final GlobalKey key = slide.child.key;
    final RenderBox renderBoxRed = key.currentContext?.findRenderObject();
    return renderBoxRed?.localToGlobal(Offset.zero);
  }
//endregion
}
