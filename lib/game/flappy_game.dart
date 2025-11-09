import 'dart:math';
import 'dart:ui' show lerpDouble;
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';

import 'bird.dart';
import 'pipe.dart';
import 'pipe_pair.dart';
import 'game_over_overlay.dart';
import '../services/db_helper.dart';

class FlappyGame extends FlameGame with TapDetector {
  late SpriteComponent background;
  late SpriteComponent ground;
  late Bird bird;
  final List<PipePair> pipes = [];

  double pipeTimer = 0;
  int score = 0;
  int bestScore = 0;
  bool isStarted = false;
  bool isGameOver = false;

  late SpriteComponent gameOverText;
  late SpriteComponent messageText;

  Map<int, Sprite> numberSprites = {};
  List<SpriteComponent> scoreDigits = [];

  @override
  Future<void> onLoad() async {
    await images.loadAll([
      'background-day.png',
      'base.png',
      'pipe_body.png',
      'pipe_head.png',
      'yellowbird-upflap.png',
      'yellowbird-midflap.png',
      'yellowbird-downflap.png',
      'gameover.png',
      'message.png',
      '0.png','1.png','2.png','3.png','4.png','5.png','6.png','7.png','8.png','9.png',
      'm0.png','m1.png','m2.png'
    ]);

    await loadNumberSprites();

    // preload âm thanh để không bị delay
    FlameAudio.audioCache.loadAll([
      'wing.wav',
      'hit.wav',
      'point.wav',
      'die.wav',
    ]);

    background = SpriteComponent()
      ..sprite = await loadSprite('background-day.png')
      ..size = size
      ..priority = 0;

    ground = SpriteComponent()
      ..sprite = await loadSprite('base.png')
      ..size = Vector2(size.x, size.y * 0.15)
      ..position = Vector2(0, size.y * 0.85)
      ..priority = 10;

    bird = Bird()
      ..position = Vector2(size.x / 4, size.y / 1.7)
      ..priority = 5;

    gameOverText = SpriteComponent()
      ..sprite = await loadSprite('gameover.png')
      ..size = Vector2(192, 42)
      ..position = Vector2(size.x / 2 - 96, size.y / 3)
      ..opacity = 0
      ..priority = 20;

    messageText = SpriteComponent()
      ..sprite = await loadSprite('message.png')
      ..size = Vector2(300, 550)
      ..opacity = 1
      ..priority = 15;
    messageText.position = size / 2 - messageText.size / 2;

    add(background);
    add(bird);
    add(ground);
    add(messageText);
    add(gameOverText);

    // Lấy best score khi game bắt đầu
    bestScore = await DBHelper().getBestScore();
  }

  Future<void> loadNumberSprites() async {
    numberSprites = {};
    for (int i = 0; i < 10; i++) {
      numberSprites[i] = await loadSprite('$i.png');
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isStarted || isGameOver) return;

    pipeTimer += dt;
    if (pipeTimer > 2.2) {
      pipeTimer = 0;
      addPipe();
    }

    pipes.removeWhere((p) {
      p.update(dt);
      return p.offScreen;
    });

    for (final pipe in pipes) {
      if (pipe.collides(bird)) {
        FlameAudio.play('hit.wav');
        endGame();
        return;
      }
    }

    if (bird.position.y > ground.position.y - bird.size.y / 2 ||
        bird.position.y < 0) {
      FlameAudio.play('hit.wav');
      endGame();
    }

    for (final pipe in pipes) {
      if (!pipe.passed && pipe.x + pipe.width < bird.x) {
        pipe.passed = true;
        score++;
        updateScoreDisplay();
        FlameAudio.play('point.wav');
      }
    }
  }

  void startGame() {
    isStarted = true;
    isGameOver = false;
    score = 0;
    pipeTimer = 0;
    pipes.clear();
    messageText.opacity = 0;
    gameOverText.opacity = 0;
    updateScoreDisplay();
    bird.resumeAnimation();
  }

  void restartGame() {
    for (final p in pipes) {
      remove(p.top);
      remove(p.bottom);
    }
    pipes.clear();

    bird.position = Vector2(size.x / 4, size.y / 1.7);
    bird.velocityY = 0;
    bird.angle = 0;

    isGameOver = false;
    isStarted = false;
    score = 0;
    gameOverText.opacity = 0;
    messageText.opacity = 1;

    for (var digit in scoreDigits) {
      remove(digit);
    }
    scoreDigits.clear();
    overlays.remove('game_over_overlay');
    bird.resumeAnimation();
  }

  Future<void> endGame() async {
    if (isGameOver) return;
    isGameOver = true;
    bird.stopAnimation();
    gameOverText.opacity = 1;

    final db = DBHelper();
    await db.updateBestScore(score); // chỉ update nếu cao hơn
    bestScore = await db.getBestScore(); // đọc lại giá trị hiện tại

    overlays.add('game_over_overlay');
    FlameAudio.play('die.wav');
  }


  void updateScoreDisplay() {
    for (var digit in scoreDigits) {
      remove(digit);
    }
    scoreDigits.clear();

    String scoreStr = score.toString();
    const digitWidth = 24.0;
    const digitHeight = 36.0;

    double totalWidth = scoreStr.length * digitWidth;
    double startX = (size.x - totalWidth) / 2;
    double posY = size.y * 0.1;

    for (int i = 0; i < scoreStr.length; i++) {
      int digit = int.parse(scoreStr[i]);
      var digitComp = SpriteComponent(
        sprite: numberSprites[digit]!,
        size: Vector2(digitWidth, digitHeight),
        position: Vector2(startX + i * digitWidth, posY),
        priority: 20,
      );

      scoreDigits.add(digitComp);
      add(digitComp);
    }
  }

  void addPipe() async {
    double gap = size.y * 0.24;
    double mid = size.y * 0.45;
    double offset = Random().nextDouble() * (size.y * 0.25) - size.y * 0.125;

    double topHeight = (mid + offset - gap / 2);
    double bottomY = mid + offset + gap / 2;
    double bottomHeight = size.y - bottomY - (size.y * 0.15);

    final topPipe = PipeDynamic(true)
      ..x = size.x
      ..y = 0;
    await add(topPipe);
    topPipe.build(topHeight);

    final bottomPipe = PipeDynamic(false)
      ..x = size.x
      ..y = bottomY;
    await add(bottomPipe);
    bottomPipe.build(bottomHeight);

    final pair = PipePair(topPipe, bottomPipe);
    pipes.add(pair);
  }

  @override
  void onTap() {
    if (!isStarted) {
      startGame();
    } else if (isGameOver) {
      restartGame();
    } else {
      bird.flap();
      FlameAudio.play('wing.wav');
    }
  }

  int getHighScore() => bestScore;
}
