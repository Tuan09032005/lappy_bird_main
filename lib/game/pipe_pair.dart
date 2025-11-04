import 'package:flame/components.dart';
import 'pipe.dart';
import 'bird.dart';

class PipePair {
  final PipeDynamic top;
  final PipeDynamic bottom;
  bool passed = false;

  PipePair(this.top, this.bottom);

  double get x => top.x;
  double get width => top.width;
  bool get offScreen => top.offScreen && bottom.offScreen;

  void update(double dt) {
    top.update(dt);
    bottom.update(dt);
  }

  bool collides(Bird bird) {
    return top.collides(bird) || bottom.collides(bird);
  }

  int score = 0;
  List<SpriteComponent> scoreDigits = [];
}
