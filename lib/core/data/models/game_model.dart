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
    return GameModel.fromJson({
      ...data,
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

enum GameStatus {
  @JsonValue('scheduled')
  scheduled,
  @JsonValue('in_progress')
  inProgress,
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