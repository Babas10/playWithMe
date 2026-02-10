import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_model.freezed.dart';
part 'game_model.g.dart';

@freezed
class GameModel with _$GameModel {
  const factory GameModel({
    required String id,
    required String title,
    String? description,
    required String groupId,
    required String createdBy,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() DateTime? updatedAt,
    @TimestampConverter() required DateTime scheduledAt,
    @TimestampConverter() DateTime? startedAt,
    @TimestampConverter() DateTime? endedAt,
    required GameLocation location,
    @Default(GameStatus.scheduled) GameStatus status,
    @Default(4) int maxPlayers,
    @Default(2) int minPlayers,
    @Default([]) List<String> playerIds,
    @Default([]) List<String> waitlistIds,
    // Game settings
    @Default(true) bool allowWaitlist,
    @Default(true) bool allowPlayerInvites,
    @Default(GameVisibility.group) GameVisibility visibility,
    // Game details
    String? notes,
    @Default([]) List<String> equipment,
    Duration? estimatedDuration,
    // Court/Game specific info
    String? courtInfo,
    GameType? gameType,
    GameSkillLevel? skillLevel,
    // Scoring
    @Default([]) List<GameScore> scores,
    String? winnerId,
    // Teams (for completed games)
    GameTeams? teams,
    // Game result (for completed games with entered scores)
    GameResult? result,
    // Verification fields
    String? resultSubmittedBy,
    @Default([]) List<String> confirmedBy,
    // ELO calculation flag (set to false when result is saved, true after Python function processes)
    @Default(false) bool eloCalculated,
    // ELO updates per player (populated by Cloud Function after calculation)
    // Map<playerId, {previousRating, newRating, change}>
    // NOTE: Must be nullable (no default) so Cloud Function can detect unprocessed games
    Map<String, dynamic>? eloUpdates,
    // Timestamp when the game result was entered and completed
    @TimestampConverter() DateTime? completedAt,
    // Weather considerations
    @Default(true) bool weatherDependent,
    String? weatherNotes,
  }) = _GameModel;

  const GameModel._();

  factory GameModel.fromJson(Map<String, dynamic> json) =>
      _$GameModelFromJson(json);

  /// Factory constructor for creating from Firestore DocumentSnapshot
  factory GameModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Convert Firestore Timestamps to DateTime strings for JSON deserialization
    final jsonData = Map<String, dynamic>.from(data);

    if (data['createdAt'] is Timestamp) {
      jsonData['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
    }
    if (data['scheduledAt'] is Timestamp) {
      jsonData['scheduledAt'] = (data['scheduledAt'] as Timestamp).toDate().toIso8601String();
    }
    if (data['updatedAt'] is Timestamp) {
      jsonData['updatedAt'] = (data['updatedAt'] as Timestamp).toDate().toIso8601String();
    }
    if (data['startedAt'] is Timestamp) {
      jsonData['startedAt'] = (data['startedAt'] as Timestamp).toDate().toIso8601String();
    }
    if (data['endedAt'] is Timestamp) {
      jsonData['endedAt'] = (data['endedAt'] as Timestamp).toDate().toIso8601String();
    }
    if (data['completedAt'] is Timestamp) {
      jsonData['completedAt'] = (data['completedAt'] as Timestamp).toDate().toIso8601String();
    }

    return GameModel.fromJson({
      ...jsonData,
      'id': doc.id,
    });
  }

  /// Convert to Firestore-compatible map (excludes id since it's the document ID)
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id'); // Remove id as it's the document ID

    // Convert DateTime fields to Firestore Timestamps
    if (json['createdAt'] is String) {
      json['createdAt'] = Timestamp.fromDate(createdAt);
    }
    if (json['scheduledAt'] is String) {
      json['scheduledAt'] = Timestamp.fromDate(scheduledAt);
    }
    if (updatedAt != null && json['updatedAt'] is String) {
      json['updatedAt'] = Timestamp.fromDate(updatedAt!);
    }
    if (startedAt != null && json['startedAt'] is String) {
      json['startedAt'] = Timestamp.fromDate(startedAt!);
    }
    if (endedAt != null && json['endedAt'] is String) {
      json['endedAt'] = Timestamp.fromDate(endedAt!);
    }
    if (completedAt != null && json['completedAt'] is String) {
      json['completedAt'] = Timestamp.fromDate(completedAt!);
    }

