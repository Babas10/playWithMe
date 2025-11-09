import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_entity.freezed.dart';

@freezed
class UserEntity with _$UserEntity {
  const factory UserEntity({
    required String uid,
    required String email,
    String? displayName,
    String? photoUrl,
    required bool isEmailVerified,
    DateTime? createdAt,
    DateTime? lastSignInAt,
    required bool isAnonymous,
    @Default([]) List<String> fcmTokens,
    // Social graph cache fields (Story 11.6)
    @Default([]) List<String> friendIds,
    @Default(0) int friendCount,
    DateTime? friendsLastUpdated,
  }) = _UserEntity;

  const UserEntity._();

  /// Check if the user has a complete profile
  bool get hasCompleteProfile => displayName != null && displayName!.isNotEmpty;

  /// Get display name or fallback to email
  String get displayNameOrEmail => displayName ?? email;

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