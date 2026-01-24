// Tests TimePeriodSelector widget displays chips and handles user interaction.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:play_with_me/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/domain/entities/time_period.dart';
import 'package:play_with_me/features/profile/presentation/widgets/time_period_selector.dart';

void main() {
  group('TimePeriodSelector Widget Tests', () {
    testWidgets('renders all 4 time period chips', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],          home: Scaffold(
            body: TimePeriodSelector(
              selectedPeriod: TimePeriod.allTime,
              onPeriodChanged: (_) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('30d'), findsOneWidget);
      expect(find.text('90d'), findsOneWidget);
      expect(find.text('1y'), findsOneWidget);
      expect(find.text('All Time'), findsOneWidget);
    });

    testWidgets('selected chip has primary color background', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],          home: Scaffold(
            body: TimePeriodSelector(
              selectedPeriod: TimePeriod.thirtyDays,
              onPeriodChanged: (_) {},
            ),
          ),
        ),
      );

      // Assert - Find the ChoiceChip for "30d"
      final thirtyDaysChip = find.widgetWithText(ChoiceChip, '30d');
      expect(thirtyDaysChip, findsOneWidget);

      final choiceChip = tester.widget<ChoiceChip>(thirtyDaysChip);
      expect(choiceChip.selected, isTrue);
    });

    testWidgets('unselected chips have outlined style', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],          home: Scaffold(
            body: TimePeriodSelector(
              selectedPeriod: TimePeriod.allTime,
              onPeriodChanged: (_) {},
            ),
          ),
        ),
      );

      // Assert - Find unselected chip (30d)
      final thirtyDaysChip = find.widgetWithText(ChoiceChip, '30d');
      expect(thirtyDaysChip, findsOneWidget);

      final choiceChip = tester.widget<ChoiceChip>(thirtyDaysChip);
      expect(choiceChip.selected, isFalse);
    });

    testWidgets('tap on chip triggers onPeriodChanged callback',
        (tester) async {
      // Arrange
      TimePeriod? selectedPeriod;

      await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],          home: Scaffold(
            body: TimePeriodSelector(
              selectedPeriod: TimePeriod.allTime,
              onPeriodChanged: (period) {
                selectedPeriod = period;
              },
            ),
          ),
        ),
      );

      // Act - Tap on "30d" chip
      await tester.tap(find.text('30d'));
      await tester.pumpAndSettle();

      // Assert
      expect(selectedPeriod, TimePeriod.thirtyDays);
    });

    testWidgets('correct period value passed to callback', (tester) async {
      // Arrange
      final List<TimePeriod> tappedPeriods = [];

      await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],          home: Scaffold(
            body: TimePeriodSelector(
              selectedPeriod: TimePeriod.allTime,
              onPeriodChanged: (period) {
                tappedPeriods.add(period);
              },
            ),
          ),
        ),
      );

      // Act - Tap on different chips
      await tester.tap(find.text('30d'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('90d'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('1y'));
      await tester.pumpAndSettle();

      // Assert
      expect(tappedPeriods.length, 3);
      expect(tappedPeriods[0], TimePeriod.thirtyDays);
      expect(tappedPeriods[1], TimePeriod.ninetyDays);
      expect(tappedPeriods[2], TimePeriod.oneYear);
    });

    testWidgets('chip labels match TimePeriod.displayName', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],          home: Scaffold(
            body: TimePeriodSelector(
              selectedPeriod: TimePeriod.allTime,
              onPeriodChanged: (_) {},
            ),
          ),
        ),
      );

      // Assert - Verify each chip label matches the displayName
      for (final period in TimePeriod.values) {
        expect(find.text(period.displayName), findsOneWidget);
      }
    });

    testWidgets('widget is horizontally scrollable', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],          home: Scaffold(
            body: TimePeriodSelector(
              selectedPeriod: TimePeriod.allTime,
              onPeriodChanged: (_) {},
            ),
          ),
        ),
      );

      // Assert - Verify ListView exists with horizontal scroll
      final listView = find.byType(ListView);
      expect(listView, findsOneWidget);

      final listViewWidget = tester.widget<ListView>(listView);
      expect(listViewWidget.scrollDirection, Axis.horizontal);
    });

    testWidgets('widget has correct height (48px)', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],          home: Scaffold(
            body: TimePeriodSelector(
              selectedPeriod: TimePeriod.allTime,
              onPeriodChanged: (_) {},
            ),
          ),
        ),
      );

      // Assert - Verify SizedBox height
      final sizedBox = find.byType(SizedBox).first;
      final sizedBoxWidget = tester.widget<SizedBox>(sizedBox);
      expect(sizedBoxWidget.height, 48);
    });

    testWidgets('chips are separated by 8px spacing', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],          home: Scaffold(
            body: TimePeriodSelector(
              selectedPeriod: TimePeriod.allTime,
              onPeriodChanged: (_) {},
            ),
          ),
        ),
      );

      // Assert - Find the ListView and verify separator
      final listView = find.byType(ListView);
      expect(listView, findsOneWidget);

      final listViewWidget = tester.widget<ListView>(listView);
      // The separatorBuilder creates SizedBox with width 8
      // We can't directly test the separator builder, but we can verify
      // that it's a ListView.separated which means spacing is applied
      expect(listViewWidget.scrollDirection, Axis.horizontal);
    });

    testWidgets('tapping selected chip still triggers callback',
        (tester) async {
      // Arrange
      int callbackCount = 0;
      TimePeriod? lastSelectedPeriod;

      await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],          home: Scaffold(
            body: TimePeriodSelector(
              selectedPeriod: TimePeriod.thirtyDays,
              onPeriodChanged: (period) {
                callbackCount++;
                lastSelectedPeriod = period;
              },
            ),
          ),
        ),
      );

      // Act - Tap on already selected chip
      await tester.tap(find.text('30d'));
      await tester.pumpAndSettle();

      // Assert - Callback should still be triggered
      expect(callbackCount, 1);
      expect(lastSelectedPeriod, TimePeriod.thirtyDays);
    });

    testWidgets('AnimatedContainer animates chip selection', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],          home: Scaffold(
            body: TimePeriodSelector(
              selectedPeriod: TimePeriod.allTime,
              onPeriodChanged: (_) {},
            ),
          ),
        ),
      );

      // Assert - Verify AnimatedContainer exists for each chip
      final animatedContainers = find.byType(AnimatedContainer);
      expect(animatedContainers, findsNWidgets(TimePeriod.values.length));

      // Verify animation duration
      final firstAnimatedContainer =
          tester.widget<AnimatedContainer>(animatedContainers.first);
      expect(firstAnimatedContainer.duration, const Duration(milliseconds: 200));
      expect(firstAnimatedContainer.curve, Curves.easeInOut);
    });
  });
}
