// Tests FriendshipModel business logic, JSON serialization/deserialization, and entity conversion
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/friendship_model.dart';
import 'package:play_with_me/core/domain/entities/friendship_entity.dart';

void main() {
  group('FriendshipModel', () {
    late FriendshipModel testFriendship;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2024, 1, 15, 10, 0, 0);
      testFriendship = FriendshipModel(
        id: 'friendship-123',
        initiatorId: 'user-1',
        recipientId: 'user-2',
        status: FriendshipStatus.pending,
        createdAt: testDate,
        updatedAt: testDate,
        initiatorName: 'Alice',
        recipientName: 'Bob',
      );
    });

    group('Factory constructors', () {
      test('creates FriendshipModel with all required fields', () {
        expect(testFriendship.id, 'friendship-123');
        expect(testFriendship.initiatorId, 'user-1');
        expect(testFriendship.recipientId, 'user-2');
        expect(testFriendship.status, FriendshipStatus.pending);
        expect(testFriendship.createdAt, testDate);
        expect(testFriendship.updatedAt, testDate);
        expect(testFriendship.initiatorName, 'Alice');
        expect(testFriendship.recipientName, 'Bob');
      });

      test('fromFirestore creates FriendshipModel from DocumentSnapshot', () {
        final data = {
          'initiatorId': 'user-1',
          'recipientId': 'user-2',
          'status': 'pending',
          'createdAt': Timestamp.fromDate(testDate),
          'updatedAt': Timestamp.fromDate(testDate),
          'initiatorName': 'Alice',
          'recipientName': 'Bob',
        };

        final mockDoc = MockDocumentSnapshot('friendship-123', data);
        final friendship = FriendshipModel.fromFirestore(mockDoc);

        expect(friendship.id, 'friendship-123');
        expect(friendship.initiatorId, 'user-1');
        expect(friendship.recipientId, 'user-2');
        expect(friendship.status, FriendshipStatus.pending);
        expect(friendship.initiatorName, 'Alice');
        expect(friendship.recipientName, 'Bob');
      });

      test('fromEntity creates FriendshipModel from FriendshipEntity', () {
        final entity = FriendshipEntity(
          id: 'friendship-456',
          initiatorId: 'user-3',
          recipientId: 'user-4',
          status: FriendshipStatus.accepted,
          createdAt: testDate,
          updatedAt: testDate,
          initiatorName: 'Charlie',
          recipientName: 'David',
        );

        final model = FriendshipModel.fromEntity(entity);

        expect(model.id, entity.id);
        expect(model.initiatorId, entity.initiatorId);
        expect(model.recipientId, entity.recipientId);
        expect(model.status, entity.status);
        expect(model.createdAt, entity.createdAt);
        expect(model.updatedAt, entity.updatedAt);
        expect(model.initiatorName, entity.initiatorName);
        expect(model.recipientName, entity.recipientName);
      });
    });

    group('JSON serialization', () {
      test('toJson serializes all fields correctly', () {
        final json = testFriendship.toJson();

        expect(json['id'], 'friendship-123');
        expect(json['initiatorId'], 'user-1');
        expect(json['recipientId'], 'user-2');
        expect(json['status'], 'pending');
        expect(json['initiatorName'], 'Alice');
        expect(json['recipientName'], 'Bob');
        expect(json['createdAt'], isA<Timestamp>());
        expect(json['updatedAt'], isA<Timestamp>());
      });

      test('fromJson deserializes all fields correctly', () {
        final json = {
          'id': 'friendship-789',
          'initiatorId': 'user-5',
          'recipientId': 'user-6',
          'status': 'accepted',
          'createdAt': Timestamp.fromDate(testDate),
          'updatedAt': Timestamp.fromDate(testDate),
          'initiatorName': 'Eve',
          'recipientName': 'Frank',
        };

        final friendship = FriendshipModel.fromJson(json);

        expect(friendship.id, 'friendship-789');
        expect(friendship.initiatorId, 'user-5');
        expect(friendship.recipientId, 'user-6');
        expect(friendship.status, FriendshipStatus.accepted);
        expect(friendship.createdAt, testDate);
        expect(friendship.updatedAt, testDate);
        expect(friendship.initiatorName, 'Eve');
        expect(friendship.recipientName, 'Frank');
      });

      test('toFirestore excludes id field', () {
        final firestoreData = testFriendship.toFirestore();

        expect(firestoreData.containsKey('id'), false);
        expect(firestoreData['initiatorId'], 'user-1');
        expect(firestoreData['recipientId'], 'user-2');
        expect(firestoreData['status'], 'pending');
      });

      test('FriendshipStatus enum serializes correctly', () {
        final pendingJson = testFriendship.toJson();
        expect(pendingJson['status'], 'pending');

        final acceptedFriendship = testFriendship.copyWith(status: FriendshipStatus.accepted);
        final acceptedJson = acceptedFriendship.toJson();
        expect(acceptedJson['status'], 'accepted');

        final declinedFriendship = testFriendship.copyWith(status: FriendshipStatus.declined);
        final declinedJson = declinedFriendship.toJson();
        expect(declinedJson['status'], 'declined');
      });
    });

    group('Entity conversion', () {
      test('toEntity converts FriendshipModel to FriendshipEntity', () {
        final entity = testFriendship.toEntity();

        expect(entity, isA<FriendshipEntity>());
        expect(entity.id, testFriendship.id);
        expect(entity.initiatorId, testFriendship.initiatorId);
        expect(entity.recipientId, testFriendship.recipientId);
        expect(entity.status, testFriendship.status);
        expect(entity.createdAt, testFriendship.createdAt);
        expect(entity.updatedAt, testFriendship.updatedAt);
        expect(entity.initiatorName, testFriendship.initiatorName);
        expect(entity.recipientName, testFriendship.recipientName);
      });

      test('fromEntity and toEntity round-trip preserves data', () {
        final entity = testFriendship.toEntity();
        final model = FriendshipModel.fromEntity(entity);

        expect(model.id, testFriendship.id);
        expect(model.initiatorId, testFriendship.initiatorId);
        expect(model.recipientId, testFriendship.recipientId);
        expect(model.status, testFriendship.status);
        expect(model.createdAt, testFriendship.createdAt);
        expect(model.updatedAt, testFriendship.updatedAt);
        expect(model.initiatorName, testFriendship.initiatorName);
        expect(model.recipientName, testFriendship.recipientName);
      });
    });

    group('Status check methods', () {
      test('isPending returns true for pending status', () {
        expect(testFriendship.isPending, true);
        expect(testFriendship.isAccepted, false);
        expect(testFriendship.isDeclined, false);
      });

      test('isAccepted returns true for accepted status', () {
        final accepted = testFriendship.copyWith(status: FriendshipStatus.accepted);
        expect(accepted.isPending, false);
        expect(accepted.isAccepted, true);
        expect(accepted.isDeclined, false);
      });

      test('isDeclined returns true for declined status', () {
        final declined = testFriendship.copyWith(status: FriendshipStatus.declined);
        expect(declined.isPending, false);
        expect(declined.isAccepted, false);
        expect(declined.isDeclined, true);
      });
    });

    group('User identification methods', () {
      test('isInitiator returns true for initiator user', () {
        expect(testFriendship.isInitiator('user-1'), true);
        expect(testFriendship.isInitiator('user-2'), false);
        expect(testFriendship.isInitiator('user-3'), false);
      });

      test('isRecipient returns true for recipient user', () {
        expect(testFriendship.isRecipient('user-1'), false);
        expect(testFriendship.isRecipient('user-2'), true);
        expect(testFriendship.isRecipient('user-3'), false);
      });

      test('involves returns true for both users', () {
        expect(testFriendship.involves('user-1'), true);
        expect(testFriendship.involves('user-2'), true);
        expect(testFriendship.involves('user-3'), false);
      });

      test('getOtherUserId returns correct user ID', () {
        expect(testFriendship.getOtherUserId('user-1'), 'user-2');
        expect(testFriendship.getOtherUserId('user-2'), 'user-1');
        expect(testFriendship.getOtherUserId('user-3'), null);
      });

      test('getOtherUserName returns correct user name', () {
        expect(testFriendship.getOtherUserName('user-1'), 'Bob');
        expect(testFriendship.getOtherUserName('user-2'), 'Alice');
        expect(testFriendship.getOtherUserName('user-3'), null);
      });

      test('involvesBothUsers checks both directions', () {
        expect(testFriendship.involvesBothUsers('user-1', 'user-2'), true);
        expect(testFriendship.involvesBothUsers('user-2', 'user-1'), true);
        expect(testFriendship.involvesBothUsers('user-1', 'user-3'), false);
        expect(testFriendship.involvesBothUsers('user-3', 'user-4'), false);
      });
    });

    group('Status update methods', () {
      test('accept changes status from pending to accepted', () {
        expect(testFriendship.status, FriendshipStatus.pending);

        final accepted = testFriendship.accept();

        expect(accepted.status, FriendshipStatus.accepted);
        expect(accepted.updatedAt.isAfter(testFriendship.updatedAt), true);
      });

      test('accept does nothing if not pending', () {
        final alreadyAccepted = testFriendship.copyWith(status: FriendshipStatus.accepted);
        final result = alreadyAccepted.accept();

        expect(result, alreadyAccepted);
        expect(result.status, FriendshipStatus.accepted);
      });

      test('decline changes status from pending to declined', () {
        expect(testFriendship.status, FriendshipStatus.pending);

        final declined = testFriendship.decline();

        expect(declined.status, FriendshipStatus.declined);
        expect(declined.updatedAt.isAfter(testFriendship.updatedAt), true);
      });

      test('decline does nothing if not pending', () {
        final alreadyAccepted = testFriendship.copyWith(status: FriendshipStatus.accepted);
        final result = alreadyAccepted.decline();

        expect(result, alreadyAccepted);
        expect(result.status, FriendshipStatus.accepted);
      });

      test('declined friendship cannot be re-accepted', () {
        final declined = testFriendship.decline();
        final attempted = declined.accept();

        expect(attempted.status, FriendshipStatus.declined);
      });
    });

    group('Name update methods', () {
      test('updateUserName updates initiator name', () {
        final updated = testFriendship.updateUserName('user-1', 'Alice Updated');

        expect(updated.initiatorName, 'Alice Updated');
        expect(updated.recipientName, 'Bob');
        expect(updated.updatedAt.isAfter(testFriendship.updatedAt), true);
      });

      test('updateUserName updates recipient name', () {
        final updated = testFriendship.updateUserName('user-2', 'Bob Updated');

        expect(updated.initiatorName, 'Alice');
        expect(updated.recipientName, 'Bob Updated');
        expect(updated.updatedAt.isAfter(testFriendship.updatedAt), true);
      });

      test('updateUserName does nothing for non-involved user', () {
        final updated = testFriendship.updateUserName('user-3', 'Charlie');

        expect(updated, testFriendship);
        expect(updated.initiatorName, 'Alice');
        expect(updated.recipientName, 'Bob');
      });
    });

    group('Status transitions', () {
      test('pending can transition to accepted', () {
        final pending = testFriendship;
        expect(pending.isPending, true);

        final accepted = pending.accept();
        expect(accepted.isAccepted, true);
      });

      test('pending can transition to declined', () {
        final pending = testFriendship;
        expect(pending.isPending, true);

        final declined = pending.decline();
        expect(declined.isDeclined, true);
      });

      test('accepted cannot transition to declined', () {
        final accepted = testFriendship.accept();
        expect(accepted.isAccepted, true);

        final attempted = accepted.decline();
        expect(attempted.isAccepted, true); // Still accepted
      });

      test('declined cannot transition to accepted', () {
        final declined = testFriendship.decline();
        expect(declined.isDeclined, true);

        final attempted = declined.accept();
        expect(attempted.isDeclined, true); // Still declined
      });
    });

    group('TimestampConverter', () {
      test('converts Timestamp to DateTime', () {
        const converter = TimestampConverter();
        final timestamp = Timestamp.fromDate(testDate);

        final result = converter.fromJson(timestamp);

        expect(result, testDate);
      });

      test('converts String to DateTime', () {
        const converter = TimestampConverter();
        final dateString = testDate.toIso8601String();

        final result = converter.fromJson(dateString);

        expect(result, testDate);
      });

      test('converts int (milliseconds) to DateTime', () {
        const converter = TimestampConverter();
        final milliseconds = testDate.millisecondsSinceEpoch;

        final result = converter.fromJson(milliseconds);

        expect(result, testDate);
      });

      test('returns null for null input', () {
        const converter = TimestampConverter();

        final result = converter.fromJson(null);

        expect(result, null);
      });

      test('converts DateTime to Timestamp', () {
        const converter = TimestampConverter();

        final result = converter.toJson(testDate);

        expect(result, isA<Timestamp>());
        expect((result as Timestamp).toDate(), testDate);
      });

      test('returns null when converting null DateTime', () {
        const converter = TimestampConverter();

        final result = converter.toJson(null);

        expect(result, null);
      });
    });

    group('Edge cases', () {
      test('handles same user as initiator and recipient in queries', () {
        final sameUserFriendship = testFriendship.copyWith(
          initiatorId: 'user-1',
          recipientId: 'user-1',
        );

        expect(sameUserFriendship.involves('user-1'), true);
        expect(sameUserFriendship.getOtherUserId('user-1'), 'user-1');
        expect(sameUserFriendship.involvesBothUsers('user-1', 'user-1'), true);
      });

      test('preserves all fields through copyWith', () {
        final updated = testFriendship.copyWith(
          status: FriendshipStatus.accepted,
        );

        expect(updated.id, testFriendship.id);
        expect(updated.initiatorId, testFriendship.initiatorId);
        expect(updated.recipientId, testFriendship.recipientId);
        expect(updated.status, FriendshipStatus.accepted);
        expect(updated.initiatorName, testFriendship.initiatorName);
        expect(updated.recipientName, testFriendship.recipientName);
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
