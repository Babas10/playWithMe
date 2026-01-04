// Tests for EloHistoryBloc
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/data/models/best_elo_record.dart';
import 'package:play_with_me/core/domain/repositories/user_repository.dart';
import 'package:play_with_me/core/data/models/rating_history_entry.dart';
import 'package:play_with_me/core/domain/entities/time_period.dart';
import 'package:play_with_me/features/profile/presentation/bloc/elo_history/elo_history_bloc.dart';
import 'package:play_with_me/features/profile/presentation/bloc/elo_history/elo_history_event.dart';
import 'package:play_with_me/features/profile/presentation/bloc/elo_history/elo_history_state.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockUserRepository mockUserRepository;

  setUp(() {
    mockUserRepository = MockUserRepository();
  });

  group('EloHistoryBloc', () {
    test('initial state is EloHistoryInitial', () {
      final bloc = EloHistoryBloc(userRepository: mockUserRepository);
      expect(bloc.state, const EloHistoryState.initial());
      bloc.close();
    });

    blocTest<EloHistoryBloc, EloHistoryState>(
      'emits [loading, loaded] when history is successfully loaded',
      build: () {
        final testHistory = [
          RatingHistoryEntry(
            entryId: 'entry-1',
            gameId: 'game-1',
            oldRating: 1600,
            newRating: 1625,
            ratingChange: 25,
            opponentTeam: 'Team A',
            won: true,
            timestamp: DateTime.now(),
          ),
          RatingHistoryEntry(
            entryId: 'entry-2',
            gameId: 'game-2',
            oldRating: 1625,
            newRating: 1610,
            ratingChange: -15,
            opponentTeam: 'Team B',
            won: false,
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ];

        when(() => mockUserRepository.getRatingHistory('user-123', limit: 100))
            .thenAnswer((_) => Stream.value(testHistory));

        return EloHistoryBloc(userRepository: mockUserRepository);
      },
      act: (bloc) => bloc.add(const EloHistoryEvent.loadHistory(
        userId: 'user-123',
        limit: 100,
      )),
      expect: () => [
        const EloHistoryState.loading(),
        isA<EloHistoryLoaded>()
            .having((s) => s.history.length, 'history length', 2)
            .having((s) => s.filteredHistory.length, 'filtered length', 2)
            .having((s) => s.filterStartDate, 'start date', null)
            .having((s) => s.filterEndDate, 'end date', null),
      ],
    );

    blocTest<EloHistoryBloc, EloHistoryState>(
      'applies date filter correctly',
      build: () {
        final now = DateTime.now();
        final testHistory = [
          RatingHistoryEntry(
            entryId: 'entry-1',
            gameId: 'game-1',
            oldRating: 1600,
            newRating: 1625,
            ratingChange: 25,
            opponentTeam: 'Team A',
            won: true,
            timestamp: now,
          ),
          RatingHistoryEntry(
            entryId: 'entry-2',
            gameId: 'game-2',
            oldRating: 1625,
            newRating: 1610,
            ratingChange: -15,
            opponentTeam: 'Team B',
            won: false,
            timestamp: now.subtract(const Duration(days: 10)),
          ),
        ];

        when(() => mockUserRepository.getRatingHistory('user-123', limit: 100))
            .thenAnswer((_) => Stream.value(testHistory));

        return EloHistoryBloc(userRepository: mockUserRepository);
      },
      seed: () {
        final now = DateTime.now();
        return EloHistoryState.loaded(
          history: [
            RatingHistoryEntry(
              entryId: 'entry-1',
              gameId: 'game-1',
              oldRating: 1600,
              newRating: 1625,
              ratingChange: 25,
              opponentTeam: 'Team A',
              won: true,
              timestamp: now,
            ),
            RatingHistoryEntry(
              entryId: 'entry-2',
              gameId: 'game-2',
              oldRating: 1625,
              newRating: 1610,
              ratingChange: -15,
              opponentTeam: 'Team B',
              won: false,
              timestamp: now.subtract(const Duration(days: 10)),
            ),
          ],
          filteredHistory: [],
          filterStartDate: null,
          filterEndDate: null,
        );
      },
      act: (bloc) {
        final now = DateTime.now();
        return bloc.add(EloHistoryEvent.filterByDateRange(
          startDate: now.subtract(const Duration(days: 5)),
          endDate: now,
        ));
      },
      expect: () => [
        isA<EloHistoryLoaded>()
            .having((s) => s.history.length, 'history length', 2)
            .having((s) => s.filteredHistory.length, 'filtered length', 1)
            .having((s) => s.filterStartDate, 'start date', isNotNull)
            .having((s) => s.filterEndDate, 'end date', isNotNull),
      ],
    );

    blocTest<EloHistoryBloc, EloHistoryState>(
      'clears filter correctly',
      build: () {
        return EloHistoryBloc(userRepository: mockUserRepository);
      },
      seed: () {
        final now = DateTime.now();
        final history = [
          RatingHistoryEntry(
            entryId: 'entry-1',
            gameId: 'game-1',
            oldRating: 1600,
            newRating: 1625,
            ratingChange: 25,
            opponentTeam: 'Team A',
            won: true,
            timestamp: now,
          ),
        ];
        return EloHistoryState.loaded(
          history: history,
          filteredHistory: [],
          filterStartDate: now.subtract(const Duration(days: 5)),
          filterEndDate: now,
        );
      },
      act: (bloc) => bloc.add(const EloHistoryEvent.clearFilter()),
      expect: () => [
        isA<EloHistoryLoaded>()
            .having((s) => s.history.length, 'history length', 1)
            .having((s) => s.filteredHistory.length, 'filtered length', 1)
            .having((s) => s.filterStartDate, 'start date', null)
            .having((s) => s.filterEndDate, 'end date', null)
            .having((s) => s.selectedPeriod, 'selected period', TimePeriod.allTime),
      ],
    );

    // Story 302.3: FilterByPeriod tests
    group('FilterByPeriod event (Story 302.3)', () {
      blocTest<EloHistoryBloc, EloHistoryState>(
        'filters history by 30 days period correctly',
        build: () {
          return EloHistoryBloc(userRepository: mockUserRepository);
        },
        seed: () {
          final now = DateTime.now();
          final history = [
            RatingHistoryEntry(
              entryId: 'entry-1',
              gameId: 'game-1',
              oldRating: 1600,
              newRating: 1625,
              ratingChange: 25,
              opponentTeam: 'Team A',
              won: true,
              timestamp: now.subtract(const Duration(days: 10)),
            ),
            RatingHistoryEntry(
              entryId: 'entry-2',
              gameId: 'game-2',
              oldRating: 1625,
              newRating: 1610,
              ratingChange: -15,
              opponentTeam: 'Team B',
              won: false,
              timestamp: now.subtract(const Duration(days: 40)),
            ),
          ];
          return EloHistoryState.loaded(
            history: history,
            filteredHistory: history,
            filterStartDate: null,
            filterEndDate: null,
          );
        },
        act: (bloc) => bloc.add(
          const EloHistoryEvent.filterByPeriod(TimePeriod.thirtyDays),
        ),
        expect: () => [
          isA<EloHistoryLoaded>()
              .having((s) => s.history.length, 'history length', 2)
              .having((s) => s.filteredHistory.length, 'filtered length', 1)
              .having((s) => s.selectedPeriod, 'selected period',
                  TimePeriod.thirtyDays),
        ],
      );

      blocTest<EloHistoryBloc, EloHistoryState>(
        'allTime period shows all entries',
        build: () {
          return EloHistoryBloc(userRepository: mockUserRepository);
        },
        seed: () {
          final now = DateTime.now();
          final history = [
            RatingHistoryEntry(
              entryId: 'entry-1',
              gameId: 'game-1',
              oldRating: 1600,
              newRating: 1625,
              ratingChange: 25,
              opponentTeam: 'Team A',
              won: true,
              timestamp: now.subtract(const Duration(days: 10)),
            ),
            RatingHistoryEntry(
              entryId: 'entry-2',
              gameId: 'game-2',
              oldRating: 1625,
              newRating: 1610,
              ratingChange: -15,
              opponentTeam: 'Team B',
              won: false,
              timestamp: now.subtract(const Duration(days: 400)),
            ),
          ];
          return EloHistoryState.loaded(
            history: history,
            filteredHistory: [],
            filterStartDate: null,
            filterEndDate: null,
          );
        },
        act: (bloc) => bloc.add(
          const EloHistoryEvent.filterByPeriod(TimePeriod.allTime),
        ),
        expect: () => [
          isA<EloHistoryLoaded>()
              .having((s) => s.history.length, 'history length', 2)
              .having((s) => s.filteredHistory.length, 'filtered length', 2)
              .having((s) => s.selectedPeriod, 'selected period',
                  TimePeriod.allTime),
        ],
      );

      blocTest<EloHistoryBloc, EloHistoryState>(
        'preserves original history when filtering',
        build: () {
          return EloHistoryBloc(userRepository: mockUserRepository);
        },
        seed: () {
          final now = DateTime.now();
          final history = [
            RatingHistoryEntry(
              entryId: 'entry-1',
              gameId: 'game-1',
              oldRating: 1600,
              newRating: 1625,
              ratingChange: 25,
              opponentTeam: 'Team A',
              won: true,
              timestamp: now.subtract(const Duration(days: 10)),
            ),
            RatingHistoryEntry(
              entryId: 'entry-2',
              gameId: 'game-2',
              oldRating: 1625,
              newRating: 1610,
              ratingChange: -15,
              opponentTeam: 'Team B',
              won: false,
              timestamp: now.subtract(const Duration(days: 100)),
            ),
          ];
          return EloHistoryState.loaded(
            history: history,
            filteredHistory: history,
            filterStartDate: null,
            filterEndDate: null,
          );
        },
        act: (bloc) => bloc.add(
          const EloHistoryEvent.filterByPeriod(TimePeriod.thirtyDays),
        ),
        expect: () => [
          isA<EloHistoryLoaded>()
              .having((s) => s.history.length, 'history length', 2)
              .having((s) => s.filteredHistory.length, 'filtered length', 1),
        ],
      );

      blocTest<EloHistoryBloc, EloHistoryState>(
        'state includes selectedPeriod field',
        build: () {
          return EloHistoryBloc(userRepository: mockUserRepository);
        },
        seed: () {
          final now = DateTime.now();
          final history = [
            RatingHistoryEntry(
              entryId: 'entry-1',
              gameId: 'game-1',
              oldRating: 1600,
              newRating: 1625,
              ratingChange: 25,
              opponentTeam: 'Team A',
              won: true,
              timestamp: now,
            ),
          ];
          return EloHistoryState.loaded(
            history: history,
            filteredHistory: history,
            filterStartDate: null,
            filterEndDate: null,
          );
        },
        act: (bloc) => bloc.add(
          const EloHistoryEvent.filterByPeriod(TimePeriod.ninetyDays),
        ),
        expect: () => [
          isA<EloHistoryLoaded>().having(
            (s) => s.selectedPeriod,
            'selected period',
            TimePeriod.ninetyDays,
          ),
        ],
      );
    });

    // Story 302.6: Best ELO calculation tests
    group('Best ELO calculation (Story 302.6)', () {
      blocTest<EloHistoryBloc, EloHistoryState>(
        'calculates best ELO correctly when loading history',
        build: () {
          final testHistory = [
            RatingHistoryEntry(
              entryId: 'entry-1',
              gameId: 'game-1',
              oldRating: 1600,
              newRating: 1625,
              ratingChange: 25,
              opponentTeam: 'Team A',
              won: true,
              timestamp: DateTime(2025, 12, 15),
            ),
            RatingHistoryEntry(
              entryId: 'entry-2',
              gameId: 'game-2',
              oldRating: 1625,
              newRating: 1650,
              ratingChange: 25,
              opponentTeam: 'Team B',
              won: true,
              timestamp: DateTime(2025, 12, 20),
            ),
            RatingHistoryEntry(
              entryId: 'entry-3',
              gameId: 'game-3',
              oldRating: 1650,
              newRating: 1630,
              ratingChange: -20,
              opponentTeam: 'Team C',
              won: false,
              timestamp: DateTime(2025, 12, 25),
            ),
          ];

          when(() => mockUserRepository.getRatingHistory('user-123', limit: 100))
              .thenAnswer((_) => Stream.value(testHistory));

          return EloHistoryBloc(userRepository: mockUserRepository);
        },
        act: (bloc) => bloc.add(const EloHistoryEvent.loadHistory(
          userId: 'user-123',
          limit: 100,
        )),
        expect: () => [
          const EloHistoryState.loading(),
          isA<EloHistoryLoaded>()
              .having((s) => s.bestEloInPeriod, 'best ELO', isNotNull)
              .having((s) => s.bestEloInPeriod?.elo, 'best ELO value', 1650)
              .having((s) => s.bestEloInPeriod?.gameId, 'best ELO game ID', 'game-2')
              .having((s) => s.bestEloInPeriod?.date, 'best ELO date', DateTime(2025, 12, 20)),
        ],
      );

      blocTest<EloHistoryBloc, EloHistoryState>(
        'returns null best ELO when history is empty',
        build: () {
          when(() => mockUserRepository.getRatingHistory('user-123', limit: 100))
              .thenAnswer((_) => Stream.value([]));

          return EloHistoryBloc(userRepository: mockUserRepository);
        },
        act: (bloc) => bloc.add(const EloHistoryEvent.loadHistory(
          userId: 'user-123',
          limit: 100,
        )),
        expect: () => [
          const EloHistoryState.loading(),
          isA<EloHistoryLoaded>()
              .having((s) => s.bestEloInPeriod, 'best ELO', null),
        ],
      );

      blocTest<EloHistoryBloc, EloHistoryState>(
        'FilterByPeriod calculates best ELO from filtered data',
        build: () {
          return EloHistoryBloc(userRepository: mockUserRepository);
        },
        seed: () {
          final now = DateTime.now();
          final history = [
            RatingHistoryEntry(
              entryId: 'entry-1',
              gameId: 'game-1',
              oldRating: 1600,
              newRating: 1650,
              ratingChange: 50,
              opponentTeam: 'Team A',
              won: true,
              timestamp: now.subtract(const Duration(days: 10)),
            ),
            RatingHistoryEntry(
              entryId: 'entry-2',
              gameId: 'game-2',
              oldRating: 1700,
              newRating: 1800,
              ratingChange: 100,
              opponentTeam: 'Team B',
              won: true,
              timestamp: now.subtract(const Duration(days: 50)),
            ),
          ];
          return EloHistoryState.loaded(
            history: history,
            filteredHistory: history,
            filterStartDate: null,
            filterEndDate: null,
          );
        },
        act: (bloc) => bloc.add(
          const EloHistoryEvent.filterByPeriod(TimePeriod.thirtyDays),
        ),
        expect: () => [
          isA<EloHistoryLoaded>()
              .having((s) => s.filteredHistory.length, 'filtered length', 1)
              .having((s) => s.bestEloInPeriod, 'best ELO', isNotNull)
              .having((s) => s.bestEloInPeriod?.elo, 'best ELO value', 1650)
              .having((s) => s.bestEloInPeriod?.gameId, 'best ELO game ID', 'game-1'),
        ],
      );

      blocTest<EloHistoryBloc, EloHistoryState>(
        'FilterByPeriod returns null when filtered data is empty',
        build: () {
          return EloHistoryBloc(userRepository: mockUserRepository);
        },
        seed: () {
          final now = DateTime.now();
          final history = [
            RatingHistoryEntry(
              entryId: 'entry-1',
              gameId: 'game-1',
              oldRating: 1600,
              newRating: 1625,
              ratingChange: 25,
              opponentTeam: 'Team A',
              won: true,
              timestamp: now.subtract(const Duration(days: 400)),
            ),
          ];
          return EloHistoryState.loaded(
            history: history,
            filteredHistory: history,
            filterStartDate: null,
            filterEndDate: null,
          );
        },
        act: (bloc) => bloc.add(
          const EloHistoryEvent.filterByPeriod(TimePeriod.thirtyDays),
        ),
        expect: () => [
          isA<EloHistoryLoaded>()
              .having((s) => s.filteredHistory.length, 'filtered length', 0)
              .having((s) => s.bestEloInPeriod, 'best ELO', null),
        ],
      );

      blocTest<EloHistoryBloc, EloHistoryState>(
        'FilterByDateRange calculates best ELO from filtered data',
        build: () {
          return EloHistoryBloc(userRepository: mockUserRepository);
        },
        seed: () {
          final now = DateTime.now();
          final history = [
            RatingHistoryEntry(
              entryId: 'entry-1',
              gameId: 'game-1',
              oldRating: 1600,
              newRating: 1700,
              ratingChange: 100,
              opponentTeam: 'Team A',
              won: true,
              timestamp: now.subtract(const Duration(days: 3)),
            ),
            RatingHistoryEntry(
              entryId: 'entry-2',
              gameId: 'game-2',
              oldRating: 1700,
              newRating: 1650,
              ratingChange: -50,
              opponentTeam: 'Team B',
              won: false,
              timestamp: now.subtract(const Duration(days: 10)),
            ),
          ];
          return EloHistoryState.loaded(
            history: history,
            filteredHistory: history,
            filterStartDate: null,
            filterEndDate: null,
          );
        },
        act: (bloc) {
          final now = DateTime.now();
          return bloc.add(EloHistoryEvent.filterByDateRange(
            startDate: now.subtract(const Duration(days: 5)),
            endDate: now,
          ));
        },
        expect: () => [
          isA<EloHistoryLoaded>()
              .having((s) => s.filteredHistory.length, 'filtered length', 1)
              .having((s) => s.bestEloInPeriod, 'best ELO', isNotNull)
              .having((s) => s.bestEloInPeriod?.elo, 'best ELO value', 1700)
              .having((s) => s.bestEloInPeriod?.gameId, 'best ELO game ID', 'game-1'),
        ],
      );

      blocTest<EloHistoryBloc, EloHistoryState>(
        'ClearFilter calculates best ELO from all history',
        build: () {
          return EloHistoryBloc(userRepository: mockUserRepository);
        },
        seed: () {
          final now = DateTime.now();
          final history = [
            RatingHistoryEntry(
              entryId: 'entry-1',
              gameId: 'game-1',
              oldRating: 1600,
              newRating: 1650,
              ratingChange: 50,
              opponentTeam: 'Team A',
              won: true,
              timestamp: now.subtract(const Duration(days: 10)),
            ),
            RatingHistoryEntry(
              entryId: 'entry-2',
              gameId: 'game-2',
              oldRating: 1700,
              newRating: 1800,
              ratingChange: 100,
              opponentTeam: 'Team B',
              won: true,
              timestamp: now.subtract(const Duration(days: 50)),
            ),
          ];
          return EloHistoryState.loaded(
            history: history,
            filteredHistory: [history[0]],
            filterStartDate: now.subtract(const Duration(days: 20)),
            filterEndDate: now,
            selectedPeriod: TimePeriod.thirtyDays,
            bestEloInPeriod: BestEloRecord(
              elo: 1650,
              date: history[0].timestamp,
              gameId: history[0].gameId,
            ),
          );
        },
        act: (bloc) => bloc.add(const EloHistoryEvent.clearFilter()),
        expect: () => [
          isA<EloHistoryLoaded>()
              .having((s) => s.filteredHistory.length, 'filtered length', 2)
              .having((s) => s.bestEloInPeriod, 'best ELO', isNotNull)
              .having((s) => s.bestEloInPeriod?.elo, 'best ELO value', 1800)
              .having((s) => s.bestEloInPeriod?.gameId, 'best ELO game ID', 'game-2')
              .having((s) => s.selectedPeriod, 'selected period', TimePeriod.allTime),
        ],
      );

      blocTest<EloHistoryBloc, EloHistoryState>(
        'handles identical ELO values (picks last one with reduce)',
        build: () {
          final testHistory = [
            RatingHistoryEntry(
              entryId: 'entry-1',
              gameId: 'game-1',
              oldRating: 1600,
              newRating: 1700,
              ratingChange: 100,
              opponentTeam: 'Team A',
              won: true,
              timestamp: DateTime(2025, 12, 15),
            ),
            RatingHistoryEntry(
              entryId: 'entry-2',
              gameId: 'game-2',
              oldRating: 1650,
              newRating: 1700,
              ratingChange: 50,
              opponentTeam: 'Team B',
              won: true,
              timestamp: DateTime(2025, 12, 20),
            ),
          ];

          when(() => mockUserRepository.getRatingHistory('user-123', limit: 100))
              .thenAnswer((_) => Stream.value(testHistory));

          return EloHistoryBloc(userRepository: mockUserRepository);
        },
        act: (bloc) => bloc.add(const EloHistoryEvent.loadHistory(
          userId: 'user-123',
          limit: 100,
        )),
        expect: () => [
          const EloHistoryState.loading(),
          isA<EloHistoryLoaded>()
              .having((s) => s.bestEloInPeriod, 'best ELO', isNotNull)
              .having((s) => s.bestEloInPeriod?.elo, 'best ELO value', 1700)
              // When ELO values are identical, reduce picks the last one
              .having((s) => s.bestEloInPeriod?.gameId, 'best ELO game ID', 'game-2'),
        ],
      );
    });
  });
}
