// Widget tests for GameHistoryCard (Story 14.7)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/game_model.dart';
import 'package:play_with_me/features/games/presentation/widgets/game_history_card.dart';

void main() {
  group('GameHistoryCard', () {
    final testGame = GameModel(
      id: 'test-game',
      title: 'Test Game',
      groupId: 'test-group',
      createdBy: 'user1',
      createdAt: DateTime(2024, 1, 1),
      scheduledAt: DateTime(2024, 1, 5, 14, 0),
      location: const GameLocation(
        latitude: 40.7128,
        longitude: -74.0060,
        name: 'Central Park',
      ),
      status: GameStatus.completed,
      completedAt: DateTime(2024, 1, 5, 16, 30),
      playerIds: ['user1', 'user2'],
      teams: const GameTeams(
        teamAPlayerIds: ['user1'],
        teamBPlayerIds: ['user2'],
      ),
      result: const GameResult(
        games: [],
        overallWinner: 'teamA',
      ),
      eloCalculated: true,
    );

    testWidgets('displays game date and location', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameHistoryCard(
              game: testGame,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Jan 5, 2024'), findsOneWidget);
      expect(find.text('Central Park'), findsOneWidget);
    });

    testWidgets('displays team scores when available', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameHistoryCard(
              game: testGame,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Team A'), findsOneWidget);
      expect(find.text('Team B'), findsOneWidget);
      expect(find.text('0'), findsWidgets); // No game scores in test data
    });

    testWidgets('shows winner indicator for winning team', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameHistoryCard(
              game: testGame,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.emoji_events), findsOneWidget);
    });

    testWidgets('shows ELO updated indicator when calculated', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameHistoryCard(
              game: testGame,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('ELO Updated'), findsOneWidget);
      expect(find.byIcon(Icons.trending_up), findsOneWidget);
    });

    testWidgets('shows message when no scores recorded', (tester) async {
      final gameWithoutScores = testGame.copyWith(
        teams: null,
        result: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameHistoryCard(
              game: gameWithoutScores,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('No scores recorded'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameHistoryCard(
              game: testGame,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GameHistoryCard));
      await tester.pumpAndSettle();

      expect(tapped, true);
    });
  });
}
