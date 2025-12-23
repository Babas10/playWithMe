// Widget tests for StatsLoadingSkeleton and related loading widgets.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/features/profile/presentation/widgets/stats_loading_skeleton.dart';

void main() {
  group('StatsLoadingSkeleton Widget Tests', () {
    testWidgets('renders with default properties', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatsLoadingSkeleton(),
          ),
        ),
      );
      await tester.pump(); // Use pump() for animated widgets

      expect(find.byType(StatsLoadingSkeleton), findsOneWidget);
      // AnimatedBuilder count may vary with MaterialApp structure
      expect(find.byType(AnimatedBuilder), findsWidgets);
    });

    testWidgets('renders with custom height and width', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatsLoadingSkeleton(
              height: 100,
              width: 200,
            ),
          ),
        ),
      );
      await tester.pump();

      // Verify the skeleton widget exists with custom dimensions
      expect(find.byType(StatsLoadingSkeleton), findsOneWidget);

      // Check that the widget size is correctly applied
      final RenderBox box = tester.renderObject(find.byType(Container).last);
      expect(box.size.height, 100);
      expect(box.size.width, 200);
    });

    testWidgets('animates continuously', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatsLoadingSkeleton(),
          ),
        ),
      );

      // Initial pump
      await tester.pump();
      final initialWidget = tester.widget<Container>(
        find.descendant(
          of: find.byType(AnimatedBuilder),
          matching: find.byType(Container),
        ).first,
      );

      // Advance animation
      await tester.pump(const Duration(milliseconds: 750));
      final animatedWidget = tester.widget<Container>(
        find.descendant(
          of: find.byType(AnimatedBuilder),
          matching: find.byType(Container),
        ).first,
      );

      // Decorations should be different due to animation
      expect(initialWidget.decoration, isNot(equals(animatedWidget.decoration)));
    });
  });

  group('LoadingStatCard Widget Tests', () {
    testWidgets('renders card with loading skeletons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingStatCard(),
          ),
        ),
      );
      await tester.pump(); // Use pump() for animated widgets

      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(StatsLoadingSkeleton), findsNWidgets(9)); // Title + 4 stat items (2 skeletons each)
    });

    testWidgets('has correct layout structure', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingStatCard(),
          ),
        ),
      );
      await tester.pump(); // Use pump() for animated widgets

      expect(find.byType(Column), findsWidgets);
      expect(find.byType(Row), findsNWidgets(2)); // Two rows of stat items
    });
  });

  group('CompactStatLoadingSkeleton Widget Tests', () {
    testWidgets('renders compact loading card', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CompactStatLoadingSkeleton(),
          ),
        ),
      );
      await tester.pump(); // Use pump() for animated widgets

      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(StatsLoadingSkeleton), findsNWidgets(2)); // Label + value
    });

    testWidgets('has correct compact layout', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CompactStatLoadingSkeleton(),
          ),
        ),
      );
      await tester.pump(); // Use pump() for animated widgets

      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });
  });
}
