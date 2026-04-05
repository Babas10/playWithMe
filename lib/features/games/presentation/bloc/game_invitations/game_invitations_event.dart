// Events for GameInvitationsBloc (Story 28.7).

part of 'game_invitations_bloc.dart';

abstract class GameInvitationsEvent {
  const GameInvitationsEvent();
}

/// Fetch all pending game invitations for the current user.
class LoadGameInvitations extends GameInvitationsEvent {
  const LoadGameInvitations();
}

/// Accept the invitation with [invitationId].
class AcceptGameInvitation extends GameInvitationsEvent {
  final String invitationId;
  const AcceptGameInvitation(this.invitationId);
}

/// Decline the invitation with [invitationId].
class DeclineGameInvitation extends GameInvitationsEvent {
  final String invitationId;
  const DeclineGameInvitation(this.invitationId);
}
