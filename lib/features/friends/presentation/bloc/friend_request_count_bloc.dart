import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/core/domain/repositories/friend_repository.dart';
import 'friend_request_count_event.dart';
import 'friend_request_count_state.dart';

/// BLoC for managing friend request count badge
/// This is a dedicated BLoC that only handles the real-time count of pending friend requests
/// Separated from FriendBloc to avoid state conflicts and enable independent updates
class FriendRequestCountBloc extends Bloc<FriendRequestCountEvent, FriendRequestCountState> {
  final FriendRepository _friendRepository;
  StreamSubscription<int>? _countSubscription;

  FriendRequestCountBloc({
    required FriendRepository friendRepository,
  })  : _friendRepository = friendRepository,
        super(const FriendRequestCountState.initial()) {
    on<FriendRequestCountStartListening>(_onStartListening);
    on<FriendRequestCountStopListening>(_onStopListening);
  }

  Future<void> _onStartListening(
    FriendRequestCountStartListening event,
    Emitter<FriendRequestCountState> emit,
  ) async {
    // Cancel any existing subscription
    await _countSubscription?.cancel();

    try {
      // Use emit.forEach for cleaner stream handling
      // This automatically subscribes and unsubscribes when the event completes
      await emit.forEach<int>(
        _friendRepository.getPendingFriendRequestCount(event.userId),
        onData: (count) => FriendRequestCountState.loaded(count: count),
        onError: (error, stackTrace) {
          return FriendRequestCountState.error(
            message: error is FriendshipException
                ? error.message
                : 'Failed to load friend request count',
          );
        },
      );
    } catch (e) {
      emit(FriendRequestCountState.error(
        message: 'Failed to start listening to friend request count: $e',
      ));
    }
  }

  Future<void> _onStopListening(
    FriendRequestCountStopListening event,
    Emitter<FriendRequestCountState> emit,
  ) async {
    await _countSubscription?.cancel();
    _countSubscription = null;
    emit(const FriendRequestCountState.initial());
  }

  @override
  Future<void> close() {
    _countSubscription?.cancel();
    return super.close();
  }
}
