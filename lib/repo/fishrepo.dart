import 'dart:async';
import 'dart:math';

import '../model/Config.dart';
import '../model/Fish.dart';

class FishRepository {
  final Random random = new Random();

  Future<Fish> getFish() async {
    await Future.delayed(Duration(seconds: ADD_NEW_FISH_TIMER));
    return Fish(
        isPredator: random.nextBool(),
        size: random.nextInt(FISH_MAX_SIZE) + 1);
  }

  Future<List<Fish>> getFishes() async {
    await Future.delayed(Duration(seconds: 2));
    final fishes = List<Fish>();
    while (fishes.length < FISH_COUNT) {
      fishes.add(Fish(
          isPredator: random.nextBool(),
          size: random.nextInt(FISH_MAX_SIZE) + 1));
    }
    return fishes;
  }
}
