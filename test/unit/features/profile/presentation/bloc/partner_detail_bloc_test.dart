// Tests for PartnerDetailBloc
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/domain/repositories/user_repository.dart';
import 'package:play_with_me/core/data/models/teammate_stats.dart';
import 'package:play_with_me/core/data/models/user_model.dart';
import 'package:play_with_me/features/profile/presentation/bloc/partner_detail/partner_detail_bloc.dart';
import 'package:play_with_me/features/profile/presentation/bloc/partner_detail/partner_detail_event.dart';
import 'package:play_with_me/features/profile/presentation/bloc/partner_detail/partner_detail_state.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockUserRepository mockUserRepository;

  setUp(() {
    mockUserRepository = MockUserRepository();
  });

  group('PartnerDetailBloc', () {
    test('initial state is PartnerDetailInitial', () {
      final bloc = PartnerDetailBloc(userRepository: mockUserRepository);
      expect(bloc.state, const PartnerDetailState.initial());
      bloc.close();
    });

    blocTest<PartnerDetailBloc, PartnerDetailState>(
      'emits [loading, loaded] when stats and partner profile are found',
      build: () {
        final testStats = TeammateStats(
          userId: 'partner-123',
          gamesPlayed: 10,
          gamesWon: 7,
          gamesLost: 3,
          pointsScored: 210,
          pointsAllowed: 180,
          eloChange: 45.0,
          recentGames: [],
        );

        final testPartner = UserModel(
          uid: 'partner-123',
          email: 'partner@example.com',
          displayName: 'Partner User',
          isEmailVerified: true,
          isAnonymous: false,
        );

        when(() => mockUserRepository.getTeammateStats('user-123', 'partner-123'))
            .thenAnswer((_) async => testStats);
        when(() => mockUserRepository.getUserById('partner-123'))
            .thenAnswer((_) async => testPartner);

        return PartnerDetailBloc(userRepository: mockUserRepository);
      },
      act: (bloc) => bloc.add(const PartnerDetailEvent.loadPartnerDetails(
        userId: 'user-123',
        partnerId: 'partner-123',
      )),
      expect: () => [
        const PartnerDetailState.loading(),
        isA<PartnerDetailLoaded>()
            .having((s) => s.stats.userId, 'stats userId', 'partner-123')
            .having((s) => s.stats.gamesPlayed, 'games played', 10)
            .having((s) => s.partnerProfile.uid, 'partner uid', 'partner-123'),
      ],
    );

    blocTest<PartnerDetailBloc, PartnerDetailState>(
      'emits [loading, error] when stats are not found',
      build: () {
        when(() => mockUserRepository.getTeammateStats('user-123', 'partner-123'))
            .thenAnswer((_) async => null);
        when(() => mockUserRepository.getUserById('partner-123'))
            .thenAnswer((_) async => UserModel(
                  uid: 'partner-123',
                  email: 'partner@example.com',
                  isEmailVerified: true,
                  isAnonymous: false,
                ));

        return PartnerDetailBloc(userRepository: mockUserRepository);
      },
      act: (bloc) => bloc.add(const PartnerDetailEvent.loadPartnerDetails(
        userId: 'user-123',
        partnerId: 'partner-123',
      )),
      expect: () => [
        const PartnerDetailState.loading(),
        const PartnerDetailState.error(
          message: 'No statistics found for this partner',
        ),
      ],
    );

    blocTest<PartnerDetailBloc, PartnerDetailState>(
      'emits [loading, error] when partner profile is not found',
      build: () {
        when(() => mockUserRepository.getTeammateStats('user-123', 'partner-123'))
            .thenAnswer((_) async => TeammateStats(
                  userId: 'partner-123',
                  gamesPlayed: 10,
                  gamesWon: 7,
                  gamesLost: 3,
                ));
        when(() => mockUserRepository.getUserById('partner-123'))
            .thenAnswer((_) async => null);

        return PartnerDetailBloc(userRepository: mockUserRepository);
      },
      act: (bloc) => bloc.add(const PartnerDetailEvent.loadPartnerDetails(
        userId: 'user-123',
        partnerId: 'partner-123',
      )),
      expect: () => [
        const PartnerDetailState.loading(),
        const PartnerDetailState.error(
          message: 'Partner profile not found',
        ),
      ],
    );

    blocTest<PartnerDetailBloc, PartnerDetailState>(
      'emits [loading, error] when repository throws exception',
      build: () {
        when(() => mockUserRepository.getTeammateStats('user-123', 'partner-123'))
            .thenThrow(Exception('Network error'));

        return PartnerDetailBloc(userRepository: mockUserRepository);
      },
      act: (bloc) => bloc.add(const PartnerDetailEvent.loadPartnerDetails(
        userId: 'user-123',
        partnerId: 'partner-123',
      )),
      expect: () => [
        const PartnerDetailState.loading(),
        isA<PartnerDetailError>()
            .having((s) => s.message, 'error message', contains('Failed to load partner details')),
      ],
    );
  });
}
