// Tests GroupBloc functionality and validates all group management operations work correctly.

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/presentation/bloc/group/group_bloc.dart';
import 'package:play_with_me/core/presentation/bloc/group/group_event.dart';
import 'package:play_with_me/core/presentation/bloc/group/group_state.dart';
import 'package:play_with_me/core/data/models/group_model.dart';

import '../../../data/repositories/mock_group_repository.dart';

void main() {
  group('GroupBloc', () {
    late GroupBloc groupBloc;
    late MockGroupRepository mockGroupRepository;

    setUp(() {
      mockGroupRepository = MockGroupRepository();
      groupBloc = GroupBloc(groupRepository: mockGroupRepository);
    });

    tearDown(() {
      groupBloc.close();
    });

    test('initial state is GroupInitial', () {
      expect(groupBloc.state, equals(const GroupInitial()));
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
        expect: () => [
          const GroupLoading(),
          GroupLoaded(group: testGroup),
        ],
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
        expect: () => [
          const GroupLoading(),
          isA<GroupCreated>(),
        ],
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
        act: (bloc) => bloc.add(const UpdateGroupInfo(
          groupId: 'group-1',
          name: 'Updated Group',
        )),
        expect: () => [
          const GroupLoading(),
          isA<GroupUpdated>(),
        ],
      );
    });
  });
}