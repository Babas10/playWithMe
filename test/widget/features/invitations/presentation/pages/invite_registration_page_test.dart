// Validates InviteRegistrationPage renders form fields, group context, validation, and state transitions correctly.
import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/features/invitations/presentation/bloc/invite_registration/invite_registration_bloc.dart';
import 'package:play_with_me/features/invitations/presentation/bloc/invite_registration/invite_registration_event.dart';
import 'package:play_with_me/features/invitations/presentation/bloc/invite_registration/invite_registration_state.dart';
import 'package:play_with_me/features/invitations/presentation/pages/invite_registration_page.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

class MockInviteRegistrationBloc
    extends MockBloc<InviteRegistrationEvent, InviteRegistrationState>
    implements InviteRegistrationBloc {}

void main() {
  late MockInviteRegistrationBloc mockBloc;

  setUpAll(() {
    registerFallbackValue(const InviteRegistrationFormReset());
    registerFallbackValue(const InviteRegistrationInitial());
  });

  setUp(() {
    mockBloc = MockInviteRegistrationBloc();
    when(() => mockBloc.state).thenReturn(const InviteRegistrationInitial());
  });

  tearDown(() {
    mockBloc.close();
  });

  Widget createTestWidget({
    String token = 'test-token',
    String groupName = 'Beach Volleyball Crew',
    String inviterName = 'Etienne',
  }) {
    return MaterialApp(
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
      home: InviteRegistrationPage(
        token: token,
        groupName: groupName,
        inviterName: inviterName,
        blocOverride: mockBloc,
      ),
    );
  }

  /// Helper to scroll the submit button into view and tap it.
  Future<void> scrollAndTapSubmit(WidgetTester tester) async {
    final submitButton = find.text('Create Account & Join');
    await tester.ensureVisible(submitButton);
    await tester.pumpAndSettle();
    await tester.tap(submitButton);
    await tester.pumpAndSettle();
  }

  group('InviteRegistrationPage', () {
    group('renders correctly', () {
      testWidgets('shows group context banner with group name and inviter',
          (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Create your account to join:'), findsOneWidget);
        expect(find.text('Beach Volleyball Crew'), findsOneWidget);
        expect(find.text('Invited by Etienne'), findsOneWidget);
      });

      testWidgets('shows all form fields', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('First Name'), findsOneWidget);
        expect(find.text('Last Name'), findsOneWidget);
        expect(find.text('Display Name'), findsOneWidget);
        expect(find.text('Email'), findsOneWidget);
        expect(find.text('Password'), findsOneWidget);
        await tester.ensureVisible(find.text('Confirm Password'));
        expect(find.text('Confirm Password'), findsOneWidget);
      });

      testWidgets('shows password requirements hint', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.ensureVisible(
          find.text('At least 8 characters, 1 uppercase letter, 1 number'),
        );

        expect(
          find.text('At least 8 characters, 1 uppercase letter, 1 number'),
          findsOneWidget,
        );
      });

      testWidgets('shows create account and join button', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.ensureVisible(find.text('Create Account & Join'));

        expect(find.text('Create Account & Join'), findsOneWidget);
      });

      testWidgets('shows already have account link', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.ensureVisible(
            find.text('Already have an account? Log in'));

        expect(
            find.text('Already have an account? Log in'), findsOneWidget);
      });

      testWidgets('shows app bar with Create Account title', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Create Account'), findsOneWidget);
      });
    });

    group('form validation', () {
      testWidgets('validates first name is required', (tester) async {
        await tester.pumpWidget(createTestWidget());

        await scrollAndTapSubmit(tester);

        expect(find.text('First name is required'), findsOneWidget);
      });

      testWidgets('validates first name minimum length', (tester) async {
        await tester.pumpWidget(createTestWidget());

        await tester.enterText(
            find.widgetWithText(TextFormField, 'First Name'), 'J');
        await scrollAndTapSubmit(tester);

        expect(find.text('First name must be at least 2 characters'),
            findsOneWidget);
      });

      testWidgets('validates last name is required', (tester) async {
        await tester.pumpWidget(createTestWidget());

        await tester.enterText(
            find.widgetWithText(TextFormField, 'First Name'), 'John');
        await scrollAndTapSubmit(tester);

        expect(find.text('Last name is required'), findsOneWidget);
      });

      testWidgets('validates display name is required', (tester) async {
        await tester.pumpWidget(createTestWidget());

        await tester.enterText(
            find.widgetWithText(TextFormField, 'First Name'), 'John');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Last Name'), 'Doe');
        await scrollAndTapSubmit(tester);

        expect(find.text('Display name is required'), findsOneWidget);
      });

      testWidgets('validates display name minimum length', (tester) async {
        await tester.pumpWidget(createTestWidget());

        await tester.enterText(
            find.widgetWithText(TextFormField, 'First Name'), 'John');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Last Name'), 'Doe');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Display Name'), 'JD');
        await scrollAndTapSubmit(tester);

        expect(find.text('Display name must be at least 3 characters'),
            findsOneWidget);
      });

      testWidgets('validates email is required', (tester) async {
        await tester.pumpWidget(createTestWidget());

        await tester.enterText(
            find.widgetWithText(TextFormField, 'First Name'), 'John');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Last Name'), 'Doe');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Display Name'), 'JohnD');
        await scrollAndTapSubmit(tester);

        expect(find.text('Email is required'), findsOneWidget);
      });

      testWidgets('validates password is required', (tester) async {
        await tester.pumpWidget(createTestWidget());

        await tester.enterText(
            find.widgetWithText(TextFormField, 'First Name'), 'John');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Last Name'), 'Doe');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Display Name'), 'JohnD');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Email'), 'john@example.com');
        await scrollAndTapSubmit(tester);

        expect(find.text('Password is required'), findsOneWidget);
      });

      testWidgets('validates password minimum length', (tester) async {
        await tester.pumpWidget(createTestWidget());

        await tester.enterText(
            find.widgetWithText(TextFormField, 'First Name'), 'John');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Last Name'), 'Doe');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Display Name'), 'JohnD');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Email'), 'john@example.com');
        await tester.ensureVisible(
            find.widgetWithText(TextFormField, 'Password'));
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Password'), 'Pass1');
        await scrollAndTapSubmit(tester);

        expect(find.text('Password must be at least 8 characters'),
            findsOneWidget);
      });

      testWidgets('validates confirm password matches', (tester) async {
        await tester.pumpWidget(createTestWidget());

        await tester.enterText(
            find.widgetWithText(TextFormField, 'First Name'), 'John');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Last Name'), 'Doe');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Display Name'), 'JohnD');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Email'), 'john@example.com');
        await tester.ensureVisible(
            find.widgetWithText(TextFormField, 'Password'));
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Password'), 'Password1');
        await tester.ensureVisible(
            find.widgetWithText(TextFormField, 'Confirm Password'));
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Confirm Password'),
            'Password2');
        await scrollAndTapSubmit(tester);

        expect(find.text('Passwords do not match'), findsOneWidget);
      });
    });

    group('state-driven behavior', () {
      testWidgets('shows loading indicator when creating account',
          (tester) async {
        when(() => mockBloc.state)
            .thenReturn(const InviteRegistrationCreatingAccount());

        await tester.pumpWidget(createTestWidget());

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('shows loading indicator when joining group',
          (tester) async {
        when(() => mockBloc.state)
            .thenReturn(const InviteRegistrationJoiningGroup());

        await tester.pumpWidget(createTestWidget());

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('shows error snackbar on failure', (tester) async {
        final controller =
            StreamController<InviteRegistrationState>.broadcast();
        whenListen(
          mockBloc,
          controller.stream,
          initialState: const InviteRegistrationInitial(),
        );

        await tester.pumpWidget(createTestWidget());

        controller.add(const InviteRegistrationFailure(
          message: 'An account with this email already exists.',
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(
          find.text('An account with this email already exists.'),
          findsOneWidget,
        );

        controller.close();
      });

      testWidgets('shows token expired snackbar and navigates to login',
          (tester) async {
        final controller =
            StreamController<InviteRegistrationState>.broadcast();
        whenListen(
          mockBloc,
          controller.stream,
          initialState: const InviteRegistrationInitial(),
        );

        await tester.pumpWidget(createTestWidget());

        controller.add(const InviteRegistrationTokenExpired());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(
          find.text(
              'The invite link has expired, but your account was created successfully.'),
          findsOneWidget,
        );

        await tester.pumpAndSettle();
        expect(find.text('Login Page'), findsOneWidget);

        controller.close();
      });
    });

    group('navigation', () {
      testWidgets('already have account link navigates to login',
          (tester) async {
        await tester.pumpWidget(createTestWidget());

        final link = find.text('Already have an account? Log in');
        await tester.ensureVisible(link);
        await tester.pumpAndSettle();
        await tester.tap(link);
        await tester.pumpAndSettle();

        expect(find.text('Login Page'), findsOneWidget);
      });
    });

    group('form submission', () {
      testWidgets('dispatches event when form is valid and submitted',
          (tester) async {
        await tester.pumpWidget(createTestWidget());

        await tester.enterText(
            find.widgetWithText(TextFormField, 'First Name'), 'John');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Last Name'), 'Doe');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Display Name'), 'JohnD');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Email'), 'john@example.com');
        await tester.ensureVisible(
            find.widgetWithText(TextFormField, 'Password'));
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Password'), 'Password1');
        await tester.ensureVisible(
            find.widgetWithText(TextFormField, 'Confirm Password'));
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Confirm Password'),
            'Password1');

        await scrollAndTapSubmit(tester);

        verify(() => mockBloc.add(const InviteRegistrationSubmitted(
              firstName: 'John',
              lastName: 'Doe',
              displayName: 'JohnD',
              email: 'john@example.com',
              password: 'Password1',
              confirmPassword: 'Password1',
              token: 'test-token',
            ))).called(1);
      });

      testWidgets('does not dispatch event when form is invalid',
          (tester) async {
        await tester.pumpWidget(createTestWidget());

        await scrollAndTapSubmit(tester);

        verifyNever(() => mockBloc.add(any()));
      });
    });
  });
}
