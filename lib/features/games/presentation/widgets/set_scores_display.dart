import 'package:flutter/material.dart';
import 'package:play_with_me/core/data/models/game_model.dart';

class SetScoresDisplay extends StatelessWidget {
  final GameResult result;

  const SetScoresDisplay({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    if (result.games.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: result.games.map((game) {
        // Flatten sets if game has multiple, or just show set scores
        // Assuming common case where IndividualGame is a set or contains the score info we want
        // If IndividualGame has multiple sets, we probably want to show them.
        
        final scores = game.sets.map((s) => '${s.teamAPoints}-${s.teamBPoints}').join(', ');
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            scores,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        );
      }).toList(),
    );
  }
}
