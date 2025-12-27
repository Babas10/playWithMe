import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'group_model.freezed.dart';
part 'group_model.g.dart';

@freezed
class GroupModel with _$GroupModel {
  const factory GroupModel({
    required String id,
    required String name,
    String? description,
    String? photoUrl,
    required String createdBy,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) required DateTime createdAt,
    @JsonKey(fromJson: _timestampFromJsonNullable, toJson: _timestampToJsonNullable) DateTime? updatedAt,
    @Default([]) List<String> memberIds,
    @Default([]) List<String> adminIds,
    @Default([]) List<String> gameIds,
    @Default(GroupPrivacy.private) GroupPrivacy privacy,
    @Default(false) bool requiresApproval,
    @Default(20) int maxMembers,
    String? location,
    // Group settings
    @Default(true) bool allowMembersToCreateGames,
    @Default(true) bool allowMembersToInviteOthers,
    @Default(true) bool notifyMembersOfNewGames,
    // Group stats
    @Default(0) int totalGamesPlayed,
    @JsonKey(fromJson: _timestampFromJsonNullable, toJson: _timestampToJsonNullable) DateTime? lastActivity,
  }) = _GroupModel;

  const GroupModel._();

  factory GroupModel.fromJson(Map<String, dynamic> json) =>
      _$GroupModelFromJson(json);

  /// Factory constructor for creating from Firestore DocumentSnapshot
  factory GroupModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GroupModel.fromJson({
      ...data,
      'id': doc.id,
    });
  }

  /// Convert to Firestore-compatible map (excludes id since it's the document ID)
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id'); // Remove id as it's the document ID
    return json;
  }

  /// Business logic methods

  /// Check if user is a member of the group
  bool isMember(String userId) => memberIds.contains(userId);

  /// Check if user is an admin of the group
  bool isAdmin(String userId) => adminIds.contains(userId);

  /// Check if user is the creator of the group
  bool isCreator(String userId) => createdBy == userId;

  /// Check if user can manage the group (admin or creator)
  bool canManage(String userId) => isAdmin(userId) || isCreator(userId);

  /// Check if group is at capacity
  bool get isAtCapacity => memberIds.length >= maxMembers;

  /// Get member count
  int get memberCount => memberIds.length;

  /// Get admin count
  int get adminCount => adminIds.length;

  /// Check if group is active (has recent activity)
  bool get isActive {
    if (lastActivity == null) return false;
    final daysSinceLastActivity = DateTime.now().difference(lastActivity!).inDays;
    return daysSinceLastActivity <= 30; // Active if activity within 30 days
  }

  /// Validation methods

  /// Validate group name
  bool get hasValidName => name.isNotEmpty && name.length >= 3;

  /// Check if group can accept new members
  bool get canAcceptNewMembers => !isAtCapacity;

  /// Update methods that return new instances

  /// Update basic group information
  GroupModel updateInfo({
    String? name,
    String? description,
    String? photoUrl,
    String? location,
  }) {
    return copyWith(
      name: name ?? this.name,
      description: description ?? this.description,
      photoUrl: photoUrl ?? this.photoUrl,
      location: location ?? this.location,
      updatedAt: DateTime.now(),
      lastActivity: DateTime.now(),
    );
  }

  /// Update group settings
  GroupModel updateSettings({
    GroupPrivacy? privacy,
    bool? requiresApproval,
    int? maxMembers,
    bool? allowMembersToCreateGames,
    bool? allowMembersToInviteOthers,
    bool? notifyMembersOfNewGames,
  }) {
    return copyWith(
      privacy: privacy ?? this.privacy,
      requiresApproval: requiresApproval ?? this.requiresApproval,
      maxMembers: maxMembers ?? this.maxMembers,
      allowMembersToCreateGames: allowMembersToCreateGames ?? this.allowMembersToCreateGames,
      allowMembersToInviteOthers: allowMembersToInviteOthers ?? this.allowMembersToInviteOthers,
      notifyMembersOfNewGames: notifyMembersOfNewGames ?? this.notifyMembersOfNewGames,
      updatedAt: DateTime.now(),
      lastActivity: DateTime.now(),
    );
  }

  /// Add a member to the group
  GroupModel addMember(String userId) {
    if (memberIds.contains(userId) || isAtCapacity) return this;
    return copyWith(
      memberIds: [...memberIds, userId],
      updatedAt: DateTime.now(),
      lastActivity: DateTime.now(),
    );
  }

  /// Remove a member from the group
  GroupModel removeMember(String userId) {
    return copyWith(
      memberIds: memberIds.where((id) => id != userId).toList(),
      adminIds: adminIds.where((id) => id != userId).toList(), // Remove from admins too
      updatedAt: DateTime.now(),
      lastActivity: DateTime.now(),
    );
  }

  /// Promote a member to admin
  GroupModel promoteToAdmin(String userId) {
    if (!memberIds.contains(userId) || adminIds.contains(userId)) return this;
    return copyWith(
      adminIds: [...adminIds, userId],
      updatedAt: DateTime.now(),
      lastActivity: DateTime.now(),
    );
  }

  /// Demote an admin to regular member
  GroupModel demoteFromAdmin(String userId) {
    if (!adminIds.contains(userId) || userId == createdBy) return this; // Can't demote creator
    return copyWith(
      adminIds: adminIds.where((id) => id != userId).toList(),
      updatedAt: DateTime.now(),
      lastActivity: DateTime.now(),
    );
  }

  /// Add a game to the group
  GroupModel addGame(String gameId) {
    if (gameIds.contains(gameId)) return this;
    return copyWith(
      gameIds: [...gameIds, gameId],
      totalGamesPlayed: totalGamesPlayed + 1,
      updatedAt: DateTime.now(),
      lastActivity: DateTime.now(),
    );
  }

  /// Remove a game from the group
  GroupModel removeGame(String gameId) {
    return copyWith(
      gameIds: gameIds.where((id) => id != gameId).toList(),
      updatedAt: DateTime.now(),
      lastActivity: DateTime.now(),
    );
  }

  /// Update last activity timestamp
  GroupModel updateActivity() {
    return copyWith(
      lastActivity: DateTime.now(),
    );
  }

  /// Get members excluding a specific user (useful for invitations)
  List<String> getMembersExcluding(String userId) {
    return memberIds.where((id) => id != userId).toList();
  }

  /// Check if user can perform action based on group settings
  bool canUserCreateGames(String userId) {
    return isMember(userId) && (allowMembersToCreateGames || canManage(userId));
  }

  bool canUserInviteOthers(String userId) {
    return isMember(userId) && (allowMembersToInviteOthers || canManage(userId));
  }
}

enum GroupPrivacy {
  @JsonValue('public')
  public,
  @JsonValue('private')
  private,
  @JsonValue('invite_only')
  inviteOnly,
}

/// Helper functions for timestamp conversion
DateTime _timestampFromJson(Object? json) {
  if (json == null) throw ArgumentError('createdAt cannot be null');
  if (json is Timestamp) return json.toDate();
  if (json is String) return DateTime.parse(json);
  if (json is int) return DateTime.fromMillisecondsSinceEpoch(json);
  throw ArgumentError('Invalid timestamp format: $json');
}

DateTime? _timestampFromJsonNullable(Object? json) {
  if (json == null) return null;
  if (json is Timestamp) return json.toDate();
  if (json is String) return DateTime.parse(json);
  if (json is int) return DateTime.fromMillisecondsSinceEpoch(json);
  return null;
}

Object _timestampToJson(DateTime dateTime) {
  return Timestamp.fromDate(dateTime);
}

Object? _timestampToJsonNullable(DateTime? dateTime) {
  if (dateTime == null) return null;
  return Timestamp.fromDate(dateTime);
}

/// Custom converter for Firestore Timestamp to DateTime
/// Note: This is kept for backwards compatibility but use JsonKey with helper functions instead
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