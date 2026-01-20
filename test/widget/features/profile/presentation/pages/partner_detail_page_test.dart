// Widget tests for PartnerDetailPage verifying UI rendering and state transitions.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/data/models/teammate_stats.dart';
import 'package:play_with_me/core/data/models/user_model.dart';
import 'package:play_with_me/core/domain/repositories/user_repository.dart';
import 'package:play_with_me/features/profile/presentation/pages/partner_detail_page.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockUserRepository mockUserRepository;

  const testUserId = 'test-user-123';
  const testPartnerId = 'partner-456';

  // Sample test data
  final testGame1 = RecentGameResult(
    gameId: 'game-1',
    won: true,
    pointsScored: 21,
    pointsAllowed: 15,
    eloChange: 18.5,
    timestamp: DateTime(2024, 1, 15),
  );

  final testGame2 = RecentGameResult(
    gameId: 'game-2',
    won: false,
    pointsScored: 18,
    pointsAllowed: 21,
    eloChange: -12.0,
    timestamp: DateTime(2024, 1, 10),
  );

  final testGame3 = RecentGameResult(
    gameId: 'game-3',
    won: true,
    pointsScored: 21,
    pointsAllowed: 19,
    eloChange: 10.0,
    timestamp: DateTime(2024, 1, 5),
  );

  final testStats = TeammateStats(
    userId: testPartnerId,
    gamesPlayed: 20,
    gamesWon: 15,
    gamesLost: 5,
    pointsScored: 400,
    pointsAllowed: 300,
    eloChange: 60.0,
    recentGames: [testGame1, testGame2, testGame3],
  );

  final testStatsNoGames = TeammateStats(
    userId: testPartnerId,
    gamesPlayed: 10,
    gamesWon: 6,
    gamesLost: 4,
    pointsScored: 200,
    pointsAllowed: 180,
    eloChange: 20.0,
    recentGames: [],
  );

  final testPartner = UserModel(
    uid: testPartnerId,
    email: 'partner@example.com',
    displayName: 'John Partner',
    photoUrl: null,
    isEmailVerified: true,
    isAnonymous: false,
  );

  final testPartnerWithoutDisplayName = UserModel(
    uid: testPartnerId,
    email: 'anonymous@example.com',
    displayName: null,
    photoUrl: null,
    isEmailVerified: true,
    isAnonymous: false,
  );

  setUp(() {
    mockUserRepository = MockUserRepository();

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
    return const MaterialApp(
      home: PartnerDetailPage(
        userId: testUserId,
        partnerId: testPartnerId,
      ),
    );
  }

  group('PartnerDetailPage Widget Tests', () {
    group('Initial UI Rendering', () {
      testWidgets('renders app bar with Partner Details title', (tester) async {
        when(() => mockUserRepository.getTeammateStats(testUserId, testPartnerId))
            .thenAnswer((_) async => testStats);
        when(() => mockUserRepository.getUserById(testPartnerId))
            .thenAnswer((_) async => testPartner);

        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byType(AppBar), findsOneWidget);
        expect(find.text('Partner Details'), findsOneWidget);
      });
    });

    group('Error State', () {
      testWidgets('shows error message when stats is null', (tester) async {
        when(() => mockUserRepository.getTeammateStats(testUserId, testPartnerId))
            .thenAnswer((_) async => null);
        when(() => mockUserRepository.getUserById(testPartnerId))
            .thenAnswer((_) async => testPartner);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.text('No statistics found for this partner'), findsOneWidget);
      });

      testWidgets('shows error message when partner profile is null',
          (tester) async {
        when(() => mockUserRepository.getTeammateStats(testUserId, testPartnerId))
            .thenAnswer((_) async => testStats);
        when(() => mockUserRepository.getUserById(testPartnerId))
            .thenAnswer((_) async => null);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.text('Partner profile not found'), findsOneWidget);
      });

      testWidgets('shows error message when exception is thrown',
          (tester) async {
        when(() => mockUserRepository.getTeammateStats(testUserId, testPartnerId))
            .thenThrow(Exception('Network error'));
        when(() => mockUserRepository.getUserById(testPartnerId))
            .thenAnswer((_) async => testPartner);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.textContaining('Failed to load partner details'),
            findsOneWidget);
      });

      testWidgets('error icon has red color', (tester) async {
        when(() => mockUserRepository.getTeammateStats(testUserId, testPartnerId))
            .thenAnswer((_) async => null);
        when(() => mockUserRepository.getUserById(testPartnerId))
            .thenAnswer((_) async => testPartner);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        final icon = tester.widget<Icon>(find.byIcon(Icons.error_outline));
        expect(icon.color, Colors.red);
      });
    });

    group('Loaded State - Partner Header', () {
      testWidgets('shows partner display name', (tester) async {
        when(() => mockUserRepository.getTeammateStats(testUserId, testPartnerId))
            .thenAnswer((_) async => testStats);
        when(() => mockUserRepository.getUserById(testPartnerId))
            .thenAnswer((_) async => testPartner);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('John Partner'), findsOneWidget);
      });

      testWidgets('shows partner email when display name is set',
          (tester) async {
        when(() => mockUserRepository.getTeammateStats(testUserId, testPartnerId))
            .thenAnswer((_) async => testStats);
        when(() => mockUserRepository.getUserById(testPartnerId))
            .thenAnswer((_) async => testPartner);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('partner@example.com'), findsOneWidget);
      });

      testWidgets('shows email as display name when no display name',
          (tester) async {
        when(() => mockUserRepository.getTeammateStats(testUserId, testPartnerId))
            .thenAnswer((_) async => testStats);
        when(() => mockUserRepository.getUserById(testPartnerId))
            .thenAnswer((_) async => testPartnerWithoutDisplayName);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // displayNameOrEmail returns email when displayName is null
        expect(find.text('anonymous@example.com'), findsOneWidget);
      });

      testWidgets('shows person icon when no photo url', (tester) async {
        when(() => mockUserRepository.getTeammateStats(testUserId, testPartnerId))
            .thenAnswer((_) async => testStats);
        when(() => mockUserRepository.getUserById(testPartnerId))
            .thenAnswer((_) async => testPartner);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.person), findsOneWidget);
      });
    });

    group('Loaded State - Record Card', () {
      testWidgets('shows Overall Record title', (tester) async {
        when(() => mockUserRepository.getTeammateStats(testUserId, testPartnerId))
            .thenAnswer((_) async => testStats);
        when(() => mockUserRepository.getUserById(testPartnerId))
            .thenAnswer((_) async => testPartner);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Overall Record'), findsOneWidget);
      });

      testWidgets('shows games played count', (tester) async {
        when(() => mockUserRepository.getTeammateStats(testUserId, testPartnerId))
            .thenAnswer((_) async => testStats);
        when(() => mockUserRepository.getUserById(testPartnerId))
            .thenAnswer((_) async => testPartner);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('20'), findsOneWidget);
        expect(find.text('Games'), findsOneWidget);
      });

      testWidgets('shows win rate percentage', (tester) async {
        when(() => mockUserRepository.getTeammateStats(testUserId, testPartnerId))
            .thenAnswer((_) async => testStats);
        when(() => mockUserRepository.getUserById(testPartnerId))
            .thenAnswer((_) async => testPartner);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // 15/20 = 75%
        expect(find.text('75.0%'), findsOneWidget);
        expect(find.text('Win Rate'), findsOneWidget);
      });

      testWidgets('shows win-loss record string', (tester) async {
        when(() => mockUserRepository.getTeammateStats(testUserId, testPartnerId))
            .thenAnswer((_) async => testStats);
        when(() => mockUserRepository.getUserById(testPartnerId))
            .thenAnswer((_) async => testPartner);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('15W - 5L'), findsOneWidget);
        expect(find.text('Record'), findsOneWidget);
      });
    });

    group('Loaded State - Point Differential Card', () {
      testWidgets('shows Point Differential title', (tester) async {
        when(() => mockUserRepository.getTeammateStats(testUserId, testPartnerId))
            .thenAnswer((_) async => testStats);
        when(() => mockUserRepository.getUserById(testPartnerId))
            .thenAnswer((_) async => testPartner);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Point Differential'), findsOneWidget);
      });

      testWidgets('shows average point differential', (tester) async {
        when(() => mockUserRepository.getTeammateStats(testUserId, testPartnerId))
            .thenAnswer((_) async => testStats);
        when(() => mockUserRepository.getUserById(testPartnerId))
            .thenAnswer((_) async => testPartner);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // avgPointsScored = 400/20 = 20, avgPointsAllowed = 300/20 = 15
        // Avg diff = 20 - 15 = 5
        expect(find.text('+5.0'), findsOneWidget);
        // 'Avg Per Game' appears in both Point Differential and ELO cards
        expect(find.text('Avg Per Game'), findsNWidgets(2));
      });

      testWidgets('shows points scored average', (tester) async {
        when(() => mockUserRepository.getTeammateStats(testUserId, testPartnerId))
            .thenAnswer((_) async => testStats);
        when(() => mockUserRepository.getUserById(testPartnerId))
            .thenAnswer((_) async => testPartner);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // 400/20 = 20.0
        expect(find.text('20.0'), findsOneWidget);
        expect(find.text('Points For'), findsOneWidget);
      });

      testWidgets('shows points allowed average', (tester) async {
        when(() => mockUserRepository.getTeammateStats(testUserId, testPartnerId))
            .thenAnswer((_) async => testStats);
        when(() => mockUserRepository.getUserById(testPartnerId))
            .thenAnswer((_) async => testPartner);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // 300/20 = 15.0
        expect(find.text('15.0'), findsOneWidget);
        expect(find.text('Points Against'), findsOneWidget);
      });
    });

    group('Loaded State - ELO Card', () {
      testWidgets('shows ELO Performance title', (tester) async {
        when(() => mockUserRepository.getTeammateStats(testUserId, testPartnerId))
            .thenAnswer((_) async => testStats);
        when(() => mockUserRepository.getUserById(testPartnerId))
            .thenAnswer((_) async => testPartner);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('ELO Performance'), findsOneWidget);
      });

      testWidgets('shows total ELO change', (tester) async {
        when(() => mockUserRepository.getTeammateStats(testUserId, testPartnerId))
            .thenAnswer((_) async => testStats);
        when(() => mockUserRepository.getUserById(testPartnerId))
            .thenAnswer((_) async => testPartner);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('+60.0'), findsOneWidget);
        expect(find.text('Total Change'), findsOneWidget);
      });

      testWidgets('shows average ELO change per game', (tester) async {
        when(() => mockUserRepository.getTeammateStats(testUserId, testPartnerId))
            .thenAnswer((_) async => testStats);
        when(() => mockUserRepository.getUserById(testPartnerId))
            .thenAnswer((_) async => testPartner);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // 60/20 = 3.0
        expect(find.text('+3.0'), findsOneWidget);
        // 'Avg Per Game' appears twice (once in Point Differential, once in ELO)
        expect(find.text('Avg Per Game'), findsNWidgets(2));
      });
    });

    group('Loaded State - Recent Form', () {
      testWidgets('shows Recent Form title', (tester) async {
        when(() => mockUserRepository.getTeammateStats(testUserId, testPartnerId))
            .thenAnswer((_) async => testStats);
        when(() => mockUserRepository.getUserById(testPartnerId))
            .thenAnswer((_) async => testPartner);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Recent Form'), findsOneWidget);
      });

      testWidgets('shows current streak badge when on winning streak',
          (tester) async {
        when(() => mockUserRepository.getTeammateStats(testUserId, testPartnerId))
            .thenAnswer((_) async => testStats);
        when(() => mockUserRepository.getUserById(testPartnerId))
            .thenAnswer((_) async => testPartner);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // First game is W, so streak = 1 W Streak
        expect(find.text('1 W Streak'), findsOneWidget);
      });

      testWidgets('shows game score displays', (tester) async {
        when(() => mockUserRepository.getTeammateStats(testUserId, testPartnerId))
            .thenAnswer((_) async => testStats);
        when(() => mockUserRepository.getUserById(testPartnerId))
            .thenAnswer((_) async => testPartner);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify score displays from games
        expect(find.text('21-15'), findsOneWidget);
        expect(find.text('18-21'), findsOneWidget);
        expect(find.text('21-19'), findsOneWidget);
      });

      testWidgets('shows W and L result letters', (tester) async {
        when(() => mockUserRepository.getTeammateStats(testUserId, testPartnerId))
            .thenAnswer((_) async => testStats);
        when(() => mockUserRepository.getUserById(testPartnerId))
            .thenAnswer((_) async => testPartner);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // 2 wins and 1 loss in recent games
        expect(find.text('W'), findsNWidgets(2));
        expect(find.text('L'), findsOneWidget);
      });

      testWidgets('shows ELO change for each game', (tester) async {
        when(() => mockUserRepository.getTeammateStats(testUserId, testPartnerId))
            .thenAnswer((_) async => testStats);
        when(() => mockUserRepository.getUserById(testPartnerId))
            .thenAnswer((_) async => testPartner);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('ELO: +18.5'), findsOneWidget);
        expect(find.text('ELO: -12.0'), findsOneWidget);
        expect(find.text('ELO: +10.0'), findsOneWidget);
      });

      testWidgets('shows empty state when no recent games', (tester) async {
        when(() => mockUserRepository.getTeammateStats(testUserId, testPartnerId))
            .thenAnswer((_) async => testStatsNoGames);
        when(() => mockUserRepository.getUserById(testPartnerId))
            .thenAnswer((_) async => testPartner);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('No recent games'), findsOneWidget);
      });
    });

    group('Loaded State - Losing Streak', () {
      testWidgets('shows losing streak badge when on losing streak',
          (tester) async {
        final losingStats = TeammateStats(
          userId: testPartnerId,
          gamesPlayed: 10,
          gamesWon: 4,
          gamesLost: 6,
          pointsScored: 180,
          pointsAllowed: 200,
          eloChange: -15.0,
          recentGames: [
            RecentGameResult(
              gameId: 'game-1',
              won: false,
              pointsScored: 15,
              pointsAllowed: 21,
              eloChange: -10.0,
              timestamp: DateTime(2024, 1, 15),
            ),
            RecentGameResult(
              gameId: 'game-2',
              won: false,
              pointsScored: 18,
              pointsAllowed: 21,
              eloChange: -8.0,
              timestamp: DateTime(2024, 1, 10),
            ),
            RecentGameResult(
              gameId: 'game-3',
              won: false,
              pointsScored: 19,
              pointsAllowed: 21,
              eloChange: -5.0,
              timestamp: DateTime(2024, 1, 5),
            ),
          ],
        );

        when(() => mockUserRepository.getTeammateStats(testUserId, testPartnerId))
            .thenAnswer((_) async => losingStats);
        when(() => mockUserRepository.getUserById(testPartnerId))
            .thenAnswer((_) async => testPartner);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('3 L Streak'), findsOneWidget);
      });
    });

    group('Negative Stats Display', () {
      testWidgets('shows negative ELO change correctly', (tester) async {
        final negativeStats = TeammateStats(
          userId: testPartnerId,
          gamesPlayed: 10,
          gamesWon: 3,
          gamesLost: 7,
          pointsScored: 150,
          pointsAllowed: 200,
          eloChange: -30.0,
          recentGames: [],
        );

        when(() => mockUserRepository.getTeammateStats(testUserId, testPartnerId))
            .thenAnswer((_) async => negativeStats);
        when(() => mockUserRepository.getUserById(testPartnerId))
            .thenAnswer((_) async => testPartner);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('-30.0'), findsOneWidget);
      });

      testWidgets('shows negative point differential correctly',
          (tester) async {
        final negativeStats = TeammateStats(
          userId: testPartnerId,
          gamesPlayed: 10,
          gamesWon: 3,
          gamesLost: 7,
          pointsScored: 150,
          pointsAllowed: 200,
          eloChange: -30.0,
          recentGames: [],
        );

        when(() => mockUserRepository.getTeammateStats(testUserId, testPartnerId))
            .thenAnswer((_) async => negativeStats);
        when(() => mockUserRepository.getUserById(testPartnerId))
            .thenAnswer((_) async => testPartner);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // 150/10 - 200/10 = 15 - 20 = -5
        expect(find.text('-5.0'), findsOneWidget);
      });
    });
  });
}
