// Tests InsufficientDataPlaceholder widget display and progress tracking (Story 302.7).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/features/profile/presentation/widgets/empty_states/insufficient_data_placeholder.dart';

void main() {
  group('InsufficientDataPlaceholder', () {
    testWidgets('displays feature name', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InsufficientDataPlaceholder(
              featureName: 'Test Feature',
              requirement: 'Play 5 games',
            ),
          ),
        ),
      );

      expect(find.text('Test Feature'), findsOneWidget);
    });

    testWidgets('displays requirement text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InsufficientDataPlaceholder(
              featureName: 'Test Feature',
              requirement: 'Play 5 games',
            ),
          ),
        ),
      );

      expect(find.text('Play 5 games'), findsOneWidget);
    });

    testWidgets('displays current progress when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InsufficientDataPlaceholder(
              featureName: 'Test Feature',
              requirement: 'Play 5 games',
              currentProgress: '2/5 games',
            ),
          ),
        ),
      );

      expect(find.text('2/5 games'), findsOneWidget);
    });

    testWidgets('hides progress when not provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InsufficientDataPlaceholder(
              featureName: 'Test Feature',
              requirement: 'Play 5 games',
            ),
          ),
        ),
      );

      expect(find.text('2/5 games'), findsNothing);
    });

    testWidgets('displays message when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InsufficientDataPlaceholder(
              featureName: 'Test Feature',
              requirement: 'Play 5 games',
              message: 'Keep playing!',
            ),
          ),
        ),
      );

      expect(find.text('Keep playing!'), findsOneWidget);
    });

    testWidgets('hides message when not provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InsufficientDataPlaceholder(
              featureName: 'Test Feature',
              requirement: 'Play 5 games',
            ),
          ),
        ),
      );

      expect(find.text('Keep playing!'), findsNothing);
    });

    testWidgets('renders custom icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InsufficientDataPlaceholder(
              featureName: 'Test Feature',
              requirement: 'Play 5 games',
              icon: Icons.sports_volleyball,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.sports_volleyball), findsOneWidget);
    });

    testWidgets('renders default icon when not provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InsufficientDataPlaceholder(
              featureName: 'Test Feature',
              requirement: 'Play 5 games',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('displays both progress and message when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InsufficientDataPlaceholder(
              featureName: 'Monthly Progress Chart',
              requirement: 'Play at least 3 games',
              currentProgress: '1/3 games',
              message: 'Start playing to track your progress!',
            ),
          ),
        ),
      );

      expect(find.text('Monthly Progress Chart'), findsOneWidget);
      expect(find.text('Play at least 3 games'), findsOneWidget);
      expect(find.text('1/3 games'), findsOneWidget);
      expect(find.text('Start playing to track your progress!'), findsOneWidget);
    });
  });
}
