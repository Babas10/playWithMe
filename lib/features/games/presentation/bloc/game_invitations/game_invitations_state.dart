// States for GameInvitationsBloc (Story 28.7).

part of 'game_invitations_bloc.dart';

abstract class GameInvitationsState {
  const GameInvitationsState();
}

class GameInvitationsInitial extends GameInvitationsState {
  const GameInvitationsInitial();
}

class GameInvitationsLoading extends GameInvitationsState {
  const GameInvitationsLoading();
}

/// Invitations loaded successfully.
class GameInvitationsLoaded extends GameInvitationsState {
  final List<GameInvitationDetails> invitations;
  const GameInvitationsLoaded(this.invitations);
}

/// Initial load failed.
class GameInvitationsError extends GameInvitationsState {
  final String message;
  const GameInvitationsError(this.message);
}

/// An accept/decline CF call is in-flight for [processingInvitationId].
/// The full list is kept so the UI can disable only the relevant card.
class GameInvitationActionInFlight extends GameInvitationsState {
  final List<GameInvitationDetails> invitations;
  final String processingInvitationId;
  const GameInvitationActionInFlight(this.invitations, this.processingInvitationId);
}

/// An accept/decline call succeeded; [invitationId] has been removed from [invitations].
/// [accepted] distinguishes which action was taken (for snackbar copy).
class GameInvitationActionSuccess extends GameInvitationsState {
  final List<GameInvitationDetails> invitations;
  final String invitationId;
  final bool accepted;
  const GameInvitationActionSuccess(this.invitations, this.invitationId, {required this.accepted});
}

/// An accept/decline call failed; the original [invitations] list is preserved.
class GameInvitationActionError extends GameInvitationsState {
  final List<GameInvitationDetails> invitations;
  final String message;
  final String? errorCode;
  const GameInvitationActionError(this.invitations, this.message, {this.errorCode});
}
