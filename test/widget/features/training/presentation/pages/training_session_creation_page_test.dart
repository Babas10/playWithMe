// Widget tests for TrainingSessionCreationPage verifying UI rendering and user interactions.

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/presentation/bloc/invitation/invitation_bloc.dart';
import 'package:play_with_me/core/presentation/bloc/invitation/invitation_event.dart';
import 'package:play_with_me/core/presentation/bloc/invitation/invitation_state.dart';
import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_state.dart';
import 'package:play_with_me/features/training/presentation/bloc/training_session_creation/training_session_creation_bloc.dart';
import 'package:play_with_me/features/training/presentation/bloc/training_session_creation/training_session_creation_event.dart';
import 'package:play_with_me/features/training/presentation/bloc/training_session_creation/training_session_creation_state.dart';
import 'package:play_with_me/features/training/presentation/pages/training_session_creation_page.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

class MockTrainingSessionCreationBloc
    extends MockBloc<TrainingSessionCreationEvent, TrainingSessionCreationState>
    implements TrainingSessionCreationBloc {}

class MockAuthenticationBloc extends Mock implements AuthenticationBloc {}
class MockInvitationBloc extends Mock implements InvitationBloc {}

class FakeTrainingSessionCreationEvent extends Fake
    implements TrainingSessionCreationEvent {}

class FakeTrainingSessionCreationState extends Fake
    implements TrainingSessionCreationState {}

