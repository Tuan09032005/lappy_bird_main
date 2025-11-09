import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'game/flappy_game.dart';
import 'game/game_over_overlay.dart';
import 'supabase_config.dart';
import 'leaderboard_overlay.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseManager().init();

  final flappyGame = FlappyGame();

  runApp(
    GameWidget(
      game: flappyGame,
      overlayBuilderMap: {
        // Màn hình game over
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

        // Màn hình leaderboard
        'leaderboard_overlay': (context, game) {
          final g = game as FlappyGame;
          return LeaderboardOverlay(
            score: g.score,
            bestScore: g.bestScore,
            onClose: () => g.overlays.remove('leaderboard_overlay'),
          );
        },
      },
    ),
  );
}
