// Widget tests for GameTeamPickerWidget (Story 14.11).
// Validates that all 3 combinations are shown and selection works.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/game_model.dart';
import 'package:play_with_me/features/games/presentation/widgets/game_team_picker_widget.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

Widget _buildWidget({
  required List<String> playerIds,
  GameTeams? selectedTeams,
  ValueChanged<GameTeams>? onTeamsSelected,
}) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en')],
    home: Scaffold(
      body: GameTeamPickerWidget(
        playerIds: playerIds,
        players: const {},
        selectedTeams: selectedTeams,
        onTeamsSelected: onTeamsSelected ?? (_) {},
      ),
    ),
  );
}

void main() {
  group('generateTeamCombinations', () {
    test('generates exactly 3 combinations for 4 players', () {
      final combos = generateTeamCombinations(['p1', 'p2', 'p3', 'p4']);
      expect(combos.length, 3);
    });

    test('each combination has 2 players per team', () {
      final combos = generateTeamCombinations(['p1', 'p2', 'p3', 'p4']);
      for (final combo in combos) {
        expect(combo.teamAPlayerIds.length, 2);
        expect(combo.teamBPlayerIds.length, 2);
      }
    });

    test('all 4 players appear in each combination', () {
      final players = ['p1', 'p2', 'p3', 'p4'];
      final combos = generateTeamCombinations(players);
      for (final combo in combos) {
        final all = {...combo.teamAPlayerIds, ...combo.teamBPlayerIds};
        expect(all, players.toSet());
      }
    });

    test('all combinations are distinct', () {
      final combos = generateTeamCombinations(['p1', 'p2', 'p3', 'p4']);
      final seen = <Set<String>>{};
      for (final combo in combos) {
        final key = combo.teamAPlayerIds.toSet();
        expect(seen.contains(key), isFalse);
        seen.add(key);
      }
    });
  });

  group('GameTeamPickerWidget', () {
    testWidgets('shows 3 combination rows for 4 players', (tester) async {
      await tester.pumpWidget(_buildWidget(
        playerIds: ['p1', 'p2', 'p3', 'p4'],
      ));
      await tester.pumpAndSettle();

      expect(find.byType(InkWell), findsNWidgets(3));
    });

    testWidgets('shows select prompt when no teams selected', (tester) async {
      await tester.pumpWidget(_buildWidget(
        playerIds: ['p1', 'p2', 'p3', 'p4'],
        selectedTeams: null,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Who played this game?'), findsOneWidget);
    });

    testWidgets('shows teams label when teams are selected', (tester) async {
      await tester.pumpWidget(_buildWidget(
        playerIds: ['p1', 'p2', 'p3', 'p4'],
        selectedTeams: const GameTeams(
          teamAPlayerIds: ['p1', 'p2'],
          teamBPlayerIds: ['p3', 'p4'],
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Teams'), findsOneWidget);
    });

    testWidgets('shows check icon after tapping a combination', (tester) async {
      GameTeams? selectedTeams;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return GameTeamPickerWidget(
                  playerIds: const ['p1', 'p2', 'p3', 'p4'],
                  players: const {},
                  selectedTeams: selectedTeams,
                  onTeamsSelected: (teams) {
                    setState(() => selectedTeams = teams);
                  },
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // No check icon before selection
      expect(find.byKey(const Key('team_combo_selected_icon')), findsNothing);

      // Tap the first combination
      await tester.tap(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      // Check icon appears on the selected combination
      expect(find.byKey(const Key('team_combo_selected_icon')), findsOneWidget);
    });

    testWidgets('calls onTeamsSelected when a combination is tapped', (tester) async {
      GameTeams? selected;
      await tester.pumpWidget(_buildWidget(
        playerIds: ['p1', 'p2', 'p3', 'p4'],
        onTeamsSelected: (t) => selected = t,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      expect(selected, isNotNull);
      expect(selected!.teamAPlayerIds.length, 2);
      expect(selected!.teamBPlayerIds.length, 2);
    });

    testWidgets('shows vs label between team names', (tester) async {
      await tester.pumpWidget(_buildWidget(
        playerIds: ['p1', 'p2', 'p3', 'p4'],
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('vs'), findsWidgets);
    });
  });
}
