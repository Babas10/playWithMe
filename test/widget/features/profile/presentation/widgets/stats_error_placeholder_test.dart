// Widget tests for StatsErrorPlaceholder and CompactStatsError.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/features/profile/presentation/widgets/stats_error_placeholder.dart';

void main() {
  group('StatsErrorPlaceholder Widget Tests', () {
    testWidgets('renders with default properties', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatsErrorPlaceholder(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Unable to Load Stats'), findsOneWidget);
      expect(find.text('Something went wrong while loading your statistics.'),
          findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('renders retry button when onRetry provided', (tester) async {
      bool retryTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatsErrorPlaceholder(
              onRetry: () {
                retryTapped = true;
              },
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(retryTapped, isTrue);
    });

    testWidgets('does not render retry button when onRetry is null',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatsErrorPlaceholder(
              onRetry: null,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Retry'), findsNothing);
      expect(find.byIcon(Icons.refresh), findsNothing);
    });

    testWidgets('renders with custom title and message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatsErrorPlaceholder(
              title: 'Custom Error',
              message: 'Custom error message',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Custom Error'), findsOneWidget);
      expect(find.text('Custom error message'), findsOneWidget);
    });
  });

  group('StatsErrorPlaceholder.network Widget Tests', () {
    testWidgets('renders network error variant', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatsErrorPlaceholder.network(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Network Error'), findsOneWidget);
      expect(find.text('Check your connection and try again.'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
    });

    testWidgets('network variant accepts retry callback', (tester) async {
      bool retryTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatsErrorPlaceholder.network(
              onRetry: () {
                retryTapped = true;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(retryTapped, isTrue);
    });
  });

  group('StatsErrorPlaceholder.permission Widget Tests', () {
    testWidgets('renders permission error variant', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatsErrorPlaceholder.permission(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Access Denied'), findsOneWidget);
      expect(
        find.text('You don\'t have permission to view these statistics.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });
  });

  group('StatsErrorPlaceholder.calculation Widget Tests', () {
    testWidgets('renders calculation error variant', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatsErrorPlaceholder.calculation(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Calculation Error'), findsOneWidget);
      expect(
        find.text('Unable to calculate statistics. Please try again later.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.calculate_outlined), findsOneWidget);
    });
  });

  group('CompactStatsError Widget Tests', () {
    testWidgets('renders compact error with default message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CompactStatsError(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Error'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('renders with custom message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CompactStatsError(
              message: 'Failed to load',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Failed to load'), findsOneWidget);
    });

    testWidgets('renders retry button when onRetry provided', (tester) async {
      bool retryTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactStatsError(
              onRetry: () {
                retryTapped = true;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Retry'), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(retryTapped, isTrue);
    });

    testWidgets('does not render retry button when onRetry is null',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CompactStatsError(
              onRetry: null,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Retry'), findsNothing);
      expect(find.byType(TextButton), findsNothing);
    });
  });
}
