import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/data/models/rating_history_entry.dart';
import 'package:play_with_me/core/data/models/user_model.dart';
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
  });
}