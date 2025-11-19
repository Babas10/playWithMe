import 'package:freezed_annotation/freezed_annotation.dart';

part 'friend_request_count_event.freezed.dart';

/// Events for the FriendRequestCountBloc
@freezed
class FriendRequestCountEvent with _$FriendRequestCountEvent {
  /// Start listening to friend request count updates
  const factory FriendRequestCountEvent.startListening({
    required String userId,
  }) = FriendRequestCountStartListening;

  /// Stop listening to friend request count updates
  const factory FriendRequestCountEvent.stopListening() = FriendRequestCountStopListening;
}
