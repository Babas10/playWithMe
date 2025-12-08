import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/game_repository.dart';
import 'game_event.dart';
import 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final GameRepository _gameRepository;
  StreamSubscription<dynamic>? _gamesSubscription;
  StreamSubscription<dynamic>? _upcomingGamesSubscription;

  GameBloc({required GameRepository gameRepository})
      : _gameRepository = gameRepository,
        super(const GameInitial()) {
    on<LoadGameById>(_onLoadGameById);
    on<LoadGamesForUser>(_onLoadGamesForUser);
    on<LoadGamesForGroup>(_onLoadGamesForGroup);
    on<LoadUpcomingGamesForUser>(_onLoadUpcomingGamesForUser);
    on<LoadPastGamesForUser>(_onLoadPastGamesForUser);
    on<CreateGame>(_onCreateGame);
    on<UpdateGameInfo>(_onUpdateGameInfo);
    on<UpdateGameSettings>(_onUpdateGameSettings);
    on<JoinGame>(_onJoinGame);
    on<LeaveGame>(_onLeaveGame);
    on<StartGame>(_onStartGame);
    on<EndGame>(_onEndGame);
    on<CancelGame>(_onCancelGame);
    on<UpdateGameScores>(_onUpdateGameScores);
    on<LoadGamesByLocation>(_onLoadGamesByLocation);
    on<LoadGamesByStatus>(_onLoadGamesByStatus);
    on<LoadGamesToday>(_onLoadGamesToday);
    on<LoadGamesThisWeek>(_onLoadGamesThisWeek);
    on<SearchGames>(_onSearchGames);
    on<LoadGameStats>(_onLoadGameStats);
    on<DeleteGame>(_onDeleteGame);
    on<SaveGameResult>(_onSaveGameResult);
  }

  Future<void> _onLoadGameById(
    LoadGameById event,
    Emitter<GameState> emit,
  ) async {
    try {
      emit(const GameLoading());

      final game = await _gameRepository.getGameById(event.gameId);
      if (game != null) {
        emit(GameLoaded(game: game));
      } else {
        emit(const GameNotFound(message: 'Game not found'));
      }
    } catch (e) {
      emit(GameError(
        message: 'Failed to load game: ${e.toString()}',
        errorCode: 'LOAD_GAME_ERROR',
      ));
    }
  }

  Future<void> _onLoadGamesForUser(
    LoadGamesForUser event,
    Emitter<GameState> emit,
  ) async {
    try {
      emit(const GameLoading());

      await _gamesSubscription?.cancel();
      _gamesSubscription = _gameRepository.getGamesForUser(event.userId).listen(
        (games) {
          emit(GamesLoaded(games: games));
        },
        onError: (error) {
          emit(GameError(
            message: 'Failed to load user games: ${error.toString()}',
            errorCode: 'LOAD_USER_GAMES_ERROR',
          ));
        },
      );
    } catch (e) {
      emit(GameError(
        message: 'Failed to load user games: ${e.toString()}',
        errorCode: 'LOAD_USER_GAMES_ERROR',
      ));
    }
  }

  Future<void> _onLoadGamesForGroup(
    LoadGamesForGroup event,
    Emitter<GameState> emit,
  ) async {
    try {
      emit(const GameLoading());

      await _gamesSubscription?.cancel();
      _gamesSubscription = _gameRepository.getGamesForGroup(event.groupId).listen(
        (games) {
          emit(GamesLoaded(games: games));
        },
        onError: (error) {
          emit(GameError(
            message: 'Failed to load group games: ${error.toString()}',
            errorCode: 'LOAD_GROUP_GAMES_ERROR',
          ));
        },
      );
    } catch (e) {
      emit(GameError(
        message: 'Failed to load group games: ${e.toString()}',
        errorCode: 'LOAD_GROUP_GAMES_ERROR',
      ));
    }
  }

  Future<void> _onLoadUpcomingGamesForUser(
    LoadUpcomingGamesForUser event,
    Emitter<GameState> emit,
  ) async {
    try {
      emit(const GameLoading());

      await _upcomingGamesSubscription?.cancel();
      _upcomingGamesSubscription = _gameRepository.getUpcomingGamesForUser(event.userId).listen(
        (games) {
          emit(GamesLoaded(games: games));
        },
        onError: (error) {
          emit(GameError(
            message: 'Failed to load upcoming games: ${error.toString()}',
            errorCode: 'LOAD_UPCOMING_GAMES_ERROR',
          ));
        },
      );
    } catch (e) {
      emit(GameError(
        message: 'Failed to load upcoming games: ${e.toString()}',
        errorCode: 'LOAD_UPCOMING_GAMES_ERROR',
      ));
    }
  }

  Future<void> _onLoadPastGamesForUser(
    LoadPastGamesForUser event,
    Emitter<GameState> emit,
  ) async {
    try {
      emit(const GameLoading());

      final games = await _gameRepository.getPastGamesForUser(
        event.userId,
        limit: event.limit,
      );

      emit(GamesLoaded(games: games));
    } catch (e) {
      emit(GameError(
        message: 'Failed to load past games: ${e.toString()}',
        errorCode: 'LOAD_PAST_GAMES_ERROR',
      ));
    }
  }

  Future<void> _onCreateGame(
    CreateGame event,
    Emitter<GameState> emit,
  ) async {
    try {
      emit(const GameLoading());

      final gameId = await _gameRepository.createGame(event.game);
      final createdGame = event.game.copyWith(id: gameId);

      emit(GameCreated(
        gameId: gameId,
        game: createdGame,
      ));
    } catch (e) {
      emit(GameError(
        message: 'Failed to create game: ${e.toString()}',
        errorCode: 'CREATE_GAME_ERROR',
      ));
    }
  }

  Future<void> _onUpdateGameInfo(
    UpdateGameInfo event,
    Emitter<GameState> emit,
  ) async {
    try {
      emit(const GameLoading());

      await _gameRepository.updateGameInfo(
        event.gameId,
        title: event.title,
        description: event.description,
        scheduledAt: event.scheduledAt,
        location: event.location,
        notes: event.notes,
        equipment: event.equipment,
        estimatedDuration: event.estimatedDuration,
      );

      final updatedGame = await _gameRepository.getGameById(event.gameId);
      if (updatedGame != null) {
        emit(GameUpdated(
          game: updatedGame,
          message: 'Game information updated successfully',
        ));
      } else {
        emit(const GameOperationSuccess(
          message: 'Game information updated successfully',
        ));
      }
    } catch (e) {
      emit(GameError(
        message: 'Failed to update game info: ${e.toString()}',
        errorCode: 'UPDATE_GAME_INFO_ERROR',
      ));
    }
  }

  Future<void> _onUpdateGameSettings(
    UpdateGameSettings event,
    Emitter<GameState> emit,
  ) async {
    try {
      emit(const GameLoading());

      await _gameRepository.updateGameSettings(
        event.gameId,
        maxPlayers: event.maxPlayers,
        minPlayers: event.minPlayers,
        allowWaitlist: event.allowWaitlist,
        allowPlayerInvites: event.allowPlayerInvites,
        visibility: event.visibility,
        gameType: event.gameType,
        skillLevel: event.skillLevel,
        weatherDependent: event.weatherDependent,
        weatherNotes: event.weatherNotes,
      );

      final updatedGame = await _gameRepository.getGameById(event.gameId);
      if (updatedGame != null) {
        emit(GameUpdated(
          game: updatedGame,
          message: 'Game settings updated successfully',
        ));
      } else {
        emit(const GameOperationSuccess(
          message: 'Game settings updated successfully',
        ));
      }
    } catch (e) {
      emit(GameError(
        message: 'Failed to update game settings: ${e.toString()}',
        errorCode: 'UPDATE_GAME_SETTINGS_ERROR',
      ));
    }
  }

  Future<void> _onJoinGame(
    JoinGame event,
    Emitter<GameState> emit,
  ) async {
    try {
      emit(const GameLoading());

      await _gameRepository.addPlayer(event.gameId, event.userId);

      final updatedGame = await _gameRepository.getGameById(event.gameId);
      if (updatedGame != null) {
        emit(GameUpdated(
          game: updatedGame,
          message: 'Successfully joined game',
        ));
      } else {
        emit(const GameOperationSuccess(
          message: 'Successfully joined game',
        ));
      }
    } catch (e) {
      emit(GameError(
        message: 'Failed to join game: ${e.toString()}',
        errorCode: 'JOIN_GAME_ERROR',
      ));
    }
  }

  Future<void> _onLeaveGame(
    LeaveGame event,
    Emitter<GameState> emit,
  ) async {
    try {
      emit(const GameLoading());

      await _gameRepository.removePlayer(event.gameId, event.userId);

      final updatedGame = await _gameRepository.getGameById(event.gameId);
      if (updatedGame != null) {
        emit(GameUpdated(
          game: updatedGame,
          message: 'Successfully left game',
        ));
      } else {
        emit(const GameOperationSuccess(
          message: 'Successfully left game',
        ));
      }
    } catch (e) {
      emit(GameError(
        message: 'Failed to leave game: ${e.toString()}',
        errorCode: 'LEAVE_GAME_ERROR',
      ));
    }
  }

  Future<void> _onStartGame(
    StartGame event,
    Emitter<GameState> emit,
  ) async {
    try {
      emit(const GameLoading());

      await _gameRepository.startGame(event.gameId);

      final updatedGame = await _gameRepository.getGameById(event.gameId);
      if (updatedGame != null) {
        emit(GameUpdated(
          game: updatedGame,
          message: 'Game started successfully',
        ));
      } else {
        emit(const GameOperationSuccess(
          message: 'Game started successfully',
        ));
      }
    } catch (e) {
      emit(GameError(
        message: 'Failed to start game: ${e.toString()}',
        errorCode: 'START_GAME_ERROR',
      ));
    }
  }

  Future<void> _onEndGame(
    EndGame event,
    Emitter<GameState> emit,
  ) async {
    try {
      emit(const GameLoading());

      await _gameRepository.endGame(
        event.gameId,
        winnerId: event.winnerId,
        finalScores: event.finalScores,
      );

      final updatedGame = await _gameRepository.getGameById(event.gameId);
      if (updatedGame != null) {
        emit(GameUpdated(
          game: updatedGame,
          message: 'Game ended successfully',
        ));
      } else {
        emit(const GameOperationSuccess(
          message: 'Game ended successfully',
        ));
      }
    } catch (e) {
      emit(GameError(
        message: 'Failed to end game: ${e.toString()}',
        errorCode: 'END_GAME_ERROR',
      ));
    }
  }

  Future<void> _onCancelGame(
    CancelGame event,
    Emitter<GameState> emit,
  ) async {
    try {
      emit(const GameLoading());

      await _gameRepository.cancelGame(event.gameId);

      final updatedGame = await _gameRepository.getGameById(event.gameId);
      if (updatedGame != null) {
        emit(GameUpdated(
          game: updatedGame,
          message: 'Game cancelled successfully',
        ));
      } else {
        emit(const GameOperationSuccess(
          message: 'Game cancelled successfully',
        ));
      }
    } catch (e) {
      emit(GameError(
        message: 'Failed to cancel game: ${e.toString()}',
        errorCode: 'CANCEL_GAME_ERROR',
      ));
    }
  }

  Future<void> _onUpdateGameScores(
    UpdateGameScores event,
    Emitter<GameState> emit,
  ) async {
    try {
      emit(const GameLoading());

      await _gameRepository.updateScores(event.gameId, event.scores);

      final updatedGame = await _gameRepository.getGameById(event.gameId);
      if (updatedGame != null) {
        emit(GameUpdated(
          game: updatedGame,
          message: 'Scores updated successfully',
        ));
      } else {
        emit(const GameOperationSuccess(
          message: 'Scores updated successfully',
        ));
      }
    } catch (e) {
      emit(GameError(
        message: 'Failed to update scores: ${e.toString()}',
        errorCode: 'UPDATE_SCORES_ERROR',
      ));
    }
  }

  Future<void> _onLoadGamesByLocation(
    LoadGamesByLocation event,
    Emitter<GameState> emit,
  ) async {
    try {
      emit(const GameLoading());

      final games = await _gameRepository.getGamesByLocation(
        event.latitude,
        event.longitude,
        event.radiusKm,
        limit: event.limit,
      );

      emit(GamesLoaded(games: games));
    } catch (e) {
      emit(GameError(
        message: 'Failed to load games by location: ${e.toString()}',
        errorCode: 'LOAD_GAMES_BY_LOCATION_ERROR',
      ));
    }
  }

  Future<void> _onLoadGamesByStatus(
    LoadGamesByStatus event,
    Emitter<GameState> emit,
  ) async {
    try {
      emit(const GameLoading());

      final games = await _gameRepository.getGamesByStatus(
        event.status,
        limit: event.limit,
      );

      emit(GamesLoaded(games: games));
    } catch (e) {
      emit(GameError(
        message: 'Failed to load games by status: ${e.toString()}',
        errorCode: 'LOAD_GAMES_BY_STATUS_ERROR',
      ));
    }
  }

  Future<void> _onLoadGamesToday(
    LoadGamesToday event,
    Emitter<GameState> emit,
  ) async {
    try {
      emit(const GameLoading());

      final games = await _gameRepository.getGamesToday();
      emit(GamesLoaded(games: games));
    } catch (e) {
      emit(GameError(
        message: 'Failed to load today\'s games: ${e.toString()}',
        errorCode: 'LOAD_GAMES_TODAY_ERROR',
      ));
    }
  }

  Future<void> _onLoadGamesThisWeek(
    LoadGamesThisWeek event,
    Emitter<GameState> emit,
  ) async {
    try {
      emit(const GameLoading());

      final games = await _gameRepository.getGamesThisWeek();
      emit(GamesLoaded(games: games));
    } catch (e) {
      emit(GameError(
        message: 'Failed to load this week\'s games: ${e.toString()}',
        errorCode: 'LOAD_GAMES_THIS_WEEK_ERROR',
      ));
    }
  }

  Future<void> _onSearchGames(
    SearchGames event,
    Emitter<GameState> emit,
  ) async {
    try {
      emit(const GameLoading());

      final games = await _gameRepository.searchGames(
        event.query,
        limit: event.limit,
      );

      emit(GamesLoaded(games: games));
    } catch (e) {
      emit(GameError(
        message: 'Failed to search games: ${e.toString()}',
        errorCode: 'SEARCH_GAMES_ERROR',
      ));
    }
  }

  Future<void> _onLoadGameStats(
    LoadGameStats event,
    Emitter<GameState> emit,
  ) async {
    try {
      emit(const GameLoading());

      final stats = await _gameRepository.getGameStats(event.gameId);
      emit(GameStatsLoaded(stats: stats));
    } catch (e) {
      emit(GameError(
        message: 'Failed to load game stats: ${e.toString()}',
        errorCode: 'LOAD_GAME_STATS_ERROR',
      ));
    }
  }

  Future<void> _onDeleteGame(
    DeleteGame event,
    Emitter<GameState> emit,
  ) async {
    try {
      emit(const GameLoading());

      await _gameRepository.deleteGame(event.gameId);

      emit(const GameOperationSuccess(
        message: 'Game deleted successfully',
      ));
    } catch (e) {
      emit(GameError(
        message: 'Failed to delete game: ${e.toString()}',
        errorCode: 'DELETE_GAME_ERROR',
      ));
    }
  }

  Future<void> _onSaveGameResult(
    SaveGameResult event,
    Emitter<GameState> emit,
  ) async {
    try {
      emit(const GameLoading());

      await _gameRepository.saveGameResult(
        gameId: event.gameId,
        userId: event.userId,
        teams: event.teams,
        result: event.result,
      );

      final updatedGame = await _gameRepository.getGameById(event.gameId);
      if (updatedGame != null) {
        emit(GameUpdated(
          game: updatedGame,
          message: 'Game result saved successfully',
        ));
      } else {
        emit(const GameOperationSuccess(
          message: 'Game result saved successfully',
        ));
      }
    } catch (e) {
      emit(GameError(
        message: 'Failed to save game result: ${e.toString()}',
        errorCode: 'SAVE_GAME_RESULT_ERROR',
      ));
    }
  }

  @override
  Future<void> close() {
    _gamesSubscription?.cancel();
    _upcomingGamesSubscription?.cancel();
    return super.close();
  }
}