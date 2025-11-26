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
  });
}
