// Tests for HeadToHeadBloc
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/domain/repositories/user_repository.dart';
import 'package:play_with_me/core/data/models/head_to_head_stats.dart';
import 'package:play_with_me/core/data/models/user_model.dart';
import 'package:play_with_me/features/profile/presentation/bloc/head_to_head/head_to_head_bloc.dart';
import 'package:play_with_me/features/profile/presentation/bloc/head_to_head/head_to_head_event.dart';
import 'package:play_with_me/features/profile/presentation/bloc/head_to_head/head_to_head_state.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockUserRepository mockUserRepository;

  setUp(() {
    mockUserRepository = MockUserRepository();
  });

  group('HeadToHeadBloc', () {
    test('initial state is HeadToHeadInitial', () {
      final bloc = HeadToHeadBloc(userRepository: mockUserRepository);
      expect(bloc.state, const HeadToHeadState.initial());
      bloc.close();
    });

    blocTest<HeadToHeadBloc, HeadToHeadState>(
      'emits [loading, loaded] when stats and opponent profile are found',
      build: () {
        final testStats = HeadToHeadStats(
          userId: 'user-123',
          opponentId: 'opponent-123',
          gamesPlayed: 8,
          gamesWon: 5,
          gamesLost: 3,
          pointsScored: 168,
          pointsAllowed: 152,
          eloChange: 32.0,
          recentMatchups: [],
        );

        final testOpponent = UserModel(
          uid: 'opponent-123',
          email: 'opponent@example.com',
          displayName: 'Opponent User',
          isEmailVerified: true,
          isAnonymous: false,
        );

        when(() => mockUserRepository.getHeadToHeadStats('user-123', 'opponent-123'))
            .thenAnswer((_) async => testStats);
        when(() => mockUserRepository.getUserById('opponent-123'))
            .thenAnswer((_) async => testOpponent);

        return HeadToHeadBloc(userRepository: mockUserRepository);
      },
      act: (bloc) => bloc.add(const HeadToHeadEvent.loadHeadToHead(
        userId: 'user-123',
        opponentId: 'opponent-123',
      )),
      expect: () => [
        const HeadToHeadState.loading(),
        isA<HeadToHeadLoaded>()
            .having((s) => s.stats.opponentId, 'opponent id', 'opponent-123')
            .having((s) => s.stats.gamesPlayed, 'games played', 8)
            .having((s) => s.opponentProfile.uid, 'opponent uid', 'opponent-123'),
      ],
    );

    blocTest<HeadToHeadBloc, HeadToHeadState>(
      'emits [loading, error] when stats are not found',
      build: () {
        when(() => mockUserRepository.getHeadToHeadStats('user-123', 'opponent-123'))
            .thenAnswer((_) async => null);
        when(() => mockUserRepository.getUserById('opponent-123'))
            .thenAnswer((_) async => UserModel(
                  uid: 'opponent-123',
                  email: 'opponent@example.com',
                  isEmailVerified: true,
                  isAnonymous: false,
                ));

        return HeadToHeadBloc(userRepository: mockUserRepository);
      },
      act: (bloc) => bloc.add(const HeadToHeadEvent.loadHeadToHead(
        userId: 'user-123',
        opponentId: 'opponent-123',
      )),
      expect: () => [
        const HeadToHeadState.loading(),
        const HeadToHeadState.error(
          message: 'No head-to-head statistics found for this opponent',
        ),
      ],
    );

    blocTest<HeadToHeadBloc, HeadToHeadState>(
      'emits [loading, error] when opponent profile is not found',
      build: () {
        when(() => mockUserRepository.getHeadToHeadStats('user-123', 'opponent-123'))
            .thenAnswer((_) async => HeadToHeadStats(
                  userId: 'user-123',
                  opponentId: 'opponent-123',
                  gamesPlayed: 5,
                  gamesWon: 3,
                  gamesLost: 2,
                ));
        when(() => mockUserRepository.getUserById('opponent-123'))
            .thenAnswer((_) async => null);

        return HeadToHeadBloc(userRepository: mockUserRepository);
      },
      act: (bloc) => bloc.add(const HeadToHeadEvent.loadHeadToHead(
        userId: 'user-123',
        opponentId: 'opponent-123',
      )),
      expect: () => [
        const HeadToHeadState.loading(),
        const HeadToHeadState.error(
          message: 'Opponent profile not found',
        ),
      ],
    );
  });
}
