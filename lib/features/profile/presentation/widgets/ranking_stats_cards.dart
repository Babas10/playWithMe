// Displays four ranking stat cards: global rank, percentile, friends rank, and streak (Story 302.5).
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:play_with_me/core/data/models/user_ranking.dart';
import 'package:play_with_me/core/theme/app_colors.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

/// Four stat cards showing global rank, percentile, friends rank, and current streak.
///
/// Displayed above the ELO progress chart.
class RankingStatsCards extends StatelessWidget {
  final UserRanking? ranking;
  final int currentStreak;

  const RankingStatsCards({
    super.key,
    required this.ranking,
    this.currentStreak = 0,
  });

  @override
  Widget build(BuildContext context) {
    if (ranking == null) {
      return _buildEmptyState(context);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 280) {
          return Column(
            children: [
              _GlobalRankCard(ranking: ranking!),
              const SizedBox(height: 8),
              _PercentileCard(ranking: ranking!),
              const SizedBox(height: 8),
              _FriendsRankCard(ranking: ranking!),
              const SizedBox(height: 8),
              _StreakCard(currentStreak: currentStreak),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: _GlobalRankCard(ranking: ranking!)),
            const SizedBox(width: 6),
            Expanded(child: _PercentileCard(ranking: ranking!)),
            const SizedBox(width: 6),
            Expanded(
              child: _FriendsRankCard(ranking: ranking!),
            ),
            const SizedBox(width: 6),
            Expanded(child: _StreakCard(currentStreak: currentStreak)),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            AppLocalizations.of(context)!.playGamesToUnlockRankings,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Global ranking card
class _GlobalRankCard extends StatelessWidget {
  final UserRanking ranking;

  const _GlobalRankCard({required this.ranking});

  @override
  Widget build(BuildContext context) {
    return _RankingStatCard(
      icon: Icons.public,
      iconColor: AppColors.secondary,
      label: AppLocalizations.of(context)!.globalRank,
      value: ranking.globalRankDisplay,
    );
  }
}

/// Percentile card — uses a gaussian curve painter instead of a Material icon.
class _PercentileCard extends StatelessWidget {
  final UserRanking ranking;

  const _PercentileCard({required this.ranking});

  @override
  Widget build(BuildContext context) {
    return _RankingStatCard(
      customIcon: const SizedBox(
        width: 18,
        height: 18,
        child: CustomPaint(painter: _GaussianCurvePainter(color: AppColors.secondary)),
      ),
      label: AppLocalizations.of(context)!.percentile,
      value: ranking.percentileDisplay,
    );
  }
}

/// Friends ranking card
class _FriendsRankCard extends StatelessWidget {
  final UserRanking ranking;

  const _FriendsRankCard({required this.ranking});

  @override
  Widget build(BuildContext context) {
    return _RankingStatCard(
      icon: Icons.people,
      iconColor: AppColors.secondary,
      label: AppLocalizations.of(context)!.friendsRank,
      value: ranking.friendsRank != null && ranking.totalFriends != null
          ? ranking.friendsRankDisplay!
          : '-',
    );
  }
}

/// Streak card — shows current win/loss streak as a signed number.
///
/// Positive = win streak (+N), negative = loss streak (-N), zero = none (-).
/// Icon and value are always blue (AppColors.secondary) for visual consistency.
class _StreakCard extends StatelessWidget {
  final int currentStreak;

  const _StreakCard({required this.currentStreak});

  @override
  Widget build(BuildContext context) {
    final String streakValue;

    if (currentStreak > 0) {
      streakValue = '+$currentStreak';
    } else if (currentStreak < 0) {
      streakValue = '$currentStreak';
    } else {
      streakValue = '-';
    }

    return _RankingStatCard(
      icon: Icons.trending_up,
      iconColor: AppColors.secondary,
      label: AppLocalizations.of(context)!.streakLabel,
      value: streakValue,
      valueColor: AppColors.secondary,
    );
  }
}

/// Base stat card widget — white background, shadow, centered content.
///
/// Accepts either [icon] + [iconColor] or [customIcon] for the top slot.
class _RankingStatCard extends StatelessWidget {
  final IconData? icon;
  final Color? iconColor;
  final Widget? customIcon;
  final String label;
  final String value;
  final Color? valueColor;

  const _RankingStatCard({
    this.icon,
    this.iconColor,
    this.customIcon,
    required this.label,
    required this.value,
    this.valueColor,
  }) : assert(icon != null || customIcon != null, 'Provide icon or customIcon');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final card = Container(
      height: 85,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          customIcon ?? Icon(icon, size: 18, color: iconColor),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? AppColors.secondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );

    return card;
  }
}

/// Draws a gaussian (bell curve) shape using a real normal distribution formula.
///
/// Samples the gaussian PDF across the canvas width and strokes the resulting path.
class _GaussianCurvePainter extends CustomPainter {
  final Color color;

  const _GaussianCurvePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    const steps = 60;
    // Map canvas x [0, width] to gaussian domain [-3.5, 3.5]
    const xMin = -3.5;
    const xMax = 3.5;
    final gaussianHeight = _gaussian(0); // peak value at x=0

    final path = Path();
    for (int i = 0; i <= steps; i++) {
      final t = i / steps;
      final x = xMin + t * (xMax - xMin);
      final y = _gaussian(x);

      // Flip y: canvas y=0 is top, gaussian peak should be at top
      final cx = t * size.width;
      final cy = size.height - (y / gaussianHeight) * size.height * 0.9;

      if (i == 0) {
        path.moveTo(cx, cy);
      } else {
        path.lineTo(cx, cy);
      }
    }

    canvas.drawPath(path, paint);
  }

  static double _gaussian(double x) {
    return math.exp(-0.5 * x * x);
  }

  @override
  bool shouldRepaint(_GaussianCurvePainter old) => old.color != color;
}
