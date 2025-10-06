// Tests all GroupModel business logic methods and JSON serialization/deserialization
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/group_model.dart';

void main() {
  group('GroupModel', () {
    late GroupModel testGroup;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2023, 12, 1, 12, 0, 0);
      testGroup = GroupModel(
        id: 'test-group-id',
        name: 'Test Beach Volleyball Group',
        description: 'A group for testing volleyball games',
        photoUrl: 'https://example.com/group.jpg',
        createdBy: 'creator-uid',
        createdAt: testDate,
        updatedAt: testDate,
        memberIds: ['creator-uid', 'member1-uid', 'member2-uid'],
        adminIds: ['creator-uid', 'member1-uid'],
        gameIds: ['game1', 'game2'],
        privacy: GroupPrivacy.public,
        requiresApproval: false,
        maxMembers: 20,
        location: 'Test Beach',
        allowMembersToCreateGames: true,
        allowMembersToInviteOthers: true,
        notifyMembersOfNewGames: true,
        totalGamesPlayed: 5,
        lastActivity: testDate,
      );
    });

    group('Factory constructors', () {
      test('creates GroupModel with required fields only', () {
        const group = GroupModel(
          id: 'id',
          name: 'Test Group',
          createdBy: 'creator',
          createdAt: null,
        );

        expect(group.id, 'id');
        expect(group.name, 'Test Group');
        expect(group.createdBy, 'creator');
        expect(group.description, null);
        expect(group.photoUrl, null);
        expect(group.updatedAt, null);
        expect(group.memberIds, []);
        expect(group.adminIds, []);
        expect(group.gameIds, []);
        expect(group.privacy, GroupPrivacy.private);
        expect(group.requiresApproval, false);
        expect(group.maxMembers, 20);
        expect(group.location, null);
        expect(group.allowMembersToCreateGames, true);
        expect(group.allowMembersToInviteOthers, true);
        expect(group.notifyMembersOfNewGames, true);
        expect(group.totalGamesPlayed, 0);
        expect(group.lastActivity, null);
      });

      test('fromFirestore creates GroupModel from DocumentSnapshot', () {
        final data = {
          'name': 'Test Group',
          'createdBy': 'creator-uid',
          'createdAt': Timestamp.fromDate(testDate),
          'memberIds': ['creator-uid', 'member1'],
          'maxMembers': 10,
        };

        final mockDoc = MockDocumentSnapshot('test-group-id', data);
        final group = GroupModel.fromFirestore(mockDoc);

        expect(group.id, 'test-group-id');
        expect(group.name, 'Test Group');
        expect(group.createdBy, 'creator-uid');
        expect(group.createdAt, testDate);
        expect(group.memberIds, ['creator-uid', 'member1']);
        expect(group.maxMembers, 10);
      });
    });

    group('JSON serialization', () {
      test('toJson serializes all fields correctly', () {
        final json = testGroup.toJson();

        expect(json['id'], 'test-group-id');
        expect(json['name'], 'Test Beach Volleyball Group');
        expect(json['description'], 'A group for testing volleyball games');
        expect(json['photoUrl'], 'https://example.com/group.jpg');
        expect(json['createdBy'], 'creator-uid');
        expect(json['memberIds'], ['creator-uid', 'member1-uid', 'member2-uid']);
        expect(json['adminIds'], ['creator-uid', 'member1-uid']);
        expect(json['gameIds'], ['game1', 'game2']);
        expect(json['privacy'], 'public');
        expect(json['requiresApproval'], false);
        expect(json['maxMembers'], 20);
        expect(json['location'], 'Test Beach');
        expect(json['allowMembersToCreateGames'], true);
        expect(json['allowMembersToInviteOthers'], true);
        expect(json['notifyMembersOfNewGames'], true);
        expect(json['totalGamesPlayed'], 5);
      });

      test('fromJson deserializes all fields correctly', () {
        final json = {
          'id': 'test-group-id',
          'name': 'Test Beach Volleyball Group',
          'description': 'A group for testing volleyball games',
          'photoUrl': 'https://example.com/group.jpg',
          'createdBy': 'creator-uid',
          'createdAt': Timestamp.fromDate(testDate),
          'updatedAt': Timestamp.fromDate(testDate),
          'memberIds': ['creator-uid', 'member1-uid', 'member2-uid'],
          'adminIds': ['creator-uid', 'member1-uid'],
          'gameIds': ['game1', 'game2'],
          'privacy': 'public',
          'requiresApproval': false,
          'maxMembers': 20,
          'location': 'Test Beach',
          'allowMembersToCreateGames': true,
          'allowMembersToInviteOthers': true,
          'notifyMembersOfNewGames': true,
          'totalGamesPlayed': 5,
          'lastActivity': Timestamp.fromDate(testDate),
        };

        final group = GroupModel.fromJson(json);

        expect(group.id, 'test-group-id');
        expect(group.name, 'Test Beach Volleyball Group');
        expect(group.description, 'A group for testing volleyball games');
        expect(group.photoUrl, 'https://example.com/group.jpg');
        expect(group.createdBy, 'creator-uid');
        expect(group.createdAt, testDate);
        expect(group.updatedAt, testDate);
        expect(group.memberIds, ['creator-uid', 'member1-uid', 'member2-uid']);
        expect(group.adminIds, ['creator-uid', 'member1-uid']);
        expect(group.gameIds, ['game1', 'game2']);
        expect(group.privacy, GroupPrivacy.public);
        expect(group.requiresApproval, false);
        expect(group.maxMembers, 20);
        expect(group.location, 'Test Beach');
        expect(group.allowMembersToCreateGames, true);
        expect(group.allowMembersToInviteOthers, true);
        expect(group.notifyMembersOfNewGames, true);
        expect(group.totalGamesPlayed, 5);
        expect(group.lastActivity, testDate);
      });

      test('toFirestore excludes id field', () {
        final firestoreData = testGroup.toFirestore();

        expect(firestoreData.containsKey('id'), false);
        expect(firestoreData['name'], 'Test Beach Volleyball Group');
        expect(firestoreData['createdBy'], 'creator-uid');
      });
    });

    group('Business logic methods', () {
      test('isMember returns true when user is in memberIds', () {
        expect(testGroup.isMember('creator-uid'), true);
        expect(testGroup.isMember('member1-uid'), true);
        expect(testGroup.isMember('nonmember-uid'), false);
      });

      test('isAdmin returns true when user is in adminIds', () {
        expect(testGroup.isAdmin('creator-uid'), true);
        expect(testGroup.isAdmin('member1-uid'), true);
        expect(testGroup.isAdmin('member2-uid'), false);
        expect(testGroup.isAdmin('nonmember-uid'), false);
      });

      test('isCreator returns true when user is the creator', () {
        expect(testGroup.isCreator('creator-uid'), true);
        expect(testGroup.isCreator('member1-uid'), false);
      });

      test('canManage returns true for admin or creator', () {
        expect(testGroup.canManage('creator-uid'), true);
        expect(testGroup.canManage('member1-uid'), true);
        expect(testGroup.canManage('member2-uid'), false);
        expect(testGroup.canManage('nonmember-uid'), false);
      });

      test('isAtCapacity returns correct value', () {
        expect(testGroup.isAtCapacity, false); // 3 members, max 20

        final fullGroup = testGroup.copyWith(maxMembers: 3);
        expect(fullGroup.isAtCapacity, true); // 3 members, max 3
      });

      test('memberCount returns correct count', () {
        expect(testGroup.memberCount, 3);
      });

      test('adminCount returns correct count', () {
        expect(testGroup.adminCount, 2);
      });

      test('isActive returns true when lastActivity is recent', () {
        final recentGroup = testGroup.copyWith(
          lastActivity: DateTime.now().subtract(const Duration(days: 15)),
        );
        expect(recentGroup.isActive, true);
      });

      test('isActive returns false when lastActivity is old', () {
        final oldGroup = testGroup.copyWith(
          lastActivity: DateTime.now().subtract(const Duration(days: 35)),
        );
        expect(oldGroup.isActive, false);
      });

      test('isActive returns false when lastActivity is null', () {
        final group = testGroup.copyWith(lastActivity: null);
        expect(group.isActive, false);
      });

      test('hasValidName returns correct validation', () {
        expect(testGroup.hasValidName, true);

        final shortNameGroup = testGroup.copyWith(name: 'AB');
        expect(shortNameGroup.hasValidName, false);

        final emptyNameGroup = testGroup.copyWith(name: '');
        expect(emptyNameGroup.hasValidName, false);
      });

      test('canAcceptNewMembers returns correct value', () {
        expect(testGroup.canAcceptNewMembers, true);

        final fullGroup = testGroup.copyWith(maxMembers: 3);
        expect(fullGroup.canAcceptNewMembers, false);
      });
    });

    group('Update methods', () {
      test('updateInfo updates group info and timestamps', () {
        final updatedGroup = testGroup.updateInfo(
          name: 'Updated Group Name',
          description: 'Updated description',
          photoUrl: 'https://example.com/new-photo.jpg',
          location: 'New Beach',
        );

        expect(updatedGroup.name, 'Updated Group Name');
        expect(updatedGroup.description, 'Updated description');
        expect(updatedGroup.photoUrl, 'https://example.com/new-photo.jpg');
        expect(updatedGroup.location, 'New Beach');
        expect(updatedGroup.updatedAt!.isAfter(testGroup.updatedAt!), true);
        expect(updatedGroup.lastActivity!.isAfter(testGroup.lastActivity!), true);
      });

      test('updateInfo keeps existing values when not provided', () {
        final updatedGroup = testGroup.updateInfo(name: 'New Name');

        expect(updatedGroup.name, 'New Name');
        expect(updatedGroup.description, testGroup.description);
        expect(updatedGroup.photoUrl, testGroup.photoUrl);
        expect(updatedGroup.location, testGroup.location);
      });

      test('updateSettings updates group settings', () {
        final updatedGroup = testGroup.updateSettings(
          privacy: GroupPrivacy.private,
          requiresApproval: true,
          maxMembers: 15,
          allowMembersToCreateGames: false,
          allowMembersToInviteOthers: false,
          notifyMembersOfNewGames: false,
        );

        expect(updatedGroup.privacy, GroupPrivacy.private);
        expect(updatedGroup.requiresApproval, true);
        expect(updatedGroup.maxMembers, 15);
        expect(updatedGroup.allowMembersToCreateGames, false);
        expect(updatedGroup.allowMembersToInviteOthers, false);
        expect(updatedGroup.notifyMembersOfNewGames, false);
      });

      test('addMember adds new member', () {
        final updatedGroup = testGroup.addMember('new-member-uid');

        expect(updatedGroup.memberIds, [
          'creator-uid',
          'member1-uid',
          'member2-uid',
          'new-member-uid'
        ]);
        expect(updatedGroup.memberCount, 4);
      });

      test('addMember does not add duplicate member', () {
        final updatedGroup = testGroup.addMember('member1-uid');

        expect(updatedGroup.memberIds, testGroup.memberIds);
        expect(updatedGroup.memberCount, 3);
      });

      test('addMember does not add when at capacity', () {
        final fullGroup = testGroup.copyWith(maxMembers: 3);
        final updatedGroup = fullGroup.addMember('new-member-uid');

        expect(updatedGroup.memberIds, fullGroup.memberIds);
        expect(updatedGroup.memberCount, 3);
      });

      test('removeMember removes member and admin status', () {
        final updatedGroup = testGroup.removeMember('member1-uid');

        expect(updatedGroup.memberIds, ['creator-uid', 'member2-uid']);
        expect(updatedGroup.adminIds, ['creator-uid']);
        expect(updatedGroup.memberCount, 2);
        expect(updatedGroup.adminCount, 1);
      });

      test('removeMember does nothing when member not in group', () {
        final updatedGroup = testGroup.removeMember('nonmember-uid');

        expect(updatedGroup.memberIds, testGroup.memberIds);
        expect(updatedGroup.adminIds, testGroup.adminIds);
      });

      test('promoteToAdmin adds user to adminIds', () {
        final updatedGroup = testGroup.promoteToAdmin('member2-uid');

        expect(updatedGroup.adminIds, ['creator-uid', 'member1-uid', 'member2-uid']);
        expect(updatedGroup.adminCount, 3);
      });

      test('promoteToAdmin does nothing if user not a member', () {
        final updatedGroup = testGroup.promoteToAdmin('nonmember-uid');

        expect(updatedGroup.adminIds, testGroup.adminIds);
      });

      test('promoteToAdmin does nothing if user already admin', () {
        final updatedGroup = testGroup.promoteToAdmin('member1-uid');

        expect(updatedGroup.adminIds, testGroup.adminIds);
      });

      test('demoteFromAdmin removes user from adminIds', () {
        final updatedGroup = testGroup.demoteFromAdmin('member1-uid');

        expect(updatedGroup.adminIds, ['creator-uid']);
        expect(updatedGroup.adminCount, 1);
      });

      test('demoteFromAdmin does not demote creator', () {
        final updatedGroup = testGroup.demoteFromAdmin('creator-uid');

        expect(updatedGroup.adminIds, testGroup.adminIds);
      });

      test('demoteFromAdmin does nothing if user not admin', () {
        final updatedGroup = testGroup.demoteFromAdmin('member2-uid');

        expect(updatedGroup.adminIds, testGroup.adminIds);
      });

      test('addGame adds game to gameIds and increments totalGamesPlayed', () {
        final updatedGroup = testGroup.addGame('game3');

        expect(updatedGroup.gameIds, ['game1', 'game2', 'game3']);
        expect(updatedGroup.totalGamesPlayed, 6);
      });

      test('addGame does not add duplicate game', () {
        final updatedGroup = testGroup.addGame('game1');

        expect(updatedGroup.gameIds, testGroup.gameIds);
        expect(updatedGroup.totalGamesPlayed, testGroup.totalGamesPlayed);
      });

      test('removeGame removes game from gameIds', () {
        final updatedGroup = testGroup.removeGame('game1');

        expect(updatedGroup.gameIds, ['game2']);
      });

      test('removeGame does nothing when game not in list', () {
        final updatedGroup = testGroup.removeGame('nonexistent-game');

        expect(updatedGroup.gameIds, testGroup.gameIds);
      });

      test('updateActivity updates lastActivity timestamp', () {
        final updatedGroup = testGroup.updateActivity();

        expect(updatedGroup.lastActivity!.isAfter(testGroup.lastActivity!), true);
      });

      test('getMembersExcluding returns members excluding specified user', () {
        final membersExcludingCreator = testGroup.getMembersExcluding('creator-uid');

        expect(membersExcludingCreator, ['member1-uid', 'member2-uid']);
      });

      test('canUserCreateGames returns correct permissions', () {
        // Member with permission
        expect(testGroup.canUserCreateGames('member2-uid'), true);

        // Admin always can
        expect(testGroup.canUserCreateGames('creator-uid'), true);

        // Non-member cannot
        expect(testGroup.canUserCreateGames('nonmember-uid'), false);

        // Member when permission disabled
        final restrictedGroup = testGroup.copyWith(allowMembersToCreateGames: false);
        expect(restrictedGroup.canUserCreateGames('member2-uid'), false);
        expect(restrictedGroup.canUserCreateGames('creator-uid'), true); // Admin still can
      });

      test('canUserInviteOthers returns correct permissions', () {
        // Member with permission
        expect(testGroup.canUserInviteOthers('member2-uid'), true);

        // Admin always can
        expect(testGroup.canUserInviteOthers('creator-uid'), true);

        // Non-member cannot
        expect(testGroup.canUserInviteOthers('nonmember-uid'), false);

        // Member when permission disabled
        final restrictedGroup = testGroup.copyWith(allowMembersToInviteOthers: false);
        expect(restrictedGroup.canUserInviteOthers('member2-uid'), false);
        expect(restrictedGroup.canUserInviteOthers('creator-uid'), true); // Admin still can
      });
    });

    group('GroupPrivacy enum', () {
      test('GroupPrivacy enum has correct JSON values', () {
        expect(GroupPrivacy.public.toString(), 'GroupPrivacy.public');
        expect(GroupPrivacy.private.toString(), 'GroupPrivacy.private');
        expect(GroupPrivacy.inviteOnly.toString(), 'GroupPrivacy.inviteOnly');
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