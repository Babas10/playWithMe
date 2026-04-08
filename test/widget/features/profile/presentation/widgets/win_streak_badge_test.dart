// Widget tests for WinStreakBadge
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:play_with_me/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/features/profile/presentation/widgets/win_streak_badge.dart';

void main() {
  group('WinStreakBadge Widget Tests', () {
    testWidgets('displays for winning streak of 1', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Scaffold(body: WinStreakBadge(currentStreak: 1)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsOneWidget);
      expect(find.text('🔥'), findsOneWidget);
    });

    testWidgets('displays for losing streak of -1', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Scaffold(body: WinStreakBadge(currentStreak: -1)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsOneWidget);
      expect(find.text('❄️'), findsOneWidget);
    });

    testWidgets('does not display for zero streak', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Scaffold(body: WinStreakBadge(currentStreak: 0)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsNothing);
    });

    testWidgets('displays fire emoji for winning streak', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Scaffold(body: WinStreakBadge(currentStreak: 5)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsOneWidget);
      expect(find.text('🔥'), findsOneWidget);
      expect(find.text('5 wins'), findsOneWidget);
    });

    testWidgets('displays snowflake emoji for losing streak', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Scaffold(body: WinStreakBadge(currentStreak: -3)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsOneWidget);
      expect(find.text('❄️'), findsOneWidget);
      expect(find.text('3 losses'), findsOneWidget);
    });

    testWidgets('displays correct text for streak of 2', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Scaffold(body: WinStreakBadge(currentStreak: 2)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('2 wins'), findsOneWidget);
    });

    testWidgets('displays correct text for large winning streak', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Scaffold(body: WinStreakBadge(currentStreak: 15)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('🔥'), findsOneWidget);
      expect(find.text('15 wins'), findsOneWidget);
    });

    testWidgets('displays correct text for large losing streak', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Scaffold(body: WinStreakBadge(currentStreak: -10)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('❄️'), findsOneWidget);
      expect(find.text('10 losses'), findsOneWidget);
    });

    testWidgets('uses green color for winning streaks', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Scaffold(body: WinStreakBadge(currentStreak: 5)),
        ),
      );
      await tester.pumpAndSettle();

      final card = tester.widget<Card>(find.byType(Card));
      expect(
        (card.color as Color).toARGB32(),
        Colors.green.withValues(alpha: 0.1).toARGB32(),
      );
    });

    testWidgets('uses blue color for losing streaks', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Scaffold(body: WinStreakBadge(currentStreak: -5)),
        ),
      );
      await tester.pumpAndSettle();

      final card = tester.widget<Card>(find.byType(Card));
      expect(
        (card.color as Color).toARGB32(),
        Colors.blue.withValues(alpha: 0.1).toARGB32(),
      );
    });
  });
}
