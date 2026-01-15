// BLoC for managing group member operations (promote, demote, remove)
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/core/domain/repositories/group_repository.dart';
import 'group_member_event.dart';
import 'group_member_state.dart';

class GroupMemberBloc extends Bloc<GroupMemberEvent, GroupMemberState> {
  final GroupRepository _groupRepository;

  GroupMemberBloc({
    required GroupRepository groupRepository,
  })  : _groupRepository = groupRepository,
        super(const GroupMemberInitial()) {
    on<PromoteMemberToAdmin>(_onPromoteMemberToAdmin);
    on<DemoteMemberFromAdmin>(_onDemoteMemberFromAdmin);
    on<RemoveMemberFromGroup>(_onRemoveMemberFromGroup);
    on<LeaveGroup>(_onLeaveGroup);
  }

  Future<void> _onPromoteMemberToAdmin(
    PromoteMemberToAdmin event,
    Emitter<GroupMemberState> emit,
  ) async {
    emit(const GroupMemberLoading());

    try {
      // Fetch the group to validate the operation
      final group = await _groupRepository.getGroupById(event.groupId);

      if (group == null) {
        emit(const GroupMemberError('Group not found'));
        return;
      }

      // Validate that the user is a member
      if (!group.isMember(event.userId)) {
        emit(const GroupMemberError('User is not a member of this group'));
        return;
      }

      // Validate that the user is not already an admin
      if (group.isAdmin(event.userId)) {
        emit(const GroupMemberError('User is already an admin'));
        return;
      }

      await _groupRepository.promoteToAdmin(event.groupId, event.userId);

      emit(MemberPromotedSuccess(
        groupId: event.groupId,
        userId: event.userId,
      ));
    } catch (e) {
      emit(GroupMemberError('Failed to promote member: ${e.toString()}'));
    }
  }

  Future<void> _onDemoteMemberFromAdmin(
    DemoteMemberFromAdmin event,
    Emitter<GroupMemberState> emit,
  ) async {
    emit(const GroupMemberLoading());

    try {
      // Fetch the group to validate the operation
      final group = await _groupRepository.getGroupById(event.groupId);

      if (group == null) {
        emit(const GroupMemberError('Group not found'));
        return;
      }

      // Validate that the user is currently an admin
      if (!group.isAdmin(event.userId)) {
        emit(const GroupMemberError('User is not an admin'));
        return;
      }

      // Prevent demoting the last admin
      if (group.adminCount <= 1) {
        emit(const GroupMemberError('Cannot demote the last admin. Promote another member first.'));
        return;
      }

      // Prevent demoting the creator
      if (group.createdBy == event.userId) {
        emit(const GroupMemberError('Cannot demote the group creator'));
        return;
      }

      await _groupRepository.demoteFromAdmin(event.groupId, event.userId);

      emit(MemberDemotedSuccess(
        groupId: event.groupId,
        userId: event.userId,
      ));
    } catch (e) {
      emit(GroupMemberError('Failed to demote member: ${e.toString()}'));
    }
  }

  Future<void> _onRemoveMemberFromGroup(
    RemoveMemberFromGroup event,
    Emitter<GroupMemberState> emit,
  ) async {
    emit(const GroupMemberLoading());

    try {
      // Fetch the group to validate the operation
      final group = await _groupRepository.getGroupById(event.groupId);

      if (group == null) {
        emit(const GroupMemberError('Group not found'));
        return;
      }

      // Validate that the user is a member
      if (!group.isMember(event.userId)) {
        emit(const GroupMemberError('User is not a member of this group'));
        return;
      }

      // If user is an admin, check if they're the last admin
      if (group.isAdmin(event.userId) && group.adminCount <= 1) {
        emit(const GroupMemberError('Cannot remove the last admin. Promote another member first.'));
        return;
      }

      await _groupRepository.removeMember(event.groupId, event.userId);

      emit(MemberRemovedSuccess(
        groupId: event.groupId,
        userId: event.userId,
      ));
    } catch (e) {
      emit(GroupMemberError('Failed to remove member: ${e.toString()}'));
    }
  }

  Future<void> _onLeaveGroup(
    LeaveGroup event,
    Emitter<GroupMemberState> emit,
  ) async {
    emit(const GroupMemberLoading());

    try {
      // Call the leaveGroup Cloud Function which handles all validation
      await _groupRepository.leaveGroup(event.groupId);

      emit(UserLeftGroupSuccess(groupId: event.groupId));
    } catch (e) {
      // Extract the meaningful error message
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring('Exception: '.length);
      }

      // Ensure we show a group-specific error message
      // This prevents confusion with other features (e.g., training sessions)
      if (!errorMessage.toLowerCase().contains('group')) {
        errorMessage = 'Failed to leave group. Please try again.';
      }

      emit(GroupMemberError(errorMessage));
    }
  }
}
