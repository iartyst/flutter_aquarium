class Fish {
  final bool isPredator;
  final int size;

  Fish(this.isPredator, this.size);

  String get imageUrl => isPredator
      ? 'https://icons.iconarchive.com/icons/google/noto-emoji-animals-nature/512/22296-shark-icon.png'
      : 'https://icons.iconarchive.com/icons/google/noto-emoji-animals-nature/512/22294-tropical-fish-icon.png';
}
