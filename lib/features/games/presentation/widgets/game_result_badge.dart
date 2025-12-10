import 'package:flutter/material.dart';
import 'package:play_with_me/core/data/models/game_model.dart';

class GameResultBadge extends StatelessWidget {
  final GameResult result;
  final VoidCallback? onTap;

  const GameResultBadge({
    super.key,
    required this.result,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final winnerName = result.overallWinner == 'teamA' ? 'Team A' : 'Team B';
    final scoreText = '$winnerName won ${result.scoreDescription}';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events, size: 16, color: Colors.green.shade700),
            const SizedBox(width: 4),
            Text(
              scoreText,
              style: TextStyle(
                color: Colors.green.shade800,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
