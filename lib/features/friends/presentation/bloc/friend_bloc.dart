import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/core/domain/entities/friendship_entity.dart';
import 'package:play_with_me/core/domain/repositories/friend_repository.dart';
import 'package:play_with_me/core/utils/error_messages.dart';
import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';
import 'package:play_with_me/features/auth/domain/repositories/auth_repository.dart';
import 'friend_event.dart';
import 'friend_state.dart';

/// BLoC for managing friend relationships and friend requests
class FriendBloc extends Bloc<FriendEvent, FriendState> {
  final FriendRepository _friendRepository;
  final AuthRepository _authRepository;

  FriendBloc({
    required FriendRepository friendRepository,
    required AuthRepository authRepository,
  })  : _friendRepository = friendRepository,
        _authRepository = authRepository,
        super(const FriendState.initial()) {
    on<FriendLoadRequested>(_onLoadRequested);
    on<FriendRequestSent>(_onRequestSent);
    on<FriendRequestAccepted>(_onRequestAccepted);
    on<FriendRequestDeclined>(_onRequestDeclined);
    on<FriendRequestCancelled>(_onRequestCancelled);
    on<FriendRemoved>(_onRemoved);
    on<FriendSearchRequested>(_onSearchRequested);
    on<FriendStatusChecked>(_onStatusChecked);
  }

  Future<void> _onLoadRequested(
    FriendLoadRequested event,
    Emitter<FriendState> emit,
  ) async {
    try {
      emit(const FriendState.loading());

      final currentUser = _authRepository.currentUser;
      if (currentUser == null) {
        emit(const FriendState.error(message: 'User not authenticated'));
        return;
      }

      // Load friends and pending requests in parallel
      final results = await Future.wait([
        _friendRepository.getFriends(currentUser.uid),
        _friendRepository.getPendingRequests(
          type: FriendRequestType.received,
        ),
        _friendRepository.getPendingRequests(
          type: FriendRequestType.sent,
        ),
      ]);

      emit(FriendState.loaded(
        friends: results[0] as List<UserEntity>,
        receivedRequests: results[1] as List<FriendshipEntity>,
        sentRequests: results[2] as List<FriendshipEntity>,
      ));
    } on FriendshipException catch (e) {
      emit(FriendState.error(message: e.message));
    } catch (e) {
      final (message, _) = e is Exception
          ? ErrorMessages.getErrorMessage(e)
          : ('Failed to load friends', true);
      emit(FriendState.error(message: message));
    }
  }

  Future<void> _onRequestSent(
    FriendRequestSent event,
    Emitter<FriendState> emit,
  ) async {
    try {
      await _friendRepository.sendFriendRequest(event.targetUserId);
      emit(const FriendState.actionSuccess(
        message: 'Friend request sent successfully',
      ));

      // Reload the data to show updated state
      add(const FriendEvent.loadRequested());
    } on FriendshipException catch (e) {
      emit(FriendState.error(message: e.message));
    } catch (e) {
      final (message, _) = e is Exception
          ? ErrorMessages.getErrorMessage(e)
          : ('Failed to send friend request', true);
      emit(FriendState.error(message: message));
    }
  }

  Future<void> _onRequestAccepted(
    FriendRequestAccepted event,
    Emitter<FriendState> emit,
  ) async {
    try {
      await _friendRepository.acceptFriendRequest(event.friendshipId);
      emit(const FriendState.actionSuccess(
        message: 'Friend request accepted',
      ));

      // Reload the data to show updated state
      add(const FriendEvent.loadRequested());
    } on FriendshipException catch (e) {
      emit(FriendState.error(message: e.message));
    } catch (e) {
      final (message, _) = e is Exception
          ? ErrorMessages.getErrorMessage(e)
          : ('Failed to accept friend request', true);
      emit(FriendState.error(message: message));
    }
  }

  Future<void> _onRequestDeclined(
    FriendRequestDeclined event,
    Emitter<FriendState> emit,
  ) async {
    try {
      await _friendRepository.declineFriendRequest(event.friendshipId);
      emit(const FriendState.actionSuccess(
        message: 'Friend request declined',
      ));

      // Reload the data to show updated state
      add(const FriendEvent.loadRequested());
    } on FriendshipException catch (e) {
      emit(FriendState.error(message: e.message));
    } catch (e) {
      final (message, _) = e is Exception
          ? ErrorMessages.getErrorMessage(e)
          : ('Failed to decline friend request', true);
      emit(FriendState.error(message: message));
    }
  }

  Future<void> _onRequestCancelled(
    FriendRequestCancelled event,
    Emitter<FriendState> emit,
  ) async {
    try {
      // Cancelling is the same as declining from the initiator's side
      await _friendRepository.declineFriendRequest(event.friendshipId);
      emit(const FriendState.actionSuccess(
        message: 'Friend request cancelled',
      ));

      // Reload the data to show updated state
      add(const FriendEvent.loadRequested());
    } on FriendshipException catch (e) {
      emit(FriendState.error(message: e.message));
    } catch (e) {
      final (message, _) = e is Exception
          ? ErrorMessages.getErrorMessage(e)
          : ('Failed to cancel friend request', true);
      emit(FriendState.error(message: message));
    }
  }

  Future<void> _onRemoved(
    FriendRemoved event,
    Emitter<FriendState> emit,
  ) async {
    try {
      await _friendRepository.removeFriend(event.friendshipId);
      emit(const FriendState.actionSuccess(
        message: 'Friend removed',
      ));

      // Reload the data to show updated state
      add(const FriendEvent.loadRequested());
    } on FriendshipException catch (e) {
      emit(FriendState.error(message: e.message));
    } catch (e) {
      final (message, _) = e is Exception
          ? ErrorMessages.getErrorMessage(e)
          : ('Failed to remove friend', true);
      emit(FriendState.error(message: message));
    }
  }

  Future<void> _onSearchRequested(
    FriendSearchRequested event,
    Emitter<FriendState> emit,
  ) async {
    try {
      emit(const FriendState.loading());

      // This would require a cloud function to search users by email
      // For now, we'll emit an error indicating this feature needs implementation
      emit(const FriendState.error(
        message: 'User search not yet implemented',
      ));
    } on FriendshipException catch (e) {
      emit(FriendState.error(message: e.message));
    } catch (e) {
      final (message, _) = e is Exception
          ? ErrorMessages.getErrorMessage(e)
          : ('Failed to search for user', true);
      emit(FriendState.error(message: message));
    }
  }

  Future<void> _onStatusChecked(
    FriendStatusChecked event,
    Emitter<FriendState> emit,
  ) async {
    try {
      emit(const FriendState.loading());

      final status = await _friendRepository.checkFriendshipStatus(
        event.userId,
      );

      emit(FriendState.statusResult(status: status));
    } on FriendshipException catch (e) {
      emit(FriendState.error(message: e.message));
    } catch (e) {
      final (message, _) = e is Exception
          ? ErrorMessages.getErrorMessage(e)
          : ('Failed to check friendship status', true);
      emit(FriendState.error(message: message));
    }
  }
}
