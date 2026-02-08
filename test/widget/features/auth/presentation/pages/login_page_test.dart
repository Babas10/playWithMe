// Widget tests for LoginPage verifying UI rendering and user interactions.
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:play_with_me/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/login/login_event.dart';
import 'package:play_with_me/features/auth/presentation/bloc/login/login_state.dart';
import 'package:play_with_me/features/auth/presentation/pages/login_page.dart';
import 'package:play_with_me/features/auth/presentation/widgets/auth_button.dart';
import 'package:play_with_me/features/auth/presentation/widgets/auth_form_field.dart';

class MockLoginBloc extends MockBloc<LoginEvent, LoginState>
    implements LoginBloc {}

class FakeLoginEvent extends Fake implements LoginEvent {}

class FakeLoginState extends Fake implements LoginState {}

void main() {
  late MockLoginBloc mockLoginBloc;

  setUpAll(() {
    registerFallbackValue(FakeLoginEvent());
    registerFallbackValue(FakeLoginState());
  });

  setUp(() {
    mockLoginBloc = MockLoginBloc();
    when(() => mockLoginBloc.state).thenReturn(const LoginInitial());
  });

  tearDown(() {
    mockLoginBloc.close();
  });

  Widget createTestWidget({Route<dynamic>? Function(RouteSettings)? onGenerateRoute}) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],      home: BlocProvider<LoginBloc>.value(
        value: mockLoginBloc,
        child: const LoginPage(),
      ),
      onGenerateRoute: onGenerateRoute ?? (settings) {
        if (settings.name == '/register') {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(body: Text('Registration Page')),
          );
        }
        if (settings.name == '/forgot-password') {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(body: Text('Password Reset Page')),
          );
        }
        return null;
      },
    );
  }

  group('LoginPage Widget Tests', () {
    group('Initial UI Rendering', () {
      testWidgets('renders app bar with Login title', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Find Login text in AppBar specifically
        expect(find.byType(AppBar), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.text('Login'),
          ),
          findsOneWidget,
        );
      });

      testWidgets('renders welcome text', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Welcome Back!'), findsOneWidget);
        expect(
          find.text('Sign in to continue organizing your volleyball games'),
          findsOneWidget,
        );
      });

      testWidgets('renders volleyball icon', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.byIcon(Icons.sports_volleyball), findsOneWidget);
      });

      testWidgets('renders email input field', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.byType(AuthFormField), findsNWidgets(2));
        expect(find.text('Email'), findsOneWidget);
        expect(find.byIcon(Icons.email), findsOneWidget);
      });

      testWidgets('renders password input field', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Password'), findsOneWidget);
        expect(find.byIcon(Icons.lock), findsOneWidget);
      });

      testWidgets('renders login button', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.widgetWithText(AuthButton, 'Login'), findsOneWidget);
      });

      testWidgets('renders sign up link', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text("Don't have an account? "), findsOneWidget);
        expect(find.text('Sign Up'), findsOneWidget);
      });

      testWidgets('renders forgot password link', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Forgot Password?'), findsOneWidget);
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

        // Tap login button without entering email
        final loginButton = find.widgetWithText(ElevatedButton, 'Login');
        await tester.tap(loginButton);
        await tester.pumpAndSettle();

        expect(find.text('Email is required'), findsOneWidget);
      });

      testWidgets('shows validation error for invalid email format',
          (tester) async {
        await tester.pumpWidget(createTestWidget());

        final emailField = find.widgetWithText(TextFormField, 'Email');
        await tester.enterText(emailField, 'invalidemail');
        await tester.pump();

        // Also enter password to avoid multiple validation errors
        final passwordField = find.widgetWithText(TextFormField, 'Password');
        await tester.enterText(passwordField, 'password123');
        await tester.pump();

        final loginButton = find.widgetWithText(ElevatedButton, 'Login');
        await tester.tap(loginButton);
        await tester.pumpAndSettle();

        expect(find.text('Please enter a valid email'), findsOneWidget);
      });
    });

    group('Password Input Field', () {
      testWidgets('can enter password text', (tester) async {
        await tester.pumpWidget(createTestWidget());

        final passwordField = find.widgetWithText(TextFormField, 'Password');
        await tester.enterText(passwordField, 'securepassword');
        await tester.pump();

        // Password should be obscured, but we can verify the text is there
        final textFormField = tester.widget<TextFormField>(passwordField);
        expect(textFormField.controller?.text, 'securepassword');
      });

      testWidgets('password is obscured by default', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Check the visibility icon indicates password is hidden
        // When obscured, the visibility icon is shown (click to show)
        expect(find.byIcon(Icons.visibility), findsOneWidget);
        expect(find.byIcon(Icons.visibility_off), findsNothing);

        // Also check the EditableText has obscureText set
        final editableTexts = find.byType(EditableText);
        final editableTextWidgets =
            tester.widgetList<EditableText>(editableTexts);

        // The second EditableText should be the password field
        final passwordEditableText = editableTextWidgets.elementAt(1);
        expect(passwordEditableText.obscureText, isTrue);
      });

      testWidgets('can toggle password visibility', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Initially password should be obscured
        expect(find.byIcon(Icons.visibility), findsOneWidget);
        expect(find.byIcon(Icons.visibility_off), findsNothing);

        // Tap visibility toggle
        await tester.tap(find.byIcon(Icons.visibility));
        await tester.pump();

        // Now password should be visible
        expect(find.byIcon(Icons.visibility_off), findsOneWidget);
        expect(find.byIcon(Icons.visibility), findsNothing);

        // Tap again to hide
        await tester.tap(find.byIcon(Icons.visibility_off));
        await tester.pump();

        expect(find.byIcon(Icons.visibility), findsOneWidget);
      });

      testWidgets('shows validation error for empty password', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Enter valid email but no password
        final emailField = find.widgetWithText(TextFormField, 'Email');
        await tester.enterText(emailField, 'test@example.com');
        await tester.pump();

        final loginButton = find.widgetWithText(ElevatedButton, 'Login');
        await tester.tap(loginButton);
        await tester.pumpAndSettle();

        expect(find.text('Password is required'), findsOneWidget);
      });
    });

    group('Login Button', () {
      testWidgets('triggers LoginWithEmailAndPasswordSubmitted event on tap',
          (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Enter valid credentials
        final emailField = find.widgetWithText(TextFormField, 'Email');
        await tester.enterText(emailField, 'test@example.com');
        await tester.pump();

        final passwordField = find.widgetWithText(TextFormField, 'Password');
        await tester.enterText(passwordField, 'password123');
        await tester.pump();

        // Tap login button
        final loginButton = find.widgetWithText(ElevatedButton, 'Login');
        await tester.tap(loginButton);
        await tester.pump();

        verify(
          () => mockLoginBloc.add(
            const LoginWithEmailAndPasswordSubmitted(
              email: 'test@example.com',
              password: 'password123',
            ),
          ),
        ).called(1);
      });

      testWidgets('does not trigger event with invalid form', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Tap login without entering anything
        final loginButton = find.widgetWithText(ElevatedButton, 'Login');
        await tester.tap(loginButton);
        await tester.pump();

        verifyNever(
          () => mockLoginBloc.add(any()),
        );
      });
    });

    group('Loading State', () {
      testWidgets('shows loading indicator during login', (tester) async {
        when(() => mockLoginBloc.state).thenReturn(const LoginLoading());

        await tester.pumpWidget(createTestWidget());

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('login button is disabled during loading', (tester) async {
        when(() => mockLoginBloc.state).thenReturn(const LoginLoading());

        await tester.pumpWidget(createTestWidget());

        // Find the ElevatedButton (Login button)
        final elevatedButton = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );
        expect(elevatedButton.onPressed, isNull);
      });
    });

    group('Navigation', () {
      testWidgets('navigates to registration page on Sign Up tap',
          (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Scroll to make Sign Up button visible
        final signUpButton = find.text('Sign Up');
        await tester.ensureVisible(signUpButton);
        await tester.pumpAndSettle();

        await tester.tap(signUpButton);
        await tester.pumpAndSettle();

        expect(find.text('Registration Page'), findsOneWidget);
      });

      testWidgets('navigates to password reset page on Forgot Password tap',
          (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Scroll to make Forgot Password button visible
        final forgotPasswordButton = find.text('Forgot Password?');
        await tester.ensureVisible(forgotPasswordButton);
        await tester.pumpAndSettle();

        await tester.tap(forgotPasswordButton);
        await tester.pumpAndSettle();

        expect(find.text('Password Reset Page'), findsOneWidget);
      });
    });

    group('Error Handling', () {
      testWidgets('shows snackbar on login failure', (tester) async {
        whenListen(
          mockLoginBloc,
          Stream.fromIterable([
            const LoginInitial(),
            const LoginLoading(),
            const LoginFailure('Invalid credentials'),
          ]),
          initialState: const LoginInitial(),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pump(); // Allow BlocListener to process state changes
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Invalid credentials'), findsOneWidget);
        expect(find.byType(SnackBar), findsOneWidget);
      });

      testWidgets('snackbar has red background color on failure',
          (tester) async {
        whenListen(
          mockLoginBloc,
          Stream.fromIterable([
            const LoginInitial(),
            const LoginFailure('Error message'),
          ]),
          initialState: const LoginInitial(),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
        expect(snackBar.backgroundColor, Colors.red);
      });
    });

    group('Form Submission via Enter Key', () {
      testWidgets('submits form when pressing enter on password field',
          (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Enter valid credentials
        final emailField = find.widgetWithText(TextFormField, 'Email');
        await tester.enterText(emailField, 'test@example.com');
        await tester.pump();

        final passwordField = find.widgetWithText(TextFormField, 'Password');
        await tester.enterText(passwordField, 'password123');
        await tester.pump();

        // Submit using keyboard action
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        verify(
          () => mockLoginBloc.add(
            const LoginWithEmailAndPasswordSubmitted(
              email: 'test@example.com',
              password: 'password123',
            ),
          ),
        ).called(1);
      });
    });
  });
}
