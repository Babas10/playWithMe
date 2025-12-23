// Widget tests for WinStreakBadge
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/features/profile/presentation/widgets/win_streak_badge.dart';

void main() {
  group('WinStreakBadge Widget Tests', () {
    testWidgets('does not display for streak less than 2', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WinStreakBadge(currentStreak: 1),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsNothing);
      expect(find.byType(SizedBox), findsOneWidget); // SizedBox.shrink()
    });

    testWidgets('does not display for negative streak less than -2',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WinStreakBadge(currentStreak: -1),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsNothing);
    });

    testWidgets('does not display for zero streak', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WinStreakBadge(currentStreak: 0),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsNothing);
    });

    testWidgets('displays fire emoji for winning streak', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WinStreakBadge(currentStreak: 5),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsOneWidget);
      expect(find.text('🔥'), findsOneWidget);
      expect(find.text('5 wins'), findsOneWidget);
    });

    testWidgets('displays snowflake emoji for losing streak', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WinStreakBadge(currentStreak: -3),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsOneWidget);
      expect(find.text('❄️'), findsOneWidget);
      expect(find.text('3 losses'), findsOneWidget);
    });

    testWidgets('displays correct text for streak of 2', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WinStreakBadge(currentStreak: 2),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('2 wins'), findsOneWidget);
    });

    testWidgets('displays correct text for large winning streak',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WinStreakBadge(currentStreak: 15),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('🔥'), findsOneWidget);
      expect(find.text('15 wins'), findsOneWidget);
    });

    testWidgets('displays correct text for large losing streak',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WinStreakBadge(currentStreak: -10),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('❄️'), findsOneWidget);
      expect(find.text('10 losses'), findsOneWidget);
    });

    testWidgets('uses green color for winning streaks', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WinStreakBadge(currentStreak: 5),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final card = tester.widget<Card>(find.byType(Card));
      expect(
        (card.color as Color).value,
        Colors.green.withOpacity(0.1).value,
      );
    });

    testWidgets('uses blue color for losing streaks', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WinStreakBadge(currentStreak: -5),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final card = tester.widget<Card>(find.byType(Card));
      expect(
        (card.color as Color).value,
        Colors.blue.withOpacity(0.1).value,
      );
    });
  });
}
