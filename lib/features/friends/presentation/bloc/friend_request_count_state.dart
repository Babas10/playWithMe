import 'package:freezed_annotation/freezed_annotation.dart';

part 'friend_request_count_state.freezed.dart';

/// States for the FriendRequestCountBloc
/// This BLoC manages only the badge count for friend requests
@freezed
class FriendRequestCountState with _$FriendRequestCountState {
  /// Initial state - count not yet loaded
  const factory FriendRequestCountState.initial() = FriendRequestCountInitial;

  /// Count loaded - shows the current number of pending friend requests
  const factory FriendRequestCountState.loaded({
    required int count,
  }) = FriendRequestCountLoaded;

  /// Error state - failed to load count
  const factory FriendRequestCountState.error({
    required String message,
  }) = FriendRequestCountError;
}
