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
  });
}
