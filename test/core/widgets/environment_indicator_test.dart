import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/config/environment_config.dart';
import 'package:play_with_me/core/widgets/environment_indicator.dart';

void main() {
  group('EnvironmentIndicator', () {
    tearDown(() {
      // Reset to default environment after each test
      EnvironmentConfig.setEnvironment(Environment.prod);
    });

    testWidgets('does not render in production environment', (tester) async {
      // Arrange
      EnvironmentConfig.setEnvironment(Environment.prod);

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EnvironmentIndicator(),
          ),
        ),
      );

      // Assert
      expect(find.byType(EnvironmentIndicator), findsOneWidget);
      expect(find.text('Production Environment'), findsNothing);
      // Should render as SizedBox.shrink() in production
      final widget = tester.widget<EnvironmentIndicator>(find.byType(EnvironmentIndicator));
      expect(widget, isNotNull);
    });

    testWidgets('renders development environment indicator', (tester) async {
      // Arrange
      EnvironmentConfig.setEnvironment(Environment.dev);

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EnvironmentIndicator(),
          ),
        ),
      );

      // Assert
      expect(find.text('Development Environment'), findsOneWidget);
      expect(find.byIcon(Icons.code), findsOneWidget);
      // Firebase is not initialized in tests, so cloud_off icon should be present
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    });

    testWidgets('renders staging environment indicator', (tester) async {
      // Arrange
      EnvironmentConfig.setEnvironment(Environment.stg);

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EnvironmentIndicator(),
          ),
        ),
      );

      // Assert
      expect(find.text('Staging Environment'), findsOneWidget);
      expect(find.byIcon(Icons.science), findsOneWidget);
    });

    testWidgets('renders detailed view when showDetails is true', (tester) async {
      // Arrange
      EnvironmentConfig.setEnvironment(Environment.dev);

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EnvironmentIndicator(showDetails: true),
          ),
        ),
      );

      // Assert
      expect(find.text('Development Environment'), findsOneWidget);
      expect(find.text('Project: playwithme-dev'), findsOneWidget);
      // Firebase is not initialized in tests, so should show 'Disconnected'
      expect(find.text('Disconnected'), findsOneWidget);
    });

    testWidgets('shows correct colors for different environments', (tester) async {
      // Test development environment color
      EnvironmentConfig.setEnvironment(Environment.dev);
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EnvironmentIndicator(),
          ),
        ),
      );

      // Find the container with the environment color
      final devContainer = tester.widget<Container>(
        find.ancestor(
          of: find.text('Development Environment'),
          matching: find.byType(Container),
        ),
      );
      final devDecoration = devContainer.decoration as BoxDecoration;
      expect(devDecoration.color, equals(Colors.red.shade600));

      // Test staging environment color
      EnvironmentConfig.setEnvironment(Environment.stg);
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EnvironmentIndicator(),
          ),
        ),
      );

      final stgContainer = tester.widget<Container>(
        find.ancestor(
          of: find.text('Staging Environment'),
          matching: find.byType(Container),
        ),
      );
      final stgDecoration = stgContainer.decoration as BoxDecoration;
      expect(stgDecoration.color, equals(Colors.orange.shade600));
    });
  });

  group('FirebaseDebugPanel', () {
    tearDown(() {
      // Reset to default environment after each test
      EnvironmentConfig.setEnvironment(Environment.prod);
    });

    testWidgets('does not render in non-development environments', (tester) async {
      // Test staging
      EnvironmentConfig.setEnvironment(Environment.stg);
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(children: [FirebaseDebugPanel()]),
          ),
        ),
      );
      expect(find.byType(FirebaseDebugPanel), findsOneWidget);
      expect(find.text('Debug'), findsNothing);

      // Test production
      EnvironmentConfig.setEnvironment(Environment.prod);
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(children: [FirebaseDebugPanel()]),
          ),
        ),
      );
      expect(find.text('Debug'), findsNothing);
    });

    testWidgets('renders collapsed debug panel in development', (tester) async {
      // Arrange
      EnvironmentConfig.setEnvironment(Environment.dev);

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(children: [FirebaseDebugPanel()]),
          ),
        ),
      );

      // Assert
      expect(find.text('Debug'), findsOneWidget);
      expect(find.byIcon(Icons.bug_report), findsOneWidget);
      expect(find.text('Firebase Debug Panel'), findsNothing);
    });

    testWidgets('expands debug panel when tapped', (tester) async {
      // Arrange
      EnvironmentConfig.setEnvironment(Environment.dev);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(children: [FirebaseDebugPanel()]),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Debug'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Firebase Debug Panel'), findsOneWidget);
      expect(find.text('Environment:'), findsOneWidget);
      expect(find.text('Project ID:'), findsOneWidget);
      expect(find.text('Test Connection'), findsOneWidget);
    });

    testWidgets('collapses debug panel when close is tapped', (tester) async {
      // Arrange
      EnvironmentConfig.setEnvironment(Environment.dev);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(children: [FirebaseDebugPanel()]),
          ),
        ),
      );

      // Expand the panel
      await tester.tap(find.text('Debug'));
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Firebase Debug Panel'), findsNothing);
      expect(find.text('Debug'), findsOneWidget);
    });

    testWidgets('shows correct environment information in debug panel', (tester) async {
      // Arrange
      EnvironmentConfig.setEnvironment(Environment.dev);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(children: [FirebaseDebugPanel()]),
          ),
        ),
      );

      // Expand the panel
      await tester.tap(find.text('Debug'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Development'), findsOneWidget);
      expect(find.text('playwithme-dev'), findsOneWidget);
      expect(find.text('false'), findsOneWidget); // isInitialized should be false in tests
    });
  });
}