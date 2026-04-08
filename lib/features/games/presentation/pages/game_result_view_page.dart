// Result view page for a completed game (Story 14.13).
// Shows ELO rating changes with per-player win/loss counts and per-game team names.
import 'package:flutter/material.dart';
import 'package:play_with_me/core/theme/app_colors.dart';
import 'package:play_with_me/core/theme/play_with_me_app_bar.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

import '../../../../core/data/models/game_model.dart';
import '../../../../core/data/models/rating_history_entry.dart';
import '../../../../core/data/models/user_model.dart';

class GameResultViewPage extends StatelessWidget {
  final GameModel game;
  final Map<String, UserModel>? players;
  final Map<String, RatingHistoryEntry?> playerEloUpdates;

  const GameResultViewPage({
    super.key,
    required this.game,
    this.players,
    this.playerEloUpdates = const {},
  });

  /// Per-player win and loss counts across all individual games.
  /// Uses per-game teams when present, session-level teams as fallback.
  Map<String, ({int wins, int losses})> _computeWinLoss(GameResult result) {
    final counts = <String, ({int wins, int losses})>{};

    for (final individualGame in result.games) {
      final gameTeams = individualGame.teams ?? game.teams;
      if (gameTeams == null) continue;
      final winner = individualGame.winner;

      for (final id in gameTeams.teamAPlayerIds) {
        final prev = counts[id] ?? (wins: 0, losses: 0);
        counts[id] = winner == 'teamA'
            ? (wins: prev.wins + 1, losses: prev.losses)
            : (wins: prev.wins, losses: prev.losses + 1);
      }
      for (final id in gameTeams.teamBPlayerIds) {
        final prev = counts[id] ?? (wins: 0, losses: 0);
        counts[id] = winner == 'teamB'
            ? (wins: prev.wins + 1, losses: prev.losses)
            : (wins: prev.wins, losses: prev.losses + 1);
      }
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (game.result == null) {
      return Scaffold(
        appBar: PlayWithMeAppBar.build(
          context: context,
          title: l10n.gameResults,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.sports_score, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  l10n.noResultsAvailable,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.scoresWillAppear,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final result = game.result!;
    final winLoss = _computeWinLoss(result);
    final allPlayerIds = [
      ...?game.teams?.teamAPlayerIds,
      ...?game.teams?.teamBPlayerIds,
    ];

    return Scaffold(
      appBar: PlayWithMeAppBar.build(
        context: context,
        title: l10n.gameResults,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ELO Rating Changes card (replaces the old "Final Score" card)
            if (playerEloUpdates.isNotEmpty)
              _EloUpdatesCard(
                playerIds: allPlayerIds,
                players: players,
                playerEloUpdates: playerEloUpdates,
                winLoss: winLoss,
              ),
            if (playerEloUpdates.isNotEmpty) const SizedBox(height: 20),
            // Individual Games section
            Text(
              l10n.individualGames,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
            ),
            const SizedBox(height: 16),
            ...result.games.asMap().entries.map((entry) {
              final index = entry.key;
              final individualGame = entry.value;
              // Per-game teams with session-level fallback
              final gameTeams = individualGame.teams ?? game.teams;
              return _IndividualGameCard(
                gameNumber: index + 1,
                game: individualGame,
                gameTeams: gameTeams,
                players: players,
                isLast: index == result.games.length - 1,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _EloUpdatesCard extends StatelessWidget {
  final List<String> playerIds;
  final Map<String, UserModel>? players;
  final Map<String, RatingHistoryEntry?> playerEloUpdates;
  final Map<String, ({int wins, int losses})> winLoss;

  const _EloUpdatesCard({
    required this.playerIds,
    required this.winLoss,
    this.players,
    this.playerEloUpdates = const {},
  });

  String _getPlayerName(BuildContext context, String playerId) {
    final l10n = AppLocalizations.of(context)!;
    return players?[playerId]?.displayName ??
        players?[playerId]?.email ??
        l10n.unknownPlayer;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final playersWithElo = playerIds.where((id) => playerEloUpdates[id] != null).toList();

    if (playersWithElo.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.eloRatingChanges,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...playersWithElo.map((playerId) {
              final eloEntry = playerEloUpdates[playerId];
              if (eloEntry == null) return const SizedBox.shrink();

              final playerName = _getPlayerName(context, playerId);
              final oldRating = eloEntry.oldRating.toInt();
              final newRating = eloEntry.newRating.toInt();
              final isGain = eloEntry.isGain;
              final isLoss = eloEntry.isLoss;
              final record = winLoss[playerId];

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Player name
                        Expanded(
                          flex: 3,
                          child: Text(
                            playerName,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Previous ELO
                        Expanded(
                          flex: 2,
                          child: Text(
                            '$oldRating',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        // Arrow
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(
                            Icons.arrow_forward,
                            size: 16,
                            color: isGain
                                ? Colors.green
                                : (isLoss ? Colors.red : Colors.grey),
                          ),
                        ),
                        // New ELO
                        Expanded(
                          flex: 2,
                          child: Text(
                            '$newRating',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isGain
                                      ? Colors.green
                                      : (isLoss ? Colors.red : Colors.grey),
                                ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Change delta
                        SizedBox(
                          width: 60,
                          child: Text(
                            eloEntry.formattedChange,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isGain
                                  ? Colors.green
                                  : (isLoss ? Colors.red : Colors.grey),
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    // Win/loss record below the ELO row
                    if (record != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(
                          l10n.winsLosses(record.wins, record.losses),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _IndividualGameCard extends StatelessWidget {
  final int gameNumber;
  final IndividualGame game;
  final GameTeams? gameTeams;
  final Map<String, UserModel>? players;
  final bool isLast;

  const _IndividualGameCard({
    required this.gameNumber,
    required this.game,
    required this.isLast,
    this.gameTeams,
    this.players,
  });

  String _playerName(String playerId) {
    final user = players?[playerId];
    if (user == null) return playerId;
    return user.displayName ?? user.email.split('@').first;
  }

  String _teamLabel(List<String> ids, String fallback) {
    if (ids.isEmpty) return fallback;
    final names = ids.take(2).map(_playerName).toList();
    if (names.length == 1) return names[0];
    return '${names[0]} & ${names[1]}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final setsWon = game.setsWon;

    return Card(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Game header: number badge + title
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '$gameNumber',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.gameNumber(gameNumber),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                ),
              ],
            ),
            // Per-game team names (Story 14.13)
            if (gameTeams != null) ...[
              const SizedBox(height: 10),
              _TeamMatchupRow(
                teamALabel: _teamLabel(gameTeams!.teamAPlayerIds, l10n.teamA),
                teamBLabel: _teamLabel(gameTeams!.teamBPlayerIds, l10n.teamB),
                winner: game.winner,
              ),
            ],
            const SizedBox(height: 12),
            // Sets won summary
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.setsScore(setsWon['teamA'] ?? 0, setsWon['teamB'] ?? 0),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.secondary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            // Individual sets
            ...game.sets.map((set) {
              final setWinner = set.winner;
              final teamAWon = setWinner == 'teamA';
              final teamBWon = setWinner == 'teamB';

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 50,
                      child: Text(
                        l10n.setNumber(set.setNumber),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppColors.secondary,
                            ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: teamAWon
                                  ? AppColors.secondary
                                  : AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: teamAWon
                                    ? AppColors.secondary
                                    : AppColors.primary,
                                width: teamAWon ? 2 : 1,
                              ),
                            ),
                            child: Text(
                              set.teamAPoints.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: teamAWon
                                    ? Colors.white
                                    : AppColors.secondary,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              '-',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: teamBWon
                                  ? AppColors.secondary
                                  : AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: teamBWon
                                    ? AppColors.secondary
                                    : AppColors.primary,
                                width: teamBWon ? 2 : 1,
                              ),
                            ),
                            child: Text(
                              set.teamBPoints.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: teamBWon
                                    ? Colors.white
                                    : AppColors.secondary,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// Compact "Alice & Bob  vs  Charlie & Dave" row with winner highlighted.
class _TeamMatchupRow extends StatelessWidget {
  final String teamALabel;
  final String teamBLabel;
  final String? winner;

  const _TeamMatchupRow({
    required this.teamALabel,
    required this.teamBLabel,
    this.winner,
  });

  @override
  Widget build(BuildContext context) {
    final teamAWon = winner == 'teamA';
    final teamBWon = winner == 'teamB';

    return Row(
      children: [
        Expanded(
          child: Text(
            teamALabel,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight:
                      teamAWon ? FontWeight.bold : FontWeight.normal,
                  color: teamAWon ? AppColors.secondary : Colors.grey[600],
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            'vs',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ),
        Expanded(
          child: Text(
            teamBLabel,
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight:
                      teamBWon ? FontWeight.bold : FontWeight.normal,
                  color: teamBWon ? AppColors.secondary : Colors.grey[600],
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
