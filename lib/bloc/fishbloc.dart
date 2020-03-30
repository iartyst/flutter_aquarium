import 'dart:async';
import 'dart:math';

import 'package:flutterapp/model/Fish.dart';

import '../repo/fishrepo.dart';

class FishBloc {
  FishBloc(this._repository);

  final FishRepository _repository;

  final _fishStreamController = StreamController<DataState>();

  Stream<DataState> get fish => _fishStreamController.stream;

  void loadFishData() {
    _fishStreamController.sink.add(DataState._fishLoading());
    _repository.getFish().then((fish) {
      _fishStreamController.sink.add(DataState._fishData(fish));
    });
  }

  void loadFishesData() {
    _repository.getFishes().then((fishes) {
      _fishStreamController.sink.add(DataState._fishesData(fishes));
    });
  }

  void dispose() {
    _fishStreamController.close();
  }

  Random getRandom() {
    return _repository.random;
  }
}

class DataState {
  DataState();

  factory DataState._fishData(Fish fish) = FishDataState;

  factory DataState._fishesData(List<Fish> fishes) = FishesDataState;

  factory DataState._fishLoading() = FishLoadingState;
}

class FishInitState extends DataState {}

class FishLoadingState extends DataState {}

class FishDataState extends DataState {
  FishDataState(this.fish);

  final Fish fish;
}

class FishesDataState extends DataState {
  FishesDataState(this.fishes);

  final List<Fish> fishes;
}
