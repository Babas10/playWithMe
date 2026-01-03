import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/data/models/rating_history_entry.dart';
import 'package:play_with_me/core/data/models/user_model.dart';
import 'package:play_with_me/core/data/models/user_ranking.dart';
import 'package:play_with_me/core/domain/repositories/user_repository.dart';
import 'package:play_with_me/features/profile/presentation/bloc/player_stats/player_stats_bloc.dart';
import 'package:play_with_me/features/profile/presentation/bloc/player_stats/player_stats_event.dart';
import 'package:play_with_me/features/profile/presentation/bloc/player_stats/player_stats_state.dart';

class MockUserRepository extends Mock implements UserRepository {}

class FakeUserModel extends Fake implements UserModel {}

void main() {
  late MockUserRepository mockUserRepository;
  late PlayerStatsBloc playerStatsBloc;

  const userId = 'user-123';
  final testUser = UserModel(
    uid: userId,
    email: 'test@example.com',
    isEmailVerified: true,
    isAnonymous: false,
    eloRating: 1650,
    gamesPlayed: 10,
  );

  final testHistory = [
    RatingHistoryEntry(
      entryId: 'entry-1',
      gameId: 'game-1',
      oldRating: 1600,
      newRating: 1625,
      ratingChange: 25,
      opponentTeam: 'Opponents',
      won: true,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    )
  ];

  setUp(() {
    mockUserRepository = MockUserRepository();
    playerStatsBloc = PlayerStatsBloc(userRepository: mockUserRepository);
    registerFallbackValue(FakeUserModel());
  });

  tearDown(() {
    playerStatsBloc.close();
  });

  group('PlayerStatsBloc', () {
    test('initial state is PlayerStatsInitial', () {
      expect(playerStatsBloc.state, PlayerStatsInitial());
    });

    blocTest<PlayerStatsBloc, PlayerStatsState>(
      'emits [PlayerStatsLoading, PlayerStatsLoaded] when LoadPlayerStats is added',
      setUp: () {
        when(() => mockUserRepository.getUserStream(userId))
            .thenAnswer((_) => Stream.value(testUser));
        when(() => mockUserRepository.getRatingHistory(userId))
            .thenAnswer((_) => Stream.value(testHistory));
      },
      build: () => playerStatsBloc,
      act: (bloc) => bloc.add(const LoadPlayerStats(userId)),
      expect: () => [
        PlayerStatsLoading(),
        PlayerStatsLoaded(user: testUser, history: testHistory),
      ],
    );

    blocTest<PlayerStatsBloc, PlayerStatsState>(
      'updates state when user stream emits new data',
      setUp: () {
        when(() => mockUserRepository.getUserStream(userId))
            .thenAnswer((_) => Stream.fromIterable([testUser, testUser.copyWith(gamesPlayed: 11)]));
        when(() => mockUserRepository.getRatingHistory(userId))
            .thenAnswer((_) => Stream.value(testHistory));
      },
      build: () => playerStatsBloc,
      act: (bloc) => bloc.add(const LoadPlayerStats(userId)),
      expect: () => [
        PlayerStatsLoading(),
        PlayerStatsLoaded(user: testUser, history: testHistory),
        PlayerStatsLoaded(user: testUser.copyWith(gamesPlayed: 11), history: testHistory),
      ],
    );

    blocTest<PlayerStatsBloc, PlayerStatsState>(
      'refreshes history if gamesPlayed increases',
      setUp: () {
        final updatedUser = testUser.copyWith(gamesPlayed: 11);
        when(() => mockUserRepository.getUserStream(userId))
            .thenAnswer((_) => Stream.fromIterable([testUser, updatedUser]));
        
        // Return initial history first, then updated history
        int callCount = 0;
        when(() => mockUserRepository.getRatingHistory(userId)).thenAnswer((_) {
          callCount++;
          if (callCount == 1) return Stream.value(testHistory);
          return Stream.value([...testHistory, testHistory.first.copyWith(entryId: 'entry-2')]);
        });
      },
      build: () => playerStatsBloc,
      act: (bloc) => bloc.add(const LoadPlayerStats(userId)),
      verify: (_) {
        verify(() => mockUserRepository.getRatingHistory(userId)).called(2);
      },
    );

    // Story 302.5: LoadRanking event tests
    group('LoadRanking', () {
      final testRanking = UserRanking(
        globalRank: 42,
        totalUsers: 1500,
        percentile: 97.2,
        friendsRank: 3,
        totalFriends: 15,
        calculatedAt: DateTime(2024, 1, 1),
      );

      blocTest<PlayerStatsBloc, PlayerStatsState>(
        'loads ranking when state is PlayerStatsLoaded',
        setUp: () {
          when(() => mockUserRepository.getUserRanking(userId))
              .thenAnswer((_) async => testRanking);
        },
        build: () => playerStatsBloc,
        seed: () => PlayerStatsLoaded(user: testUser, history: testHistory),
        act: (bloc) => bloc.add(const LoadRanking(userId)),
        expect: () => [
          PlayerStatsLoaded(
            user: testUser,
            history: testHistory,
            ranking: testRanking,
          ),
        ],
      );

      blocTest<PlayerStatsBloc, PlayerStatsState>(
        'does nothing when state is not PlayerStatsLoaded',
        setUp: () {
          when(() => mockUserRepository.getUserRanking(userId))
              .thenAnswer((_) async => testRanking);
        },
        build: () => playerStatsBloc,
        seed: () => PlayerStatsInitial(),
        act: (bloc) => bloc.add(const LoadRanking(userId)),
        expect: () => [],
        verify: (_) {
          verifyNever(() => mockUserRepository.getUserRanking(userId));
        },
      );

      blocTest<PlayerStatsBloc, PlayerStatsState>(
        'preserves user and history when loading ranking',
        setUp: () {
          when(() => mockUserRepository.getUserRanking(userId))
              .thenAnswer((_) async => testRanking);
        },
        build: () => playerStatsBloc,
        seed: () => PlayerStatsLoaded(user: testUser, history: testHistory),
        act: (bloc) => bloc.add(const LoadRanking(userId)),
        verify: (bloc) {
          final state = bloc.state as PlayerStatsLoaded;
          expect(state.user, testUser);
          expect(state.history, testHistory);
          expect(state.ranking, testRanking);
        },
      );

      blocTest<PlayerStatsBloc, PlayerStatsState>(
        'does not emit error when ranking fetch fails',
        setUp: () {
          when(() => mockUserRepository.getUserRanking(userId))
              .thenThrow(Exception('Network error'));
        },
        build: () => playerStatsBloc,
        seed: () => PlayerStatsLoaded(user: testUser, history: testHistory),
        act: (bloc) => bloc.add(const LoadRanking(userId)),
        expect: () => [],
        verify: (_) {
          // State should remain unchanged
          verify(() => mockUserRepository.getUserRanking(userId)).called(1);
        },
      );
    });

    group('UpdateUserStats with ranking', () {
      final testRanking = UserRanking(
        globalRank: 42,
        totalUsers: 1500,
        percentile: 97.2,
        calculatedAt: DateTime(2024, 1, 1),
      );

      blocTest<PlayerStatsBloc, PlayerStatsState>(
        'preserves ranking when updating user stats',
        setUp: () {
          when(() => mockUserRepository.getRatingHistory(userId))
              .thenAnswer((_) => Stream.value(testHistory));
        },
        build: () => playerStatsBloc,
        seed: () => PlayerStatsLoaded(
          user: testUser,
          history: testHistory,
          ranking: testRanking,
        ),
        act: (bloc) => bloc.add(UpdateUserStats(testUser.copyWith(gamesPlayed: 11))),
        verify: (bloc) {
          final state = bloc.state as PlayerStatsLoaded;
          expect(state.ranking, testRanking,
              reason: 'Ranking should be preserved when user updates');
        },
      );
    });
  });
}