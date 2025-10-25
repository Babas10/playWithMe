import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/group_repository.dart';
import '../../../data/models/group_model.dart';
import 'group_event.dart';
import 'group_state.dart';

class GroupBloc extends Bloc<GroupEvent, GroupState> {
  final GroupRepository _groupRepository;
  StreamSubscription<dynamic>? _groupsSubscription;

  GroupBloc({required GroupRepository groupRepository})
      : _groupRepository = groupRepository,
        super(const GroupInitial()) {
    on<LoadGroupById>(_onLoadGroupById);
    on<LoadGroupsForUser>(_onLoadGroupsForUser);
    on<CreateGroup>(_onCreateGroup);
    on<UpdateGroupInfo>(_onUpdateGroupInfo);
    on<UpdateGroupSettings>(_onUpdateGroupSettings);
    on<AddMemberToGroup>(_onAddMemberToGroup);
    on<RemoveMemberFromGroup>(_onRemoveMemberFromGroup);
    on<PromoteToAdmin>(_onPromoteToAdmin);
    on<DemoteFromAdmin>(_onDemoteFromAdmin);
    on<SearchPublicGroups>(_onSearchPublicGroups);
    on<LoadGroupStats>(_onLoadGroupStats);
    on<DeleteGroup>(_onDeleteGroup);
  }

  Future<void> _onLoadGroupById(
    LoadGroupById event,
    Emitter<GroupState> emit,
  ) async {
    try {
      emit(const GroupLoading());

      final group = await _groupRepository.getGroupById(event.groupId);
      if (group != null) {
        emit(GroupLoaded(group: group));
      } else {
        emit(const GroupNotFound(message: 'Group not found'));
      }
    } catch (e) {
      emit(GroupError(
        message: 'Failed to load group: ${e.toString()}',
        errorCode: 'LOAD_GROUP_ERROR',
      ));
    }
  }

  Future<void> _onLoadGroupsForUser(
    LoadGroupsForUser event,
    Emitter<GroupState> emit,
  ) async {

    // Cancel existing subscription
    await _groupsSubscription?.cancel();

    try {
      final stream = _groupRepository.getGroupsForUser(event.userId);

      // Use emit.forEach to keep the emitter alive and automatically emit states
      await emit.forEach<List<GroupModel>>(
        stream,
        onData: (groups) {
          for (var i = 0; i < groups.length; i++) {
          }
          return GroupsLoaded(groups: groups);
        },
        onError: (error, stackTrace) {
          return GroupError(
            message: 'Failed to load user groups: ${error.toString()}',
            errorCode: 'LOAD_USER_GROUPS_ERROR',
          );
        },
      );
    } catch (e) {
      emit(GroupError(
        message: 'Failed to load user groups: ${e.toString()}',
        errorCode: 'LOAD_USER_GROUPS_ERROR',
      ));
    }
  }

  Future<void> _onCreateGroup(
    CreateGroup event,
    Emitter<GroupState> emit,
  ) async {
    try {
      emit(const GroupLoading());

      final groupId = await _groupRepository.createGroup(event.group);
      final createdGroup = event.group.copyWith(id: groupId);

      emit(GroupCreated(
        groupId: groupId,
        group: createdGroup,
      ));
    } catch (e) {
      emit(GroupError(
        message: 'Failed to create group: ${e.toString()}',
        errorCode: 'CREATE_GROUP_ERROR',
      ));
    }
  }

  Future<void> _onUpdateGroupInfo(
    UpdateGroupInfo event,
    Emitter<GroupState> emit,
  ) async {
    try {
      emit(const GroupLoading());

      await _groupRepository.updateGroupInfo(
        event.groupId,
        name: event.name,
        description: event.description,
        photoUrl: event.photoUrl,
        location: event.location,
      );

      final updatedGroup = await _groupRepository.getGroupById(event.groupId);
      if (updatedGroup != null) {
        emit(GroupUpdated(
          group: updatedGroup,
          message: 'Group information updated successfully',
        ));
      } else {
        emit(const GroupOperationSuccess(
          message: 'Group information updated successfully',
        ));
      }
    } catch (e) {
      emit(GroupError(
        message: 'Failed to update group info: ${e.toString()}',
        errorCode: 'UPDATE_GROUP_INFO_ERROR',
      ));
    }
  }

  Future<void> _onUpdateGroupSettings(
    UpdateGroupSettings event,
    Emitter<GroupState> emit,
  ) async {
    try {
      emit(const GroupLoading());

      await _groupRepository.updateGroupSettings(
        event.groupId,
        privacy: event.privacy,
        requiresApproval: event.requiresApproval,
        maxMembers: event.maxMembers,
        allowMembersToCreateGames: event.allowMembersToCreateGames,
        allowMembersToInviteOthers: event.allowMembersToInviteOthers,
        notifyMembersOfNewGames: event.notifyMembersOfNewGames,
      );

      final updatedGroup = await _groupRepository.getGroupById(event.groupId);
      if (updatedGroup != null) {
        emit(GroupUpdated(
          group: updatedGroup,
          message: 'Group settings updated successfully',
        ));
      } else {
        emit(const GroupOperationSuccess(
          message: 'Group settings updated successfully',
        ));
      }
    } catch (e) {
      emit(GroupError(
        message: 'Failed to update group settings: ${e.toString()}',
        errorCode: 'UPDATE_GROUP_SETTINGS_ERROR',
      ));
    }
  }

