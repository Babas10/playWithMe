// Widget tests for GroupBottomNavBar ensuring navigation actions work correctly
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/features/groups/presentation/widgets/group_bottom_nav_bar.dart';

void main() {
  group('GroupBottomNavBar', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: GroupBottomNavBar(
              isAdmin: true,
              onInviteTap: () {},
              onCreateGameTap: () {},
              onGamesListTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check the navigation bar widget is present
      expect(find.byType(GroupBottomNavBar), findsOneWidget);
    });

    testWidgets('calls onInviteTap when admin taps first item',
        (tester) async {
      bool inviteTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: GroupBottomNavBar(
              isAdmin: true,
              onInviteTap: () => inviteTapped = true,
              onCreateGameTap: () {},
              onGamesListTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final bottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar).first,
      );
      bottomNavBar.onTap!(0);

      expect(inviteTapped, isTrue);
    });

    testWidgets('does not call onInviteTap when non-admin taps first item',
        (tester) async {
      bool inviteTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: GroupBottomNavBar(
              isAdmin: false,
              onInviteTap: () => inviteTapped = true,
              onCreateGameTap: () {},
              onGamesListTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final bottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar).first,
      );
      bottomNavBar.onTap!(0);

      expect(inviteTapped, isFalse);
    });

    testWidgets('calls onCreateGameTap when second item is tapped',
        (tester) async {
      bool createGameTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: GroupBottomNavBar(
              isAdmin: true,
              onInviteTap: () {},
              onCreateGameTap: () => createGameTapped = true,
              onGamesListTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final bottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar).first,
      );
      bottomNavBar.onTap!(1);

      expect(createGameTapped, isTrue);
    });

    testWidgets('calls onGamesListTap when third item is tapped',
        (tester) async {
      bool gamesListTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: GroupBottomNavBar(
              isAdmin: true,
              onInviteTap: () {},
              onCreateGameTap: () {},
              onGamesListTap: () => gamesListTapped = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final bottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar).first,
      );
      bottomNavBar.onTap!(2);

      expect(gamesListTapped, isTrue);
    });

    testWidgets('renders correctly for non-admin', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: GroupBottomNavBar(
              isAdmin: false,
              onInviteTap: () {},
              onCreateGameTap: () {},
              onGamesListTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify widget is rendered
      expect(find.byType(GroupBottomNavBar), findsOneWidget);
    });

    testWidgets('has three navigation items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: GroupBottomNavBar(
              isAdmin: true,
              onInviteTap: () {},
              onCreateGameTap: () {},
              onGamesListTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final bottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar).first,
      );

      expect(bottomNavBar.items.length, 3);
    });

    testWidgets('first item has correct label and tooltip for admin',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: GroupBottomNavBar(
              isAdmin: true,
              onInviteTap: () {},
              onCreateGameTap: () {},
              onGamesListTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final bottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar).first,
      );

      expect(bottomNavBar.items[0].label, 'Invite');
      expect(bottomNavBar.items[0].tooltip, 'Invite Members');
    });

    testWidgets('first item tooltip changes for non-admin', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: GroupBottomNavBar(
              isAdmin: false,
              onInviteTap: () {},
              onCreateGameTap: () {},
              onGamesListTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final bottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar).first,
      );

      expect(bottomNavBar.items[0].tooltip, 'Admin only');
    });

    testWidgets('uses BottomNavigationBarType.fixed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: GroupBottomNavBar(
              isAdmin: true,
              onInviteTap: () {},
              onCreateGameTap: () {},
              onGamesListTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final bottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar).first,
      );

      expect(bottomNavBar.type, BottomNavigationBarType.fixed);
    });

    group('Badge Display', () {
      testWidgets('shows no badge when game count is 0', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: GroupBottomNavBar(
                isAdmin: true,
                upcomingGamesCount: 0,
                onInviteTap: () {},
                onCreateGameTap: () {},
                onGamesListTap: () {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Badge should not be visible when count is 0
        final badgeFinder = find.byType(Badge);
        expect(badgeFinder, findsOneWidget);

        final badge = tester.widget<Badge>(badgeFinder);
        expect(badge.isLabelVisible, isFalse);
      });

      testWidgets('shows badge with correct count when games exist',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: GroupBottomNavBar(
                isAdmin: true,
                upcomingGamesCount: 3,
                onInviteTap: () {},
                onCreateGameTap: () {},
                onGamesListTap: () {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Badge should be visible
        final badgeFinder = find.byType(Badge);
        expect(badgeFinder, findsOneWidget);

        final badge = tester.widget<Badge>(badgeFinder);
        expect(badge.isLabelVisible, isTrue);

        // Check badge label shows correct count
        expect(find.text('3'), findsOneWidget);
      });

      testWidgets('shows "9+" when game count is 10 or more',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: GroupBottomNavBar(
                isAdmin: true,
                upcomingGamesCount: 15,
                onInviteTap: () {},
                onCreateGameTap: () {},
                onGamesListTap: () {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Badge should be visible
        final badgeFinder = find.byType(Badge);
        expect(badgeFinder, findsOneWidget);

        final badge = tester.widget<Badge>(badgeFinder);
        expect(badge.isLabelVisible, isTrue);

        // Check badge label shows "9+"
        expect(find.text('9+'), findsOneWidget);
      });

      testWidgets('shows exact count for 9 games', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: GroupBottomNavBar(
                isAdmin: true,
                upcomingGamesCount: 9,
                onInviteTap: () {},
                onCreateGameTap: () {},
                onGamesListTap: () {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Badge should be visible
        final badgeFinder = find.byType(Badge);
        expect(badgeFinder, findsOneWidget);

        final badge = tester.widget<Badge>(badgeFinder);
        expect(badge.isLabelVisible, isTrue);

        // Check badge label shows exact count "9"
        expect(find.text('9'), findsOneWidget);
      });

      testWidgets('badge appears on Games icon', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: GroupBottomNavBar(
                isAdmin: true,
                upcomingGamesCount: 5,
                onInviteTap: () {},
                onCreateGameTap: () {},
                onGamesListTap: () {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find the badge
        final badgeFinder = find.byType(Badge);
        expect(badgeFinder, findsOneWidget);

        // Verify badge wraps the Games list icon
        final badge = tester.widget<Badge>(badgeFinder);
        expect(badge.child, isA<Icon>());
      });

      testWidgets('defaults to 0 games when not specified', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: GroupBottomNavBar(
                isAdmin: true,
                // upcomingGamesCount not specified, should default to 0
                onInviteTap: () {},
                onCreateGameTap: () {},
                onGamesListTap: () {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Badge should exist but not be visible
        final badgeFinder = find.byType(Badge);
        expect(badgeFinder, findsOneWidget);

        final badge = tester.widget<Badge>(badgeFinder);
        expect(badge.isLabelVisible, isFalse);
      });
    });
  });
}
