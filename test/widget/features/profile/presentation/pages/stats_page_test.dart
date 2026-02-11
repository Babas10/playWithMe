// Verifies that StatsPage renders correctly in different PlayerStatsBloc states

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/data/models/rating_history_entry.dart';
import 'package:play_with_me/core/data/models/user_model.dart';
import 'package:play_with_me/core/data/models/user_ranking.dart';
import 'package:play_with_me/core/domain/repositories/user_repository.dart';
import 'package:play_with_me/features/profile/presentation/pages/stats_page.dart';
import 'package:play_with_me/features/profile/presentation/bloc/player_stats/player_stats_bloc.dart';
import 'package:play_with_me/features/profile/presentation/bloc/player_stats/player_stats_event.dart';
import 'package:play_with_me/features/profile/presentation/bloc/player_stats/player_stats_state.dart';
import 'package:play_with_me/features/profile/presentation/widgets/expanded_stats_section.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

class MockPlayerStatsBloc
    extends MockBloc<PlayerStatsEvent, PlayerStatsState>
    implements PlayerStatsBloc {}

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockPlayerStatsBloc mockBloc;
  late MockUserRepository mockUserRepository;
  final sl = GetIt.instance;

  const userId = 'test-uid';

  final testUserModel = UserModel(
    uid: userId,
    email: 'test@example.com',
    isEmailVerified: true,
    isAnonymous: false,
    eloRating: 1500,
    gamesPlayed: 5,
    gamesWon: 3,
    gamesLost: 2,
    currentStreak: 1,
  );

  final testHistory = [
    RatingHistoryEntry(
      entryId: 'e1',
      gameId: 'g1',
      oldRating: 1480,
      newRating: 1500,
      ratingChange: 20,
      opponentTeam: 'Opponents',
      won: true,
      timestamp: DateTime.now(),
    ),
  ];

  setUp(() {
    mockBloc = MockPlayerStatsBloc();
    mockUserRepository = MockUserRepository();

    if (sl.isRegistered<UserRepository>()) {
      sl.unregister<UserRepository>();
    }
    sl.registerSingleton<UserRepository>(mockUserRepository);

    // Stub methods used by internal blocs in MomentumConsistencyCard
    when(() => mockUserRepository.getUserStream(any()))
        .thenAnswer((_) => Stream.value(testUserModel));
    when(() => mockUserRepository.getRatingHistory(any(), limit: any(named: 'limit')))
        .thenAnswer((_) => Stream.value(testHistory));
    when(() => mockUserRepository.getRatingHistory(any()))
        .thenAnswer((_) => Stream.value(testHistory));
    when(() => mockUserRepository.getUserRanking(any()))
        .thenAnswer((_) async => UserRanking(
              globalRank: 1,
              totalUsers: 10,
              percentile: 90.0,
              friendsRank: 1,
              totalFriends: 5,
              calculatedAt: DateTime.now(),
            ));
  });

  tearDown(() async {
    await mockBloc.close();
    sl.reset();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: BlocProvider<PlayerStatsBloc>.value(
        value: mockBloc,
        child: const Scaffold(body: StatsPage()),
      ),
    );
  }

  group('StatsPage', () {
    testWidgets('displays loading indicator when stats are loading', (tester) async {
      whenListen(mockBloc, const Stream<PlayerStatsState>.empty(),
          initialState: PlayerStatsLoading());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays ExpandedStatsSection when stats are loaded', (tester) async {
      final loadedState = PlayerStatsLoaded(
        user: testUserModel,
        history: testHistory,
        ranking: null,
        rankingLoadFailed: false,
      );
      whenListen(mockBloc, const Stream<PlayerStatsState>.empty(),
          initialState: loadedState);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // ExpandedStatsSection should be displayed
      expect(find.byType(ExpandedStatsSection), findsOneWidget);

      // Verify Performance Overview section is present
      expect(find.text('Performance Overview'), findsOneWidget);

      // Verify Momentum & Consistency section is present
      expect(find.text('Momentum & Consistency'), findsOneWidget);
    });

    testWidgets('displays error message when stats fail to load', (tester) async {
      const errorState = PlayerStatsError('Network error');
      whenListen(mockBloc, const Stream<PlayerStatsState>.empty(),
          initialState: errorState);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.textContaining('Error loading stats'), findsOneWidget);
    });

    testWidgets('is scrollable when loaded', (tester) async {
      final loadedState = PlayerStatsLoaded(
        user: testUserModel,
        history: testHistory,
        ranking: null,
        rankingLoadFailed: false,
      );
      whenListen(mockBloc, const Stream<PlayerStatsState>.empty(),
          initialState: loadedState);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}
