import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'flappy_game.dart';
import 'bird.dart';

class PipeDynamic extends PositionComponent with HasGameRef<FlappyGame> {
  final bool isTop;
  bool passed = false;
  bool offScreen = false;

  final double pipeWidth = 52;
  double height = 0;

  late Sprite headSprite;
  late Sprite bodySprite;

  PipeDynamic(this.isTop);

  @override
  Future<void> onLoad() async {
    headSprite = await gameRef.loadSprite('pipe_head.png');
    bodySprite = await gameRef.loadSprite('pipe_body.png');
  }

  void build(double totalHeight) {
    height = totalHeight;
    removeAll(children.toList());

    int numBodies = ((totalHeight - 23) / 296).ceil();

    for (int i = 0; i < numBodies; i++) {
      double bodyY = isTop
          ? height - 23 - (i + 1) * 296
          : i * 296 + 23;

      final body = SpriteComponent()
        ..sprite = bodySprite
        ..size = Vector2(pipeWidth, 296)
        ..position = Vector2(0, bodyY);
      add(body);
    }

    final head = SpriteComponent()
      ..sprite = headSprite
      ..size = Vector2(pipeWidth, 23)
      ..position = Vector2(0, isTop ? height - 23 : 0);
    add(head);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameRef.isGameOver) return;
    x -= 120 * dt;
    if (x + pipeWidth < 0) offScreen = true;
  }

  bool collides(Bird bird) {
    final birdRect = Rect.fromLTWH(bird.x, bird.y, bird.width, bird.height);
    final pipeRect = Rect.fromLTWH(x, y, pipeWidth, height);
    return birdRect.overlaps(pipeRect);
  }
}
