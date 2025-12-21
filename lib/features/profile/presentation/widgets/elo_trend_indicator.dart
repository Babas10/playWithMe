// ELO trend indicator widget showing rating delta and direction.
import 'package:flutter/material.dart';
import 'package:play_with_me/core/data/models/rating_history_entry.dart';

/// Widget that displays ELO rating with trend indicator.
///
/// Shows:
/// - Current ELO value (large, prominent)
/// - Trend arrow (↑ or ↓) based on recent rating changes
/// - Rating delta over last N games
/// - Optional micro-sparkline (future enhancement)
class ELOTrendIndicator extends StatelessWidget {
  final double currentElo;
  final List<RatingHistoryEntry> recentHistory;
  final int lookbackGames;

  const ELOTrendIndicator({
    super.key,
    required this.currentElo,
    required this.recentHistory,
    this.lookbackGames = 5,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trendData = _calculateTrend();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Label
            Text(
              'ELO Rating',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            // Current ELO with trend
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                // Current ELO
                Text(
                  currentElo.toStringAsFixed(0),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (trendData != null && trendData['delta'] != 0) ...[
                  const SizedBox(width: 8),
                  // Trend arrow
                  Icon(
                    trendData['isPositive']
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    size: 16,
                    color: trendData['isPositive']
                        ? Colors.green
                        : Colors.red,
                  ),
                  const SizedBox(width: 4),
                  // Delta
                  Text(
                    '${trendData['delta'] > 0 ? '+' : ''}${trendData['delta'].toStringAsFixed(0)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: trendData['isPositive']
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
            // Sub-label showing lookback period
            if (trendData != null && trendData['delta'] != 0) ...[
              const SizedBox(height: 4),
              Text(
                'Last ${trendData['gamesCount']} games',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ] else if (recentHistory.isEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'No games played yet',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Calculates the trend data from recent rating history.
  ///
  /// Returns a map with:
  /// - 'delta': The rating change over the lookback period
  /// - 'isPositive': Whether the trend is positive
  /// - 'gamesCount': Number of games used in calculation
  ///
  /// Returns null if there's insufficient history.
  Map<String, dynamic>? _calculateTrend() {
    if (recentHistory.isEmpty) return null;

    // Take the most recent N games (up to lookbackGames)
    final gamesToAnalyze = recentHistory.take(lookbackGames).toList();

    if (gamesToAnalyze.isEmpty) return null;

    // Calculate total rating change over these games
    // Recent history is sorted descending by timestamp, so:
    // - First entry is most recent (newest rating)
    // - Last entry is oldest in our lookback window
    final newestRating = gamesToAnalyze.first.newRating;
    final oldestRating = gamesToAnalyze.last.oldRating;
    final delta = newestRating - oldestRating;

    return {
      'delta': delta,
      'isPositive': delta > 0,
      'gamesCount': gamesToAnalyze.length,
    };
  }
}