  Future<void> _onAddMemberToGroup(
    AddMemberToGroup event,
    Emitter<GroupState> emit,
  ) async {
    try {
      emit(const GroupLoading());

      await _groupRepository.addMember(event.groupId, event.userId);

      final updatedGroup = await _groupRepository.getGroupById(event.groupId);
      if (updatedGroup != null) {
        emit(GroupUpdated(
          group: updatedGroup,
          message: 'Member added successfully',
        ));
      } else {
        emit(const GroupOperationSuccess(
          message: 'Member added successfully',
        ));
      }
    } catch (e) {
      emit(GroupError(
        message: 'Failed to add member: ${e.toString()}',
        errorCode: 'ADD_MEMBER_ERROR',
      ));
    }
  }

  Future<void> _onRemoveMemberFromGroup(
    RemoveMemberFromGroup event,
    Emitter<GroupState> emit,
  ) async {
    try {
      emit(const GroupLoading());

      await _groupRepository.removeMember(event.groupId, event.userId);

      final updatedGroup = await _groupRepository.getGroupById(event.groupId);
      if (updatedGroup != null) {
        emit(GroupUpdated(
          group: updatedGroup,
          message: 'Member removed successfully',
        ));
      } else {
        emit(const GroupOperationSuccess(
          message: 'Member removed successfully',
        ));
      }
    } catch (e) {
      emit(GroupError(
        message: 'Failed to remove member: ${e.toString()}',
        errorCode: 'REMOVE_MEMBER_ERROR',
      ));
    }
  }

  Future<void> _onPromoteToAdmin(
    PromoteToAdmin event,
    Emitter<GroupState> emit,
  ) async {
    try {
      emit(const GroupLoading());

      await _groupRepository.promoteToAdmin(event.groupId, event.userId);

      final updatedGroup = await _groupRepository.getGroupById(event.groupId);
      if (updatedGroup != null) {
        emit(GroupUpdated(
          group: updatedGroup,
          message: 'Member promoted to admin successfully',
        ));
      } else {
        emit(const GroupOperationSuccess(
          message: 'Member promoted to admin successfully',
        ));
      }
    } catch (e) {
      emit(GroupError(
        message: 'Failed to promote member: ${e.toString()}',
        errorCode: 'PROMOTE_MEMBER_ERROR',
      ));
    }
  }

  Future<void> _onDemoteFromAdmin(
    DemoteFromAdmin event,
    Emitter<GroupState> emit,
  ) async {
    try {
      emit(const GroupLoading());

      await _groupRepository.demoteFromAdmin(event.groupId, event.userId);

      final updatedGroup = await _groupRepository.getGroupById(event.groupId);
      if (updatedGroup != null) {
        emit(GroupUpdated(
          group: updatedGroup,
          message: 'Admin demoted successfully',
        ));
      } else {
        emit(const GroupOperationSuccess(
          message: 'Admin demoted successfully',
        ));
      }
    } catch (e) {
      emit(GroupError(
        message: 'Failed to demote admin: ${e.toString()}',
        errorCode: 'DEMOTE_ADMIN_ERROR',
      ));
    }
  }

  Future<void> _onSearchPublicGroups(
    SearchPublicGroups event,
    Emitter<GroupState> emit,
  ) async {
    try {
      emit(const GroupLoading());

      final groups = await _groupRepository.searchPublicGroups(
        event.query,
        limit: event.limit,
      );

      emit(GroupsLoaded(groups: groups));
    } catch (e) {
      emit(GroupError(
        message: 'Failed to search groups: ${e.toString()}',
        errorCode: 'SEARCH_GROUPS_ERROR',
      ));
    }
  }

  Future<void> _onLoadGroupStats(
    LoadGroupStats event,
    Emitter<GroupState> emit,
  ) async {
    try {
      emit(const GroupLoading());

      final stats = await _groupRepository.getGroupStats(event.groupId);
      emit(GroupStatsLoaded(stats: stats));
    } catch (e) {
      emit(GroupError(
        message: 'Failed to load group stats: ${e.toString()}',
        errorCode: 'LOAD_GROUP_STATS_ERROR',
      ));
    }
  }

  Future<void> _onDeleteGroup(
    DeleteGroup event,
    Emitter<GroupState> emit,
  ) async {
    try {
      emit(const GroupLoading());

      await _groupRepository.deleteGroup(event.groupId);

      emit(const GroupOperationSuccess(
        message: 'Group deleted successfully',
      ));
    } catch (e) {
      emit(GroupError(
        message: 'Failed to delete group: ${e.toString()}',
        errorCode: 'DELETE_GROUP_ERROR',
      ));
    }
  }

  @override
  Future<void> close() {
    _groupsSubscription?.cancel();
    return super.close();
  }
}