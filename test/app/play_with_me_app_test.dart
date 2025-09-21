import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/app/play_with_me_app.dart';

void main() {
  group('PlayWithMeApp', () {
    testWidgets('should render correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const PlayWithMeApp());

      expect(find.text('PlayWithMe'), findsOneWidget);
      expect(find.text('Welcome to PlayWithMe!'), findsOneWidget);
      expect(find.text('Beach volleyball games organizer'), findsOneWidget);
    });

    testWidgets('should have correct theme colors', (WidgetTester tester) async {
      await tester.pumpWidget(const PlayWithMeApp());

      final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));
      expect(materialApp.theme?.colorScheme.primary, isNotNull);
    });

    testWidgets('should have correct app title', (WidgetTester tester) async {
      await tester.pumpWidget(const PlayWithMeApp());

      final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));
      expect(materialApp.title, 'PlayWithMe');
    });
  });

  group('HomePage', () {
    testWidgets('should render correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: HomePage()),
      );

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('PlayWithMe'), findsOneWidget);
      expect(find.text('Welcome to PlayWithMe!'), findsOneWidget);
      expect(find.text('Beach volleyball games organizer'), findsOneWidget);
    });

    testWidgets('should have correct layout structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: HomePage()),
      );

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Center), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
    });
  });
}