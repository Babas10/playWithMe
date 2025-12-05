// Mock repository for GameRepository used in testing
import 'dart:async';

import 'package:play_with_me/core/data/models/game_model.dart';
import 'package:play_with_me/core/domain/repositories/game_repository.dart';

class MockGameRepository implements GameRepository {
  final StreamController<List<GameModel>> _gamesController = StreamController<List<GameModel>>.broadcast();
  final Map<String, StreamController<GameModel?>> _gameStreamControllers = {};
  final Map<String, GameModel> _games = {};
  String _lastCreatedGameId = '';

  MockGameRepository() {
    // Seed initial empty list to match real repository behavior
    _gamesController.add(const []);
  }

  StreamController<List<GameModel>> get gamesController => _gamesController;

  // Helper methods for testing
  void addGame(GameModel game) {
    _games[game.id] = game;
    _emitGames();
    _emitGameUpdate(game.id); // Emit to individual game stream as well
  }

  void clearGames() {
    _games.clear();
    _emitGames();
  }

  void _emitGames() {
    if (!_gamesController.isClosed) {
      _gamesController.add(_games.values.toList());
    }
  }

  void _emitGameUpdate(String gameId) {
    final controller = _gameStreamControllers[gameId];
    if (controller != null && !controller.isClosed) {
      // Synchronous emission - no delays, no async
      controller.add(_games[gameId]);
    }
  }

  void dispose() {
    _gamesController.close();
    for (final controller in _gameStreamControllers.values) {
      controller.close();
    }
    _gameStreamControllers.clear();
  }

  // Repository methods
  @override
  Future<GameModel?> getGameById(String gameId) async {
    return _games[gameId];
  }

  @override
  Stream<GameModel?> getGameStream(String gameId) {
    if (!_gameStreamControllers.containsKey(gameId)) {
      // Create broadcast controller with synchronous emission on listen
      late final StreamController<GameModel?> controller;
      controller = StreamController<GameModel?>.broadcast(
        onListen: () {
          // Always emit current value SYNCHRONOUSLY when listener attaches
          // This ensures no timing race conditions
          controller.add(_games[gameId]);
        },
      );
      _gameStreamControllers[gameId] = controller;
    }

    return _gameStreamControllers[gameId]!.stream;
  }

  @override
  Future<List<GameModel>> getGamesByIds(List<String> gameIds) async {
    return gameIds
        .map((id) => _games[id])
        .where((game) => game != null)
        .cast<GameModel>()
        .toList();
  }

  @override
  Stream<List<GameModel>> getGamesForUser(String userId) {
    return _gamesController.stream.map((games) =>
        games.where((game) => game.playerIds.contains(userId)).toList());
  }

  @override
  Stream<List<GameModel>> getGamesForGroup(String groupId) async* {
    // Emit current state immediately
    yield _games.values.where((game) => game.groupId == groupId).toList();

    // Then emit future updates
    await for (final games in _gamesController.stream) {
      yield games.where((game) => game.groupId == groupId).toList();
    }
  }

  @override
  Stream<int> getUpcomingGamesCount(String groupId) async* {
    final now = DateTime.now();

    // Emit current count immediately
    yield _games.values
        .where((game) =>
            game.groupId == groupId &&
            game.scheduledAt.isAfter(now) &&
            game.status == GameStatus.scheduled)
        .length;

    // Then emit future updates
    await for (final games in _gamesController.stream) {
      final updatedNow = DateTime.now();
      yield games
          .where((game) =>
              game.groupId == groupId &&
              game.scheduledAt.isAfter(updatedNow) &&
              game.status == GameStatus.scheduled)
          .length;
    }
  }

  @override
  Stream<List<GameModel>> getUpcomingGamesForUser(String userId) {
    final now = DateTime.now();
    return _gamesController.stream.map((games) =>
        games.where((game) =>
            game.playerIds.contains(userId) &&
            game.scheduledAt.isAfter(now)).toList());
  }

  @override
  Future<List<GameModel>> getPastGamesForUser(String userId, {int limit = 20}) async {
    final now = DateTime.now();
    return _games.values
        .where((game) =>
            game.playerIds.contains(userId) &&
            game.scheduledAt.isBefore(now))
        .take(limit)
        .toList();
  }

  @override
  Future<String> createGame(GameModel game) async {
    final gameId = 'game-${DateTime.now().millisecondsSinceEpoch}';
    final gameWithId = game.copyWith(id: gameId);
    _games[gameId] = gameWithId;
    _lastCreatedGameId = gameId;
    _emitGames();
    return gameId;
  }

  String get lastCreatedGameId => _lastCreatedGameId;

