import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/game_model.dart';
import 'package:play_with_me/features/games/presentation/widgets/game_result_badge.dart';

void main() {
  group('GameResultBadge', () {
    testWidgets('displays winner name and score correctly for Team A', (tester) async {
      // We need to construct a result with valid data so scoreDescription returns a valid description.
      final validResult = const GameResult(
        games: [
          IndividualGame(
            gameNumber: 1,
            winner: 'teamA',
            sets: [SetScore(teamAPoints: 21, teamBPoints: 19, setNumber: 1)],
          )
        ],
        overallWinner: 'teamA',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameResultBadge(result: validResult),
          ),
        ),
      );

      expect(find.text('Team A won 1-0'), findsOneWidget);
      expect(find.byIcon(Icons.emoji_events), findsOneWidget);
    });

    testWidgets('displays winner name and score correctly for Team B', (tester) async {
      final validResult = const GameResult(
        games: [
          IndividualGame(
            gameNumber: 1,
            winner: 'teamB',
            sets: [SetScore(teamAPoints: 19, teamBPoints: 21, setNumber: 1)],
          )
        ],
        overallWinner: 'teamB',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameResultBadge(result: validResult),
          ),
        ),
      );

      expect(find.text('Team B won 0-1'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;
      final validResult = const GameResult(
        games: [
          IndividualGame(
            gameNumber: 1,
            winner: 'teamA',
            sets: [SetScore(teamAPoints: 21, teamBPoints: 19, setNumber: 1)],
          )
        ],
        overallWinner: 'teamA',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameResultBadge(
              result: validResult,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GameResultBadge));
      expect(tapped, isTrue);
    });
  });
}
