import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/data/models/game_model.dart';
import '../../../../../core/domain/repositories/game_repository.dart';
import 'score_entry_event.dart';
import 'score_entry_state.dart';

class ScoreEntryBloc extends Bloc<ScoreEntryEvent, ScoreEntryState> {
  final GameRepository gameRepository;

  ScoreEntryBloc({
    required this.gameRepository,
  }) : super(const ScoreEntryInitial()) {
    on<LoadGameForScoreEntry>(_onLoadGameForScoreEntry);
    on<SetGameCount>(_onSetGameCount);
    on<SetGameFormat>(_onSetGameFormat);
    on<UpdateSetScore>(_onUpdateSetScore);
    on<SaveScores>(_onSaveScores);
  }

  Future<void> _onLoadGameForScoreEntry(
    LoadGameForScoreEntry event,
    Emitter<ScoreEntryState> emit,
  ) async {
    emit(const ScoreEntryLoading());

    try {
      final game = await gameRepository.getGameById(event.gameId);

      if (game == null) {
        emit(const ScoreEntryError(message: 'Game not found'));
        return;
      }

      // Validate game state
      if (game.status == GameStatus.cancelled) {
        emit(const ScoreEntryError(message: 'Cannot enter scores for a cancelled game'));
        return;
      }

      if (game.teams == null) {
        emit(const ScoreEntryError(message: 'Teams must be assigned before entering scores'));
        return;
      }

      // If result already exists, load it
      if (game.result != null) {
        final result = game.result!;
        final loadedGames = <GameData>[];

        for (final individualGame in result.games) {
          final sets = individualGame.sets.map((set) {
            return SetScoreData(
              teamAPoints: set.teamAPoints,
              teamBPoints: set.teamBPoints,
            );
          }).toList();

          loadedGames.add(GameData(
            numberOfSets: individualGame.sets.length,
            sets: sets,
          ));
        }

        emit(ScoreEntryLoaded(
          game: game,
          gameCount: result.games.length,
          games: loadedGames,
        ));
      } else {
        emit(ScoreEntryLoaded(game: game));
      }
    } catch (e) {
      emit(ScoreEntryError(message: 'Failed to load game: $e'));
    }
  }

  Future<void> _onSetGameCount(
    SetGameCount event,
    Emitter<ScoreEntryState> emit,
  ) async {
    if (state is! ScoreEntryLoaded) return;

    final currentState = state as ScoreEntryLoaded;

    // Initialize games list with default single-set games
    final games = List.generate(
      event.count,
      (index) => GameData(
        numberOfSets: 1,
        sets: [const SetScoreData()],
      ),
    );

    emit(currentState.copyWith(
      gameCount: event.count,
      games: games,
    ));
  }

  Future<void> _onSetGameFormat(
    SetGameFormat event,
    Emitter<ScoreEntryState> emit,
  ) async {
    if (state is! ScoreEntryLoaded) return;

    final currentState = state as ScoreEntryLoaded;

    if (event.gameIndex < 0 || event.gameIndex >= currentState.games.length) {
      return;
    }

    // Create a new list of games with updated format for the specific game
    final updatedGames = List<GameData>.from(currentState.games);
    final currentGame = updatedGames[event.gameIndex];

    // Update the game with new number of sets
    final newSets = List.generate(
      event.numberOfSets,
      (index) {
        // Keep existing set data if it exists
        if (index < currentGame.sets.length) {
          return currentGame.sets[index];
        }
        return const SetScoreData();
      },
    );

    updatedGames[event.gameIndex] = GameData(
      numberOfSets: event.numberOfSets,
      sets: newSets,
    );

    emit(currentState.copyWith(games: updatedGames));
  }

  Future<void> _onUpdateSetScore(
    UpdateSetScore event,
    Emitter<ScoreEntryState> emit,
  ) async {
    if (state is! ScoreEntryLoaded) return;

    final currentState = state as ScoreEntryLoaded;

    if (event.gameIndex < 0 || event.gameIndex >= currentState.games.length) {
      return;
    }

    final updatedGames = List<GameData>.from(currentState.games);
    final currentGame = updatedGames[event.gameIndex];

    if (event.setIndex < 0 || event.setIndex >= currentGame.sets.length) {
      return;
    }

    // Update the specific set score with both values
    final updatedSets = List<SetScoreData>.from(currentGame.sets);
    updatedSets[event.setIndex] = SetScoreData(
      teamAPoints: event.teamAPoints,
      teamBPoints: event.teamBPoints,
    );

    updatedGames[event.gameIndex] = currentGame.copyWith(sets: updatedSets);

    emit(currentState.copyWith(games: updatedGames));
  }

  Future<void> _onSaveScores(
    SaveScores event,
    Emitter<ScoreEntryState> emit,
  ) async {
    if (state is! ScoreEntryLoaded) return;

    final currentState = state as ScoreEntryLoaded;

    // Validate that we can save
    if (!currentState.canSave) {
      emit(const ScoreEntryError(message: 'Please enter valid scores for all games'));
      emit(currentState); // Return to loaded state
      return;
    }

    // Build individual games list
    final individualGames = <IndividualGame>[];

    for (int gameIndex = 0; gameIndex < currentState.games.length; gameIndex++) {
      final gameData = currentState.games[gameIndex];

      // Build sets for this game
      final sets = <SetScore>[];
      for (int setIndex = 0; setIndex < gameData.numberOfSets; setIndex++) {
        final setData = gameData.sets[setIndex];
        sets.add(SetScore(
          teamAPoints: setData.teamAPoints!,
          teamBPoints: setData.teamBPoints!,
          setNumber: setIndex + 1,
        ));
      }

      individualGames.add(IndividualGame(
        gameNumber: gameIndex + 1,
        sets: sets,
        winner: gameData.winner!,
      ));
    }

    // Create result
    final result = GameResult(
      games: individualGames,
      overallWinner: currentState.overallWinner!,
    );

    // Validate result
    if (!result.isValid()) {
      emit(const ScoreEntryError(message: 'Invalid game result. Please check all scores.'));
      emit(currentState); // Return to loaded state
      return;
    }

    emit(ScoreEntrySaving(game: currentState.game, result: result));

    try {
      await gameRepository.saveGameResult(
        gameId: currentState.game.id,
        userId: event.userId,
        teams: currentState.game.teams!,
        result: result,
      );

      emit(ScoreEntrySaved(game: currentState.game, result: result));
    } catch (e) {
      emit(ScoreEntryError(message: 'Failed to save scores: $e'));
      emit(currentState); // Return to loaded state
    }
  }
}