  @override
  Future<void> updateGameInfo(String gameId, {
    String? title,
    String? description,
    DateTime? scheduledAt,
    GameLocation? location,
    String? notes,
    List<String>? equipment,
    Duration? estimatedDuration,
  }) async {
    final game = _games[gameId];
    if (game == null) throw Exception('Game not found');

    final updatedGame = game.updateInfo(
      title: title,
      description: description,
      scheduledAt: scheduledAt,
      location: location,
      notes: notes,
      equipment: equipment,
      estimatedDuration: estimatedDuration,
    );

    _games[gameId] = updatedGame;
    _emitGames();
  }

  @override
  Future<void> updateGameSettings(String gameId, {
    int? maxPlayers,
    int? minPlayers,
    bool? allowWaitlist,
    bool? allowPlayerInvites,
    GameVisibility? visibility,
    GameType? gameType,
    GameSkillLevel? skillLevel,
    bool? weatherDependent,
    String? weatherNotes,
  }) async {
    final game = _games[gameId];
    if (game == null) throw Exception('Game not found');

    final updatedGame = game.updateSettings(
      maxPlayers: maxPlayers,
      minPlayers: minPlayers,
      allowWaitlist: allowWaitlist,
      allowPlayerInvites: allowPlayerInvites,
      visibility: visibility,
      gameType: gameType,
      skillLevel: skillLevel,
      weatherDependent: weatherDependent,
      weatherNotes: weatherNotes,
    );

    _games[gameId] = updatedGame;
    _emitGames();
  }

  @override
  Future<void> addPlayer(String gameId, String userId) async {
    final game = _games[gameId];
    if (game == null) throw Exception('Game not found');

    final updatedGame = game.addPlayer(userId);
    _games[gameId] = updatedGame;
    _emitGames();
    _emitGameUpdate(gameId);
  }

  @override
  Future<void> removePlayer(String gameId, String userId) async {
    final game = _games[gameId];
    if (game == null) throw Exception('Game not found');

    final updatedGame = game.removePlayer(userId);
    _games[gameId] = updatedGame;
    _emitGames();
    _emitGameUpdate(gameId);
  }

  @override
  Future<void> startGame(String gameId) async {
    final game = _games[gameId];
    if (game == null) throw Exception('Game not found');

    final updatedGame = game.startGame();
    _games[gameId] = updatedGame;
    _emitGames();
  }

  @override
  Future<void> endGame(String gameId, {
    String? winnerId,
    List<GameScore>? finalScores,
  }) async {
    final game = _games[gameId];
    if (game == null) throw Exception('Game not found');

    final updatedGame = game.endGame(
      winnerId: winnerId,
      finalScores: finalScores,
    );

    _games[gameId] = updatedGame;
    _emitGames();
  }

  @override
  Future<void> cancelGame(String gameId) async {
    final game = _games[gameId];
    if (game == null) throw Exception('Game not found');

    final updatedGame = game.cancelGame();
    _games[gameId] = updatedGame;
    _emitGames();
  }

