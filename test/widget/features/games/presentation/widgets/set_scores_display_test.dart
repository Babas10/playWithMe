import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/game_model.dart';
import 'package:play_with_me/features/games/presentation/widgets/set_scores_display.dart';

void main() {
  group('SetScoresDisplay', () {
    testWidgets('displays single set score correctly', (tester) async {
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
            body: SetScoresDisplay(result: validResult),
          ),
        ),
      );

      expect(find.text('21-19'), findsOneWidget);
    });

    testWidgets('displays multiple set scores correctly', (tester) async {
      final validResult = const GameResult(
        games: [
          IndividualGame(
            gameNumber: 1,
            winner: 'teamA',
            sets: [
              SetScore(teamAPoints: 21, teamBPoints: 19, setNumber: 1),
              SetScore(teamAPoints: 15, teamBPoints: 21, setNumber: 2),
              SetScore(teamAPoints: 15, teamBPoints: 10, setNumber: 3),
            ],
          )
        ],
        overallWinner: 'teamA',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SetScoresDisplay(result: validResult),
          ),
        ),
      );

      expect(find.text('21-19, 15-21, 15-10'), findsOneWidget);
    });

    testWidgets('displays multiple games scores correctly', (tester) async {
      final validResult = const GameResult(
        games: [
          IndividualGame(
            gameNumber: 1,
            winner: 'teamA',
            sets: [SetScore(teamAPoints: 21, teamBPoints: 15, setNumber: 1)],
          ),
          IndividualGame(
            gameNumber: 2,
            winner: 'teamB',
            sets: [SetScore(teamAPoints: 10, teamBPoints: 21, setNumber: 1)],
          ),
        ],
        overallWinner: 'tie', // Example tie scenario
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SetScoresDisplay(result: validResult),
          ),
        ),
      );

      expect(find.text('21-15'), findsOneWidget);
      expect(find.text('10-21'), findsOneWidget);
    });

    testWidgets('renders nothing when there are no games', (tester) async {
      final emptyResult = const GameResult(
        games: [],
        overallWinner: 'teamA',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SetScoresDisplay(result: emptyResult),
          ),
        ),
      );

      expect(find.byType(Container), findsNothing);
    });
  });
}
