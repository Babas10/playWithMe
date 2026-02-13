// States for the InviteJoinBloc.
import 'package:equatable/equatable.dart';

sealed class InviteJoinState extends Equatable {
  const InviteJoinState();

  @override
  List<Object?> get props => [];
}

class InviteJoinInitial extends InviteJoinState {
  const InviteJoinInitial();
}

class InviteJoinValidating extends InviteJoinState {
  const InviteJoinValidating();
}

class InviteJoinValidated extends InviteJoinState {
  final String groupId;
  final String groupName;
  final String? groupDescription;
  final String? groupPhotoUrl;
  final int memberCount;
  final String inviterName;
  final String? inviterPhotoUrl;
  final String token;

  const InviteJoinValidated({
    required this.groupId,
    required this.groupName,
    this.groupDescription,
    this.groupPhotoUrl,
    required this.memberCount,
    required this.inviterName,
    this.inviterPhotoUrl,
    required this.token,
  });

  @override
  List<Object?> get props => [
        groupId,
        groupName,
        groupDescription,
        groupPhotoUrl,
        memberCount,
        inviterName,
        inviterPhotoUrl,
        token,
      ];
}

class InviteJoinJoining extends InviteJoinState {
  const InviteJoinJoining();
}

class InviteJoinJoined extends InviteJoinState {
  final String groupId;
  final String groupName;
  final bool alreadyMember;

  const InviteJoinJoined({
    required this.groupId,
    required this.groupName,
    required this.alreadyMember,
  });

  @override
  List<Object?> get props => [groupId, groupName, alreadyMember];
}

class InviteJoinError extends InviteJoinState {
  final String message;

  const InviteJoinError({required this.message});

  @override
  List<Object?> get props => [message];
}

class InviteJoinInvalidToken extends InviteJoinState {
  final String reason;

  const InviteJoinInvalidToken({required this.reason});

  @override
  List<Object?> get props => [reason];
}
