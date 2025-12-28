import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String uid,
    required String email,
    String? displayName,
    String? photoUrl,
    required bool isEmailVerified,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? lastSignInAt,
    @TimestampConverter() DateTime? updatedAt,
    required bool isAnonymous,
    // Extended fields for full user profile
    String? firstName,
    String? lastName,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? location,
    String? bio,
    @Default([]) List<String> groupIds,
    @Default([]) List<String> gameIds,
    // Social graph cache fields (Story 11.6)
    @Default([]) List<String> friendIds,
    @Default(0) int friendCount,
    @TimestampConverter() DateTime? friendsLastUpdated,
    // User preferences
    @Default(true) bool notificationsEnabled,
    @Default(true) bool emailNotifications,
    @Default(true) bool pushNotifications,
    // Privacy settings
    @Default(UserPrivacyLevel.public) UserPrivacyLevel privacyLevel,
    @Default(true) bool showEmail,
    @Default(true) bool showPhoneNumber,
    // Stats
    @Default(0) int gamesPlayed,
    @Default(0) int gamesWon,
    @Default(0) int gamesLost,
    @Default(0) int totalScore,
    @Default(0) int currentStreak,
    @Default([]) List<String> recentGameIds,
    @TimestampConverter() DateTime? lastGameDate,
    @Default({}) Map<String, dynamic> teammateStats,
    // ELO Rating fields (Story 14.5.3)
    @Default(1600.0) double eloRating,
    @TimestampConverter() DateTime? eloLastUpdated,
    @Default(1600.0) double eloPeak,
    @TimestampConverter() DateTime? eloPeakDate,
    @Default(0) int eloGamesPlayed,
    // Nemesis/Rival tracking (Story 301.8)
    NemesisRecord? nemesis,
    // Best Win tracking (Story 301.6)
    BestWinRecord? bestWin,
  }) = _UserModel;

  const UserModel._();

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// Factory constructor for creating from Firestore DocumentSnapshot
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromJson({
      ...data,
      'uid': doc.id,
    });
  }

  /// Convert to Firestore-compatible map (excludes uid since it's the document ID)
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('uid'); // Remove uid as it's the document ID
    return json;
  }

  /// Business logic methods

  /// Check if the user has a complete profile
  bool get hasCompleteProfile =>
      displayName != null &&
      displayName!.isNotEmpty &&
      firstName != null &&
      lastName != null;

  /// Get full display name
  String get fullDisplayName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return displayName ?? email;
  }

  /// Get display name or fallback to email
  String get displayNameOrEmail => displayName ?? email;

  /// Check if user can be contacted
  bool get canBeContacted =>
      (showEmail || (showPhoneNumber && phoneNumber != null)) &&
      privacyLevel != UserPrivacyLevel.private;

  /// Calculate win rate
  double get winRate => gamesPlayed > 0 ? gamesWon / gamesPlayed : 0.0;

  /// Calculate loss rate
  double get lossRate => gamesPlayed > 0 ? gamesLost / gamesPlayed : 0.0;

  /// Check if currently on a winning streak
  bool get isOnWinningStreak => currentStreak > 0;

  /// Check if currently on a losing streak
  bool get isOnLosingStreak => currentStreak < 0;

  /// Get absolute streak value
  int get streakValue => currentStreak.abs();

  /// Calculate average score per game
  double get averageScore => gamesPlayed > 0 ? totalScore / gamesPlayed : 0.0;

  /// Validation methods

  /// Validate email format
  bool get hasValidEmail => email.isNotEmpty && email.contains('@');

  /// Check if user is active (has logged in recently)
  bool get isActive {
    if (lastSignInAt == null) return false;
    final daysSinceLastLogin = DateTime.now().difference(lastSignInAt!).inDays;
    return daysSinceLastLogin <= 30; // Active if logged in within 30 days
  }

  /// Update methods that return new instances

  /// Update basic profile information
  UserModel updateProfile({
    String? displayName,
    String? photoUrl,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? location,
    String? bio,
    DateTime? dateOfBirth,
  }) {
    return copyWith(
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      location: location ?? this.location,
      bio: bio ?? this.bio,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      updatedAt: DateTime.now(),
    );
  }

  /// Update preferences
  UserModel updatePreferences({
    bool? notificationsEnabled,
    bool? emailNotifications,
    bool? pushNotifications,
  }) {
    return copyWith(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      updatedAt: DateTime.now(),
    );
  }

  /// Update privacy settings
  UserModel updatePrivacy({
    UserPrivacyLevel? privacyLevel,
    bool? showEmail,
    bool? showPhoneNumber,
  }) {
    return copyWith(
      privacyLevel: privacyLevel ?? this.privacyLevel,
      showEmail: showEmail ?? this.showEmail,
      showPhoneNumber: showPhoneNumber ?? this.showPhoneNumber,
      updatedAt: DateTime.now(),
    );
  }

  /// Join a group
  UserModel joinGroup(String groupId) {
    if (groupIds.contains(groupId)) return this;
    return copyWith(
      groupIds: [...groupIds, groupId],
      updatedAt: DateTime.now(),
    );
  }

  /// Leave a group
  UserModel leaveGroup(String groupId) {
    return copyWith(
      groupIds: groupIds.where((id) => id != groupId).toList(),
      updatedAt: DateTime.now(),
    );
  }

  /// Add game participation
  UserModel addGame(String gameId, {bool won = false, int score = 0}) {
    final newGameIds = gameIds.contains(gameId) ? gameIds : [...gameIds, gameId];
    return copyWith(
      gameIds: newGameIds,
      gamesPlayed: gamesPlayed + 1,
      gamesWon: won ? gamesWon + 1 : gamesWon,
      totalScore: totalScore + score,
      updatedAt: DateTime.now(),
    );
  }

  /// Add friend to cache (Story 11.6)
  UserModel addFriend(String friendId) {
    if (friendIds.contains(friendId)) return this;
    return copyWith(
      friendIds: [...friendIds, friendId],
      friendCount: friendCount + 1,
      friendsLastUpdated: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Remove friend from cache (Story 11.6)
  UserModel removeFriend(String friendId) {
    if (!friendIds.contains(friendId)) return this;
    return copyWith(
      friendIds: friendIds.where((id) => id != friendId).toList(),
      friendCount: friendCount > 0 ? friendCount - 1 : 0,
      friendsLastUpdated: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Check if user is a friend (Story 11.6)
  bool isFriend(String userId) => friendIds.contains(userId);

  /// Check if friend cache needs refresh (Story 11.6)
  /// Cache is considered stale after 24 hours
  bool get needsFriendCacheRefresh {
    if (friendsLastUpdated == null) return true;
    final hoursSinceUpdate =
        DateTime.now().difference(friendsLastUpdated!).inHours;
    return hoursSinceUpdate > 24;
  }
}

enum UserPrivacyLevel {
  @JsonValue('public')
  public,
  @JsonValue('friends')
  friends,
  @JsonValue('private')
  private,
}

/// Custom converter for Firestore Timestamp to DateTime (nullable)
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

/// Custom converter for Firestore Timestamp to DateTime (required/non-nullable)
class RequiredTimestampConverter implements JsonConverter<DateTime, Object> {
  const RequiredTimestampConverter();

  @override
  DateTime fromJson(Object json) {
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.parse(json);
    if (json is int) return DateTime.fromMillisecondsSinceEpoch(json);
    throw ArgumentError('Cannot convert $json to DateTime');
  }

  @override
  Object toJson(DateTime object) {
    return Timestamp.fromDate(object);
  }
}

/// Nemesis record tracking the opponent a player has lost to most often.
/// This record is automatically updated by Cloud Functions after each game.
@freezed
class NemesisRecord with _$NemesisRecord {
  const factory NemesisRecord({
    /// Opponent user ID
    required String opponentId,

    /// Opponent display name (cached for quick display)
    required String opponentName,

    /// Total games lost against this opponent
    required int gamesLost,

    /// Total games won against this opponent
    required int gamesWon,

    /// Total games played against this opponent (gamesWon + gamesLost)
    required int gamesPlayed,

    /// Win rate as percentage (0-100)
    required double winRate,
  }) = _NemesisRecord;

  const NemesisRecord._();

  factory NemesisRecord.fromJson(Map<String, dynamic> json) =>
      _$NemesisRecordFromJson(json);

  /// Format win-loss record as string (e.g., "3W - 7L")
  String get recordString => '${gamesWon}W - ${gamesLost}L';

  /// Check if this is a true nemesis (win rate < 50%)
  bool get isTrueNemesis => winRate < 50.0;

  /// Get rivalry level based on games played
  String get rivalryLevel {
    if (gamesPlayed >= 10) return 'Intense Rivalry';
    if (gamesPlayed >= 5) return 'Developing Rivalry';
    return 'New Matchup';
  }
}

/// Best win record tracking the highest-rated opponent team defeated.
/// This record is automatically updated by Cloud Functions after each game win.
@freezed
class BestWinRecord with _$BestWinRecord {
  const factory BestWinRecord({
    /// Game ID where this best win occurred
    required String gameId,

    /// Combined opponent team ELO at time of game
    required double opponentTeamElo,

    /// Average opponent team ELO at time of game
    required double opponentTeamAvgElo,

    /// ELO gained from this specific win
    required double eloGained,

    /// Date when this win occurred
    @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson) required DateTime date,

    /// Game title or description for display
    required String gameTitle,
  }) = _BestWinRecord;

  const BestWinRecord._();

  factory BestWinRecord.fromJson(Map<String, dynamic> json) =>
      _$BestWinRecordFromJson(json);

  /// Format ELO gain as string with sign (e.g., "+24")
  String get eloGainString => '+${eloGained.toStringAsFixed(0)}';

  /// Get formatted average opponent ELO (rounded)
  String get avgEloString => opponentTeamAvgElo.toStringAsFixed(0);

  /// Get formatted team ELO (rounded)
  String get teamEloString => opponentTeamElo.toStringAsFixed(0);
}

// Helper functions for BestWinRecord date field
DateTime _dateFromJson(dynamic value) {
  final result = const TimestampConverter().fromJson(value);
  if (result == null) {
    throw ArgumentError('BestWinRecord date cannot be null');
  }
  return result;
}

dynamic _dateToJson(DateTime date) {
  return const TimestampConverter().toJson(date);
}