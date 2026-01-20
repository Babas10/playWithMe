// Tests FriendshipEntity for serialization and equality.

import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/domain/entities/friendship_entity.dart';

void main() {
  group('FriendshipEntity', () {
    late DateTime testCreatedAt;
    late DateTime testUpdatedAt;
    late FriendshipEntity baseFriendship;

    setUp(() {
      testCreatedAt = DateTime(2024, 1, 15, 10, 30);
      testUpdatedAt = DateTime(2024, 1, 16, 14, 0);
      baseFriendship = FriendshipEntity(
        id: 'friendship-123',
        initiatorId: 'user-456',
        recipientId: 'user-789',
        initiatorName: 'John Doe',
        recipientName: 'Jane Smith',
        status: FriendshipStatus.pending,
        createdAt: testCreatedAt,
        updatedAt: testUpdatedAt,
      );
    });

    group('constructor', () {
      test('creates instance with all required fields', () {
        expect(baseFriendship.id, equals('friendship-123'));
        expect(baseFriendship.initiatorId, equals('user-456'));
        expect(baseFriendship.recipientId, equals('user-789'));
        expect(baseFriendship.initiatorName, equals('John Doe'));
        expect(baseFriendship.recipientName, equals('Jane Smith'));
        expect(baseFriendship.status, equals(FriendshipStatus.pending));
        expect(baseFriendship.createdAt, equals(testCreatedAt));
        expect(baseFriendship.updatedAt, equals(testUpdatedAt));
      });

      test('creates instance with accepted status', () {
        final friendship = FriendshipEntity(
          id: 'friendship-456',
          initiatorId: 'user-1',
          recipientId: 'user-2',
          initiatorName: 'Alice',
          recipientName: 'Bob',
          status: FriendshipStatus.accepted,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(friendship.status, equals(FriendshipStatus.accepted));
      });

      test('creates instance with declined status', () {
        final friendship = FriendshipEntity(
          id: 'friendship-789',
          initiatorId: 'user-3',
          recipientId: 'user-4',
          initiatorName: 'Charlie',
          recipientName: 'Diana',
          status: FriendshipStatus.declined,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(friendship.status, equals(FriendshipStatus.declined));
      });
    });

    group('fromJson', () {
      test('parses valid JSON with ISO string dates', () {
        final json = {
          'id': 'friendship-123',
          'initiatorId': 'user-456',
          'recipientId': 'user-789',
          'initiatorName': 'John Doe',
          'recipientName': 'Jane Smith',
          'status': 'pending',
          'createdAt': '2024-01-15T10:30:00.000',
          'updatedAt': '2024-01-16T14:00:00.000',
        };

        final friendship = FriendshipEntity.fromJson(json);

        expect(friendship.id, equals('friendship-123'));
        expect(friendship.initiatorId, equals('user-456'));
        expect(friendship.recipientId, equals('user-789'));
        expect(friendship.status, equals(FriendshipStatus.pending));
      });

      test('parses JSON with accepted status', () {
        final json = {
          'id': 'friendship-456',
          'initiatorId': 'user-1',
          'recipientId': 'user-2',
          'initiatorName': 'Alice',
          'recipientName': 'Bob',
          'status': 'accepted',
          'createdAt': '2024-01-15T10:30:00.000',
          'updatedAt': '2024-01-16T14:00:00.000',
        };

        final friendship = FriendshipEntity.fromJson(json);

        expect(friendship.status, equals(FriendshipStatus.accepted));
      });

      test('parses JSON with declined status', () {
        final json = {
          'id': 'friendship-789',
          'initiatorId': 'user-3',
          'recipientId': 'user-4',
          'initiatorName': 'Charlie',
          'recipientName': 'Diana',
          'status': 'declined',
          'createdAt': '2024-01-15T10:30:00.000',
          'updatedAt': '2024-01-16T14:00:00.000',
        };

        final friendship = FriendshipEntity.fromJson(json);

        expect(friendship.status, equals(FriendshipStatus.declined));
      });
    });

    group('toJson', () {
      test('serializes to JSON correctly', () {
        final json = baseFriendship.toJson();

        expect(json['id'], equals('friendship-123'));
        expect(json['initiatorId'], equals('user-456'));
        expect(json['recipientId'], equals('user-789'));
        expect(json['initiatorName'], equals('John Doe'));
        expect(json['recipientName'], equals('Jane Smith'));
        expect(json['status'], equals('pending'));
      });

      test('serializes accepted status correctly', () {
        final friendship = baseFriendship.copyWith(
          status: FriendshipStatus.accepted,
        );

        final json = friendship.toJson();

        expect(json['status'], equals('accepted'));
      });

      test('serializes declined status correctly', () {
        final friendship = baseFriendship.copyWith(
          status: FriendshipStatus.declined,
        );

        final json = friendship.toJson();

        expect(json['status'], equals('declined'));
      });
    });

    group('copyWith', () {
      test('creates copy with updated id', () {
        final copy = baseFriendship.copyWith(id: 'new-id');

        expect(copy.id, equals('new-id'));
        expect(copy.initiatorId, equals(baseFriendship.initiatorId));
      });

      test('creates copy with updated status', () {
        final copy = baseFriendship.copyWith(status: FriendshipStatus.accepted);

        expect(copy.status, equals(FriendshipStatus.accepted));
        expect(copy.id, equals(baseFriendship.id));
      });

      test('creates copy with updated names', () {
        final copy = baseFriendship.copyWith(
          initiatorName: 'New John',
          recipientName: 'New Jane',
        );

        expect(copy.initiatorName, equals('New John'));
        expect(copy.recipientName, equals('New Jane'));
      });

      test('creates copy with updated timestamps', () {
        final newCreatedAt = DateTime(2024, 2, 1);
        final newUpdatedAt = DateTime(2024, 2, 2);

        final copy = baseFriendship.copyWith(
          createdAt: newCreatedAt,
          updatedAt: newUpdatedAt,
        );

        expect(copy.createdAt, equals(newCreatedAt));
        expect(copy.updatedAt, equals(newUpdatedAt));
      });
    });

    group('equality', () {
      test('two friendships with same values are equal', () {
        final friendship1 = FriendshipEntity(
          id: 'friendship-123',
          initiatorId: 'user-456',
          recipientId: 'user-789',
          initiatorName: 'John Doe',
          recipientName: 'Jane Smith',
          status: FriendshipStatus.pending,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        final friendship2 = FriendshipEntity(
          id: 'friendship-123',
          initiatorId: 'user-456',
          recipientId: 'user-789',
          initiatorName: 'John Doe',
          recipientName: 'Jane Smith',
          status: FriendshipStatus.pending,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(friendship1, equals(friendship2));
      });

      test('two friendships with different id are not equal', () {
        final friendship1 = baseFriendship;
        final friendship2 = baseFriendship.copyWith(id: 'different-id');

        expect(friendship1, isNot(equals(friendship2)));
      });

      test('two friendships with different status are not equal', () {
        final friendship1 = baseFriendship;
        final friendship2 = baseFriendship.copyWith(
          status: FriendshipStatus.accepted,
        );

        expect(friendship1, isNot(equals(friendship2)));
      });
    });

    group('hashCode', () {
      test('same values produce same hashCode', () {
        final friendship1 = FriendshipEntity(
          id: 'friendship-123',
          initiatorId: 'user-456',
          recipientId: 'user-789',
          initiatorName: 'John Doe',
          recipientName: 'Jane Smith',
          status: FriendshipStatus.pending,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        final friendship2 = FriendshipEntity(
          id: 'friendship-123',
          initiatorId: 'user-456',
          recipientId: 'user-789',
          initiatorName: 'John Doe',
          recipientName: 'Jane Smith',
          status: FriendshipStatus.pending,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(friendship1.hashCode, equals(friendship2.hashCode));
      });
    });
  });

  group('FriendshipStatus', () {
    test('pending has correct JSON value', () {
      expect(FriendshipStatus.pending.name, equals('pending'));
    });

    test('accepted has correct JSON value', () {
      expect(FriendshipStatus.accepted.name, equals('accepted'));
    });

    test('declined has correct JSON value', () {
      expect(FriendshipStatus.declined.name, equals('declined'));
    });

    test('all statuses are defined', () {
      expect(FriendshipStatus.values.length, equals(3));
      expect(FriendshipStatus.values, contains(FriendshipStatus.pending));
      expect(FriendshipStatus.values, contains(FriendshipStatus.accepted));
      expect(FriendshipStatus.values, contains(FriendshipStatus.declined));
    });
  });
}
