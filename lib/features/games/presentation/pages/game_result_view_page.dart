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
            if (teams != null) const SizedBox(height: 16),
            // Individual Games List
            Text(
              'Individual Games',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
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
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              winnerColor.withOpacity(0.1),
              winnerColor.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.emoji_events, color: winnerColor, size: 32),
                  const SizedBox(width: 12),
                  Text(
                    'Final Score',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _TeamScore(
                    teamName: teamAName,
                    score: gamesWon['teamA'] ?? 0,
                    isWinner: result.overallWinner == 'teamA',
                    color: Colors.blue,
                  ),
                  Column(
                    children: [
                      Text(
                        'vs',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${result.totalGames} ${result.totalGames == 1 ? 'game' : 'games'}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                    ],
                  ),
                  _TeamScore(
                    teamName: teamBName,
                    score: gamesWon['teamB'] ?? 0,
                    isWinner: result.overallWinner == 'teamB',
                    color: Colors.red,
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
  final Color color;

  const _TeamScore({
    required this.teamName,
    required this.score,
    required this.isWinner,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: isWinner ? color : color.withOpacity(0.3),
            shape: BoxShape.circle,
            border: Border.all(
              color: color,
              width: isWinner ? 3 : 2,
            ),
          ),
          child: Center(
            child: Text(
              score.toString(),
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: isWinner ? Colors.white : color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          teamName,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
                color: isWinner ? color : Colors.grey,
              ),
        ),
        if (isWinner) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'WINNER',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Teams',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
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
            Text(
              teamName,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...playerIds.map((playerId) => Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(
                '• ${_getPlayerName(playerId)}',
                style: Theme.of(context).textTheme.bodySmall,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: winnerColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '$gameNumber',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: winnerColor,
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: winnerColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: winnerColor),
                  ),
                  child: Text(
                    'Winner: ${game.winner == 'teamA' ? 'Team A' : 'Team B'}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: winnerColor,
                      fontSize: 12,
                    ),
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
