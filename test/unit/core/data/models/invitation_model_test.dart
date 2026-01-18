// Tests InvitationModel serialization, status methods, and TimestampConverter.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/invitation_model.dart';

void main() {
  group('InvitationModel', () {
    final testCreatedAt = DateTime(2024, 1, 15, 10, 30);
    final testRespondedAt = DateTime(2024, 1, 16, 14, 45);

    group('constructor', () {
      test('creates instance with required fields', () {
        final invitation = InvitationModel(
          id: 'inv-123',
          groupId: 'group-456',
          groupName: 'Beach Volleyball',
          invitedBy: 'user-789',
          inviterName: 'John Doe',
          invitedUserId: 'user-101',
          createdAt: testCreatedAt,
        );

        expect(invitation.id, 'inv-123');
        expect(invitation.groupId, 'group-456');
        expect(invitation.groupName, 'Beach Volleyball');
        expect(invitation.invitedBy, 'user-789');
        expect(invitation.inviterName, 'John Doe');
        expect(invitation.invitedUserId, 'user-101');
        expect(invitation.createdAt, testCreatedAt);
      });

      test('defaults status to pending', () {
        final invitation = InvitationModel(
          id: 'inv-123',
          groupId: 'group-456',
          groupName: 'Beach Volleyball',
          invitedBy: 'user-789',
          inviterName: 'John Doe',
          invitedUserId: 'user-101',
          createdAt: testCreatedAt,
        );

        expect(invitation.status, InvitationStatus.pending);
      });

      test('defaults respondedAt to null', () {
        final invitation = InvitationModel(
          id: 'inv-123',
          groupId: 'group-456',
          groupName: 'Beach Volleyball',
          invitedBy: 'user-789',
          inviterName: 'John Doe',
          invitedUserId: 'user-101',
          createdAt: testCreatedAt,
        );

        expect(invitation.respondedAt, isNull);
      });

      test('creates instance with all fields including optional', () {
        final invitation = InvitationModel(
          id: 'inv-123',
          groupId: 'group-456',
          groupName: 'Beach Volleyball',
          invitedBy: 'user-789',
          inviterName: 'John Doe',
          invitedUserId: 'user-101',
          status: InvitationStatus.accepted,
          createdAt: testCreatedAt,
          respondedAt: testRespondedAt,
        );

        expect(invitation.status, InvitationStatus.accepted);
        expect(invitation.respondedAt, testRespondedAt);
      });
    });

    group('fromJson', () {
      test('deserializes JSON with Timestamp for createdAt', () {
        final json = {
          'id': 'inv-123',
          'groupId': 'group-456',
          'groupName': 'Beach Volleyball',
          'invitedBy': 'user-789',
          'inviterName': 'John Doe',
          'invitedUserId': 'user-101',
          'status': 'pending',
          'createdAt': Timestamp.fromDate(testCreatedAt),
        };

        final invitation = InvitationModel.fromJson(json);

        expect(invitation.id, 'inv-123');
        expect(invitation.createdAt, testCreatedAt);
      });

      test('deserializes JSON with int timestamp for createdAt', () {
        final json = {
          'id': 'inv-123',
          'groupId': 'group-456',
          'groupName': 'Beach Volleyball',
          'invitedBy': 'user-789',
          'inviterName': 'John Doe',
          'invitedUserId': 'user-101',
          'status': 'pending',
          'createdAt': testCreatedAt.millisecondsSinceEpoch,
        };

        final invitation = InvitationModel.fromJson(json);

        expect(invitation.createdAt, testCreatedAt);
      });

      test('deserializes JSON with ISO string for createdAt', () {
        final json = {
          'id': 'inv-123',
          'groupId': 'group-456',
          'groupName': 'Beach Volleyball',
          'invitedBy': 'user-789',
          'inviterName': 'John Doe',
          'invitedUserId': 'user-101',
          'status': 'pending',
          'createdAt': testCreatedAt.toIso8601String(),
        };

        final invitation = InvitationModel.fromJson(json);

        expect(invitation.createdAt, testCreatedAt);
      });

      test('deserializes JSON with respondedAt when present', () {
        final json = {
          'id': 'inv-123',
          'groupId': 'group-456',
          'groupName': 'Beach Volleyball',
          'invitedBy': 'user-789',
          'inviterName': 'John Doe',
          'invitedUserId': 'user-101',
          'status': 'accepted',
          'createdAt': Timestamp.fromDate(testCreatedAt),
          'respondedAt': Timestamp.fromDate(testRespondedAt),
        };

        final invitation = InvitationModel.fromJson(json);

        expect(invitation.respondedAt, testRespondedAt);
      });

      test('deserializes all InvitationStatus values', () {
        for (final status in InvitationStatus.values) {
          final json = {
            'id': 'inv-123',
            'groupId': 'group-456',
            'groupName': 'Beach Volleyball',
            'invitedBy': 'user-789',
            'inviterName': 'John Doe',
            'invitedUserId': 'user-101',
            'status': status.name,
            'createdAt': Timestamp.fromDate(testCreatedAt),
          };

          final invitation = InvitationModel.fromJson(json);
          expect(invitation.status, status);
        }
      });
    });

    group('toJson', () {
      test('serializes all fields to JSON', () {
        final invitation = InvitationModel(
          id: 'inv-123',
          groupId: 'group-456',
          groupName: 'Beach Volleyball',
          invitedBy: 'user-789',
          inviterName: 'John Doe',
          invitedUserId: 'user-101',
          status: InvitationStatus.pending,
          createdAt: testCreatedAt,
        );

        final json = invitation.toJson();

        expect(json['id'], 'inv-123');
        expect(json['groupId'], 'group-456');
        expect(json['groupName'], 'Beach Volleyball');
        expect(json['invitedBy'], 'user-789');
        expect(json['inviterName'], 'John Doe');
        expect(json['invitedUserId'], 'user-101');
        expect(json['status'], 'pending');
      });

      test('converts createdAt to Timestamp', () {
        final invitation = InvitationModel(
          id: 'inv-123',
          groupId: 'group-456',
          groupName: 'Beach Volleyball',
          invitedBy: 'user-789',
          inviterName: 'John Doe',
          invitedUserId: 'user-101',
          createdAt: testCreatedAt,
        );

        final json = invitation.toJson();

        expect(json['createdAt'], isA<Timestamp>());
        expect((json['createdAt'] as Timestamp).toDate(), testCreatedAt);
      });

      test('converts respondedAt to Timestamp when present', () {
        final invitation = InvitationModel(
          id: 'inv-123',
          groupId: 'group-456',
          groupName: 'Beach Volleyball',
          invitedBy: 'user-789',
          inviterName: 'John Doe',
          invitedUserId: 'user-101',
          createdAt: testCreatedAt,
          respondedAt: testRespondedAt,
        );

        final json = invitation.toJson();

        expect(json['respondedAt'], isA<Timestamp>());
        expect((json['respondedAt'] as Timestamp).toDate(), testRespondedAt);
      });

      test('respondedAt is null when not set', () {
        final invitation = InvitationModel(
          id: 'inv-123',
          groupId: 'group-456',
          groupName: 'Beach Volleyball',
          invitedBy: 'user-789',
          inviterName: 'John Doe',
          invitedUserId: 'user-101',
          createdAt: testCreatedAt,
        );

        final json = invitation.toJson();

        expect(json['respondedAt'], isNull);
      });
    });

    group('toFirestore', () {
      test('excludes id from Firestore data', () {
        final invitation = InvitationModel(
          id: 'inv-123',
          groupId: 'group-456',
          groupName: 'Beach Volleyball',
          invitedBy: 'user-789',
          inviterName: 'John Doe',
          invitedUserId: 'user-101',
          createdAt: testCreatedAt,
        );

        final firestoreData = invitation.toFirestore();

        expect(firestoreData.containsKey('id'), isFalse);
      });

      test('includes all other fields', () {
        final invitation = InvitationModel(
          id: 'inv-123',
          groupId: 'group-456',
          groupName: 'Beach Volleyball',
          invitedBy: 'user-789',
          inviterName: 'John Doe',
          invitedUserId: 'user-101',
          status: InvitationStatus.pending,
          createdAt: testCreatedAt,
        );

        final firestoreData = invitation.toFirestore();

        expect(firestoreData['groupId'], 'group-456');
        expect(firestoreData['groupName'], 'Beach Volleyball');
        expect(firestoreData['invitedBy'], 'user-789');
        expect(firestoreData['inviterName'], 'John Doe');
        expect(firestoreData['invitedUserId'], 'user-101');
        expect(firestoreData['status'], 'pending');
        expect(firestoreData['createdAt'], isA<Timestamp>());
      });

      test('converts DateTime fields to Timestamp', () {
        final invitation = InvitationModel(
          id: 'inv-123',
          groupId: 'group-456',
          groupName: 'Beach Volleyball',
          invitedBy: 'user-789',
          inviterName: 'John Doe',
          invitedUserId: 'user-101',
          createdAt: testCreatedAt,
          respondedAt: testRespondedAt,
        );

        final firestoreData = invitation.toFirestore();

        expect(firestoreData['createdAt'], isA<Timestamp>());
        expect(firestoreData['respondedAt'], isA<Timestamp>());
        expect(
          (firestoreData['createdAt'] as Timestamp).toDate(),
          testCreatedAt,
        );
        expect(
          (firestoreData['respondedAt'] as Timestamp).toDate(),
          testRespondedAt,
        );
      });
    });

    group('status getters', () {
      test('isPending returns true when status is pending', () {
        final invitation = InvitationModel(
          id: 'inv-123',
          groupId: 'group-456',
          groupName: 'Beach Volleyball',
          invitedBy: 'user-789',
          inviterName: 'John Doe',
          invitedUserId: 'user-101',
          status: InvitationStatus.pending,
          createdAt: testCreatedAt,
        );

        expect(invitation.isPending, isTrue);
        expect(invitation.isAccepted, isFalse);
        expect(invitation.isDeclined, isFalse);
      });

      test('isAccepted returns true when status is accepted', () {
        final invitation = InvitationModel(
          id: 'inv-123',
          groupId: 'group-456',
          groupName: 'Beach Volleyball',
          invitedBy: 'user-789',
          inviterName: 'John Doe',
          invitedUserId: 'user-101',
          status: InvitationStatus.accepted,
          createdAt: testCreatedAt,
        );

        expect(invitation.isPending, isFalse);
        expect(invitation.isAccepted, isTrue);
        expect(invitation.isDeclined, isFalse);
      });

      test('isDeclined returns true when status is declined', () {
        final invitation = InvitationModel(
          id: 'inv-123',
          groupId: 'group-456',
          groupName: 'Beach Volleyball',
          invitedBy: 'user-789',
          inviterName: 'John Doe',
          invitedUserId: 'user-101',
          status: InvitationStatus.declined,
          createdAt: testCreatedAt,
        );

        expect(invitation.isPending, isFalse);
        expect(invitation.isAccepted, isFalse);
        expect(invitation.isDeclined, isTrue);
      });
    });

    group('accept', () {
      test('returns new invitation with accepted status', () {
        final invitation = InvitationModel(
          id: 'inv-123',
          groupId: 'group-456',
          groupName: 'Beach Volleyball',
          invitedBy: 'user-789',
          inviterName: 'John Doe',
          invitedUserId: 'user-101',
          status: InvitationStatus.pending,
          createdAt: testCreatedAt,
        );

        final acceptedInvitation = invitation.accept();

        expect(acceptedInvitation.status, InvitationStatus.accepted);
        expect(acceptedInvitation.isAccepted, isTrue);
      });

      test('sets respondedAt to current time', () {
        final invitation = InvitationModel(
          id: 'inv-123',
          groupId: 'group-456',
          groupName: 'Beach Volleyball',
          invitedBy: 'user-789',
          inviterName: 'John Doe',
          invitedUserId: 'user-101',
          status: InvitationStatus.pending,
          createdAt: testCreatedAt,
        );

        final before = DateTime.now();
        final acceptedInvitation = invitation.accept();
        final after = DateTime.now();

        expect(acceptedInvitation.respondedAt, isNotNull);
        expect(acceptedInvitation.respondedAt!.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
        expect(acceptedInvitation.respondedAt!.isBefore(after.add(const Duration(seconds: 1))), isTrue);
      });

      test('preserves other fields unchanged', () {
        final invitation = InvitationModel(
          id: 'inv-123',
          groupId: 'group-456',
          groupName: 'Beach Volleyball',
          invitedBy: 'user-789',
          inviterName: 'John Doe',
          invitedUserId: 'user-101',
          status: InvitationStatus.pending,
          createdAt: testCreatedAt,
        );

        final acceptedInvitation = invitation.accept();

        expect(acceptedInvitation.id, invitation.id);
        expect(acceptedInvitation.groupId, invitation.groupId);
        expect(acceptedInvitation.groupName, invitation.groupName);
        expect(acceptedInvitation.invitedBy, invitation.invitedBy);
        expect(acceptedInvitation.inviterName, invitation.inviterName);
        expect(acceptedInvitation.invitedUserId, invitation.invitedUserId);
        expect(acceptedInvitation.createdAt, invitation.createdAt);
      });

      test('does not modify original invitation', () {
        final invitation = InvitationModel(
          id: 'inv-123',
          groupId: 'group-456',
          groupName: 'Beach Volleyball',
          invitedBy: 'user-789',
          inviterName: 'John Doe',
          invitedUserId: 'user-101',
          status: InvitationStatus.pending,
          createdAt: testCreatedAt,
        );

        invitation.accept();

        expect(invitation.status, InvitationStatus.pending);
        expect(invitation.respondedAt, isNull);
      });
    });

    group('decline', () {
      test('returns new invitation with declined status', () {
        final invitation = InvitationModel(
          id: 'inv-123',
          groupId: 'group-456',
          groupName: 'Beach Volleyball',
          invitedBy: 'user-789',
          inviterName: 'John Doe',
          invitedUserId: 'user-101',
          status: InvitationStatus.pending,
          createdAt: testCreatedAt,
        );

        final declinedInvitation = invitation.decline();

        expect(declinedInvitation.status, InvitationStatus.declined);
        expect(declinedInvitation.isDeclined, isTrue);
      });

      test('sets respondedAt to current time', () {
        final invitation = InvitationModel(
          id: 'inv-123',
          groupId: 'group-456',
          groupName: 'Beach Volleyball',
          invitedBy: 'user-789',
          inviterName: 'John Doe',
          invitedUserId: 'user-101',
          status: InvitationStatus.pending,
          createdAt: testCreatedAt,
        );

        final before = DateTime.now();
        final declinedInvitation = invitation.decline();
        final after = DateTime.now();

        expect(declinedInvitation.respondedAt, isNotNull);
        expect(declinedInvitation.respondedAt!.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
        expect(declinedInvitation.respondedAt!.isBefore(after.add(const Duration(seconds: 1))), isTrue);
      });

      test('preserves other fields unchanged', () {
        final invitation = InvitationModel(
          id: 'inv-123',
          groupId: 'group-456',
          groupName: 'Beach Volleyball',
          invitedBy: 'user-789',
          inviterName: 'John Doe',
          invitedUserId: 'user-101',
          status: InvitationStatus.pending,
          createdAt: testCreatedAt,
        );

        final declinedInvitation = invitation.decline();

        expect(declinedInvitation.id, invitation.id);
        expect(declinedInvitation.groupId, invitation.groupId);
        expect(declinedInvitation.groupName, invitation.groupName);
        expect(declinedInvitation.invitedBy, invitation.invitedBy);
        expect(declinedInvitation.inviterName, invitation.inviterName);
        expect(declinedInvitation.invitedUserId, invitation.invitedUserId);
        expect(declinedInvitation.createdAt, invitation.createdAt);
      });

      test('does not modify original invitation', () {
        final invitation = InvitationModel(
          id: 'inv-123',
          groupId: 'group-456',
          groupName: 'Beach Volleyball',
          invitedBy: 'user-789',
          inviterName: 'John Doe',
          invitedUserId: 'user-101',
          status: InvitationStatus.pending,
          createdAt: testCreatedAt,
        );

        invitation.decline();

        expect(invitation.status, InvitationStatus.pending);
        expect(invitation.respondedAt, isNull);
      });
    });

    group('copyWith', () {
      test('creates copy with updated id', () {
        final invitation = InvitationModel(
          id: 'inv-123',
          groupId: 'group-456',
          groupName: 'Beach Volleyball',
          invitedBy: 'user-789',
          inviterName: 'John Doe',
          invitedUserId: 'user-101',
          createdAt: testCreatedAt,
        );

        final copy = invitation.copyWith(id: 'inv-999');

        expect(copy.id, 'inv-999');
        expect(copy.groupId, 'group-456');
      });

      test('creates copy with updated status', () {
        final invitation = InvitationModel(
          id: 'inv-123',
          groupId: 'group-456',
          groupName: 'Beach Volleyball',
          invitedBy: 'user-789',
          inviterName: 'John Doe',
          invitedUserId: 'user-101',
          createdAt: testCreatedAt,
        );

        final copy = invitation.copyWith(status: InvitationStatus.declined);

        expect(copy.status, InvitationStatus.declined);
        expect(copy.id, 'inv-123');
      });

      test('creates copy with multiple fields updated', () {
        final invitation = InvitationModel(
          id: 'inv-123',
          groupId: 'group-456',
          groupName: 'Beach Volleyball',
          invitedBy: 'user-789',
          inviterName: 'John Doe',
          invitedUserId: 'user-101',
          createdAt: testCreatedAt,
        );

        final copy = invitation.copyWith(
          groupName: 'Updated Group',
          status: InvitationStatus.accepted,
          respondedAt: testRespondedAt,
        );

        expect(copy.groupName, 'Updated Group');
        expect(copy.status, InvitationStatus.accepted);
        expect(copy.respondedAt, testRespondedAt);
        expect(copy.id, 'inv-123');
        expect(copy.groupId, 'group-456');
      });
    });

    group('equality', () {
      test('two invitations with same data are equal', () {
        final invitation1 = InvitationModel(
          id: 'inv-123',
          groupId: 'group-456',
          groupName: 'Beach Volleyball',
          invitedBy: 'user-789',
          inviterName: 'John Doe',
          invitedUserId: 'user-101',
          status: InvitationStatus.pending,
          createdAt: testCreatedAt,
        );

        final invitation2 = InvitationModel(
          id: 'inv-123',
          groupId: 'group-456',
          groupName: 'Beach Volleyball',
          invitedBy: 'user-789',
          inviterName: 'John Doe',
          invitedUserId: 'user-101',
          status: InvitationStatus.pending,
          createdAt: testCreatedAt,
        );

        expect(invitation1, invitation2);
        expect(invitation1.hashCode, invitation2.hashCode);
      });

      test('two invitations with different data are not equal', () {
        final invitation1 = InvitationModel(
          id: 'inv-123',
          groupId: 'group-456',
          groupName: 'Beach Volleyball',
          invitedBy: 'user-789',
          inviterName: 'John Doe',
          invitedUserId: 'user-101',
          createdAt: testCreatedAt,
        );

        final invitation2 = InvitationModel(
          id: 'inv-999',
          groupId: 'group-456',
          groupName: 'Beach Volleyball',
          invitedBy: 'user-789',
          inviterName: 'John Doe',
          invitedUserId: 'user-101',
          createdAt: testCreatedAt,
        );

        expect(invitation1, isNot(invitation2));
      });

      test('invitations with different status are not equal', () {
        final invitation1 = InvitationModel(
          id: 'inv-123',
          groupId: 'group-456',
          groupName: 'Beach Volleyball',
          invitedBy: 'user-789',
          inviterName: 'John Doe',
          invitedUserId: 'user-101',
          status: InvitationStatus.pending,
          createdAt: testCreatedAt,
        );

        final invitation2 = InvitationModel(
          id: 'inv-123',
          groupId: 'group-456',
          groupName: 'Beach Volleyball',
          invitedBy: 'user-789',
          inviterName: 'John Doe',
          invitedUserId: 'user-101',
          status: InvitationStatus.accepted,
          createdAt: testCreatedAt,
        );

        expect(invitation1, isNot(invitation2));
      });
    });
  });

  group('InvitationStatus', () {
    test('has three values', () {
      expect(InvitationStatus.values.length, 3);
    });

    test('values are pending, accepted, declined', () {
      expect(InvitationStatus.values, contains(InvitationStatus.pending));
      expect(InvitationStatus.values, contains(InvitationStatus.accepted));
      expect(InvitationStatus.values, contains(InvitationStatus.declined));
    });

    test('pending has index 0', () {
      expect(InvitationStatus.pending.index, 0);
    });

    test('accepted has index 1', () {
      expect(InvitationStatus.accepted.index, 1);
    });

    test('declined has index 2', () {
      expect(InvitationStatus.declined.index, 2);
    });
  });

  group('TimestampConverter', () {
    const converter = TimestampConverter();
    final testDate = DateTime(2024, 6, 15, 12, 30, 45);

    group('fromJson', () {
      test('converts Timestamp to DateTime', () {
        final timestamp = Timestamp.fromDate(testDate);
        final result = converter.fromJson(timestamp);
        expect(result, testDate);
      });

      test('converts int milliseconds to DateTime', () {
        final millis = testDate.millisecondsSinceEpoch;
        final result = converter.fromJson(millis);
        expect(result, testDate);
      });

      test('converts ISO string to DateTime', () {
        final isoString = testDate.toIso8601String();
        final result = converter.fromJson(isoString);
        expect(result, testDate);
      });

      test('throws exception for unknown type', () {
        expect(
          () => converter.fromJson(12.34),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Unknown type for timestamp'),
          )),
        );
      });

      test('throws exception for list type', () {
        expect(
          () => converter.fromJson([1, 2, 3]),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Unknown type for timestamp'),
          )),
        );
      });

      test('throws exception for map type', () {
        expect(
          () => converter.fromJson({'key': 'value'}),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Unknown type for timestamp'),
          )),
        );
      });
    });

    group('toJson', () {
      test('converts DateTime to Timestamp', () {
        final result = converter.toJson(testDate);
        expect(result, isA<Timestamp>());
        expect((result as Timestamp).toDate(), testDate);
      });

      test('preserves millisecond precision', () {
        final dateWithMillis = DateTime(2024, 6, 15, 12, 30, 45, 123);
        final result = converter.toJson(dateWithMillis);
        expect((result as Timestamp).toDate(), dateWithMillis);
      });
    });

    group('round trip', () {
      test('fromJson and toJson are inverse operations', () {
        final original = DateTime(2024, 12, 25, 18, 30, 0);
        final timestamp = converter.toJson(original);
        final restored = converter.fromJson(timestamp);
        expect(restored, original);
      });
    });
  });
}