    // Ensure nested objects are properly serialized
    if (json['location'] is GameLocation) {
      json['location'] = (json['location'] as GameLocation).toJson();
    }

    // Ensure scores list is properly serialized
    if (json['scores'] is List && (json['scores'] as List).isNotEmpty) {
      json['scores'] = (json['scores'] as List)
          .map((score) => score is GameScore ? score.toJson() : score)
          .toList();
    }

    // Ensure teams is properly serialized
    if (json['teams'] is GameTeams) {
      json['teams'] = (json['teams'] as GameTeams).toJson();
    }

    // Ensure result is properly serialized
    if (json['result'] is GameResult) {
      json['result'] = (json['result'] as GameResult).toJson();
    }

    // CRITICAL: Remove eloUpdates if null or empty to prevent Cloud Function from skipping processing
    // The Cloud Function checks `if (eloUpdates)` which is truthy for empty objects {}
    if (json['eloUpdates'] == null ||
        (json['eloUpdates'] is Map && (json['eloUpdates'] as Map).isEmpty)) {
      json.remove('eloUpdates');
    }

    return json;
  }

  /// Business logic methods

  /// Check if user is participating in the game
  bool isPlayer(String userId) => playerIds.contains(userId);

  /// Check if user is on the waitlist
  bool isOnWaitlist(String userId) => waitlistIds.contains(userId);

  /// Check if user is the creator
  bool isCreator(String userId) => createdBy == userId;

  /// Check if user can manage the game
  bool canManage(String userId) => createdBy == userId;

  /// Check if game is full
  bool get isFull => playerIds.length >= maxPlayers;

  /// Check if game has minimum players
  bool get hasMinimumPlayers => playerIds.length >= minPlayers;

  /// Get available spots
  int get availableSpots => maxPlayers - playerIds.length;

  /// Get current player count
  int get currentPlayerCount => playerIds.length;

  /// Get waitlist count
  int get waitlistCount => waitlistIds.length;

  /// Check if game can start
  bool get canStart =>
      hasMinimumPlayers &&
      status == GameStatus.scheduled &&
      scheduledAt.isBefore(DateTime.now().add(const Duration(minutes: 15)));

  /// Check if game is in the past
  bool get isPast => scheduledAt.isBefore(DateTime.now());

  /// Check if game is today
  bool get isToday {
    final now = DateTime.now();
    final gameDate = scheduledAt;
    return now.year == gameDate.year &&
           now.month == gameDate.month &&
           now.day == gameDate.day;
  }

  /// Check if game is this week
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return scheduledAt.isAfter(startOfWeek) && scheduledAt.isBefore(endOfWeek);
  }

  /// Get game duration if completed
  Duration? get gameDuration {
    if (startedAt != null && endedAt != null) {
      return endedAt!.difference(startedAt!);
    }
    return null;
  }

  /// Check if user can join the game
  bool canUserJoin(String userId) {
    if (isPlayer(userId) || isOnWaitlist(userId)) return false;
    if (status != GameStatus.scheduled) return false;
    if (isPast) return false;
    return !isFull || allowWaitlist;
  }

  /// Check if user can leave the game
  bool canUserLeave(String userId) {
    return (isPlayer(userId) || isOnWaitlist(userId)) &&
           status == GameStatus.scheduled;
  }

  /// Check if user can enter/record results for the game
  /// Allows participants (or creator) to enter results if the game is ready
  /// (completed, in-progress, or past scheduled time)
  bool canUserEnterResults(String userId) {
    final isParticipant = isPlayer(userId) || isCreator(userId);
    final hasExistingResult = result != null;
    final isCancelled = status == GameStatus.cancelled;
    final isVerification = status == GameStatus.verification;
    
    final isReady = status == GameStatus.completed || 
                    status == GameStatus.inProgress || 
                    isPast || 
                    isCreator(userId);

    return isParticipant && 
           !isCancelled && 
           !isVerification && 
           !hasExistingResult && 
           isReady;
  }

  /// Validation methods

  /// Validate game timing
  bool get hasValidTiming => scheduledAt.isAfter(DateTime.now());

  /// Validate player limits
  bool get hasValidPlayerLimits => minPlayers <= maxPlayers && minPlayers >= 2;

  /// Update methods that return new instances

  /// Update basic game information
  GameModel updateInfo({
    String? title,
    String? description,
    DateTime? scheduledAt,
    GameLocation? location,
    String? notes,
    List<String>? equipment,
    Duration? estimatedDuration,
  }) {
    return copyWith(
      title: title ?? this.title,
      description: description ?? this.description,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      equipment: equipment ?? this.equipment,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      updatedAt: DateTime.now(),
    );
  }

  /// Update game settings
  GameModel updateSettings({
    int? maxPlayers,
    int? minPlayers,
    bool? allowWaitlist,
    bool? allowPlayerInvites,
    GameVisibility? visibility,
    GameType? gameType,
    GameSkillLevel? skillLevel,
    bool? weatherDependent,
    String? weatherNotes,
  }) {
    return copyWith(
      maxPlayers: maxPlayers ?? this.maxPlayers,
      minPlayers: minPlayers ?? this.minPlayers,
      allowWaitlist: allowWaitlist ?? this.allowWaitlist,
      allowPlayerInvites: allowPlayerInvites ?? this.allowPlayerInvites,
      visibility: visibility ?? this.visibility,
      gameType: gameType ?? this.gameType,
      skillLevel: skillLevel ?? this.skillLevel,
      weatherDependent: weatherDependent ?? this.weatherDependent,
      weatherNotes: weatherNotes ?? this.weatherNotes,
      updatedAt: DateTime.now(),
    );
  }

  /// Add a player to the game
  GameModel addPlayer(String userId) {
    if (isPlayer(userId)) return this;

    // If game is full, add to waitlist if allowed
    if (isFull && allowWaitlist && !isOnWaitlist(userId)) {
      return copyWith(
        waitlistIds: [...waitlistIds, userId],
        updatedAt: DateTime.now(),
      );
    }

    // If not full, add as player and remove from waitlist if they were there
    if (!isFull) {
      return copyWith(
        playerIds: [...playerIds, userId],
        waitlistIds: waitlistIds.where((id) => id != userId).toList(),
        updatedAt: DateTime.now(),
      );
    }

    return this;
  }

  /// Remove a player from the game
  GameModel removePlayer(String userId) {
    var updated = copyWith(
      playerIds: playerIds.where((id) => id != userId).toList(),
      waitlistIds: waitlistIds.where((id) => id != userId).toList(),
      updatedAt: DateTime.now(),
    );

    // Promote someone from waitlist if there's space and waitlist exists
    if (updated.availableSpots > 0 && updated.waitlistIds.isNotEmpty) {
      final nextPlayerId = updated.waitlistIds.first;
      updated = updated.copyWith(
        playerIds: [...updated.playerIds, nextPlayerId],
        waitlistIds: updated.waitlistIds.skip(1).toList(),
      );
    }

    return updated;
  }

  /// Start the game
  GameModel startGame() {
    if (status != GameStatus.scheduled || !hasMinimumPlayers) return this;
    return copyWith(
      status: GameStatus.inProgress,
      startedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// End the game
  GameModel endGame({String? winnerId, List<GameScore>? finalScores}) {
    if (status != GameStatus.inProgress) return this;
    return copyWith(
      status: GameStatus.completed,
      endedAt: DateTime.now(),
      winnerId: winnerId,
      scores: finalScores ?? scores,
      updatedAt: DateTime.now(),
    );
  }

  /// Cancel the game
  GameModel cancelGame() {
    if (status == GameStatus.completed) return this;
    return copyWith(
      status: GameStatus.cancelled,
      updatedAt: DateTime.now(),
    );
  }

  /// Update scores
  GameModel updateScores(List<GameScore> newScores) {
    return copyWith(
      scores: newScores,
      updatedAt: DateTime.now(),
    );
  }

  /// Get formatted time until game
  String getTimeUntilGame() {
    final now = DateTime.now();
    if (scheduledAt.isBefore(now)) return 'Past';

    final difference = scheduledAt.difference(now);
    if (difference.inDays > 0) {
      return '${difference.inDays}d ${difference.inHours.remainder(24)}h';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes.remainder(60)}m';
    } else {
      return '${difference.inMinutes}m';
    }
  }
}

