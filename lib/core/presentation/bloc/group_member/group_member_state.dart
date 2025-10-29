// States for group member management operations
import 'package:equatable/equatable.dart';

abstract class GroupMemberState extends Equatable {
  const GroupMemberState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any member operations
class GroupMemberInitial extends GroupMemberState {
  const GroupMemberInitial();
}

/// State when a member operation is in progress
class GroupMemberLoading extends GroupMemberState {
  const GroupMemberLoading();
}

/// State when a member was successfully promoted to admin
class MemberPromotedSuccess extends GroupMemberState {
  final String groupId;
  final String userId;

  const MemberPromotedSuccess({
    required this.groupId,
    required this.userId,
  });

  @override
  List<Object?> get props => [groupId, userId];
}

/// State when a member was successfully demoted from admin
class MemberDemotedSuccess extends GroupMemberState {
  final String groupId;
  final String userId;

  const MemberDemotedSuccess({
    required this.groupId,
    required this.userId,
  });

  @override
  List<Object?> get props => [groupId, userId];
}

/// State when a member was successfully removed from group
class MemberRemovedSuccess extends GroupMemberState {
  final String groupId;
  final String userId;

  const MemberRemovedSuccess({
    required this.groupId,
    required this.userId,
  });

  @override
  List<Object?> get props => [groupId, userId];
}

/// State when a member operation failed
class GroupMemberError extends GroupMemberState {
  final String message;

  const GroupMemberError(this.message);

  @override
  List<Object?> get props => [message];
}

/// State when current user successfully left the group
class UserLeftGroupSuccess extends GroupMemberState {
  final String groupId;

  const UserLeftGroupSuccess({
    required this.groupId,
  });

  @override
  List<Object?> get props => [groupId];
}
