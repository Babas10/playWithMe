// Manages game details screen state with real-time updates and RSVP actions.
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/core/domain/repositories/game_repository.dart';
import 'package:play_with_me/core/domain/repositories/user_repository.dart';
import 'package:play_with_me/core/data/models/user_model.dart';
import 'game_details_event.dart';
import 'game_details_state.dart';

class GameDetailsBloc extends Bloc<GameDetailsEvent, GameDetailsState> {
  final GameRepository _gameRepository;
  final UserRepository _userRepository;
  StreamSubscription<dynamic>? _gameSubscription;

  GameDetailsBloc({
    required GameRepository gameRepository,
    required UserRepository userRepository,
  })  : _gameRepository = gameRepository,
        _userRepository = userRepository,
        super(const GameDetailsInitial()) {
    on<LoadGameDetails>(_onLoadGameDetails);
    on<GameDetailsUpdated>(_onGameDetailsUpdated);
    on<JoinGameDetails>(_onJoinGameDetails);
    on<LeaveGameDetails>(_onLeaveGameDetails);
    on<MarkGameCompleted>(_onMarkGameCompleted);
    on<ConfirmGameResult>(_onConfirmGameResult);
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
      // Fetch player data for all players and waitlisted users
      final allPlayerIds = <String>{
        ...event.game.playerIds,
        ...event.game.waitlistIds,
        event.game.createdBy, // Include creator
      }.toList();

      Map<String, UserModel> players = {};

      if (allPlayerIds.isNotEmpty) {
        try {
          final userList = await _userRepository.getUsersByIds(allPlayerIds);
          for (final user in userList) {
            players[user.uid] = user;
          }
        } catch (e) {
          // If fetching users fails, emit state without user data
          // This ensures the game details still load
          print('Failed to load user data: $e');
        }
      }

      emit(GameDetailsLoaded(game: event.game, players: players));
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
        final currentState = state as GameDetailsLoaded;
        emit(GameDetailsOperationInProgress(
          game: currentState.game,
          operation: 'join',
          players: currentState.players,
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
        final currentState = state as GameDetailsLoaded;
        emit(GameDetailsOperationInProgress(
          game: currentState.game,
          operation: 'leave',
          players: currentState.players,
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
        final currentState = state as GameDetailsLoaded;
        emit(GameDetailsOperationInProgress(
          game: currentState.game,
          operation: 'mark_completed',
          players: currentState.players,
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

  Future<void> _onConfirmGameResult(
    ConfirmGameResult event,
    Emitter<GameDetailsState> emit,
  ) async {
    try {
      if (state is GameDetailsLoaded) {
        final currentState = state as GameDetailsLoaded;
        emit(GameDetailsOperationInProgress(
          game: currentState.game,
          operation: 'confirm_result',
          players: currentState.players,
        ));
      }

      await _gameRepository.confirmGameResult(event.gameId, event.userId);
      // Stream updates state
    } catch (e) {
      emit(GameDetailsError(
        message: 'Failed to confirm result: ${e.toString()}',
        errorCode: 'CONFIRM_RESULT_ERROR',
      ));
    }
  }

  @override
  Future<void> close() {
    _gameSubscription?.cancel();
    return super.close();
  }
}
