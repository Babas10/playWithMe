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
      supportedLocales: const [Locale('en')],
      home: BlocProvider<RegistrationBloc>.value(
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

        // One in page body (decorative) + one in PlayWithMeAppBar title
        expect(find.byIcon(Icons.sports_volleyball), findsNWidgets(2));
      });

      testWidgets('renders all form fields', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // 6 fields: firstName, lastName, displayName, email, password, confirmPassword
        expect(find.byType(AuthFormField), findsNWidgets(6));
        expect(find.text('First Name'), findsOneWidget);
        expect(find.text('Last Name'), findsOneWidget);
        expect(find.text('Display Name'), findsOneWidget);
        expect(find.text('Email'), findsOneWidget);
      });

      testWidgets('renders password requirements hint', (tester) async {
        await tester.pumpWidget(createTestWidget());

        await tester.ensureVisible(
          find.text('At least 8 characters, 1 uppercase letter, 1 number'),
        );
        expect(
          find.text('At least 8 characters, 1 uppercase letter, 1 number'),
          findsOneWidget,
        );
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

        final termsText = find.textContaining('Terms of Service');
        await tester.ensureVisible(termsText);
        await tester.pumpAndSettle();

        expect(find.textContaining('Terms of Service'), findsOneWidget);
        expect(find.textContaining('Privacy Policy'), findsOneWidget);
      });
    });

    group('Form Validation', () {
      testWidgets('shows validation error for empty first name', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Tap create account button without filling fields
        final createButton =
            find.widgetWithText(ElevatedButton, 'Create Account');
        await tester.ensureVisible(createButton);
        await tester.pumpAndSettle();
        await tester.tap(createButton);
        await tester.pumpAndSettle();

        expect(find.text('First name is required'), findsOneWidget);
      });

      testWidgets('shows validation error for empty email', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Fill name fields but leave email empty
        await tester.enterText(
            find.widgetWithText(TextFormField, 'First Name'), 'John');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Last Name'), 'Doe');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Display Name'), 'JohnD');
        await tester.pump();

        final createButton =
            find.widgetWithText(ElevatedButton, 'Create Account');
        await tester.ensureVisible(createButton);
        await tester.pumpAndSettle();
        await tester.tap(createButton);
        await tester.pumpAndSettle();

        expect(find.text('Email is required'), findsOneWidget);
      });

      testWidgets('shows validation error for short password', (tester) async {
        await tester.pumpWidget(createTestWidget());

        await tester.enterText(
            find.widgetWithText(TextFormField, 'First Name'), 'John');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Last Name'), 'Doe');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Display Name'), 'JohnD');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
        await tester.pump();

        await tester.ensureVisible(
            find.widgetWithText(TextFormField, 'Password'));
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Password'), 'Pass1');
        await tester.pump();

        final createButton =
            find.widgetWithText(ElevatedButton, 'Create Account');
        await tester.ensureVisible(createButton);
        await tester.pumpAndSettle();
        await tester.tap(createButton);
        await tester.pumpAndSettle();

        expect(
          find.text('Password must be at least 8 characters'),
          findsOneWidget,
        );
      });
    });

    group('Registration Button', () {
      testWidgets('triggers RegistrationSubmitted event on tap with all fields',
          (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Fill all fields
        await tester.enterText(
            find.widgetWithText(TextFormField, 'First Name'), 'John');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Last Name'), 'Doe');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Display Name'), 'JohnD');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
        await tester.pump();

        await tester.ensureVisible(
            find.widgetWithText(TextFormField, 'Password'));
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Password'), 'Password1');
        await tester.pump();

        await tester.ensureVisible(
            find.widgetWithText(TextFormField, 'Confirm Password'));
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Confirm Password'), 'Password1');
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
              firstName: 'John',
              lastName: 'Doe',
              displayName: 'JohnD',
              email: 'test@example.com',
              password: 'Password1',
              confirmPassword: 'Password1',
            ),
          ),
        ).called(1);
      });

      testWidgets('does not trigger event with invalid form', (tester) async {
        await tester.pumpWidget(createTestWidget());

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
        whenListen(
          mockRegistrationBloc,
          Stream.fromIterable([
            const RegistrationInitial(),
            const RegistrationSuccess(),
          ]),
          initialState: const RegistrationInitial(),
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
            home: Builder(
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

        await tester.tap(find.text('Go to Registration'));
        await tester.pumpAndSettle();

        expect(find.text('Go to Registration'), findsOneWidget);
        expect(find.text('Create Account'), findsNothing);

        expect(
          find.textContaining('Account created successfully'),
          findsOneWidget,
        );
      });
    });
  });
}
