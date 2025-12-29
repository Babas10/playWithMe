// Tests for RoleBasedPerformanceCard widget - validates UI rendering and interaction for role-based stats.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/user_model.dart';
import 'package:play_with_me/features/profile/presentation/widgets/role_based_performance_card.dart';

void main() {
  group('RoleBasedPerformanceCard Widget Tests', () {
    late UserModel userWithNoData;
    late UserModel userWithAllRoles;
    late UserModel userWithOnlyCarry;
    late UserModel userWithOnlyWeakLink;
    late UserModel userWithStrongCarry;

    setUp(() {
      // User with no role-based stats
      userWithNoData = const UserModel(
        uid: 'test-uid-1',
        email: 'test@example.com',
        displayName: 'Test User',
        isEmailVerified: true,
        isAnonymous: false,
        roleBasedStats: null,
      );

      // User with stats in all roles
      userWithAllRoles = const UserModel(
        uid: 'test-uid-2',
        email: 'test2@example.com',
        displayName: 'All Roles User',
        isEmailVerified: true,
        isAnonymous: false,
        roleBasedStats: RoleBasedStats(
          weakLink: RoleStats(games: 5, wins: 2, winRate: 0.4),
          carry: RoleStats(games: 8, wins: 6, winRate: 0.75),
          balanced: RoleStats(games: 10, wins: 7, winRate: 0.7),
        ),
      );

      // User with only carry stats
      userWithOnlyCarry = const UserModel(
        uid: 'test-uid-3',
        email: 'test3@example.com',
        displayName: 'Carry User',
        isEmailVerified: true,
        isAnonymous: false,
        roleBasedStats: RoleBasedStats(
          carry: RoleStats(games: 10, wins: 8, winRate: 0.8),
        ),
      );

      // User with only weak-link stats
      userWithOnlyWeakLink = const UserModel(
        uid: 'test-uid-4',
        email: 'test4@example.com',
        displayName: 'WeakLink User',
        isEmailVerified: true,
        isAnonymous: false,
        roleBasedStats: RoleBasedStats(
          weakLink: RoleStats(games: 6, wins: 4, winRate: 0.667),
        ),
      );

      // User with strong carry performance (triggers specific insight)
      userWithStrongCarry = const UserModel(
        uid: 'test-uid-5',
        email: 'test5@example.com',
        displayName: 'Strong Carry',
        isEmailVerified: true,
        isAnonymous: false,
        roleBasedStats: RoleBasedStats(
          carry: RoleStats(games: 15, wins: 12, winRate: 0.8),
        ),
      );
    });

    testWidgets('displays empty state when no role-based data', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoleBasedPerformanceCard(user: userWithNoData),
          ),
        ),
      );

      // Verify card is collapsed by default
      expect(find.text('Adaptability Stats'), findsOneWidget);
      expect(find.text('Advanced'), findsOneWidget);
      expect(find.byIcon(Icons.expand_more), findsOneWidget);

      // Expand the card
      await tester.tap(find.text('Adaptability Stats'));
      await tester.pumpAndSettle();

      // Verify empty state is shown
      expect(find.text('Adaptability Stats Locked'), findsOneWidget);
      expect(find.text('Play more games to see how you perform in different team roles'), findsOneWidget);
      expect(find.byIcon(Icons.analytics_outlined), findsOneWidget);
    });

    testWidgets('card is collapsed by default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoleBasedPerformanceCard(user: userWithAllRoles),
          ),
        ),
      );

      // Verify card is collapsed
      expect(find.byIcon(Icons.expand_more), findsOneWidget);
      expect(find.text('Leading the Team'), findsNothing);
    });

    testWidgets('expands and collapses when tapped', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoleBasedPerformanceCard(user: userWithAllRoles),
          ),
        ),
      );

      // Initially collapsed
      expect(find.byIcon(Icons.expand_more), findsOneWidget);
      expect(find.byIcon(Icons.expand_less), findsNothing);

      // Tap to expand
      await tester.tap(find.text('Adaptability Stats'));
      await tester.pumpAndSettle();

      // Verify expanded
      expect(find.byIcon(Icons.expand_less), findsOneWidget);
      expect(find.byIcon(Icons.expand_more), findsNothing);
      expect(find.text('Leading the Team'), findsOneWidget);

      // Tap to collapse
      await tester.tap(find.text('Adaptability Stats'));
      await tester.pumpAndSettle();

      // Verify collapsed again
      expect(find.byIcon(Icons.expand_more), findsOneWidget);
      expect(find.text('Leading the Team'), findsNothing);
    });

    testWidgets('displays all three roles when available', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoleBasedPerformanceCard(user: userWithAllRoles),
          ),
        ),
      );

      // Expand card
      await tester.tap(find.text('Adaptability Stats'));
      await tester.pumpAndSettle();

      // Verify all role sections are shown
      expect(find.text('Leading the Team'), findsOneWidget);
      expect(find.text('Playing with Stronger Partners'), findsOneWidget);
      expect(find.text('Balanced Teams'), findsOneWidget);

      // Verify descriptions
      expect(find.text('When you\'re the highest-rated player'), findsOneWidget);
      expect(find.text('When playing with more experienced teammates'), findsOneWidget);
      expect(find.text('When playing with similarly-rated teammates'), findsOneWidget);
    });

    testWidgets('displays correct stats for carry role', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoleBasedPerformanceCard(user: userWithOnlyCarry),
          ),
        ),
      );

      // Expand card
      await tester.tap(find.text('Adaptability Stats'));
      await tester.pumpAndSettle();

      // Verify carry stats are displayed
      expect(find.text('Leading the Team'), findsOneWidget);
      expect(find.text('8W - 2L (10 games)'), findsOneWidget);
      expect(find.text('80.0%'), findsOneWidget);

      // Verify other roles are not shown
      expect(find.text('Playing with Stronger Partners'), findsNothing);
      expect(find.text('Balanced Teams'), findsNothing);
    });

    testWidgets('displays correct stats for weak-link role with positive framing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoleBasedPerformanceCard(user: userWithOnlyWeakLink),
          ),
        ),
      );

      // Expand card
      await tester.tap(find.text('Adaptability Stats'));
      await tester.pumpAndSettle();

      // Verify positive framing is used (not "weak-link")
      expect(find.text('Playing with Stronger Partners'), findsOneWidget);
      expect(find.text('When playing with more experienced teammates'), findsOneWidget);

      // Verify stats
      expect(find.text('4W - 2L (6 games)'), findsOneWidget);
      expect(find.text('66.7%'), findsOneWidget);

      // Verify "weak-link" terminology is NOT used
      expect(find.textContaining('weak'), findsNothing);
      expect(find.textContaining('Weak'), findsNothing);
    });

    testWidgets('win rate displays in green when >= 50%', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoleBasedPerformanceCard(user: userWithOnlyCarry),
          ),
        ),
      );

      // Expand card
      await tester.tap(find.text('Adaptability Stats'));
      await tester.pumpAndSettle();

      // Find the win rate text widget
      final winRateText = tester.widget<Text>(find.text('80.0%'));

      // Verify it's green for good win rate
      expect(winRateText.style?.color, Colors.green);
    });

    testWidgets('win rate displays in orange when < 50%', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoleBasedPerformanceCard(user: userWithAllRoles),
          ),
        ),
      );

      // Expand card
      await tester.tap(find.text('Adaptability Stats'));
      await tester.pumpAndSettle();

      // Find weak-link win rate (40%)
      final winRateText = tester.widget<Text>(find.text('40.0%'));

      // Verify it's orange for poor win rate
      expect(winRateText.style?.color, Colors.orange);
    });

    testWidgets('displays personalized insight for strong carry performance', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoleBasedPerformanceCard(user: userWithStrongCarry),
          ),
        ),
      );

      // Expand card
      await tester.tap(find.text('Adaptability Stats'));
      await tester.pumpAndSettle();

      // Verify strong carry insight is shown
      expect(find.text('💪 Strong carry performance! You elevate your teammates.'), findsOneWidget);
      expect(find.byIcon(Icons.lightbulb_outline), findsOneWidget);
    });

    testWidgets('displays personalized insight for good weak-link performance', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoleBasedPerformanceCard(user: userWithOnlyWeakLink),
          ),
        ),
      );

      // Expand card
      await tester.tap(find.text('Adaptability Stats'));
      await tester.pumpAndSettle();

      // Verify weak-link insight is shown (66.7% win rate > 50%)
      expect(find.text('🌟 Great adaptability! You thrive with experienced partners.'), findsOneWidget);
    });

    testWidgets('displays icons for each role', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoleBasedPerformanceCard(user: userWithAllRoles),
          ),
        ),
      );

      // Expand card
      await tester.tap(find.text('Adaptability Stats'));
      await tester.pumpAndSettle();

      // Verify role icons
      expect(find.byIcon(Icons.emoji_events), findsOneWidget); // Carry
      expect(find.byIcon(Icons.people), findsOneWidget); // Weak-link
      expect(find.byIcon(Icons.balance), findsOneWidget); // Balanced
    });

    testWidgets('shows correct colors for each role', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoleBasedPerformanceCard(user: userWithAllRoles),
          ),
        ),
      );

      // Expand card
      await tester.tap(find.text('Adaptability Stats'));
      await tester.pumpAndSettle();

      // Find icon widgets and verify colors
      final carryIcon = tester.widget<Icon>(find.byIcon(Icons.emoji_events));
      expect(carryIcon.color, Colors.amber);

      final weakLinkIcon = tester.widget<Icon>(find.byIcon(Icons.people));
      expect(weakLinkIcon.color, Colors.blue);

      final balancedIcon = tester.widget<Icon>(find.byIcon(Icons.balance));
      expect(balancedIcon.color, Colors.green);
    });

    testWidgets('only shows roles with games played', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoleBasedPerformanceCard(user: userWithOnlyCarry),
          ),
        ),
      );

      // Expand card
      await tester.tap(find.text('Adaptability Stats'));
      await tester.pumpAndSettle();

      // Verify only carry is shown
      expect(find.text('Leading the Team'), findsOneWidget);
      expect(find.text('Playing with Stronger Partners'), findsNothing);
      expect(find.text('Balanced Teams'), findsNothing);
    });

    testWidgets('header shows Advanced badge', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoleBasedPerformanceCard(user: userWithAllRoles),
          ),
        ),
      );

      // Verify Advanced badge is present
      expect(find.text('Advanced'), findsOneWidget);
    });

    testWidgets('displays description text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoleBasedPerformanceCard(user: userWithAllRoles),
          ),
        ),
      );

      // Expand card
      await tester.tap(find.text('Adaptability Stats'));
      await tester.pumpAndSettle();

      // Verify description
      expect(find.text('See how you perform in different team roles'), findsOneWidget);
    });
  });
}
