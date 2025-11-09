import 'package:flutter/material.dart';

class LeaderboardOverlay extends StatelessWidget {
  final int score;
  final int bestScore;
  final VoidCallback onClose;

  const LeaderboardOverlay({
    Key? key,
    required this.score,
    required this.bestScore,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Nền mờ
        Container(
          color: Colors.black54,
          width: double.infinity,
          height: double.infinity,
        ),
        Center(
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '🏆 Leaderboard',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Text('Score: $score', style: const TextStyle(fontSize: 18)),
                Text('Best Score: $bestScore', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: onClose,
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
