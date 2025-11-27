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
