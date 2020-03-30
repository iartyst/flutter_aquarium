import 'package:meta/meta.dart';

import 'Config.dart';

class Fish {
  Fish({
    @required this.isPredator,
    @required this.size,
  });

  final bool isPredator;
  final int size;

  String get imageUrl =>
      isPredator ? PREDATOR_IMAGE_URL : HERBIVOROUS_IMAGE_URL;
}
