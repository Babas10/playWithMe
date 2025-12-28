import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/data/models/rating_history_entry.dart';
import 'package:play_with_me/core/data/models/user_model.dart';
import 'package:play_with_me/core/domain/repositories/user_repository.dart';
import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_event.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_state.dart';
import 'package:play_with_me/features/profile/presentation/pages/profile_page.dart';
import 'package:play_with_me/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MockAuthenticationBloc extends MockBloc<AuthenticationEvent, AuthenticationState>
    implements AuthenticationBloc {}

class MockUserRepository extends Mock implements UserRepository {}

class FakeAuthenticationState extends Fake implements AuthenticationState {}

void main() {
  late MockAuthenticationBloc mockAuthBloc;
  late MockUserRepository mockUserRepository;
  final sl = GetIt.instance;

  const userId = 'test-uid';
  // UserEntity for Auth Bloc
  const testUserEntity = UserEntity(
    uid: userId,
    email: 'test@example.com',
    isEmailVerified: true,
    isAnonymous: false,
  );

  // UserModel for Stats Bloc (via Repository)
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

  setUpAll(() {
    registerFallbackValue(FakeAuthenticationState());
  });

  setUp(() {
    mockAuthBloc = MockAuthenticationBloc();
    mockUserRepository = MockUserRepository();

    if (sl.isRegistered<UserRepository>()) {
      sl.unregister<UserRepository>();
    }
    sl.registerSingleton<UserRepository>(mockUserRepository);

    when(() => mockAuthBloc.state).thenReturn(const AuthenticationAuthenticated(testUserEntity));
    // Use broadcast stream to allow multiple subscriptions
    when(() => mockUserRepository.getUserStream(userId))
        .thenAnswer((_) => Stream.value(testUserModel).asBroadcastStream());
    when(() => mockUserRepository.getRatingHistory(userId))
        .thenAnswer((_) => Stream.value(testHistory).asBroadcastStream());
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
      home: BlocProvider<AuthenticationBloc>.value(
        value: mockAuthBloc,
        child: const ProfilePage(),
      ),
    );
  }

  testWidgets('ProfilePage displays PlayerStatsSection and correct stats', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle(); // Wait for async blocs to load

    // Check if section title is present
    // New stats layout uses ExpandedStatsSection with different structure
    expect(find.text('Performance Overview'), findsOneWidget);

    // Check if Current ELO is present
    expect(find.text('Current ELO'), findsOneWidget);
    expect(find.text('1650'), findsOneWidget);

    // Check if Win Rate is present
    expect(find.text('Win Rate'), findsOneWidget);
    expect(find.text('60.0%'), findsOneWidget); // 6/10

    // Check if Games Played is present
    expect(find.text('Games Played'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);

    // Check for Momentum & Consistency section
    expect(find.text('Momentum & Consistency'), findsOneWidget);
  });
}