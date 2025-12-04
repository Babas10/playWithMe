import '../../data/models/game_model.dart';

abstract class GameRepository {
  /// Get game by ID
  Future<GameModel?> getGameById(String gameId);

  /// Stream game by ID (real-time updates)
  Stream<GameModel?> getGameStream(String gameId);

  /// Get multiple games by IDs
  Future<List<GameModel>> getGamesByIds(List<String> gameIds);

  /// Get games for a user
  Stream<List<GameModel>> getGamesForUser(String userId);

  /// Get games for a group
  Stream<List<GameModel>> getGamesForGroup(String groupId);

  /// Get count of upcoming games for a group
  Stream<int> getUpcomingGamesCount(String groupId);

  /// Get upcoming games for a user
  Stream<List<GameModel>> getUpcomingGamesForUser(String userId);

  /// Get past games for a user
  Future<List<GameModel>> getPastGamesForUser(String userId, {int limit = 20});

  /// Create a new game
  Future<String> createGame(GameModel game);

  /// Update game information
  Future<void> updateGameInfo(String gameId, {
    String? title,
    String? description,
    DateTime? scheduledAt,
    GameLocation? location,
    String? notes,
    List<String>? equipment,
    Duration? estimatedDuration,
  });

  /// Update game settings
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
  });

  /// Add player to game
  Future<void> addPlayer(String gameId, String userId);

  /// Remove player from game
  Future<void> removePlayer(String gameId, String userId);

  /// Start game
  Future<void> startGame(String gameId);

  /// End game
  Future<void> endGame(String gameId, {
    String? winnerId,
    List<GameScore>? finalScores,
  });

  /// Cancel game
  Future<void> cancelGame(String gameId);

  /// Mark game as completed
  Future<void> markGameAsCompleted(String gameId, String userId);

  /// Update game teams (for completed games)
  Future<void> updateGameTeams(String gameId, String userId, GameTeams teams);

  /// Update game scores
  Future<void> updateScores(String gameId, List<GameScore> scores);

  /// Get games by location
  Future<List<GameModel>> getGamesByLocation(
    double latitude,
    double longitude,
    double radiusKm, {
    int limit = 20,
  });

  /// Get games by status
  Future<List<GameModel>> getGamesByStatus(
    GameStatus status, {
    int limit = 20,
  });

  /// Get games scheduled for today
  Future<List<GameModel>> getGamesToday();

  /// Get games scheduled for this week
  Future<List<GameModel>> getGamesThisWeek();

  /// Search games by title or description
  Future<List<GameModel>> searchGames(String query, {int limit = 20});

  /// Get game participants
  Future<List<String>> getGameParticipants(String gameId);

  /// Get game waitlist
  Future<List<String>> getGameWaitlist(String gameId);

  /// Check if user can join game
  Future<bool> canUserJoinGame(String gameId, String userId);

  /// Delete game
  Future<void> deleteGame(String gameId);

  /// Check if game exists
  Future<bool> gameExists(String gameId);

  /// Get game statistics
  Future<Map<String, dynamic>> getGameStats(String gameId);
}