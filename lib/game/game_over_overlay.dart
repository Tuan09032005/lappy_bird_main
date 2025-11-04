import 'package:flutter/material.dart';

class GameOverOverlay extends StatelessWidget {
  final int score;
  final int bestScore;
  final VoidCallback onRestart;

  const GameOverOverlay({
    super.key,
    required this.score,
    required this.bestScore,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    // Chọn huy chương dựa vào điểm
    String? medalAsset;
    if (score >= 50) {
      medalAsset = 'assets/images/m2.png';
    } else if (score >= 20) {
      medalAsset = 'assets/images/m1.png';
    } else if (score > 0) {
      medalAsset = 'assets/images/m0.png';
    }

    return Material(
      color: Colors.black54, // nền mờ tối
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (medalAsset != null)
              Image.asset(
                medalAsset,
                width: 64,
                height: 64,
              ),
            const SizedBox(height: 16),
            Text(
              'SCORE: $score',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 4,
                    color: Colors.black87,
                    offset: Offset(2, 2),
                  )
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'BEST: $bestScore',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 3,
                    color: Colors.black87,
                    offset: Offset(2, 2),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRestart,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('RESTART'),
            ),
          ],
        ),
      ),
    );
  }
}
