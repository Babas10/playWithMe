// BLoC for the invite-guest-players flow (Story 28.6).
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/core/data/models/invitable_player_model.dart';
import 'package:play_with_me/core/domain/exceptions/repository_exceptions.dart';
import 'package:play_with_me/core/domain/repositories/game_guest_invitation_repository.dart';

import 'game_guest_invitation_event.dart';
import 'game_guest_invitation_state.dart';

class GameGuestInvitationBloc
    extends Bloc<GameGuestInvitationEvent, GameGuestInvitationState> {
  final GameGuestInvitationRepository _repository;

  GameGuestInvitationBloc({required GameGuestInvitationRepository repository})
      : _repository = repository,
        super(const GameGuestInvitationInitial()) {
    on<LoadInvitablePlayers>(_onLoadInvitablePlayers);
    on<InviteGuestPlayer>(_onInviteGuestPlayer);
  }

  Future<void> _onLoadInvitablePlayers(
    LoadInvitablePlayers event,
    Emitter<GameGuestInvitationState> emit,
  ) async {
    try {
      emit(const InvitablePlayersLoading());
      final players = await _repository.getInvitablePlayers(event.gameId);
      emit(InvitablePlayersLoaded(players: players));
    } on GameInvitationException catch (e) {
      emit(InvitablePlayersError(
        message: e.message,
        errorCode: e.code ?? 'LOAD_INVITABLE_PLAYERS_ERROR',
      ));
    } catch (e) {
      emit(InvitablePlayersError(
        message: 'Failed to load players: ${e.toString()}',
        errorCode: 'LOAD_INVITABLE_PLAYERS_ERROR',
      ));
    }
  }

  Future<void> _onInviteGuestPlayer(
    InviteGuestPlayer event,
    Emitter<GameGuestInvitationState> emit,
  ) async {
    final currentState = state;
    final loadedPlayers = switch (currentState) {
      InvitablePlayersLoaded s => s.players,
      InvitePlayerSuccess s => s.players,
      InvitePlayerError s => s.players,
      InvitePlayerSending s => s.players,
      _ => const <InvitablePlayerModel>[],
    };

    try {
      emit(InvitePlayerSending(
        players: List.unmodifiable(loadedPlayers),
        inviteeId: event.inviteeId,
      ));
      await _repository.inviteGuestPlayer(
        gameId: event.gameId,
        inviteeId: event.inviteeId,
      );
      emit(InvitePlayerSuccess(
        players: List.unmodifiable(loadedPlayers),
        inviteeId: event.inviteeId,
      ));
    } on GameInvitationException catch (e) {
      emit(InvitePlayerError(
        players: List.unmodifiable(loadedPlayers),
        message: e.message,
        errorCode: e.code ?? 'INVITE_GUEST_PLAYER_ERROR',
      ));
    } catch (e) {
      emit(InvitePlayerError(
        players: List.unmodifiable(loadedPlayers),
        message: 'Failed to send invitation: ${e.toString()}',
        errorCode: 'INVITE_GUEST_PLAYER_ERROR',
      ));
    }
  }
}
