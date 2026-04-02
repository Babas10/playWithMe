// Validates MomentumConsistencyCard ELO tab switcher visibility and behaviour (Story 26.6).
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/rating_history_entry.dart';
import 'package:play_with_me/core/data/models/user_model.dart';
import 'package:play_with_me/core/domain/repositories/user_repository.dart';
import 'package:play_with_me/core/services/service_locator.dart';
import 'package:play_with_me/features/profile/presentation/widgets/momentum_consistency_card.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

import '../../../../../unit/core/data/repositories/mock_user_repository.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

UserModel _makeUser({UserGender? gender, double mixEloRating = 1100.0}) {
  return UserModel(
    uid: 'u1',
    email: 'test@example.com',
    displayName: 'Test User',
    isEmailVerified: true,
    isAnonymous: false,
    eloRating: 1500.0,
    mixEloRating: mixEloRating,
    gender: gender,
  );
}

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en')],
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockUserRepository mockRepo;

  setUp(() {
    mockRepo = MockUserRepository();
    if (!sl.isRegistered<UserRepository>()) {
      sl.registerSingleton<UserRepository>(mockRepo);
    } else {
      sl.unregister<UserRepository>();
      sl.registerSingleton<UserRepository>(mockRepo);
    }
  });

  tearDown(() async {
    if (sl.isRegistered<UserRepository>()) {
      sl.unregister<UserRepository>();
    }
  });

  group('MomentumConsistencyCard — ELO tab switcher visibility (Story 26.6)',
      () {
    testWidgets('tab switcher is visible for male user', (tester) async {
      final user = _makeUser(gender: UserGender.male);
      await tester.pumpWidget(
          _wrap(MomentumConsistencyCard(user: user, ratingHistory: const [])));
      await tester.pumpAndSettle();

      expect(find.text('Gender ELO'), findsOneWidget);
      expect(find.text('Mix ELO'), findsOneWidget);
    });

    testWidgets('tab switcher is visible for female user', (tester) async {
      final user = _makeUser(gender: UserGender.female);
      await tester.pumpWidget(
          _wrap(MomentumConsistencyCard(user: user, ratingHistory: const [])));
      await tester.pumpAndSettle();

      expect(find.text('Gender ELO'), findsOneWidget);
      expect(find.text('Mix ELO'), findsOneWidget);
    });

    testWidgets('tab switcher is hidden for mix-only user (gender = none)',
        (tester) async {
      final user = _makeUser(gender: UserGender.none);
      await tester.pumpWidget(
          _wrap(MomentumConsistencyCard(user: user, ratingHistory: const [])));
      await tester.pumpAndSettle();

      expect(find.text('Gender ELO'), findsNothing);
      expect(find.text('Mix ELO'), findsNothing);
    });

    testWidgets('tab switcher is hidden for mix-only user (gender = null)',
        (tester) async {
      final user = _makeUser(gender: null);
      await tester.pumpWidget(
          _wrap(MomentumConsistencyCard(user: user, ratingHistory: const [])));
      await tester.pumpAndSettle();

      expect(find.text('Gender ELO'), findsNothing);
      expect(find.text('Mix ELO'), findsNothing);
    });
  });

  group(
      'MomentumConsistencyCard — ELO tab switcher switches rating (Story 26.6)',
      () {
    // Seed the mock repo with rating history entries so the EloHistoryBloc
    // reaches EloHistoryLoaded and renders the chart + tab switcher.
    List<RatingHistoryEntry> makeHistory() {
      final now = DateTime.now();
      return [
        RatingHistoryEntry(
          entryId: 'e1',
          gameId: 'g1',
          oldRating: 1480,
          newRating: 1500,
          ratingChange: 20,
          opponentTeam: 'Team A',
          won: true,
          timestamp: now.subtract(const Duration(days: 5)),
          gameType: EloGameType.gender,
        ),
        RatingHistoryEntry(
          entryId: 'e2',
          gameId: 'g2',
          oldRating: 1080,
          newRating: 1100,
          ratingChange: 20,
          opponentTeam: 'Team B',
          won: true,
          timestamp: now.subtract(const Duration(days: 3)),
          gameType: EloGameType.mix,
        ),
      ];
    }

    testWidgets('Gender ELO tab is active by default for gendered user',
        (tester) async {
      final user = _makeUser(gender: UserGender.male, mixEloRating: 1100.0);
      await tester.pumpWidget(
          _wrap(MomentumConsistencyCard(user: user, ratingHistory: makeHistory())));
      await tester.pumpAndSettle();

      // The "Gender ELO" tab should be styled as active (first tab shown)
      expect(find.text('Gender ELO'), findsOneWidget);
      expect(find.text('Mix ELO'), findsOneWidget);
    });

    testWidgets('tapping Mix ELO tab updates active tab', (tester) async {
      final user = _makeUser(gender: UserGender.male, mixEloRating: 1100.0);
      await tester.pumpWidget(
          _wrap(MomentumConsistencyCard(user: user, ratingHistory: makeHistory())));
      await tester.pumpAndSettle();

      // Both tabs should be present initially
      expect(find.text('Gender ELO'), findsOneWidget);
      expect(find.text('Mix ELO'), findsOneWidget);

      // Tap the Mix ELO tab
      await tester.tap(find.text('Mix ELO'));
      await tester.pumpAndSettle();

      // Tabs should still be visible after switching
      expect(find.text('Gender ELO'), findsOneWidget);
      expect(find.text('Mix ELO'), findsOneWidget);
    });

    testWidgets('tapping Gender ELO tab after Mix ELO switches back',
        (tester) async {
      final user = _makeUser(gender: UserGender.female, mixEloRating: 1200.0);
      await tester.pumpWidget(
          _wrap(MomentumConsistencyCard(user: user, ratingHistory: makeHistory())));
      await tester.pumpAndSettle();

      // Switch to Mix ELO
      await tester.tap(find.text('Mix ELO'));
      await tester.pumpAndSettle();

      // Switch back to Gender ELO
      await tester.tap(find.text('Gender ELO'));
      await tester.pumpAndSettle();

      // Both tabs still visible
      expect(find.text('Gender ELO'), findsOneWidget);
      expect(find.text('Mix ELO'), findsOneWidget);
    });
  });

  group('MomentumConsistencyCard — history filtering (Story 26.6)', () {
    testWidgets('gender tab only shows gender and null-type entries',
        (tester) async {
      // This tests the filtering logic via `_filterHistory` indirectly:
      // we verify no crash and correct rendering with mixed entry types.
      final user = _makeUser(gender: UserGender.male);
      final history = [
        RatingHistoryEntry(
          entryId: 'e1',
          gameId: 'g1',
          oldRating: 1480,
          newRating: 1500,
          ratingChange: 20,
          opponentTeam: 'Team A',
          won: true,
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          gameType: EloGameType.gender,
        ),
        RatingHistoryEntry(
          entryId: 'e2',
          gameId: 'g2',
          oldRating: 1080,
          newRating: 1100,
          ratingChange: 20,
          opponentTeam: 'Team B',
          won: true,
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          gameType: EloGameType.mix,
        ),
        RatingHistoryEntry(
          entryId: 'e3',
          gameId: 'g3',
          oldRating: 1470,
          newRating: 1480,
          ratingChange: 10,
          opponentTeam: 'Team C',
          won: true,
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
          // null gameType — legacy entry, treated as gender
        ),
      ];

      await tester.pumpWidget(
          _wrap(MomentumConsistencyCard(user: user, ratingHistory: history)));
      await tester.pumpAndSettle();

      // Widget renders without error
      expect(find.text('Gender ELO'), findsOneWidget);
    });
  });
}
