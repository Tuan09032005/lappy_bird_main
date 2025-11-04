import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'game/flappy_game.dart';
import 'game/game_over_overlay.dart'; // import overlay

void main() {
  final flappyGame = FlappyGame();

  runApp(
    GameWidget(
      game: flappyGame,
      overlayBuilderMap: {
        'game_over_overlay': (context, game) {
          final g = game as FlappyGame;
          return GameOverOverlay(
            score: g.score,
            bestScore: g.bestScore,
            onRestart: () {
              g.restartGame();
              g.overlays.remove('game_over_overlay');
            },
          );
        },
      },
    ),
  );
}
