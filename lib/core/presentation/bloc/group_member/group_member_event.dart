// Events for group member management operations
import 'package:equatable/equatable.dart';

abstract class GroupMemberEvent extends Equatable {
  const GroupMemberEvent();

  @override
  List<Object?> get props => [];
}

/// Event to promote a member to admin
class PromoteMemberToAdmin extends GroupMemberEvent {
  final String groupId;
  final String userId;

  const PromoteMemberToAdmin({
    required this.groupId,
    required this.userId,
  });

  @override
  List<Object?> get props => [groupId, userId];
}

/// Event to demote an admin to regular member
class DemoteMemberFromAdmin extends GroupMemberEvent {
  final String groupId;
  final String userId;

  const DemoteMemberFromAdmin({
    required this.groupId,
    required this.userId,
  });

  @override
  List<Object?> get props => [groupId, userId];
}

/// Event to remove a member from the group
class RemoveMemberFromGroup extends GroupMemberEvent {
  final String groupId;
  final String userId;

  const RemoveMemberFromGroup({
    required this.groupId,
    required this.userId,
  });

  @override
  List<Object?> get props => [groupId, userId];
}

/// Event for current user to leave the group
class LeaveGroup extends GroupMemberEvent {
  final String groupId;
  final String userId; // Current user's ID

  const LeaveGroup({
    required this.groupId,
    required this.userId,
  });

  @override
  List<Object?> get props => [groupId, userId];
}
