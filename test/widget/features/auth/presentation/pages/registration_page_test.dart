// Widget tests for RegistrationPage verifying UI rendering and user interactions.
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:play_with_me/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/features/auth/presentation/bloc/registration/registration_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/registration/registration_event.dart';
import 'package:play_with_me/features/auth/presentation/bloc/registration/registration_state.dart';
import 'package:play_with_me/features/auth/presentation/pages/registration_page.dart';
import 'package:play_with_me/features/auth/presentation/widgets/auth_button.dart';
import 'package:play_with_me/features/auth/presentation/widgets/auth_form_field.dart';

class MockRegistrationBloc
    extends MockBloc<RegistrationEvent, RegistrationState>
    implements RegistrationBloc {}

class FakeRegistrationEvent extends Fake implements RegistrationEvent {}

class FakeRegistrationState extends Fake implements RegistrationState {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late MockRegistrationBloc mockRegistrationBloc;
  late MockNavigatorObserver mockNavigatorObserver;

  setUpAll(() {
    registerFallbackValue(FakeRegistrationEvent());
    registerFallbackValue(FakeRegistrationState());
    registerFallbackValue(MaterialPageRoute<void>(builder: (_) => Container()));
  });

  setUp(() {
    mockRegistrationBloc = MockRegistrationBloc();
    mockNavigatorObserver = MockNavigatorObserver();
    when(() => mockRegistrationBloc.state)
        .thenReturn(const RegistrationInitial());
  });

  tearDown(() {
    mockRegistrationBloc.close();
  });

