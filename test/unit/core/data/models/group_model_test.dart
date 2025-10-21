// Tests all GroupModel business logic methods and JSON serialization/deserialization
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/group_model.dart';

void main() {
  group('GroupModel', () {
    late GroupModel testGroup;

    setUp(() {
      testGroup = GroupModel(
        id: 'test-group-123',
        name: 'Beach Volleyball Crew',
        description: 'Weekly beach volleyball games',
        createdBy: 'user-123',
        createdAt: DateTime(2024, 1, 1),
        memberIds: const ['user-123', 'user-456'],
        adminIds: const ['user-123'],
      );
    });

    group('Factory constructors', () {
      test('creates GroupModel with required fields only', () {
        final group = GroupModel(
          id: 'test-id',
          name: 'Test Group',
          createdBy: 'user-1',
          createdAt: DateTime(2024, 1, 1),
        );

        expect(group.id, 'test-id');
        expect(group.name, 'Test Group');
        expect(group.createdBy, 'user-1');
        expect(group.memberIds, isEmpty);
        expect(group.adminIds, isEmpty);
        expect(group.privacy, GroupPrivacy.private);
      });

      test('creates GroupModel with all fields', () {
        final group = GroupModel(
          id: 'test-id',
          name: 'Test Group',
          description: 'Test description',
          photoUrl: 'https://example.com/photo.jpg',
          createdBy: 'user-1',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 2),
          memberIds: const ['user-1', 'user-2'],
          adminIds: const ['user-1'],
          gameIds: const ['game-1'],
          privacy: GroupPrivacy.public,
          requiresApproval: true,
          maxMembers: 30,
          location: 'Santa Monica Beach',
          allowMembersToCreateGames: false,
          allowMembersToInviteOthers: false,
          notifyMembersOfNewGames: false,
          totalGamesPlayed: 10,
          lastActivity: DateTime(2024, 1, 3),
        );

        expect(group.id, 'test-id');
        expect(group.description, 'Test description');
        expect(group.photoUrl, 'https://example.com/photo.jpg');
        expect(group.privacy, GroupPrivacy.public);
        expect(group.requiresApproval, true);
        expect(group.maxMembers, 30);
        expect(group.location, 'Santa Monica Beach');
        expect(group.allowMembersToCreateGames, false);
        expect(group.totalGamesPlayed, 10);
      });
    });

    group('JSON serialization', () {
      test('toJson serializes all fields correctly', () {
        final json = testGroup.toJson();

        expect(json['id'], 'test-group-123');
        expect(json['name'], 'Beach Volleyball Crew');
        expect(json['description'], 'Weekly beach volleyball games');
        expect(json['createdBy'], 'user-123');
        expect(json['memberIds'], ['user-123', 'user-456']);
        expect(json['adminIds'], ['user-123']);
        expect(json['privacy'], 'private');
      });

      test('fromJson deserializes all fields correctly', () {
        // When deserializing from Firestore, dates come as Timestamps
        // but fromJson expects the converter to handle this
        final testDate = DateTime(2024, 1, 1);
        final group = GroupModel(
          id: 'group-1',
          name: 'Test Group',
          description: 'Test',
          createdBy: 'user-1',
          createdAt: testDate,
          memberIds: const ['user-1'],
          adminIds: const ['user-1'],
          privacy: GroupPrivacy.public,
        );

        // Convert to JSON and back
        final json = group.toJson();
        final deserialized = GroupModel.fromJson(json);

        expect(deserialized.id, 'group-1');
        expect(deserialized.name, 'Test Group');
        expect(deserialized.description, 'Test');
        expect(deserialized.privacy, GroupPrivacy.public);
        expect(deserialized.memberIds, ['user-1']);
        expect(deserialized.adminIds, ['user-1']);
      });

      test('toFirestore excludes id field', () {
        final firestoreData = testGroup.toFirestore();

        expect(firestoreData.containsKey('id'), false);
        expect(firestoreData['name'], 'Beach Volleyball Crew');
        expect(firestoreData['createdBy'], 'user-123');
      });
    });

    group('Member management methods', () {
      test('isMember returns true for members', () {
        expect(testGroup.isMember('user-123'), true);
        expect(testGroup.isMember('user-456'), true);
      });

      test('isMember returns false for non-members', () {
        expect(testGroup.isMember('user-789'), false);
      });

      test('isAdmin returns true for admins', () {
        expect(testGroup.isAdmin('user-123'), true);
      });

      test('isAdmin returns false for non-admins', () {
        expect(testGroup.isAdmin('user-456'), false);
      });

      test('isCreator returns true for creator', () {
        expect(testGroup.isCreator('user-123'), true);
      });

      test('isCreator returns false for non-creator', () {
        expect(testGroup.isCreator('user-456'), false);
      });

      test('canManage returns true for admins', () {
        expect(testGroup.canManage('user-123'), true);
      });

      test('canManage returns false for regular members', () {
        expect(testGroup.canManage('user-456'), false);
      });
    });

    group('Group status methods', () {
      test('isAtCapacity returns false when below max', () {
        expect(testGroup.isAtCapacity, false);
      });

      test('isAtCapacity returns true when at max', () {
        final members = List.generate(20, (i) => 'user-$i');
        final fullGroup = testGroup.copyWith(memberIds: members);

        expect(fullGroup.isAtCapacity, true);
      });

      test('memberCount returns correct count', () {
        expect(testGroup.memberCount, 2);
      });

      test('adminCount returns correct count', () {
        expect(testGroup.adminCount, 1);
      });

      test('isActive returns true for recent activity', () {
        final activeGroup = testGroup.copyWith(
          lastActivity: DateTime.now().subtract(const Duration(days: 15)),
        );

        expect(activeGroup.isActive, true);
      });

      test('isActive returns false for old activity', () {
        final inactiveGroup = testGroup.copyWith(
          lastActivity: DateTime.now().subtract(const Duration(days: 35)),
        );

        expect(inactiveGroup.isActive, false);
      });

      test('isActive returns false when lastActivity is null', () {
        expect(testGroup.isActive, false);
      });

      test('hasValidName returns true for valid names', () {
        expect(testGroup.hasValidName, true);
      });

      test('hasValidName returns false for short names', () {
        final shortNameGroup = testGroup.copyWith(name: 'AB');
        expect(shortNameGroup.hasValidName, false);
      });

      test('hasValidName returns false for empty names', () {
        final emptyNameGroup = testGroup.copyWith(name: '');
        expect(emptyNameGroup.hasValidName, false);
      });

      test('canAcceptNewMembers returns true when not at capacity', () {
        expect(testGroup.canAcceptNewMembers, true);
      });

      test('canAcceptNewMembers returns false when at capacity', () {
        final members = List.generate(20, (i) => 'user-$i');
        final fullGroup = testGroup.copyWith(memberIds: members);

        expect(fullGroup.canAcceptNewMembers, false);
      });
    });

    group('Update methods', () {
      test('updateInfo updates basic information', () {
        final updated = testGroup.updateInfo(
          name: 'New Name',
          description: 'New description',
          photoUrl: 'https://example.com/new.jpg',
          location: 'Venice Beach',
        );

        expect(updated.name, 'New Name');
        expect(updated.description, 'New description');
        expect(updated.photoUrl, 'https://example.com/new.jpg');
        expect(updated.location, 'Venice Beach');
        expect(updated.updatedAt, isNotNull);
      });

      test('updateInfo keeps existing values when not provided', () {
        final updated = testGroup.updateInfo(name: 'New Name');

        expect(updated.name, 'New Name');
        expect(updated.description, testGroup.description);
        expect(updated.photoUrl, testGroup.photoUrl);
      });

      test('updateSettings updates group settings', () {
        final updated = testGroup.updateSettings(
          privacy: GroupPrivacy.public,
          requiresApproval: true,
          maxMembers: 30,
          allowMembersToCreateGames: false,
        );

        expect(updated.privacy, GroupPrivacy.public);
        expect(updated.requiresApproval, true);
        expect(updated.maxMembers, 30);
        expect(updated.allowMembersToCreateGames, false);
        expect(updated.updatedAt, isNotNull);
      });

      test('addMember adds new member successfully', () {
        final updated = testGroup.addMember('user-789');

        expect(updated.memberIds, contains('user-789'));
        expect(updated.memberIds.length, 3);
        expect(updated.updatedAt, isNotNull);
      });

      test('addMember does not add duplicate member', () {
        final updated = testGroup.addMember('user-123');

        expect(updated.memberIds.length, 2);
      });

      test('addMember does not add when at capacity', () {
        final members = List.generate(20, (i) => 'user-$i');
        final fullGroup = testGroup.copyWith(memberIds: members);

        final updated = fullGroup.addMember('user-new');

        expect(updated.memberIds, equals(members));
      });

      test('removeMember removes member successfully', () {
        final updated = testGroup.removeMember('user-456');

        expect(updated.memberIds, isNot(contains('user-456')));
        expect(updated.memberIds.length, 1);
        expect(updated.updatedAt, isNotNull);
      });

      test('removeMember also removes from admins', () {
        final group = testGroup.copyWith(
          memberIds: ['user-123', 'user-456'],
          adminIds: ['user-123', 'user-456'],
        );

        final updated = group.removeMember('user-456');

        expect(updated.adminIds, isNot(contains('user-456')));
      });

      test('promoteToAdmin promotes member successfully', () {
        final updated = testGroup.promoteToAdmin('user-456');

        expect(updated.adminIds, contains('user-456'));
        expect(updated.adminIds.length, 2);
        expect(updated.updatedAt, isNotNull);
      });

      test('promoteToAdmin does not promote non-member', () {
        final updated = testGroup.promoteToAdmin('user-789');

        expect(updated.adminIds, equals(testGroup.adminIds));
      });

      test('promoteToAdmin does not duplicate admin', () {
        final updated = testGroup.promoteToAdmin('user-123');

        expect(updated.adminIds.length, 1);
      });

      test('demoteFromAdmin demotes admin successfully', () {
        final group = testGroup.copyWith(
          adminIds: ['user-123', 'user-456'],
        );

        final updated = group.demoteFromAdmin('user-456');

        expect(updated.adminIds, isNot(contains('user-456')));
        expect(updated.adminIds.length, 1);
        expect(updated.updatedAt, isNotNull);
      });

      test('demoteFromAdmin does not demote creator', () {
        final updated = testGroup.demoteFromAdmin('user-123');

        expect(updated.adminIds, contains('user-123'));
      });

      test('addGame adds game successfully', () {
        final updated = testGroup.addGame('game-1');

        expect(updated.gameIds, contains('game-1'));
        expect(updated.totalGamesPlayed, 1);
        expect(updated.updatedAt, isNotNull);
      });

      test('addGame does not add duplicate game', () {
        final group = testGroup.copyWith(gameIds: ['game-1']);
        final updated = group.addGame('game-1');

        expect(updated.gameIds.length, 1);
      });

      test('removeGame removes game successfully', () {
        final group = testGroup.copyWith(gameIds: ['game-1', 'game-2']);
        final updated = group.removeGame('game-1');

        expect(updated.gameIds, isNot(contains('game-1')));
        expect(updated.gameIds.length, 1);
        expect(updated.updatedAt, isNotNull);
      });

      test('updateActivity updates lastActivity timestamp', () {
        final updated = testGroup.updateActivity();

        expect(updated.lastActivity, isNotNull);
        expect(
          updated.lastActivity!.difference(DateTime.now()).inSeconds,
          lessThan(2),
        );
      });
    });

    group('Permission methods', () {
      test('canUserCreateGames returns true for admin', () {
        expect(testGroup.canUserCreateGames('user-123'), true);
      });

      test('canUserCreateGames returns true for member when allowed', () {
        expect(testGroup.canUserCreateGames('user-456'), true);
      });

      test('canUserCreateGames returns false for member when not allowed', () {
        final restrictedGroup = testGroup.copyWith(
          allowMembersToCreateGames: false,
        );

        expect(restrictedGroup.canUserCreateGames('user-456'), false);
      });

      test('canUserCreateGames returns false for non-member', () {
        expect(testGroup.canUserCreateGames('user-789'), false);
      });

      test('canUserInviteOthers returns true for admin', () {
        expect(testGroup.canUserInviteOthers('user-123'), true);
      });

      test('canUserInviteOthers returns true for member when allowed', () {
        expect(testGroup.canUserInviteOthers('user-456'), true);
      });

      test('canUserInviteOthers returns false for member when not allowed', () {
        final restrictedGroup = testGroup.copyWith(
          allowMembersToInviteOthers: false,
        );

        expect(restrictedGroup.canUserInviteOthers('user-456'), false);
      });
    });

    group('Utility methods', () {
      test('getMembersExcluding excludes specified user', () {
        final members = testGroup.getMembersExcluding('user-123');

        expect(members, isNot(contains('user-123')));
        expect(members, contains('user-456'));
      });

      test('getMembersExcluding returns all members if user not found', () {
        final members = testGroup.getMembersExcluding('user-789');

        expect(members.length, 2);
      });
    });

    group('GroupPrivacy enum', () {
      test('GroupPrivacy has correct JSON values', () {
        expect(GroupPrivacy.public.name, 'public');
        expect(GroupPrivacy.private.name, 'private');
        expect(GroupPrivacy.inviteOnly.name, 'inviteOnly');
      });
    });

    group('TimestampConverter', () {
      const converter = TimestampConverter();

      test('converts Timestamp to DateTime', () {
        final timestamp = Timestamp.fromDate(DateTime(2024, 1, 1));
        final dateTime = converter.fromJson(timestamp);

        expect(dateTime, isA<DateTime>());
        expect(dateTime!.year, 2024);
        expect(dateTime.month, 1);
        expect(dateTime.day, 1);
      });

      test('converts String to DateTime', () {
        final dateTime = converter.fromJson('2024-01-01T00:00:00.000');

        expect(dateTime, isA<DateTime>());
        expect(dateTime!.year, 2024);
      });

      test('converts int (milliseconds) to DateTime', () {
        final dateTime = converter.fromJson(1704067200000);

        expect(dateTime, isA<DateTime>());
      });

      test('returns null for null input', () {
        final dateTime = converter.fromJson(null);

        expect(dateTime, isNull);
      });

      test('converts DateTime to Timestamp', () {
        final timestamp = converter.toJson(DateTime(2024, 1, 1));

        expect(timestamp, isA<Timestamp>());
      });

      test('converts null to null', () {
        final timestamp = converter.toJson(null);

        expect(timestamp, isNull);
      });
    });
  });
}
