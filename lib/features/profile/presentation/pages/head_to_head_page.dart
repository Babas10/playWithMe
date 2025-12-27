// Head-to-head rivalry screen showing comprehensive opponent statistics.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/core/data/models/head_to_head_stats.dart';
import 'package:play_with_me/core/data/models/user_model.dart';
import 'package:play_with_me/core/services/service_locator.dart';
import 'package:play_with_me/core/domain/repositories/user_repository.dart';
import 'package:play_with_me/features/profile/presentation/bloc/head_to_head/head_to_head_bloc.dart';
import 'package:play_with_me/features/profile/presentation/bloc/head_to_head/head_to_head_event.dart';
import 'package:play_with_me/features/profile/presentation/bloc/head_to_head/head_to_head_state.dart';

class HeadToHeadPage extends StatelessWidget {
  final String userId;
  final String opponentId;

  const HeadToHeadPage({
    super.key,
    required this.userId,
    required this.opponentId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HeadToHeadBloc(
        userRepository: sl<UserRepository>(),
      )..add(HeadToHeadEvent.loadHeadToHead(
          userId: userId,
          opponentId: opponentId,
        )),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Head-to-Head'),
        ),
        body: BlocBuilder<HeadToHeadBloc, HeadToHeadState>(
          builder: (context, state) {
            return state.when(
              initial: () => const SizedBox.shrink(),
              loading: () => const Center(child: CircularProgressIndicator()),
              loaded: (stats) => _buildLoadedView(context, stats),
              error: (message) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(message, textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadedView(
    BuildContext context,
    HeadToHeadStats stats,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Opponent header
          _buildOpponentHeader(context, stats),
          const SizedBox(height: 24),

          // Rivalry intensity
          _buildRivalryCard(context, stats),
          const SizedBox(height: 16),

          // Overall record
          _buildRecordCard(context, stats),
          const SizedBox(height: 16),

          // Point differential
          _buildPointDifferentialCard(context, stats),
          const SizedBox(height: 16),

          // Matchup margins
          _buildMarginsCard(context, stats),
          const SizedBox(height: 16),

          // Recent matchups
          _buildRecentMatchupsCard(context, stats),
        ],
      ),
    );
  }

  Widget _buildOpponentHeader(BuildContext context, HeadToHeadStats stats) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: theme.colorScheme.errorContainer,
                  backgroundImage:
                      stats.opponentPhotoUrl != null ? NetworkImage(stats.opponentPhotoUrl!) : null,
                  child: stats.opponentPhotoUrl == null
                      ? Icon(Icons.person, size: 40, color: theme.colorScheme.onErrorContainer)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.sports_kabaddi, size: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stats.opponentDisplayName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (stats.opponentName != null && stats.opponentEmail != null)
                    Text(
                      stats.opponentEmail!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRivalryCard(BuildContext context, HeadToHeadStats stats) {
    final theme = Theme.of(context);

    return Card(
      color: Colors.red.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              stats.rivalryIntensity,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              stats.matchupAdvantage,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordCard(BuildContext context, HeadToHeadStats stats) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Head-to-Head Record',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn(
                  context,
                  'Matchups',
                  stats.gamesPlayed.toString(),
                  Colors.blue,
                ),
                _buildStatColumn(
                  context,
                  'Win Rate',
                  '${stats.winRate.toStringAsFixed(1)}%',
                  stats.winRate >= 50 ? Colors.green : Colors.red,
                ),
                _buildStatColumn(
                  context,
                  'Record',
                  stats.recordString,
                  Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointDifferentialCard(BuildContext context, HeadToHeadStats stats) {
    final theme = Theme.of(context);
    final avgDiff = stats.avgPointDifferential;
    final isPositive = avgDiff >= 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Point Differential',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn(
                  context,
                  'Avg Per Game',
                  stats.formattedPointDifferential,
                  isPositive ? Colors.green : Colors.red,
                ),
                _buildStatColumn(
                  context,
                  'Points For',
                  stats.avgPointsScored.toStringAsFixed(1),
                  Colors.blue,
                ),
                _buildStatColumn(
                  context,
                  'Points Against',
                  stats.avgPointsAllowed.toStringAsFixed(1),
                  Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarginsCard(BuildContext context, HeadToHeadStats stats) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Matchup Margins',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn(
                  context,
                  'Biggest Win',
                  '+${stats.largestVictoryMargin}',
                  Colors.green,
                ),
                _buildStatColumn(
                  context,
                  'Worst Loss',
                  '-${stats.largestDefeatMargin}',
                  Colors.red,
                ),
                _buildStatColumn(
                  context,
                  'ELO vs Them',
                  stats.formattedEloChange,
                  stats.eloChange >= 0 ? Colors.green : Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentMatchupsCard(BuildContext context, HeadToHeadStats stats) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Matchups',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (stats.currentStreak.abs() > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: stats.isOnWinningStreak
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${stats.currentStreak.abs()} ${stats.isOnWinningStreak ? "W" : "L"} Streak',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: stats.isOnWinningStreak ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (stats.recentMatchups.isEmpty)
              Center(
                child: Text(
                  'No recent matchups',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              )
            else
              ...stats.recentMatchups.map((matchup) => _buildMatchupTile(context, matchup)),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchupTile(BuildContext context, HeadToHeadGameResult matchup) {
    final theme = Theme.of(context);
    final resultColor = matchup.won ? Colors.green : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: resultColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: resultColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                matchup.resultLetter,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: resultColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      matchup.scoreDisplay,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${matchup.formattedPointDifferential})',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'ELO: ${matchup.formattedEloChange}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: matchup.eloChange >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}
