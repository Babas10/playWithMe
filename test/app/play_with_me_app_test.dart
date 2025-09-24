import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/app/play_with_me_app.dart';
import 'package:play_with_me/core/config/environment_config.dart';

void main() {
  group('PlayWithMeApp', () {
    setUp(() {
      EnvironmentConfig.setEnvironment(Environment.prod);
    });

    testWidgets('should render correctly in production environment', (WidgetTester tester) async {
      await tester.pumpWidget(const PlayWithMeApp());

      expect(find.text('PlayWithMe'), findsOneWidget);
      expect(find.text('Welcome to PlayWithMe!'), findsOneWidget);
      expect(find.text('Beach volleyball games organizer'), findsOneWidget);
      expect(find.text('Environment: Production'), findsOneWidget);
      expect(find.text('Firebase Project: playwithme-prod'), findsOneWidget);
    });

    testWidgets('should render correctly in development environment', (WidgetTester tester) async {
      EnvironmentConfig.setEnvironment(Environment.dev);
      await tester.pumpWidget(const PlayWithMeApp());

      expect(find.text('PlayWithMe (Dev)'), findsOneWidget);
      expect(find.text('Welcome to PlayWithMe!'), findsOneWidget);
      expect(find.text('Beach volleyball games organizer'), findsOneWidget);
      expect(find.text('Environment: Development'), findsOneWidget);
      expect(find.text('Firebase Project: playwithme-dev'), findsOneWidget);
    });

    testWidgets('should render correctly in staging environment', (WidgetTester tester) async {
      EnvironmentConfig.setEnvironment(Environment.stg);
      await tester.pumpWidget(const PlayWithMeApp());

      expect(find.text('PlayWithMe (Staging)'), findsOneWidget);
      expect(find.text('Welcome to PlayWithMe!'), findsOneWidget);
      expect(find.text('Beach volleyball games organizer'), findsOneWidget);
      expect(find.text('Environment: Staging'), findsOneWidget);
      expect(find.text('Firebase Project: playwithme-stg'), findsOneWidget);
    });

    testWidgets('should have correct theme colors', (WidgetTester tester) async {
      await tester.pumpWidget(const PlayWithMeApp());

      final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));
      expect(materialApp.theme?.colorScheme.primary, isNotNull);
    });

    testWidgets('should have correct app title for each environment', (WidgetTester tester) async {
      // Test production
      EnvironmentConfig.setEnvironment(Environment.prod);
      await tester.pumpWidget(const PlayWithMeApp());
      MaterialApp materialApp = tester.widget(find.byType(MaterialApp));
      expect(materialApp.title, 'PlayWithMe');

      // Test development
      EnvironmentConfig.setEnvironment(Environment.dev);
      await tester.pumpWidget(const PlayWithMeApp());
      materialApp = tester.widget(find.byType(MaterialApp));
      expect(materialApp.title, 'PlayWithMe (Dev)');

      // Test staging
      EnvironmentConfig.setEnvironment(Environment.stg);
      await tester.pumpWidget(const PlayWithMeApp());
      materialApp = tester.widget(find.byType(MaterialApp));
      expect(materialApp.title, 'PlayWithMe (Staging)');
    });
  });

  group('HomePage', () {
    setUp(() {
      EnvironmentConfig.setEnvironment(Environment.prod);
    });

    testWidgets('should render correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: HomePage()),
      );

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('PlayWithMe'), findsOneWidget);
      expect(find.text('Welcome to PlayWithMe!'), findsOneWidget);
      expect(find.text('Beach volleyball games organizer'), findsOneWidget);
      expect(find.text('Environment: Production'), findsOneWidget);
    });

    testWidgets('should have correct layout structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: HomePage()),
      );

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Center), findsOneWidget);
      expect(find.byType(Column), findsNWidgets(2)); // Main column + environment info column
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('should show correct environment indicator colors', (WidgetTester tester) async {
      // Test development environment (red)
      EnvironmentConfig.setEnvironment(Environment.dev);
      await tester.pumpWidget(const MaterialApp(home: HomePage()));
      await tester.pumpAndSettle();

      Container container = tester.widget(find.byType(Container).last);
      BoxDecoration decoration = container.decoration as BoxDecoration;
      expect(decoration.border?.top.color, Colors.red);

      // Test staging environment (orange)
      EnvironmentConfig.setEnvironment(Environment.stg);
      await tester.pumpWidget(const MaterialApp(home: HomePage()));
      await tester.pumpAndSettle();

      container = tester.widget(find.byType(Container).last);
      decoration = container.decoration as BoxDecoration;
      expect(decoration.border?.top.color, Colors.orange);

      // Test production environment (green)
      EnvironmentConfig.setEnvironment(Environment.prod);
      await tester.pumpWidget(const MaterialApp(home: HomePage()));
      await tester.pumpAndSettle();

      container = tester.widget(find.byType(Container).last);
      decoration = container.decoration as BoxDecoration;
      expect(decoration.border?.top.color, Colors.green);
    });
  });
}