// Widget tests for EmptyStatsPlaceholder and InsufficientDataPlaceholder.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/features/profile/presentation/widgets/empty_states/insufficient_data_placeholder.dart';

void main() {
  group('EmptyStatsPlaceholder Widget Tests', () {
    testWidgets('renders with default properties', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStatsPlaceholder(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No Stats Yet'), findsOneWidget);
      expect(find.text('Start playing games to see your statistics!'),
          findsOneWidget);
      expect(find.byIcon(Icons.insert_chart_outlined), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('renders with custom title and message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStatsPlaceholder(
              title: 'Custom Title',
              message: 'Custom message here',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Custom Title'), findsOneWidget);
      expect(find.text('Custom message here'), findsOneWidget);
    });

    testWidgets('renders with custom icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStatsPlaceholder(
              icon: Icons.sports_volleyball,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.sports_volleyball), findsOneWidget);
      expect(find.byIcon(Icons.insert_chart_outlined), findsNothing);
    });

    testWidgets('renders unlock message when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStatsPlaceholder(
              unlockMessage: 'Play at least 5 games to unlock',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Play at least 5 games to unlock'), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('does not render unlock message when null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStatsPlaceholder(
              unlockMessage: null,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.lock_outline), findsNothing);
    });

    testWidgets('renders with all custom properties', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStatsPlaceholder(
              title: 'No Performance Data',
              message: 'Play your first game to see stats!',
              unlockMessage: 'Play at least 1 game to unlock',
              icon: Icons.show_chart,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No Performance Data'), findsOneWidget);
      expect(find.text('Play your first game to see stats!'), findsOneWidget);
      expect(find.text('Play at least 1 game to unlock'), findsOneWidget);
      expect(find.byIcon(Icons.show_chart), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });
  });

  group('InsufficientDataPlaceholder Widget Tests', () {
    testWidgets('renders with required properties', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InsufficientDataPlaceholder(
              featureName: 'Monthly Progress Chart',
              requirement: 'Play games for at least 2 months',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Story 302.7: Updated to match new implementation (no "Locked" suffix)
      expect(find.text('Monthly Progress Chart'), findsOneWidget);
      expect(find.text('Play games for at least 2 months'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('renders with custom icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InsufficientDataPlaceholder(
              featureName: 'Best Partner',
              requirement: 'Play 5+ games with a teammate',
              icon: Icons.people,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Story 302.7: Updated to match new implementation (no "Locked" suffix)
      expect(find.text('Best Partner'), findsOneWidget);
      expect(find.text('Play 5+ games with a teammate'), findsOneWidget);
      expect(find.byIcon(Icons.people), findsOneWidget);
    });

    // Story 302.7: Removed "includes lock icon" test - new implementation uses customizable
    // icon parameter instead of hardcoded lock icon
  });
}
