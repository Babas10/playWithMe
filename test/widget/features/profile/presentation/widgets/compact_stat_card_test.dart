// Widget tests for CompactStatCard
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/features/profile/presentation/widgets/compact_stat_card.dart';

void main() {
  group('CompactStatCard Widget Tests', () {
    testWidgets('renders with required properties', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CompactStatCard(
              label: 'Win Rate',
              value: '75%',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Win Rate'), findsOneWidget);
      expect(find.text('75%'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('renders with icon when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CompactStatCard(
              label: 'ELO Rating',
              value: '1650',
              icon: Icons.trending_up,
              iconColor: Colors.green,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ELO Rating'), findsOneWidget);
      expect(find.text('1650'), findsOneWidget);
      expect(find.byIcon(Icons.trending_up), findsOneWidget);
    });

    testWidgets('renders with sub-label when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CompactStatCard(
              label: 'Games Played',
              value: '42',
              subLabel: 'Last 30 days',
              subLabelColor: Colors.grey,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Games Played'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
      expect(find.text('Last 30 days'), findsOneWidget);
    });

    testWidgets('handles long text with ellipsis', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 150,
              child: CompactStatCard(
                label: 'Very Long Label That Should Be Truncated',
                value: '999',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final textWidget = tester.widget<Text>(
        find.text('Very Long Label That Should Be Truncated'),
      );
      expect(textWidget.overflow, TextOverflow.ellipsis);
    });

    testWidgets('renders without sub-label by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CompactStatCard(
              label: 'Test Label',
              value: '100',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should only find the label and value, not any sub-label
      expect(find.text('Test Label'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
      expect(find.byType(Text), findsNWidgets(2)); // Only label and value
    });

    testWidgets('renders without icon by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CompactStatCard(
              label: 'Test Label',
              value: '100',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Icon), findsNothing);
    });
  });
}
