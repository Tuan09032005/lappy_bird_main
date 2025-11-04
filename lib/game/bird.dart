import 'dart:ui' show lerpDouble;
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'flappy_game.dart';

class Bird extends SpriteAnimationComponent with HasGameRef<FlappyGame> {
  double gravity = 600;
  double flapVelocity = -250;
  double velocityY = 0;

  Bird() : super(size: Vector2(40, 30));

  @override
  Future<void> onLoad() async {
    final up = await gameRef.loadSprite('yellowbird-upflap.png');
    final mid = await gameRef.loadSprite('yellowbird-midflap.png');
    final down = await gameRef.loadSprite('yellowbird-downflap.png');

    animation = SpriteAnimation.spriteList(
      [up, mid, down, mid],
      stepTime: 0.12,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!gameRef.isStarted || gameRef.isGameOver) return;

    velocityY += gravity * dt;
    y += velocityY * dt;
    angle = lerpDouble(angle, velocityY > 0 ? 0.5 : -0.3, 0.1)!;
  }

  void flap() => velocityY = flapVelocity;

  void stopAnimation() {
    if (animationTicker != null) {
      animationTicker!.paused = true;
    }
  }

  void resumeAnimation() {
    if (animationTicker != null) {
      animationTicker!.paused = false;
    }
  }
}
