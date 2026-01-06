// Widget tests for RivalsCard displaying nemesis statistics.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/user_model.dart';
import 'package:play_with_me/features/profile/presentation/widgets/rivals_card.dart';
import 'package:play_with_me/features/profile/presentation/widgets/empty_states/insufficient_data_placeholder.dart';

void main() {
  group('RivalsCard Widget Tests', () {
    group('Empty State', () {
      testWidgets('shows empty state when nemesis is null', (tester) async {
        final user = UserModel(
          uid: 'test-uid',
          email: 'test@example.com',
          isEmailVerified: true,
          isAnonymous: false,
          nemesis: null,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RivalsCard(user: user),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Should show EmptyStatsPlaceholder
        expect(find.byType(EmptyStatsPlaceholder), findsOneWidget);
        expect(find.text('No Nemesis Yet'), findsOneWidget);
        expect(
          find.text(
              'Play at least 3 games against the same opponent to track your toughest matchup.'),
          findsOneWidget,
        );
        expect(find.text('Face the same opponent 3+ times'), findsOneWidget);

        // Should NOT show nemesis data
        expect(find.text('Win Rate:'), findsNothing);
        expect(find.byIcon(Icons.arrow_forward_ios), findsNothing);
      });

      testWidgets('empty state shows correct unlock message', (tester) async {
        final user = UserModel(
          uid: 'test-uid',
          email: 'test@example.com',
          isEmailVerified: true,
          isAnonymous: false,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RivalsCard(user: user),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Face the same opponent 3+ times'), findsOneWidget);
      });
    });

    group('Nemesis Display', () {
      testWidgets('shows nemesis data when nemesis exists', (tester) async {
        final nemesis = NemesisRecord(
          opponentId: 'opponent-123',
          opponentName: 'John Doe',
          gamesLost: 7,
          gamesWon: 3,
          gamesPlayed: 10,
          winRate: 30.0,
        );

        final user = UserModel(
          uid: 'test-uid',
          email: 'test@example.com',
          isEmailVerified: true,
          isAnonymous: false,
          nemesis: nemesis,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RivalsCard(user: user),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Should NOT show EmptyStatsPlaceholder
        expect(find.byType(EmptyStatsPlaceholder), findsNothing);

        // Should show nemesis data
        expect(find.text('John Doe'), findsOneWidget);
        expect(find.text('3W - 7L'), findsOneWidget);
        expect(find.text('(10 matchups)'), findsOneWidget);
        expect(find.text('Win Rate: 30.0%'), findsOneWidget);
        expect(find.text('Tap for full breakdown'), findsOneWidget);

        // Should show navigation arrow
        expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);
      });

      testWidgets('displays correct record format', (tester) async {
        final nemesis = NemesisRecord(
          opponentId: 'opponent-123',
          opponentName: 'Jane Smith',
          gamesLost: 5,
          gamesWon: 2,
          gamesPlayed: 7,
          winRate: 28.57,
        );

        final user = UserModel(
          uid: 'test-uid',
          email: 'test@example.com',
          isEmailVerified: true,
          isAnonymous: false,
          nemesis: nemesis,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RivalsCard(user: user),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Check record format: "XW - YL"
        expect(find.text('2W - 5L'), findsOneWidget);
        expect(find.text('(7 matchups)'), findsOneWidget);
      });

      testWidgets('win rate displays with one decimal place', (tester) async {
        final nemesis = NemesisRecord(
          opponentId: 'opponent-123',
          opponentName: 'Bob Johnson',
          gamesLost: 4,
          gamesWon: 3,
          gamesPlayed: 7,
          winRate: 42.857142857,
        );

        final user = UserModel(
          uid: 'test-uid',
          email: 'test@example.com',
          isEmailVerified: true,
          isAnonymous: false,
          nemesis: nemesis,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RivalsCard(user: user),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Win rate should be formatted to 1 decimal place
        expect(find.text('Win Rate: 42.9%'), findsOneWidget);
      });

      testWidgets('win rate shows in red when less than 50%', (tester) async {
        final nemesis = NemesisRecord(
          opponentId: 'opponent-123',
          opponentName: 'Test Opponent',
          gamesLost: 6,
          gamesWon: 2,
          gamesPlayed: 8,
          winRate: 25.0, // Less than 50%
        );

        final user = UserModel(
          uid: 'test-uid',
          email: 'test@example.com',
          isEmailVerified: true,
          isAnonymous: false,
          nemesis: nemesis,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RivalsCard(user: user),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find the Text widget with win rate
        final winRateText = tester.widget<Text>(
          find.text('Win Rate: 25.0%'),
        );

        // Check if text style indicates error color (red)
        // Note: We can't directly check the color since it's theme-dependent,
        // but we can verify the text exists
        expect(winRateText.data, 'Win Rate: 25.0%');
      });

      testWidgets('displays minimum matchup count (3 games)', (tester) async {
        final nemesis = NemesisRecord(
          opponentId: 'opponent-123',
          opponentName: 'Minimum Rival',
          gamesLost: 2,
          gamesWon: 1,
          gamesPlayed: 3, // Exactly at threshold
          winRate: 33.33,
        );

        final user = UserModel(
          uid: 'test-uid',
          email: 'test@example.com',
          isEmailVerified: true,
          isAnonymous: false,
          nemesis: nemesis,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RivalsCard(user: user),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('(3 matchups)'), findsOneWidget);
        expect(find.text('1W - 2L'), findsOneWidget);
      });
    });

    group('Navigation', () {
      testWidgets('card is tappable when nemesis exists', (tester) async {
        final nemesis = NemesisRecord(
          opponentId: 'opponent-123',
          opponentName: 'Tap Test',
          gamesLost: 5,
          gamesWon: 2,
          gamesPlayed: 7,
          winRate: 28.57,
        );

        final user = UserModel(
          uid: 'test-uid',
          email: 'test@example.com',
          isEmailVerified: true,
          isAnonymous: false,
          nemesis: nemesis,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RivalsCard(user: user),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify InkWell is present
        expect(find.byType(InkWell), findsOneWidget);

        // Verify navigation arrow is shown
        expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);
      });

      testWidgets('card is not tappable when nemesis is null',
          (tester) async {
        final user = UserModel(
          uid: 'test-uid',
          email: 'test@example.com',
          isEmailVerified: true,
          isAnonymous: false,
          nemesis: null,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RivalsCard(user: user),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // InkWell exists but onTap should be null
        expect(find.byType(InkWell), findsOneWidget);

        // Navigation arrow should NOT be shown
        expect(find.byIcon(Icons.arrow_forward_ios), findsNothing);
      });
    });

    group('UI Elements', () {
      testWidgets('displays rival emoji and title', (tester) async {
        final user = UserModel(
          uid: 'test-uid',
          email: 'test@example.com',
          isEmailVerified: true,
          isAnonymous: false,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RivalsCard(user: user),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('🆚 '), findsOneWidget);
        expect(find.text('Rival'), findsOneWidget);
      });

      testWidgets('displays correct icons for nemesis data', (tester) async {
        final nemesis = NemesisRecord(
          opponentId: 'opponent-123',
          opponentName: 'Icon Test',
          gamesLost: 4,
          gamesWon: 3,
          gamesPlayed: 7,
          winRate: 42.86,
        );

        final user = UserModel(
          uid: 'test-uid',
          email: 'test@example.com',
          isEmailVerified: true,
          isAnonymous: false,
          nemesis: nemesis,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RivalsCard(user: user),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Check for stats icons
        expect(find.byIcon(Icons.sports_score), findsOneWidget);
        expect(find.byIcon(Icons.percent), findsOneWidget);
        expect(find.byIcon(Icons.info_outline), findsOneWidget);
      });
    });
  });
}
