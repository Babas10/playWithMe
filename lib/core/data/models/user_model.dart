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
    @Default(0) int totalScore,
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
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? location,
    String? bio,
    DateTime? dateOfBirth,
  }) {
    return copyWith(
      displayName: displayName ?? this.displayName,
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
    return copyWith(
      gameIds: [...gameIds, gameId],
      gamesPlayed: gamesPlayed + 1,
      gamesWon: won ? gamesWon + 1 : gamesWon,
      totalScore: totalScore + score,
      updatedAt: DateTime.now(),
    );
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