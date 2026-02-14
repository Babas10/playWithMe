// Validates InviteOnboardingPage renders correct UI states for validating, validated, invalid, and error states.

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/features/invitations/presentation/bloc/invite_join/invite_join_bloc.dart';
import 'package:play_with_me/features/invitations/presentation/bloc/invite_join/invite_join_event.dart';
import 'package:play_with_me/features/invitations/presentation/bloc/invite_join/invite_join_state.dart';
import 'package:play_with_me/features/invitations/presentation/bloc/invite_registration/invite_registration_bloc.dart';
import 'package:play_with_me/features/invitations/presentation/bloc/invite_registration/invite_registration_event.dart';
import 'package:play_with_me/features/invitations/presentation/bloc/invite_registration/invite_registration_state.dart';
import 'package:play_with_me/features/invitations/presentation/pages/invite_onboarding_page.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

class MockInviteJoinBloc
    extends MockBloc<InviteJoinEvent, InviteJoinState>
    implements InviteJoinBloc {}

class MockInviteRegistrationBloc
    extends MockBloc<InviteRegistrationEvent, InviteRegistrationState>
    implements InviteRegistrationBloc {}

void main() {
  late MockInviteJoinBloc mockBloc;

  setUpAll(() {
    registerFallbackValue(const ValidateInviteToken(''));
    registerFallbackValue(const InviteJoinInitial());
    registerFallbackValue(const InviteRegistrationFormReset());
    registerFallbackValue(const InviteRegistrationInitial());
  });

  setUp(() {
    mockBloc = MockInviteJoinBloc();

    // Register mock InviteRegistrationBloc in GetIt for navigation tests
    final sl = GetIt.instance;
    if (sl.isRegistered<InviteRegistrationBloc>()) {
      sl.unregister<InviteRegistrationBloc>();
    }
    final mockRegBloc = MockInviteRegistrationBloc();
    when(() => mockRegBloc.state)
        .thenReturn(const InviteRegistrationInitial());
    sl.registerFactory<InviteRegistrationBloc>(() => mockRegBloc);
  });

  tearDown(() {
    mockBloc.close();
    final sl = GetIt.instance;
    if (sl.isRegistered<InviteRegistrationBloc>()) {
      sl.unregister<InviteRegistrationBloc>();
    }
  });

  Widget createTestWidget({String token = 'test-token'}) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: BlocProvider<InviteJoinBloc>.value(
        value: mockBloc,
        child: InviteOnboardingPage(token: token),
      ),
    );
  }

  group('InviteOnboardingPage', () {
    group('loading state', () {
      testWidgets('shows loading indicator when validating', (tester) async {
        when(() => mockBloc.state).thenReturn(const InviteJoinValidating());

        await tester.pumpWidget(createTestWidget());

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Validating invite...'), findsOneWidget);
      });

      testWidgets('shows loading indicator for initial state', (tester) async {
        when(() => mockBloc.state).thenReturn(const InviteJoinInitial());

        await tester.pumpWidget(createTestWidget());

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('validated state', () {
      const validatedState = InviteJoinValidated(
        groupId: 'group-123',
        groupName: 'Beach Volleyball Crew',
        groupDescription: 'Weekend players',
        memberCount: 8,
        inviterName: 'John Doe',
        token: 'test-token',
      );

      testWidgets('shows group name and inviter info', (tester) async {
        when(() => mockBloc.state).thenReturn(validatedState);

        await tester.pumpWidget(createTestWidget());

        expect(find.text('Beach Volleyball Crew'), findsOneWidget);
        expect(find.text('Invited by John Doe'), findsOneWidget);
        expect(find.text('8 members'), findsOneWidget);
      });

      testWidgets('shows onboarding title and subtitle', (tester) async {
        when(() => mockBloc.state).thenReturn(validatedState);

        await tester.pumpWidget(createTestWidget());

        expect(find.text("You've been invited!"), findsOneWidget);
        expect(find.text("You've been invited to join:"), findsOneWidget);
      });

      testWidgets('shows create account and login buttons', (tester) async {
        when(() => mockBloc.state).thenReturn(validatedState);

        await tester.pumpWidget(createTestWidget());

        expect(find.text('Create Account'), findsOneWidget);
        expect(find.text('I have an account'), findsOneWidget);
      });

      testWidgets('create account button navigates to InviteRegistrationPage',
          (tester) async {
        when(() => mockBloc.state).thenReturn(validatedState);

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en')],
            home: BlocProvider<InviteJoinBloc>.value(
              value: mockBloc,
              child: const InviteOnboardingPage(token: 'test-token'),
            ),
          ),
        );

        await tester.tap(find.text('Create Account'));
        await tester.pumpAndSettle();

        // Verifies navigation to InviteRegistrationPage with group context
        expect(find.text('Create your account to join:'), findsOneWidget);
        expect(find.text('Beach Volleyball Crew'), findsOneWidget);
      });

      testWidgets('login button navigates to /login', (tester) async {
        when(() => mockBloc.state).thenReturn(validatedState);

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en')],
            routes: {
              '/login': (_) => const Scaffold(body: Text('Login Page')),
            },
            home: BlocProvider<InviteJoinBloc>.value(
              value: mockBloc,
              child: const InviteOnboardingPage(token: 'test-token'),
            ),
          ),
        );

        await tester.tap(find.text('I have an account'));
        await tester.pumpAndSettle();

        expect(find.text('Login Page'), findsOneWidget);
      });
    });

    group('invalid token state', () {
      testWidgets('shows error icon and reason message', (tester) async {
        when(() => mockBloc.state).thenReturn(
          const InviteJoinInvalidToken(reason: 'This invite has expired'),
        );

        await tester.pumpWidget(createTestWidget());

        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.text('This invite has expired'), findsOneWidget);
        expect(find.text('Continue to app'), findsOneWidget);
      });

      testWidgets('continue button navigates to /login', (tester) async {
        when(() => mockBloc.state).thenReturn(
          const InviteJoinInvalidToken(reason: 'Expired'),
        );

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en')],
            routes: {
              '/login': (_) => const Scaffold(body: Text('Login Page')),
            },
            home: BlocProvider<InviteJoinBloc>.value(
              value: mockBloc,
              child: const InviteOnboardingPage(token: 'test-token'),
            ),
          ),
        );

        await tester.tap(find.text('Continue to app'));
        await tester.pumpAndSettle();

        expect(find.text('Login Page'), findsOneWidget);
      });
    });

    group('error state', () {
      testWidgets('shows error icon and error message', (tester) async {
        when(() => mockBloc.state).thenReturn(
          const InviteJoinError(message: 'Network error occurred'),
        );

        await tester.pumpWidget(createTestWidget());

        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.text('Network error occurred'), findsOneWidget);
        expect(find.text('Continue to app'), findsOneWidget);
      });
    });
  });
}
