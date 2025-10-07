import '../base_bloc_event.dart';
import '../../../data/models/group_model.dart';

abstract class GroupEvent extends BaseBlocEvent {
  const GroupEvent();
}

class LoadGroupById extends GroupEvent {
  final String groupId;

  const LoadGroupById({required this.groupId});

  @override
  List<Object?> get props => [groupId];
}

class LoadGroupsForUser extends GroupEvent {
  final String userId;

  const LoadGroupsForUser({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class CreateGroup extends GroupEvent {
  final GroupModel group;

  const CreateGroup({required this.group});

  @override
  List<Object?> get props => [group];
}

class UpdateGroupInfo extends GroupEvent {
  final String groupId;
  final String? name;
  final String? description;
  final String? photoUrl;
  final String? location;

  const UpdateGroupInfo({
    required this.groupId,
    this.name,
    this.description,
    this.photoUrl,
    this.location,
  });

  @override
  List<Object?> get props => [groupId, name, description, photoUrl, location];
}

class UpdateGroupSettings extends GroupEvent {
  final String groupId;
  final GroupPrivacy? privacy;
  final bool? requiresApproval;
  final int? maxMembers;
  final bool? allowMembersToCreateGames;
  final bool? allowMembersToInviteOthers;
  final bool? notifyMembersOfNewGames;

  const UpdateGroupSettings({
    required this.groupId,
    this.privacy,
    this.requiresApproval,
    this.maxMembers,
    this.allowMembersToCreateGames,
    this.allowMembersToInviteOthers,
    this.notifyMembersOfNewGames,
  });

  @override
  List<Object?> get props => [
        groupId,
        privacy,
        requiresApproval,
        maxMembers,
        allowMembersToCreateGames,
        allowMembersToInviteOthers,
        notifyMembersOfNewGames,
      ];
}

class AddMemberToGroup extends GroupEvent {
  final String groupId;
  final String userId;

  const AddMemberToGroup({
    required this.groupId,
    required this.userId,
  });

  @override
  List<Object?> get props => [groupId, userId];
}

class RemoveMemberFromGroup extends GroupEvent {
  final String groupId;
  final String userId;

  const RemoveMemberFromGroup({
    required this.groupId,
    required this.userId,
  });

  @override
  List<Object?> get props => [groupId, userId];
}

class PromoteToAdmin extends GroupEvent {
  final String groupId;
  final String userId;

  const PromoteToAdmin({
    required this.groupId,
    required this.userId,
  });

  @override
  List<Object?> get props => [groupId, userId];
}

class DemoteFromAdmin extends GroupEvent {
  final String groupId;
  final String userId;

  const DemoteFromAdmin({
    required this.groupId,
    required this.userId,
  });

  @override
  List<Object?> get props => [groupId, userId];
}

class SearchPublicGroups extends GroupEvent {
  final String query;
  final int limit;

  const SearchPublicGroups({
    required this.query,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [query, limit];
}

class LoadGroupStats extends GroupEvent {
  final String groupId;

  const LoadGroupStats({required this.groupId});

  @override
  List<Object?> get props => [groupId];
}

class DeleteGroup extends GroupEvent {
  final String groupId;

  const DeleteGroup({required this.groupId});

  @override
  List<Object?> get props => [groupId];
}