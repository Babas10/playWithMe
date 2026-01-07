// Validates that the layered architecture dependency rules are enforced.
// Games module should not depend on friendships directly.

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Architecture Dependency Rules', () {
    test('Games module should not import FriendRepository', () {
      final gamesDir = Directory('lib/features/games');

      if (!gamesDir.existsSync()) {
        fail('Games directory does not exist at ${gamesDir.path}');
      }

      final violations = <String>[];

      // Recursively check all Dart files in games directory
      gamesDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))
          .forEach((file) {
        final content = file.readAsStringSync();

        // Check for friendship-related imports
        if (content.contains('FriendRepository') ||
            content.contains('friend_repository') ||
            content.contains('features/friends/')) {
          violations.add(file.path);
        }
      });

      expect(
        violations,
        isEmpty,
        reason: 'Games module should not import friendship-related code.\n'
            'Violations found in:\n${violations.join('\n')}\n\n'
            'Rule: Games → Groups → My Community (one-way dependency)',
      );
    });

    test('Game repositories should not import FriendRepository', () {
      final gameRepoFiles = [
        'lib/core/data/repositories/firestore_game_repository.dart',
        'lib/core/domain/repositories/game_repository.dart',
      ];

      final violations = <String>[];

      for (final filePath in gameRepoFiles) {
        final file = File(filePath);
        if (!file.existsSync()) continue;

        final content = file.readAsStringSync();

        if (content.contains('FriendRepository') ||
            content.contains('friend_repository') ||
            content.contains('features/friends/')) {
          violations.add(filePath);
        }
      }

      expect(
        violations,
        isEmpty,
        reason: 'Game repositories should not depend on friendship layer.\n'
            'Violations found in:\n${violations.join('\n')}\n\n'
            'Rule: Games access players via Groups only',
      );
    });

    test('Game BLoCs should not import FriendRepository', () {
      final gameBlocDir = Directory('lib/core/presentation/bloc/game');

      if (!gameBlocDir.existsSync()) {
        // If directory doesn't exist yet, test passes
        return;
      }

      final violations = <String>[];

      gameBlocDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))
          .forEach((file) {
        final content = file.readAsStringSync();

        if (content.contains('FriendRepository') ||
            content.contains('friend_repository') ||
            content.contains('features/friends/')) {
          violations.add(file.path);
        }
      });

      expect(
        violations,
        isEmpty,
        reason: 'Game BLoCs should not depend on friendship layer.\n'
            'Violations found in:\n${violations.join('\n')}\n\n'
            'Rule: Games → Groups → My Community',
      );
    });

    test('Architecture documentation exists', () {
      final architectureDocs = [
        'docs/architecture/LAYERED_DEPENDENCIES.md',
        'docs/architecture/DEPENDENCY_DIAGRAM.md',
      ];

      for (final docPath in architectureDocs) {
        final file = File(docPath);
        expect(
          file.existsSync(),
          isTrue,
          reason: 'Required architecture documentation missing: $docPath',
        );
      }
    });

    test('Training module should not import FriendRepository (Story 15.1)', () {
      final trainingDir = Directory('lib/features/training');

      if (!trainingDir.existsSync()) {
        // If directory doesn't exist yet, test passes
        return;
      }

      final violations = <String>[];

      // Recursively check all Dart files in training directory
      trainingDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))
          .forEach((file) {
        final content = file.readAsStringSync();

        // Check for friendship-related imports
        if (content.contains('FriendRepository') ||
            content.contains('friend_repository') ||
            content.contains('features/friends/')) {
          violations.add(file.path);
        }
      });

      expect(
        violations,
        isEmpty,
        reason: 'Training module should not import friendship-related code.\n'
            'Violations found in:\n${violations.join('\n')}\n\n'
            'ARCHITECTURE RULE: Training Sessions → Groups → My Community\n'
            'Training sessions are in the Games layer and participants are resolved via group.memberIds only.\n'
            'See Epic 15 specification and CLAUDE.md for details.',
      );
    });

    test('Training repositories should not import FriendRepository (Story 15.1)', () {
      final trainingRepoFiles = [
        'lib/core/data/repositories/firestore_training_session_repository.dart',
        'lib/core/domain/repositories/training_session_repository.dart',
      ];

      final violations = <String>[];

      for (final filePath in trainingRepoFiles) {
        final file = File(filePath);
        if (!file.existsSync()) continue;

        final content = file.readAsStringSync();

        // Check for actual imports, not comments
        // Look for import statements specifically
        if (RegExp(r"import\s+.*friend", caseSensitive: false).hasMatch(content) ||
            RegExp(r"import\s+.*features/friends").hasMatch(content)) {
          violations.add(filePath);
        }
      }

      expect(
        violations,
        isEmpty,
        reason: 'Training repositories should not depend on friendship layer.\n'
            'Violations found in:\n${violations.join('\n')}\n\n'
            'ARCHITECTURE RULE: Training Sessions access participants via Groups only\n'
            'Participants must be validated using GroupRepository.getGroupMembers()',
      );
    });

    test('Training BLoCs should not import FriendRepository (Story 15.1)', () {
      final trainingBlocDir = Directory('lib/features/training/presentation/bloc');

      if (!trainingBlocDir.existsSync()) {
        // If directory doesn't exist yet, test passes
        return;
      }

      final violations = <String>[];

      trainingBlocDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))
          .forEach((file) {
        final content = file.readAsStringSync();

        if (content.contains('FriendRepository') ||
            content.contains('friend_repository') ||
            content.contains('features/friends/')) {
          violations.add(file.path);
        }
      });

      expect(
        violations,
        isEmpty,
        reason: 'Training BLoCs should not depend on friendship layer.\n'
            'Violations found in:\n${violations.join('\n')}\n\n'
            'ARCHITECTURE RULE: Training Sessions → Groups → My Community',
      );
    });
  });
}
