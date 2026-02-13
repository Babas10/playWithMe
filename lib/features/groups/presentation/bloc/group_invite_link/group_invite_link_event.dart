import 'package:play_with_me/core/presentation/bloc/base_bloc_event.dart';

abstract class GroupInviteLinkEvent extends BaseBlocEvent {
  const GroupInviteLinkEvent();
}

/// Event to generate a new invite link for a group.
class GenerateInvite extends GroupInviteLinkEvent {
  final String groupId;
  final int? expiresInHours;
  final int? usageLimit;

  const GenerateInvite({
    required this.groupId,
    this.expiresInHours,
    this.usageLimit,
  });

  @override
  List<Object?> get props => [groupId, expiresInHours, usageLimit];
}

/// Event to revoke an existing invite link.
class RevokeInvite extends GroupInviteLinkEvent {
  final String groupId;
  final String inviteId;

  const RevokeInvite({
    required this.groupId,
    required this.inviteId,
  });

  @override
  List<Object?> get props => [groupId, inviteId];
}