void main() {
  late MockTrainingSessionCreationBloc mockCreationBloc;
  late MockAuthenticationBloc mockAuthBloc;
  late MockInvitationBloc mockInvitationBloc;

  const testUserId = 'test-user-123';
  const testGroupId = 'test-group-123';
  const testGroupName = 'Beach Volleyball Crew';

  setUpAll(() {
    registerFallbackValue(FakeTrainingSessionCreationEvent());
    registerFallbackValue(FakeTrainingSessionCreationState());
  });

  setUp(() {
    mockCreationBloc = MockTrainingSessionCreationBloc();
    mockAuthBloc = MockAuthenticationBloc();
    mockInvitationBloc = MockInvitationBloc();
    when(() => mockInvitationBloc.state).thenReturn(const InvitationInitial());
    when(() => mockInvitationBloc.stream).thenAnswer((_) => const Stream.empty());

    when(() => mockCreationBloc.state)
        .thenReturn(const TrainingSessionCreationInitial());

    when(() => mockAuthBloc.state).thenReturn(
      AuthenticationAuthenticated(
        UserEntity(
          uid: testUserId,
          email: 'test@example.com',
          displayName: 'Test User',
          isEmailVerified: true,
          createdAt: DateTime(2024, 1, 1),
          lastSignInAt: DateTime(2024, 1, 1),
          isAnonymous: false,
        ),
      ),
    );
    when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  tearDown(() {
    mockCreationBloc.close();
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
      home: MultiBlocProvider(
        providers: [
          BlocProvider<TrainingSessionCreationBloc>.value(
              value: mockCreationBloc),
          BlocProvider<AuthenticationBloc>.value(value: mockAuthBloc),
          BlocProvider<InvitationBloc>.value(value: mockInvitationBloc),
        ],
        child: const TrainingSessionCreationPage(
          groupId: testGroupId,
          groupName: testGroupName,
        ),
      ),
    );
  }

  group('TrainingSessionCreationPage Widget Tests', () {
    group('Initial UI Rendering', () {
      testWidgets('renders app bar with Create Training Session title',
          (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.byType(AppBar), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.text('Create Training Session'),
          ),
          findsOneWidget,
        );
      });

      testWidgets('renders group name in the form', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text(testGroupName), findsOneWidget);
      });

      testWidgets('renders title input field', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Title'), findsOneWidget);
        expect(find.byIcon(Icons.fitness_center), findsOneWidget);
      });

      testWidgets('renders description input field', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Description (Optional)'), findsOneWidget);
        expect(find.byIcon(Icons.description), findsOneWidget);
      });

      testWidgets('renders location input field', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Location'), findsOneWidget);
        expect(find.byIcon(Icons.location_on), findsOneWidget);
      });

      testWidgets('renders start time selector', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Start Time'), findsOneWidget);
        expect(find.text('Not selected'), findsNWidgets(2)); // Start and End
        expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      });

      testWidgets('renders end time selector', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('End Time'), findsOneWidget);
        expect(find.byIcon(Icons.access_time), findsOneWidget);
      });

      testWidgets('renders participant sliders', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Min Participants'), findsOneWidget);
        expect(find.text('Max Participants'), findsOneWidget);
        expect(find.byType(Slider), findsNWidgets(2));
      });

      testWidgets('renders create button', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Scroll to make button visible (find the FilledButton specifically)
        final createButton = find.byType(FilledButton);
        await tester.ensureVisible(createButton);
        await tester.pumpAndSettle();

        expect(createButton, findsOneWidget);
        // Also verify the button text
        expect(
          find.descendant(
            of: createButton,
            matching: find.text('Create Training Session'),
          ),
          findsOneWidget,
        );
      });

      testWidgets('sends SelectTrainingGroup event on init', (tester) async {
        await tester.pumpWidget(createTestWidget());

        verify(
          () => mockCreationBloc.add(
            const SelectTrainingGroup(
              groupId: testGroupId,
              groupName: testGroupName,
            ),
          ),
        ).called(1);
      });
    });

    group('Title Input Field', () {
      testWidgets('can enter title text', (tester) async {
        await tester.pumpWidget(createTestWidget());

        final titleField = find.widgetWithText(TextFormField, 'Title');
        await tester.enterText(titleField, 'Morning Drills Session');
        await tester.pump();

        expect(find.text('Morning Drills Session'), findsOneWidget);
      });

      testWidgets('shows validation error for empty title', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Fill location to avoid multiple validation errors
        final locationField = find.widgetWithText(TextFormField, 'Location');
        await tester.enterText(locationField, 'Venice Beach');
        await tester.pump();

        // Scroll to and tap create button (find the FilledButton specifically)
        final createButton = find.byType(FilledButton);
        await tester.ensureVisible(createButton);
        await tester.pumpAndSettle();
        await tester.tap(createButton);
        await tester.pumpAndSettle();

        expect(find.text('Please enter a title'), findsOneWidget);
      });
    });

    group('Description Input Field', () {
      testWidgets('can enter description text', (tester) async {
        await tester.pumpWidget(createTestWidget());

        final descriptionField =
            find.widgetWithText(TextFormField, 'Description (Optional)');
        await tester.enterText(
            descriptionField, 'Practice serves and blocks today!');
        await tester.pump();

        expect(find.text('Practice serves and blocks today!'), findsOneWidget);
      });
    });

    group('Location Input Field', () {
      testWidgets('can enter location text', (tester) async {
        await tester.pumpWidget(createTestWidget());

        final locationField = find.widgetWithText(TextFormField, 'Location');
        await tester.enterText(locationField, 'Beach Court 3');
        await tester.pump();

        expect(find.text('Beach Court 3'), findsOneWidget);
      });

      testWidgets('shows validation error for empty location', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Fill title to avoid multiple validation errors
        final titleField = find.widgetWithText(TextFormField, 'Title');
        await tester.enterText(titleField, 'Morning Drills');
        await tester.pump();

        // Scroll to and tap create button (find the FilledButton specifically)
        final createButton = find.byType(FilledButton);
        await tester.ensureVisible(createButton);
        await tester.pumpAndSettle();
        await tester.tap(createButton);
        await tester.pumpAndSettle();

        expect(find.text('Please enter a location'), findsOneWidget);
      });
    });

    group('Time Selection', () {
      testWidgets('start time selector is tappable', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Find the start time list tile and tap it
        final startTimeTile = find.ancestor(
          of: find.text('Start Time'),
          matching: find.byType(ListTile),
        );
        expect(startTimeTile, findsOneWidget);

        await tester.tap(startTimeTile);
        await tester.pumpAndSettle();

        // Date picker dialog should appear
        expect(find.byType(DatePickerDialog), findsOneWidget);
      });
    });

    group('Participant Sliders', () {
      testWidgets('min participants slider shows initial value', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Initial min participants value is 2
        expect(find.text('2'), findsWidgets);
      });

      testWidgets('max participants slider shows initial value', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Initial max participants value is 10
        expect(find.text('10'), findsOneWidget);
      });
    });

    group('Loading State', () {
      testWidgets('shows loading indicator during submission', (tester) async {
        when(() => mockCreationBloc.state)
            .thenReturn(const TrainingSessionCreationSubmitting());

        await tester.pumpWidget(createTestWidget());

        // Scroll to button
        final createButton = find.byType(FilledButton);
        await tester.ensureVisible(createButton);
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('button is disabled during loading', (tester) async {
        when(() => mockCreationBloc.state)
            .thenReturn(const TrainingSessionCreationSubmitting());

        await tester.pumpWidget(createTestWidget());

        // Scroll to button
        final createButton = find.byType(FilledButton);
        await tester.ensureVisible(createButton);
        await tester.pump();

        final filledButton = tester.widget<FilledButton>(createButton);
        expect(filledButton.onPressed, isNull);
      });

      testWidgets('form fields are disabled during loading', (tester) async {
        when(() => mockCreationBloc.state)
            .thenReturn(const TrainingSessionCreationSubmitting());

        await tester.pumpWidget(createTestWidget());

        final titleField = tester.widget<TextFormField>(
          find.widgetWithText(TextFormField, 'Title'),
        );
        expect(titleField.enabled, isFalse);
      });
    });

    // Note: Success handling tests that involve navigation to TrainingSessionDetailsPage
    // require Firebase initialization which is not available in widget tests.
    // Success flow is tested in integration tests instead.

    group('Error Handling', () {
      testWidgets('shows error snackbar on failure', (tester) async {
        whenListen(
          mockCreationBloc,
          Stream.fromIterable([
            const TrainingSessionCreationInitial(),
            const TrainingSessionCreationSubmitting(),
            const TrainingSessionCreationError(
                message: 'Failed to create training session'),
          ]),
          initialState: const TrainingSessionCreationInitial(),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Failed to create training session'), findsOneWidget);
        expect(find.byType(SnackBar), findsOneWidget);
      });

      testWidgets('error snackbar has red background', (tester) async {
        whenListen(
          mockCreationBloc,
          Stream.fromIterable([
            const TrainingSessionCreationInitial(),
            const TrainingSessionCreationError(message: 'Error message'),
          ]),
          initialState: const TrainingSessionCreationInitial(),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
        expect(snackBar.backgroundColor, Colors.red);
      });
    });

    group('Unauthenticated State', () {
      testWidgets('shows login message when not authenticated', (tester) async {
        when(() => mockAuthBloc.state)
            .thenReturn(const AuthenticationUnauthenticated());

        await tester.pumpWidget(createTestWidget());

        expect(find.text('Please log in to create a training session'),
            findsOneWidget);
      });
    });
  });
}