@freezed
class GameTeams with _$GameTeams {
  const factory GameTeams({
    @Default([]) List<String> teamAPlayerIds,
    @Default([]) List<String> teamBPlayerIds,
  }) = _GameTeams;

  const GameTeams._();

  factory GameTeams.fromJson(Map<String, dynamic> json) =>
      _$GameTeamsFromJson(json);

  /// Check if all players from the game are assigned to a team
  bool areAllPlayersAssigned(List<String> allPlayerIds) {
    final assignedPlayers = {...teamAPlayerIds, ...teamBPlayerIds};
    return allPlayerIds.every((playerId) => assignedPlayers.contains(playerId));
  }

  /// Check if a player is on both teams (validation error)
  bool hasPlayerOnBothTeams() {
    final teamASet = teamAPlayerIds.toSet();
    final teamBSet = teamBPlayerIds.toSet();
    return teamASet.intersection(teamBSet).isNotEmpty;
  }

  /// Get list of unassigned players
  List<String> getUnassignedPlayers(List<String> allPlayerIds) {
    final assignedPlayers = {...teamAPlayerIds, ...teamBPlayerIds};
    return allPlayerIds.where((playerId) => !assignedPlayers.contains(playerId)).toList();
  }

  /// Check if teams are valid (no duplicates, all players assigned)
  bool isValid(List<String> allPlayerIds) {
    return !hasPlayerOnBothTeams() && areAllPlayersAssigned(allPlayerIds);
  }
}

