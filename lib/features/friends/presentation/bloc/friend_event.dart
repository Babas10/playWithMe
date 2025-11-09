import 'package:freezed_annotation/freezed_annotation.dart';

part 'friend_event.freezed.dart';

/// Events for the FriendBloc
@freezed
class FriendEvent with _$FriendEvent {
  /// Load all friends and pending requests for the current user
  const factory FriendEvent.loadRequested() = FriendLoadRequested;

  /// Send a friend request to a user
  const factory FriendEvent.requestSent({
    required String targetUserId,
  }) = FriendRequestSent;

  /// Accept a friend request
  const factory FriendEvent.requestAccepted({
    required String friendshipId,
  }) = FriendRequestAccepted;

  /// Decline a friend request
  const factory FriendEvent.requestDeclined({
    required String friendshipId,
  }) = FriendRequestDeclined;

  /// Cancel a sent friend request
  const factory FriendEvent.requestCancelled({
    required String friendshipId,
  }) = FriendRequestCancelled;

  /// Remove a friend (delete friendship)
  const factory FriendEvent.removed({
    required String friendshipId,
  }) = FriendRemoved;

  /// Search for a user by email
  const factory FriendEvent.searchRequested({
    required String email,
  }) = FriendSearchRequested;

  /// Clear search results
  const factory FriendEvent.searchCleared() = FriendSearchCleared;

  /// Check friendship status with a specific user
  const factory FriendEvent.statusChecked({
    required String userId,
  }) = FriendStatusChecked;
}
