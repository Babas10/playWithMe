// Tests for ProfilePage widget to ensure proper display of user information and navigation functionality.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_state.dart';
import 'package:play_with_me/features/auth/presentation/pages/profile_page.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  group('ProfilePage', () {
    setUp(() async {
      await initializeTestDependencies();
    });

    tearDown(() {
      cleanupTestDependencies();
    });

    testWidgets('displays loading view when authentication state is unknown', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthenticationBloc>(
            create: (context) => AuthenticationBloc(authRepository: getTestAuthRepository()!),
            child: const ProfilePage(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading profile...'), findsOneWidget);
    });

    testWidgets('displays unauthenticated view when user is not signed in', (tester) async {
      final mockRepo = getTestAuthRepository()!;
      mockRepo.setCurrentUser(null);

      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/login': (context) => const Scaffold(body: Text('Login Page')),
          },
          home: BlocProvider<AuthenticationBloc>(
            create: (context) => AuthenticationBloc(authRepository: mockRepo),
            child: const ProfilePage(),
          ),
        ),
      );

      await tester.pump();

      expect(find.byIcon(Icons.person_off), findsOneWidget);
      expect(find.text('Not Signed In'), findsOneWidget);
      expect(find.text('Please sign in to view your profile'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('navigates to login when sign in button is tapped', (tester) async {
      final mockRepo = getTestAuthRepository()!;
      mockRepo.setCurrentUser(null);

      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/login': (context) => const Scaffold(body: Text('Login Page')),
          },
          home: BlocProvider<AuthenticationBloc>(
            create: (context) => AuthenticationBloc(authRepository: mockRepo),
            child: const ProfilePage(),
          ),
        ),
      );

      await tester.pump();

      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Login Page'), findsOneWidget);
    });

    testWidgets('displays profile content when user is authenticated', (tester) async {
      final testUser = UserEntity(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        isEmailVerified: true,
        isAnonymous: false,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        lastSignInAt: DateTime.now().subtract(const Duration(hours: 2)),
      );

      final mockRepo = getTestAuthRepository()!;
      mockRepo.setCurrentUser(testUser);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthenticationBloc>(
            create: (context) => AuthenticationBloc(authRepository: mockRepo),
            child: const ProfilePage(),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Account Settings'), findsOneWidget);
      expect(find.text('Sign Out'), findsOneWidget);
    });

    testWidgets('shows verification badge when email is not verified', (tester) async {
      final testUser = UserEntity(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        isEmailVerified: false,
        isAnonymous: false,
      );

      final mockRepo = getTestAuthRepository()!;
      mockRepo.setCurrentUser(testUser);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthenticationBloc>(
            create: (context) => AuthenticationBloc(authRepository: mockRepo),
            child: const ProfilePage(),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Email not verified'), findsOneWidget);
      expect(find.text('Verify Email'), findsOneWidget);
    });

    testWidgets('shows account type badge for anonymous user', (tester) async {
      final testUser = UserEntity(
        uid: 'test-uid',
        email: 'anonymous@example.com',
        displayName: null,
        isEmailVerified: false,
        isAnonymous: true,
      );

      final mockRepo = getTestAuthRepository()!;
      mockRepo.setCurrentUser(testUser);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthenticationBloc>(
            create: (context) => AuthenticationBloc(authRepository: mockRepo),
            child: const ProfilePage(),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Guest Account'), findsOneWidget);
    });

    testWidgets('shows registered user badge for regular user', (tester) async {
      final testUser = UserEntity(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        isEmailVerified: true,
        isAnonymous: false,
      );

      final mockRepo = getTestAuthRepository()!;
      mockRepo.setCurrentUser(testUser);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthenticationBloc>(
            create: (context) => AuthenticationBloc(authRepository: mockRepo),
            child: const ProfilePage(),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Registered User'), findsOneWidget);
    });

    testWidgets('shows coming soon message when edit profile is tapped', (tester) async {
      final testUser = UserEntity(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        isEmailVerified: true,
        isAnonymous: false,
      );

      final mockRepo = getTestAuthRepository()!;
      mockRepo.setCurrentUser(testUser);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthenticationBloc>(
            create: (context) => AuthenticationBloc(authRepository: mockRepo),
            child: const ProfilePage(),
          ),
        ),
      );

      await tester.pump();

      await tester.tap(find.text('Edit Profile'));
      await tester.pump();

      expect(find.text('Edit Profile - Coming Soon'), findsOneWidget);
    });

    testWidgets('shows coming soon message when account settings is tapped', (tester) async {
      final testUser = UserEntity(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        isEmailVerified: true,
        isAnonymous: false,
      );

      final mockRepo = getTestAuthRepository()!;
      mockRepo.setCurrentUser(testUser);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthenticationBloc>(
            create: (context) => AuthenticationBloc(authRepository: mockRepo),
            child: const ProfilePage(),
          ),
        ),
      );

      await tester.pump();

      await tester.tap(find.text('Account Settings'));
      await tester.pump();

      expect(find.text('Account Settings - Coming Soon'), findsOneWidget);
    });

    testWidgets('shows sign out dialog when sign out is tapped', (tester) async {
      final testUser = UserEntity(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        isEmailVerified: true,
        isAnonymous: false,
      );

      final mockRepo = getTestAuthRepository()!;
      mockRepo.setCurrentUser(testUser);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthenticationBloc>(
            create: (context) => AuthenticationBloc(authRepository: mockRepo),
            child: const ProfilePage(),
          ),
        ),
      );

      await tester.pump();

      await tester.tap(find.text('Sign Out'));
      await tester.pump();

      expect(find.text('Sign Out'), findsNWidgets(2)); // Button and dialog title
      expect(find.text('Are you sure you want to sign out?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('cancels sign out when cancel is tapped', (tester) async {
      final testUser = UserEntity(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        isEmailVerified: true,
        isAnonymous: false,
      );

      final mockRepo = getTestAuthRepository()!;
      mockRepo.setCurrentUser(testUser);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthenticationBloc>(
            create: (context) => AuthenticationBloc(authRepository: mockRepo),
            child: const ProfilePage(),
          ),
        ),
      );

      await tester.pump();

      await tester.tap(find.text('Sign Out'));
      await tester.pump();

      await tester.tap(find.text('Cancel'));
      await tester.pump();

      expect(find.text('Are you sure you want to sign out?'), findsNothing);
    });

    testWidgets('displays fallback to email when display name is null', (tester) async {
      final testUser = UserEntity(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: null,
        isEmailVerified: true,
        isAnonymous: false,
      );

      final mockRepo = getTestAuthRepository()!;
      mockRepo.setCurrentUser(testUser);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthenticationBloc>(
            create: (context) => AuthenticationBloc(authRepository: mockRepo),
            child: const ProfilePage(),
          ),
        ),
      );

      await tester.pump();

      // Should display email as the display name
      expect(find.text('test@example.com'), findsNWidgets(2)); // Header and email field
    });

    testWidgets('displays account information correctly', (tester) async {
      final testUser = UserEntity(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        isEmailVerified: true,
        isAnonymous: false,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        lastSignInAt: DateTime.now().subtract(const Duration(hours: 2)),
      );

      final mockRepo = getTestAuthRepository()!;
      mockRepo.setCurrentUser(testUser);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthenticationBloc>(
            create: (context) => AuthenticationBloc(authRepository: mockRepo),
            child: const ProfilePage(),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Account Information'), findsOneWidget);
      expect(find.text('Member since'), findsOneWidget);
      expect(find.text('Last sign-in'), findsOneWidget);
      expect(find.text('Authentication'), findsOneWidget);
      expect(find.text('Email verification'), findsOneWidget);
      expect(find.text('Email & Password'), findsOneWidget);
      expect(find.text('Verified'), findsOneWidget);
    });

    testWidgets('has proper app bar with title', (tester) async {
      final testUser = UserEntity(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        isEmailVerified: true,
        isAnonymous: false,
      );

      final mockRepo = getTestAuthRepository()!;
      mockRepo.setCurrentUser(testUser);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthenticationBloc>(
            create: (context) => AuthenticationBloc(authRepository: mockRepo),
            child: const ProfilePage(),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Profile'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });
  });
}