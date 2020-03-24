class Fish {
  bool isPredator;
  int size;

  Fish.init(this.isPredator, this.size);

  String getImageUrl() {
    return isPredator
        ? 'https://icons.iconarchive.com/icons/google/noto-emoji-animals-nature/512/22296-shark-icon.png'
        : 'https://icons.iconarchive.com/icons/google/noto-emoji-animals-nature/512/22294-tropical-fish-icon.png';
  }

// TODO add devotion algorithm
// TODO add tests
}
