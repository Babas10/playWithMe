// Widget tests for GameCreationPage verifying UI rendering and user interactions.
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/l10n/app_localizations.dart';
import 'package:play_with_me/core/data/models/game_model.dart';
import 'package:play_with_me/core/presentation/bloc/invitation/invitation_bloc.dart';
import 'package:play_with_me/core/presentation/bloc/invitation/invitation_event.dart';
import 'package:play_with_me/core/presentation/bloc/invitation/invitation_state.dart';
import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_state.dart';
import 'package:play_with_me/features/games/presentation/bloc/game_creation/game_creation_bloc.dart';
import 'package:play_with_me/features/games/presentation/bloc/game_creation/game_creation_event.dart';
import 'package:play_with_me/features/games/presentation/bloc/game_creation/game_creation_state.dart';
import 'package:play_with_me/features/games/presentation/pages/game_creation_page.dart';

class MockGameCreationBloc
    extends MockBloc<GameCreationEvent, GameCreationState>
    implements GameCreationBloc {}

class MockAuthenticationBloc extends Mock implements AuthenticationBloc {}

class MockInvitationBloc
    extends MockBloc<InvitationEvent, InvitationState>
    implements InvitationBloc {}

class FakeGameCreationEvent extends Fake implements GameCreationEvent {}

class FakeGameCreationState extends Fake implements GameCreationState {}

