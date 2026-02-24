// Tests FirestoreGroupRepository methods with fake Firestore
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/group_model.dart';
import 'package:play_with_me/core/data/repositories/firestore_group_repository.dart';
import 'package:play_with_me/core/domain/exceptions/repository_exceptions.dart';

void main() {
  group('FirestoreGroupRepository', () {
    late FakeFirebaseFirestore fakeFirestore;
    late FirestoreGroupRepository repository;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      repository = FirestoreGroupRepository(firestore: fakeFirestore);
    });

    group('createGroup', () {
      test('creates group successfully and returns document ID', () async {
        final testGroup = GroupModel(
          id: '',
          name: 'Beach Volleyball Crew',
          description: 'Weekly beach volleyball games',
          createdBy: 'user-123',
          createdAt: DateTime(2024, 1, 1),
          memberIds: const ['user-123'],
          adminIds: const ['user-123'],
        );

        final groupId = await repository.createGroup(testGroup);

        expect(groupId, isNotEmpty);

        final doc = await fakeFirestore.collection('groups').doc(groupId).get();
        expect(doc.exists, true);

        final data = doc.data()!;
        expect(data['name'], 'Beach Volleyball Crew');
        expect(data['description'], 'Weekly beach volleyball games');
        expect(data['createdBy'], 'user-123');
        expect(data['memberIds'], ['user-123']);
        expect(data['adminIds'], ['user-123']);
      });

      test('creates group with minimal required fields', () async {
        final testGroup = GroupModel(
          id: '',
          name: 'Test Group',
          createdBy: 'user-456',
          createdAt: DateTime(2024, 1, 1),
        );

        final groupId = await repository.createGroup(testGroup);

        expect(groupId, isNotEmpty);

        final doc = await fakeFirestore.collection('groups').doc(groupId).get();
        expect(doc.exists, true);
        expect(doc.data()!['name'], 'Test Group');
        expect(doc.data()!['createdBy'], 'user-456');
      });

      test('creates group without id field in Firestore', () async {
        final testGroup = GroupModel(
          id: 'should-be-ignored',
          name: 'Test Group',
          createdBy: 'user-123',
          createdAt: DateTime(2024, 1, 1),
        );

        final groupId = await repository.createGroup(testGroup);

        expect(groupId, isNot('should-be-ignored'));

        final doc = await fakeFirestore.collection('groups').doc(groupId).get();
        final data = doc.data()!;
        expect(data.containsKey('id'), false);
      });

      test('creates group with all optional fields', () async {
        final testGroup = GroupModel(
          id: '',
          name: 'Advanced Group',
          description: 'Pro players only',
          photoUrl: 'https://example.com/photo.jpg',
          createdBy: 'user-123',
          createdAt: DateTime(2024, 1, 1),
          memberIds: const ['user-123', 'user-456'],
          adminIds: const ['user-123'],
          privacy: GroupPrivacy.public,
          requiresApproval: true,
          maxMembers: 30,
          location: 'Santa Monica Beach',
        );

        final groupId = await repository.createGroup(testGroup);

        final doc = await fakeFirestore.collection('groups').doc(groupId).get();
        final data = doc.data()!;

        expect(data['description'], 'Pro players only');
        expect(data['photoUrl'], 'https://example.com/photo.jpg');
        expect(data['privacy'], 'public');
        expect(data['requiresApproval'], true);
        expect(data['maxMembers'], 30);
        expect(data['location'], 'Santa Monica Beach');
      });

      test('completes successfully with valid data', () async {
        final testGroup = GroupModel(
          id: '',
          name: 'Test Group',
          createdBy: 'user-123',
          createdAt: DateTime(2024, 1, 1),
        );

        await expectLater(
          repository.createGroup(testGroup),
          completes,
        );
      });
    });

    group('watchGroupById', () {
      test('emits group when document exists', () async {
        final testGroup = GroupModel(
          id: '',
          name: 'Watched Group',
          createdBy: 'user-123',
          createdAt: DateTime(2024, 1, 1),
          memberIds: const ['user-123'],
        );
        final groupId = await repository.createGroup(testGroup);

        final stream = repository.watchGroupById(groupId);

        await expectLater(
          stream,
          emits(isA<GroupModel>().having((g) => g.name, 'name', 'Watched Group')),
        );
      });

      test('emits null when document does not exist', () async {
        final stream = repository.watchGroupById('non-existent-id');

        await expectLater(stream, emits(isNull));
      });
    });

    group('getGroupById', () {
      test('returns group when it exists', () async {
        final testGroup = GroupModel(
          id: '',
          name: 'Test Group',
          createdBy: 'user-123',
          createdAt: DateTime(2024, 1, 1),
          memberIds: const ['user-123'],
        );
        final groupId = await repository.createGroup(testGroup);

        final retrievedGroup = await repository.getGroupById(groupId);

        expect(retrievedGroup, isNotNull);
        expect(retrievedGroup!.id, groupId);
        expect(retrievedGroup.name, 'Test Group');
        expect(retrievedGroup.createdBy, 'user-123');
      });

      test('returns null when group does not exist', () async {
        final group = await repository.getGroupById('non-existent-id');

        expect(group, isNull);
      });

      test('returns group with all fields populated', () async {
        final testGroup = GroupModel(
          id: '',
          name: 'Full Group',
          description: 'Full description',
          photoUrl: 'https://example.com/photo.jpg',
          createdBy: 'user-123',
          createdAt: DateTime(2024, 1, 1),
          memberIds: const ['user-123', 'user-456'],
          adminIds: const ['user-123'],
          privacy: GroupPrivacy.private,
          requiresApproval: true,
          maxMembers: 50,
          location: 'Test Location',
        );
        final groupId = await repository.createGroup(testGroup);

        final retrievedGroup = await repository.getGroupById(groupId);

        expect(retrievedGroup, isNotNull);
        expect(retrievedGroup!.name, 'Full Group');
        expect(retrievedGroup.description, 'Full description');
        expect(retrievedGroup.photoUrl, 'https://example.com/photo.jpg');
        expect(retrievedGroup.memberIds, ['user-123', 'user-456']);
        expect(retrievedGroup.adminIds, ['user-123']);
        expect(retrievedGroup.privacy, GroupPrivacy.private);
        expect(retrievedGroup.requiresApproval, true);
        expect(retrievedGroup.maxMembers, 50);
        expect(retrievedGroup.location, 'Test Location');
      });
    });

    group('getGroupsByIds', () {
      test('returns empty list for empty input', () async {
        final groups = await repository.getGroupsByIds([]);

        expect(groups, isEmpty);
      });

      test('returns groups for valid IDs', () async {
        final group1 = GroupModel(
          id: '',
          name: 'Group 1',
          createdBy: 'user-123',
          createdAt: DateTime(2024, 1, 1),
        );
        final group2 = GroupModel(
          id: '',
          name: 'Group 2',
          createdBy: 'user-123',
          createdAt: DateTime(2024, 1, 2),
        );
        final id1 = await repository.createGroup(group1);
        final id2 = await repository.createGroup(group2);

        final groups = await repository.getGroupsByIds([id1, id2]);

        expect(groups.length, 2);
        expect(groups.any((g) => g.name == 'Group 1'), true);
        expect(groups.any((g) => g.name == 'Group 2'), true);
      });

      test('handles non-existent IDs gracefully', () async {
        final group1 = GroupModel(
          id: '',
          name: 'Group 1',
          createdBy: 'user-123',
          createdAt: DateTime(2024, 1, 1),
        );
        final id1 = await repository.createGroup(group1);

        final groups =
            await repository.getGroupsByIds([id1, 'non-existent-id']);

        expect(groups.length, 1);
        expect(groups.first.name, 'Group 1');
      });

      test('handles more than 10 IDs with batching', () async {
        final ids = <String>[];
        for (int i = 0; i < 15; i++) {
          final group = GroupModel(
            id: '',
            name: 'Group $i',
            createdBy: 'user-123',
            createdAt: DateTime(2024, 1, 1),
          );
          final id = await repository.createGroup(group);
          ids.add(id);
        }

        final groups = await repository.getGroupsByIds(ids);

        expect(groups.length, 15);
      });
    });

    group('getGroupsForUser', () {
      test('returns stream of groups for user', () async {
        final group1 = GroupModel(
          id: '',
          name: 'Group 1',
          createdBy: 'user-123',
          createdAt: DateTime(2024, 1, 1),
          memberIds: const ['user-123', 'user-456'],
          adminIds: const ['user-123'],
        );
        final group2 = GroupModel(
          id: '',
          name: 'Group 2',
          createdBy: 'user-456',
          createdAt: DateTime(2024, 1, 2),
          memberIds: const ['user-456', 'user-123'],
          adminIds: const ['user-456'],
        );
        await repository.createGroup(group1);
        await repository.createGroup(group2);

        final stream = repository.getGroupsForUser('user-123');
        final groups = await stream.first;

        expect(groups.length, 2);
        expect(groups.any((g) => g.name == 'Group 1'), true);
        expect(groups.any((g) => g.name == 'Group 2'), true);
      });

      test('returns empty list when user is not member of any group', () async {
        final group = GroupModel(
          id: '',
          name: 'Other Group',
          createdBy: 'user-456',
          createdAt: DateTime(2024, 1, 1),
          memberIds: const ['user-456'],
          adminIds: const ['user-456'],
        );
        await repository.createGroup(group);

        final stream = repository.getGroupsForUser('user-123');
        final groups = await stream.first;

        expect(groups, isEmpty);
      });
    });

    group('updateGroupInfo', () {
      test('updates group name successfully', () async {
        final testGroup = GroupModel(
          id: '',
          name: 'Original Name',
          createdBy: 'user-123',
          createdAt: DateTime(2024, 1, 1),
        );
        final groupId = await repository.createGroup(testGroup);

        await repository.updateGroupInfo(groupId, name: 'Updated Name');

        final updatedGroup = await repository.getGroupById(groupId);
        expect(updatedGroup!.name, 'Updated Name');
      });

      test('updates group description successfully', () async {
        final testGroup = GroupModel(
          id: '',
          name: 'Test Group',
          createdBy: 'user-123',
          createdAt: DateTime(2024, 1, 1),
        );
        final groupId = await repository.createGroup(testGroup);

        await repository.updateGroupInfo(groupId, description: 'New desc');

        final updatedGroup = await repository.getGroupById(groupId);
        expect(updatedGroup!.description, 'New desc');
      });

      test('updates group photoUrl successfully', () async {
        final testGroup = GroupModel(
          id: '',
          name: 'Test Group',
          createdBy: 'user-123',
          createdAt: DateTime(2024, 1, 1),
        );
        final groupId = await repository.createGroup(testGroup);

        await repository.updateGroupInfo(
          groupId,
          photoUrl: 'https://new-photo.jpg',
        );

        final updatedGroup = await repository.getGroupById(groupId);
        expect(updatedGroup!.photoUrl, 'https://new-photo.jpg');
      });

      test('updates group location successfully', () async {
        final testGroup = GroupModel(
          id: '',
          name: 'Test Group',
          createdBy: 'user-123',
          createdAt: DateTime(2024, 1, 1),
        );
        final groupId = await repository.createGroup(testGroup);

        await repository.updateGroupInfo(groupId, location: 'New Location');

        final updatedGroup = await repository.getGroupById(groupId);
        expect(updatedGroup!.location, 'New Location');
      });

      test('updates multiple fields at once', () async {
        final testGroup = GroupModel(
          id: '',
          name: 'Original Name',
          createdBy: 'user-123',
          createdAt: DateTime(2024, 1, 1),
        );
        final groupId = await repository.createGroup(testGroup);

        await repository.updateGroupInfo(
          groupId,
          name: 'New Name',
          description: 'New Description',
          location: 'New Location',
        );

        final updatedGroup = await repository.getGroupById(groupId);
        expect(updatedGroup!.name, 'New Name');
        expect(updatedGroup.description, 'New Description');
        expect(updatedGroup.location, 'New Location');
      });

      test('throws exception when group does not exist', () async {
        await expectLater(
          repository.updateGroupInfo('non-existent-id', name: 'New Name'),
          throwsA(isA<GroupException>()),
        );
      });
    });

    group('updateGroupSettings', () {
      test('updates privacy setting successfully', () async {
        final testGroup = GroupModel(
          id: '',
          name: 'Test Group',
          createdBy: 'user-123',
          createdAt: DateTime(2024, 1, 1),
          privacy: GroupPrivacy.public,
        );
        final groupId = await repository.createGroup(testGroup);

        await repository.updateGroupSettings(
          groupId,
          privacy: GroupPrivacy.private,
        );

        final updatedGroup = await repository.getGroupById(groupId);
        expect(updatedGroup!.privacy, GroupPrivacy.private);
      });

      test('updates requiresApproval setting successfully', () async {
        final testGroup = GroupModel(
          id: '',
          name: 'Test Group',
          createdBy: 'user-123',
          createdAt: DateTime(2024, 1, 1),
          requiresApproval: false,
        );
        final groupId = await repository.createGroup(testGroup);

        await repository.updateGroupSettings(groupId, requiresApproval: true);

        final updatedGroup = await repository.getGroupById(groupId);
        expect(updatedGroup!.requiresApproval, true);
      });

      test('updates maxMembers setting successfully', () async {
        final testGroup = GroupModel(
          id: '',
          name: 'Test Group',
          createdBy: 'user-123',
          createdAt: DateTime(2024, 1, 1),
          maxMembers: 50,
        );
        final groupId = await repository.createGroup(testGroup);

        await repository.updateGroupSettings(groupId, maxMembers: 100);

        final updatedGroup = await repository.getGroupById(groupId);
        expect(updatedGroup!.maxMembers, 100);
      });

      test('updates multiple settings at once', () async {
        final testGroup = GroupModel(
          id: '',
          name: 'Test Group',
          createdBy: 'user-123',
          createdAt: DateTime(2024, 1, 1),
        );
        final groupId = await repository.createGroup(testGroup);

        await repository.updateGroupSettings(
          groupId,
          privacy: GroupPrivacy.private,
          requiresApproval: true,
          maxMembers: 25,
          allowMembersToCreateGames: false,
          allowMembersToInviteOthers: false,
          notifyMembersOfNewGames: true,
        );

        final updatedGroup = await repository.getGroupById(groupId);
        expect(updatedGroup!.privacy, GroupPrivacy.private);
        expect(updatedGroup.requiresApproval, true);
        expect(updatedGroup.maxMembers, 25);
        expect(updatedGroup.allowMembersToCreateGames, false);
        expect(updatedGroup.allowMembersToInviteOthers, false);
        expect(updatedGroup.notifyMembersOfNewGames, true);
      });

      test('throws exception when group does not exist', () async {
        await expectLater(
          repository.updateGroupSettings(
            'non-existent-id',
            privacy: GroupPrivacy.private,
          ),
          throwsA(isA<GroupException>()),
        );
      });
    });

    group('addMember', () {
      test('adds new member to group', () async {
        final testGroup = GroupModel(
          id: '',
          name: 'Test Group',
          createdBy: 'user-123',
          createdAt: DateTime(2024, 1, 1),
          memberIds: const ['user-123'],
          adminIds: const ['user-123'],
        );
        final groupId = await repository.createGroup(testGroup);

        await repository.addMember(groupId, 'user-456');

        final updatedGroup = await repository.getGroupById(groupId);
        expect(updatedGroup!.memberIds, contains('user-456'));
        expect(updatedGroup.memberIds.length, 2);
      });

      test('throws exception when group does not exist', () async {
        await expectLater(
          repository.addMember('non-existent-id', 'user-456'),
          throwsA(isA<GroupException>()),
        );
      });
    });

    group('removeMember', () {
      test('removes member from group', () async {
        final testGroup = GroupModel(
          id: '',
          name: 'Test Group',
          createdBy: 'user-123',
          createdAt: DateTime(2024, 1, 1),
          memberIds: const ['user-123', 'user-456'],
          adminIds: const ['user-123'],
        );
        final groupId = await repository.createGroup(testGroup);

        await repository.removeMember(groupId, 'user-456');

        final updatedGroup = await repository.getGroupById(groupId);
        expect(updatedGroup!.memberIds, isNot(contains('user-456')));
        expect(updatedGroup.memberIds.length, 1);
      });

      test('throws exception when group does not exist', () async {
        await expectLater(
          repository.removeMember('non-existent-id', 'user-456'),
          throwsA(isA<GroupException>()),
        );
      });
    });

    group('promoteToAdmin', () {
      test('promotes member to admin', () async {
        final testGroup = GroupModel(
          id: '',
          name: 'Test Group',
          createdBy: 'user-123',
          createdAt: DateTime(2024, 1, 1),
          memberIds: const ['user-123', 'user-456'],
          adminIds: const ['user-123'],
        );
        final groupId = await repository.createGroup(testGroup);

        await repository.promoteToAdmin(groupId, 'user-456');

        final updatedGroup = await repository.getGroupById(groupId);
        expect(updatedGroup!.adminIds, contains('user-456'));
        expect(updatedGroup.adminIds.length, 2);
      });

      test('throws exception when group does not exist', () async {
        await expectLater(
          repository.promoteToAdmin('non-existent-id', 'user-456'),
          throwsA(isA<GroupException>()),
        );
      });
    });

    group('demoteFromAdmin', () {
      test('demotes admin to member', () async {
        final testGroup = GroupModel(
          id: '',
          name: 'Test Group',
          createdBy: 'user-123',
          createdAt: DateTime(2024, 1, 1),
          memberIds: const ['user-123', 'user-456'],
          adminIds: const ['user-123', 'user-456'],
        );
        final groupId = await repository.createGroup(testGroup);

        await repository.demoteFromAdmin(groupId, 'user-456');

        final updatedGroup = await repository.getGroupById(groupId);
        expect(updatedGroup!.adminIds, isNot(contains('user-456')));
        expect(updatedGroup.adminIds.length, 1);
      });

      test('throws exception when group does not exist', () async {
        await expectLater(
          repository.demoteFromAdmin('non-existent-id', 'user-456'),
          throwsA(isA<GroupException>()),
        );
      });
    });

    group('addGame', () {
      test('adds game to group', () async {
        final testGroup = GroupModel(
          id: '',
          name: 'Test Group',
          createdBy: 'user-123',
          createdAt: DateTime(2024, 1, 1),
        );
        final groupId = await repository.createGroup(testGroup);

        await repository.addGame(groupId, 'game-123');

        final updatedGroup = await repository.getGroupById(groupId);
        expect(updatedGroup!.gameIds, contains('game-123'));
      });

      test('throws exception when group does not exist', () async {
        await expectLater(
          repository.addGame('non-existent-id', 'game-123'),
          throwsA(isA<GroupException>()),
        );
      });
    });

    group('removeGame', () {
      test('removes game from group', () async {
        final testGroup = GroupModel(
          id: '',
          name: 'Test Group',
          createdBy: 'user-123',
          createdAt: DateTime(2024, 1, 1),
          gameIds: const ['game-123', 'game-456'],
        );
        final groupId = await repository.createGroup(testGroup);

        await repository.removeGame(groupId, 'game-123');

        final updatedGroup = await repository.getGroupById(groupId);
        expect(updatedGroup!.gameIds, isNot(contains('game-123')));
        expect(updatedGroup.gameIds, contains('game-456'));
      });

      test('throws exception when group does not exist', () async {
        await expectLater(
          repository.removeGame('non-existent-id', 'game-123'),
          throwsA(isA<GroupException>()),
        );
      });
    });

    group('updateActivity', () {
      test('updates lastActivity timestamp', () async {
        final testGroup = GroupModel(
          id: '',
          name: 'Test Group',
          createdBy: 'user-123',
          createdAt: DateTime(2024, 1, 1),
        );
        final groupId = await repository.createGroup(testGroup);

        await repository.updateActivity(groupId);

        final updatedGroup = await repository.getGroupById(groupId);
        expect(updatedGroup!.lastActivity, isNotNull);
      });

      test('throws exception when group does not exist', () async {
        await expectLater(
          repository.updateActivity('non-existent-id'),
          throwsA(isA<GroupException>()),
        );
      });
    });

    group('searchPublicGroups', () {
      test('returns empty list for empty query', () async {
        final groups = await repository.searchPublicGroups('');

        expect(groups, isEmpty);
      });

      test('returns empty list for whitespace query', () async {
        final groups = await repository.searchPublicGroups('   ');

        expect(groups, isEmpty);
      });

      test('finds public groups matching query', () async {
        final publicGroup = GroupModel(
          id: '',
          name: 'beach volleyball',
          createdBy: 'user-123',
          createdAt: DateTime(2024, 1, 1),
          privacy: GroupPrivacy.public,
        );
        await repository.createGroup(publicGroup);

        final groups = await repository.searchPublicGroups('beach');

        expect(groups.length, 1);
        expect(groups.first.name, 'beach volleyball');
      });

      test('does not return private groups', () async {
        final privateGroup = GroupModel(
          id: '',
          name: 'beach private',
          createdBy: 'user-123',
          createdAt: DateTime(2024, 1, 1),
          privacy: GroupPrivacy.private,
        );
        await repository.createGroup(privateGroup);

        final groups = await repository.searchPublicGroups('beach');

        expect(groups, isEmpty);
      });

      test('respects limit parameter', () async {
        for (int i = 0; i < 5; i++) {
          final group = GroupModel(
            id: '',
            name: 'beach group $i',
            createdBy: 'user-123',
            createdAt: DateTime(2024, 1, 1),
            privacy: GroupPrivacy.public,
          );
          await repository.createGroup(group);
        }

        final groups = await repository.searchPublicGroups('beach', limit: 3);

        expect(groups.length, 3);
      });
    });

    group('getGroupMembers', () {
      test('returns member IDs for existing group', () async {
        final testGroup = GroupModel(
          id: '',
          name: 'Test Group',
          createdBy: 'user-123',
          createdAt: DateTime(2024, 1, 1),
          memberIds: const ['user-123', 'user-456', 'user-789'],
        );
        final groupId = await repository.createGroup(testGroup);

        final memberIds = await repository.getGroupMembers(groupId);

        expect(memberIds.length, 3);
        expect(memberIds, contains('user-123'));
        expect(memberIds, contains('user-456'));
        expect(memberIds, contains('user-789'));
      });

      test('returns empty list for non-existent group', () async {
        final memberIds = await repository.getGroupMembers('non-existent-id');

        expect(memberIds, isEmpty);
      });
    });

    group('getGroupAdmins', () {
      test('returns admin IDs for existing group', () async {
        final testGroup = GroupModel(
          id: '',
          name: 'Test Group',
          createdBy: 'user-123',
          createdAt: DateTime(2024, 1, 1),
          memberIds: const ['user-123', 'user-456'],
          adminIds: const ['user-123', 'user-456'],
        );
        final groupId = await repository.createGroup(testGroup);

        final adminIds = await repository.getGroupAdmins(groupId);

        expect(adminIds.length, 2);
        expect(adminIds, contains('user-123'));
        expect(adminIds, contains('user-456'));
      });

      test('returns empty list for non-existent group', () async {
        final adminIds = await repository.getGroupAdmins('non-existent-id');

        expect(adminIds, isEmpty);
      });
    });

    group('canUserJoinGroup', () {
      test('returns true when user can join public group', () async {
        final testGroup = GroupModel(
          id: '',
          name: 'Test Group',
          createdBy: 'user-123',
          createdAt: DateTime(2024, 1, 1),
          memberIds: const ['user-123'],
          privacy: GroupPrivacy.public,
          maxMembers: 50,
        );
        final groupId = await repository.createGroup(testGroup);

        final canJoin = await repository.canUserJoinGroup(groupId, 'user-456');

        expect(canJoin, true);
      });

      test('returns false when user is already a member', () async {
        final testGroup = GroupModel(
          id: '',
          name: 'Test Group',
          createdBy: 'user-123',
          createdAt: DateTime(2024, 1, 1),
          memberIds: const ['user-123', 'user-456'],
          privacy: GroupPrivacy.public,
        );
        final groupId = await repository.createGroup(testGroup);

        final canJoin = await repository.canUserJoinGroup(groupId, 'user-456');

        expect(canJoin, false);
      });

      test('returns false when group is at capacity', () async {
        final testGroup = GroupModel(
          id: '',
          name: 'Test Group',
          createdBy: 'user-123',
          createdAt: DateTime(2024, 1, 1),
          memberIds: const ['user-123', 'user-456'],
          privacy: GroupPrivacy.public,
          maxMembers: 2,
        );
        final groupId = await repository.createGroup(testGroup);

        final canJoin = await repository.canUserJoinGroup(groupId, 'user-789');

        expect(canJoin, false);
      });

      test('returns false when group is private', () async {
        final testGroup = GroupModel(
          id: '',
          name: 'Test Group',
          createdBy: 'user-123',
          createdAt: DateTime(2024, 1, 1),
          memberIds: const ['user-123'],
          privacy: GroupPrivacy.private,
        );
        final groupId = await repository.createGroup(testGroup);

        final canJoin = await repository.canUserJoinGroup(groupId, 'user-456');

        expect(canJoin, false);
      });

      test('returns false when group does not exist', () async {
        final canJoin =
            await repository.canUserJoinGroup('non-existent-id', 'user-456');

        expect(canJoin, false);
      });
    });

    group('deleteGroup', () {
      test('deletes group successfully', () async {
        final testGroup = GroupModel(
          id: '',
          name: 'Test Group',
          createdBy: 'user-123',
          createdAt: DateTime(2024, 1, 1),
        );
        final groupId = await repository.createGroup(testGroup);

        await repository.deleteGroup(groupId);

        final exists = await repository.groupExists(groupId);
        expect(exists, false);
      });

      test('does not throw when deleting non-existent group', () async {
        await expectLater(
          repository.deleteGroup('non-existent-id'),
          completes,
        );
      });
    });

    group('groupExists', () {
      test('returns true when group exists', () async {
        final testGroup = GroupModel(
          id: '',
          name: 'Test Group',
          createdBy: 'user-123',
          createdAt: DateTime(2024, 1, 1),
        );
        final groupId = await repository.createGroup(testGroup);

        final exists = await repository.groupExists(groupId);

        expect(exists, true);
      });

      test('returns false when group does not exist', () async {
        final exists = await repository.groupExists('non-existent-id');

        expect(exists, false);
      });
    });

    group('getGroupStats', () {
      test('returns stats for existing group', () async {
        final testGroup = GroupModel(
          id: '',
          name: 'Test Group',
          createdBy: 'user-123',
          createdAt: DateTime(2024, 1, 1),
          memberIds: const ['user-123', 'user-456', 'user-789'],
          adminIds: const ['user-123', 'user-456'],
          gameIds: const ['game-1', 'game-2', 'game-3'],
          totalGamesPlayed: 3,
        );
        final groupId = await repository.createGroup(testGroup);

        final stats = await repository.getGroupStats(groupId);

        expect(stats['memberCount'], 3);
        expect(stats['adminCount'], 2);
        expect(stats['totalGamesPlayed'], 3);
        expect(stats['createdAt'], isNotNull);
      });

      test('throws exception when group does not exist', () async {
        await expectLater(
          repository.getGroupStats('non-existent-id'),
          throwsA(isA<GroupException>()),
        );
      });

      test('includes isActive status', () async {
        final testGroup = GroupModel(
          id: '',
          name: 'Test Group',
          createdBy: 'user-123',
          createdAt: DateTime(2024, 1, 1),
          memberIds: const ['user-123'],
        );
        final groupId = await repository.createGroup(testGroup);

        final stats = await repository.getGroupStats(groupId);

        expect(stats.containsKey('isActive'), true);
      });

      test('includes lastActivity when available', () async {
        final testGroup = GroupModel(
          id: '',
          name: 'Test Group',
          createdBy: 'user-123',
          createdAt: DateTime(2024, 1, 1),
          lastActivity: DateTime(2024, 6, 15),
        );
        final groupId = await repository.createGroup(testGroup);

        final stats = await repository.getGroupStats(groupId);

        expect(stats['lastActivity'], isNotNull);
      });
    });

  });
}
