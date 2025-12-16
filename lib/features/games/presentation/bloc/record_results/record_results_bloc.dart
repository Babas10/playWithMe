import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/core/data/models/game_model.dart';
import 'package:play_with_me/core/data/models/user_model.dart';
import 'package:play_with_me/core/domain/repositories/game_repository.dart';
import 'package:play_with_me/core/domain/repositories/user_repository.dart';

import 'record_results_event.dart';
import 'record_results_state.dart';

class RecordResultsBloc extends Bloc<RecordResultsEvent, RecordResultsState> {
  final GameRepository _gameRepository;
  final UserRepository _userRepository;

  RecordResultsBloc({
    required GameRepository gameRepository,
    required UserRepository userRepository,
  })  : _gameRepository = gameRepository,
        _userRepository = userRepository,
        super(const RecordResultsInitial()) {
    on<LoadGameForResults>(_onLoadGameForResults);
    on<AssignPlayerToTeamA>(_onAssignPlayerToTeamA);
    on<AssignPlayerToTeamB>(_onAssignPlayerToTeamB);
    on<RemovePlayerFromTeam>(_onRemovePlayerFromTeam);
    on<SaveTeams>(_onSaveTeams);
  }

  Future<void> _onLoadGameForResults(
    LoadGameForResults event,
    Emitter<RecordResultsState> emit,
  ) async {
    emit(const RecordResultsLoading());

    try {
      final game = await _gameRepository.getGameById(event.gameId);

      if (game == null) {
        emit(const RecordResultsError(message: 'Game not found'));
        return;
      }

      if (game.status == GameStatus.cancelled) {
        emit(const RecordResultsError(message: 'Cannot record results for a cancelled game'));
        return;
      }

      // Initialize teams from existing data or start fresh
      final List<String> teamAPlayerIds = game.teams?.teamAPlayerIds ?? [];
      final List<String> teamBPlayerIds = game.teams?.teamBPlayerIds ?? [];
      final assignedPlayers = {...teamAPlayerIds, ...teamBPlayerIds};
      final unassignedPlayerIds = game.playerIds
          .where((playerId) => !assignedPlayers.contains(playerId))
          .toList();

      // Load player data
      Map<String, UserModel> players = {};
      if (game.playerIds.isNotEmpty) {
        try {
          final userList = await _userRepository.getUsersByIds(game.playerIds);
          for (final user in userList) {
            players[user.uid] = user;
          }
        } catch (e) {
          // If fetching users fails, continue without user data
          print('Failed to load user data: $e');
        }
      }

      emit(RecordResultsLoaded(
        game: game,
        teamAPlayerIds: teamAPlayerIds,
        teamBPlayerIds: teamBPlayerIds,
        unassignedPlayerIds: unassignedPlayerIds,
        players: players,
      ));
    } catch (e) {
      emit(RecordResultsError(message: 'Failed to load game: ${e.toString()}'));
    }
  }

  Future<void> _onAssignPlayerToTeamA(
    AssignPlayerToTeamA event,
    Emitter<RecordResultsState> emit,
  ) async {
    if (state is! RecordResultsLoaded) return;

    final currentState = state as RecordResultsLoaded;

    // Remove from teamB if present
    final newTeamBPlayerIds = currentState.teamBPlayerIds
        .where((id) => id != event.playerId)
        .toList();

    // Remove from unassigned
    final newUnassignedPlayerIds = currentState.unassignedPlayerIds
        .where((id) => id != event.playerId)
        .toList();

    // Add to teamA if not already there
    final newTeamAPlayerIds = currentState.teamAPlayerIds.contains(event.playerId)
        ? currentState.teamAPlayerIds
        : [...currentState.teamAPlayerIds, event.playerId];

    emit(currentState.copyWith(
      teamAPlayerIds: newTeamAPlayerIds,
      teamBPlayerIds: newTeamBPlayerIds,
      unassignedPlayerIds: newUnassignedPlayerIds,
    ));
  }

  Future<void> _onAssignPlayerToTeamB(
    AssignPlayerToTeamB event,
    Emitter<RecordResultsState> emit,
  ) async {
    if (state is! RecordResultsLoaded) return;

    final currentState = state as RecordResultsLoaded;

    // Remove from teamA if present
    final newTeamAPlayerIds = currentState.teamAPlayerIds
        .where((id) => id != event.playerId)
        .toList();

    // Remove from unassigned
    final newUnassignedPlayerIds = currentState.unassignedPlayerIds
        .where((id) => id != event.playerId)
        .toList();

    // Add to teamB if not already there
    final newTeamBPlayerIds = currentState.teamBPlayerIds.contains(event.playerId)
        ? currentState.teamBPlayerIds
        : [...currentState.teamBPlayerIds, event.playerId];

    emit(currentState.copyWith(
      teamAPlayerIds: newTeamAPlayerIds,
      teamBPlayerIds: newTeamBPlayerIds,
      unassignedPlayerIds: newUnassignedPlayerIds,
    ));
  }

  Future<void> _onRemovePlayerFromTeam(
    RemovePlayerFromTeam event,
    Emitter<RecordResultsState> emit,
  ) async {
    if (state is! RecordResultsLoaded) return;

    final currentState = state as RecordResultsLoaded;

    // Remove from both teams
    final newTeamAPlayerIds = currentState.teamAPlayerIds
        .where((id) => id != event.playerId)
        .toList();
    final newTeamBPlayerIds = currentState.teamBPlayerIds
        .where((id) => id != event.playerId)
        .toList();

    // Add to unassigned if not already there
    final newUnassignedPlayerIds = currentState.unassignedPlayerIds.contains(event.playerId)
        ? currentState.unassignedPlayerIds
        : [...currentState.unassignedPlayerIds, event.playerId];

    emit(currentState.copyWith(
      teamAPlayerIds: newTeamAPlayerIds,
      teamBPlayerIds: newTeamBPlayerIds,
      unassignedPlayerIds: newUnassignedPlayerIds,
    ));
  }

  Future<void> _onSaveTeams(
    SaveTeams event,
    Emitter<RecordResultsState> emit,
  ) async {
    if (state is! RecordResultsLoaded) return;

    final currentState = state as RecordResultsLoaded;

    if (!currentState.canSave) {
      emit(const RecordResultsError(message: 'All players must be assigned to a team'));
      emit(currentState);
      return;
    }

    emit(RecordResultsSaving(
      game: currentState.game,
      teamAPlayerIds: currentState.teamAPlayerIds,
      teamBPlayerIds: currentState.teamBPlayerIds,
    ));

    try {
      final teams = GameTeams(
        teamAPlayerIds: currentState.teamAPlayerIds,
        teamBPlayerIds: currentState.teamBPlayerIds,
      );

      await _gameRepository.updateGameTeams(
        currentState.game.id,
        event.userId,
        teams,
      );

      // Fetch updated game
      final updatedGame = await _gameRepository.getGameById(currentState.game.id);

      if (updatedGame != null) {
        emit(RecordResultsSaved(game: updatedGame));
      } else {
        emit(currentState);
      }
    } catch (e) {
      emit(RecordResultsError(message: 'Failed to save teams: ${e.toString()}'));
      emit(currentState);
    }
  }
}
