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

  /// Generate team name from player IDs (e.g., "Alice & Bob" or "Team A")
  String _getTeamName(List<String> playerIds, String fallbackName) {
    if (players == null || players!.isEmpty || playerIds.isEmpty) {
      return fallbackName;
    }

    // Get up to 2 player names
    final names = playerIds
        .take(2)
        .map((id) {
          final player = players![id];
          if (player == null) return null;
          return player.displayName ?? player.email.split('@').first;
        })
        .where((name) => name != null)
        .toList();

    if (names.isEmpty) return fallbackName;
    if (names.length == 1) return names[0]!;
    return '${names[0]} & ${names[1]}';
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
    final teams = game.teams;

    // Generate team names
    final teamAName = teams != null
        ? _getTeamName(teams.teamAPlayerIds, l10n.teamA)
        : l10n.teamA;
    final teamBName = teams != null
        ? _getTeamName(teams.teamBPlayerIds, l10n.teamB)
        : l10n.teamB;

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
            // Overall Result Card
            _OverallResultCard(
              result: result,
              teams: teams,
              teamAName: teamAName,
              teamBName: teamBName,
            ),
            const SizedBox(height: 16),
            // ELO Updates Card (if ELO is calculated)
            if (playerEloUpdates.isNotEmpty)
              _EloUpdatesCard(
                playerIds: [...teams?.teamAPlayerIds ?? [], ...teams?.teamBPlayerIds ?? []],
                players: players,
                playerEloUpdates: playerEloUpdates,
              ),
            if (playerEloUpdates.isNotEmpty) const SizedBox(height: 20),
            // Individual Games List
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
              final game = entry.value;
              return _IndividualGameCard(
                gameNumber: index + 1,
                game: game,
                isLast: index == result.games.length - 1,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _OverallResultCard extends StatelessWidget {
  final GameResult result;
  final GameTeams? teams;
  final String teamAName;
  final String teamBName;

  const _OverallResultCard({
    required this.result,
    required this.teams,
    required this.teamAName,
    required this.teamBName,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final gamesWon = result.gamesWon;

    return Card(
      elevation: 3,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.15),
              AppColors.primary.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.emoji_events, color: AppColors.primary, size: 28),
                  const SizedBox(width: 10),
                  Text(
                    l10n.finalScore,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: _TeamScore(
                      teamName: teamAName,
                      score: gamesWon['teamA'] ?? 0,
                      isWinner: result.overallWinner == 'teamA',
                      isTied: result.overallWinner == null,
                      isTeamA: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _TeamScore(
                      teamName: teamBName,
                      score: gamesWon['teamB'] ?? 0,
                      isWinner: result.overallWinner == 'teamB',
                      isTied: result.overallWinner == null,
                      isTeamA: false,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeamScore extends StatelessWidget {
  final String teamName;
  final int score;
  final bool isWinner;
  final bool isTied;
  final bool isTeamA;

  const _TeamScore({
    required this.teamName,
    required this.score,
    required this.isWinner,
    this.isTied = false,
    this.isTeamA = true,
  });

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor;
    final Color textColor;
    final Color borderColor;

    if (isWinner) {
      backgroundColor = AppColors.secondary;
      textColor = Colors.white;
      borderColor = AppColors.secondary;
    } else if (isTied) {
      // Tie: Team A gets yellow/gold, Team B gets blue — visually distinct
      backgroundColor = isTeamA ? AppColors.primary : AppColors.secondary;
      textColor = isTeamA ? AppColors.secondary : Colors.white;
      borderColor = isTeamA ? AppColors.primary : AppColors.secondary;
    } else {
      backgroundColor = AppColors.primary;
      textColor = AppColors.secondary;
      borderColor = AppColors.primary;
    }

    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: borderColor,
              width: isWinner ? 2.5 : 1.5,
            ),
          ),
          child: Center(
            child: Text(
              score.toString(),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          teamName,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: isWinner ? FontWeight.bold : FontWeight.w500,
                color: AppColors.secondary,
                height: 1.2,
              ),
        ),
      ],
    );
  }
}

class _EloUpdatesCard extends StatelessWidget {
  final List<String> playerIds;
  final Map<String, UserModel>? players;
  final Map<String, RatingHistoryEntry?> playerEloUpdates;

  const _EloUpdatesCard({
    required this.playerIds,
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
    // Filter to only players with ELO updates
    final playersWithElo = playerIds.where((id) => playerEloUpdates[id] != null).toList();

    if (playersWithElo.isEmpty) {
      return const SizedBox.shrink();
    }

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

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
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
                        isGain ? Icons.arrow_forward : Icons.arrow_forward,
                        size: 16,
                        color: isGain ? Colors.green : (isLoss ? Colors.red : Colors.grey),
                      ),
                    ),
                    // New ELO
                    Expanded(
                      flex: 2,
                      child: Text(
                        '$newRating',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isGain ? Colors.green : (isLoss ? Colors.red : Colors.grey),
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
                          color: isGain ? Colors.green : (isLoss ? Colors.red : Colors.grey),
                        ),
                        textAlign: TextAlign.right,
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
  final bool isLast;

  const _IndividualGameCard({
    required this.gameNumber,
    required this.game,
    required this.isLast,
  });

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
                                color: teamAWon ? AppColors.secondary : AppColors.primary,
                                width: teamAWon ? 2 : 1,
                              ),
                            ),
                            child: Text(
                              set.teamAPoints.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: teamAWon ? Colors.white : AppColors.secondary,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
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
                                color: teamBWon ? AppColors.secondary : AppColors.primary,
                                width: teamBWon ? 2 : 1,
                              ),
                            ),
                            child: Text(
                              set.teamBPoints.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: teamBWon ? Colors.white : AppColors.secondary,
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
