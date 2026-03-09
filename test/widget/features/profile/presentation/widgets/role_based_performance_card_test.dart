// Tests for RoleBasedPerformanceCard widget - validates UI rendering for role-based stats.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:play_with_me/l10n/app_localizations.dart';
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
      userWithNoData = const UserModel(
        uid: 'test-uid-1',
        email: 'test@example.com',
        displayName: 'Test User',
        isEmailVerified: true,
        isAnonymous: false,
        roleBasedStats: null,
      );

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

    Widget buildWidget(UserModel user) => MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Scaffold(body: RoleBasedPerformanceCard(user: user)),
        );

    testWidgets('displays section label', (tester) async {
      await tester.pumpWidget(buildWidget(userWithNoData));
      expect(find.text('ADAPTABILITY STATS'), findsOneWidget);
    });

    testWidgets('displays empty state when no role-based data', (tester) async {
      await tester.pumpWidget(buildWidget(userWithNoData));
      await tester.pump();

      expect(find.text('Adaptability Stats Locked'), findsOneWidget);
      expect(find.text('Play more games to see how you perform in different team roles'), findsOneWidget);
      expect(find.byIcon(Icons.analytics_outlined), findsOneWidget);
    });

    testWidgets('displays all three roles when available', (tester) async {
      await tester.pumpWidget(buildWidget(userWithAllRoles));
      await tester.pump();

      expect(find.text('Leading the Team'), findsOneWidget);
      expect(find.text('Playing with Stronger Partners'), findsOneWidget);
      expect(find.text('Balanced Teams'), findsOneWidget);
      expect(find.text('When you\'re the highest-rated player'), findsOneWidget);
      expect(find.text('When playing with more experienced teammates'), findsOneWidget);
      expect(find.text('When playing with similarly-rated teammates'), findsOneWidget);
    });

    testWidgets('displays correct stats for carry role', (tester) async {
      await tester.pumpWidget(buildWidget(userWithOnlyCarry));
      await tester.pump();

      expect(find.text('Leading the Team'), findsOneWidget);
      expect(find.text('8W - 2L (10 games)'), findsOneWidget);
      expect(find.text('80.0%'), findsOneWidget);
      expect(find.text('Playing with Stronger Partners'), findsNothing);
      expect(find.text('Balanced Teams'), findsNothing);
    });

    testWidgets('displays correct stats for weak-link role with positive framing', (tester) async {
      await tester.pumpWidget(buildWidget(userWithOnlyWeakLink));
      await tester.pump();

      expect(find.text('Playing with Stronger Partners'), findsOneWidget);
      expect(find.text('When playing with more experienced teammates'), findsOneWidget);
      expect(find.text('4W - 2L (6 games)'), findsOneWidget);
      expect(find.text('66.7%'), findsOneWidget);
      expect(find.textContaining('weak'), findsNothing);
      expect(find.textContaining('Weak'), findsNothing);
    });

    testWidgets('win rate color is blue (AppColors.secondary)', (tester) async {
      await tester.pumpWidget(buildWidget(userWithOnlyCarry));
      await tester.pump();

      final winRateText = tester.widget<Text>(find.text('80.0%'));
      expect(winRateText.style?.color, const Color(0xFF004E64));
    });

    testWidgets('low win rate also displays in blue', (tester) async {
      await tester.pumpWidget(buildWidget(userWithAllRoles));
      await tester.pump();

      final winRateText = tester.widget<Text>(find.text('40.0%'));
      expect(winRateText.style?.color, const Color(0xFF004E64));
    });

    testWidgets('displays personalized insight for strong carry performance', (tester) async {
      await tester.pumpWidget(buildWidget(userWithStrongCarry));
      await tester.pump();

      expect(find.text('💪 Strong carry performance! You elevate your teammates.'), findsOneWidget);
      expect(find.byIcon(Icons.lightbulb_outline), findsOneWidget);
    });

    testWidgets('displays personalized insight for good weak-link performance', (tester) async {
      await tester.pumpWidget(buildWidget(userWithOnlyWeakLink));
      await tester.pump();

      expect(find.text('🌟 Great adaptability! You thrive with experienced partners.'), findsOneWidget);
    });

    testWidgets('displays icons for each role', (tester) async {
      await tester.pumpWidget(buildWidget(userWithAllRoles));
      await tester.pump();

      expect(find.byIcon(Icons.emoji_events), findsOneWidget); // Carry
      expect(find.byIcon(Icons.people), findsOneWidget);       // Weak-link
      expect(find.byIcon(Icons.balance), findsOneWidget);      // Balanced
    });

    testWidgets('shows correct colors for each role icon', (tester) async {
      await tester.pumpWidget(buildWidget(userWithAllRoles));
      await tester.pump();

      final carryIcon = tester.widget<Icon>(find.byIcon(Icons.emoji_events));
      expect(carryIcon.color, const Color(0xFFEACE6A)); // AppColors.primary

      final weakLinkIcon = tester.widget<Icon>(find.byIcon(Icons.people));
      expect(weakLinkIcon.color, const Color(0xFF004E64)); // AppColors.secondary

      final balancedIcon = tester.widget<Icon>(find.byIcon(Icons.balance));
      expect(balancedIcon.color, const Color(0xFFEACE6A)); // AppColors.primary
    });

    testWidgets('only shows roles with games played', (tester) async {
      await tester.pumpWidget(buildWidget(userWithOnlyCarry));
      await tester.pump();

      expect(find.text('Leading the Team'), findsOneWidget);
      expect(find.text('Playing with Stronger Partners'), findsNothing);
      expect(find.text('Balanced Teams'), findsNothing);
    });

    testWidgets('displays description text', (tester) async {
      await tester.pumpWidget(buildWidget(userWithAllRoles));
      await tester.pump();

      expect(find.text('See how you perform in different team roles'), findsOneWidget);
    });
  });
}