@freezed
class GameLocation with _$GameLocation {
  const factory GameLocation({
    required String name,
    String? address,
    double? latitude,
    double? longitude,
    String? description,
    String? parkingInfo,
    String? accessInstructions,
  }) = _GameLocation;

  factory GameLocation.fromJson(Map<String, dynamic> json) =>
      _$GameLocationFromJson(json);
}

@freezed
class GameScore with _$GameScore {
  const factory GameScore({
    required String playerId,
    required int score,
    @Default(0) int sets,
    @Default(0) int gamesWon,
    Map<String, dynamic>? additionalStats,
  }) = _GameScore;

  factory GameScore.fromJson(Map<String, dynamic> json) =>
      _$GameScoreFromJson(json);
}

/// Represents a single set in a volleyball game
@freezed
class SetScore with _$SetScore {
  const factory SetScore({
    required int teamAPoints,
    required int teamBPoints,
    required int setNumber, // 1, 2, 3, etc.
  }) = _SetScore;

  const SetScore._();

  factory SetScore.fromJson(Map<String, dynamic> json) =>
      _$SetScoreFromJson(json);

  /// Validate if the set score is valid for beach volleyball
  /// Standard rule: First to 21, win by 2
  bool isValid() {
    final maxPoints = teamAPoints > teamBPoints ? teamAPoints : teamBPoints;
    final minPoints = teamAPoints < teamBPoints ? teamAPoints : teamBPoints;

    // Must have a winner
    if (maxPoints < 21) return false;

    // Win by 2 rule
    if (maxPoints == 21) {
      return minPoints <= 19;
    }

    // Extended set (e.g., 22-20, 23-21, etc.)
    return (maxPoints - minPoints) == 2;
  }

  /// Get the winner of this set (teamA or teamB)
  String? get winner {
    if (!isValid()) return null;
    return teamAPoints > teamBPoints ? 'teamA' : 'teamB';
  }
}

/// Represents a single game played during a session
/// Most commonly a single set (first to 21), but can be best-of format
@freezed
class IndividualGame with _$IndividualGame {
  const factory IndividualGame({
    required int gameNumber, // 1, 2, 3, etc. within the session
    @SetScoreListConverter() required List<SetScore> sets,
    required String winner, // 'teamA' or 'teamB'
  }) = _IndividualGame;

  const IndividualGame._();

  factory IndividualGame.fromJson(Map<String, dynamic> json) =>
      _$IndividualGameFromJson(json);

  /// Validate the individual game
  bool isValid() {
    // Must have at least 1 set
    if (sets.isEmpty) return false;

    // All sets must be valid
    if (!sets.every((set) => set.isValid())) return false;

    // Verify set numbers are sequential
    for (int i = 0; i < sets.length; i++) {
      if (sets[i].setNumber != i + 1) return false;
    }

    // Count wins for each team
    int teamAWins = 0;
    int teamBWins = 0;

    for (final set in sets) {
      if (set.winner == 'teamA') {
        teamAWins++;
      } else if (set.winner == 'teamB') {
        teamBWins++;
      }
    }

    // Winner must have won the majority of sets
    final requiredWins = (sets.length / 2).ceil();
    if (winner == 'teamA') {
      return teamAWins >= requiredWins;
    } else if (winner == 'teamB') {
      return teamBWins >= requiredWins;
    }

    return false;
  }

