// Tests GroupBloc functionality and validates all group management operations work correctly.

import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/presentation/bloc/group/group_bloc.dart';
import 'package:play_with_me/core/presentation/bloc/group/group_event.dart';
import 'package:play_with_me/core/presentation/bloc/group/group_state.dart';
import 'package:play_with_me/core/data/models/group_model.dart';

import '../../../data/repositories/mock_group_repository.dart';
import '../../../data/repositories/mock_invitation_repository.dart';

class MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

void main() {
  group('GroupBloc', () {
    late GroupBloc groupBloc;
    late MockGroupRepository mockGroupRepository;
    late MockInvitationRepository mockInvitationRepository;
    late MockFirebaseAnalytics mockAnalytics;

    setUp(() {
      mockGroupRepository = MockGroupRepository();
      mockInvitationRepository = MockInvitationRepository();
      mockAnalytics = MockFirebaseAnalytics();
      when(
        () => mockAnalytics.logEvent(
          name: any(named: 'name'),
          parameters: any(named: 'parameters'),
        ),
      ).thenAnswer((_) async {});
      groupBloc = GroupBloc(
        groupRepository: mockGroupRepository,
        invitationRepository: mockInvitationRepository,
        analytics: mockAnalytics,
      );
    });

    tearDown(() {
      groupBloc.close();
    });

    test('initial state is GroupInitial', () {
      expect(groupBloc.state, equals(const GroupInitial()));
    });

    group('GroupCreationStarted', () {
      blocTest<GroupBloc, GroupState>(
        'logs create_group_started and emits no state change',
        build: () => groupBloc,
        act: (bloc) => bloc.add(const GroupCreationStarted()),
        expect: () => [],
        verify: (_) {
          verify(
            () => mockAnalytics.logEvent(name: 'create_group_started'),
          ).called(1);
        },
      );
    });

    group('LoadGroupById', () {
      final testGroup = GroupModel(
        id: 'group-1',
        name: 'Test Group',
        createdBy: 'user-1',
        createdAt: DateTime.now(),
      );

      blocTest<GroupBloc, GroupState>(
        'emits GroupLoaded when group exists',
        build: () {
          mockGroupRepository.addGroup(testGroup);
          return groupBloc;
        },
        act: (bloc) => bloc.add(const LoadGroupById(groupId: 'group-1')),
        expect: () => [const GroupLoading(), GroupLoaded(group: testGroup)],
      );

      blocTest<GroupBloc, GroupState>(
        'emits GroupNotFound when group does not exist',
        build: () {
          mockGroupRepository.clearGroups();
          return groupBloc;
        },
        act: (bloc) => bloc.add(const LoadGroupById(groupId: 'group-1')),
        expect: () => [
          const GroupLoading(),
          const GroupNotFound(message: 'Group not found'),
        ],
      );
    });

    group('CreateGroup', () {
      final newGroup = GroupModel(
        id: '',
        name: 'New Group',
        createdBy: 'user-1',
        createdAt: DateTime.now(),
      );

      blocTest<GroupBloc, GroupState>(
        'emits GroupCreated when creation succeeds',
        build: () {
          mockGroupRepository.clearGroups();
          return groupBloc;
        },
        act: (bloc) => bloc.add(CreateGroup(group: newGroup)),
        expect: () => [const GroupLoading(), isA<GroupCreated>()],
      );

      blocTest<GroupBloc, GroupState>(
        'emits GroupCreated and sends invitations when friendIdsToInvite provided',
        build: () {
          mockGroupRepository.clearGroups();
          mockInvitationRepository.clearInvitations();
          return groupBloc;
        },
        act: (bloc) => bloc.add(
          CreateGroup(
            group: newGroup,
            friendIdsToInvite: {'friend-1', 'friend-2'},
          ),
        ),
        expect: () => [const GroupLoading(), isA<GroupCreated>()],
        verify: (_) async {
          // Verify that invitations were sent to both friends
          final sentInvitations = await mockInvitationRepository
              .getInvitationsSentByUser('user-1');
          expect(sentInvitations.length, 2);
          expect(sentInvitations.map((i) => i.invitedUserId).toSet(), {
            'friend-1',
            'friend-2',
          });
        },
      );
    });

    group('UpdateGroupInfo', () {
      final updatedGroup = GroupModel(
        id: 'group-1',
        name: 'Updated Group',
        createdBy: 'user-1',
        createdAt: DateTime.now(),
      );

      blocTest<GroupBloc, GroupState>(
        'emits GroupUpdated when update succeeds',
        build: () {
          mockGroupRepository.addGroup(updatedGroup);
          return groupBloc;
        },
        act: (bloc) => bloc.add(
          const UpdateGroupInfo(groupId: 'group-1', name: 'Updated Group'),
        ),
        expect: () => [const GroupLoading(), isA<GroupUpdated>()],
      );
    });
  });
}
