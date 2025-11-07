import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:play_with_me/core/domain/entities/friendship_entity.dart';
import 'package:play_with_me/core/domain/entities/friendship_status_result.dart';
import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';

part 'friend_state.freezed.dart';

/// States for the FriendBloc
@freezed
class FriendState with _$FriendState {
  /// Initial state
  const factory FriendState.initial() = FriendInitial;

  /// Loading state
  const factory FriendState.loading() = FriendLoading;

  /// Loaded state with friends and pending requests
  const factory FriendState.loaded({
    required List<UserEntity> friends,
    required List<FriendshipEntity> receivedRequests,
    required List<FriendshipEntity> sentRequests,
  }) = FriendLoaded;

  /// Search result state
  const factory FriendState.searchResult({
    UserEntity? user,
    required bool isFriend,
    required bool hasPendingRequest,
    String? requestDirection,
  }) = FriendSearchResult;

  /// Status check result state
  const factory FriendState.statusResult({
    required FriendshipStatusResult status,
  }) = FriendStatusResult;

  /// Error state
  const factory FriendState.error({
    required String message,
  }) = FriendError;

  /// Action success state (for showing success messages)
  const factory FriendState.actionSuccess({
    required String message,
  }) = FriendActionSuccess;
}