  @override
  Future<void> markGameAsCompleted(String gameId, String userId) async {
    final game = _games[gameId];
    if (game == null) throw Exception('Game not found');

    // Check if user has permission (creator only)
    if (!game.isCreator(userId)) {
      throw Exception('Only the game creator can mark the game as completed');
    }

    // Check if game can be marked as completed
    if (game.status == GameStatus.completed) {
      throw Exception('Game is already completed');
    }

    if (game.status == GameStatus.cancelled) {
      throw Exception('Cannot complete a cancelled game');
    }

    // Update game status to completed
    final updatedGame = game.copyWith(
      status: GameStatus.completed,
      endedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _games[gameId] = updatedGame;
    _emitGames();
    _emitGameUpdate(gameId);
  }

  @override
  Future<void> updateGameTeams(String gameId, String userId, GameTeams teams) async {
    final game = _games[gameId];
    if (game == null) throw Exception('Game not found');

    // Check if user has permission (creator only)
    if (!game.isCreator(userId)) {
      throw Exception('Only the game creator can update teams');
    }

    // Check if game is completed
    if (game.status != GameStatus.completed) {
      throw Exception('Can only assign teams to completed games');
    }

    // Validate teams
    if (teams.hasPlayerOnBothTeams()) {
      throw Exception('A player cannot be on both teams');
    }

    if (!teams.areAllPlayersAssigned(game.playerIds)) {
      final unassigned = teams.getUnassignedPlayers(game.playerIds);
      throw Exception('All players must be assigned to a team. Unassigned: ${unassigned.join(", ")}');
    }

    // Update game with teams
    final updatedGame = game.copyWith(
      teams: teams,
      updatedAt: DateTime.now(),
    );

    _games[gameId] = updatedGame;
    _emitGames();
    _emitGameUpdate(gameId);
  }

  @override
  Future<void> updateGameResult(String gameId, String userId, GameResult result) async {
    final game = _games[gameId];
    if (game == null) throw Exception('Game not found');

    // Check if user has permission (creator only)
    if (!game.isCreator(userId)) {
      throw Exception('Only the game creator can update game result');
    }

    // Check if game is completed
    if (game.status != GameStatus.completed) {
      throw Exception('Can only add result to completed games');
    }

    // Check if teams are assigned
    if (game.teams == null) {
      throw Exception('Teams must be assigned before entering scores');
    }

    // Validate result
    if (!result.isValid()) {
      throw Exception('Invalid game result. Check that all sets are valid and winner is correct.');
    }

    // Update game with result
    final updatedGame = game.copyWith(
      result: result,
      winnerId: result.overallWinner,
      updatedAt: DateTime.now(),
    );

    _games[gameId] = updatedGame;
    _emitGames();
    _emitGameUpdate(gameId);
  }

  @override
  Future<void> saveGameResult({
    required String gameId,
    required String userId,
    required GameTeams teams,
    required GameResult result,
  }) async {
    final game = _games[gameId];
    if (game == null) throw Exception('Game not found');

    // Check if user has permission (creator only)
    if (!game.isCreator(userId)) {
      throw Exception('Only the game creator can save game result');
    }

    // Check if game is completed
    if (game.status != GameStatus.completed) {
      throw Exception('Can only save result to completed games');
    }

    // Validate teams
    if (teams.hasPlayerOnBothTeams()) {
      throw Exception('A player cannot be on both teams');
    }

    if (!teams.areAllPlayersAssigned(game.playerIds)) {
      final unassigned = teams.getUnassignedPlayers(game.playerIds);
      throw Exception('All players must be assigned to a team. Unassigned: ${unassigned.join(", ")}');
    }

    // Validate result
    if (!result.isValid()) {
      throw Exception('Invalid game result. Check that all sets are valid and winner is correct.');
    }

    // Update game with teams, result, eloCalculated flag, and completedAt timestamp
    final updatedGame = game.copyWith(
      teams: teams,
      result: result,
      winnerId: result.overallWinner,
      eloCalculated: false,
      completedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _games[gameId] = updatedGame;
    _emitGames();
    _emitGameUpdate(gameId);
  }

  @override
  Future<void> updateScores(String gameId, List<GameScore> scores) async {
    final game = _games[gameId];
    if (game == null) throw Exception('Game not found');

    final updatedGame = game.updateScores(scores);
    _games[gameId] = updatedGame;
    _emitGames();
  }

  @override
  Future<List<GameModel>> getGamesByLocation(
    double latitude,
    double longitude,
    double radiusKm, {
    int limit = 20,
  }) async {
    // Simple mock implementation - just return all games for testing
    return _games.values.take(limit).toList();
  }

  @override
  Future<List<GameModel>> getGamesByStatus(
    GameStatus status, {
    int limit = 20,
  }) async {
    return _games.values
        .where((game) => game.status == status)
        .take(limit)
        .toList();
  }

  @override
  Future<List<GameModel>> getGamesToday() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _games.values
        .where((game) =>
            game.scheduledAt.isAfter(startOfDay) &&
            game.scheduledAt.isBefore(endOfDay))
        .toList();
  }

  @override
  Future<List<GameModel>> getGamesThisWeek() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    return _games.values
        .where((game) =>
            game.scheduledAt.isAfter(startOfWeek) &&
            game.scheduledAt.isBefore(endOfWeek))
        .toList();
  }

  @override
  Future<List<GameModel>> searchGames(String query, {int limit = 20}) async {
    final queryLower = query.toLowerCase();
    return _games.values
        .where((game) =>
            game.title.toLowerCase().contains(queryLower) ||
            (game.description?.toLowerCase().contains(queryLower) == true))
        .take(limit)
        .toList();
  }

  @override
  Future<List<String>> getGameParticipants(String gameId) async {
    final game = _games[gameId];
    return game?.playerIds ?? [];
  }

  @override
  Future<List<String>> getGameWaitlist(String gameId) async {
    final game = _games[gameId];
    return game?.waitlistIds ?? [];
  }

  @override
  Future<bool> canUserJoinGame(String gameId, String userId) async {
    final game = _games[gameId];
    if (game == null) return false;

    return game.canUserJoin(userId);
  }

  @override
  Future<void> deleteGame(String gameId) async {
    _games.remove(gameId);
    _emitGames();
  }

  @override
  Future<bool> gameExists(String gameId) async {
    return _games.containsKey(gameId);
  }

