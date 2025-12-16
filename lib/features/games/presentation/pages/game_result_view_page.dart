import 'package:flutter/material.dart';

import '../../../../core/data/models/game_model.dart';
import '../../../../core/data/models/user_model.dart';

class GameResultViewPage extends StatelessWidget {
  final GameModel game;
  final Map<String, UserModel>? players;

  const GameResultViewPage({
    super.key,
    required this.game,
    this.players,
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
    if (game.result == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Game Results'),
          elevation: 0,
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sports_score, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No results available yet',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Scores will appear here once they are entered',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
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
        ? _getTeamName(teams.teamAPlayerIds, 'Team A')
        : 'Team A';
    final teamBName = teams != null
        ? _getTeamName(teams.teamBPlayerIds, 'Team B')
        : 'Team B';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Results'),
        elevation: 0,
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
            // Team Names Card (if teams are assigned)
            if (teams != null)
              _TeamNamesCard(
                teams: teams,
                players: players,
                teamAName: teamAName,
                teamBName: teamBName,
              ),
            if (teams != null) const SizedBox(height: 20),
            // Individual Games List
            Text(
              'Individual Games',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
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
    final gamesWon = result.gamesWon;
    final winnerColor = result.overallWinner == 'teamA' ? Colors.blue : Colors.red;

    return Card(
      elevation: 3,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              winnerColor.withOpacity(0.08),
              winnerColor.withOpacity(0.03),
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
                  Icon(Icons.emoji_events, color: winnerColor, size: 28),
                  const SizedBox(width: 10),
                  Text(
                    'Final Score',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
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
                      winnerColor: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _TeamScore(
                      teamName: teamBName,
                      score: gamesWon['teamB'] ?? 0,
                      isWinner: result.overallWinner == 'teamB',
                      winnerColor: Colors.red,
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
  final Color winnerColor;

  const _TeamScore({
    required this.teamName,
    required this.score,
    required this.isWinner,
    required this.winnerColor,
  });

  @override
  Widget build(BuildContext context) {
    // Use winner color for winner, neutral grey for loser
    final displayColor = isWinner ? winnerColor : Colors.grey.shade600;
    final backgroundColor = isWinner ? winnerColor : Colors.grey.shade300;

    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: displayColor,
              width: isWinner ? 2.5 : 1.5,
            ),
          ),
          child: Center(
            child: Text(
              score.toString(),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isWinner ? Colors.white : displayColor,
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
                color: displayColor,
                height: 1.2,
              ),
        ),
      ],
    );
  }
}

class _TeamNamesCard extends StatelessWidget {
  final GameTeams teams;
  final Map<String, UserModel>? players;
  final String teamAName;
  final String teamBName;

  const _TeamNamesCard({
    required this.teams,
    this.players,
    required this.teamAName,
    required this.teamBName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Teams',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _TeamList(
                    teamName: teamAName,
                    playerIds: teams.teamAPlayerIds,
                    players: players,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _TeamList(
                    teamName: teamBName,
                    playerIds: teams.teamBPlayerIds,
                    players: players,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamList extends StatelessWidget {
  final String teamName;
  final List<String> playerIds;
  final Map<String, UserModel>? players;
  final Color color;

  const _TeamList({
    required this.teamName,
    required this.playerIds,
    this.players,
    required this.color,
  });

  String _getPlayerName(String playerId) {
    if (players == null) {
      // Fallback to showing truncated ID if no player data available
      return playerId.length > 20 ? '${playerId.substring(0, 20)}...' : playerId;
    }

    final player = players![playerId];
    if (player == null) {
      return 'Player';
    }

    return player.displayName ?? player.email.split('@').first;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                teamName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...playerIds.map((playerId) => Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Text(
                '• ${_getPlayerName(playerId)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.4,
                    ),
              ),
            )),
      ],
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
    final setsWon = game.setsWon;
    final winnerColor = game.winner == 'teamA' ? Colors.blue : Colors.red;

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
                    color: winnerColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '$gameNumber',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: winnerColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Game $gameNumber',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
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
                  'Sets: ${setsWon['teamA']} - ${setsWon['teamB']}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
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
                        'Set ${set.setNumber}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
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
                                  ? Colors.blue.withOpacity(0.2)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: teamAWon ? Colors.blue : Colors.grey,
                                width: teamAWon ? 2 : 1,
                              ),
                            ),
                            child: Text(
                              set.teamAPoints.toString(),
                              style: TextStyle(
                                fontWeight:
                                    teamAWon ? FontWeight.bold : FontWeight.normal,
                                color: teamAWon ? Colors.blue : Colors.grey[700],
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              '-',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
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
                                  ? Colors.red.withOpacity(0.2)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: teamBWon ? Colors.red : Colors.grey,
                                width: teamBWon ? 2 : 1,
                              ),
                            ),
                            child: Text(
                              set.teamBPoints.toString(),
                              style: TextStyle(
                                fontWeight:
                                    teamBWon ? FontWeight.bold : FontWeight.normal,
                                color: teamBWon ? Colors.red : Colors.grey[700],
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
