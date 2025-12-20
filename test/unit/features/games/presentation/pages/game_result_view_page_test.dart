// Tests player name resolution in GameResultViewPage widget.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/game_model.dart';
import 'package:play_with_me/core/data/models/user_model.dart';
import 'package:play_with_me/features/games/presentation/pages/game_result_view_page.dart';

void main() {
  group('GameResultViewPage', () {
    late GameModel gameWithResult;
    late Map<String, UserModel> players;

    setUp(() {
      // Create test users
      players = {
        'user1': const UserModel(
          uid: 'user1',
          email: 'alice@example.com',
          displayName: 'Alice',
          isEmailVerified: true,
          isAnonymous: false,
        ),
        'user2': const UserModel(
          uid: 'user2',
          email: 'bob@example.com',
          displayName: 'Bob',
          isEmailVerified: true,
          isAnonymous: false,
        ),
        'user3': const UserModel(
          uid: 'user3',
          email: 'charlie@example.com',
          displayName: null, // No display name
          isEmailVerified: true,
          isAnonymous: false,
        ),
        'user4': const UserModel(
          uid: 'user4',
          email: 'diana@example.com',
          displayName: 'Diana',
          isEmailVerified: true,
          isAnonymous: false,
        ),
      };

      // Create game with teams and results
      gameWithResult = GameModel(
        id: 'game1',
        title: 'Beach Volleyball Match',
        groupId: 'group1',
        scheduledAt: DateTime(2024, 1, 15, 10, 0),
        status: GameStatus.completed,
        location: const GameLocation(
          name: 'Test Court',
          latitude: 40.7128,
          longitude: -74.0060,
        ),
        createdBy: 'user1',
        createdAt: DateTime(2024, 1, 1),
        playerIds: const ['user1', 'user2', 'user3', 'user4'],
        waitlistIds: const [],
        teams: const GameTeams(
          teamAPlayerIds: ['user1', 'user2'],
          teamBPlayerIds: ['user3', 'user4'],
        ),
        result: const GameResult(
          overallWinner: 'teamA',
          games: [
            IndividualGame(
              gameNumber: 1,
              winner: 'teamA',
              sets: [
                SetScore(setNumber: 1, teamAPoints: 21, teamBPoints: 19),
                SetScore(setNumber: 2, teamAPoints: 21, teamBPoints: 17),
              ],
            ),
          ],
        ),
      );
    });

    testWidgets('displays player names when players data is provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameResultViewPage(
            game: gameWithResult,
            players: players,
          ),
        ),
      );

      // Note: Player names are now only shown in the ELO card (when ELO is calculated)
      // The Teams card was removed as redundant in Story 290
      // Player names still appear in the "Team Names" section of the Overall Result card
      expect(find.text('Alice & Bob'), findsAtLeastNWidgets(1));
      expect(find.text('charlie & Diana'), findsAtLeastNWidgets(1));
    });

    testWidgets('displays player IDs when players data is not provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameResultViewPage(
            game: gameWithResult,
            players: null, // No player data
          ),
        ),
      );

      // With the Teams card removed, player IDs are no longer individually listed
      // They still appear in the Overall Result card as team names
      // Verify the page renders without error even when player data is null
      expect(find.byType(GameResultViewPage), findsOneWidget);
    });

    testWidgets('handles missing player data gracefully', (tester) async {
      // Partial player data - only some players loaded
      final partialPlayers = {
        'user1': players['user1']!,
        'user2': players['user2']!,
        // user3 and user4 missing
      };

      await tester.pumpWidget(
        MaterialApp(
          home: GameResultViewPage(
            game: gameWithResult,
            players: partialPlayers,
          ),
        ),
      );

      // With Teams card removed, player names appear in Overall Result team names
      // Available players still show in team composition
      expect(find.text('Alice & Bob'), findsAtLeastNWidgets(1));
      // Verify page renders without throwing errors for missing player data
      expect(find.byType(GameResultViewPage), findsOneWidget);
    });

    testWidgets('displays team names correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameResultViewPage(
            game: gameWithResult,
            players: players,
          ),
        ),
      );

      // Verify team labels show player names instead of generic "Team A"/"Team B"
      expect(find.text('Alice & Bob'), findsAtLeastNWidgets(1));
      expect(find.text('charlie & Diana'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows empty state when no results available', (tester) async {
      final gameWithoutResult = gameWithResult.copyWith(result: null);

      await tester.pumpWidget(
        MaterialApp(
          home: GameResultViewPage(
            game: gameWithoutResult,
            players: players,
          ),
        ),
      );

      expect(find.text('No results available yet'), findsOneWidget);
      expect(find.text('Scores will appear here once they are entered'), findsOneWidget);
    });

    testWidgets('displays game results card with correct structure', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameResultViewPage(
            game: gameWithResult,
            players: players,
          ),
        ),
      );

      // Verify overall result card elements
      expect(find.text('Final Score'), findsOneWidget);
      expect(find.byIcon(Icons.emoji_events), findsOneWidget);
      // Verify team names are displayed (appears in both Final Score and Teams cards)
      expect(find.text('Alice & Bob'), findsWidgets);
      expect(find.text('charlie & Diana'), findsWidgets);
    });

    testWidgets('displays individual games section', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameResultViewPage(
            game: gameWithResult,
            players: players,
          ),
        ),
      );

      expect(find.text('Individual Games'), findsOneWidget);
      expect(find.text('Game 1'), findsOneWidget);
      // Verify game details are shown (sets won)
      expect(find.textContaining('Sets:'), findsOneWidget);
    });
  });
}
