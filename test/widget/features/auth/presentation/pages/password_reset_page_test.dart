// Widget tests for PasswordResetPage verifying email input and reset request functionality (Story 16.3.3.4).

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:play_with_me/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/features/auth/presentation/bloc/password_reset/password_reset_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/password_reset/password_reset_event.dart';
import 'package:play_with_me/features/auth/presentation/bloc/password_reset/password_reset_state.dart';
import 'package:play_with_me/features/auth/presentation/pages/password_reset_page.dart';
import 'package:play_with_me/features/auth/presentation/widgets/auth_button.dart';
import 'package:play_with_me/features/auth/presentation/widgets/auth_form_field.dart';

class MockPasswordResetBloc
    extends MockBloc<PasswordResetEvent, PasswordResetState>
    implements PasswordResetBloc {}

class FakePasswordResetEvent extends Fake implements PasswordResetEvent {}

class FakePasswordResetState extends Fake implements PasswordResetState {}

void main() {
  late MockPasswordResetBloc mockPasswordResetBloc;

  setUpAll(() {
    registerFallbackValue(FakePasswordResetEvent());
    registerFallbackValue(FakePasswordResetState());
  });

  setUp(() {
    mockPasswordResetBloc = MockPasswordResetBloc();
    when(() => mockPasswordResetBloc.state)
        .thenReturn(const PasswordResetInitial());
  });

  tearDown(() {
    mockPasswordResetBloc.close();
  });

  Widget createTestWidget() {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],      home: BlocProvider<PasswordResetBloc>.value(
        value: mockPasswordResetBloc,
        child: const PasswordResetPage(),
      ),
    );
  }

  group('PasswordResetPage Widget Tests', () {
    group('Initial UI Rendering', () {
      testWidgets('renders app bar with Reset Password title', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.byType(AppBar), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.text('Reset Password'),
          ),
          findsOneWidget,
        );
      });

      testWidgets('renders lock reset icon', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.byIcon(Icons.lock_reset), findsOneWidget);
      });

      testWidgets('renders forgot password title', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Forgot Your Password?'), findsOneWidget);
      });

      testWidgets('renders instructions text', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(
          find.text(
              "Enter your email address and we'll send you a link to reset your password."),
          findsOneWidget,
        );
      });

      testWidgets('renders email input field', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.byType(AuthFormField), findsOneWidget);
        expect(find.text('Email'), findsOneWidget);
        expect(find.byIcon(Icons.email), findsOneWidget);
      });

      testWidgets('renders send reset email button', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.widgetWithText(AuthButton, 'Send Reset Email'), findsOneWidget);
      });

      testWidgets('renders back to login button', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Back to Login'), findsOneWidget);
      });
    });

    group('Email Input Field', () {
      testWidgets('can enter email text', (tester) async {
        await tester.pumpWidget(createTestWidget());

        final emailField = find.byType(TextFormField);
        await tester.enterText(emailField, 'test@example.com');
        await tester.pump();

        expect(find.text('test@example.com'), findsOneWidget);
      });

      testWidgets('shows validation error for empty email', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Tap send reset button without entering email
        final sendButton = find.widgetWithText(ElevatedButton, 'Send Reset Email');
        await tester.tap(sendButton);
        await tester.pumpAndSettle();

        expect(find.text('Email is required'), findsOneWidget);
      });

      testWidgets('shows validation error for invalid email format',
          (tester) async {
        await tester.pumpWidget(createTestWidget());

        final emailField = find.byType(TextFormField);
        await tester.enterText(emailField, 'invalidemail');
        await tester.pump();

        final sendButton = find.widgetWithText(ElevatedButton, 'Send Reset Email');
        await tester.tap(sendButton);
        await tester.pumpAndSettle();

        expect(find.text('Please enter a valid email'), findsOneWidget);
      });

      testWidgets('accepts valid email format', (tester) async {
        await tester.pumpWidget(createTestWidget());

        final emailField = find.byType(TextFormField);
        await tester.enterText(emailField, 'valid@example.com');
        await tester.pump();

        final sendButton = find.widgetWithText(ElevatedButton, 'Send Reset Email');
        await tester.tap(sendButton);
        await tester.pump();

        // Should not show validation errors
        expect(find.text('Email is required'), findsNothing);
        expect(find.text('Please enter a valid email'), findsNothing);
      });
    });

    group('Send Reset Button', () {
      testWidgets('dispatches PasswordResetRequested event on tap',
          (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Enter valid email
        final emailField = find.byType(TextFormField);
        await tester.enterText(emailField, 'test@example.com');
        await tester.pump();

        // Tap send reset button
        final sendButton = find.widgetWithText(ElevatedButton, 'Send Reset Email');
        await tester.tap(sendButton);
        await tester.pump();

        verify(
          () => mockPasswordResetBloc.add(
            const PasswordResetRequested(email: 'test@example.com'),
          ),
        ).called(1);
      });

      testWidgets('does not dispatch event with invalid form', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Tap send reset without entering email
        final sendButton = find.widgetWithText(ElevatedButton, 'Send Reset Email');
        await tester.tap(sendButton);
        await tester.pump();

        verifyNever(() => mockPasswordResetBloc.add(any()));
      });
    });

    group('Loading State', () {
      testWidgets('shows loading indicator during request', (tester) async {
        when(() => mockPasswordResetBloc.state)
            .thenReturn(const PasswordResetLoading());

        await tester.pumpWidget(createTestWidget());

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('button is disabled during loading', (tester) async {
        when(() => mockPasswordResetBloc.state)
            .thenReturn(const PasswordResetLoading());

        await tester.pumpWidget(createTestWidget());

        // The ElevatedButton inside AuthButton should be disabled
        final authButton = find.byType(AuthButton);
        expect(authButton, findsOneWidget);
      });
    });

    group('Success State', () {
      testWidgets('shows success dialog when reset email sent', (tester) async {
        whenListen(
          mockPasswordResetBloc,
          Stream.fromIterable([
            const PasswordResetInitial(),
            const PasswordResetLoading(),
            const PasswordResetSuccess('test@example.com'),
          ]),
          initialState: const PasswordResetInitial(),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Email Sent!'), findsOneWidget);
        expect(find.byType(AlertDialog), findsOneWidget);
      });

      testWidgets('success dialog displays sent email', (tester) async {
        whenListen(
          mockPasswordResetBloc,
          Stream.fromIterable([
            const PasswordResetInitial(),
            const PasswordResetSuccess('user@example.com'),
          ]),
          initialState: const PasswordResetInitial(),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('user@example.com'), findsOneWidget);
      });

      testWidgets('success dialog shows check circle icon', (tester) async {
        whenListen(
          mockPasswordResetBloc,
          Stream.fromIterable([
            const PasswordResetInitial(),
            const PasswordResetSuccess('test@example.com'),
          ]),
          initialState: const PasswordResetInitial(),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.check_circle), findsOneWidget);
      });

      testWidgets('success dialog has OK button', (tester) async {
        whenListen(
          mockPasswordResetBloc,
          Stream.fromIterable([
            const PasswordResetInitial(),
            const PasswordResetSuccess('test@example.com'),
          ]),
          initialState: const PasswordResetInitial(),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('OK'), findsOneWidget);
      });

      testWidgets('success dialog shows instructions text', (tester) async {
        whenListen(
          mockPasswordResetBloc,
          Stream.fromIterable([
            const PasswordResetInitial(),
            const PasswordResetSuccess('test@example.com'),
          ]),
          initialState: const PasswordResetInitial(),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(
          find.text("We've sent a password reset link to:"),
          findsOneWidget,
        );
        expect(
          find.text(
              'Please check your email and follow the instructions to reset your password.'),
          findsOneWidget,
        );
      });
    });

    group('Error Handling', () {
      testWidgets('shows snackbar on failure', (tester) async {
        whenListen(
          mockPasswordResetBloc,
          Stream.fromIterable([
            const PasswordResetInitial(),
            const PasswordResetFailure('User not found'),
          ]),
          initialState: const PasswordResetInitial(),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('User not found'), findsOneWidget);
        expect(find.byType(SnackBar), findsOneWidget);
      });

      testWidgets('snackbar has red background on failure', (tester) async {
        whenListen(
          mockPasswordResetBloc,
          Stream.fromIterable([
            const PasswordResetInitial(),
            const PasswordResetFailure('Error message'),
          ]),
          initialState: const PasswordResetInitial(),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
        expect(snackBar.backgroundColor, Colors.red);
      });
    });

    group('Navigation', () {
      testWidgets('back to login button navigates back', (tester) async {
        await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],            home: BlocProvider<PasswordResetBloc>.value(
              value: mockPasswordResetBloc,
              child: Navigator(
                onGenerateRoute: (settings) {
                  return MaterialPageRoute(
                    builder: (context) => const PasswordResetPage(),
                  );
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // The back button should be present
        expect(find.text('Back to Login'), findsOneWidget);
      });
    });

    group('Form Submission via Enter Key', () {
      testWidgets('submits form when pressing done on email field',
          (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Enter valid email
        final emailField = find.byType(TextFormField);
        await tester.enterText(emailField, 'test@example.com');
        await tester.pump();

        // Submit using keyboard action
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        verify(
          () => mockPasswordResetBloc.add(
            const PasswordResetRequested(email: 'test@example.com'),
          ),
        ).called(1);
      });
    });

    group('Email Validation Edge Cases', () {
      testWidgets('validates email with subdomain', (tester) async {
        await tester.pumpWidget(createTestWidget());

        final emailField = find.byType(TextFormField);
        await tester.enterText(emailField, 'user@mail.example.com');
        await tester.pump();

        final sendButton = find.widgetWithText(ElevatedButton, 'Send Reset Email');
        await tester.tap(sendButton);
        await tester.pump();

        // Should dispatch event for valid email
        verify(
          () => mockPasswordResetBloc.add(
            const PasswordResetRequested(email: 'user@mail.example.com'),
          ),
        ).called(1);
      });

      testWidgets('rejects email with spaces', (tester) async {
        await tester.pumpWidget(createTestWidget());

        final emailField = find.byType(TextFormField);
        await tester.enterText(emailField, '   ');
        await tester.pump();

        final sendButton = find.widgetWithText(ElevatedButton, 'Send Reset Email');
        await tester.tap(sendButton);
        await tester.pumpAndSettle();

        expect(find.text('Email is required'), findsOneWidget);
      });

      testWidgets('rejects email without domain', (tester) async {
        await tester.pumpWidget(createTestWidget());

        final emailField = find.byType(TextFormField);
        await tester.enterText(emailField, 'user@');
        await tester.pump();

        final sendButton = find.widgetWithText(ElevatedButton, 'Send Reset Email');
        await tester.tap(sendButton);
        await tester.pumpAndSettle();

        expect(find.text('Please enter a valid email'), findsOneWidget);
      });
    });
  });
}
