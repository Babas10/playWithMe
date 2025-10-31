// Validates OfflineBanner widget displays correctly.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/presentation/widgets/offline_banner.dart';

void main() {
  group('OfflineBanner', () {
    testWidgets('displays offline icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OfflineBanner(),
          ),
        ),
      );

      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    });

    testWidgets('displays offline message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OfflineBanner(),
          ),
        ),
      );

      expect(
        find.text(
          'You\'re offline. Changes will sync when connection is restored.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('has orange background color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OfflineBanner(),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      expect(
        container.color,
        Colors.orange.shade700,
      );
    });

    testWidgets('has white text color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OfflineBanner(),
          ),
        ),
      );

      final text = tester.widget<Text>(
        find.text(
          'You\'re offline. Changes will sync when connection is restored.',
        ),
      );
      expect(text.style?.color, Colors.white);
    });

    testWidgets('has white icon color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OfflineBanner(),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.cloud_off));
      expect(icon.color, Colors.white);
    });

    testWidgets('spans full width', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OfflineBanner(),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.constraints?.minWidth, double.infinity);
    });

    testWidgets('centers content horizontally', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OfflineBanner(),
          ),
        ),
      );

      final row = tester.widget<Row>(find.byType(Row));
      expect(row.mainAxisAlignment, MainAxisAlignment.center);
    });

    testWidgets('text has ellipsis overflow', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OfflineBanner(),
          ),
        ),
      );

      final text = tester.widget<Text>(
        find.text(
          'You\'re offline. Changes will sync when connection is restored.',
        ),
      );
      expect(text.overflow, TextOverflow.ellipsis);
    });
  });
}
