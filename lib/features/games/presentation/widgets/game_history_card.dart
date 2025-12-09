// Widget displaying a game in history list (Story 14.7)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/data/models/game_model.dart';

class GameHistoryCard extends StatelessWidget {
  final GameModel game;
  final VoidCallback onTap;

  const GameHistoryCard({
    super.key,
    required this.game,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, y');
    final timeFormat = DateFormat('h:mm a');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date and location header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    game.completedAt != null
                        ? dateFormat.format(game.completedAt!)
                        : dateFormat.format(game.scheduledAt),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (game.completedAt != null)
                    Text(
                      timeFormat.format(game.completedAt!),
                      style: theme.textTheme.bodySmall,
                    ),
                ],
              ),
              if (game.location.name != null) ...[
                const SizedBox(height: 4),
                Text(
                  game.location.name!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // Teams and scores
              if (game.teams != null && game.result != null)
                _buildTeamsAndScores(context)
              else
                Text(
                  'No scores recorded',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),

              // ELO changes indicator
              if (game.eloCalculated) ...[
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'ELO Updated',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamsAndScores(BuildContext context) {
    final theme = Theme.of(context);
    final teams = game.teams!;
    final result = game.result!;
    final winnerTeam = result.overallWinner;

    // Count total games won by each team
    int teamAWins = result.games.where((g) => g.winner == 'teamA').length;
    int teamBWins = result.games.where((g) => g.winner == 'teamB').length;

    return Row(
      children: [
        // Team A
        Expanded(
          child: _buildTeamSection(
            context,
            'Team A',
            teams.teamAPlayerIds.length,
            teamAWins,
            winnerTeam == 'teamA',
          ),
        ),
        const SizedBox(width: 16),
        // VS indicator
        Text(
          'VS',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 16),
        // Team B
        Expanded(
          child: _buildTeamSection(
            context,
            'Team B',
            teams.teamBPlayerIds.length,
            teamBWins,
            winnerTeam == 'teamB',
          ),
        ),
      ],
    );
  }

  Widget _buildTeamSection(
    BuildContext context,
    String teamName,
    int playerCount,
    int gamesWon,
    bool isWinner,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isWinner
            ? theme.colorScheme.primaryContainer.withOpacity(0.3)
            : theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: isWinner
            ? Border.all(color: theme.colorScheme.primary, width: 2)
            : null,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                teamName,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (isWinner) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.emoji_events,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$playerCount ${playerCount == 1 ? 'player' : 'players'}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            gamesWon.toString(),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isWinner ? theme.colorScheme.primary : null,
            ),
          ),
          Text(
            'games won',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
