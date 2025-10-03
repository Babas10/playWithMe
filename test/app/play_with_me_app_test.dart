import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/app/play_with_me_app.dart';
import 'package:play_with_me/core/config/environment_config.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('PlayWithMeApp', () {
    setUp(() async {
      EnvironmentConfig.setEnvironment(Environment.prod);
      await initializeTestDependencies();
    });

    tearDown(() {
      cleanupTestDependencies();
    });

    testWidgets('should render correctly in production environment', (WidgetTester tester) async {
      await tester.pumpWidget(const PlayWithMeApp());

      // Wait for initial state changes - the AuthenticationBloc needs time to process the stream
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Should show login screen for unauthenticated users
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign in to continue playing'), findsOneWidget);
    });

    testWidgets('should render correctly in development environment', (WidgetTester tester) async {
      EnvironmentConfig.setEnvironment(Environment.dev);
      await tester.pumpWidget(const PlayWithMeApp());
      await tester.pumpAndSettle();

      // App shows authentication screen regardless of environment
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign in to continue playing'), findsOneWidget);
    });

    testWidgets('should render correctly in staging environment', (WidgetTester tester) async {
      EnvironmentConfig.setEnvironment(Environment.stg);
      await tester.pumpWidget(const PlayWithMeApp());
      await tester.pumpAndSettle();

      // App shows authentication screen regardless of environment
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign in to continue playing'), findsOneWidget);
    });

    testWidgets('should have correct theme colors', (WidgetTester tester) async {
      await tester.pumpWidget(const PlayWithMeApp());
      await tester.pumpAndSettle();

      final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));
      expect(materialApp.theme?.colorScheme.primary, isNotNull);
    });

    testWidgets('should have correct app title for each environment', (WidgetTester tester) async {
      // Test production
      EnvironmentConfig.setEnvironment(Environment.prod);
      await tester.pumpWidget(const PlayWithMeApp());
      await tester.pumpAndSettle();
      MaterialApp materialApp = tester.widget(find.byType(MaterialApp));
      expect(materialApp.title, 'PlayWithMe');

      // Test development
      EnvironmentConfig.setEnvironment(Environment.dev);
      await tester.pumpWidget(const PlayWithMeApp());
      await tester.pumpAndSettle();
      materialApp = tester.widget(find.byType(MaterialApp));
      expect(materialApp.title, 'PlayWithMe (Dev)');

      // Test staging
      EnvironmentConfig.setEnvironment(Environment.stg);
      await tester.pumpWidget(const PlayWithMeApp());
      await tester.pumpAndSettle();
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
      expect(find.byType(Center), findsAtLeastNWidgets(1)); // At least one Center widget
      expect(find.byType(Column), findsAtLeastNWidgets(2)); // Main column + environment info column
      expect(find.byType(Container), findsAtLeastNWidgets(1)); // At least one Container
    });

    testWidgets('should show correct environment indicator colors', (WidgetTester tester) async {
      // Test development environment (red)
      EnvironmentConfig.setEnvironment(Environment.dev);
      await tester.pumpWidget(const MaterialApp(home: HomePage()));
      await tester.pumpAndSettle();

      // Find containers and look for the one with decoration
      final containers = tester.widgetList<Container>(find.byType(Container));
      Container? envContainer;
      for (final container in containers) {
        if (container.decoration is BoxDecoration) {
          final decoration = container.decoration as BoxDecoration;
          if (decoration.border != null) {
            envContainer = container;
            break;
          }
        }
      }

      expect(envContainer, isNotNull);
      BoxDecoration decoration = envContainer!.decoration as BoxDecoration;
      expect(decoration.border?.top.color, Colors.red);

      // Test staging environment (orange)
      EnvironmentConfig.setEnvironment(Environment.stg);
      await tester.pumpWidget(const MaterialApp(home: HomePage()));
      await tester.pumpAndSettle();

      // Find the environment container again
      final stagingContainers = tester.widgetList<Container>(find.byType(Container));
      Container? stagingEnvContainer;
      for (final container in stagingContainers) {
        if (container.decoration is BoxDecoration) {
          final decoration = container.decoration as BoxDecoration;
          if (decoration.border != null) {
            stagingEnvContainer = container;
            break;
          }
        }
      }

      expect(stagingEnvContainer, isNotNull);
      BoxDecoration stagingDecoration = stagingEnvContainer!.decoration as BoxDecoration;
      expect(stagingDecoration.border?.top.color, Colors.orange);

      // Test production environment (green)
      EnvironmentConfig.setEnvironment(Environment.prod);
      await tester.pumpWidget(const MaterialApp(home: HomePage()));
      await tester.pumpAndSettle();

      // Find the environment container for production
      final prodContainers = tester.widgetList<Container>(find.byType(Container));
      Container? prodEnvContainer;
      for (final container in prodContainers) {
        if (container.decoration is BoxDecoration) {
          final decoration = container.decoration as BoxDecoration;
          if (decoration.border != null) {
            prodEnvContainer = container;
            break;
          }
        }
      }

      expect(prodEnvContainer, isNotNull);
      BoxDecoration prodDecoration = prodEnvContainer!.decoration as BoxDecoration;
      expect(prodDecoration.border?.top.color, Colors.green);
    });
  });
}