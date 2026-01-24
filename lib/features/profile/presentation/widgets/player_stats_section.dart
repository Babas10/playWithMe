import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/l10n/app_localizations.dart';
import 'package:play_with_me/features/profile/presentation/bloc/player_stats/player_stats_bloc.dart';
import 'package:play_with_me/features/profile/presentation/bloc/player_stats/player_stats_state.dart';
import 'package:play_with_me/features/profile/presentation/widgets/elo_history_chart.dart';
import 'package:play_with_me/features/profile/presentation/widgets/stat_card.dart';

class PlayerStatsSection extends StatelessWidget {
  const PlayerStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<PlayerStatsBloc, PlayerStatsState>(
      builder: (context, state) {
        if (state is PlayerStatsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is PlayerStatsError) {
          return Center(child: Text(l10n.error(state.message)));
        }

        if (state is PlayerStatsLoaded) {
          final user = state.user;
          final history = state.history;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  l10n.performanceStats,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),

              // ELO History Chart
              Container(
                height: 200,
                padding: const EdgeInsets.all(16.0),
                child: EloHistoryChart(
                  history: history,
                  currentRating: user.eloRating,
                ),
              ),

              // Stats Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                padding: const EdgeInsets.all(16.0),
                mainAxisSpacing: 12.0,
                crossAxisSpacing: 12.0,
                children: [
                  StatCard(
                    label: l10n.eloRatingLabel,
                    value: user.eloRating.toStringAsFixed(0),
                    subLabel: l10n.peak(user.eloPeak.toStringAsFixed(0)),
                    icon: Icons.show_chart,
                    iconColor: Colors.blue,
                  ),
                  StatCard(
                    label: l10n.winRate,
                    value: '${(user.winRate * 100).toStringAsFixed(1)}%',
                    subLabel: l10n.winsLosses(user.gamesWon, user.gamesLost),
                    icon: Icons.pie_chart,
                    iconColor: Colors.green,
                  ),
                  StatCard(
                    label: l10n.streakLabel,
                    value: user.streakValue.toString(),
                    subLabel: user.isOnWinningStreak ? l10n.winning : (user.isOnLosingStreak ? l10n.losingStreak : l10n.noStreak),
                    icon: Icons.local_fire_department,
                    iconColor: user.isOnWinningStreak ? Colors.orange : Colors.grey,
                  ),
                  StatCard(
                    label: l10n.gamesPlayedLabel,
                    value: user.gamesPlayed.toString(),
                    icon: Icons.sports_volleyball,
                    iconColor: Colors.orange,
                  ),
                ],
              ),

              // Best Teammate (Optional, if data exists)
              if (user.teammateStats.isNotEmpty)
                _BestTeammateCard(teammateStats: user.teammateStats),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _BestTeammateCard extends StatelessWidget {
  final Map<String, dynamic> teammateStats;

  const _BestTeammateCard({required this.teammateStats});

  String? _getBestTeammateId() {
    if (teammateStats.isEmpty) return null;
    
    String? bestId;
    int maxWins = -1;
    
    teammateStats.forEach((key, value) {
      final wins = value['gamesWon'] as int? ?? 0;
      if (wins > maxWins) {
        maxWins = wins;
        bestId = key;
      }
    });
    
    return bestId;
  }

  Map<String, dynamic>? _getStatsForId(String id) {
    return teammateStats[id] as Map<String, dynamic>?;
  }

  @override
  Widget build(BuildContext context) {
    final bestId = _getBestTeammateId();
    if (bestId == null) return const SizedBox.shrink();

    final stats = _getStatsForId(bestId);
    final wins = stats?['gamesWon'] ?? 0;
    final played = stats?['gamesPlayed'] ?? 0;
    final winRate = played > 0 ? (wins / played * 100).toStringAsFixed(1) : '0.0';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        child: ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)), // Placeholder for avatar
          title: Text(AppLocalizations.of(context)!.bestTeammate),
          subtitle: Text('ID: ${bestId.substring(0, 5)}... • $wins wins ($winRate%)'), // ID is temporary until we resolve name
          trailing: const Icon(Icons.star, color: Colors.amber),
        ),
      ),
    );
  }
}
