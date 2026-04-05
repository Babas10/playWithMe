// Events for GameGuestInvitationBloc (Story 28.6).
import 'package:play_with_me/core/presentation/bloc/base_bloc_event.dart';

abstract class GameGuestInvitationEvent extends BaseBlocEvent {
  const GameGuestInvitationEvent();
}

class LoadInvitablePlayers extends GameGuestInvitationEvent {
  final String gameId;

  const LoadInvitablePlayers({required this.gameId});

  @override
  List<Object?> get props => [gameId];
}

class InviteGuestPlayer extends GameGuestInvitationEvent {
  final String gameId;
  final String inviteeId;

  const InviteGuestPlayer({required this.gameId, required this.inviteeId});

  @override
  List<Object?> get props => [gameId, inviteeId];
}
