import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'game/flappy_game.dart';
import 'game/game_over_overlay.dart';
import 'supabase_config.dart'; // ✅ Thêm dòng này

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Khởi tạo Supabase
  await SupabaseManager().init();

  final flappyGame = FlappyGame();

  runApp(
    GameWidget(
      game: flappyGame,
      overlayBuilderMap: {
        'game_over_overlay': (context, game) {
          final g = game as FlappyGame;
          return GameOverOverlay(
            score: g.score,
            bestScore: g.bestScore, // hiển thị đúng best score thực tế
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
