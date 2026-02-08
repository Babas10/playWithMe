// Verifies that EmailVerificationPage displays correct UI for different verification states

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/l10n/app_localizations.dart';
import 'package:play_with_me/features/profile/presentation/bloc/email_verification/email_verification_bloc.dart';
import 'package:play_with_me/features/profile/presentation/bloc/email_verification/email_verification_event.dart';
import 'package:play_with_me/features/profile/presentation/bloc/email_verification/email_verification_state.dart';
import 'package:play_with_me/features/profile/presentation/pages/email_verification_page.dart';

// Mock classes
class MockEmailVerificationBloc
    extends Mock
    implements EmailVerificationBloc {}

// Fake classes for mocktail
class FakeEmailVerificationEvent extends Fake
    implements EmailVerificationEvent {}

class FakeEmailVerificationState extends Fake
    implements EmailVerificationState {}

void main() {
  late MockEmailVerificationBloc mockBloc;

  setUpAll(() {
    registerFallbackValue(FakeEmailVerificationEvent());
    registerFallbackValue(FakeEmailVerificationState());
  });

  setUp(() {
    mockBloc = MockEmailVerificationBloc();
  });

  Widget createWidgetUnderTest() {
    return MediaQuery(
      data: const MediaQueryData(size: Size(800, 1200)), // Larger viewport for tests
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
        home: BlocProvider<EmailVerificationBloc>.value(
          value: mockBloc,
          child: const EmailVerificationPage(),
        ),
      ),
    );
  }

  group('EmailVerificationPage', () {
    testWidgets('displays loading indicator for initial state',
        (tester) async {
      when(() => mockBloc.state)
          .thenReturn(const EmailVerificationState.initial());
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Email Verification'), findsOneWidget);
    });

    testWidgets('displays loading indicator for loading state',
        (tester) async {
      when(() => mockBloc.state)
          .thenReturn(const EmailVerificationState.loading());
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    group('Verified State', () {
      testWidgets('displays verified UI with success icon', (tester) async {
        final verifiedAt = DateTime(2024, 10, 15);
        when(() => mockBloc.state).thenReturn(
          EmailVerificationState.verified(verifiedAt: verifiedAt),
        );
        when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.text('Email Verified!'), findsOneWidget);
        expect(find.text('Your email has been successfully verified.'),
            findsOneWidget);
        expect(find.text('Verified on: Oct 15, 2024'), findsOneWidget);
        expect(find.byIcon(Icons.verified), findsOneWidget);
        expect(find.text('Back to Profile'), findsOneWidget);
      });

      testWidgets('back button pops navigation', (tester) async {
        when(() => mockBloc.state).thenReturn(
          EmailVerificationState.verified(verifiedAt: DateTime.now()),
        );
        when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.tap(find.text('Back to Profile'));
        await tester.pumpAndSettle();

        // Widget tree should be disposed after navigation
        expect(find.byType(EmailVerificationPage), findsNothing);
      });
    });

    group('Pending State', () {
      testWidgets('displays pending UI when email not yet sent',
          (tester) async {
        when(() => mockBloc.state).thenReturn(
          const EmailVerificationState.pending(
            email: 'test@example.com',
            emailSent: false,
            lastSentAt: null,
            resendCooldownSeconds: 0,
          ),
        );
        when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.text('Verify Your Email'), findsOneWidget);
        expect(find.text('test@example.com'), findsOneWidget);
        expect(find.text('Send Verification Email'), findsOneWidget);
        expect(
            find.text(
                'Click the button below to send a verification email.'),
            findsOneWidget);
      });

      testWidgets('displays pending UI when email has been sent',
          (tester) async {
        when(() => mockBloc.state).thenReturn(
          EmailVerificationState.pending(
            email: 'test@example.com',
            emailSent: true,
            lastSentAt: DateTime.now(),
            resendCooldownSeconds: 0,
          ),
        );
        when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.text('Verify Your Email'), findsOneWidget);
        expect(find.text('test@example.com'), findsOneWidget);
        // Note: "Refresh Status" appears in both a button and an instruction card
        expect(find.text('Refresh Status'), findsAtLeastNWidgets(1));
        expect(find.text('Resend Email'), findsOneWidget);
        expect(
            find.text(
                'We\'ve sent a verification email to your address.'),
            findsOneWidget);
      });

      testWidgets('displays instruction cards', (tester) async {
        when(() => mockBloc.state).thenReturn(
          const EmailVerificationState.pending(
            email: 'test@example.com',
            emailSent: false,
            lastSentAt: null,
            resendCooldownSeconds: 0,
          ),
        );
        when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.text('Check Your Inbox'), findsOneWidget);
        expect(find.text('Click the Link'), findsOneWidget);
        expect(find.text('Refresh Status'), findsOneWidget);
      });

      testWidgets('displays troubleshooting section', (tester) async {
        when(() => mockBloc.state).thenReturn(
          const EmailVerificationState.pending(
            email: 'test@example.com',
            emailSent: false,
            lastSentAt: null,
            resendCooldownSeconds: 0,
          ),
        );
        when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.text('Troubleshooting'), findsOneWidget);

        // Ensure the troubleshooting section is visible
        final expansionTile = find.byType(ExpansionTile);
        await tester.ensureVisible(expansionTile);
        await tester.pumpAndSettle();

        // Expand troubleshooting section
        await tester.tap(expansionTile);
        await tester.pumpAndSettle();

        expect(find.text('Check your spam/junk folder'), findsOneWidget);
        expect(
            find.text('Make sure the email address is correct'), findsOneWidget);
        expect(find.text('Wait a few minutes for the email to arrive'),
            findsOneWidget);
        expect(find.text('Check your internet connection'), findsOneWidget);
        expect(find.text('Still having issues?'), findsOneWidget);
        expect(find.text('Contact support at support@playwithme.com'),
            findsOneWidget);
      });
    });

    group('EmailSent State', () {
      testWidgets('shows success snackbar when email is sent', (tester) async {
        when(() => mockBloc.state).thenReturn(
          const EmailVerificationState.pending(
            email: 'test@example.com',
            emailSent: false,
            lastSentAt: null,
            resendCooldownSeconds: 0,
          ),
        );
        when(() => mockBloc.stream).thenAnswer(
          (_) => Stream.value(
            EmailVerificationState.emailSent(
              email: 'test@example.com',
              sentAt: DateTime.now(),
              resendCooldownSeconds: 60,
            ),
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        // Snackbar message appears
        expect(
            find.text('Verification email sent to test@example.com'),
            findsOneWidget);
      });
    });

    group('Error State', () {
      testWidgets('displays error UI with error message', (tester) async {
        when(() => mockBloc.state).thenReturn(
          const EmailVerificationState.error(
            message: 'Failed to send email',
            email: 'test@example.com',
          ),
        );
        when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.text('Something Went Wrong'), findsOneWidget);
        expect(find.text('Failed to send email'), findsOneWidget);
        expect(find.text('Try Again'), findsOneWidget);
        expect(find.text('Back to Profile'), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      });

      testWidgets('try again button triggers checkStatus event',
          (tester) async {
        when(() => mockBloc.state).thenReturn(
          const EmailVerificationState.error(
            message: 'Failed to send email',
          ),
        );
        when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
        when(() => mockBloc.add(any())).thenReturn(null);

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.tap(find.text('Try Again'));
        await tester.pump();

        verify(() => mockBloc.add(const EmailVerificationEvent.checkStatus()))
            .called(1);
      });

      testWidgets('back button pops navigation', (tester) async {
        when(() => mockBloc.state).thenReturn(
          const EmailVerificationState.error(
            message: 'Failed to send email',
          ),
        );
        when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.tap(find.text('Back to Profile'));
        await tester.pumpAndSettle();

        // Widget tree should be disposed after navigation
        expect(find.byType(EmailVerificationPage), findsNothing);
      });

      testWidgets('shows error snackbar when error state is emitted',
          (tester) async {
        when(() => mockBloc.state).thenReturn(
          const EmailVerificationState.pending(
            email: 'test@example.com',
            emailSent: false,
            lastSentAt: null,
            resendCooldownSeconds: 0,
          ),
        );
        when(() => mockBloc.stream).thenAnswer(
          (_) => Stream.value(
            const EmailVerificationState.error(
              message: 'Network error occurred',
            ),
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        // Error message appears in both snackbar and error UI
        expect(find.text('Network error occurred'), findsAtLeastNWidgets(1));
      });
    });

    testWidgets('AppBar displays correct title', (tester) async {
      when(() => mockBloc.state)
          .thenReturn(const EmailVerificationState.initial());
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Email Verification'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('UI is scrollable to handle small screens', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const EmailVerificationState.pending(
          email: 'test@example.com',
          emailSent: true,
          lastSentAt: null,
          resendCooldownSeconds: 0,
        ),
      );
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify SingleChildScrollView is present for pending state
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}
