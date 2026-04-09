// Verifies GlobalBottomNavBar renders correctly and highlights the active tab.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/presentation/widgets/global_bottom_nav_bar.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

void main() {
  Widget buildWidget({
    int selectedIndex = 0,
    ValueChanged<int>? onTabSelected,
    int friendRequestCount = 0,
  }) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: Scaffold(
        bottomNavigationBar: GlobalBottomNavBar(
          selectedIndex: selectedIndex,
          onTabSelected: onTabSelected ?? (_) {},
          friendRequestCount: friendRequestCount,
        ),
      ),
    );
  }

  group('GlobalBottomNavBar', () {
    testWidgets('renders a BottomNavigationBar', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('shows all four navigation labels', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Stats'), findsOneWidget);
      expect(find.text('Groups'), findsOneWidget);
      expect(find.text('Community'), findsOneWidget);
    });

    testWidgets('highlights Home tab when selectedIndex is 0', (tester) async {
      await tester.pumpWidget(buildWidget(selectedIndex: 0));
      final nav = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(nav.currentIndex, 0);
    });

    testWidgets('highlights Groups tab when selectedIndex is 2', (
      tester,
    ) async {
      await tester.pumpWidget(buildWidget(selectedIndex: 2));
      final nav = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(nav.currentIndex, 2);
    });

    testWidgets('invokes onTabSelected with tapped index', (tester) async {
      int? tappedIndex;
      await tester.pumpWidget(
        buildWidget(onTabSelected: (i) => tappedIndex = i),
      );

      await tester.tap(find.text('Groups'));
      expect(tappedIndex, 2);
    });

    testWidgets('shows no badge when friendRequestCount is 0', (tester) async {
      await tester.pumpWidget(buildWidget(friendRequestCount: 0));
      // The badge text should not appear
      expect(find.text('0'), findsNothing);
    });

    testWidgets('shows badge with count when friendRequestCount > 0', (
      tester,
    ) async {
      await tester.pumpWidget(buildWidget(friendRequestCount: 3));
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('shows 9+ badge when friendRequestCount > 9', (tester) async {
      await tester.pumpWidget(buildWidget(friendRequestCount: 15));
      expect(find.text('9+'), findsOneWidget);
    });
  });
}