  @override
  Future<Map<String, dynamic>> getGameStats(String gameId) async {
    final game = _games[gameId];
    if (game == null) throw Exception('Game not found');

    return {
      'currentPlayerCount': game.currentPlayerCount,
      'availableSpots': game.availableSpots,
      'waitlistCount': game.waitlistCount,
      'isFull': game.isFull,
      'hasMinimumPlayers': game.hasMinimumPlayers,
      'canStart': game.canStart,
      'isPast': game.isPast,
      'isToday': game.isToday,
      'isThisWeek': game.isThisWeek,
      'gameDuration': game.gameDuration?.inMinutes,
      'status': game.status.toString().split('.').last,
      'createdAt': game.createdAt.toIso8601String(),
      'scheduledAt': game.scheduledAt.toIso8601String(),
    };
  }
}

// Test data helpers
class TestGameData {
  static final testGame = GameModel(
    id: 'test-game-123',
    title: 'Beach Volleyball Test Game',
    description: 'A test game for unit testing',
    groupId: 'test-group-123',
    createdBy: 'test-uid-123',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    scheduledAt: DateTime.now().add(const Duration(hours: 2)),
    location: const GameLocation(
      name: 'Test Beach',
      address: '123 Test Beach St',
      latitude: 40.7128,
      longitude: -74.0060,
      description: 'A beautiful test beach',
    ),
    status: GameStatus.scheduled,
    maxPlayers: 4,
    minPlayers: 2,
    playerIds: ['test-uid-123', 'user-uid-789'],
    waitlistIds: [],
    allowWaitlist: true,
    allowPlayerInvites: true,
    visibility: GameVisibility.group,
    notes: 'Bring sunscreen!',
    equipment: ['Volleyball', 'Net'],
    gameType: GameType.beachVolleyball,
    skillLevel: GameSkillLevel.intermediate,
    scores: [],
    weatherDependent: true,
  );

  static final upcomingGame = GameModel(
    id: 'upcoming-game-456',
    title: 'Upcoming Test Game',
    description: 'A game scheduled for tomorrow',
    groupId: 'test-group-123',
    createdBy: 'test-uid-123',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    scheduledAt: DateTime.now().add(const Duration(days: 1)),
    location: const GameLocation(
      name: 'Future Beach',
      address: '456 Future Beach St',
      latitude: 40.7580,
      longitude: -73.9855,
    ),
    status: GameStatus.scheduled,
    maxPlayers: 6,
    minPlayers: 4,
    playerIds: ['test-uid-123'],
    waitlistIds: [],
    allowWaitlist: true,
    allowPlayerInvites: true,
    visibility: GameVisibility.public,
    gameType: GameType.beachVolleyball,
    skillLevel: GameSkillLevel.beginner,
    scores: [],
    weatherDependent: true,
  );

  static final pastGame = GameModel(
    id: 'past-game-789',
    title: 'Past Test Game',
    description: 'A completed game',
    groupId: 'test-group-123',
    createdBy: 'test-uid-123',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    scheduledAt: DateTime.now().subtract(const Duration(days: 1)),
    startedAt: DateTime.now().subtract(const Duration(hours: 25)),
    endedAt: DateTime.now().subtract(const Duration(hours: 24)),
    location: const GameLocation(
      name: 'Past Beach',
      address: '789 Past Beach St',
      latitude: 40.6892,
      longitude: -74.0445,
    ),
    status: GameStatus.completed,
    maxPlayers: 4,
    minPlayers: 2,
    playerIds: ['test-uid-123', 'user-uid-789'],
    waitlistIds: [],
    allowWaitlist: true,
    allowPlayerInvites: true,
    visibility: GameVisibility.group,
    gameType: GameType.beachVolleyball,
    skillLevel: GameSkillLevel.intermediate,
    scores: [
      const GameScore(playerId: 'test-uid-123', score: 21),
      const GameScore(playerId: 'user-uid-789', score: 19),
    ],
    winnerId: 'test-uid-123',
    weatherDependent: true,
  );

  static final fullGame = GameModel(
    id: 'full-game-101',
    title: 'Full Test Game',
    description: 'A game at maximum capacity',
    groupId: 'test-group-123',
    createdBy: 'test-uid-123',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    scheduledAt: DateTime.now().add(const Duration(hours: 3)),
    location: const GameLocation(
      name: 'Busy Beach',
      address: '101 Busy Beach St',
      latitude: 40.7410,
      longitude: -73.9896,
    ),
    status: GameStatus.scheduled,
    maxPlayers: 2,
    minPlayers: 2,
    playerIds: ['test-uid-123', 'user-uid-789'], // Already full
    waitlistIds: ['another-uid-101'],
    allowWaitlist: true,
    allowPlayerInvites: true,
    visibility: GameVisibility.group,
    gameType: GameType.beachVolleyball,
    skillLevel: GameSkillLevel.advanced,
    scores: [],
    weatherDependent: true,
  );
}