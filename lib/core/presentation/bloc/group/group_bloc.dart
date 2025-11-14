import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/group_repository.dart';
import '../../../domain/repositories/invitation_repository.dart';
import '../../../data/models/group_model.dart';
import '../../../utils/error_messages.dart';
import 'group_event.dart';
import 'group_state.dart';

class GroupBloc extends Bloc<GroupEvent, GroupState> {
  final GroupRepository _groupRepository;
  final InvitationRepository? _invitationRepository;
  StreamSubscription<dynamic>? _groupsSubscription;

  GroupBloc({
    required GroupRepository groupRepository,
    InvitationRepository? invitationRepository,
  })  : _groupRepository = groupRepository,
        _invitationRepository = invitationRepository,
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
      final (message, isRetryable) = e is Exception
          ? GroupErrorMessages.getErrorMessage(e)
          : ('Failed to load group', true);
      emit(GroupError(
        message: message,
        errorCode: 'LOAD_GROUP_ERROR',
        isRetryable: isRetryable,
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
          final (message, isRetryable) = error is Exception
              ? GroupErrorMessages.getErrorMessage(error)
              : ('Failed to load user groups', true);
          return GroupError(
            message: message,
            errorCode: 'LOAD_USER_GROUPS_ERROR',
            isRetryable: isRetryable,
          );
        },
      );
    } catch (e) {
      final (message, isRetryable) = e is Exception
          ? GroupErrorMessages.getErrorMessage(e)
          : ('Failed to load user groups', true);
      emit(GroupError(
        message: message,
        errorCode: 'LOAD_USER_GROUPS_ERROR',
        isRetryable: isRetryable,
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

      // Send invitations to selected friends
      if (event.friendIdsToInvite != null &&
          event.friendIdsToInvite!.isNotEmpty &&
          _invitationRepository != null) {
        try {
          for (final friendId in event.friendIdsToInvite!) {
            await _invitationRepository!.sendInvitation(
              groupId: groupId,
              groupName: createdGroup.name,
              invitedUserId: friendId,
              invitedBy: createdGroup.createdBy,
              inviterName: '', // Will be filled by backend from user document
            );
          }
        } catch (inviteError) {
          // Log invitation errors but don't fail group creation
          // Group was created successfully, invitation failures are non-critical
          // Using print for now - consider using a proper logger in production
          // ignore: avoid_print
          print('⚠️ Warning: Failed to send invitations during group creation: $inviteError');
        }
      }

      emit(GroupCreated(
        groupId: groupId,
        group: createdGroup,
      ));
    } catch (e) {
      final (message, isRetryable) = e is Exception
          ? GroupErrorMessages.getErrorMessage(e)
          : ('Failed to create group', true);
      emit(GroupError(
        message: message,
        errorCode: 'CREATE_GROUP_ERROR',
        isRetryable: isRetryable,
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
      final (message, isRetryable) = e is Exception
          ? GroupErrorMessages.getErrorMessage(e)
          : ('Failed to update group info', true);
      emit(GroupError(
        message: message,
        errorCode: 'UPDATE_GROUP_INFO_ERROR',
        isRetryable: isRetryable,
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
      final (message, isRetryable) = e is Exception
          ? GroupErrorMessages.getErrorMessage(e)
          : ('Failed to update group settings', true);
      emit(GroupError(
        message: message,
        errorCode: 'UPDATE_GROUP_SETTINGS_ERROR',
        isRetryable: isRetryable,
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
      final (message, isRetryable) = e is Exception
          ? GroupErrorMessages.getErrorMessage(e)
          : ('Failed to add member', true);
      emit(GroupError(
        message: message,
        errorCode: 'ADD_MEMBER_ERROR',
        isRetryable: isRetryable,
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
      final (message, isRetryable) = e is Exception
          ? GroupErrorMessages.getErrorMessage(e)
          : ('Failed to remove member', true);
      emit(GroupError(
        message: message,
        errorCode: 'REMOVE_MEMBER_ERROR',
        isRetryable: isRetryable,
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
      final (message, isRetryable) = e is Exception
          ? GroupErrorMessages.getErrorMessage(e)
          : ('Failed to promote member', true);
      emit(GroupError(
        message: message,
        errorCode: 'PROMOTE_MEMBER_ERROR',
        isRetryable: isRetryable,
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
      final (message, isRetryable) = e is Exception
          ? GroupErrorMessages.getErrorMessage(e)
          : ('Failed to demote admin', true);
      emit(GroupError(
        message: message,
        errorCode: 'DEMOTE_ADMIN_ERROR',
        isRetryable: isRetryable,
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
      final (message, isRetryable) = e is Exception
          ? GroupErrorMessages.getErrorMessage(e)
          : ('Failed to search groups', true);
      emit(GroupError(
        message: message,
        errorCode: 'SEARCH_GROUPS_ERROR',
        isRetryable: isRetryable,
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
      final (message, isRetryable) = e is Exception
          ? GroupErrorMessages.getErrorMessage(e)
          : ('Failed to load group stats', true);
      emit(GroupError(
        message: message,
        errorCode: 'LOAD_GROUP_STATS_ERROR',
        isRetryable: isRetryable,
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
      final (message, isRetryable) = e is Exception
          ? GroupErrorMessages.getErrorMessage(e)
          : ('Failed to delete group', true);
      emit(GroupError(
        message: message,
        errorCode: 'DELETE_GROUP_ERROR',
        isRetryable: isRetryable,
      ));
    }
  }

  @override
  Future<void> close() {
    _groupsSubscription?.cancel();
    return super.close();
  }
}