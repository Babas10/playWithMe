// Tests GroupInviteLinkModel serialization, business logic, and Firestore conversion.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/group_invite_link_model.dart';

void main() {
  group('GroupInviteLinkModel', () {
    final testCreatedAt = DateTime(2025, 6, 15, 10, 30);
    final testExpiresAt = DateTime(2025, 7, 15, 10, 30);

    GroupInviteLinkModel createTestInvite({
      String id = 'invite-123',
      String token = 'abc123def456ghi789jkl012mno345pq',
      String createdBy = 'user-789',
      DateTime? createdAt,
      DateTime? expiresAt,
      bool revoked = false,
      int? usageLimit,
      int usageCount = 0,
      String groupId = 'group-456',
      String inviteType = 'group_link',
    }) {
      return GroupInviteLinkModel(
        id: id,
        token: token,
        createdBy: createdBy,
        createdAt: createdAt ?? testCreatedAt,
        expiresAt: expiresAt,
        revoked: revoked,
        usageLimit: usageLimit,
        usageCount: usageCount,
        groupId: groupId,
        inviteType: inviteType,
      );
    }

    group('constructor', () {
      test('creates instance with required fields only', () {
        final invite = GroupInviteLinkModel(
          id: 'invite-123',
          token: 'abc123def456ghi789jkl012mno345pq',
          createdBy: 'user-789',
          createdAt: testCreatedAt,
          groupId: 'group-456',
        );

        expect(invite.id, 'invite-123');
        expect(invite.token, 'abc123def456ghi789jkl012mno345pq');
        expect(invite.createdBy, 'user-789');
        expect(invite.createdAt, testCreatedAt);
        expect(invite.groupId, 'group-456');
      });

      test('defaults revoked to false', () {
        final invite = createTestInvite();
        expect(invite.revoked, isFalse);
      });

      test('defaults usageCount to 0', () {
        final invite = createTestInvite();
        expect(invite.usageCount, 0);
      });

      test('defaults inviteType to group_link', () {
        final invite = createTestInvite();
        expect(invite.inviteType, 'group_link');
      });

      test('defaults expiresAt to null', () {
        final invite = createTestInvite();
        expect(invite.expiresAt, isNull);
      });

      test('defaults usageLimit to null', () {
        final invite = createTestInvite();
        expect(invite.usageLimit, isNull);
      });

      test('creates instance with all fields including optional', () {
        final invite = createTestInvite(
          expiresAt: testExpiresAt,
          revoked: true,
          usageLimit: 10,
          usageCount: 5,
        );

        expect(invite.expiresAt, testExpiresAt);
        expect(invite.revoked, isTrue);
        expect(invite.usageLimit, 10);
        expect(invite.usageCount, 5);
      });
    });

    group('fromJson', () {
      test('deserializes JSON with Timestamp for createdAt', () {
        final json = {
          'id': 'invite-123',
          'token': 'abc123def456ghi789jkl012mno345pq',
          'createdBy': 'user-789',
          'createdAt': Timestamp.fromDate(testCreatedAt),
          'revoked': false,
          'usageCount': 0,
          'groupId': 'group-456',
          'inviteType': 'group_link',
        };

        final invite = GroupInviteLinkModel.fromJson(json);

        expect(invite.id, 'invite-123');
        expect(invite.createdAt, testCreatedAt);
      });

      test('deserializes JSON with int timestamp for createdAt', () {
        final json = {
          'id': 'invite-123',
          'token': 'abc123def456ghi789jkl012mno345pq',
          'createdBy': 'user-789',
          'createdAt': testCreatedAt.millisecondsSinceEpoch,
          'revoked': false,
          'usageCount': 0,
          'groupId': 'group-456',
          'inviteType': 'group_link',
        };

        final invite = GroupInviteLinkModel.fromJson(json);

        expect(invite.createdAt, testCreatedAt);
      });

      test('deserializes JSON with ISO string for createdAt', () {
        final json = {
          'id': 'invite-123',
          'token': 'abc123def456ghi789jkl012mno345pq',
          'createdBy': 'user-789',
          'createdAt': testCreatedAt.toIso8601String(),
          'revoked': false,
          'usageCount': 0,
          'groupId': 'group-456',
          'inviteType': 'group_link',
        };

        final invite = GroupInviteLinkModel.fromJson(json);

        expect(invite.createdAt, testCreatedAt);
      });

      test('deserializes JSON with expiresAt Timestamp when present', () {
        final json = {
          'id': 'invite-123',
          'token': 'abc123def456ghi789jkl012mno345pq',
          'createdBy': 'user-789',
          'createdAt': Timestamp.fromDate(testCreatedAt),
          'expiresAt': Timestamp.fromDate(testExpiresAt),
          'revoked': false,
          'usageCount': 0,
          'groupId': 'group-456',
          'inviteType': 'group_link',
        };

        final invite = GroupInviteLinkModel.fromJson(json);

        expect(invite.expiresAt, testExpiresAt);
      });

      test('deserializes JSON with null expiresAt', () {
        final json = {
          'id': 'invite-123',
          'token': 'abc123def456ghi789jkl012mno345pq',
          'createdBy': 'user-789',
          'createdAt': Timestamp.fromDate(testCreatedAt),
          'expiresAt': null,
          'revoked': false,
          'usageCount': 0,
          'groupId': 'group-456',
          'inviteType': 'group_link',
        };

        final invite = GroupInviteLinkModel.fromJson(json);

        expect(invite.expiresAt, isNull);
      });

      test('deserializes JSON with usageLimit when present', () {
        final json = {
          'id': 'invite-123',
          'token': 'abc123def456ghi789jkl012mno345pq',
          'createdBy': 'user-789',
          'createdAt': Timestamp.fromDate(testCreatedAt),
          'revoked': false,
          'usageLimit': 50,
          'usageCount': 10,
          'groupId': 'group-456',
          'inviteType': 'group_link',
        };

        final invite = GroupInviteLinkModel.fromJson(json);

        expect(invite.usageLimit, 50);
        expect(invite.usageCount, 10);
      });

      test('deserializes JSON with null usageLimit', () {
        final json = {
          'id': 'invite-123',
          'token': 'abc123def456ghi789jkl012mno345pq',
          'createdBy': 'user-789',
          'createdAt': Timestamp.fromDate(testCreatedAt),
          'revoked': false,
          'usageLimit': null,
          'usageCount': 0,
          'groupId': 'group-456',
          'inviteType': 'group_link',
        };

        final invite = GroupInviteLinkModel.fromJson(json);

        expect(invite.usageLimit, isNull);
      });
    });

    group('toJson', () {
      test('serializes all fields to JSON', () {
        final invite = createTestInvite(
          expiresAt: testExpiresAt,
          usageLimit: 10,
          usageCount: 3,
        );

        final json = invite.toJson();

        expect(json['id'], 'invite-123');
        expect(json['token'], 'abc123def456ghi789jkl012mno345pq');
        expect(json['createdBy'], 'user-789');
        expect(json['revoked'], false);
        expect(json['usageLimit'], 10);
        expect(json['usageCount'], 3);
        expect(json['groupId'], 'group-456');
        expect(json['inviteType'], 'group_link');
      });

      test('converts createdAt to Timestamp', () {
        final invite = createTestInvite();

        final json = invite.toJson();

        expect(json['createdAt'], isA<Timestamp>());
        expect((json['createdAt'] as Timestamp).toDate(), testCreatedAt);
      });

      test('converts expiresAt to Timestamp when present', () {
        final invite = createTestInvite(expiresAt: testExpiresAt);

        final json = invite.toJson();

        expect(json['expiresAt'], isA<Timestamp>());
        expect((json['expiresAt'] as Timestamp).toDate(), testExpiresAt);
      });

      test('expiresAt is null when not set', () {
        final invite = createTestInvite();

        final json = invite.toJson();

        expect(json['expiresAt'], isNull);
      });

      test('usageLimit is null when not set', () {
        final invite = createTestInvite();

        final json = invite.toJson();

        expect(json['usageLimit'], isNull);
      });
    });

    group('toFirestore', () {
      test('excludes id from Firestore data', () {
        final invite = createTestInvite();

        final firestoreData = invite.toFirestore();

        expect(firestoreData.containsKey('id'), isFalse);
      });

      test('includes all other fields', () {
        final invite = createTestInvite(
          expiresAt: testExpiresAt,
          usageLimit: 10,
          usageCount: 3,
        );

        final firestoreData = invite.toFirestore();

        expect(firestoreData['token'], 'abc123def456ghi789jkl012mno345pq');
        expect(firestoreData['createdBy'], 'user-789');
        expect(firestoreData['revoked'], false);
        expect(firestoreData['usageLimit'], 10);
        expect(firestoreData['usageCount'], 3);
        expect(firestoreData['groupId'], 'group-456');
        expect(firestoreData['inviteType'], 'group_link');
        expect(firestoreData['createdAt'], isA<Timestamp>());
        expect(firestoreData['expiresAt'], isA<Timestamp>());
      });

      test('converts DateTime fields to Timestamp', () {
        final invite = createTestInvite(expiresAt: testExpiresAt);

        final firestoreData = invite.toFirestore();

        expect(firestoreData['createdAt'], isA<Timestamp>());
        expect(firestoreData['expiresAt'], isA<Timestamp>());
        expect(
          (firestoreData['createdAt'] as Timestamp).toDate(),
          testCreatedAt,
        );
        expect(
          (firestoreData['expiresAt'] as Timestamp).toDate(),
          testExpiresAt,
        );
      });
    });

    group('isExpired', () {
      test('returns false when expiresAt is null', () {
        final invite = createTestInvite(expiresAt: null);

        expect(invite.isExpired, isFalse);
      });

      test('returns false when expiresAt is in the future', () {
        final invite = createTestInvite(
          expiresAt: DateTime.now().add(const Duration(days: 7)),
        );

        expect(invite.isExpired, isFalse);
      });

      test('returns true when expiresAt is in the past', () {
        final invite = createTestInvite(
          expiresAt: DateTime.now().subtract(const Duration(days: 1)),
        );

        expect(invite.isExpired, isTrue);
      });
    });

    group('isRevoked', () {
      test('returns false when revoked is false', () {
        final invite = createTestInvite(revoked: false);

        expect(invite.isRevoked, isFalse);
      });

      test('returns true when revoked is true', () {
        final invite = createTestInvite(revoked: true);

        expect(invite.isRevoked, isTrue);
      });
    });

    group('isUsageLimitReached', () {
      test('returns false when usageLimit is null (unlimited)', () {
        final invite = createTestInvite(usageLimit: null, usageCount: 100);

        expect(invite.isUsageLimitReached, isFalse);
      });

      test('returns false when usageCount is below usageLimit', () {
        final invite = createTestInvite(usageLimit: 10, usageCount: 5);

        expect(invite.isUsageLimitReached, isFalse);
      });

      test('returns true when usageCount equals usageLimit', () {
        final invite = createTestInvite(usageLimit: 10, usageCount: 10);

        expect(invite.isUsageLimitReached, isTrue);
      });

      test('returns true when usageCount exceeds usageLimit', () {
        final invite = createTestInvite(usageLimit: 10, usageCount: 15);

        expect(invite.isUsageLimitReached, isTrue);
      });
    });

    group('isActive', () {
      test('returns true when not expired, not revoked, and limit not reached',
          () {
        final invite = createTestInvite(
          expiresAt: DateTime.now().add(const Duration(days: 7)),
          revoked: false,
          usageLimit: 10,
          usageCount: 3,
        );

        expect(invite.isActive, isTrue);
      });

      test('returns true when no expiration and no usage limit', () {
        final invite = createTestInvite(
          expiresAt: null,
          revoked: false,
          usageLimit: null,
          usageCount: 100,
        );

        expect(invite.isActive, isTrue);
      });

      test('returns false when expired', () {
        final invite = createTestInvite(
          expiresAt: DateTime.now().subtract(const Duration(days: 1)),
          revoked: false,
          usageLimit: null,
        );

        expect(invite.isActive, isFalse);
      });

      test('returns false when revoked', () {
        final invite = createTestInvite(
          expiresAt: DateTime.now().add(const Duration(days: 7)),
          revoked: true,
          usageLimit: null,
        );

        expect(invite.isActive, isFalse);
      });

      test('returns false when usage limit reached', () {
        final invite = createTestInvite(
          expiresAt: DateTime.now().add(const Duration(days: 7)),
          revoked: false,
          usageLimit: 5,
          usageCount: 5,
        );

        expect(invite.isActive, isFalse);
      });

      test('returns false when expired and revoked and limit reached', () {
        final invite = createTestInvite(
          expiresAt: DateTime.now().subtract(const Duration(days: 1)),
          revoked: true,
          usageLimit: 5,
          usageCount: 5,
        );

        expect(invite.isActive, isFalse);
      });
    });

    group('remainingUses', () {
      test('returns null when usageLimit is null (unlimited)', () {
        final invite = createTestInvite(usageLimit: null, usageCount: 100);

        expect(invite.remainingUses, isNull);
      });

      test('returns correct remaining count', () {
        final invite = createTestInvite(usageLimit: 10, usageCount: 3);

        expect(invite.remainingUses, 7);
      });

      test('returns 0 when limit reached', () {
        final invite = createTestInvite(usageLimit: 10, usageCount: 10);

        expect(invite.remainingUses, 0);
      });

      test('returns negative when count exceeds limit', () {
        final invite = createTestInvite(usageLimit: 10, usageCount: 12);

        expect(invite.remainingUses, -2);
      });

      test('returns full limit when usageCount is 0', () {
        final invite = createTestInvite(usageLimit: 25, usageCount: 0);

        expect(invite.remainingUses, 25);
      });
    });

    group('copyWith', () {
      test('creates copy with updated token', () {
        final invite = createTestInvite();

        final copy = invite.copyWith(token: 'new-token-value');

        expect(copy.token, 'new-token-value');
        expect(copy.id, invite.id);
        expect(copy.groupId, invite.groupId);
      });

      test('creates copy with updated revoked status', () {
        final invite = createTestInvite(revoked: false);

        final copy = invite.copyWith(revoked: true);

        expect(copy.revoked, isTrue);
        expect(copy.id, invite.id);
      });

      test('creates copy with updated usageCount', () {
        final invite = createTestInvite(usageCount: 5);

        final copy = invite.copyWith(usageCount: 6);

        expect(copy.usageCount, 6);
        expect(copy.usageLimit, invite.usageLimit);
      });

      test('creates copy with multiple fields updated', () {
        final invite = createTestInvite();

        final copy = invite.copyWith(
          revoked: true,
          usageCount: 10,
          expiresAt: testExpiresAt,
        );

        expect(copy.revoked, isTrue);
        expect(copy.usageCount, 10);
        expect(copy.expiresAt, testExpiresAt);
        expect(copy.id, invite.id);
        expect(copy.token, invite.token);
        expect(copy.groupId, invite.groupId);
      });
    });

    group('equality', () {
      test('two invites with same data are equal', () {
        final invite1 = createTestInvite();
        final invite2 = createTestInvite();

        expect(invite1, invite2);
        expect(invite1.hashCode, invite2.hashCode);
      });

      test('two invites with different id are not equal', () {
        final invite1 = createTestInvite(id: 'invite-1');
        final invite2 = createTestInvite(id: 'invite-2');

        expect(invite1, isNot(invite2));
      });

      test('two invites with different token are not equal', () {
        final invite1 = createTestInvite(token: 'token-aaa');
        final invite2 = createTestInvite(token: 'token-bbb');

        expect(invite1, isNot(invite2));
      });

      test('two invites with different revoked status are not equal', () {
        final invite1 = createTestInvite(revoked: false);
        final invite2 = createTestInvite(revoked: true);

        expect(invite1, isNot(invite2));
      });

      test('two invites with different usageCount are not equal', () {
        final invite1 = createTestInvite(usageCount: 0);
        final invite2 = createTestInvite(usageCount: 5);

        expect(invite1, isNot(invite2));
      });
    });

    group('JSON round trip', () {
      test('toJson then fromJson preserves all fields', () {
        final original = createTestInvite(
          expiresAt: testExpiresAt,
          revoked: true,
          usageLimit: 50,
          usageCount: 25,
        );

        final json = original.toJson();
        final restored = GroupInviteLinkModel.fromJson(json);

        expect(restored, original);
      });

      test('toJson then fromJson preserves null optional fields', () {
        final original = createTestInvite(
          expiresAt: null,
          usageLimit: null,
        );

        final json = original.toJson();
        final restored = GroupInviteLinkModel.fromJson(json);

        expect(restored.expiresAt, isNull);
        expect(restored.usageLimit, isNull);
        expect(restored, original);
      });
    });
  });
}
