// BLoC for managing game guest invitations (Story 28.7).
// Handles loading, accepting, and declining pending game invitations.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/core/data/models/game_invitation_details.dart';
import 'package:play_with_me/core/domain/exceptions/repository_exceptions.dart';
import 'package:play_with_me/core/domain/repositories/game_invitations_repository.dart';

part 'game_invitations_event.dart';
part 'game_invitations_state.dart';

class GameInvitationsBloc
    extends Bloc<GameInvitationsEvent, GameInvitationsState> {
  final GameInvitationsRepository _repository;

  GameInvitationsBloc({required GameInvitationsRepository repository})
    : _repository = repository,
      super(const GameInvitationsInitial()) {
    on<LoadGameInvitations>(_onLoadGameInvitations);
    on<AcceptGameInvitation>(_onAcceptGameInvitation);
    on<DeclineGameInvitation>(_onDeclineGameInvitation);
  }

  Future<void> _onLoadGameInvitations(
    LoadGameInvitations event,
    Emitter<GameInvitationsState> emit,
  ) async {
    emit(const GameInvitationsLoading());
    try {
      final invitations = await _repository.getGameInvitations();
      emit(GameInvitationsLoaded(invitations));
    } on GameInvitationException catch (e) {
      emit(GameInvitationsError(e.message));
    } catch (e) {
      emit(GameInvitationsError('Failed to load invitations: ${e.toString()}'));
    }
  }

  Future<void> _onAcceptGameInvitation(
    AcceptGameInvitation event,
    Emitter<GameInvitationsState> emit,
  ) async {
    final current = _currentInvitations();
    if (current == null) return;

    emit(GameInvitationActionInFlight(current, event.invitationId));
    try {
      final accepted = current.firstWhere(
        (i) => i.invitationId == event.invitationId,
        orElse: () => current.first,
      );
      await _repository.acceptGameInvitation(event.invitationId);
      final updated = current
          .where((i) => i.invitationId != event.invitationId)
          .toList();
      emit(
        GameInvitationActionSuccess(
          updated,
          event.invitationId,
          accepted: true,
          gameId: accepted.gameId,
        ),
      );
    } on GameInvitationException catch (e) {
      emit(GameInvitationActionError(current, e.message, errorCode: e.code));
    } catch (e) {
      emit(
        GameInvitationActionError(
          current,
          'Failed to accept invitation: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onDeclineGameInvitation(
    DeclineGameInvitation event,
    Emitter<GameInvitationsState> emit,
  ) async {
    final current = _currentInvitations();
    if (current == null) return;

    emit(GameInvitationActionInFlight(current, event.invitationId));
    try {
      await _repository.declineGameInvitation(event.invitationId);
      final updated = current
          .where((i) => i.invitationId != event.invitationId)
          .toList();
      emit(
        GameInvitationActionSuccess(
          updated,
          event.invitationId,
          accepted: false,
        ),
      );
    } on GameInvitationException catch (e) {
      emit(GameInvitationActionError(current, e.message, errorCode: e.code));
    } catch (e) {
      emit(
        GameInvitationActionError(
          current,
          'Failed to decline invitation: ${e.toString()}',
        ),
      );
    }
  }

  /// Extracts the current invitation list from any state that carries it.
  List<GameInvitationDetails>? _currentInvitations() {
    final s = state;
    return switch (s) {
      GameInvitationsLoaded() => s.invitations,
      GameInvitationActionSuccess() => s.invitations,
      GameInvitationActionError() => s.invitations,
      GameInvitationActionInFlight() => s.invitations,
      _ => null,
    };
  }
}
