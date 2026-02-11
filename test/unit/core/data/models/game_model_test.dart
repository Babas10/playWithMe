// Tests GameModel serialization and business logic methods
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/game_model.dart';

void main() {
  group('GameModel', () {
    GameModel createTestGame({
      String id = 'test-game-123',
      String title = 'Test Game',
      String groupId = 'group-123',
      String createdBy = 'user-123',
      DateTime? createdAt,
      DateTime? scheduledAt,
      GameLocation? location,
      GameStatus status = GameStatus.scheduled,
      int maxPlayers = 4,
      int minPlayers = 2,
      List<String>? playerIds,
      List<String>? waitlistIds,
      bool allowWaitlist = true,
      GameResult? result,
      DateTime? startedAt,
      DateTime? endedAt,
    }) {
      final now = DateTime.now();
      return GameModel(
        id: id,
        title: title,
        groupId: groupId,
        createdBy: createdBy,
        createdAt: createdAt ?? now,
        scheduledAt: scheduledAt ?? now.add(const Duration(days: 1)),
        location: location ?? const GameLocation(name: 'Beach Court'),
        status: status,
        maxPlayers: maxPlayers,
        minPlayers: minPlayers,
        playerIds: playerIds ?? const [],
        waitlistIds: waitlistIds ?? const [],
        allowWaitlist: allowWaitlist,
        result: result,
        startedAt: startedAt,
        endedAt: endedAt,
      );
    }

    group('toFirestore', () {
      test('converts DateTime fields to Timestamp', () {
        final now = DateTime.now();
        final futureDate = now.add(const Duration(days: 1));

        final game = GameModel(
          id: 'test-game-123',
          title: 'Test Game',
          groupId: 'group-123',
          createdBy: 'user-123',
          createdAt: now,
          scheduledAt: futureDate,
          location: const GameLocation(name: 'Beach Court'),
          status: GameStatus.scheduled,
        );

        final firestoreData = game.toFirestore();

        expect(firestoreData['createdAt'], isA<Timestamp>());
        expect(firestoreData['scheduledAt'], isA<Timestamp>());

        final createdAtTimestamp = firestoreData['createdAt'] as Timestamp;
        final scheduledAtTimestamp = firestoreData['scheduledAt'] as Timestamp;

        expect(
          createdAtTimestamp.toDate(),
          equals(now),
        );
        expect(
          scheduledAtTimestamp.toDate(),
          equals(futureDate),
        );
      });

      test('converts optional DateTime fields to Timestamp when present', () {
        final now = DateTime.now();
        final startTime = now.add(const Duration(hours: 1));
        final endTime = now.add(const Duration(hours: 2));
        final updateTime = now.add(const Duration(minutes: 30));

        final game = GameModel(
          id: 'test-game-456',
          title: 'Test Game with Optional Times',
          groupId: 'group-123',
          createdBy: 'user-123',
          createdAt: now,
          scheduledAt: now,
          updatedAt: updateTime,
          startedAt: startTime,
          endedAt: endTime,
          location: const GameLocation(name: 'Beach Court'),
          status: GameStatus.completed,
        );

        final firestoreData = game.toFirestore();

        expect(firestoreData['updatedAt'], isA<Timestamp>());
        expect(firestoreData['startedAt'], isA<Timestamp>());
        expect(firestoreData['endedAt'], isA<Timestamp>());
      });

      test('excludes id from Firestore data', () {
        final game = GameModel(
          id: 'test-game-789',
          title: 'Test Game',
          groupId: 'group-123',
          createdBy: 'user-123',
          createdAt: DateTime.now(),
          scheduledAt: DateTime.now(),
          location: const GameLocation(name: 'Beach Court'),
        );

        final firestoreData = game.toFirestore();

        expect(firestoreData.containsKey('id'), isFalse);
      });

      test('properly serializes nested GameLocation object', () {
        final game = GameModel(
          id: 'test-game-101',
          title: 'Test Game',
          groupId: 'group-123',
          createdBy: 'user-123',
          createdAt: DateTime.now(),
          scheduledAt: DateTime.now(),
          location: const GameLocation(
            name: 'Sunset Beach',
            address: '123 Beach St',
            latitude: 34.0195,
            longitude: -118.4912,
          ),
        );

        final firestoreData = game.toFirestore();

        expect(firestoreData['location'], isA<Map>());
        final location = firestoreData['location'] as Map;
        expect(location['name'], 'Sunset Beach');
        expect(location['address'], '123 Beach St');
        expect(location['latitude'], 34.0195);
        expect(location['longitude'], -118.4912);
      });

      test('includes all required fields', () {
        final game = GameModel(
          id: 'test-game-202',
          title: 'Required Fields Test',
          groupId: 'group-123',
          createdBy: 'user-123',
          createdAt: DateTime.now(),
          scheduledAt: DateTime.now(),
          location: const GameLocation(name: 'Court'),
          status: GameStatus.scheduled,
          maxPlayers: 8,
          minPlayers: 4,
        );

        final firestoreData = game.toFirestore();

        expect(firestoreData['title'], 'Required Fields Test');
        expect(firestoreData['groupId'], 'group-123');
        expect(firestoreData['createdBy'], 'user-123');
        expect(firestoreData['status'], 'scheduled');
        expect(firestoreData['maxPlayers'], 8);
        expect(firestoreData['minPlayers'], 4);
      });

      test('properly serializes GameTeams object', () {
        final game = GameModel(
          id: 'test-game-303',
          title: 'Test Game with Teams',
          groupId: 'group-123',
          createdBy: 'user-123',
          createdAt: DateTime.now(),
          scheduledAt: DateTime.now(),
          location: const GameLocation(name: 'Court'),
          status: GameStatus.completed,
          playerIds: const ['player1', 'player2', 'player3', 'player4'],
          teams: const GameTeams(
            teamAPlayerIds: ['player1', 'player2'],
            teamBPlayerIds: ['player3', 'player4'],
          ),
        );

        final firestoreData = game.toFirestore();

        expect(firestoreData['teams'], isA<Map>());
        final teams = firestoreData['teams'] as Map;
        expect(teams['teamAPlayerIds'], ['player1', 'player2']);
        expect(teams['teamBPlayerIds'], ['player3', 'player4']);
      });

      test('properly serializes GameResult with sets and games', () {
        final result = GameResult(
          games: const [
            IndividualGame(
              gameNumber: 1,
              sets: [
                SetScore(teamAPoints: 21, teamBPoints: 15, setNumber: 1),
              ],
              winner: 'teamA',
            ),
            IndividualGame(
              gameNumber: 2,
              sets: [
                SetScore(teamAPoints: 19, teamBPoints: 21, setNumber: 1),
              ],
              winner: 'teamB',
            ),
            IndividualGame(
              gameNumber: 3,
              sets: [
                SetScore(teamAPoints: 21, teamBPoints: 18, setNumber: 1),
              ],
              winner: 'teamA',
            ),
          ],
          overallWinner: 'teamA',
        );

        final game = GameModel(
          id: 'test-game-404',
          title: 'Test Game with Result',
          groupId: 'group-123',
          createdBy: 'user-123',
          createdAt: DateTime.now(),
          scheduledAt: DateTime.now(),
          location: const GameLocation(name: 'Court'),
          status: GameStatus.completed,
          result: result,
        );

        final firestoreData = game.toFirestore();

        expect(firestoreData['result'], isA<Map>());
        final resultMap = firestoreData['result'] as Map;
        expect(resultMap['overallWinner'], 'teamA');
        expect(resultMap['games'], isA<List>());
        final games = resultMap['games'] as List;
        expect(games.length, 3);
        expect(games[0]['gameNumber'], 1);
        expect(games[0]['winner'], 'teamA');
      });

      test('includes eloCalculated flag defaulting to false', () {
        final game = GameModel(
          id: 'test-game-505',
          title: 'Test Game',
          groupId: 'group-123',
          createdBy: 'user-123',
          createdAt: DateTime.now(),
          scheduledAt: DateTime.now(),
          location: const GameLocation(name: 'Court'),
        );

        final firestoreData = game.toFirestore();

        expect(firestoreData['eloCalculated'], false);
      });

      test('converts completedAt DateTime to Timestamp when present', () {
        final now = DateTime.now();
        final completedTime = now.add(const Duration(hours: 2));

        final game = GameModel(
          id: 'test-game-606',
          title: 'Test Game with Completion Time',
          groupId: 'group-123',
          createdBy: 'user-123',
          createdAt: now,
          scheduledAt: now,
          location: const GameLocation(name: 'Court'),
          status: GameStatus.completed,
          completedAt: completedTime,
          eloCalculated: false,
        );

        final firestoreData = game.toFirestore();

        expect(firestoreData['completedAt'], isA<Timestamp>());
        final completedAtTimestamp = firestoreData['completedAt'] as Timestamp;
        expect(completedAtTimestamp.toDate(), equals(completedTime));
        expect(firestoreData['eloCalculated'], false);
      });

      test('serializes complete game with teams, result, and elo flag', () {
        final now = DateTime.now();
        final completedTime = now.add(const Duration(hours: 2));

        final game = GameModel(
          id: 'test-game-707',
          title: 'Complete Game Test',
          groupId: 'group-123',
          createdBy: 'user-123',
          createdAt: now,
          scheduledAt: now,
          location: const GameLocation(name: 'Court'),
          status: GameStatus.completed,
          playerIds: const ['p1', 'p2', 'p3', 'p4'],
          teams: const GameTeams(
            teamAPlayerIds: ['p1', 'p2'],
            teamBPlayerIds: ['p3', 'p4'],
          ),
          result: const GameResult(
            games: [
              IndividualGame(
                gameNumber: 1,
                sets: [SetScore(teamAPoints: 21, teamBPoints: 19, setNumber: 1)],
                winner: 'teamA',
              ),
            ],
            overallWinner: 'teamA',
          ),
          winnerId: 'teamA',
          eloCalculated: false,
          completedAt: completedTime,
        );

        final firestoreData = game.toFirestore();

        expect(firestoreData['teams'], isA<Map>());
        expect(firestoreData['result'], isA<Map>());
        expect(firestoreData['eloCalculated'], false);
        expect(firestoreData['completedAt'], isA<Timestamp>());
        expect(firestoreData['winnerId'], 'teamA');
      });

      test('removes null or empty eloUpdates', () {
        final game = GameModel(
          id: 'test-game-808',
          title: 'Test Game',
          groupId: 'group-123',
          createdBy: 'user-123',
          createdAt: DateTime.now(),
          scheduledAt: DateTime.now(),
          location: const GameLocation(name: 'Court'),
          eloUpdates: null,
        );

        final firestoreData = game.toFirestore();

        expect(firestoreData.containsKey('eloUpdates'), isFalse);
      });
    });

    group('fromFirestore', () {
      test('deserializes Timestamp fields to DateTime', () {
        final now = DateTime.now();
        final futureDate = now.add(const Duration(days: 1));

        final firestoreDoc = {
          'id': 'test-game-303',
          'title': 'Test Game',
          'groupId': 'group-123',
          'createdBy': 'user-123',
          'createdAt': Timestamp.fromDate(now),
          'scheduledAt': Timestamp.fromDate(futureDate),
          'location': {
            'name': 'Beach Court',
          },
          'status': 'scheduled',
          'maxPlayers': 4,
          'minPlayers': 2,
          'playerIds': <String>[],
          'waitlistIds': <String>[],
        };

        final game = GameModel.fromJson({
          ...firestoreDoc,
          'createdAt':
              (firestoreDoc['createdAt'] as Timestamp).toDate().toIso8601String(),
          'scheduledAt': (firestoreDoc['scheduledAt'] as Timestamp)
              .toDate()
              .toIso8601String(),
        });

        expect(game.createdAt, isA<DateTime>());
        expect(game.scheduledAt, isA<DateTime>());
      });
    });

    group('Business Logic Methods', () {
      group('isPlayer', () {
        test('returns true when user is a player', () {
          final game = createTestGame(
            playerIds: ['user-123', 'user-456'],
          );

          expect(game.isPlayer('user-123'), isTrue);
          expect(game.isPlayer('user-456'), isTrue);
        });

        test('returns false when user is not a player', () {
          final game = createTestGame(
            playerIds: ['user-123'],
          );

          expect(game.isPlayer('user-789'), isFalse);
        });
      });

      group('isOnWaitlist', () {
        test('returns true when user is on waitlist', () {
          final game = createTestGame(
            waitlistIds: ['user-456', 'user-789'],
          );

          expect(game.isOnWaitlist('user-456'), isTrue);
        });

        test('returns false when user is not on waitlist', () {
          final game = createTestGame(
            waitlistIds: ['user-456'],
          );

          expect(game.isOnWaitlist('user-123'), isFalse);
        });
      });

      group('isCreator', () {
        test('returns true when user is the creator', () {
          final game = createTestGame(createdBy: 'user-123');

          expect(game.isCreator('user-123'), isTrue);
        });

        test('returns false when user is not the creator', () {
          final game = createTestGame(createdBy: 'user-123');

          expect(game.isCreator('user-456'), isFalse);
        });
      });

      group('canManage', () {
        test('returns true when user is the creator', () {
          final game = createTestGame(createdBy: 'user-123');

          expect(game.canManage('user-123'), isTrue);
        });

        test('returns false when user is not the creator', () {
          final game = createTestGame(createdBy: 'user-123');

          expect(game.canManage('user-456'), isFalse);
        });
      });

      group('isFull', () {
        test('returns true when player count equals max players', () {
          final game = createTestGame(
            maxPlayers: 4,
            playerIds: ['p1', 'p2', 'p3', 'p4'],
          );

          expect(game.isFull, isTrue);
        });

        test('returns true when player count exceeds max players', () {
          final game = createTestGame(
            maxPlayers: 4,
            playerIds: ['p1', 'p2', 'p3', 'p4', 'p5'],
          );

          expect(game.isFull, isTrue);
        });

        test('returns false when player count is less than max', () {
          final game = createTestGame(
            maxPlayers: 4,
            playerIds: ['p1', 'p2'],
          );

          expect(game.isFull, isFalse);
        });
      });

      group('hasMinimumPlayers', () {
        test('returns true when player count meets minimum', () {
          final game = createTestGame(
            minPlayers: 2,
            playerIds: ['p1', 'p2'],
          );

          expect(game.hasMinimumPlayers, isTrue);
        });

        test('returns true when player count exceeds minimum', () {
          final game = createTestGame(
            minPlayers: 2,
            playerIds: ['p1', 'p2', 'p3', 'p4'],
          );

          expect(game.hasMinimumPlayers, isTrue);
        });

        test('returns false when player count is below minimum', () {
          final game = createTestGame(
            minPlayers: 4,
            playerIds: ['p1', 'p2'],
          );

          expect(game.hasMinimumPlayers, isFalse);
        });
      });

      group('availableSpots', () {
        test('returns correct number of available spots', () {
          final game = createTestGame(
            maxPlayers: 6,
            playerIds: ['p1', 'p2'],
          );

          expect(game.availableSpots, 4);
        });

        test('returns 0 when game is full', () {
          final game = createTestGame(
            maxPlayers: 4,
            playerIds: ['p1', 'p2', 'p3', 'p4'],
          );

          expect(game.availableSpots, 0);
        });
      });

      group('currentPlayerCount', () {
        test('returns correct player count', () {
          final game = createTestGame(
            playerIds: ['p1', 'p2', 'p3'],
          );

          expect(game.currentPlayerCount, 3);
        });

        test('returns 0 when no players', () {
          final game = createTestGame(playerIds: []);

          expect(game.currentPlayerCount, 0);
        });
      });

      group('waitlistCount', () {
        test('returns correct waitlist count', () {
          final game = createTestGame(
            waitlistIds: ['w1', 'w2'],
          );

          expect(game.waitlistCount, 2);
        });

        test('returns 0 when no waitlist', () {
          final game = createTestGame(waitlistIds: []);

          expect(game.waitlistCount, 0);
        });
      });

      group('isPast', () {
        test('returns true when scheduled date is in the past', () {
          final game = createTestGame(
            scheduledAt: DateTime.now().subtract(const Duration(hours: 1)),
          );

          expect(game.isPast, isTrue);
        });

        test('returns false when scheduled date is in the future', () {
          final game = createTestGame(
            scheduledAt: DateTime.now().add(const Duration(hours: 1)),
          );

          expect(game.isPast, isFalse);
        });
      });

      group('isToday', () {
        test('returns true when game is scheduled for today', () {
          final game = createTestGame(
            scheduledAt: DateTime.now(),
          );

          expect(game.isToday, isTrue);
        });

        test('returns false when game is scheduled for tomorrow', () {
          final game = createTestGame(
            scheduledAt: DateTime.now().add(const Duration(days: 1)),
          );

          expect(game.isToday, isFalse);
        });

        test('returns false when game was yesterday', () {
          final game = createTestGame(
            scheduledAt: DateTime.now().subtract(const Duration(days: 1)),
          );

          expect(game.isToday, isFalse);
        });
      });

      group('gameDuration', () {
        test('returns duration when game has started and ended', () {
          final startTime = DateTime.now();
          final endTime = startTime.add(const Duration(hours: 2));

          final game = createTestGame(
            startedAt: startTime,
            endedAt: endTime,
          );

          expect(game.gameDuration, const Duration(hours: 2));
        });

        test('returns null when game has not started', () {
          final game = createTestGame();

          expect(game.gameDuration, isNull);
        });

        test('returns null when game has not ended', () {
          final game = createTestGame(
            startedAt: DateTime.now(),
          );

          expect(game.gameDuration, isNull);
        });
      });

      group('canUserJoin', () {
        test('returns true when game has spots and user is not playing', () {
          final game = createTestGame(
            maxPlayers: 4,
            playerIds: ['p1', 'p2'],
            scheduledAt: DateTime.now().add(const Duration(hours: 1)),
          );

          expect(game.canUserJoin('user-new'), isTrue);
        });

        test('returns false when user is already a player', () {
          final game = createTestGame(
            playerIds: ['user-123'],
          );

          expect(game.canUserJoin('user-123'), isFalse);
        });

        test('returns false when user is on waitlist', () {
          final game = createTestGame(
            waitlistIds: ['user-123'],
          );

          expect(game.canUserJoin('user-123'), isFalse);
        });

        test('returns false when game is not scheduled', () {
          final game = createTestGame(
            status: GameStatus.inProgress,
          );

          expect(game.canUserJoin('user-new'), isFalse);
        });

        test('returns false when game is in the past', () {
          final game = createTestGame(
            scheduledAt: DateTime.now().subtract(const Duration(hours: 1)),
          );

          expect(game.canUserJoin('user-new'), isFalse);
        });

        test('returns true for waitlist when game is full and waitlist allowed',
            () {
          final game = createTestGame(
            maxPlayers: 2,
            playerIds: ['p1', 'p2'],
            allowWaitlist: true,
            scheduledAt: DateTime.now().add(const Duration(hours: 1)),
          );

          expect(game.canUserJoin('user-new'), isTrue);
        });

        test('returns false when game is full and waitlist not allowed', () {
          final game = createTestGame(
            maxPlayers: 2,
            playerIds: ['p1', 'p2'],
            allowWaitlist: false,
            scheduledAt: DateTime.now().add(const Duration(hours: 1)),
          );

          expect(game.canUserJoin('user-new'), isFalse);
        });
      });

      group('canUserLeave', () {
        test('returns true when user is player and game is scheduled', () {
          final game = createTestGame(
            playerIds: ['user-123'],
            status: GameStatus.scheduled,
          );

          expect(game.canUserLeave('user-123'), isTrue);
        });

        test('returns true when user is on waitlist and game is scheduled', () {
          final game = createTestGame(
            waitlistIds: ['user-123'],
            status: GameStatus.scheduled,
          );

          expect(game.canUserLeave('user-123'), isTrue);
        });

        test('returns false when user is not participating', () {
          final game = createTestGame(
            playerIds: ['other-user'],
            status: GameStatus.scheduled,
          );

          expect(game.canUserLeave('user-123'), isFalse);
        });

        test('returns false when game is in progress', () {
          final game = createTestGame(
            playerIds: ['user-123'],
            status: GameStatus.inProgress,
          );

          expect(game.canUserLeave('user-123'), isFalse);
        });
      });

      group('canUserEnterResults', () {
        test('returns true when participant and game is completed with enough players', () {
          final game = createTestGame(
            playerIds: ['user-123', 'user-456'],
            minPlayers: 2,
            status: GameStatus.completed,
          );

          expect(game.canUserEnterResults('user-123'), isTrue);
        });

        test('returns true when creator and game is past with enough players', () {
          final game = createTestGame(
            createdBy: 'user-123',
            playerIds: ['user-123', 'user-456'],
            minPlayers: 2,
            scheduledAt: DateTime.now().subtract(const Duration(hours: 1)),
          );

          expect(game.canUserEnterResults('user-123'), isTrue);
        });

        test('returns false when result already exists', () {
          final game = createTestGame(
            playerIds: ['user-123', 'user-456'],
            minPlayers: 2,
            status: GameStatus.completed,
            result: const GameResult(
              games: [
                IndividualGame(
                  gameNumber: 1,
                  sets: [SetScore(teamAPoints: 21, teamBPoints: 18, setNumber: 1)],
                  winner: 'teamA',
                ),
              ],
              overallWinner: 'teamA',
            ),
          );

          expect(game.canUserEnterResults('user-123'), isFalse);
        });

        test('returns false when game is cancelled', () {
          final game = createTestGame(
            playerIds: ['user-123', 'user-456'],
            minPlayers: 2,
            status: GameStatus.cancelled,
          );

          expect(game.canUserEnterResults('user-123'), isFalse);
        });

        test('returns false when game is in verification', () {
          final game = createTestGame(
            playerIds: ['user-123', 'user-456'],
            minPlayers: 2,
            status: GameStatus.verification,
          );

          expect(game.canUserEnterResults('user-123'), isFalse);
        });

        test('returns false when creator and game is future (not past scheduled time)', () {
          final game = createTestGame(
            createdBy: 'user-123',
            playerIds: ['user-123', 'user-456'],
            minPlayers: 2,
            scheduledAt: DateTime.now().add(const Duration(hours: 2)),
            status: GameStatus.scheduled,
          );

          expect(game.canUserEnterResults('user-123'), isFalse);
        });

        test('returns false when game has fewer players than minPlayers', () {
          final game = createTestGame(
            playerIds: ['user-123'],
            minPlayers: 4,
            scheduledAt: DateTime.now().subtract(const Duration(hours: 1)),
          );

          expect(game.canUserEnterResults('user-123'), isFalse);
        });

        test('returns false when game has zero players despite being past', () {
          final game = createTestGame(
            createdBy: 'user-123',
            playerIds: [],
            minPlayers: 2,
            scheduledAt: DateTime.now().subtract(const Duration(hours: 1)),
          );

          expect(game.canUserEnterResults('user-123'), isFalse);
        });

        test('returns true when game is in progress with enough players', () {
          final game = createTestGame(
            playerIds: ['user-123', 'user-456'],
            minPlayers: 2,
            status: GameStatus.inProgress,
            scheduledAt: DateTime.now().add(const Duration(hours: 1)),
          );

          expect(game.canUserEnterResults('user-123'), isTrue);
        });

        test('returns false for non-participant even when game is ready', () {
          final game = createTestGame(
            createdBy: 'other-creator',
            playerIds: ['other-user', 'another-user'],
            minPlayers: 2,
            status: GameStatus.completed,
          );

          expect(game.canUserEnterResults('user-123'), isFalse);
        });
      });

      group('hasValidTiming', () {
        test('returns true when scheduled in future', () {
          final game = createTestGame(
            scheduledAt: DateTime.now().add(const Duration(hours: 1)),
          );

          expect(game.hasValidTiming, isTrue);
        });

        test('returns false when scheduled in past', () {
          final game = createTestGame(
            scheduledAt: DateTime.now().subtract(const Duration(hours: 1)),
          );

          expect(game.hasValidTiming, isFalse);
        });
      });

      group('hasValidPlayerLimits', () {
        test('returns true when min <= max and min >= 2', () {
          final game = createTestGame(
            minPlayers: 2,
            maxPlayers: 6,
          );

          expect(game.hasValidPlayerLimits, isTrue);
        });

        test('returns false when min > max', () {
          final game = createTestGame(
            minPlayers: 6,
            maxPlayers: 4,
          );

          expect(game.hasValidPlayerLimits, isFalse);
        });

        test('returns false when min < 2', () {
          final game = createTestGame(
            minPlayers: 1,
            maxPlayers: 4,
          );

          expect(game.hasValidPlayerLimits, isFalse);
        });
      });
    });

    group('Update Methods', () {
      group('updateInfo', () {
        test('updates title successfully', () {
          final game = createTestGame(title: 'Old Title');

          final updated = game.updateInfo(title: 'New Title');

          expect(updated.title, 'New Title');
          expect(updated.updatedAt, isNotNull);
        });

        test('updates description successfully', () {
          final game = createTestGame();

          final updated = game.updateInfo(description: 'New description');

          expect(updated.description, 'New description');
        });

        test('updates location successfully', () {
          final game = createTestGame();
          const newLocation = GameLocation(name: 'New Court');

          final updated = game.updateInfo(location: newLocation);

          expect(updated.location.name, 'New Court');
        });

        test('preserves unchanged fields', () {
          final game = createTestGame(
            title: 'Original Title',
            groupId: 'group-123',
          );

          final updated = game.updateInfo(description: 'New description');

          expect(updated.title, 'Original Title');
          expect(updated.groupId, 'group-123');
        });
      });

      group('updateSettings', () {
        test('updates maxPlayers successfully', () {
          final game = createTestGame(maxPlayers: 4);

          final updated = game.updateSettings(maxPlayers: 8);

          expect(updated.maxPlayers, 8);
        });

        test('updates minPlayers successfully', () {
          final game = createTestGame(minPlayers: 2);

          final updated = game.updateSettings(minPlayers: 4);

          expect(updated.minPlayers, 4);
        });

        test('updates allowWaitlist successfully', () {
          final game = createTestGame(allowWaitlist: true);

          final updated = game.updateSettings(allowWaitlist: false);

          expect(updated.allowWaitlist, false);
        });

        test('updates multiple settings at once', () {
          final game = createTestGame();

          final updated = game.updateSettings(
            maxPlayers: 10,
            minPlayers: 4,
            visibility: GameVisibility.public,
            gameType: GameType.competitive,
            skillLevel: GameSkillLevel.advanced,
          );

          expect(updated.maxPlayers, 10);
          expect(updated.minPlayers, 4);
          expect(updated.visibility, GameVisibility.public);
          expect(updated.gameType, GameType.competitive);
          expect(updated.skillLevel, GameSkillLevel.advanced);
        });
      });

      group('addPlayer', () {
        test('adds player to game when not full', () {
          final game = createTestGame(
            maxPlayers: 4,
            playerIds: ['p1', 'p2'],
          );

          final updated = game.addPlayer('p3');

          expect(updated.playerIds, contains('p3'));
          expect(updated.playerIds.length, 3);
        });

        test('does not add player if already playing', () {
          final game = createTestGame(
            playerIds: ['p1', 'p2'],
          );

          final updated = game.addPlayer('p1');

          expect(updated.playerIds.length, 2);
        });

        test('adds to waitlist when full and waitlist allowed', () {
          final game = createTestGame(
            maxPlayers: 2,
            playerIds: ['p1', 'p2'],
            allowWaitlist: true,
          );

          final updated = game.addPlayer('p3');

          expect(updated.waitlistIds, contains('p3'));
          expect(updated.playerIds.length, 2);
        });

        test('removes from waitlist when adding as player', () {
          final game = createTestGame(
            maxPlayers: 4,
            playerIds: ['p1'],
            waitlistIds: ['p2'],
          );

          final updated = game.addPlayer('p2');

          expect(updated.playerIds, contains('p2'));
          expect(updated.waitlistIds, isNot(contains('p2')));
        });
      });

      group('removePlayer', () {
        test('removes player from game', () {
          final game = createTestGame(
            playerIds: ['p1', 'p2', 'p3'],
          );

          final updated = game.removePlayer('p2');

          expect(updated.playerIds, isNot(contains('p2')));
          expect(updated.playerIds.length, 2);
        });

        test('promotes from waitlist when player removed', () {
          final game = createTestGame(
            maxPlayers: 2,
            playerIds: ['p1', 'p2'],
            waitlistIds: ['p3', 'p4'],
          );

          final updated = game.removePlayer('p1');

          expect(updated.playerIds, contains('p3'));
          expect(updated.waitlistIds, isNot(contains('p3')));
          expect(updated.playerIds.length, 2);
        });

        test('removes from waitlist if user is on waitlist', () {
          final game = createTestGame(
            playerIds: ['p1'],
            waitlistIds: ['w1', 'w2'],
          );

          final updated = game.removePlayer('w1');

          expect(updated.waitlistIds, isNot(contains('w1')));
        });
      });

      group('startGame', () {
        test('starts game when conditions met', () {
          final game = createTestGame(
            status: GameStatus.scheduled,
            minPlayers: 2,
            playerIds: ['p1', 'p2', 'p3', 'p4'],
          );

          final updated = game.startGame();

          expect(updated.status, GameStatus.inProgress);
          expect(updated.startedAt, isNotNull);
        });

        test('does not start if not scheduled', () {
          final game = createTestGame(
            status: GameStatus.inProgress,
            playerIds: ['p1', 'p2'],
          );

          final updated = game.startGame();

          expect(updated.status, GameStatus.inProgress);
          expect(updated.startedAt, isNull);
        });

        test('does not start if not enough players', () {
          final game = createTestGame(
            status: GameStatus.scheduled,
            minPlayers: 4,
            playerIds: ['p1', 'p2'],
          );

          final updated = game.startGame();

          expect(updated.status, GameStatus.scheduled);
        });
      });

      group('endGame', () {
        test('ends game when in progress', () {
          final game = createTestGame(
            status: GameStatus.inProgress,
            startedAt: DateTime.now().subtract(const Duration(hours: 1)),
          );

          final updated = game.endGame(winnerId: 'team-a');

          expect(updated.status, GameStatus.completed);
          expect(updated.endedAt, isNotNull);
          expect(updated.winnerId, 'team-a');
        });

        test('does not end if not in progress', () {
          final game = createTestGame(
            status: GameStatus.scheduled,
          );

          final updated = game.endGame(winnerId: 'team-a');

          expect(updated.status, GameStatus.scheduled);
          expect(updated.endedAt, isNull);
        });
      });

      group('cancelGame', () {
        test('cancels scheduled game', () {
          final game = createTestGame(
            status: GameStatus.scheduled,
          );

          final updated = game.cancelGame();

          expect(updated.status, GameStatus.cancelled);
        });

        test('cancels in-progress game', () {
          final game = createTestGame(
            status: GameStatus.inProgress,
          );

          final updated = game.cancelGame();

          expect(updated.status, GameStatus.cancelled);
        });

        test('does not cancel completed game', () {
          final game = createTestGame(
            status: GameStatus.completed,
          );

          final updated = game.cancelGame();

          expect(updated.status, GameStatus.completed);
        });
      });

      group('updateScores', () {
        test('updates scores successfully', () {
          final game = createTestGame();
          const newScores = [
            GameScore(playerId: 'p1', score: 21),
            GameScore(playerId: 'p2', score: 18),
          ];

          final updated = game.updateScores(newScores);

          expect(updated.scores.length, 2);
          expect(updated.scores[0].score, 21);
          expect(updated.scores[1].score, 18);
        });
      });

      group('getTimeUntilGame', () {
        test('returns Past for past games', () {
          final game = createTestGame(
            scheduledAt: DateTime.now().subtract(const Duration(hours: 1)),
          );

          expect(game.getTimeUntilGame(), 'Past');
        });

        test('returns days format for games more than a day away', () {
          final game = createTestGame(
            scheduledAt: DateTime.now().add(const Duration(days: 2, hours: 5)),
          );

          final result = game.getTimeUntilGame();
          expect(result.contains('d'), isTrue);
        });

        test('returns hours format for games less than a day away', () {
          final game = createTestGame(
            scheduledAt: DateTime.now().add(const Duration(hours: 5, minutes: 30)),
          );

          final result = game.getTimeUntilGame();
          expect(result.contains('h'), isTrue);
        });

        test('returns minutes format for games less than an hour away', () {
          final game = createTestGame(
            scheduledAt: DateTime.now().add(const Duration(minutes: 30)),
          );

          final result = game.getTimeUntilGame();
          expect(result.contains('m'), isTrue);
        });
      });
    });
  });

  group('GameTeams', () {
    test('areAllPlayersAssigned returns true when all players assigned', () {
      const teams = GameTeams(
        teamAPlayerIds: ['p1', 'p2'],
        teamBPlayerIds: ['p3', 'p4'],
      );

      expect(teams.areAllPlayersAssigned(['p1', 'p2', 'p3', 'p4']), isTrue);
    });

    test('areAllPlayersAssigned returns false when player missing', () {
      const teams = GameTeams(
        teamAPlayerIds: ['p1', 'p2'],
        teamBPlayerIds: ['p3'],
      );

      expect(teams.areAllPlayersAssigned(['p1', 'p2', 'p3', 'p4']), isFalse);
    });

    test('hasPlayerOnBothTeams returns true when player on both teams', () {
      const teams = GameTeams(
        teamAPlayerIds: ['p1', 'p2'],
        teamBPlayerIds: ['p2', 'p3'],
      );

      expect(teams.hasPlayerOnBothTeams(), isTrue);
    });

    test('hasPlayerOnBothTeams returns false when no overlap', () {
      const teams = GameTeams(
        teamAPlayerIds: ['p1', 'p2'],
        teamBPlayerIds: ['p3', 'p4'],
      );

      expect(teams.hasPlayerOnBothTeams(), isFalse);
    });

    test('getUnassignedPlayers returns list of unassigned players', () {
      const teams = GameTeams(
        teamAPlayerIds: ['p1'],
        teamBPlayerIds: ['p2'],
      );

      final unassigned = teams.getUnassignedPlayers(['p1', 'p2', 'p3', 'p4']);

      expect(unassigned, ['p3', 'p4']);
    });

    test('isValid returns true for valid teams', () {
      const teams = GameTeams(
        teamAPlayerIds: ['p1', 'p2'],
        teamBPlayerIds: ['p3', 'p4'],
      );

      expect(teams.isValid(['p1', 'p2', 'p3', 'p4']), isTrue);
    });

    test('isValid returns false when player on both teams', () {
      const teams = GameTeams(
        teamAPlayerIds: ['p1', 'p2'],
        teamBPlayerIds: ['p2', 'p3'],
      );

      expect(teams.isValid(['p1', 'p2', 'p3']), isFalse);
    });
  });

  group('SetScore', () {
    test('isValid returns true for valid score (21 win)', () {
      const score = SetScore(
        teamAPoints: 21,
        teamBPoints: 18,
        setNumber: 1,
      );

      expect(score.isValid(), isTrue);
    });

    test('isValid returns true for extended set (22-20)', () {
      const score = SetScore(
        teamAPoints: 22,
        teamBPoints: 20,
        setNumber: 1,
      );

      expect(score.isValid(), isTrue);
    });

    test('isValid returns false when no winner (below 21)', () {
      const score = SetScore(
        teamAPoints: 20,
        teamBPoints: 18,
        setNumber: 1,
      );

      expect(score.isValid(), isFalse);
    });

    test('isValid returns false when not win by 2', () {
      const score = SetScore(
        teamAPoints: 21,
        teamBPoints: 20,
        setNumber: 1,
      );

      expect(score.isValid(), isFalse);
    });

    test('winner returns teamA when team A wins', () {
      const score = SetScore(
        teamAPoints: 21,
        teamBPoints: 18,
        setNumber: 1,
      );

      expect(score.winner, 'teamA');
    });

    test('winner returns teamB when team B wins', () {
      const score = SetScore(
        teamAPoints: 15,
        teamBPoints: 21,
        setNumber: 1,
      );

      expect(score.winner, 'teamB');
    });

    test('winner returns null for invalid score', () {
      const score = SetScore(
        teamAPoints: 10,
        teamBPoints: 5,
        setNumber: 1,
      );

      expect(score.winner, isNull);
    });
  });

  group('IndividualGame', () {
    test('isValid returns true for valid single-set game', () {
      const game = IndividualGame(
        gameNumber: 1,
        sets: [SetScore(teamAPoints: 21, teamBPoints: 18, setNumber: 1)],
        winner: 'teamA',
      );

      expect(game.isValid(), isTrue);
    });

    test('isValid returns false for empty sets', () {
      const game = IndividualGame(
        gameNumber: 1,
        sets: [],
        winner: 'teamA',
      );

      expect(game.isValid(), isFalse);
    });

    test('setsWon returns correct counts', () {
      const game = IndividualGame(
        gameNumber: 1,
        sets: [
          SetScore(teamAPoints: 21, teamBPoints: 18, setNumber: 1),
          SetScore(teamAPoints: 18, teamBPoints: 21, setNumber: 2),
          SetScore(teamAPoints: 21, teamBPoints: 19, setNumber: 3),
        ],
        winner: 'teamA',
      );

      expect(game.setsWon['teamA'], 2);
      expect(game.setsWon['teamB'], 1);
    });
  });

  group('GameResult', () {
    test('isValid returns true for valid result', () {
      const result = GameResult(
        games: [
          IndividualGame(
            gameNumber: 1,
            sets: [SetScore(teamAPoints: 21, teamBPoints: 18, setNumber: 1)],
            winner: 'teamA',
          ),
          IndividualGame(
            gameNumber: 2,
            sets: [SetScore(teamAPoints: 21, teamBPoints: 15, setNumber: 1)],
            winner: 'teamA',
          ),
        ],
        overallWinner: 'teamA',
      );

      expect(result.isValid(), isTrue);
    });

    test('isValid returns false for empty games', () {
      const result = GameResult(
        games: [],
        overallWinner: 'teamA',
      );

      expect(result.isValid(), isFalse);
    });

    test('gamesWon returns correct counts', () {
      const result = GameResult(
        games: [
          IndividualGame(
            gameNumber: 1,
            sets: [SetScore(teamAPoints: 21, teamBPoints: 18, setNumber: 1)],
            winner: 'teamA',
          ),
          IndividualGame(
            gameNumber: 2,
            sets: [SetScore(teamAPoints: 18, teamBPoints: 21, setNumber: 1)],
            winner: 'teamB',
          ),
          IndividualGame(
            gameNumber: 3,
            sets: [SetScore(teamAPoints: 21, teamBPoints: 15, setNumber: 1)],
            winner: 'teamA',
          ),
        ],
        overallWinner: 'teamA',
      );

      expect(result.gamesWon['teamA'], 2);
      expect(result.gamesWon['teamB'], 1);
    });

    test('totalGames returns correct count', () {
      const result = GameResult(
        games: [
          IndividualGame(
            gameNumber: 1,
            sets: [SetScore(teamAPoints: 21, teamBPoints: 18, setNumber: 1)],
            winner: 'teamA',
          ),
          IndividualGame(
            gameNumber: 2,
            sets: [SetScore(teamAPoints: 21, teamBPoints: 15, setNumber: 1)],
            winner: 'teamA',
          ),
        ],
        overallWinner: 'teamA',
      );

      expect(result.totalGames, 2);
    });

    test('scoreDescription returns correct format', () {
      const result = GameResult(
        games: [
          IndividualGame(
            gameNumber: 1,
            sets: [SetScore(teamAPoints: 21, teamBPoints: 18, setNumber: 1)],
            winner: 'teamA',
          ),
          IndividualGame(
            gameNumber: 2,
            sets: [SetScore(teamAPoints: 18, teamBPoints: 21, setNumber: 1)],
            winner: 'teamB',
          ),
          IndividualGame(
            gameNumber: 3,
            sets: [SetScore(teamAPoints: 21, teamBPoints: 15, setNumber: 1)],
            winner: 'teamA',
          ),
        ],
        overallWinner: 'teamA',
      );

      expect(result.scoreDescription, '2-1');
    });
  });

  group('TimestampConverter', () {
    const converter = TimestampConverter();

    test('fromJson handles null', () {
      expect(converter.fromJson(null), isNull);
    });

    test('fromJson handles Timestamp', () {
      final now = DateTime.now();
      final timestamp = Timestamp.fromDate(now);

      final result = converter.fromJson(timestamp);

      expect(result, isNotNull);
      expect(result!.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
    });

    test('fromJson handles String', () {
      final now = DateTime.now();

      final result = converter.fromJson(now.toIso8601String());

      expect(result, isNotNull);
    });

    test('fromJson handles int (milliseconds)', () {
      final now = DateTime.now();

      final result = converter.fromJson(now.millisecondsSinceEpoch);

      expect(result, isNotNull);
      expect(result!.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
    });

    test('toJson returns null for null', () {
      expect(converter.toJson(null), isNull);
    });

    test('toJson returns Timestamp for DateTime', () {
      final now = DateTime.now();

      final result = converter.toJson(now);

      expect(result, isA<Timestamp>());
    });
  });
}
