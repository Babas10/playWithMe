// Validates GameTeams model methods for team assignment validation.

import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/game_model.dart';

void main() {
  group('GameTeams', () {
    test('areAllPlayersAssigned returns true when all players assigned', () {
      final teams = GameTeams(
        teamAPlayerIds: ['player1', 'player2'],
        teamBPlayerIds: ['player3', 'player4'],
      );

      expect(
        teams.areAllPlayersAssigned(['player1', 'player2', 'player3', 'player4']),
        true,
      );
    });

    test('areAllPlayersAssigned returns false when players are missing', () {
      final teams = GameTeams(
        teamAPlayerIds: ['player1', 'player2'],
        teamBPlayerIds: ['player3'],
      );

      expect(
        teams.areAllPlayersAssigned(['player1', 'player2', 'player3', 'player4']),
        false,
      );
    });

    test('hasPlayerOnBothTeams returns true when player is on both teams', () {
      final teams = GameTeams(
        teamAPlayerIds: ['player1', 'player2'],
        teamBPlayerIds: ['player2', 'player3'],
      );

      expect(teams.hasPlayerOnBothTeams(), true);
    });

    test('hasPlayerOnBothTeams returns false when no duplicates', () {
      final teams = GameTeams(
        teamAPlayerIds: ['player1', 'player2'],
        teamBPlayerIds: ['player3', 'player4'],
      );

      expect(teams.hasPlayerOnBothTeams(), false);
    });

    test('getUnassignedPlayers returns list of players not assigned', () {
      final teams = GameTeams(
        teamAPlayerIds: ['player1'],
        teamBPlayerIds: ['player2'],
      );

      final unassigned = teams.getUnassignedPlayers(
        ['player1', 'player2', 'player3', 'player4'],
      );

      expect(unassigned, ['player3', 'player4']);
    });

    test('getUnassignedPlayers returns empty list when all assigned', () {
      final teams = GameTeams(
        teamAPlayerIds: ['player1', 'player2'],
        teamBPlayerIds: ['player3', 'player4'],
      );

      final unassigned = teams.getUnassignedPlayers(
        ['player1', 'player2', 'player3', 'player4'],
      );

      expect(unassigned, isEmpty);
    });

    test('isValid returns true when teams are valid', () {
      final teams = GameTeams(
        teamAPlayerIds: ['player1', 'player2'],
        teamBPlayerIds: ['player3', 'player4'],
      );

      expect(
        teams.isValid(['player1', 'player2', 'player3', 'player4']),
        true,
      );
    });

    test('isValid returns false when player is on both teams', () {
      final teams = GameTeams(
        teamAPlayerIds: ['player1', 'player2'],
        teamBPlayerIds: ['player2', 'player3'],
      );

      expect(
        teams.isValid(['player1', 'player2', 'player3']),
        false,
      );
    });

    test('isValid returns false when not all players assigned', () {
      final teams = GameTeams(
        teamAPlayerIds: ['player1'],
        teamBPlayerIds: ['player2'],
      );

      expect(
        teams.isValid(['player1', 'player2', 'player3', 'player4']),
        false,
      );
    });

    test('fromJson and toJson work correctly', () {
      final teams = GameTeams(
        teamAPlayerIds: ['player1', 'player2'],
        teamBPlayerIds: ['player3', 'player4'],
      );

      final json = teams.toJson();
      final fromJson = GameTeams.fromJson(json);

      expect(fromJson.teamAPlayerIds, teams.teamAPlayerIds);
      expect(fromJson.teamBPlayerIds, teams.teamBPlayerIds);
    });
  });
}
