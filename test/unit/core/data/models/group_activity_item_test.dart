// Tests GroupActivityItem union type for game and training session activities.

import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/game_model.dart';
import 'package:play_with_me/core/data/models/group_activity_item.dart';
import 'package:play_with_me/core/data/models/training_session_model.dart';

void main() {
  group('GroupActivityItem', () {
    late DateTime now;
    late DateTime futureDate;
    late DateTime pastDate;
    late GameModel testGame;
    late TrainingSessionModel testTraining;

    const testLocation = GameLocation(name: 'Beach Court', address: '123 Beach Rd');

    setUp(() {
      now = DateTime.now();
      futureDate = now.add(const Duration(days: 1));
      pastDate = now.subtract(const Duration(days: 1));

      testGame = GameModel(
        id: 'game-123',
        title: 'Beach Volleyball Game',
        groupId: 'group-456',
        createdBy: 'user-123',
        createdAt: now.subtract(const Duration(days: 7)),
        scheduledAt: futureDate,
        location: testLocation,
        status: GameStatus.scheduled,
        maxPlayers: 4,
        minPlayers: 2,
      );

      testTraining = TrainingSessionModel(
        id: 'training-789',
        groupId: 'group-456',
        title: 'Morning Practice',
        location: testLocation,
        startTime: futureDate,
        endTime: futureDate.add(const Duration(hours: 2)),
        minParticipants: 4,
        maxParticipants: 8,
        createdBy: 'user-123',
        createdAt: now.subtract(const Duration(days: 3)),
      );
    });

    group('GameActivityItem', () {
      test('creates game activity item', () {
        final item = GroupActivityItem.game(testGame);

        expect(item, isA<GameActivityItem>());
      });

      test('id returns game id', () {
        final item = GroupActivityItem.game(testGame);

        expect(item.id, equals('game-123'));
      });

      test('startTime returns game scheduledAt', () {
        final item = GroupActivityItem.game(testGame);

        expect(item.startTime, equals(futureDate));
      });

      test('title returns game title', () {
        final item = GroupActivityItem.game(testGame);

        expect(item.title, equals('Beach Volleyball Game'));
      });

      test('groupId returns game groupId', () {
        final item = GroupActivityItem.game(testGame);

        expect(item.groupId, equals('group-456'));
      });
    });

    group('TrainingActivityItem', () {
      test('creates training activity item', () {
        final item = GroupActivityItem.training(testTraining);

        expect(item, isA<TrainingActivityItem>());
      });

      test('id returns training session id', () {
        final item = GroupActivityItem.training(testTraining);

        expect(item.id, equals('training-789'));
      });

      test('startTime returns training startTime', () {
        final item = GroupActivityItem.training(testTraining);

        expect(item.startTime, equals(futureDate));
      });

      test('title returns training title', () {
        final item = GroupActivityItem.training(testTraining);

        expect(item.title, equals('Morning Practice'));
      });

      test('groupId returns training groupId', () {
        final item = GroupActivityItem.training(testTraining);

        expect(item.groupId, equals('group-456'));
      });
    });

    group('isPast', () {
      test('returns false for future game', () {
        final item = GroupActivityItem.game(testGame);

        expect(item.isPast, isFalse);
      });

      test('returns true for past game', () {
        final pastGame = testGame.copyWith(scheduledAt: pastDate);
        final item = GroupActivityItem.game(pastGame);

        expect(item.isPast, isTrue);
      });

      test('returns false for future training', () {
        final item = GroupActivityItem.training(testTraining);

        expect(item.isPast, isFalse);
      });

      test('returns true for past training', () {
        final pastTraining = testTraining.copyWith(
          startTime: pastDate,
          endTime: pastDate.add(const Duration(hours: 2)),
        );
        final item = GroupActivityItem.training(pastTraining);

        expect(item.isPast, isTrue);
      });
    });

    group('isUpcoming', () {
      test('returns true for future game', () {
        final item = GroupActivityItem.game(testGame);

        expect(item.isUpcoming, isTrue);
      });

      test('returns false for past game', () {
        final pastGame = testGame.copyWith(scheduledAt: pastDate);
        final item = GroupActivityItem.game(pastGame);

        expect(item.isUpcoming, isFalse);
      });

      test('returns true for future training', () {
        final item = GroupActivityItem.training(testTraining);

        expect(item.isUpcoming, isTrue);
      });

      test('returns false for past training', () {
        final pastTraining = testTraining.copyWith(
          startTime: pastDate,
          endTime: pastDate.add(const Duration(hours: 2)),
        );
        final item = GroupActivityItem.training(pastTraining);

        expect(item.isUpcoming, isFalse);
      });
    });

    group('when', () {
      test('executes game callback for game activity', () {
        final item = GroupActivityItem.game(testGame);

        final result = item.when(
          game: (game) => 'game: ${game.id}',
          training: (session) => 'training: ${session.id}',
        );

        expect(result, equals('game: game-123'));
      });

      test('executes training callback for training activity', () {
        final item = GroupActivityItem.training(testTraining);

        final result = item.when(
          game: (game) => 'game: ${game.id}',
          training: (session) => 'training: ${session.id}',
        );

        expect(result, equals('training: training-789'));
      });
    });

    group('maybeWhen', () {
      test('executes game callback for game activity', () {
        final item = GroupActivityItem.game(testGame);

        final result = item.maybeWhen(
          game: (game) => 'game found',
          orElse: () => 'not found',
        );

        expect(result, equals('game found'));
      });

      test('executes orElse for game when training callback provided', () {
        final item = GroupActivityItem.game(testGame);

        final result = item.maybeWhen(
          training: (session) => 'training found',
          orElse: () => 'not found',
        );

        expect(result, equals('not found'));
      });

      test('executes training callback for training activity', () {
        final item = GroupActivityItem.training(testTraining);

        final result = item.maybeWhen(
          training: (session) => 'training found',
          orElse: () => 'not found',
        );

        expect(result, equals('training found'));
      });
    });

    group('map', () {
      test('maps game activity', () {
        final item = GroupActivityItem.game(testGame);

        final result = item.map(
          game: (gameItem) => 'GameItem: ${gameItem.game.id}',
          training: (trainingItem) => 'TrainingItem: ${trainingItem.session.id}',
        );

        expect(result, equals('GameItem: game-123'));
      });

      test('maps training activity', () {
        final item = GroupActivityItem.training(testTraining);

        final result = item.map(
          game: (gameItem) => 'GameItem: ${gameItem.game.id}',
          training: (trainingItem) => 'TrainingItem: ${trainingItem.session.id}',
        );

        expect(result, equals('TrainingItem: training-789'));
      });
    });

    group('sorting', () {
      test('activities can be sorted by startTime', () {
        final earlyDate = now.add(const Duration(hours: 1));
        final lateDate = now.add(const Duration(days: 2));

        final earlyGame = testGame.copyWith(scheduledAt: earlyDate);
        final lateTraining = testTraining.copyWith(
          startTime: lateDate,
          endTime: lateDate.add(const Duration(hours: 2)),
        );

        final items = [
          GroupActivityItem.training(lateTraining),
          GroupActivityItem.game(earlyGame),
        ];

        items.sort((a, b) => a.startTime.compareTo(b.startTime));

        expect(items[0].id, equals('game-123'));
        expect(items[1].id, equals('training-789'));
      });
    });

    group('equality', () {
      test('two game activities with same game are equal', () {
        final item1 = GroupActivityItem.game(testGame);
        final item2 = GroupActivityItem.game(testGame);

        expect(item1, equals(item2));
      });

      test('two training activities with same session are equal', () {
        final item1 = GroupActivityItem.training(testTraining);
        final item2 = GroupActivityItem.training(testTraining);

        expect(item1, equals(item2));
      });

      test('game activity not equal to training activity', () {
        final gameItem = GroupActivityItem.game(testGame);
        final trainingItem = GroupActivityItem.training(testTraining);

        expect(gameItem, isNot(equals(trainingItem)));
      });
    });
  });
}
