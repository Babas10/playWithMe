// Home screen statistics section with "Performance Overview" title and 4 stat cards.
import 'package:flutter/material.dart';
import 'package:play_with_me/core/data/models/rating_history_entry.dart';
import 'package:play_with_me/core/data/models/user_model.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

// Golden Hour theme colors
const _kSecondary = Color(0xFF004E64);
const _kDanger = Color(0xFFEF476F);
const _kPrimary = Color(0xFFEACE6A);
const _kTextMuted = Color(0xFF64748B);
const _kShadow = Color(0x14004E64);

/// A section widget displaying performance statistics on the home screen.
///
/// Layout:
/// - Section title: "Performance Overview" (uppercase, muted)
/// - Row 1: ELO card (left) + Win Rate card (right) — side-by-side
/// - Row 2: Streak card (left) + Games Played card (right) — side-by-side
class HomeStatsSection extends StatelessWidget {
  final UserModel user;
  final List<RatingHistoryEntry> ratingHistory;

  const HomeStatsSection({
    super.key,
    required this.user,
    required this.ratingHistory,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final trendData = _calculateTrend();
    final hasStreak = user.currentStreak.abs() >= 2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Section title — uppercase, muted, letter-spaced
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Text(
              l10n.performanceOverview.toUpperCase(),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _kTextMuted,
                letterSpacing: 0.8,
              ),
            ),
          ),
          // Row 1: ELO + Win Rate side-by-side
          Row(
            children: [
              Expanded(
                child: _buildEloCard(context, l10n, trendData),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildWinRateCard(context, l10n),
              ),
            ],
          ),
          const SizedBox(height: 15),
          // Row 2: Streak + Games Played side-by-side
          Row(
            children: [
              Expanded(
                child: _buildStreakCard(context, l10n, hasStreak),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildGamesPlayedCard(context, l10n),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEloCard(
    BuildContext context,
    AppLocalizations l10n,
    Map<String, dynamic>? trendData,
  ) {
    return _StatsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.eloRatingLabel,
            style: const TextStyle(
              fontSize: 12,
              color: _kTextMuted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user.eloRating.toStringAsFixed(0),
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: _kSecondary,
            ),
          ),
          if (trendData != null && trendData['delta'] != 0) ...[
            const SizedBox(height: 5),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  trendData['isPositive']
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  size: 13,
                  color: trendData['isPositive'] ? _kPrimary : _kDanger,
                ),
                const SizedBox(width: 2),
                Text(
                  '${trendData['delta'] > 0 ? '+' : ''}${trendData['delta'].toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: trendData['isPositive'] ? _kPrimary : _kDanger,
                  ),
                ),
              ],
            ),
          ] else if (ratingHistory.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                l10n.noGamesPlayedYet,
                style: const TextStyle(
                  fontSize: 10,
                  color: _kTextMuted,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWinRateCard(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return _StatsCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(user.winRate * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: _kSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.winRate,
                  style: const TextStyle(
                    fontSize: 12,
                    color: _kTextMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.winsLosses(user.gamesWon, user.gamesLost),
                  style: const TextStyle(
                    fontSize: 10,
                    color: _kTextMuted,
                  ),
                ),
              ],
            ),
          ),
          // Donut chart with trophy icon
          SizedBox(
            width: 50,
            height: 50,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    value: user.winRate,
                    strokeWidth: 6,
                    backgroundColor: const Color(0xFFEEEEEE),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(_kPrimary),
                  ),
                ),
                const Icon(
                  Icons.emoji_events,
                  size: 16,
                  color: _kPrimary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(
    BuildContext context,
    AppLocalizations l10n,
    bool hasStreak,
  ) {
    final isWinning = user.currentStreak > 0;
    final streakCount = user.currentStreak.abs();

    return _StatsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.streakLabel,
            style: const TextStyle(
              fontSize: 12,
              color: _kTextMuted,
            ),
          ),
          const SizedBox(height: 8),
          if (hasStreak)
            Text(
              isWinning
                  ? l10n.winsStreakCount(streakCount)
                  : l10n.lossesStreakCount(streakCount),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isWinning ? _kPrimary : _kDanger,
              ),
            )
          else
            Text(
              l10n.noStreak,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _kTextMuted.withValues(alpha: 0.5),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGamesPlayedCard(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return _StatsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.gamesPlayed,
            style: const TextStyle(
              fontSize: 12,
              color: _kTextMuted,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                user.gamesPlayed.toString(),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: _kSecondary,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.sports_volleyball,
                size: 24,
                color: _kTextMuted.withValues(alpha: 0.5),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Map<String, dynamic>? _calculateTrend() {
    if (ratingHistory.isEmpty) return null;

    final gamesToAnalyze = ratingHistory.take(5).toList();
    if (gamesToAnalyze.isEmpty) return null;

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

/// A styled card container with soft shadow for the stats grid.
class _StatsCard extends StatelessWidget {
  final Widget child;

  const _StatsCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: _kShadow,
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}
