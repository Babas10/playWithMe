// Verifies that PlayWithMeApp correctly handles authentication state transitions and UI updates
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/app/play_with_me_app.dart';
import 'package:play_with_me/core/config/environment_config.dart';
import '../../helpers/test_helpers.dart';
import '../features/auth/data/mock_auth_repository.dart';

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

      // Wait for AuthenticationBloc to process initial auth state and stream subscription
      await tester.pump(); // Initial build
      await tester.pump(const Duration(milliseconds: 10)); // Allow bloc to start stream subscription
      await tester.pump(const Duration(milliseconds: 10)); // Allow stream to emit initial value
      await tester.pump(); // Rebuild with new state

      // Should show login screen for unauthenticated users
      expect(find.text('Welcome Back!'), findsOneWidget);
      expect(find.text('Sign in to continue organizing your volleyball games'), findsOneWidget);
    });

    testWidgets('should render correctly in development environment', (WidgetTester tester) async {
      EnvironmentConfig.setEnvironment(Environment.dev);
      await tester.pumpWidget(const PlayWithMeApp());

      // Wait for AuthenticationBloc to process initial auth state and stream subscription
      await tester.pump(); // Initial build
      await tester.pump(const Duration(milliseconds: 10)); // Allow bloc to start stream subscription
      await tester.pump(const Duration(milliseconds: 10)); // Allow stream to emit initial value
      await tester.pump(); // Rebuild with new state

      // App shows authentication screen regardless of environment
      expect(find.text('Welcome Back!'), findsOneWidget);
      expect(find.text('Sign in to continue organizing your volleyball games'), findsOneWidget);
    });

    testWidgets('should render correctly in staging environment', (WidgetTester tester) async {
      EnvironmentConfig.setEnvironment(Environment.stg);
      await tester.pumpWidget(const PlayWithMeApp());

      // Wait for AuthenticationBloc to process initial auth state and stream subscription
      await tester.pump(); // Initial build
      await tester.pump(const Duration(milliseconds: 10)); // Allow bloc to start stream subscription
      await tester.pump(const Duration(milliseconds: 10)); // Allow stream to emit initial value
      await tester.pump(); // Rebuild with new state

      // App shows authentication screen regardless of environment
      expect(find.text('Welcome Back!'), findsOneWidget);
      expect(find.text('Sign in to continue organizing your volleyball games'), findsOneWidget);
    });

    testWidgets('should have correct theme colors', (WidgetTester tester) async {
      await tester.pumpWidget(const PlayWithMeApp());

      // Wait for AuthenticationBloc to process initial auth state and stream subscription
      await tester.pump(); // Initial build
      await tester.pump(const Duration(milliseconds: 10)); // Allow bloc to start stream subscription
      await tester.pump(const Duration(milliseconds: 10)); // Allow stream to emit initial value
      await tester.pump(); // Rebuild with new state

      final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));
      expect(materialApp.theme?.colorScheme.primary, isNotNull);
    });

    testWidgets('should have correct app title for each environment', (WidgetTester tester) async {
      // Test production
      EnvironmentConfig.setEnvironment(Environment.prod);
      await tester.pumpWidget(const PlayWithMeApp());
      // Wait for AuthenticationBloc to process initial auth state and stream subscription
      await tester.pump(); // Initial build
      await tester.pump(const Duration(milliseconds: 10)); // Allow bloc to start stream subscription
      await tester.pump(const Duration(milliseconds: 10)); // Allow stream to emit initial value
      await tester.pump(); // Rebuild with new state
      MaterialApp materialApp = tester.widget(find.byType(MaterialApp));
      expect(materialApp.title, 'PlayWithMe');

      // Test development
      EnvironmentConfig.setEnvironment(Environment.dev);
      await tester.pumpWidget(const PlayWithMeApp());
      // Wait for AuthenticationBloc to process initial auth state and stream subscription
      await tester.pump(); // Initial build
      await tester.pump(const Duration(milliseconds: 10)); // Allow bloc to start stream subscription
      await tester.pump(const Duration(milliseconds: 10)); // Allow stream to emit initial value
      await tester.pump(); // Rebuild with new state
      materialApp = tester.widget(find.byType(MaterialApp));
      expect(materialApp.title, 'PlayWithMe (Dev)');

      // Test staging
      EnvironmentConfig.setEnvironment(Environment.stg);
      await tester.pumpWidget(const PlayWithMeApp());
      // Wait for AuthenticationBloc to process initial auth state and stream subscription
      await tester.pump(); // Initial build
      await tester.pump(const Duration(milliseconds: 10)); // Allow bloc to start stream subscription
      await tester.pump(const Duration(milliseconds: 10)); // Allow stream to emit initial value
      await tester.pump(); // Rebuild with new state
      materialApp = tester.widget(find.byType(MaterialApp));
      expect(materialApp.title, 'PlayWithMe (Staging)');
    });

    testWidgets('should properly handle authentication state transitions (Unknown → Unauthenticated → UI update)', (WidgetTester tester) async {
      // Set up initial environment
      EnvironmentConfig.setEnvironment(Environment.dev);

      // Build the app and capture the initial splash state
      await tester.pumpWidget(const PlayWithMeApp());

      // Initial state should show splash screen (Unknown state)
      expect(find.byIcon(Icons.sports_volleyball), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Allow authentication process to start and emit initial state
      await tester.pump(); // Initial build
      await tester.pump(const Duration(milliseconds: 10)); // Allow bloc to start stream subscription
      await tester.pump(const Duration(milliseconds: 10)); // Allow stream to emit initial null value
      await tester.pump(); // Rebuild with new unauthenticated state

      // Should transition to login screen (Unauthenticated state)
      expect(find.text('Welcome Back!'), findsOneWidget);
      expect(find.text('Sign in to continue organizing your volleyball games'), findsOneWidget);

      // Should no longer show splash screen elements
      expect(find.text('Loading...'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Simulate user authentication by setting a user
      final mockRepo = getTestAuthRepository()!;
      const testUser = TestUserData.testUser;
      mockRepo.setCurrentUser(testUser);

      // Allow authentication bloc to process the state change
      await tester.pump(const Duration(milliseconds: 10)); // Allow stream emission
      await tester.pump(); // Rebuild with authenticated state

      // Should transition to HomePage (Authenticated state)
      expect(find.text('Welcome to PlayWithMe!'), findsOneWidget);
      expect(find.text('Beach volleyball games organizer'), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);

      // Should no longer show login screen elements
      expect(find.text('Welcome Back!'), findsNothing);
      expect(find.text('Sign in to continue organizing your volleyball games'), findsNothing);
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

      // Use controlled pump instead of pumpAndSettle to avoid timeouts
      await tester.pump();

      // Find the environment info container by looking for the one with environment text
      final envText = find.text('Environment: Development');
      expect(envText, findsOneWidget);

      // Find containers and look for the one with border decoration
      final containers = tester.widgetList<Container>(find.byType(Container));
      Container? envContainer;
      for (final container in containers) {
        if (container.decoration is BoxDecoration) {
          final decoration = container.decoration as BoxDecoration;
          if (decoration.border != null && decoration.border is Border) {
            final border = decoration.border as Border;
            // Check if it's a uniform border (Border.all) with red color
            if (border.top.color == Colors.red) {
              envContainer = container;
              break;
            }
          }
        }
      }

      expect(envContainer, isNotNull, reason: 'Should find container with red border for dev environment');
      BoxDecoration decoration = envContainer!.decoration as BoxDecoration;
      final border = decoration.border as Border;
      expect(border.top.color, Colors.red);

      // Test staging environment (orange)
      EnvironmentConfig.setEnvironment(Environment.stg);
      await tester.pumpWidget(const MaterialApp(home: HomePage()));
      await tester.pump();

      // Verify staging environment text
      expect(find.text('Environment: Staging'), findsOneWidget);

      // Find the environment container for staging
      final stagingContainers = tester.widgetList<Container>(find.byType(Container));
      Container? stagingEnvContainer;
      for (final container in stagingContainers) {
        if (container.decoration is BoxDecoration) {
          final decoration = container.decoration as BoxDecoration;
          if (decoration.border != null && decoration.border is Border) {
            final border = decoration.border as Border;
            // Check if it's a uniform border (Border.all) with orange color
            if (border.top.color == Colors.orange) {
              stagingEnvContainer = container;
              break;
            }
          }
        }
      }

      expect(stagingEnvContainer, isNotNull, reason: 'Should find container with orange border for staging environment');
      BoxDecoration stagingDecoration = stagingEnvContainer!.decoration as BoxDecoration;
      final stagingBorder = stagingDecoration.border as Border;
      expect(stagingBorder.top.color, Colors.orange);

      // Test production environment (green)
      EnvironmentConfig.setEnvironment(Environment.prod);
      await tester.pumpWidget(const MaterialApp(home: HomePage()));
      await tester.pump();

      // Verify production environment text
      expect(find.text('Environment: Production'), findsOneWidget);

      // Find the environment container for production
      final prodContainers = tester.widgetList<Container>(find.byType(Container));
      Container? prodEnvContainer;
      for (final container in prodContainers) {
        if (container.decoration is BoxDecoration) {
          final decoration = container.decoration as BoxDecoration;
          if (decoration.border != null && decoration.border is Border) {
            final border = decoration.border as Border;
            // Check if it's a uniform border (Border.all) with green color
            if (border.top.color == Colors.green) {
              prodEnvContainer = container;
              break;
            }
          }
        }
      }

      expect(prodEnvContainer, isNotNull, reason: 'Should find container with green border for production environment');
      BoxDecoration prodDecoration = prodEnvContainer!.decoration as BoxDecoration;
      final prodBorder = prodDecoration.border as Border;
      expect(prodBorder.top.color, Colors.green);
    });
  });
}