  Widget createTestWidget({bool withNavigatorObserver = false}) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],      home: BlocProvider<RegistrationBloc>.value(
        value: mockRegistrationBloc,
        child: const RegistrationPage(),
      ),
      navigatorObservers:
          withNavigatorObserver ? [mockNavigatorObserver] : [],
    );
  }

  group('RegistrationPage Widget Tests', () {
    group('Initial UI Rendering', () {
      testWidgets('renders app bar with Create Account title', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.byType(AppBar), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.text('Create Account'),
          ),
          findsOneWidget,
        );
      });

      testWidgets('renders welcome text', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Join PlayWithMe!'), findsOneWidget);
        expect(
          find.text('Create your account to start organizing volleyball games'),
          findsOneWidget,
        );
      });

      testWidgets('renders volleyball icon', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.byIcon(Icons.sports_volleyball), findsOneWidget);
      });

      testWidgets('renders email input field', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.byType(AuthFormField), findsNWidgets(4));
        expect(find.text('Email'), findsOneWidget);
        expect(find.byIcon(Icons.email), findsOneWidget);
      });

      testWidgets('renders display name input field', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Display Name (Optional)'), findsOneWidget);
        expect(find.byIcon(Icons.person), findsOneWidget);
      });

      testWidgets('renders password input field', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Password'), findsOneWidget);
      });

      testWidgets('renders confirm password input field', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Confirm Password'), findsOneWidget);
      });

      testWidgets('renders create account button', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(
          find.widgetWithText(AuthButton, 'Create Account'),
          findsOneWidget,
        );
      });

      testWidgets('renders sign in link', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Already have an account? '), findsOneWidget);
        expect(find.text('Sign In'), findsOneWidget);
      });

      testWidgets('renders terms and privacy text', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Scroll to ensure the text is visible
        final termsText = find.textContaining('Terms of Service');
        await tester.ensureVisible(termsText);
        await tester.pumpAndSettle();

        expect(
          find.textContaining('Terms of Service'),
          findsOneWidget,
        );
        expect(
          find.textContaining('Privacy Policy'),
          findsOneWidget,
        );
      });
    });

    group('Email Input Field', () {
      testWidgets('can enter email text', (tester) async {
        await tester.pumpWidget(createTestWidget());

        final emailField = find.widgetWithText(TextFormField, 'Email');
        await tester.enterText(emailField, 'test@example.com');
        await tester.pump();

        expect(find.text('test@example.com'), findsOneWidget);
      });

      testWidgets('shows validation error for empty email', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Fill other required fields but leave email empty
        final passwordField = find.widgetWithText(TextFormField, 'Password');
        await tester.enterText(passwordField, 'password123');
        await tester.pump();

        final confirmField =
            find.widgetWithText(TextFormField, 'Confirm Password');
        await tester.enterText(confirmField, 'password123');
        await tester.pump();

        // Scroll to and tap create account button
        final createButton =
            find.widgetWithText(ElevatedButton, 'Create Account');
        await tester.ensureVisible(createButton);
        await tester.pumpAndSettle();
        await tester.tap(createButton);
        await tester.pumpAndSettle();

        expect(find.text('Email is required'), findsOneWidget);
      });

      testWidgets('shows validation error for invalid email format',
          (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Enter invalid email
        final emailField = find.widgetWithText(TextFormField, 'Email');
        await tester.enterText(emailField, 'invalidemail');
        await tester.pump();

        // Fill other required fields
        final passwordField = find.widgetWithText(TextFormField, 'Password');
        await tester.enterText(passwordField, 'password123');
        await tester.pump();

        final confirmField =
            find.widgetWithText(TextFormField, 'Confirm Password');
        await tester.enterText(confirmField, 'password123');
        await tester.pump();

        // Tap create account button
        final createButton =
            find.widgetWithText(ElevatedButton, 'Create Account');
        await tester.ensureVisible(createButton);
        await tester.pumpAndSettle();
        await tester.tap(createButton);
        await tester.pumpAndSettle();

        expect(find.text('Please enter a valid email'), findsOneWidget);
      });
    });

    group('Display Name Input Field', () {
      testWidgets('can enter display name text', (tester) async {
        await tester.pumpWidget(createTestWidget());

        final displayNameField =
            find.widgetWithText(TextFormField, 'Display Name (Optional)');
        await tester.enterText(displayNameField, 'John Doe');
        await tester.pump();

        expect(find.text('John Doe'), findsOneWidget);
      });

      testWidgets('display name is optional (can submit without it)',
          (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Fill required fields only (no display name)
        final emailField = find.widgetWithText(TextFormField, 'Email');
        await tester.enterText(emailField, 'test@example.com');
        await tester.pump();

        final passwordField = find.widgetWithText(TextFormField, 'Password');
        await tester.enterText(passwordField, 'password123');
        await tester.pump();

        final confirmField =
            find.widgetWithText(TextFormField, 'Confirm Password');
        await tester.enterText(confirmField, 'password123');
        await tester.pump();

        // Tap create account button
        final createButton =
            find.widgetWithText(ElevatedButton, 'Create Account');
        await tester.ensureVisible(createButton);
        await tester.pumpAndSettle();
        await tester.tap(createButton);
        await tester.pump();

        // Should trigger registration event (with null display name)
        verify(
          () => mockRegistrationBloc.add(
            const RegistrationSubmitted(
              email: 'test@example.com',
              password: 'password123',
              confirmPassword: 'password123',
              displayName: null,
            ),
          ),
        ).called(1);
      });

      testWidgets('shows validation error for too long display name',
          (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Enter very long display name (>50 chars)
        final displayNameField =
            find.widgetWithText(TextFormField, 'Display Name (Optional)');
        await tester.enterText(
          displayNameField,
          'This is a very long display name that exceeds fifty characters limit',
        );
        await tester.pump();

        // Fill required fields
        final emailField = find.widgetWithText(TextFormField, 'Email');
        await tester.enterText(emailField, 'test@example.com');
        await tester.pump();

        final passwordField = find.widgetWithText(TextFormField, 'Password');
        await tester.enterText(passwordField, 'password123');
        await tester.pump();

        final confirmField =
            find.widgetWithText(TextFormField, 'Confirm Password');
        await tester.enterText(confirmField, 'password123');
        await tester.pump();

        // Tap create account button
        final createButton =
            find.widgetWithText(ElevatedButton, 'Create Account');
        await tester.ensureVisible(createButton);
        await tester.pumpAndSettle();
        await tester.tap(createButton);
        await tester.pumpAndSettle();

        expect(
          find.text('Display name must be less than 50 characters'),
          findsOneWidget,
        );
      });
    });

    group('Password Input Field', () {
      testWidgets('can enter password text', (tester) async {
        await tester.pumpWidget(createTestWidget());

        final passwordField = find.widgetWithText(TextFormField, 'Password');
        await tester.enterText(passwordField, 'securepassword');
        await tester.pump();

        final textFormField = tester.widget<TextFormField>(passwordField);
        expect(textFormField.controller?.text, 'securepassword');
      });

      testWidgets('password is obscured by default', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Find all visibility icons - should find 2 (password and confirm)
        expect(find.byIcon(Icons.visibility), findsNWidgets(2));
      });

      testWidgets('can toggle password visibility', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Tap first visibility toggle (password field)
        await tester.tap(find.byIcon(Icons.visibility).first);
        await tester.pump();

        // Now we should have one visibility and one visibility_off
        expect(find.byIcon(Icons.visibility_off), findsOneWidget);
        expect(find.byIcon(Icons.visibility), findsOneWidget);
      });

      testWidgets('shows validation error for empty password', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Enter email but no password
        final emailField = find.widgetWithText(TextFormField, 'Email');
        await tester.enterText(emailField, 'test@example.com');
        await tester.pump();

        // Tap create account button
        final createButton =
            find.widgetWithText(ElevatedButton, 'Create Account');
        await tester.ensureVisible(createButton);
        await tester.pumpAndSettle();
        await tester.tap(createButton);
        await tester.pumpAndSettle();

        expect(find.text('Password is required'), findsOneWidget);
      });

      testWidgets('shows validation error for short password', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Enter valid email
        final emailField = find.widgetWithText(TextFormField, 'Email');
        await tester.enterText(emailField, 'test@example.com');
        await tester.pump();

        // Enter short password
        final passwordField = find.widgetWithText(TextFormField, 'Password');
        await tester.enterText(passwordField, '12345');
        await tester.pump();

        final confirmField =
            find.widgetWithText(TextFormField, 'Confirm Password');
        await tester.enterText(confirmField, '12345');
        await tester.pump();

        // Tap create account button
        final createButton =
            find.widgetWithText(ElevatedButton, 'Create Account');
        await tester.ensureVisible(createButton);
        await tester.pumpAndSettle();
        await tester.tap(createButton);
        await tester.pumpAndSettle();

        expect(
          find.text('Password must be at least 6 characters'),
          findsOneWidget,
        );
      });
    });

    group('Confirm Password Input Field', () {
      testWidgets('can enter confirm password text', (tester) async {
        await tester.pumpWidget(createTestWidget());

        final confirmField =
            find.widgetWithText(TextFormField, 'Confirm Password');
        await tester.enterText(confirmField, 'password123');
        await tester.pump();

        final textFormField = tester.widget<TextFormField>(confirmField);
        expect(textFormField.controller?.text, 'password123');
      });

      testWidgets('can toggle confirm password visibility', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Tap second visibility toggle (confirm password field)
        await tester.tap(find.byIcon(Icons.visibility).last);
        await tester.pump();

        // Now we should have one visibility and one visibility_off
        expect(find.byIcon(Icons.visibility_off), findsOneWidget);
        expect(find.byIcon(Icons.visibility), findsOneWidget);
      });

      testWidgets('shows validation error for empty confirm password',
          (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Enter email and password but no confirm
        final emailField = find.widgetWithText(TextFormField, 'Email');
        await tester.enterText(emailField, 'test@example.com');
        await tester.pump();

        final passwordField = find.widgetWithText(TextFormField, 'Password');
        await tester.enterText(passwordField, 'password123');
        await tester.pump();

        // Tap create account button
        final createButton =
            find.widgetWithText(ElevatedButton, 'Create Account');
        await tester.ensureVisible(createButton);
        await tester.pumpAndSettle();
        await tester.tap(createButton);
        await tester.pumpAndSettle();

        expect(find.text('Please confirm your password'), findsOneWidget);
      });

      testWidgets('shows validation error for mismatched passwords',
          (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Enter valid email
        final emailField = find.widgetWithText(TextFormField, 'Email');
        await tester.enterText(emailField, 'test@example.com');
        await tester.pump();

        // Enter password
        final passwordField = find.widgetWithText(TextFormField, 'Password');
        await tester.enterText(passwordField, 'password123');
        await tester.pump();

        // Enter different confirm password
        final confirmField =
            find.widgetWithText(TextFormField, 'Confirm Password');
        await tester.enterText(confirmField, 'differentpassword');
        await tester.pump();

        // Tap create account button
        final createButton =
            find.widgetWithText(ElevatedButton, 'Create Account');
        await tester.ensureVisible(createButton);
        await tester.pumpAndSettle();
        await tester.tap(createButton);
        await tester.pumpAndSettle();

        expect(find.text('Passwords do not match'), findsOneWidget);
      });
    });

    group('Registration Button', () {
      testWidgets('triggers RegistrationSubmitted event on tap',
          (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Fill all fields
        final emailField = find.widgetWithText(TextFormField, 'Email');
        await tester.enterText(emailField, 'test@example.com');
        await tester.pump();

        final displayNameField =
            find.widgetWithText(TextFormField, 'Display Name (Optional)');
        await tester.enterText(displayNameField, 'Test User');
        await tester.pump();

        final passwordField = find.widgetWithText(TextFormField, 'Password');
        await tester.enterText(passwordField, 'password123');
        await tester.pump();

        final confirmField =
            find.widgetWithText(TextFormField, 'Confirm Password');
        await tester.enterText(confirmField, 'password123');
        await tester.pump();

        // Tap create account button
        final createButton =
            find.widgetWithText(ElevatedButton, 'Create Account');
        await tester.ensureVisible(createButton);
        await tester.pumpAndSettle();
        await tester.tap(createButton);
        await tester.pump();

        verify(
          () => mockRegistrationBloc.add(
            const RegistrationSubmitted(
              email: 'test@example.com',
              password: 'password123',
              confirmPassword: 'password123',
              displayName: 'Test User',
            ),
          ),
        ).called(1);
      });

      testWidgets('does not trigger event with invalid form', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Tap create account button without filling any fields
        final createButton =
            find.widgetWithText(ElevatedButton, 'Create Account');
        await tester.ensureVisible(createButton);
        await tester.pumpAndSettle();
        await tester.tap(createButton);
        await tester.pump();

        verifyNever(
          () => mockRegistrationBloc.add(any()),
        );
      });
    });

    group('Loading State', () {
      testWidgets('shows loading indicator during registration',
          (tester) async {
        when(() => mockRegistrationBloc.state)
            .thenReturn(const RegistrationLoading());

        await tester.pumpWidget(createTestWidget());

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('button is disabled during loading', (tester) async {
        when(() => mockRegistrationBloc.state)
            .thenReturn(const RegistrationLoading());

        await tester.pumpWidget(createTestWidget());

        final elevatedButton = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );
        expect(elevatedButton.onPressed, isNull);
      });
    });

    group('Navigation', () {
      testWidgets('navigates back on Sign In tap', (tester) async {
        // Create a simple navigation stack to test pop
        await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider<RegistrationBloc>.value(
                          value: mockRegistrationBloc,
                          child: const RegistrationPage(),
                        ),
                      ),
                    );
                  },
                  child: const Text('Go to Registration'),
                ),
              ),
            ),
          ),
        );

        // Navigate to registration page
        await tester.tap(find.text('Go to Registration'));
        await tester.pumpAndSettle();

        // Verify we're on registration page by checking the AppBar title
        expect(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.text('Create Account'),
          ),
          findsOneWidget,
        );

        // Scroll to and tap Sign In
        final signInButton = find.text('Sign In');
        await tester.ensureVisible(signInButton);
        await tester.pumpAndSettle();
        await tester.tap(signInButton);
        await tester.pumpAndSettle();

        // Should navigate back
        expect(find.text('Go to Registration'), findsOneWidget);
        // The AppBar with Create Account should not be visible
        expect(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.text('Create Account'),
          ),
          findsNothing,
        );
      });
    });

    group('Error Handling', () {
      testWidgets('shows snackbar on registration failure', (tester) async {
        whenListen(
          mockRegistrationBloc,
          Stream.fromIterable([
            const RegistrationInitial(),
            const RegistrationLoading(),
            const RegistrationFailure('Email already in use'),
          ]),
          initialState: const RegistrationInitial(),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Email already in use'), findsOneWidget);
        expect(find.byType(SnackBar), findsOneWidget);
      });

      testWidgets('snackbar has red background color on failure',
          (tester) async {
        whenListen(
          mockRegistrationBloc,
          Stream.fromIterable([
            const RegistrationInitial(),
            const RegistrationFailure('Error message'),
          ]),
          initialState: const RegistrationInitial(),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
        expect(snackBar.backgroundColor, Colors.red);
      });
    });

    group('Success Handling', () {
      testWidgets('shows success snackbar and navigates back on success',
          (tester) async {
        // Set up the bloc to emit success when we pump
        whenListen(
          mockRegistrationBloc,
          Stream.fromIterable([
            const RegistrationInitial(),
            const RegistrationSuccess(),
          ]),
          initialState: const RegistrationInitial(),
        );

        // Create a simple navigation stack
        await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider<RegistrationBloc>.value(
                          value: mockRegistrationBloc,
                          child: const RegistrationPage(),
                        ),
                      ),
                    );
                  },
                  child: const Text('Go to Registration'),
                ),
              ),
            ),
          ),
        );

        // Navigate to registration page
        await tester.tap(find.text('Go to Registration'));
        await tester.pumpAndSettle();

        // The success state should trigger navigation back
        // Verify we're back on the original page
        expect(find.text('Go to Registration'), findsOneWidget);
        expect(find.text('Create Account'), findsNothing);

        // The snackbar should be visible on the original page
        expect(
          find.textContaining('Account created successfully'),
          findsOneWidget,
        );
      });

      testWidgets('success snackbar has green background color',
          (tester) async {
        // Set up the bloc to emit success when we pump
        whenListen(
          mockRegistrationBloc,
          Stream.fromIterable([
            const RegistrationInitial(),
            const RegistrationSuccess(),
          ]),
          initialState: const RegistrationInitial(),
        );

        // Create a simple navigation stack
        await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider<RegistrationBloc>.value(
                          value: mockRegistrationBloc,
                          child: const RegistrationPage(),
                        ),
                      ),
                    );
                  },
                  child: const Text('Go to Registration'),
                ),
              ),
            ),
          ),
        );

        // Navigate to registration page
        await tester.tap(find.text('Go to Registration'));
        await tester.pumpAndSettle();

        // The snackbar should be visible
        final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
        expect(snackBar.backgroundColor, Colors.green);
      });
    });

    group('Form Submission via Enter Key', () {
      testWidgets('submits form when pressing enter on confirm password field',
          (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Fill all fields
        final emailField = find.widgetWithText(TextFormField, 'Email');
        await tester.enterText(emailField, 'test@example.com');
        await tester.pump();

        final passwordField = find.widgetWithText(TextFormField, 'Password');
        await tester.enterText(passwordField, 'password123');
        await tester.pump();

        final confirmField =
            find.widgetWithText(TextFormField, 'Confirm Password');
        await tester.enterText(confirmField, 'password123');
        await tester.pump();

        // Submit using keyboard action
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        verify(
          () => mockRegistrationBloc.add(
            const RegistrationSubmitted(
              email: 'test@example.com',
              password: 'password123',
              confirmPassword: 'password123',
              displayName: null,
            ),
          ),
        ).called(1);
      });
    });
  });
}
