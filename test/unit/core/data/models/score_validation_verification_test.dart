import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/game_model.dart';
import 'package:play_with_me/features/games/presentation/bloc/score_entry/score_entry_state.dart';

/// This test file explicitly verifies the requirements from Story #293
/// "Verify Score Validation (21-Point Rule)"
void main() {
  group('Story #293 - Score Validation Verification', () {
    
    // Requirement 1: Score can be 21-x (Standard win)
    test('Requirement: Score can be 21-x (where x <= 19)', () {
      // 21-19 (Closest standard win)
      expect(
        const SetScore(teamAPoints: 21, teamBPoints: 19, setNumber: 1).isValid(),
        isTrue,
        reason: '21-19 should be valid'
      );

      // 21-0 (Shutout)
      expect(
        const SetScore(teamAPoints: 21, teamBPoints: 0, setNumber: 1).isValid(),
        isTrue,
        reason: '21-0 should be valid'
      );

       // 21-20 (Invalid - must win by 2)
      expect(
        const SetScore(teamAPoints: 21, teamBPoints: 20, setNumber: 1).isValid(),
        isFalse,
        reason: '21-20 should be INVALID (must win by 2)'
      );
    });

    // Requirement 2: Score can be 23-21 (Extended set)
    test('Requirement: Score can be 23-21', () {
      expect(
        const SetScore(teamAPoints: 23, teamBPoints: 21, setNumber: 1).isValid(),
        isTrue,
        reason: '23-21 should be valid'
      );
    });

    // Requirement 3: Two point of difference after the game goes above 21 points
    test('Requirement: Two point of difference after 21 points', () {
      // 22-20
      expect(
        const SetScore(teamAPoints: 22, teamBPoints: 20, setNumber: 1).isValid(),
        isTrue,
        reason: '22-20 should be valid'
      );

      // 24-22
      expect(
        const SetScore(teamAPoints: 24, teamBPoints: 22, setNumber: 1).isValid(),
        isTrue,
        reason: '24-22 should be valid'
      );

      // 30-28 (Long set)
      expect(
        const SetScore(teamAPoints: 30, teamBPoints: 28, setNumber: 1).isValid(),
        isTrue,
        reason: '30-28 should be valid'
      );

      // 22-21 (Invalid - only 1 point diff)
      expect(
        const SetScore(teamAPoints: 22, teamBPoints: 21, setNumber: 1).isValid(),
        isFalse,
        reason: '22-21 should be INVALID (only 1 point diff)'
      );

      // 25-22 (Invalid - 3 points diff)
      expect(
        const SetScore(teamAPoints: 25, teamBPoints: 22, setNumber: 1).isValid(),
        isFalse,
        reason: '25-22 should be INVALID (game would have ended at 24-22)'
      );
    });

    group('UI Error Message Verification', () {
      test('Returns correct error for scores < 21', () {
        final data = SetScoreData(teamAPoints: 20, teamBPoints: 18);
        expect(data.isValid, isFalse);
        expect(data.validationError, 'Winning team must reach at least 21 points');
      });

      test('Returns correct error for 21-20 (not winning by 2)', () {
        final data = SetScoreData(teamAPoints: 21, teamBPoints: 20);
        expect(data.isValid, isFalse);
        expect(data.validationError, 'Must win by at least 2 points (e.g., 21-19)');
      });

      test('Returns correct error for > 21 and diff != 2', () {
        final data = SetScoreData(teamAPoints: 25, teamBPoints: 22);
        expect(data.isValid, isFalse);
        expect(data.validationError, 'In extra points, must win by exactly 2 points');
      });

      test('Returns null for valid scores', () {
        final data = SetScoreData(teamAPoints: 21, teamBPoints: 19);
        expect(data.isValid, isTrue);
        expect(data.validationError, isNull);
      });
    });
  });
}
