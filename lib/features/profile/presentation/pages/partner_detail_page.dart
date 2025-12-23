// Partner detail screen showing comprehensive teammate statistics.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/core/data/models/teammate_stats.dart';
import 'package:play_with_me/core/data/models/user_model.dart';
import 'package:play_with_me/core/services/service_locator.dart';
import 'package:play_with_me/core/domain/repositories/user_repository.dart';
import 'package:play_with_me/features/profile/presentation/bloc/partner_detail/partner_detail_bloc.dart';
import 'package:play_with_me/features/profile/presentation/bloc/partner_detail/partner_detail_event.dart';
import 'package:play_with_me/features/profile/presentation/bloc/partner_detail/partner_detail_state.dart';

class PartnerDetailPage extends StatelessWidget {
  final String userId;
  final String partnerId;

  const PartnerDetailPage({
    super.key,
    required this.userId,
    required this.partnerId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PartnerDetailBloc(
        userRepository: sl<UserRepository>(),
      )..add(PartnerDetailEvent.loadPartnerDetails(
          userId: userId,
          partnerId: partnerId,
        )),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Partner Details'),
        ),
        body: BlocBuilder<PartnerDetailBloc, PartnerDetailState>(
          builder: (context, state) {
            return state.when(
              initial: () => const SizedBox.shrink(),
              loading: () => const Center(child: CircularProgressIndicator()),
              loaded: (stats, partner) => _buildLoadedView(context, stats, partner),
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
    TeammateStats stats,
    UserModel partner,
  ) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Partner header
          _buildPartnerHeader(context, partner),
          const SizedBox(height: 24),

          // Overall record
          _buildRecordCard(context, stats),
          const SizedBox(height: 16),

          // Point differential
          _buildPointDifferentialCard(context, stats),
          const SizedBox(height: 16),

          // ELO change together
          _buildEloCard(context, stats),
          const SizedBox(height: 16),

          // Recent form
          _buildRecentFormCard(context, stats),
        ],
      ),
    );
  }

  Widget _buildPartnerHeader(BuildContext context, UserModel partner) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: theme.colorScheme.primaryContainer,
              backgroundImage:
                  partner.photoUrl != null ? NetworkImage(partner.photoUrl!) : null,
              child: partner.photoUrl == null
                  ? Icon(Icons.person, size: 40, color: theme.colorScheme.onPrimaryContainer)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    partner.displayNameOrEmail,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (partner.displayName != null)
                    Text(
                      partner.email,
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

  Widget _buildRecordCard(BuildContext context, TeammateStats stats) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overall Record',
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
                  'Games',
                  stats.gamesPlayed.toString(),
                  Colors.blue,
                ),
                _buildStatColumn(
                  context,
                  'Win Rate',
                  '${stats.winRate.toStringAsFixed(1)}%',
                  Colors.green,
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

  Widget _buildPointDifferentialCard(BuildContext context, TeammateStats stats) {
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

  Widget _buildEloCard(BuildContext context, TeammateStats stats) {
    final theme = Theme.of(context);
    final isPositive = stats.eloChange >= 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ELO Performance',
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
                  'Total Change',
                  stats.formattedEloChange,
                  isPositive ? Colors.green : Colors.red,
                ),
                _buildStatColumn(
                  context,
                  'Avg Per Game',
                  stats.avgEloChange >= 0
                      ? '+${stats.avgEloChange.toStringAsFixed(1)}'
                      : stats.avgEloChange.toStringAsFixed(1),
                  stats.avgEloChange >= 0 ? Colors.green : Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentFormCard(BuildContext context, TeammateStats stats) {
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
                  'Recent Form',
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
            if (stats.recentGames.isEmpty)
              Center(
                child: Text(
                  'No recent games',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              )
            else
              ...stats.recentGames.map((game) => _buildGameTile(context, game)),
          ],
        ),
      ),
    );
  }

  Widget _buildGameTile(BuildContext context, RecentGameResult game) {
    final theme = Theme.of(context);
    final resultColor = game.won ? Colors.green : Colors.red;

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
                game.resultLetter,
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
                      '${game.pointsScored}-${game.pointsAllowed}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${game.formattedPointDifferential})',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'ELO: ${game.formattedEloChange}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: game.eloChange >= 0 ? Colors.green : Colors.red,
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
