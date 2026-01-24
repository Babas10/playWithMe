// Widget tests for TrainingSessionFeedbackPage verifying feedback form rendering and submission.

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/features/training/presentation/bloc/feedback/training_feedback_bloc.dart';
import 'package:play_with_me/features/training/presentation/bloc/feedback/training_feedback_event.dart';
import 'package:play_with_me/features/training/presentation/bloc/feedback/training_feedback_state.dart';
import 'package:play_with_me/features/training/presentation/pages/training_session_feedback_page.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

class MockTrainingFeedbackBloc
    extends MockBloc<TrainingFeedbackEvent, TrainingFeedbackState>
    implements TrainingFeedbackBloc {}

class FakeTrainingFeedbackEvent extends Fake implements TrainingFeedbackEvent {}

class FakeTrainingFeedbackState extends Fake implements TrainingFeedbackState {}

void main() {
  late MockTrainingFeedbackBloc mockFeedbackBloc;

  const testSessionId = 'test-session-123';
  const testSessionTitle = 'Morning Beach Drills';

  setUpAll(() {
    registerFallbackValue(FakeTrainingFeedbackEvent());
    registerFallbackValue(FakeTrainingFeedbackState());
  });

  setUp(() {
    mockFeedbackBloc = MockTrainingFeedbackBloc();

    when(() => mockFeedbackBloc.state).thenReturn(const FeedbackInitial());
  });

  tearDown(() {
    mockFeedbackBloc.close();
  });

  Widget createTestWidget() {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: BlocProvider<TrainingFeedbackBloc>.value(
        value: mockFeedbackBloc,
        child: const TrainingSessionFeedbackPage(
          trainingSessionId: testSessionId,
          sessionTitle: testSessionTitle,
        ),
      ),
    );
  }

  group('TrainingSessionFeedbackPage Widget Tests', () {
    group('Initial UI Rendering', () {
      testWidgets('renders app bar with Session Feedback title',
          (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.byType(AppBar), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.text('Session Feedback'),
          ),
          findsOneWidget,
        );
      });

      testWidgets('renders anonymous feedback header', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Provide Anonymous Feedback'), findsOneWidget);
      });

      testWidgets('renders session title', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text(testSessionTitle), findsOneWidget);
      });

      testWidgets('renders anonymous explanation text', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(
          find.text(
              'Your feedback is anonymous and helps improve future training sessions.'),
          findsOneWidget,
        );
      });

      testWidgets('renders exercises quality rating section', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Exercises Quality'), findsOneWidget);
        expect(find.text('Were the drills effective?'), findsOneWidget);
      });

      testWidgets('renders training intensity rating section', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Training Intensity'), findsOneWidget);
        expect(find.text('Physical demand level'), findsOneWidget);
      });

      testWidgets('renders coaching clarity rating section', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Coaching Clarity'), findsOneWidget);
        expect(find.text('Instructions & corrections?'), findsOneWidget);
      });

      testWidgets('renders rating icons for each category', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Each rating section has 5 volleyball icons
        // 3 categories * 5 icons = 15 volleyball icons
        expect(find.byIcon(Icons.sports_volleyball), findsNWidgets(15));
      });

      testWidgets('renders rating labels', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // 3 categories each with "Needs work" and "Top-level training" labels
        expect(find.text('Needs work'), findsNWidgets(3));
        expect(find.text('Top-level training'), findsNWidgets(3));
      });

      testWidgets('renders comment section', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Additional Comments (Optional)'), findsOneWidget);
        expect(
          find.text(
              'Share your thoughts about the session, exercises, or suggestions for improvement...'),
          findsOneWidget,
        );
      });

      testWidgets('renders submit button', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Scroll to button
        final submitButton = find.text('Submit Feedback');
        await tester.ensureVisible(submitButton);
        await tester.pump();

        expect(submitButton, findsOneWidget);
      });

      testWidgets('renders privacy reminder card', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Scroll down to see privacy card
        await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
        await tester.pumpAndSettle();

        expect(
          find.text(
              'Your feedback is completely anonymous and cannot be traced back to you.'),
          findsOneWidget,
        );
        expect(find.byIcon(Icons.privacy_tip_outlined), findsOneWidget);
      });

      testWidgets('sends CheckFeedbackSubmission event on init',
          (tester) async {
        await tester.pumpWidget(createTestWidget());

        verify(
          () => mockFeedbackBloc
              .add(const CheckFeedbackSubmission(testSessionId)),
        ).called(1);
      });
    });

    group('Rating Selection', () {
      testWidgets('can tap to select exercises quality rating', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Find all volleyball icons (15 total: 3 categories x 5 icons)
        final volleyballIcons = find.byIcon(Icons.sports_volleyball);
        expect(volleyballIcons, findsNWidgets(15));

        // Tap the third icon (index 2) in the first category (Exercises Quality)
        // This gives a 3-star rating
        await tester.tap(volleyballIcons.at(2));
        await tester.pump();

        // The tap should succeed without errors
        // Visual feedback is that the icon becomes larger (44 vs 40) and primary color
      });
    });

    group('Comment Input', () {
      testWidgets('can enter comment text', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Scroll to comment field
        final commentField = find.byType(TextFormField);
        await tester.ensureVisible(commentField);
        await tester.pump();

        await tester.enterText(commentField, 'Great session with good drills!');
        await tester.pump();

        expect(find.text('Great session with good drills!'), findsOneWidget);
      });

      testWidgets('comment field has max length counter', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Scroll to comment field
        final commentField = find.byType(TextFormField);
        await tester.ensureVisible(commentField);
        await tester.pump();

        // The max length is shown as a counter (0/500)
        expect(find.text('0/500'), findsOneWidget);
      });
    });

    group('Validation', () {
      testWidgets('shows warning when ratings not selected', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Scroll to submit button and tap
        final submitButton = find.text('Submit Feedback');
        await tester.ensureVisible(submitButton);
        await tester.pump();

        await tester.tap(find.widgetWithText(ElevatedButton, 'Submit Feedback'));
        await tester.pump();

        // Should show validation snackbar
        expect(
          find.text('Please rate all three categories before submitting'),
          findsOneWidget,
        );
        expect(find.byType(SnackBar), findsOneWidget);
      });
    });

    group('Checking Submission State', () {
      testWidgets('shows loading indicator when checking submission',
          (tester) async {
        when(() => mockFeedbackBloc.state)
            .thenReturn(const CheckingFeedbackSubmission(testSessionId));

        await tester.pumpWidget(createTestWidget());

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('Already Submitted State', () {
      testWidgets('shows already submitted view', (tester) async {
        when(() => mockFeedbackBloc.state).thenReturn(
          const FeedbackSubmissionChecked(
            trainingSessionId: testSessionId,
            hasSubmitted: true,
          ),
        );

        await tester.pumpWidget(createTestWidget());

        expect(find.text('Feedback Already Submitted'), findsOneWidget);
        expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
      });

      testWidgets('shows session title in already submitted view',
          (tester) async {
        when(() => mockFeedbackBloc.state).thenReturn(
          const FeedbackSubmissionChecked(
            trainingSessionId: testSessionId,
            hasSubmitted: true,
          ),
        );

        await tester.pumpWidget(createTestWidget());

        expect(
          find.text('You have already provided feedback for "$testSessionTitle".'),
          findsOneWidget,
        );
      });

      testWidgets('shows back button in already submitted view',
          (tester) async {
        when(() => mockFeedbackBloc.state).thenReturn(
          const FeedbackSubmissionChecked(
            trainingSessionId: testSessionId,
            hasSubmitted: true,
          ),
        );

        await tester.pumpWidget(createTestWidget());

        expect(find.text('Back to Session'), findsOneWidget);
      });
    });

    group('Submitting State', () {
      testWidgets('shows loading indicator during submission', (tester) async {
        when(() => mockFeedbackBloc.state)
            .thenReturn(const SubmittingFeedback(testSessionId));

        await tester.pumpWidget(createTestWidget());

        // Scroll to submit button area
        final submitButton = find.byType(ElevatedButton);
        await tester.ensureVisible(submitButton);
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('submit button is disabled during submission', (tester) async {
        when(() => mockFeedbackBloc.state)
            .thenReturn(const SubmittingFeedback(testSessionId));

        await tester.pumpWidget(createTestWidget());

        // Scroll to submit button
        final submitButton = find.byType(ElevatedButton);
        await tester.ensureVisible(submitButton);
        await tester.pump();

        final elevatedButton = tester.widget<ElevatedButton>(submitButton);
        expect(elevatedButton.onPressed, isNull);
      });
    });

    group('Success Handling', () {
      testWidgets('shows success snackbar after submission', (tester) async {
        whenListen(
          mockFeedbackBloc,
          Stream.fromIterable([
            const FeedbackInitial(),
            const SubmittingFeedback(testSessionId),
            const FeedbackSubmitted(trainingSessionId: testSessionId),
          ]),
          initialState: const FeedbackInitial(),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Thank you for your feedback!'), findsOneWidget);
        expect(find.byType(SnackBar), findsOneWidget);

        // Advance past the 2-second navigation delay to clean up pending timer
        await tester.pump(const Duration(seconds: 3));
      });

      testWidgets('success snackbar has green background', (tester) async {
        whenListen(
          mockFeedbackBloc,
          Stream.fromIterable([
            const FeedbackInitial(),
            const FeedbackSubmitted(trainingSessionId: testSessionId),
          ]),
          initialState: const FeedbackInitial(),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
        expect(snackBar.backgroundColor, Colors.green);

        // Advance past the 2-second navigation delay to clean up pending timer
        await tester.pump(const Duration(seconds: 3));
      });
    });

    group('Error Handling', () {
      testWidgets('shows error snackbar on failure', (tester) async {
        whenListen(
          mockFeedbackBloc,
          Stream.fromIterable([
            const FeedbackInitial(),
            const SubmittingFeedback(testSessionId),
            const FeedbackError(message: 'Failed to submit feedback'),
          ]),
          initialState: const FeedbackInitial(),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Failed to submit feedback'), findsOneWidget);
        expect(find.byType(SnackBar), findsOneWidget);
      });

      testWidgets('error snackbar has red background', (tester) async {
        whenListen(
          mockFeedbackBloc,
          Stream.fromIterable([
            const FeedbackInitial(),
            const FeedbackError(message: 'Error message'),
          ]),
          initialState: const FeedbackInitial(),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
        expect(snackBar.backgroundColor, Colors.red);
      });
    });
  });
}
