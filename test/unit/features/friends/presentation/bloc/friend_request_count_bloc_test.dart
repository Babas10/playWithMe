// Validates FriendRequestCountBloc emits correct states for friend request count streaming
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/domain/repositories/friend_repository.dart';
import 'package:play_with_me/features/friends/presentation/bloc/friend_request_count_bloc.dart';
import 'package:play_with_me/features/friends/presentation/bloc/friend_request_count_event.dart';
import 'package:play_with_me/features/friends/presentation/bloc/friend_request_count_state.dart';

class MockFriendRepository extends Mock implements FriendRepository {}

void main() {
  late MockFriendRepository mockFriendRepository;
  late FriendRequestCountBloc friendRequestCountBloc;

  setUp(() {
    mockFriendRepository = MockFriendRepository();
    friendRequestCountBloc = FriendRequestCountBloc(
      friendRepository: mockFriendRepository,
    );
  });

  tearDown(() {
    friendRequestCountBloc.close();
  });

  group('FriendRequestCountBloc', () {
    test('initial state is FriendRequestCountInitial', () {
      expect(
        friendRequestCountBloc.state,
        equals(const FriendRequestCountState.initial()),
      );
    });

    group('FriendRequestCountStartListening', () {
      blocTest<FriendRequestCountBloc, FriendRequestCountState>(
        'emits [loaded] states when count stream updates',
        build: () {
          when(() => mockFriendRepository.getPendingFriendRequestCount('test-user-id'))
              .thenAnswer((_) => Stream.fromIterable([0, 1, 2, 3]));
          return friendRequestCountBloc;
        },
        act: (bloc) => bloc.add(
          const FriendRequestCountEvent.startListening(userId: 'test-user-id'),
        ),
        expect: () => [
          const FriendRequestCountState.loaded(count: 0),
          const FriendRequestCountState.loaded(count: 1),
          const FriendRequestCountState.loaded(count: 2),
          const FriendRequestCountState.loaded(count: 3),
        ],
        verify: (_) {
          verify(() =>
                  mockFriendRepository.getPendingFriendRequestCount('test-user-id'))
              .called(1);
        },
      );

      blocTest<FriendRequestCountBloc, FriendRequestCountState>(
        'emits [loaded] with zero when no pending requests',
        build: () {
          when(() => mockFriendRepository.getPendingFriendRequestCount('test-user-id'))
              .thenAnswer((_) => Stream.value(0));
          return friendRequestCountBloc;
        },
        act: (bloc) => bloc.add(
          const FriendRequestCountEvent.startListening(userId: 'test-user-id'),
        ),
        expect: () => [
          const FriendRequestCountState.loaded(count: 0),
        ],
      );

      blocTest<FriendRequestCountBloc, FriendRequestCountState>(
        'emits [error] when repository throws FriendshipException',
        build: () {
          when(() => mockFriendRepository.getPendingFriendRequestCount('test-user-id'))
              .thenAnswer(
            (_) => Stream.error(
              FriendshipException('Permission denied', code: 'permission-denied'),
            ),
          );
          return friendRequestCountBloc;
        },
        act: (bloc) => bloc.add(
          const FriendRequestCountEvent.startListening(userId: 'test-user-id'),
        ),
        expect: () => [
          const FriendRequestCountState.error(message: 'Permission denied'),
        ],
      );

      blocTest<FriendRequestCountBloc, FriendRequestCountState>(
        'emits [error] when repository throws generic exception',
        build: () {
          when(() => mockFriendRepository.getPendingFriendRequestCount('test-user-id'))
              .thenAnswer(
            (_) => Stream.error(Exception('Network error')),
          );
          return friendRequestCountBloc;
        },
        act: (bloc) => bloc.add(
          const FriendRequestCountEvent.startListening(userId: 'test-user-id'),
        ),
        expect: () => [
          const FriendRequestCountState.error(
            message: 'Failed to load friend request count',
          ),
        ],
      );

      blocTest<FriendRequestCountBloc, FriendRequestCountState>(
        'handles stream that emits count then error',
        build: () {
          // Create a stream controller to emit values then error
          when(() => mockFriendRepository.getPendingFriendRequestCount('test-user-id'))
              .thenAnswer((_) async* {
            yield 1;
            yield 2;
            throw FriendshipException('Connection lost');
          });
          return friendRequestCountBloc;
        },
        act: (bloc) => bloc.add(
          const FriendRequestCountEvent.startListening(userId: 'test-user-id'),
        ),
        expect: () => [
          const FriendRequestCountState.loaded(count: 1),
          const FriendRequestCountState.loaded(count: 2),
          const FriendRequestCountState.error(message: 'Connection lost'),
        ],
      );
    });

    group('FriendRequestCountStopListening', () {
      blocTest<FriendRequestCountBloc, FriendRequestCountState>(
        'emits [initial] when stop listening event is triggered',
        build: () => friendRequestCountBloc,
        act: (bloc) => bloc.add(
          const FriendRequestCountEvent.stopListening(),
        ),
        expect: () => [
          const FriendRequestCountState.initial(),
        ],
      );
    });
  });
}