  /// Get the number of sets won by each team
  Map<String, int> get setsWon {
    int teamAWins = 0;
    int teamBWins = 0;

    for (final set in sets) {
      if (set.winner == 'teamA') {
        teamAWins++;
      } else if (set.winner == 'teamB') {
        teamBWins++;
      }
    }

    return {'teamA': teamAWins, 'teamB': teamBWins};
  }
}

/// Represents the complete result of a play session
/// Contains all individual games played during the session
@freezed
class GameResult with _$GameResult {
  const factory GameResult({
    @IndividualGameListConverter() required List<IndividualGame> games,
    String? overallWinner, // 'teamA', 'teamB', or null for tie
  }) = _GameResult;

  const GameResult._();

  factory GameResult.fromJson(Map<String, dynamic> json) =>
      _$GameResultFromJson(json);

  /// Validate the entire session result
  bool isValid() {
    // Must have at least 1 game
    if (games.isEmpty) return false;

    // All games must be valid
    if (!games.every((game) => game.isValid())) return false;

    // Verify game numbers are sequential
    for (int i = 0; i < games.length; i++) {
      if (games[i].gameNumber != i + 1) return false;
    }

    // Count wins for each team
    final wins = gamesWon;

    // If overallWinner is null, it must be a tie (equal wins)
    if (overallWinner == null) {
      return wins['teamA']! == wins['teamB']!;
    }

    // Overall winner must have won more games
    if (overallWinner == 'teamA') {
      return wins['teamA']! > wins['teamB']!;
    } else if (overallWinner == 'teamB') {
      return wins['teamB']! > wins['teamA']!;
    }

    return false;
  }

  /// Get the number of games won by each team
  Map<String, int> get gamesWon {
    int teamAWins = 0;
    int teamBWins = 0;

    for (final game in games) {
      if (game.winner == 'teamA') {
        teamAWins++;
      } else if (game.winner == 'teamB') {
        teamBWins++;
      }
    }

    return {'teamA': teamAWins, 'teamB': teamBWins};
  }

  /// Get total number of games played
  int get totalGames => games.length;

  /// Get the score summary (e.g., "4-2" for Team A winning 4-2)
  String get scoreDescription {
    final wins = gamesWon;
    return '${wins['teamA']}-${wins['teamB']}';
  }
}

enum GameStatus {
  @JsonValue('scheduled')
  scheduled,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('verification')
  verification,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
}

enum GameVisibility {
  @JsonValue('group')
  group,
  @JsonValue('public')
  public,
  @JsonValue('private')
  private,
}

enum GameType {
  @JsonValue('beach_volleyball')
  beachVolleyball,
  @JsonValue('indoor_volleyball')
  indoorVolleyball,
  @JsonValue('casual')
  casual,
  @JsonValue('competitive')
  competitive,
  @JsonValue('tournament')
  tournament,
}

enum GameSkillLevel {
  @JsonValue('beginner')
  beginner,
  @JsonValue('intermediate')
  intermediate,
  @JsonValue('advanced')
  advanced,
  @JsonValue('mixed')
  mixed,
}

/// Custom converter for Firestore Timestamp to DateTime
class TimestampConverter implements JsonConverter<DateTime?, Object?> {
  const TimestampConverter();

  @override
  DateTime? fromJson(Object? json) {
    if (json == null) return null;
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.parse(json);
    if (json is int) return DateTime.fromMillisecondsSinceEpoch(json);
    return null;
  }

  @override
  Object? toJson(DateTime? object) {
    if (object == null) return null;
    return Timestamp.fromDate(object);
  }
}

/// Custom converter for List<SetScore> to handle proper JSON serialization
class SetScoreListConverter implements JsonConverter<List<SetScore>, List<dynamic>> {
  const SetScoreListConverter();

  @override
  List<SetScore> fromJson(List<dynamic> json) {
    return json.map((e) => SetScore.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  List<dynamic> toJson(List<SetScore> object) {
    return object.map((e) => e.toJson()).toList();
  }
}

/// Custom converter for List<IndividualGame> to handle proper JSON serialization
class IndividualGameListConverter implements JsonConverter<List<IndividualGame>, List<dynamic>> {
  const IndividualGameListConverter();

  @override
  List<IndividualGame> fromJson(List<dynamic> json) {
    return json.map((e) => IndividualGame.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  List<dynamic> toJson(List<IndividualGame> object) {
    return object.map((e) => e.toJson()).toList();
  }
}