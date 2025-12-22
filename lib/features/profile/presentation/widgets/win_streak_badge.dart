// Win streak badge widget displaying current win/loss streak.
import 'package:flutter/material.dart';

/// A badge widget that displays the current win or loss streak.
///
/// Only displays when the streak is >= 2 (positive or negative).
/// - Winning streaks: 🔥 emoji with green color
/// - Losing streaks: ❄️ emoji with blue/grey color
class WinStreakBadge extends StatelessWidget {
  final int currentStreak;

  const WinStreakBadge({
    super.key,
    required this.currentStreak,
  });

  bool get shouldDisplay => currentStreak.abs() >= 2;

  bool get isWinningStreak => currentStreak > 0;

  String get streakEmoji => isWinningStreak ? '🔥' : '❄️';

  String get streakText {
    final absStreak = currentStreak.abs();
    final type = isWinningStreak ? 'wins' : 'losses';
    return '$absStreak $type';
  }

  Color get streakColor => isWinningStreak ? Colors.green : Colors.blue;

  @override
  Widget build(BuildContext context) {
    if (!shouldDisplay) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      color: streakColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Emoji
            Text(
              streakEmoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 8),
            // Streak text
            Text(
              streakText,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: streakColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
