// Manages game details screen state with real-time updates and RSVP actions.
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/core/domain/repositories/game_repository.dart';
import 'game_details_event.dart';
import 'game_details_state.dart';

class GameDetailsBloc extends Bloc<GameDetailsEvent, GameDetailsState> {
  final GameRepository _gameRepository;
  StreamSubscription<dynamic>? _gameSubscription;

  GameDetailsBloc({required GameRepository gameRepository})
      : _gameRepository = gameRepository,
        super(const GameDetailsInitial()) {
    on<LoadGameDetails>(_onLoadGameDetails);
    on<GameDetailsUpdated>(_onGameDetailsUpdated);
    on<JoinGameDetails>(_onJoinGameDetails);
    on<LeaveGameDetails>(_onLeaveGameDetails);
    on<MarkGameCompleted>(_onMarkGameCompleted);
  }

  Future<void> _onLoadGameDetails(
    LoadGameDetails event,
    Emitter<GameDetailsState> emit,
  ) async {
    try {
      emit(const GameDetailsLoading());

      await _gameSubscription?.cancel();
      _gameSubscription = _gameRepository.getGameStream(event.gameId).listen(
        (game) {
          add(GameDetailsUpdated(game: game));
        },
        onError: (error) {
          add(GameDetailsUpdated(game: null));
        },
      );
    } catch (e) {
      emit(GameDetailsError(
        message: 'Failed to load game details: ${e.toString()}',
        errorCode: 'LOAD_GAME_DETAILS_ERROR',
      ));
    }
  }

  Future<void> _onGameDetailsUpdated(
    GameDetailsUpdated event,
    Emitter<GameDetailsState> emit,
  ) async {
    if (event.game != null) {
      emit(GameDetailsLoaded(game: event.game));
    } else {
      emit(const GameDetailsNotFound(
        message: 'Game not found or has been deleted',
      ));
    }
  }

  Future<void> _onJoinGameDetails(
    JoinGameDetails event,
    Emitter<GameDetailsState> emit,
  ) async {
    try {
      // Keep showing current game while operation is in progress
      if (state is GameDetailsLoaded) {
        final currentGame = (state as GameDetailsLoaded).game;
        emit(GameDetailsOperationInProgress(
          game: currentGame,
          operation: 'join',
        ));
      }

      await _gameRepository.addPlayer(event.gameId, event.userId);

      // The stream will automatically update with the new state
    } catch (e) {
      emit(GameDetailsError(
        message: 'Failed to join game: ${e.toString()}',
        errorCode: 'JOIN_GAME_ERROR',
      ));
    }
  }

  Future<void> _onLeaveGameDetails(
    LeaveGameDetails event,
    Emitter<GameDetailsState> emit,
  ) async {
    try {
      // Keep showing current game while operation is in progress
      if (state is GameDetailsLoaded) {
        final currentGame = (state as GameDetailsLoaded).game;
        emit(GameDetailsOperationInProgress(
          game: currentGame,
          operation: 'leave',
        ));
      }

      await _gameRepository.removePlayer(event.gameId, event.userId);

      // The stream will automatically update with the new state
    } catch (e) {
      emit(GameDetailsError(
        message: 'Failed to leave game: ${e.toString()}',
        errorCode: 'LEAVE_GAME_ERROR',
      ));
    }
  }

  Future<void> _onMarkGameCompleted(
    MarkGameCompleted event,
    Emitter<GameDetailsState> emit,
  ) async {
    try {
      // Keep showing current game while operation is in progress
      if (state is GameDetailsLoaded) {
        final currentGame = (state as GameDetailsLoaded).game;
        emit(GameDetailsOperationInProgress(
          game: currentGame,
          operation: 'mark_completed',
        ));
      }

      await _gameRepository.markGameAsCompleted(event.gameId, event.userId);

      // Fetch the updated game to emit the success state
      final updatedGame = await _gameRepository.getGameById(event.gameId);
      if (updatedGame != null) {
        emit(GameCompletedSuccessfully(game: updatedGame));
      }

      // The stream will automatically update with the new state
    } catch (e) {
      emit(GameDetailsError(
        message: 'Failed to mark game as completed: ${e.toString()}',
        errorCode: 'MARK_COMPLETED_ERROR',
      ));
    }
  }

  @override
  Future<void> close() {
    _gameSubscription?.cancel();
    return super.close();
  }
}
