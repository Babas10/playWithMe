// States for GameGuestInvitationBloc (Story 28.6).
import 'package:play_with_me/core/data/models/invitable_player_model.dart';
import 'package:play_with_me/core/presentation/bloc/base_bloc_state.dart';

abstract class GameGuestInvitationState extends BaseBlocState {
  const GameGuestInvitationState();
}

class GameGuestInvitationInitial extends GameGuestInvitationState
    implements InitialState {
  const GameGuestInvitationInitial();
}

class InvitablePlayersLoading extends GameGuestInvitationState
    implements LoadingState {
  const InvitablePlayersLoading();
}

class InvitablePlayersLoaded extends GameGuestInvitationState
    implements SuccessState {
  final List<InvitablePlayerModel> players;

  const InvitablePlayersLoaded({required this.players});

  @override
  List<Object?> get props => [players];
}

class InvitablePlayersError extends GameGuestInvitationState
    implements ErrorState {
  @override
  final String message;
  @override
  final String? errorCode;
  @override
  final bool isRetryable;

  const InvitablePlayersError({
    required this.message,
    this.errorCode,
    this.isRetryable = true,
  });

  @override
  List<Object?> get props => [message, errorCode, isRetryable];
}

class InvitePlayerSending extends GameGuestInvitationState
    implements LoadingState {
  final List<InvitablePlayerModel> players;
  final String inviteeId;

  const InvitePlayerSending({
    required this.players,
    required this.inviteeId,
  });

  @override
  List<Object?> get props => [players, inviteeId];
}

class InvitePlayerSuccess extends GameGuestInvitationState
    implements SuccessState {
  final List<InvitablePlayerModel> players;
  final String inviteeId;

  const InvitePlayerSuccess({
    required this.players,
    required this.inviteeId,
  });

  @override
  List<Object?> get props => [players, inviteeId];
}

class InvitePlayerError extends GameGuestInvitationState implements ErrorState {
  final List<InvitablePlayerModel> players;
  @override
  final String message;
  @override
  final String? errorCode;
  @override
  final bool isRetryable;

  const InvitePlayerError({
    required this.players,
    required this.message,
    this.errorCode,
    this.isRetryable = true,
  });

  @override
  List<Object?> get props => [players, message, errorCode, isRetryable];
}
