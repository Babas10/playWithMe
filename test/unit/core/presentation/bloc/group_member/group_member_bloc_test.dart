// Validates GroupMemberBloc emits correct states during member management operations
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/data/models/group_model.dart';
import 'package:play_with_me/core/domain/repositories/group_repository.dart';
import 'package:play_with_me/core/presentation/bloc/group_member/group_member_bloc.dart';
import 'package:play_with_me/core/presentation/bloc/group_member/group_member_event.dart';
import 'package:play_with_me/core/presentation/bloc/group_member/group_member_state.dart';

class MockGroupRepository extends Mock implements GroupRepository {}

void main() {
  late GroupMemberBloc bloc;
  late MockGroupRepository mockGroupRepository;

  final testGroup = GroupModel(
    id: 'group1',
    name: 'Test Group',
    createdBy: 'creator123',
    createdAt: DateTime(2024, 1, 1),
    memberIds: ['creator123', 'admin1', 'user1', 'user2'],
    adminIds: ['creator123', 'admin1'],
  );

  setUp(() {
    mockGroupRepository = MockGroupRepository();
    bloc = GroupMemberBloc(groupRepository: mockGroupRepository);
  });

  tearDown(() {
    bloc.close();
  });

  group('PromoteMemberToAdmin', () {
    blocTest<GroupMemberBloc, GroupMemberState>(
      'emits [loading, success] when member is successfully promoted',
      build: () {
        when(() => mockGroupRepository.getGroupById('group1'))
            .thenAnswer((_) async => testGroup);
        when(() => mockGroupRepository.promoteToAdmin('group1', 'user1'))
            .thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) => bloc.add(const PromoteMemberToAdmin(
        groupId: 'group1',
        userId: 'user1',
      )),
      expect: () => [
        const GroupMemberLoading(),
        const MemberPromotedSuccess(groupId: 'group1', userId: 'user1'),
      ],
      verify: (_) {
        verify(() => mockGroupRepository.getGroupById('group1')).called(1);
        verify(() => mockGroupRepository.promoteToAdmin('group1', 'user1'))
            .called(1);
      },
    );

    blocTest<GroupMemberBloc, GroupMemberState>(
      'emits [loading, error] when group is not found',
      build: () {
        when(() => mockGroupRepository.getGroupById('group1'))
            .thenAnswer((_) async => null);
        return bloc;
      },
      act: (bloc) => bloc.add(const PromoteMemberToAdmin(
        groupId: 'group1',
        userId: 'user1',
      )),
      expect: () => [
        const GroupMemberLoading(),
        const GroupMemberError('Group not found'),
      ],
      verify: (_) {
        verify(() => mockGroupRepository.getGroupById('group1')).called(1);
        verifyNever(() => mockGroupRepository.promoteToAdmin(any(), any()));
      },
    );

    blocTest<GroupMemberBloc, GroupMemberState>(
      'emits [loading, error] when user is not a member',
      build: () {
        when(() => mockGroupRepository.getGroupById('group1'))
            .thenAnswer((_) async => testGroup);
        return bloc;
      },
      act: (bloc) => bloc.add(const PromoteMemberToAdmin(
        groupId: 'group1',
        userId: 'nonMember123',
      )),
      expect: () => [
        const GroupMemberLoading(),
        const GroupMemberError('User is not a member of this group'),
      ],
      verify: (_) {
        verify(() => mockGroupRepository.getGroupById('group1')).called(1);
        verifyNever(() => mockGroupRepository.promoteToAdmin(any(), any()));
      },
    );

    blocTest<GroupMemberBloc, GroupMemberState>(
      'emits [loading, error] when user is already an admin',
      build: () {
        when(() => mockGroupRepository.getGroupById('group1'))
            .thenAnswer((_) async => testGroup);
        return bloc;
      },
      act: (bloc) => bloc.add(const PromoteMemberToAdmin(
        groupId: 'group1',
        userId: 'admin1',
      )),
      expect: () => [
        const GroupMemberLoading(),
        const GroupMemberError('User is already an admin'),
      ],
      verify: (_) {
        verify(() => mockGroupRepository.getGroupById('group1')).called(1);
        verifyNever(() => mockGroupRepository.promoteToAdmin(any(), any()));
      },
    );

    blocTest<GroupMemberBloc, GroupMemberState>(
      'emits [loading, error] when repository throws exception',
      build: () {
        when(() => mockGroupRepository.getGroupById('group1'))
            .thenAnswer((_) async => testGroup);
        when(() => mockGroupRepository.promoteToAdmin('group1', 'user1'))
            .thenThrow(Exception('Network error'));
        return bloc;
      },
      act: (bloc) => bloc.add(const PromoteMemberToAdmin(
        groupId: 'group1',
        userId: 'user1',
      )),
      expect: () => [
        const GroupMemberLoading(),
        const GroupMemberError('Failed to promote member: Exception: Network error'),
      ],
    );
  });

  group('DemoteMemberFromAdmin', () {
    blocTest<GroupMemberBloc, GroupMemberState>(
      'emits [loading, success] when admin is successfully demoted',
      build: () {
        when(() => mockGroupRepository.getGroupById('group1'))
            .thenAnswer((_) async => testGroup);
        when(() => mockGroupRepository.demoteFromAdmin('group1', 'admin1'))
            .thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) => bloc.add(const DemoteMemberFromAdmin(
        groupId: 'group1',
        userId: 'admin1',
      )),
      expect: () => [
        const GroupMemberLoading(),
        const MemberDemotedSuccess(groupId: 'group1', userId: 'admin1'),
      ],
      verify: (_) {
        verify(() => mockGroupRepository.getGroupById('group1')).called(1);
        verify(() => mockGroupRepository.demoteFromAdmin('group1', 'admin1'))
            .called(1);
      },
    );

    blocTest<GroupMemberBloc, GroupMemberState>(
      'emits [loading, error] when group is not found',
      build: () {
        when(() => mockGroupRepository.getGroupById('group1'))
            .thenAnswer((_) async => null);
        return bloc;
      },
      act: (bloc) => bloc.add(const DemoteMemberFromAdmin(
        groupId: 'group1',
        userId: 'admin1',
      )),
      expect: () => [
        const GroupMemberLoading(),
        const GroupMemberError('Group not found'),
      ],
      verify: (_) {
        verify(() => mockGroupRepository.getGroupById('group1')).called(1);
        verifyNever(() => mockGroupRepository.demoteFromAdmin(any(), any()));
      },
    );

    blocTest<GroupMemberBloc, GroupMemberState>(
      'emits [loading, error] when user is not an admin',
      build: () {
        when(() => mockGroupRepository.getGroupById('group1'))
            .thenAnswer((_) async => testGroup);
        return bloc;
      },
      act: (bloc) => bloc.add(const DemoteMemberFromAdmin(
        groupId: 'group1',
        userId: 'user1',
      )),
      expect: () => [
        const GroupMemberLoading(),
        const GroupMemberError('User is not an admin'),
      ],
      verify: (_) {
        verify(() => mockGroupRepository.getGroupById('group1')).called(1);
        verifyNever(() => mockGroupRepository.demoteFromAdmin(any(), any()));
      },
    );

    blocTest<GroupMemberBloc, GroupMemberState>(
      'emits [loading, error] when trying to demote last admin',
      build: () {
        final singleAdminGroup = testGroup.copyWith(adminIds: ['creator123']);
        when(() => mockGroupRepository.getGroupById('group1'))
            .thenAnswer((_) async => singleAdminGroup);
        return bloc;
      },
      act: (bloc) => bloc.add(const DemoteMemberFromAdmin(
        groupId: 'group1',
        userId: 'creator123',
      )),
      expect: () => [
        const GroupMemberLoading(),
        const GroupMemberError(
            'Cannot demote the last admin. Promote another member first.'),
      ],
      verify: (_) {
        verify(() => mockGroupRepository.getGroupById('group1')).called(1);
        verifyNever(() => mockGroupRepository.demoteFromAdmin(any(), any()));
      },
    );

    blocTest<GroupMemberBloc, GroupMemberState>(
      'emits [loading, error] when trying to demote group creator',
      build: () {
        when(() => mockGroupRepository.getGroupById('group1'))
            .thenAnswer((_) async => testGroup);
        return bloc;
      },
      act: (bloc) => bloc.add(const DemoteMemberFromAdmin(
        groupId: 'group1',
        userId: 'creator123',
      )),
      expect: () => [
        const GroupMemberLoading(),
        const GroupMemberError('Cannot demote the group creator'),
      ],
      verify: (_) {
        verify(() => mockGroupRepository.getGroupById('group1')).called(1);
        verifyNever(() => mockGroupRepository.demoteFromAdmin(any(), any()));
      },
    );

    blocTest<GroupMemberBloc, GroupMemberState>(
      'emits [loading, error] when repository throws exception',
      build: () {
        when(() => mockGroupRepository.getGroupById('group1'))
            .thenAnswer((_) async => testGroup);
        when(() => mockGroupRepository.demoteFromAdmin('group1', 'admin1'))
            .thenThrow(Exception('Network error'));
        return bloc;
      },
      act: (bloc) => bloc.add(const DemoteMemberFromAdmin(
        groupId: 'group1',
        userId: 'admin1',
      )),
      expect: () => [
        const GroupMemberLoading(),
        const GroupMemberError('Failed to demote member: Exception: Network error'),
      ],
    );
  });

  group('RemoveMemberFromGroup', () {
    blocTest<GroupMemberBloc, GroupMemberState>(
      'emits [loading, success] when member is successfully removed',
      build: () {
        when(() => mockGroupRepository.getGroupById('group1'))
            .thenAnswer((_) async => testGroup);
        when(() => mockGroupRepository.removeMember('group1', 'user1'))
            .thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) => bloc.add(const RemoveMemberFromGroup(
        groupId: 'group1',
        userId: 'user1',
      )),
      expect: () => [
        const GroupMemberLoading(),
        const MemberRemovedSuccess(groupId: 'group1', userId: 'user1'),
      ],
      verify: (_) {
        verify(() => mockGroupRepository.getGroupById('group1')).called(1);
        verify(() => mockGroupRepository.removeMember('group1', 'user1'))
            .called(1);
      },
    );

    blocTest<GroupMemberBloc, GroupMemberState>(
      'emits [loading, error] when group is not found',
      build: () {
        when(() => mockGroupRepository.getGroupById('group1'))
            .thenAnswer((_) async => null);
        return bloc;
      },
      act: (bloc) => bloc.add(const RemoveMemberFromGroup(
        groupId: 'group1',
        userId: 'user1',
      )),
      expect: () => [
        const GroupMemberLoading(),
        const GroupMemberError('Group not found'),
      ],
      verify: (_) {
        verify(() => mockGroupRepository.getGroupById('group1')).called(1);
        verifyNever(() => mockGroupRepository.removeMember(any(), any()));
      },
    );

    blocTest<GroupMemberBloc, GroupMemberState>(
      'emits [loading, error] when user is not a member',
      build: () {
        when(() => mockGroupRepository.getGroupById('group1'))
            .thenAnswer((_) async => testGroup);
        return bloc;
      },
      act: (bloc) => bloc.add(const RemoveMemberFromGroup(
        groupId: 'group1',
        userId: 'nonMember123',
      )),
      expect: () => [
        const GroupMemberLoading(),
        const GroupMemberError('User is not a member of this group'),
      ],
      verify: (_) {
        verify(() => mockGroupRepository.getGroupById('group1')).called(1);
        verifyNever(() => mockGroupRepository.removeMember(any(), any()));
      },
    );

    blocTest<GroupMemberBloc, GroupMemberState>(
      'emits [loading, error] when trying to remove last admin',
      build: () {
        final singleAdminGroup = testGroup.copyWith(adminIds: ['admin1']);
        when(() => mockGroupRepository.getGroupById('group1'))
            .thenAnswer((_) async => singleAdminGroup);
        return bloc;
      },
      act: (bloc) => bloc.add(const RemoveMemberFromGroup(
        groupId: 'group1',
        userId: 'admin1',
      )),
      expect: () => [
        const GroupMemberLoading(),
        const GroupMemberError(
            'Cannot remove the last admin. Promote another member first.'),
      ],
      verify: (_) {
        verify(() => mockGroupRepository.getGroupById('group1')).called(1);
        verifyNever(() => mockGroupRepository.removeMember(any(), any()));
      },
    );

    blocTest<GroupMemberBloc, GroupMemberState>(
      'emits [loading, success] when removing admin with other admins present',
      build: () {
        when(() => mockGroupRepository.getGroupById('group1'))
            .thenAnswer((_) async => testGroup);
        when(() => mockGroupRepository.removeMember('group1', 'admin1'))
            .thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) => bloc.add(const RemoveMemberFromGroup(
        groupId: 'group1',
        userId: 'admin1',
      )),
      expect: () => [
        const GroupMemberLoading(),
        const MemberRemovedSuccess(groupId: 'group1', userId: 'admin1'),
      ],
      verify: (_) {
        verify(() => mockGroupRepository.getGroupById('group1')).called(1);
        verify(() => mockGroupRepository.removeMember('group1', 'admin1'))
            .called(1);
      },
    );

    blocTest<GroupMemberBloc, GroupMemberState>(
      'emits [loading, error] when repository throws exception',
      build: () {
        when(() => mockGroupRepository.getGroupById('group1'))
            .thenAnswer((_) async => testGroup);
        when(() => mockGroupRepository.removeMember('group1', 'user1'))
            .thenThrow(Exception('Network error'));
        return bloc;
      },
      act: (bloc) => bloc.add(const RemoveMemberFromGroup(
        groupId: 'group1',
        userId: 'user1',
      )),
      expect: () => [
        const GroupMemberLoading(),
        const GroupMemberError('Failed to remove member: Exception: Network error'),
      ],
    );
  });

  group('LeaveGroup', () {
    blocTest<GroupMemberBloc, GroupMemberState>(
      'emits [loading, success] when user successfully leaves group',
      build: () {
        when(() => mockGroupRepository.leaveGroup('group1'))
            .thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) => bloc.add(const LeaveGroup(
        groupId: 'group1',
        userId: 'user1',
      )),
      expect: () => [
        const GroupMemberLoading(),
        const UserLeftGroupSuccess(groupId: 'group1'),
      ],
      verify: (_) {
        verify(() => mockGroupRepository.leaveGroup('group1')).called(1);
      },
    );

    blocTest<GroupMemberBloc, GroupMemberState>(
      'emits [loading, error] when group not found',
      build: () {
        when(() => mockGroupRepository.leaveGroup('group1'))
            .thenThrow(Exception('Group not found'));
        return bloc;
      },
      act: (bloc) => bloc.add(const LeaveGroup(
        groupId: 'group1',
        userId: 'user1',
      )),
      expect: () => [
        const GroupMemberLoading(),
        const GroupMemberError('Group not found'),
      ],
      verify: (_) {
        verify(() => mockGroupRepository.leaveGroup('group1')).called(1);
      },
    );

    blocTest<GroupMemberBloc, GroupMemberState>(
      'emits [loading, error] when user is not a member',
      build: () {
        when(() => mockGroupRepository.leaveGroup('group1'))
            .thenThrow(Exception('You are not a member of this group'));
        return bloc;
      },
      act: (bloc) => bloc.add(const LeaveGroup(
        groupId: 'group1',
        userId: 'nonMember123',
      )),
      expect: () => [
        const GroupMemberLoading(),
        const GroupMemberError('You are not a member of this group'),
      ],
      verify: (_) {
        verify(() => mockGroupRepository.leaveGroup('group1')).called(1);
      },
    );

    blocTest<GroupMemberBloc, GroupMemberState>(
      'emits [loading, error] when user is last admin trying to leave',
      build: () {
        when(() => mockGroupRepository.leaveGroup('group1'))
            .thenThrow(Exception(
                'Cannot leave group as the last admin. Promote another member to admin first.'));
        return bloc;
      },
      act: (bloc) => bloc.add(const LeaveGroup(
        groupId: 'group1',
        userId: 'user1',
      )),
      expect: () => [
        const GroupMemberLoading(),
        const GroupMemberError(
            'Cannot leave group as the last admin. Promote another member to admin first.'),
      ],
      verify: (_) {
        verify(() => mockGroupRepository.leaveGroup('group1')).called(1);
      },
    );

    blocTest<GroupMemberBloc, GroupMemberState>(
      'emits [loading, error] when creator is last admin trying to leave',
      build: () {
        when(() => mockGroupRepository.leaveGroup('group1'))
            .thenThrow(Exception(
                'Cannot leave group as the last admin. Promote another member to admin first.'));
        return bloc;
      },
      act: (bloc) => bloc.add(const LeaveGroup(
        groupId: 'group1',
        userId: 'creator123',
      )),
      expect: () => [
        const GroupMemberLoading(),
        const GroupMemberError(
            'Cannot leave group as the last admin. Promote another member to admin first.'),
      ],
      verify: (_) {
        verify(() => mockGroupRepository.leaveGroup('group1')).called(1);
      },
    );

    blocTest<GroupMemberBloc, GroupMemberState>(
      'emits [loading, success] when admin leaves but other admins present',
      build: () {
        when(() => mockGroupRepository.leaveGroup('group1'))
            .thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) => bloc.add(const LeaveGroup(
        groupId: 'group1',
        userId: 'admin1',
      )),
      expect: () => [
        const GroupMemberLoading(),
        const UserLeftGroupSuccess(groupId: 'group1'),
      ],
      verify: (_) {
        verify(() => mockGroupRepository.leaveGroup('group1')).called(1);
      },
    );

    blocTest<GroupMemberBloc, GroupMemberState>(
      'emits [loading, error] when repository throws exception',
      build: () {
        when(() => mockGroupRepository.leaveGroup('group1'))
            .thenThrow(Exception('Network error'));
        return bloc;
      },
      act: (bloc) => bloc.add(const LeaveGroup(
        groupId: 'group1',
        userId: 'user1',
      )),
      expect: () => [
        const GroupMemberLoading(),
        const GroupMemberError('Network error'),
      ],
    );
  });

  group('GroupMemberBloc initial state', () {
    test('initial state is GroupMemberInitial', () {
      expect(bloc.state, const GroupMemberInitial());
    });
  });
}
