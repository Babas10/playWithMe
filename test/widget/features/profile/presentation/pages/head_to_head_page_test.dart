// Widget tests for HeadToHeadPage verifying UI rendering and state transitions.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/presentation/bloc/invitation/invitation_bloc.dart';
import 'package:play_with_me/core/presentation/bloc/invitation/invitation_state.dart';
import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_state.dart';
import 'package:play_with_me/l10n/app_localizations.dart';
import 'package:play_with_me/core/data/models/head_to_head_stats.dart';
import 'package:play_with_me/core/domain/repositories/user_repository.dart';
import 'package:play_with_me/features/profile/presentation/pages/head_to_head_page.dart';

class MockUserRepository extends Mock implements UserRepository {}
class MockInvitationBloc extends Mock implements InvitationBloc {}
class MockAuthenticationBloc extends Mock implements AuthenticationBloc {}

void main() {
  late MockUserRepository mockUserRepository;
  late MockInvitationBloc mockInvitationBloc;
  late MockAuthenticationBloc mockAuthBloc;

  const testUserId = 'test-user-123';
  const testOpponentId = 'opponent-456';

  // Sample test data
  final testMatchup1 = HeadToHeadGameResult(
    gameId: 'game-1',
    won: true,
    pointsScored: 21,
    pointsAllowed: 15,
    eloChange: 18.5,
    timestamp: DateTime(2024, 1, 15),
  );

  final testMatchup2 = HeadToHeadGameResult(
    gameId: 'game-2',
    won: false,
    pointsScored: 18,
    pointsAllowed: 21,
    eloChange: -12.0,
    timestamp: DateTime(2024, 1, 10),
  );

  final testMatchup3 = HeadToHeadGameResult(
    gameId: 'game-3',
    won: true,
    pointsScored: 21,
    pointsAllowed: 19,
    eloChange: 10.0,
    timestamp: DateTime(2024, 1, 5),
  );

  final testStats = HeadToHeadStats(
    userId: testUserId,
    opponentId: testOpponentId,
    opponentName: 'John Doe',
    opponentEmail: 'john@example.com',
    opponentPhotoUrl: null,
    gamesPlayed: 15,
    gamesWon: 10,
    gamesLost: 5,
    pointsScored: 300,
    pointsAllowed: 250,
    eloChange: 45.0,
    largestVictoryMargin: 8,
    largestDefeatMargin: 5,
    recentMatchups: [testMatchup1, testMatchup2, testMatchup3],
  );

  final testStatsNoMatchups = HeadToHeadStats(
    userId: testUserId,
    opponentId: testOpponentId,
    opponentName: 'Jane Smith',
    opponentEmail: 'jane@example.com',
    opponentPhotoUrl: null,
    gamesPlayed: 5,
    gamesWon: 3,
    gamesLost: 2,
    pointsScored: 100,
    pointsAllowed: 90,
    eloChange: 15.0,
    largestVictoryMargin: 4,
    largestDefeatMargin: 3,
    recentMatchups: [],
  );

  setUp(() {
    mockUserRepository = MockUserRepository();
    mockInvitationBloc = MockInvitationBloc();
    mockAuthBloc = MockAuthenticationBloc();
    when(() => mockInvitationBloc.state).thenReturn(const InvitationInitial());
    when(() => mockInvitationBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockAuthBloc.state).thenReturn(
      AuthenticationAuthenticated(
        UserEntity(uid: 'test-user', email: 'test@example.com', isEmailVerified: true, isAnonymous: false),
      ),
    );
    when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());

    // Register mock in GetIt
    final sl = GetIt.instance;
    if (sl.isRegistered<UserRepository>()) {
      sl.unregister<UserRepository>();
    }
    sl.registerSingleton<UserRepository>(mockUserRepository);
  });

  tearDown(() {
    final sl = GetIt.instance;
    if (sl.isRegistered<UserRepository>()) {
      sl.unregister<UserRepository>();
    }
  });

  Widget createTestWidget() {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: MultiBlocProvider(
        providers: [
          BlocProvider<InvitationBloc>.value(value: mockInvitationBloc),
          BlocProvider<AuthenticationBloc>.value(value: mockAuthBloc),
        ],
        child: const HeadToHeadPage(
          userId: testUserId,
          opponentId: testOpponentId,
        ),
      ),
    );
  }

  group('HeadToHeadPage Widget Tests', () {
    group('Initial UI Rendering', () {
      testWidgets('renders app bar with Head-to-Head title', (tester) async {
        when(() => mockUserRepository.getHeadToHeadStats(testUserId, testOpponentId))
            .thenAnswer((_) async => testStats);

        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byType(AppBar), findsOneWidget);
        expect(find.text('Head-to-Head'), findsOneWidget);
      });
    });

    group('Error State', () {
      testWidgets('shows error message when stats is null', (tester) async {
        when(() => mockUserRepository.getHeadToHeadStats(testUserId, testOpponentId))
            .thenAnswer((_) async => null);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.text('No head-to-head statistics found for this opponent'),
            findsOneWidget);
      });

      testWidgets('shows error message when exception is thrown', (tester) async {
        when(() => mockUserRepository.getHeadToHeadStats(testUserId, testOpponentId))
            .thenThrow(Exception('Network error'));

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.textContaining('Failed to load head-to-head details'),
            findsOneWidget);
      });

      testWidgets('error icon has red color', (tester) async {
        when(() => mockUserRepository.getHeadToHeadStats(testUserId, testOpponentId))
            .thenAnswer((_) async => null);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        final icon = tester.widget<Icon>(find.byIcon(Icons.error_outline));
        expect(icon.color, Colors.red);
      });
    });

    group('Loaded State - Opponent Header', () {
      testWidgets('shows opponent display name', (tester) async {
        when(() => mockUserRepository.getHeadToHeadStats(testUserId, testOpponentId))
            .thenAnswer((_) async => testStats);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('John Doe'), findsOneWidget);
      });

      testWidgets('shows opponent email when available', (tester) async {
        when(() => mockUserRepository.getHeadToHeadStats(testUserId, testOpponentId))
            .thenAnswer((_) async => testStats);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('john@example.com'), findsOneWidget);
      });

      testWidgets('shows person icon when no photo url', (tester) async {
        when(() => mockUserRepository.getHeadToHeadStats(testUserId, testOpponentId))
            .thenAnswer((_) async => testStats);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.person), findsOneWidget);
      });

      testWidgets('shows rivalry indicator badge', (tester) async {
        when(() => mockUserRepository.getHeadToHeadStats(testUserId, testOpponentId))
            .thenAnswer((_) async => testStats);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.sports_kabaddi), findsOneWidget);
      });
    });

    group('Loaded State - Rivalry Card', () {
      testWidgets('shows rivalry intensity', (tester) async {
        when(() => mockUserRepository.getHeadToHeadStats(testUserId, testOpponentId))
            .thenAnswer((_) async => testStats);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // 15 games = "Active rivalry"
        expect(find.text('Active rivalry'), findsOneWidget);
      });

      testWidgets('shows matchup advantage', (tester) async {
        when(() => mockUserRepository.getHeadToHeadStats(testUserId, testOpponentId))
            .thenAnswer((_) async => testStats);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // 10/15 = 66.7% > 60% = "Strong advantage"
        expect(find.text('Strong advantage'), findsOneWidget);
      });
    });

    group('Loaded State - Record Card', () {
      testWidgets('shows Head-to-Head Record title', (tester) async {
        when(() => mockUserRepository.getHeadToHeadStats(testUserId, testOpponentId))
            .thenAnswer((_) async => testStats);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Head-to-Head Record'), findsOneWidget);
      });

      testWidgets('shows games played count', (tester) async {
        when(() => mockUserRepository.getHeadToHeadStats(testUserId, testOpponentId))
            .thenAnswer((_) async => testStats);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('15'), findsOneWidget);
        expect(find.text('Matchups'), findsOneWidget);
      });

      testWidgets('shows win rate percentage', (tester) async {
        when(() => mockUserRepository.getHeadToHeadStats(testUserId, testOpponentId))
            .thenAnswer((_) async => testStats);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // 10/15 = 66.7%
        expect(find.text('66.7%'), findsOneWidget);
        expect(find.text('Win Rate'), findsOneWidget);
      });

      testWidgets('shows win-loss record string', (tester) async {
        when(() => mockUserRepository.getHeadToHeadStats(testUserId, testOpponentId))
            .thenAnswer((_) async => testStats);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('10W - 5L'), findsOneWidget);
        expect(find.text('Record'), findsOneWidget);
      });
    });

    group('Loaded State - Point Differential Card', () {
      testWidgets('shows Point Differential title', (tester) async {
        when(() => mockUserRepository.getHeadToHeadStats(testUserId, testOpponentId))
            .thenAnswer((_) async => testStats);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Point Differential'), findsOneWidget);
      });

      testWidgets('shows average point differential', (tester) async {
        when(() => mockUserRepository.getHeadToHeadStats(testUserId, testOpponentId))
            .thenAnswer((_) async => testStats);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // avgPointsScored = 300/15 = 20, avgPointsAllowed = 250/15 = 16.67
        // Avg diff = 20 - 16.67 = 3.33
        expect(find.text('+3.3'), findsOneWidget);
        expect(find.text('Avg Per Game'), findsOneWidget);
      });

      testWidgets('shows points scored average', (tester) async {
        when(() => mockUserRepository.getHeadToHeadStats(testUserId, testOpponentId))
            .thenAnswer((_) async => testStats);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // 300/15 = 20.0
        expect(find.text('20.0'), findsOneWidget);
        expect(find.text('Points For'), findsOneWidget);
      });

      testWidgets('shows points allowed average', (tester) async {
        when(() => mockUserRepository.getHeadToHeadStats(testUserId, testOpponentId))
            .thenAnswer((_) async => testStats);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // 250/15 = 16.67
        expect(find.text('16.7'), findsOneWidget);
        expect(find.text('Points Against'), findsOneWidget);
      });
    });

    group('Loaded State - Margins Card', () {
      testWidgets('shows Matchup Margins title', (tester) async {
        when(() => mockUserRepository.getHeadToHeadStats(testUserId, testOpponentId))
            .thenAnswer((_) async => testStats);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Matchup Margins'), findsOneWidget);
      });

      testWidgets('shows biggest victory margin', (tester) async {
        when(() => mockUserRepository.getHeadToHeadStats(testUserId, testOpponentId))
            .thenAnswer((_) async => testStats);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('+8'), findsOneWidget);
        expect(find.text('Biggest Win'), findsOneWidget);
      });

      testWidgets('shows worst defeat margin', (tester) async {
        when(() => mockUserRepository.getHeadToHeadStats(testUserId, testOpponentId))
            .thenAnswer((_) async => testStats);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('-5'), findsOneWidget);
        expect(find.text('Worst Loss'), findsOneWidget);
      });

      testWidgets('shows total ELO change against opponent', (tester) async {
        when(() => mockUserRepository.getHeadToHeadStats(testUserId, testOpponentId))
            .thenAnswer((_) async => testStats);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('+45.0'), findsOneWidget);
        expect(find.text('ELO vs Them'), findsOneWidget);
      });
    });

    group('Loaded State - Recent Matchups', () {
      testWidgets('shows Recent Matchups title', (tester) async {
        when(() => mockUserRepository.getHeadToHeadStats(testUserId, testOpponentId))
            .thenAnswer((_) async => testStats);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Recent Matchups'), findsOneWidget);
      });

      testWidgets('shows current streak badge when on streak', (tester) async {
        when(() => mockUserRepository.getHeadToHeadStats(testUserId, testOpponentId))
            .thenAnswer((_) async => testStats);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // First matchup is W, so streak = 1 W Streak
        expect(find.text('1 W Streak'), findsOneWidget);
      });

      testWidgets('shows matchup score displays', (tester) async {
        when(() => mockUserRepository.getHeadToHeadStats(testUserId, testOpponentId))
            .thenAnswer((_) async => testStats);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify score displays from matchups
        expect(find.text('21-15'), findsOneWidget);
        expect(find.text('18-21'), findsOneWidget);
        expect(find.text('21-19'), findsOneWidget);
      });

      testWidgets('shows W and L result letters', (tester) async {
        when(() => mockUserRepository.getHeadToHeadStats(testUserId, testOpponentId))
            .thenAnswer((_) async => testStats);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // 2 wins and 1 loss in recent matchups
        expect(find.text('W'), findsNWidgets(2));
        expect(find.text('L'), findsOneWidget);
      });

      testWidgets('shows ELO change for each matchup', (tester) async {
        when(() => mockUserRepository.getHeadToHeadStats(testUserId, testOpponentId))
            .thenAnswer((_) async => testStats);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('ELO: +18.5'), findsOneWidget);
        expect(find.text('ELO: -12.0'), findsOneWidget);
        expect(find.text('ELO: +10.0'), findsOneWidget);
      });

      testWidgets('shows empty state when no recent matchups', (tester) async {
        when(() => mockUserRepository.getHeadToHeadStats(testUserId, testOpponentId))
            .thenAnswer((_) async => testStatsNoMatchups);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('No recent matchups'), findsOneWidget);
      });
    });

    group('Loaded State - Losing Streak', () {
      testWidgets('shows losing streak badge when on losing streak',
          (tester) async {
        final losingStats = HeadToHeadStats(
          userId: testUserId,
          opponentId: testOpponentId,
          opponentName: 'Tough Opponent',
          opponentEmail: 'tough@example.com',
          gamesPlayed: 10,
          gamesWon: 3,
          gamesLost: 7,
          pointsScored: 150,
          pointsAllowed: 200,
          eloChange: -25.0,
          largestVictoryMargin: 3,
          largestDefeatMargin: 10,
          recentMatchups: [
            HeadToHeadGameResult(
              gameId: 'game-1',
              won: false,
              pointsScored: 15,
              pointsAllowed: 21,
              eloChange: -10.0,
              timestamp: DateTime(2024, 1, 15),
            ),
            HeadToHeadGameResult(
              gameId: 'game-2',
              won: false,
              pointsScored: 18,
              pointsAllowed: 21,
              eloChange: -8.0,
              timestamp: DateTime(2024, 1, 10),
            ),
          ],
        );

        when(() => mockUserRepository.getHeadToHeadStats(testUserId, testOpponentId))
            .thenAnswer((_) async => losingStats);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('2 L Streak'), findsOneWidget);
      });
    });

    group('Opponent Display Name Fallback', () {
      testWidgets('shows email when name is null', (tester) async {
        final statsWithoutName = HeadToHeadStats(
          userId: testUserId,
          opponentId: testOpponentId,
          opponentName: null,
          opponentEmail: 'anonymous@example.com',
          gamesPlayed: 5,
          gamesWon: 3,
          gamesLost: 2,
          pointsScored: 100,
          pointsAllowed: 90,
          eloChange: 10.0,
          largestVictoryMargin: 4,
          largestDefeatMargin: 3,
          recentMatchups: [],
        );

        when(() => mockUserRepository.getHeadToHeadStats(testUserId, testOpponentId))
            .thenAnswer((_) async => statsWithoutName);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // opponentDisplayName fallback to email - appears once in header
        expect(find.text('anonymous@example.com'), findsOneWidget);
      });
    });
  });
}
