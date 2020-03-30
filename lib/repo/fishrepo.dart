import 'dart:async';
import 'dart:math';

import '../model/Config.dart';
import '../model/Fish.dart';

class FishRepository {
  final Random random = new Random();

  Future<Fish> getFish() async {
    await Future.delayed(Duration(seconds: ADD_NEW_FISH_TIMER));
    return _generateFish();
  }

  Future<List<Fish>> getFishes() async {
    /// Added some delay to show initial state
    await Future.delayed(Duration(seconds: 2));
    final fishes = List<Fish>();
    while (fishes.length < FISH_COUNT) {
      fishes.add(_generateFish());
    }
    return fishes;
  }

  Fish _generateFish() {
    return Fish(
        isPredator: random.nextBool(),
        size: random.nextInt(FISH_MAX_SIZE) + 1);
  }
}
