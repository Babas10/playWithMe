// Tests for FriendBloc to verify friend management functionality
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/domain/entities/friendship_entity.dart';
import 'package:play_with_me/core/domain/entities/friendship_status_result.dart';
import 'package:play_with_me/core/domain/repositories/friend_repository.dart';
import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';
import 'package:play_with_me/features/auth/domain/repositories/auth_repository.dart';
import 'package:play_with_me/features/friends/presentation/bloc/friend_bloc.dart';
import 'package:play_with_me/features/friends/presentation/bloc/friend_event.dart';
import 'package:play_with_me/features/friends/presentation/bloc/friend_state.dart';

class MockFriendRepository extends Mock implements FriendRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late FriendBloc friendBloc;
  late MockFriendRepository mockFriendRepository;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockFriendRepository = MockFriendRepository();
    mockAuthRepository = MockAuthRepository();
    friendBloc = FriendBloc(
      friendRepository: mockFriendRepository,
      authRepository: mockAuthRepository,
    );
  });

  tearDown(() {
    friendBloc.close();
  });

  group('FriendBloc', () {
    final testUser = UserEntity(
      uid: 'test-user-id',
      email: 'test@example.com',
      displayName: 'Test User',
      isEmailVerified: true,
      isAnonymous: false,
    );

    final testFriend = UserEntity(
      uid: 'friend-user-id',
      email: 'friend@example.com',
      displayName: 'Friend User',
      isEmailVerified: true,
      isAnonymous: false,
    );

    final testReceivedRequest = FriendshipEntity(
      id: 'friendship-1',
      initiatorId: 'friend-user-id',
      recipientId: 'test-user-id',
      initiatorName: 'Friend User',
      recipientName: 'Test User',
      status: FriendshipStatus.pending,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final testSentRequest = FriendshipEntity(
      id: 'friendship-2',
      initiatorId: 'test-user-id',
      recipientId: 'other-user-id',
      initiatorName: 'Test User',
      recipientName: 'Other User',
      status: FriendshipStatus.pending,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    test('initial state is FriendInitial', () {
      expect(friendBloc.state, equals(const FriendState.initial()));
    });

    group('FriendLoadRequested', () {
      blocTest<FriendBloc, FriendState>(
        'emits [loading, loaded] when data loads successfully',
        build: () {
          when(() => mockAuthRepository.currentUser).thenReturn(testUser);
          when(() => mockFriendRepository.getFriends(any()))
              .thenAnswer((_) async => [testFriend]);
          when(() => mockFriendRepository.getPendingRequests(
                type: FriendRequestType.received,
              )).thenAnswer((_) async => [testReceivedRequest]);
          when(() => mockFriendRepository.getPendingRequests(
                type: FriendRequestType.sent,
              )).thenAnswer((_) async => [testSentRequest]);
          return friendBloc;
        },
        act: (bloc) => bloc.add(const FriendEvent.loadRequested()),
        expect: () => [
          const FriendState.loading(),
          FriendState.loaded(
            friends: [testFriend],
            receivedRequests: [testReceivedRequest],
            sentRequests: [testSentRequest],
          ),
        ],
        verify: (_) {
          verify(() => mockAuthRepository.currentUser).called(1);
          verify(() => mockFriendRepository.getFriends(testUser.uid)).called(1);
          verify(() => mockFriendRepository.getPendingRequests(
                type: FriendRequestType.received,
              )).called(1);
          verify(() => mockFriendRepository.getPendingRequests(
                type: FriendRequestType.sent,
              )).called(1);
        },
      );

      blocTest<FriendBloc, FriendState>(
        'emits [loading, error] when user is not authenticated',
        build: () {
          when(() => mockAuthRepository.currentUser).thenReturn(null);
          return friendBloc;
        },
        act: (bloc) => bloc.add(const FriendEvent.loadRequested()),
        expect: () => [
          const FriendState.loading(),
          const FriendState.error(message: 'User not authenticated'),
        ],
      );

      blocTest<FriendBloc, FriendState>(
        'emits [loading, loaded] with empty lists when repository throws FriendshipException',
        build: () {
          when(() => mockAuthRepository.currentUser).thenReturn(testUser);
          when(() => mockFriendRepository.getFriends(any()))
              .thenThrow(FriendshipException('Failed to load friends'));
          return friendBloc;
        },
        act: (bloc) => bloc.add(const FriendEvent.loadRequested()),
        expect: () => [
          const FriendState.loading(),
          const FriendState.loaded(
            friends: [],
            receivedRequests: [],
            sentRequests: [],
          ),
        ],
      );
    });

    group('FriendRequestSent', () {
      blocTest<FriendBloc, FriendState>(
        'emits [actionSuccess, loading, loaded] when request sent successfully',
        build: () {
          when(() => mockFriendRepository.sendFriendRequest(any()))
              .thenAnswer((_) async => 'friendship-id');
          when(() => mockAuthRepository.currentUser).thenReturn(testUser);
          when(() => mockFriendRepository.getFriends(any()))
              .thenAnswer((_) async => []);
          when(() => mockFriendRepository.getPendingRequests(
                type: FriendRequestType.received,
              )).thenAnswer((_) async => []);
          when(() => mockFriendRepository.getPendingRequests(
                type: FriendRequestType.sent,
              )).thenAnswer((_) async => [testSentRequest]);
          return friendBloc;
        },
        act: (bloc) => bloc.add(
          const FriendEvent.requestSent(targetUserId: 'target-user-id'),
        ),
        expect: () => [
          const FriendState.actionSuccess(
            message: 'Friend request sent successfully',
          ),
          const FriendState.loading(),
          FriendState.loaded(
            friends: [],
            receivedRequests: [],
            sentRequests: [testSentRequest],
          ),
        ],
        verify: (_) {
          verify(() => mockFriendRepository.sendFriendRequest('target-user-id'))
              .called(1);
        },
      );

      blocTest<FriendBloc, FriendState>(
        'emits [error] when repository throws exception',
        build: () {
          when(() => mockFriendRepository.sendFriendRequest(any()))
              .thenThrow(FriendshipException('User not found'));
          return friendBloc;
        },
        act: (bloc) => bloc.add(
          const FriendEvent.requestSent(targetUserId: 'target-user-id'),
        ),
        expect: () => [
          const FriendState.error(message: 'User not found'),
        ],
      );
    });

    group('FriendRequestAccepted', () {
      blocTest<FriendBloc, FriendState>(
        'emits [actionSuccess, loading, loaded] when request accepted successfully',
        build: () {
          when(() => mockFriendRepository.acceptFriendRequest(any()))
              .thenAnswer((_) async {});
          when(() => mockAuthRepository.currentUser).thenReturn(testUser);
          when(() => mockFriendRepository.getFriends(any()))
              .thenAnswer((_) async => [testFriend]);
          when(() => mockFriendRepository.getPendingRequests(
                type: FriendRequestType.received,
              )).thenAnswer((_) async => []);
          when(() => mockFriendRepository.getPendingRequests(
                type: FriendRequestType.sent,
              )).thenAnswer((_) async => []);
          return friendBloc;
        },
        act: (bloc) => bloc.add(
          const FriendEvent.requestAccepted(friendshipId: 'friendship-1'),
        ),
        expect: () => [
          const FriendState.actionSuccess(message: 'Friend request accepted'),
          const FriendState.loading(),
          FriendState.loaded(
            friends: [testFriend],
            receivedRequests: [],
            sentRequests: [],
          ),
        ],
        verify: (_) {
          verify(() => mockFriendRepository.acceptFriendRequest('friendship-1'))
              .called(1);
        },
      );
    });

    group('FriendRequestDeclined', () {
      blocTest<FriendBloc, FriendState>(
        'emits [actionSuccess, loading, loaded] when request declined successfully',
        build: () {
          when(() => mockFriendRepository.declineFriendRequest(any()))
              .thenAnswer((_) async {});
          when(() => mockAuthRepository.currentUser).thenReturn(testUser);
          when(() => mockFriendRepository.getFriends(any()))
              .thenAnswer((_) async => []);
          when(() => mockFriendRepository.getPendingRequests(
                type: FriendRequestType.received,
              )).thenAnswer((_) async => []);
          when(() => mockFriendRepository.getPendingRequests(
                type: FriendRequestType.sent,
              )).thenAnswer((_) async => []);
          return friendBloc;
        },
        act: (bloc) => bloc.add(
          const FriendEvent.requestDeclined(friendshipId: 'friendship-1'),
        ),
        expect: () => [
          const FriendState.actionSuccess(message: 'Friend request declined'),
          const FriendState.loading(),
          const FriendState.loaded(
            friends: [],
            receivedRequests: [],
            sentRequests: [],
          ),
        ],
        verify: (_) {
          verify(() => mockFriendRepository.declineFriendRequest('friendship-1'))
              .called(1);
        },
      );
    });

    group('FriendRequestCancelled', () {
      blocTest<FriendBloc, FriendState>(
        'emits [actionSuccess, loading, loaded] when request cancelled successfully',
        build: () {
          when(() => mockFriendRepository.declineFriendRequest(any()))
              .thenAnswer((_) async {});
          when(() => mockAuthRepository.currentUser).thenReturn(testUser);
          when(() => mockFriendRepository.getFriends(any()))
              .thenAnswer((_) async => []);
          when(() => mockFriendRepository.getPendingRequests(
                type: FriendRequestType.received,
              )).thenAnswer((_) async => []);
          when(() => mockFriendRepository.getPendingRequests(
                type: FriendRequestType.sent,
              )).thenAnswer((_) async => []);
          return friendBloc;
        },
        act: (bloc) => bloc.add(
          const FriendEvent.requestCancelled(friendshipId: 'friendship-2'),
        ),
        expect: () => [
          const FriendState.actionSuccess(message: 'Friend request cancelled'),
          const FriendState.loading(),
          const FriendState.loaded(
            friends: [],
            receivedRequests: [],
            sentRequests: [],
          ),
        ],
        verify: (_) {
          verify(() => mockFriendRepository.declineFriendRequest('friendship-2'))
              .called(1);
        },
      );
    });

    group('FriendRemoved', () {
      blocTest<FriendBloc, FriendState>(
        'emits [actionSuccess, loading, loaded] when friend removed successfully',
        build: () {
          when(() => mockFriendRepository.removeFriend(any()))
              .thenAnswer((_) async {});
          when(() => mockAuthRepository.currentUser).thenReturn(testUser);
          when(() => mockFriendRepository.getFriends(any()))
              .thenAnswer((_) async => []);
          when(() => mockFriendRepository.getPendingRequests(
                type: FriendRequestType.received,
              )).thenAnswer((_) async => []);
          when(() => mockFriendRepository.getPendingRequests(
                type: FriendRequestType.sent,
              )).thenAnswer((_) async => []);
          return friendBloc;
        },
        act: (bloc) => bloc.add(
          const FriendEvent.removed(friendshipId: 'friendship-1'),
        ),
        expect: () => [
          const FriendState.actionSuccess(message: 'Friend removed'),
          const FriendState.loading(),
          const FriendState.loaded(
            friends: [],
            receivedRequests: [],
            sentRequests: [],
          ),
        ],
        verify: (_) {
          verify(() => mockFriendRepository.removeFriend('friendship-1'))
              .called(1);
        },
      );
    });

    group('FriendStatusChecked', () {
      blocTest<FriendBloc, FriendState>(
        'emits [loading, statusResult] when status checked successfully',
        build: () {
          when(() => mockFriendRepository.checkFriendshipStatus(any()))
              .thenAnswer(
            (_) async => const FriendshipStatusResult(
              isFriend: true,
              hasPendingRequest: false,
            ),
          );
          return friendBloc;
        },
        act: (bloc) => bloc.add(
          const FriendEvent.statusChecked(userId: 'user-id'),
        ),
        expect: () => [
          const FriendState.loading(),
          const FriendState.statusResult(
            status: FriendshipStatusResult(
              isFriend: true,
              hasPendingRequest: false,
            ),
          ),
        ],
        verify: (_) {
          verify(() => mockFriendRepository.checkFriendshipStatus('user-id'))
              .called(1);
        },
      );
    });

    group('FriendSearchRequested', () {
      blocTest<FriendBloc, FriendState>(
        'emits [loading, error] as search is not yet implemented',
        build: () => friendBloc,
        act: (bloc) => bloc.add(
          const FriendEvent.searchRequested(email: 'test@example.com'),
        ),
        expect: () => [
          const FriendState.loading(),
          const FriendState.error(message: 'User search not yet implemented'),
        ],
      );
    });
  });
}
