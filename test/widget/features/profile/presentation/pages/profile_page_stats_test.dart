// Verifies that StatsPage displays player statistics correctly using PlayerStatsBloc

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:play_with_me/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockUserRepository mockUserRepository;
  final sl = GetIt.instance;

  const userId = 'test-uid';

  final testUserModel = UserModel(
    uid: userId,
    email: 'test@example.com',
    isEmailVerified: true,
    isAnonymous: false,
    eloRating: 1650,
    gamesPlayed: 10,
    gamesWon: 6,
    gamesLost: 4,
    currentStreak: 2,
  );

  final testHistory = [
    RatingHistoryEntry(
      entryId: 'e1',
      gameId: 'g1',
      oldRating: 1600,
      newRating: 1625,
      ratingChange: 25,
      opponentTeam: 'Opponents',
      won: true,
      timestamp: DateTime.now(),
    )
  ];

  setUp(() {
    mockUserRepository = MockUserRepository();

    if (sl.isRegistered<UserRepository>()) {
      sl.unregister<UserRepository>();
    }
    sl.registerSingleton<UserRepository>(mockUserRepository);

    when(() => mockUserRepository.getUserStream(userId))
        .thenAnswer((_) => Stream.value(testUserModel).asBroadcastStream());
    when(() => mockUserRepository.getRatingHistory(userId))
        .thenAnswer((_) => Stream.value(testHistory).asBroadcastStream());
    when(() => mockUserRepository.getUserRanking(userId))
        .thenAnswer((_) async => UserRanking(
              globalRank: 5,
              totalUsers: 100,
              percentile: 95.0,
              calculatedAt: DateTime(2024, 1, 1),
            ));
  });

  tearDown(() {
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
      home: BlocProvider<PlayerStatsBloc>(
        create: (_) => PlayerStatsBloc(
          userRepository: mockUserRepository,
        )..add(LoadPlayerStats(userId)),
        child: const Scaffold(body: StatsPage()),
      ),
    );
  }

  testWidgets('StatsPage displays ExpandedStatsSection and correct stats', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Check if Performance Overview section is present (from ExpandedStatsSection)
    expect(find.text('Performance Overview'), findsOneWidget);

    // Check if Current ELO is present
    expect(find.text('Current ELO'), findsOneWidget);
    expect(find.text('1650'), findsOneWidget);

    // Check if Win Rate is present
    expect(find.text('Win Rate'), findsOneWidget);
    expect(find.text('60.0%'), findsOneWidget);

    // Check if Games Played is present
    expect(find.text('Games Played'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);

    // Check for Momentum & Consistency section
    expect(find.text('Momentum & Consistency'), findsOneWidget);
  });
}
