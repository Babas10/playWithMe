// Tests RankingErrorPlaceholder widget display and retry functionality (Story 302.7).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/features/profile/presentation/widgets/empty_states/ranking_error_placeholder.dart';

void main() {
  group('RankingErrorPlaceholder', () {
    testWidgets('displays error message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RankingErrorPlaceholder(
              message: 'Failed to load rankings',
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(find.text('Failed to load rankings'), findsOneWidget);
    });

    testWidgets('displays retry button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RankingErrorPlaceholder(
              message: 'Failed to load rankings',
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(find.text('Retry'), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('displays error icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RankingErrorPlaceholder(
              message: 'Failed to load rankings',
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('triggers callback when retry button is tapped', (tester) async {
      var retryCallbackCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RankingErrorPlaceholder(
              message: 'Failed to load rankings',
              onRetry: () {
                retryCallbackCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(retryCallbackCalled, isTrue);
    });

    testWidgets('displays custom error messages correctly', (tester) async {
      const customMessage = 'Network error occurred';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RankingErrorPlaceholder(
              message: customMessage,
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(find.text(customMessage), findsOneWidget);
    });

    testWidgets('can be tapped multiple times', (tester) async {
      var tapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RankingErrorPlaceholder(
              message: 'Failed to load rankings',
              onRetry: () {
                tapCount++;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Retry'));
      await tester.pump();
      await tester.tap(find.text('Retry'));
      await tester.pump();
      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(tapCount, equals(3));
    });
  });
}