void main() {
  late MockGameCreationBloc mockGameCreationBloc;
  late MockAuthenticationBloc mockAuthBloc;
  late MockInvitationBloc mockInvitationBloc;

  const testUserId = 'test-user-123';
  const testGroupId = 'test-group-123';
  const testGroupName = 'Beach Volleyball Crew';

  setUpAll(() {
    registerFallbackValue(FakeGameCreationEvent());
    registerFallbackValue(FakeGameCreationState());
  });

  setUp(() {
    mockGameCreationBloc = MockGameCreationBloc();
    mockAuthBloc = MockAuthenticationBloc();
    mockInvitationBloc = MockInvitationBloc();
    when(() => mockInvitationBloc.state).thenReturn(const InvitationInitial());

    when(() => mockGameCreationBloc.state)
        .thenReturn(const GameCreationInitial());

    when(() => mockAuthBloc.state).thenReturn(
      AuthenticationAuthenticated(
        UserEntity(
          uid: testUserId,
          email: 'test@example.com',
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
    mockGameCreationBloc.close();
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
          BlocProvider<GameCreationBloc>.value(value: mockGameCreationBloc),
          BlocProvider<AuthenticationBloc>.value(value: mockAuthBloc),
          BlocProvider<InvitationBloc>.value(value: mockInvitationBloc),
        ],
        child: const GameCreationPage(
          groupId: testGroupId,
          groupName: testGroupName,
        ),
      ),
    );
  }

  group('GameCreationPage Widget Tests', () {
    group('Initial UI Rendering', () {
      testWidgets('renders app bar with Create Game title', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.byType(AppBar), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.text('Create Game'),
          ),
          findsOneWidget,
        );
      });

      testWidgets('renders group card with group name', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Group'), findsOneWidget);
        expect(find.text(testGroupName), findsOneWidget);
        expect(find.byIcon(Icons.group), findsOneWidget);
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
      });

      testWidgets('renders game title input field', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Game Title'), findsOneWidget);
        // One in form field + one in PlayWithMeAppBar title
        expect(find.byIcon(Icons.sports_volleyball), findsNWidgets(2));
      });

      testWidgets('renders description input field', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Description (Optional)'), findsOneWidget);
        expect(find.byIcon(Icons.description), findsOneWidget);
      });

      testWidgets('renders date and time selector', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Date & Time'), findsOneWidget);
        // 'Tap to select' appears twice: in ListTile subtitle and as validation hint
        expect(find.text('Tap to select'), findsNWidgets(2));
        expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      });

      testWidgets('renders location input field', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Location'), findsOneWidget);
        expect(find.byIcon(Icons.location_on), findsOneWidget);
      });

      testWidgets('renders address input field', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Address (Optional)'), findsOneWidget);
        expect(find.byIcon(Icons.place), findsOneWidget);
      });

      testWidgets('renders create game button', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Scroll to make button visible
        final createButton =
            find.widgetWithText(ElevatedButton, 'Create Game');
        await tester.ensureVisible(createButton);
        await tester.pumpAndSettle();

        expect(createButton, findsOneWidget);
      });

      testWidgets('sends SelectGroup event on init', (tester) async {
        await tester.pumpWidget(createTestWidget());

        verify(
          () => mockGameCreationBloc.add(
            const SelectGroup(
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

        final titleField = find.widgetWithText(TextFormField, 'Game Title');
        await tester.enterText(titleField, 'Beach Volleyball Match');
        await tester.pump();

        expect(find.text('Beach Volleyball Match'), findsOneWidget);
      });

      testWidgets('shows validation error for empty title', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Fill location to avoid multiple validation errors
        final locationField = find.widgetWithText(TextFormField, 'Location');
        await tester.enterText(locationField, 'Venice Beach');
        await tester.pump();

        // Scroll to and tap create game button
        final createButton =
            find.widgetWithText(ElevatedButton, 'Create Game');
        await tester.ensureVisible(createButton);
        await tester.pumpAndSettle();
        await tester.tap(createButton);
        await tester.pumpAndSettle();

        expect(find.text('Please enter a game title'), findsOneWidget);
      });

      testWidgets('shows validation error for short title', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Enter short title
        final titleField = find.widgetWithText(TextFormField, 'Game Title');
        await tester.enterText(titleField, 'AB');
        await tester.pump();

        // Fill location
        final locationField = find.widgetWithText(TextFormField, 'Location');
        await tester.enterText(locationField, 'Venice Beach');
        await tester.pump();

        // Tap create game button
        final createButton =
            find.widgetWithText(ElevatedButton, 'Create Game');
        await tester.ensureVisible(createButton);
        await tester.pumpAndSettle();
        await tester.tap(createButton);
        await tester.pumpAndSettle();

        expect(find.text('Title must be at least 3 characters'), findsOneWidget);
      });
    });

    group('Description Input Field', () {
      testWidgets('can enter description text', (tester) async {
        await tester.pumpWidget(createTestWidget());

        final descriptionField =
            find.widgetWithText(TextFormField, 'Description (Optional)');
        await tester.enterText(descriptionField, 'Fun game at the beach!');
        await tester.pump();

        expect(find.text('Fun game at the beach!'), findsOneWidget);
      });
    });

    group('Location Input Field', () {
      testWidgets('can enter location text', (tester) async {
        await tester.pumpWidget(createTestWidget());

        final locationField = find.widgetWithText(TextFormField, 'Location');
        await tester.enterText(locationField, 'Venice Beach');
        await tester.pump();

        expect(find.text('Venice Beach'), findsOneWidget);
      });

      testWidgets('shows validation error for empty location', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Fill title to avoid multiple validation errors
        final titleField = find.widgetWithText(TextFormField, 'Game Title');
        await tester.enterText(titleField, 'Beach Volleyball Match');
        await tester.pump();

        // Tap create game button
        final createButton =
            find.widgetWithText(ElevatedButton, 'Create Game');
        await tester.ensureVisible(createButton);
        await tester.pumpAndSettle();
        await tester.tap(createButton);
        await tester.pumpAndSettle();

        expect(find.text('Please enter a location'), findsOneWidget);
      });
    });

    group('Address Input Field', () {
      testWidgets('can enter address text', (tester) async {
        await tester.pumpWidget(createTestWidget());

        final addressField =
            find.widgetWithText(TextFormField, 'Address (Optional)');
        await tester.enterText(addressField, '123 Beach Street');
        await tester.pump();

        expect(find.text('123 Beach Street'), findsOneWidget);
      });
    });

    group('Date & Time Selector', () {
      testWidgets('date time selector is tappable', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Find the ListTile with the calendar icon (date time selector)
        final dateTimeTile = find.ancestor(
          of: find.byIcon(Icons.calendar_today),
          matching: find.byType(ListTile),
        );
        expect(dateTimeTile, findsOneWidget);

        // Verify the list tile is tappable
        await tester.tap(dateTimeTile);
        await tester.pump();

        // Date picker dialog should appear
        expect(find.byType(DatePickerDialog), findsOneWidget);
      });

      testWidgets('shows date validation message when not selected',
          (tester) async {
        await tester.pumpWidget(createTestWidget());

        // The widget shows 'Tap to select' as the validation hint
        // It appears in the ListTile subtitle and as validation text
        expect(
          find.text('Tap to select'),
          findsNWidgets(2),
        );
      });
    });

    group('Loading State', () {
      testWidgets('shows loading indicator during submission', (tester) async {
        when(() => mockGameCreationBloc.state)
            .thenReturn(const GameCreationSubmitting());

        await tester.pumpWidget(createTestWidget());

        // Scroll to button
        final createButton = find.byType(ElevatedButton);
        await tester.ensureVisible(createButton);
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('button is disabled during loading', (tester) async {
        when(() => mockGameCreationBloc.state)
            .thenReturn(const GameCreationSubmitting());

        await tester.pumpWidget(createTestWidget());

        // Scroll to button
        final createButton = find.byType(ElevatedButton);
        await tester.ensureVisible(createButton);
        await tester.pump();

        final elevatedButton = tester.widget<ElevatedButton>(createButton);
        expect(elevatedButton.onPressed, isNull);
      });

      testWidgets('form fields are disabled during loading', (tester) async {
        when(() => mockGameCreationBloc.state)
            .thenReturn(const GameCreationSubmitting());

        await tester.pumpWidget(createTestWidget());

        final titleField = tester.widget<TextFormField>(
          find.widgetWithText(TextFormField, 'Game Title'),
        );
        expect(titleField.enabled, isFalse);
      });
    });

    group('Success Handling', () {
      testWidgets('shows success snackbar on game creation', (tester) async {
        final testGame = GameModel(
          id: 'test-game-id',
          title: 'Test Game',
          groupId: testGroupId,
          createdBy: testUserId,
          createdAt: DateTime.now(),
          scheduledAt: DateTime.now().add(const Duration(days: 1)),
          location: GameLocation(name: 'Venice Beach'),
          maxPlayers: 4,
          minPlayers: 2,
          playerIds: [testUserId],
        );

        whenListen(
          mockGameCreationBloc,
          Stream.fromIterable([
            const GameCreationInitial(),
            const GameCreationSubmitting(),
            GameCreationSuccess(gameId: 'test-game-id', game: testGame),
          ]),
          initialState: const GameCreationInitial(),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Game created successfully!'), findsOneWidget);
        expect(find.byType(SnackBar), findsOneWidget);

        // Complete the pending timer from Future.delayed in the source
        await tester.pump(const Duration(milliseconds: 600));
      });

      testWidgets('success snackbar has green background', (tester) async {
        final testGame = GameModel(
          id: 'test-game-id',
          title: 'Test Game',
          groupId: testGroupId,
          createdBy: testUserId,
          createdAt: DateTime.now(),
          scheduledAt: DateTime.now().add(const Duration(days: 1)),
          location: GameLocation(name: 'Venice Beach'),
          maxPlayers: 4,
          minPlayers: 2,
          playerIds: [testUserId],
        );

        whenListen(
          mockGameCreationBloc,
          Stream.fromIterable([
            const GameCreationInitial(),
            GameCreationSuccess(gameId: 'test-game-id', game: testGame),
          ]),
          initialState: const GameCreationInitial(),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
        expect(snackBar.backgroundColor, Colors.green);

        // Complete the pending timer from Future.delayed in the source
        await tester.pump(const Duration(milliseconds: 600));
      });
    });

    group('Error Handling', () {
      testWidgets('shows error snackbar on failure', (tester) async {
        whenListen(
          mockGameCreationBloc,
          Stream.fromIterable([
            const GameCreationInitial(),
            const GameCreationSubmitting(),
            const GameCreationError(message: 'Failed to create game'),
          ]),
          initialState: const GameCreationInitial(),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Failed to create game'), findsOneWidget);
        expect(find.byType(SnackBar), findsOneWidget);
      });

      testWidgets('error snackbar has red background', (tester) async {
        whenListen(
          mockGameCreationBloc,
          Stream.fromIterable([
            const GameCreationInitial(),
            const GameCreationError(message: 'Error message'),
          ]),
          initialState: const GameCreationInitial(),
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

        expect(find.text('Please log in to create a game'), findsOneWidget);
      });
    });
  });
}
