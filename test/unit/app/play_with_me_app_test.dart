// Verifies that PlayWithMeApp correctly handles authentication state transitions and UI updates
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/app/play_with_me_app.dart';
import 'package:play_with_me/core/config/environment_config.dart';
import 'package:play_with_me/core/services/service_locator.dart';
import 'package:play_with_me/features/profile/domain/entities/locale_preferences_entity.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_bloc.dart';
import 'package:play_with_me/core/presentation/bloc/invitation/invitation_bloc.dart';
import 'package:play_with_me/features/games/presentation/bloc/game_invitations/game_invitations_bloc.dart';
import 'package:play_with_me/l10n/app_localizations.dart';
import '../helpers/test_helpers.dart';
import '../features/auth/data/mock_auth_repository.dart';

// Fake for mocktail matchers
class FakeLocalePreferencesEntity extends Fake
    implements LocalePreferencesEntity {}

void main() {
  setUpAll(() {
    // Register fallback values for mocktail matchers
    registerFallbackValue(FakeLocalePreferencesEntity());
  });

  group('PlayWithMeApp', () {
    setUp(() async {
      EnvironmentConfig.setEnvironment(Environment.prod);
      await initializeTestDependencies();
    });

    tearDown(() {
      cleanupTestDependencies();
    });

    testWidgets('should render correctly in production environment', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const PlayWithMeApp());

      // Wait for AuthenticationBloc to process initial auth state and stream subscription
      await tester.pump(); // Initial build
      await tester.pump(
        const Duration(milliseconds: 10),
      ); // Allow bloc to start stream subscription
      await tester.pump(
        const Duration(milliseconds: 10),
      ); // Allow stream to emit initial value
      await tester.pump(); // Rebuild with new state

      // Should show login screen for unauthenticated users
      expect(find.text('Welcome!'), findsOneWidget);
      expect(
        find.text('Sign in to continue organizing your volleyball games'),
        findsOneWidget,
      );
    });

    testWidgets('should render correctly in development environment', (
      WidgetTester tester,
    ) async {
      EnvironmentConfig.setEnvironment(Environment.dev);
      await tester.pumpWidget(const PlayWithMeApp());

      // Wait for AuthenticationBloc to process initial auth state and stream subscription
      await tester.pump(); // Initial build
      await tester.pump(
        const Duration(milliseconds: 10),
      ); // Allow bloc to start stream subscription
      await tester.pump(
        const Duration(milliseconds: 10),
      ); // Allow stream to emit initial value
      await tester.pump(); // Rebuild with new state

      // App shows authentication screen regardless of environment
      expect(find.text('Welcome!'), findsOneWidget);
      expect(
        find.text('Sign in to continue organizing your volleyball games'),
        findsOneWidget,
      );
    });

    testWidgets('should have correct theme colors', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const PlayWithMeApp());

      // Wait for AuthenticationBloc to process initial auth state and stream subscription
      await tester.pump(); // Initial build
      await tester.pump(
        const Duration(milliseconds: 10),
      ); // Allow bloc to start stream subscription
      await tester.pump(
        const Duration(milliseconds: 10),
      ); // Allow stream to emit initial value
      await tester.pump(); // Rebuild with new state

      final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));
      expect(materialApp.theme?.colorScheme.primary, isNotNull);
    });

    testWidgets('should have correct app title for each environment', (
      WidgetTester tester,
    ) async {
      // Test production
      EnvironmentConfig.setEnvironment(Environment.prod);
      await tester.pumpWidget(const PlayWithMeApp());
      // Wait for AuthenticationBloc to process initial auth state and stream subscription
      await tester.pump(); // Initial build
      await tester.pump(
        const Duration(milliseconds: 10),
      ); // Allow bloc to start stream subscription
      await tester.pump(
        const Duration(milliseconds: 10),
      ); // Allow stream to emit initial value
      await tester.pump(); // Rebuild with new state
      MaterialApp materialApp = tester.widget(find.byType(MaterialApp));
      expect(materialApp.title, 'Gatherli');

      // Test development
      EnvironmentConfig.setEnvironment(Environment.dev);
      await tester.pumpWidget(const PlayWithMeApp());
      // Wait for AuthenticationBloc to process initial auth state and stream subscription
      await tester.pump(); // Initial build
      await tester.pump(
        const Duration(milliseconds: 10),
      ); // Allow bloc to start stream subscription
      await tester.pump(
        const Duration(milliseconds: 10),
      ); // Allow stream to emit initial value
      await tester.pump(); // Rebuild with new state
      materialApp = tester.widget(find.byType(MaterialApp));
      expect(materialApp.title, 'Gatherli (Dev)');
    });

    testWidgets(
      'should properly handle authentication state transitions (Unknown → Unauthenticated → UI update)',
      (WidgetTester tester) async {
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
        await tester.pump(
          const Duration(milliseconds: 10),
        ); // Allow bloc to start stream subscription
        await tester.pump(
          const Duration(milliseconds: 10),
        ); // Allow stream to emit initial null value
        await tester.pump(); // Rebuild with new unauthenticated state

        // Should transition to login screen (Unauthenticated state)
        expect(find.text('Welcome!'), findsOneWidget);
        expect(
          find.text('Sign in to continue organizing your volleyball games'),
          findsOneWidget,
        );

        // Should no longer show splash screen elements
        expect(find.text('Loading...'), findsNothing);
        expect(find.byType(CircularProgressIndicator), findsNothing);

        // Simulate user authentication by setting a user
        final mockRepo = getTestAuthRepository()!;
        const testUser = TestUserData.testUser;
        mockRepo.setCurrentUser(testUser);

        // Allow authentication bloc to process the state change
        await tester.pump(
          const Duration(milliseconds: 10),
        ); // Allow stream emission
        await tester
            .pump(); // AuthenticationAuthenticated emitted → HomePage rendered

        // Should transition to HomePage (Authenticated state)
        // Bottom nav now has: Home, Stats, Groups, Community (Profile is in AppBar)
        expect(find.byType(Scaffold), findsWidgets); // HomePage rendered
        expect(find.byType(BottomNavigationBar), findsOneWidget);

        // Should no longer show login screen elements
        expect(find.text('Welcome!'), findsNothing);
        expect(
          find.text('Sign in to continue organizing your volleyball games'),
          findsNothing,
        );
      },
    );
  });

  group('HomePage', () {
    setUp(() async {
      EnvironmentConfig.setEnvironment(Environment.prod);
      await initializeTestDependencies();
    });

    tearDown(() {
      cleanupTestDependencies();
    });

    testWidgets('should render correctly', (WidgetTester tester) async {
      // Set up authenticated user for HomePage
      final mockRepo = getTestAuthRepository()!;
      const testUser = TestUserData.testUser;
      mockRepo.setCurrentUser(testUser);

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthenticationBloc>(
              create: (context) => sl<AuthenticationBloc>(),
            ),
            BlocProvider<InvitationBloc>(
              create: (context) => sl<InvitationBloc>(),
            ),
            BlocProvider<GameInvitationsBloc>(
              create: (context) => sl<GameInvitationsBloc>(),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('en')],
            home: HomePage(),
          ),
        ),
      );

      await tester.pump(); // Initial build
      await tester.pump(
        const Duration(milliseconds: 10),
      ); // Allow bloc to start stream subscription
      await tester.pump(
        const Duration(milliseconds: 10),
      ); // Allow stream to emit user value
      await tester.pump(); // Rebuild with authenticated state

      expect(find.byType(AppBar), findsOneWidget);
      // First tab (Home) shows app title as AppBar title
      expect(find.text('Gatherli'), findsOneWidget);
      // Bottom navigation has 4 tabs: Home, Stats, Groups, Community (Profile is in AppBar)
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should have correct layout structure', (
      WidgetTester tester,
    ) async {
      // Set up authenticated user for HomePage
      final mockRepo = getTestAuthRepository()!;
      const testUser = TestUserData.testUser;
      mockRepo.setCurrentUser(testUser);

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthenticationBloc>(
              create: (context) => sl<AuthenticationBloc>(),
            ),
            BlocProvider<InvitationBloc>(
              create: (context) => sl<InvitationBloc>(),
            ),
            BlocProvider<GameInvitationsBloc>(
              create: (context) => sl<GameInvitationsBloc>(),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('en')],
            home: HomePage(),
          ),
        ),
      );

      await tester.pump(); // Allow initial build

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      // Home tab widgets are loaded
      // Note: Stats may be loading or empty in test environment
    });

    testWidgets('should show correct environment indicator colors', (
      WidgetTester tester,
    ) async {
      // SKIP: Environment indicators removed from home screen (Story #301)
    });
  });
}
