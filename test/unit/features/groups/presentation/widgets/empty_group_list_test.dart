// Tests for EmptyGroupList widget covering display and interaction
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/features/groups/presentation/widgets/empty_group_list.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale('en')],
      home: Scaffold(
        body: EmptyGroupList(),
      ),
    );
  }

  group('EmptyGroupList', () {
    testWidgets('displays empty state icon', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.groups_outlined), findsOneWidget);
    });

    testWidgets('displays "no groups yet" title', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text("You're not part of any group yet"), findsOneWidget);
    });

    testWidgets('displays encouraging message', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(
        find.text('Create or join groups to start organizing beach volleyball games with your friends!'),
        findsOneWidget,
      );
    });

    testWidgets('displays helper text for FAB', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Use the Create Group button below to get started.'), findsOneWidget);
    });

    testWidgets('is centered on screen', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(Center), findsWidgets);
    });

    testWidgets('uses correct text styles', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Title should be in headlineSmall style
      final titleText = tester.widget<Text>(
        find.text("You're not part of any group yet"),
      );
      expect(titleText.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('icon has correct size', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final icon = tester.widget<Icon>(find.byIcon(Icons.groups_outlined));
      expect(icon.size, 96);
    });

    testWidgets('all content is visible without scrolling on standard device', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verify all key elements are rendered
      expect(find.byIcon(Icons.groups_outlined), findsOneWidget);
      expect(find.text("You're not part of any group yet"), findsOneWidget);
      expect(find.text('Use the Create Group button below to get started.'), findsOneWidget);
    });

    testWidgets('uses padding around content', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final padding = tester.widget<Padding>(
        find.descendant(
          of: find.byType(Center),
          matching: find.byType(Padding),
        ).first,
      );
      expect(padding.padding, const EdgeInsets.all(32.0));
    });
  });
}
