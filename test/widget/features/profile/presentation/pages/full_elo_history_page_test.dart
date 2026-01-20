// Widget tests for FullEloHistoryPage verifying UI rendering and state transitions.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/data/models/rating_history_entry.dart';
import 'package:play_with_me/core/domain/repositories/user_repository.dart';
import 'package:play_with_me/features/profile/presentation/pages/full_elo_history_page.dart';
import 'package:play_with_me/features/profile/presentation/widgets/best_elo_highlight_card.dart';
import 'package:play_with_me/features/profile/presentation/widgets/time_period_selector.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockUserRepository mockUserRepository;

  const testUserId = 'test-user-123';

  // Sample test data
  final testHistoryEntry1 = RatingHistoryEntry(
    entryId: 'entry-1',
    gameId: 'game-1',
    oldRating: 1600.0,
    newRating: 1620.0,
    ratingChange: 20.0,
    opponentTeam: 'Alice & Bob',
    won: true,
    timestamp: DateTime(2024, 1, 15),
  );

  final testHistoryEntry2 = RatingHistoryEntry(
    entryId: 'entry-2',
    gameId: 'game-2',
    oldRating: 1620.0,
    newRating: 1605.0,
    ratingChange: -15.0,
    opponentTeam: 'Charlie & Diana',
    won: false,
    timestamp: DateTime(2024, 1, 10),
  );

  final testHistoryEntry3 = RatingHistoryEntry(
    entryId: 'entry-3',
    gameId: 'game-3',
    oldRating: 1580.0,
    newRating: 1600.0,
    ratingChange: 20.0,
    opponentTeam: 'Eve & Frank',
    won: true,
    timestamp: DateTime(2024, 1, 5),
  );

  final testHistory = [testHistoryEntry1, testHistoryEntry2, testHistoryEntry3];

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
      home: FullEloHistoryPage(userId: testUserId),
    );
  }

  group('FullEloHistoryPage Widget Tests', () {
    group('Initial UI Rendering', () {
      testWidgets('renders app bar with ELO History title', (tester) async {
        when(() => mockUserRepository.getRatingHistory(testUserId, limit: 100))
            .thenAnswer((_) => Stream.value(testHistory));

        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byType(AppBar), findsOneWidget);
        expect(find.text('ELO History'), findsOneWidget);
      });

      testWidgets('renders filter icon in app bar when loaded', (tester) async {
        when(() => mockUserRepository.getRatingHistory(testUserId, limit: 100))
            .thenAnswer((_) => Stream.value(testHistory));

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.filter_alt), findsOneWidget);
      });
    });

    group('Error State', () {
      testWidgets('shows error message when error state', (tester) async {
        when(() => mockUserRepository.getRatingHistory(testUserId, limit: 100))
            .thenAnswer((_) => Stream.error('Failed to load ELO history'));

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.textContaining('Failed to load ELO history'), findsOneWidget);
      });

      testWidgets('error icon has red color', (tester) async {
        when(() => mockUserRepository.getRatingHistory(testUserId, limit: 100))
            .thenAnswer((_) => Stream.error('Network error'));

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        final icon = tester.widget<Icon>(find.byIcon(Icons.error_outline));
        expect(icon.color, Colors.red);
      });
    });

    group('Empty State', () {
      testWidgets('shows empty state when no history', (tester) async {
        when(() => mockUserRepository.getRatingHistory(testUserId, limit: 100))
            .thenAnswer((_) => Stream.value([]));

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.timeline), findsOneWidget);
        expect(find.text('No ELO history yet'), findsOneWidget);
        expect(find.text('Play some games to see your rating history'),
            findsOneWidget);
      });
    });

    group('Loaded State - Stats Summary', () {
      testWidgets('shows games count in stats summary', (tester) async {
        when(() => mockUserRepository.getRatingHistory(testUserId, limit: 100))
            .thenAnswer((_) => Stream.value(testHistory));

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // 3 games in history
        expect(find.text('3'), findsOneWidget);
        expect(find.text('Games'), findsOneWidget);
      });

      testWidgets('shows win-loss record', (tester) async {
        when(() => mockUserRepository.getRatingHistory(testUserId, limit: 100))
            .thenAnswer((_) => Stream.value(testHistory));

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // 2 wins, 1 loss
        expect(find.text('2-1'), findsOneWidget);
        expect(find.text('W-L'), findsOneWidget);
      });

      testWidgets('shows total rating change', (tester) async {
        when(() => mockUserRepository.getRatingHistory(testUserId, limit: 100))
            .thenAnswer((_) => Stream.value(testHistory));

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Total change: 1620 (newRating of first) - 1580 (oldRating of last) = +40
        expect(find.text('+40'), findsOneWidget);
        expect(find.text('Total'), findsOneWidget);
      });

      testWidgets('shows average rating change', (tester) async {
        when(() => mockUserRepository.getRatingHistory(testUserId, limit: 100))
            .thenAnswer((_) => Stream.value(testHistory));

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Avg = 40 / 3 = 13.3
        expect(find.text('+13.3'), findsOneWidget);
        expect(find.text('Avg'), findsOneWidget);
      });
    });

    group('Loaded State - Time Period Selector', () {
      testWidgets('renders time period selector', (tester) async {
        when(() => mockUserRepository.getRatingHistory(testUserId, limit: 100))
            .thenAnswer((_) => Stream.value(testHistory));

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(TimePeriodSelector), findsOneWidget);
      });
    });

    group('Loaded State - Best ELO Card', () {
      testWidgets('renders best ELO highlight card', (tester) async {
        when(() => mockUserRepository.getRatingHistory(testUserId, limit: 100))
            .thenAnswer((_) => Stream.value(testHistory));

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(BestEloHighlightCard), findsOneWidget);
      });
    });

    group('Loaded State - History List', () {
      testWidgets('renders history entries', (tester) async {
        when(() => mockUserRepository.getRatingHistory(testUserId, limit: 100))
            .thenAnswer((_) => Stream.value(testHistory));

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify opponent names are displayed
        expect(find.text('vs Alice & Bob'), findsOneWidget);
        expect(find.text('vs Charlie & Diana'), findsOneWidget);
        expect(find.text('vs Eve & Frank'), findsOneWidget);
      });

      testWidgets('shows W for wins and L for losses', (tester) async {
        when(() => mockUserRepository.getRatingHistory(testUserId, limit: 100))
            .thenAnswer((_) => Stream.value(testHistory));

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // 2 wins and 1 loss
        expect(find.text('W'), findsNWidgets(2));
        expect(find.text('L'), findsOneWidget);
      });

      testWidgets('shows rating change for each entry', (tester) async {
        when(() => mockUserRepository.getRatingHistory(testUserId, limit: 100))
            .thenAnswer((_) => Stream.value(testHistory));

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify formatted changes are displayed
        expect(find.text('+20.0'), findsNWidgets(2)); // Two +20 entries
        expect(find.text('-15.0'), findsOneWidget);
      });

      testWidgets('shows trending up icon for gains', (tester) async {
        when(() => mockUserRepository.getRatingHistory(testUserId, limit: 100))
            .thenAnswer((_) => Stream.value(testHistory));

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.trending_up), findsNWidgets(2));
      });

      testWidgets('shows trending down icon for losses', (tester) async {
        when(() => mockUserRepository.getRatingHistory(testUserId, limit: 100))
            .thenAnswer((_) => Stream.value(testHistory));

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.trending_down), findsOneWidget);
      });
    });

    group('Time Period Filter', () {
      testWidgets('time period selector displays all period options',
          (tester) async {
        when(() => mockUserRepository.getRatingHistory(testUserId, limit: 100))
            .thenAnswer((_) => Stream.value(testHistory));

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // The time period selector should display all period options
        expect(find.text('30d'), findsOneWidget);
        expect(find.text('90d'), findsOneWidget);
        expect(find.text('1y'), findsOneWidget);
        expect(find.text('All Time'), findsOneWidget);
      });
    });
  });
}
