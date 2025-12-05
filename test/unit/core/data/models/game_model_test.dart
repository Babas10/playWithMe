// Tests GameModel toFirestore serialization to ensure DateTime fields convert to Timestamp
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/game_model.dart';

void main() {
  group('GameModel', () {
    group('toFirestore', () {
      test('converts DateTime fields to Timestamp', () {
        // Arrange
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

        // Act
        final firestoreData = game.toFirestore();

        // Assert - DateTime fields should be Timestamps
        expect(firestoreData['createdAt'], isA<Timestamp>());
        expect(firestoreData['scheduledAt'], isA<Timestamp>());

        // Verify timestamp values are correct
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
        // Arrange
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

        // Act
        final firestoreData = game.toFirestore();

        // Assert
        expect(firestoreData['updatedAt'], isA<Timestamp>());
        expect(firestoreData['startedAt'], isA<Timestamp>());
        expect(firestoreData['endedAt'], isA<Timestamp>());
      });

      test('excludes id from Firestore data', () {
        // Arrange
        final game = GameModel(
          id: 'test-game-789',
          title: 'Test Game',
          groupId: 'group-123',
          createdBy: 'user-123',
          createdAt: DateTime.now(),
          scheduledAt: DateTime.now(),
          location: const GameLocation(name: 'Beach Court'),
        );

        // Act
        final firestoreData = game.toFirestore();

        // Assert - id should not be in Firestore data
        expect(firestoreData.containsKey('id'), isFalse);
      });

      test('properly serializes nested GameLocation object', () {
        // Arrange
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

        // Act
        final firestoreData = game.toFirestore();

        // Assert
        expect(firestoreData['location'], isA<Map>());
        final location = firestoreData['location'] as Map;
        expect(location['name'], 'Sunset Beach');
        expect(location['address'], '123 Beach St');
        expect(location['latitude'], 34.0195);
        expect(location['longitude'], -118.4912);
      });

      test('includes all required fields', () {
        // Arrange
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

        // Act
        final firestoreData = game.toFirestore();

        // Assert
        expect(firestoreData['title'], 'Required Fields Test');
        expect(firestoreData['groupId'], 'group-123');
        expect(firestoreData['createdBy'], 'user-123');
        expect(firestoreData['status'], 'scheduled');
        expect(firestoreData['maxPlayers'], 8);
        expect(firestoreData['minPlayers'], 4);
      });

      test('properly serializes GameTeams object', () {
        // Arrange
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

        // Act
        final firestoreData = game.toFirestore();

        // Assert
        expect(firestoreData['teams'], isA<Map>());
        final teams = firestoreData['teams'] as Map;
        expect(teams['teamAPlayerIds'], ['player1', 'player2']);
        expect(teams['teamBPlayerIds'], ['player3', 'player4']);
      });

      test('properly serializes GameResult with sets and games', () {
        // Arrange
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

        // Act
        final firestoreData = game.toFirestore();

        // Assert
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
        // Arrange
        final game = GameModel(
          id: 'test-game-505',
          title: 'Test Game',
          groupId: 'group-123',
          createdBy: 'user-123',
          createdAt: DateTime.now(),
          scheduledAt: DateTime.now(),
          location: const GameLocation(name: 'Court'),
        );

        // Act
        final firestoreData = game.toFirestore();

        // Assert
        expect(firestoreData['eloCalculated'], false);
      });

      test('converts completedAt DateTime to Timestamp when present', () {
        // Arrange
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

        // Act
        final firestoreData = game.toFirestore();

        // Assert
        expect(firestoreData['completedAt'], isA<Timestamp>());
        final completedAtTimestamp = firestoreData['completedAt'] as Timestamp;
        expect(completedAtTimestamp.toDate(), equals(completedTime));
        expect(firestoreData['eloCalculated'], false);
      });

      test('serializes complete game with teams, result, and elo flag', () {
        // Arrange
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
          eloCalculated: false,
          completedAt: completedTime,
        );

        // Act
        final firestoreData = game.toFirestore();

        // Assert - Verify all result-related fields are present
        expect(firestoreData['teams'], isA<Map>());
        expect(firestoreData['result'], isA<Map>());
        expect(firestoreData['eloCalculated'], false);
        expect(firestoreData['completedAt'], isA<Timestamp>());
        expect(firestoreData['winnerId'], 'teamA');
      });
    });

    group('fromFirestore', () {
      test('deserializes Timestamp fields to DateTime', () {
        // Arrange
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

        // Act
        final game = GameModel.fromJson({
          ...firestoreDoc,
          'createdAt': (firestoreDoc['createdAt'] as Timestamp).toDate().toIso8601String(),
          'scheduledAt': (firestoreDoc['scheduledAt'] as Timestamp).toDate().toIso8601String(),
        });

        // Assert
        expect(game.createdAt, isA<DateTime>());
        expect(game.scheduledAt, isA<DateTime>());
      });
    });
  });
}
