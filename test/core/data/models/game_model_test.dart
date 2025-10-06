// Tests all GameModel business logic methods and JSON serialization/deserialization
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/game_model.dart';

void main() {
  group('GameModel', () {
    late GameModel testGame;
    late DateTime testDate;
    late DateTime scheduledDate;

    setUp(() {
      testDate = DateTime(2023, 12, 1, 12, 0, 0);
      scheduledDate = DateTime(2023, 12, 2, 15, 0, 0);

      testGame = GameModel(
        id: 'test-game-id',
        title: 'Beach Volleyball Game',
        description: 'A fun beach volleyball game',
        groupId: 'test-group-id',
        createdBy: 'creator-uid',
        createdAt: testDate,
        updatedAt: testDate,
        scheduledAt: scheduledDate,
        startedAt: null,
        endedAt: null,
        location: const GameLocation(
          name: 'Sunset Beach',
          address: '123 Beach St',
          latitude: 40.7128,
          longitude: -74.0060,
          description: 'Beautiful beach volleyball court',
          parkingInfo: 'Free parking available',
          accessInstructions: 'Enter through main gate',
        ),
        status: GameStatus.scheduled,
        maxPlayers: 4,
        minPlayers: 2,
        playerIds: ['creator-uid', 'player1-uid'],
        waitlistIds: [],
        allowWaitlist: true,
        allowPlayerInvites: true,
        visibility: GameVisibility.group,
        notes: 'Bring sunscreen and water',
        equipment: ['Volleyball', 'Net'],
        estimatedDuration: const Duration(hours: 2),
        courtInfo: 'Court 1',
        gameType: GameType.beachVolleyball,
        skillLevel: GameSkillLevel.intermediate,
        scores: [],
        winnerId: null,
        weatherDependent: true,
        weatherNotes: 'Game cancelled if raining',
      );
    });

    group('Factory constructors', () {
      test('creates GameModel with required fields only', () {
        final minimalGame = GameModel(
          id: 'id',
          title: 'Test Game',
          groupId: 'group-id',
          createdBy: 'creator',
          createdAt: testDate,
          scheduledAt: scheduledDate,
          location: const GameLocation(name: 'Test Location'),
        );

        expect(minimalGame.id, 'id');
        expect(minimalGame.title, 'Test Game');
        expect(minimalGame.groupId, 'group-id');
        expect(minimalGame.createdBy, 'creator');
        expect(minimalGame.description, null);
        expect(minimalGame.updatedAt, null);
        expect(minimalGame.startedAt, null);
        expect(minimalGame.endedAt, null);
        expect(minimalGame.status, GameStatus.scheduled);
        expect(minimalGame.maxPlayers, 4);
        expect(minimalGame.minPlayers, 2);
        expect(minimalGame.playerIds, []);
        expect(minimalGame.waitlistIds, []);
        expect(minimalGame.allowWaitlist, true);
        expect(minimalGame.allowPlayerInvites, true);
        expect(minimalGame.visibility, GameVisibility.group);
        expect(minimalGame.notes, null);
        expect(minimalGame.equipment, []);
        expect(minimalGame.estimatedDuration, null);
        expect(minimalGame.courtInfo, null);
        expect(minimalGame.gameType, null);
        expect(minimalGame.skillLevel, null);
        expect(minimalGame.scores, []);
        expect(minimalGame.winnerId, null);
        expect(minimalGame.weatherDependent, true);
        expect(minimalGame.weatherNotes, null);
      });

      test('fromFirestore creates GameModel from DocumentSnapshot', () {
        final data = {
          'title': 'Test Game',
          'groupId': 'group-id',
          'createdBy': 'creator',
          'createdAt': Timestamp.fromDate(testDate),
          'scheduledAt': Timestamp.fromDate(scheduledDate),
          'location': {
            'name': 'Test Beach',
            'address': '123 Test St',
            'latitude': 40.7128,
            'longitude': -74.0060,
          },
          'maxPlayers': 6,
          'playerIds': ['creator', 'player1'],
        };

        final mockDoc = MockDocumentSnapshot('test-game-id', data);
        final game = GameModel.fromFirestore(mockDoc);

        expect(game.id, 'test-game-id');
        expect(game.title, 'Test Game');
        expect(game.groupId, 'group-id');
        expect(game.createdBy, 'creator');
        expect(game.maxPlayers, 6);
        expect(game.playerIds, ['creator', 'player1']);
        expect(game.location.name, 'Test Beach');
        expect(game.location.latitude, 40.7128);
      });
    });

    group('JSON serialization', () {
      test('toJson serializes all fields correctly', () {
        final json = testGame.toJson();

        expect(json['id'], 'test-game-id');
        expect(json['title'], 'Beach Volleyball Game');
        expect(json['description'], 'A fun beach volleyball game');
        expect(json['groupId'], 'test-group-id');
        expect(json['createdBy'], 'creator-uid');
        expect(json['status'], 'scheduled');
        expect(json['maxPlayers'], 4);
        expect(json['minPlayers'], 2);
        expect(json['playerIds'], ['creator-uid', 'player1-uid']);
        expect(json['waitlistIds'], []);
        expect(json['allowWaitlist'], true);
        expect(json['allowPlayerInvites'], true);
        expect(json['visibility'], 'group');
        expect(json['notes'], 'Bring sunscreen and water');
        expect(json['equipment'], ['Volleyball', 'Net']);
        expect(json['courtInfo'], 'Court 1');
        expect(json['gameType'], 'beach_volleyball');
        expect(json['skillLevel'], 'intermediate');
        expect(json['weatherDependent'], true);
        expect(json['weatherNotes'], 'Game cancelled if raining');

        // Test location serialization
        final location = json['location'] as Map<String, dynamic>;
        expect(location['name'], 'Sunset Beach');
        expect(location['address'], '123 Beach St');
        expect(location['latitude'], 40.7128);
        expect(location['longitude'], -74.0060);
        expect(location['description'], 'Beautiful beach volleyball court');
        expect(location['parkingInfo'], 'Free parking available');
        expect(location['accessInstructions'], 'Enter through main gate');
      });

      test('toFirestore excludes id field', () {
        final firestoreData = testGame.toFirestore();

        expect(firestoreData.containsKey('id'), false);
        expect(firestoreData['title'], 'Beach Volleyball Game');
        expect(firestoreData['groupId'], 'test-group-id');
      });
    });

    group('Business logic methods', () {
      test('isPlayer returns correct values', () {
        expect(testGame.isPlayer('creator-uid'), true);
        expect(testGame.isPlayer('player1-uid'), true);
        expect(testGame.isPlayer('nonplayer-uid'), false);
      });

      test('isOnWaitlist returns correct values', () {
        final gameWithWaitlist = testGame.copyWith(waitlistIds: ['waitlist-uid']);

        expect(gameWithWaitlist.isOnWaitlist('waitlist-uid'), true);
        expect(gameWithWaitlist.isOnWaitlist('creator-uid'), false);
      });

      test('isCreator returns correct value', () {
        expect(testGame.isCreator('creator-uid'), true);
        expect(testGame.isCreator('player1-uid'), false);
      });

      test('canManage returns correct value (creator only)', () {
        expect(testGame.canManage('creator-uid'), true);
        expect(testGame.canManage('player1-uid'), false);
      });

      test('isFull returns correct value', () {
        expect(testGame.isFull, false); // 2 players, max 4

        final fullGame = testGame.copyWith(
          playerIds: ['p1', 'p2', 'p3', 'p4'],
        );
        expect(fullGame.isFull, true);
      });

      test('hasMinimumPlayers returns correct value', () {
        expect(testGame.hasMinimumPlayers, true); // 2 players, min 2

        final gameWithoutMinPlayers = testGame.copyWith(
          playerIds: ['creator-uid'],
          minPlayers: 2,
        );
        expect(gameWithoutMinPlayers.hasMinimumPlayers, false);
      });

      test('availableSpots returns correct count', () {
        expect(testGame.availableSpots, 2); // max 4, current 2
      });

      test('currentPlayerCount returns correct count', () {
        expect(testGame.currentPlayerCount, 2);
      });

      test('waitlistCount returns correct count', () {
        expect(testGame.waitlistCount, 0);

        final gameWithWaitlist = testGame.copyWith(waitlistIds: ['w1', 'w2']);
        expect(gameWithWaitlist.waitlistCount, 2);
      });

      test('canStart returns correct value', () {
        // Game in past should not be able to start
        final pastGame = testGame.copyWith(
          scheduledAt: DateTime.now().subtract(const Duration(hours: 1)),
        );
        expect(pastGame.canStart, false);

        // Game within 15 minutes should be able to start
        final soonGame = testGame.copyWith(
          scheduledAt: DateTime.now().add(const Duration(minutes: 10)),
          status: GameStatus.scheduled,
        );
        expect(soonGame.hasMinimumPlayers, true);
        expect(soonGame.status, GameStatus.scheduled);
        expect(soonGame.canStart, true);

        // Game without minimum players should not start
        final gameWithoutMinPlayers = testGame.copyWith(
          scheduledAt: DateTime.now().add(const Duration(minutes: 10)),
          playerIds: ['creator-uid'],
          minPlayers: 2,
        );
        expect(gameWithoutMinPlayers.canStart, false);

        // Game already in progress should not start
        final inProgressGame = testGame.copyWith(
          scheduledAt: DateTime.now().add(const Duration(minutes: 10)),
          status: GameStatus.inProgress,
        );
        expect(inProgressGame.canStart, false);
      });

      test('isPast returns correct value', () {
        expect(testGame.isPast, true); // scheduled for 2023-12-02

        final futureGame = testGame.copyWith(
          scheduledAt: DateTime.now().add(const Duration(hours: 1)),
        );
        expect(futureGame.isPast, false);
      });

      test('isToday returns correct value', () {
        final todayGame = testGame.copyWith(
          scheduledAt: DateTime.now(),
        );
        expect(todayGame.isToday, true);

        final yesterdayGame = testGame.copyWith(
          scheduledAt: DateTime.now().subtract(const Duration(days: 1)),
        );
        expect(yesterdayGame.isToday, false);
      });

      test('isThisWeek returns correct value', () {
        final thisWeekGame = testGame.copyWith(
          scheduledAt: DateTime.now().add(const Duration(days: 2)),
        );
        expect(thisWeekGame.isThisWeek, true);

        final nextWeekGame = testGame.copyWith(
          scheduledAt: DateTime.now().add(const Duration(days: 10)),
        );
        expect(nextWeekGame.isThisWeek, false);
      });

      test('gameDuration returns correct duration', () {
        expect(testGame.gameDuration, null); // Not started

        final completedGame = testGame.copyWith(
          startedAt: DateTime(2023, 12, 2, 15, 0, 0),
          endedAt: DateTime(2023, 12, 2, 17, 30, 0),
        );
        expect(completedGame.gameDuration, const Duration(hours: 2, minutes: 30));
      });

      test('canUserJoin returns correct values', () {
        // User already playing cannot join
        expect(testGame.canUserJoin('creator-uid'), false);

        // User on waitlist cannot join
        final gameWithWaitlist = testGame.copyWith(waitlistIds: ['waitlist-uid']);
        expect(gameWithWaitlist.canUserJoin('waitlist-uid'), false);

        // Game not scheduled cannot be joined
        final inProgressGame = testGame.copyWith(status: GameStatus.inProgress);
        expect(inProgressGame.canUserJoin('new-user'), false);

        // Past game cannot be joined
        final pastGame = testGame.copyWith(
          scheduledAt: DateTime.now().subtract(const Duration(hours: 1)),
        );
        expect(pastGame.canUserJoin('new-user'), false);

        // Full game with waitlist allowed can be joined (to waitlist)
        final fullGameWithWaitlist = testGame.copyWith(
          playerIds: ['p1', 'p2', 'p3', 'p4'],
          allowWaitlist: true,
        );
        expect(fullGameWithWaitlist.canUserJoin('new-user'), true);

        // Full game without waitlist cannot be joined
        final fullGameNoWaitlist = testGame.copyWith(
          playerIds: ['p1', 'p2', 'p3', 'p4'],
          allowWaitlist: false,
        );
        expect(fullGameNoWaitlist.canUserJoin('new-user'), false);

        // Available spots can be joined
        expect(testGame.canUserJoin('new-user'), true);
      });

      test('canUserLeave returns correct values', () {
        // Player can leave scheduled game
        expect(testGame.canUserLeave('creator-uid'), true);

        // Waitlisted user can leave
        final gameWithWaitlist = testGame.copyWith(waitlistIds: ['waitlist-uid']);
        expect(gameWithWaitlist.canUserLeave('waitlist-uid'), true);

        // Non-participant cannot leave
        expect(testGame.canUserLeave('non-participant'), false);

        // Cannot leave non-scheduled game
        final inProgressGame = testGame.copyWith(status: GameStatus.inProgress);
        expect(inProgressGame.canUserLeave('creator-uid'), false);
      });

      test('hasValidTiming returns correct value', () {
        expect(testGame.hasValidTiming, false); // scheduled in past

        final futureGame = testGame.copyWith(
          scheduledAt: DateTime.now().add(const Duration(hours: 1)),
        );
        expect(futureGame.hasValidTiming, true);
      });

      test('hasValidPlayerLimits returns correct value', () {
        expect(testGame.hasValidPlayerLimits, true); // min 2, max 4

        final invalidGame = testGame.copyWith(
          minPlayers: 5,
          maxPlayers: 3,
        );
        expect(invalidGame.hasValidPlayerLimits, false);

        final invalidMinGame = testGame.copyWith(
          minPlayers: 1,
        );
        expect(invalidMinGame.hasValidPlayerLimits, false);
      });

      test('getTimeUntilGame returns correct string', () {
        final futureGame = testGame.copyWith(
          scheduledAt: DateTime.now().add(const Duration(days: 2, hours: 3)),
        );
        final timeString = futureGame.getTimeUntilGame();
        expect(timeString, contains('2d'));
        expect(timeString, contains('3h'));

        final pastGame = testGame.copyWith(
          scheduledAt: DateTime.now().subtract(const Duration(hours: 1)),
        );
        expect(pastGame.getTimeUntilGame(), 'Past');

        final soonGame = testGame.copyWith(
          scheduledAt: DateTime.now().add(const Duration(minutes: 45)),
        );
        expect(soonGame.getTimeUntilGame(), contains('45m'));
      });
    });

    group('Update methods', () {
      test('updateInfo updates game information', () {
        final updatedGame = testGame.updateInfo(
          title: 'Updated Game Title',
          description: 'Updated description',
          scheduledAt: DateTime.now().add(const Duration(days: 1)),
          location: const GameLocation(
            name: 'New Beach',
            address: '456 New St',
          ),
          notes: 'Updated notes',
          equipment: ['New Ball'],
          estimatedDuration: const Duration(hours: 3),
        );

        expect(updatedGame.title, 'Updated Game Title');
        expect(updatedGame.description, 'Updated description');
        expect(updatedGame.location.name, 'New Beach');
        expect(updatedGame.notes, 'Updated notes');
        expect(updatedGame.equipment, ['New Ball']);
        expect(updatedGame.estimatedDuration, const Duration(hours: 3));
        expect(updatedGame.updatedAt!.isAfter(testGame.updatedAt!), true);
      });

      test('updateSettings updates game settings', () {
        final updatedGame = testGame.updateSettings(
          maxPlayers: 6,
          minPlayers: 3,
          allowWaitlist: false,
          allowPlayerInvites: false,
          visibility: GameVisibility.public,
          gameType: GameType.indoorVolleyball,
          skillLevel: GameSkillLevel.advanced,
          weatherDependent: false,
          weatherNotes: 'Indoor game',
        );

        expect(updatedGame.maxPlayers, 6);
        expect(updatedGame.minPlayers, 3);
        expect(updatedGame.allowWaitlist, false);
        expect(updatedGame.allowPlayerInvites, false);
        expect(updatedGame.visibility, GameVisibility.public);
        expect(updatedGame.gameType, GameType.indoorVolleyball);
        expect(updatedGame.skillLevel, GameSkillLevel.advanced);
        expect(updatedGame.weatherDependent, false);
        expect(updatedGame.weatherNotes, 'Indoor game');
      });

      test('addPlayer adds player when space available', () {
        final updatedGame = testGame.addPlayer('new-player-uid');

        expect(updatedGame.playerIds, [
          'creator-uid',
          'player1-uid',
          'new-player-uid'
        ]);
        expect(updatedGame.currentPlayerCount, 3);
      });

      test('addPlayer adds to waitlist when game is full', () {
        final fullGame = testGame.copyWith(
          playerIds: ['p1', 'p2', 'p3', 'p4'],
          allowWaitlist: true,
        );
        final updatedGame = fullGame.addPlayer('new-player-uid');

        expect(updatedGame.playerIds, ['p1', 'p2', 'p3', 'p4']);
        expect(updatedGame.waitlistIds, ['new-player-uid']);
      });

      test('addPlayer does nothing when already a player', () {
        final updatedGame = testGame.addPlayer('creator-uid');

        expect(updatedGame.playerIds, testGame.playerIds);
      });

      test('removePlayer removes player and promotes from waitlist', () {
        final gameWithWaitlist = testGame.copyWith(
          waitlistIds: ['waitlist-uid'],
        );
        final updatedGame = gameWithWaitlist.removePlayer('player1-uid');

        expect(updatedGame.playerIds, ['creator-uid', 'waitlist-uid']);
        expect(updatedGame.waitlistIds, <String>[]);
      });

      test('startGame changes status and sets startedAt', () {
        final updatedGame = testGame.startGame();

        expect(updatedGame.status, GameStatus.inProgress);
        expect(updatedGame.startedAt, isNotNull);
        expect(updatedGame.updatedAt!.isAfter(testGame.updatedAt!), true);
      });

      test('startGame does nothing when not scheduled or insufficient players', () {
        final inProgressGame = testGame.copyWith(status: GameStatus.inProgress);
        final updatedGame = inProgressGame.startGame();

        expect(updatedGame.status, GameStatus.inProgress);
        expect(updatedGame.startedAt, null);

        final gameWithoutMinPlayers = testGame.copyWith(
          playerIds: ['creator-uid'],
          minPlayers: 2,
        );
        final stillScheduled = gameWithoutMinPlayers.startGame();
        expect(stillScheduled.status, GameStatus.scheduled);
      });

      test('endGame changes status and sets endedAt', () {
        final inProgressGame = testGame.copyWith(
          status: GameStatus.inProgress,
          startedAt: DateTime.now(),
        );
        final scores = [
          const GameScore(playerId: 'creator-uid', score: 21),
          const GameScore(playerId: 'player1-uid', score: 19),
        ];
        final updatedGame = inProgressGame.endGame(
          winnerId: 'creator-uid',
          finalScores: scores,
        );

        expect(updatedGame.status, GameStatus.completed);
        expect(updatedGame.endedAt, isNotNull);
        expect(updatedGame.winnerId, 'creator-uid');
        expect(updatedGame.scores, scores);
      });

      test('endGame does nothing when not in progress', () {
        final updatedGame = testGame.endGame();

        expect(updatedGame.status, GameStatus.scheduled);
        expect(updatedGame.endedAt, null);
      });

      test('cancelGame changes status to cancelled', () {
        final updatedGame = testGame.cancelGame();

        expect(updatedGame.status, GameStatus.cancelled);
        expect(updatedGame.updatedAt!.isAfter(testGame.updatedAt!), true);
      });

      test('cancelGame does nothing when already completed', () {
        final completedGame = testGame.copyWith(status: GameStatus.completed);
        final updatedGame = completedGame.cancelGame();

        expect(updatedGame.status, GameStatus.completed);
      });

      test('updateScores updates game scores', () {
        final scores = [
          const GameScore(playerId: 'creator-uid', score: 15),
          const GameScore(playerId: 'player1-uid', score: 12),
        ];
        final updatedGame = testGame.updateScores(scores);

        expect(updatedGame.scores, scores);
        expect(updatedGame.updatedAt!.isAfter(testGame.updatedAt!), true);
      });
    });

    group('Enums', () {
      test('GameStatus enum has correct JSON values', () {
        expect(GameStatus.scheduled.toString(), 'GameStatus.scheduled');
        expect(GameStatus.inProgress.toString(), 'GameStatus.inProgress');
        expect(GameStatus.completed.toString(), 'GameStatus.completed');
        expect(GameStatus.cancelled.toString(), 'GameStatus.cancelled');
      });

      test('GameVisibility enum has correct JSON values', () {
        expect(GameVisibility.group.toString(), 'GameVisibility.group');
        expect(GameVisibility.public.toString(), 'GameVisibility.public');
        expect(GameVisibility.private.toString(), 'GameVisibility.private');
      });

      test('GameType enum has correct JSON values', () {
        expect(GameType.beachVolleyball.toString(), 'GameType.beachVolleyball');
        expect(GameType.indoorVolleyball.toString(), 'GameType.indoorVolleyball');
        expect(GameType.casual.toString(), 'GameType.casual');
        expect(GameType.competitive.toString(), 'GameType.competitive');
        expect(GameType.tournament.toString(), 'GameType.tournament');
      });

      test('GameSkillLevel enum has correct JSON values', () {
        expect(GameSkillLevel.beginner.toString(), 'GameSkillLevel.beginner');
        expect(GameSkillLevel.intermediate.toString(), 'GameSkillLevel.intermediate');
        expect(GameSkillLevel.advanced.toString(), 'GameSkillLevel.advanced');
        expect(GameSkillLevel.mixed.toString(), 'GameSkillLevel.mixed');
      });
    });

    group('GameLocation', () {
      test('creates GameLocation with required fields', () {
        const location = GameLocation(name: 'Test Beach');

        expect(location.name, 'Test Beach');
        expect(location.address, null);
        expect(location.latitude, null);
        expect(location.longitude, null);
        expect(location.description, null);
        expect(location.parkingInfo, null);
        expect(location.accessInstructions, null);
      });

      test('creates GameLocation with all fields', () {
        const location = GameLocation(
          name: 'Sunset Beach',
          address: '123 Beach St',
          latitude: 40.7128,
          longitude: -74.0060,
          description: 'Beautiful beach',
          parkingInfo: 'Free parking',
          accessInstructions: 'Enter through main gate',
        );

        expect(location.name, 'Sunset Beach');
        expect(location.address, '123 Beach St');
        expect(location.latitude, 40.7128);
        expect(location.longitude, -74.0060);
        expect(location.description, 'Beautiful beach');
        expect(location.parkingInfo, 'Free parking');
        expect(location.accessInstructions, 'Enter through main gate');
      });
    });

    group('GameScore', () {
      test('creates GameScore with required fields', () {
        const score = GameScore(playerId: 'player1', score: 21);

        expect(score.playerId, 'player1');
        expect(score.score, 21);
        expect(score.sets, 0);
        expect(score.gamesWon, 0);
        expect(score.additionalStats, null);
      });

      test('creates GameScore with all fields', () {
        const score = GameScore(
          playerId: 'player1',
          score: 21,
          sets: 2,
          gamesWon: 3,
          additionalStats: {'aces': 5, 'kills': 12},
        );

        expect(score.playerId, 'player1');
        expect(score.score, 21);
        expect(score.sets, 2);
        expect(score.gamesWon, 3);
        expect(score.additionalStats, {'aces': 5, 'kills': 12});
      });
    });
  });
}

// Mock DocumentSnapshot for testing
class MockDocumentSnapshot implements DocumentSnapshot {
  final String _id;
  final Map<String, dynamic> _data;

  MockDocumentSnapshot(this._id, this._data);

  @override
  String get id => _id;

  @override
  Map<String, dynamic>? data() => _data;

  @override
  bool get exists => true;

  // Implement other required methods as no-ops for testing
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}