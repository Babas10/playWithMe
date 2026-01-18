// Widget tests for GroupCreationPage verifying UI rendering and user interactions.
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/data/models/group_model.dart';
import 'package:play_with_me/core/presentation/bloc/group/group_bloc.dart';
import 'package:play_with_me/core/presentation/bloc/group/group_event.dart';
import 'package:play_with_me/core/presentation/bloc/group/group_state.dart';
import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_event.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_state.dart';
import 'package:play_with_me/features/groups/presentation/pages/group_creation_page.dart';

class MockGroupBloc extends MockBloc<GroupEvent, GroupState>
    implements GroupBloc {}

class MockAuthenticationBloc
    extends MockBloc<AuthenticationEvent, AuthenticationState>
    implements AuthenticationBloc {}

class FakeGroupEvent extends Fake implements GroupEvent {}

class FakeGroupState extends Fake implements GroupState {}

void main() {
  late MockGroupBloc mockGroupBloc;
  late MockAuthenticationBloc mockAuthBloc;

  const testUserId = 'test-user-123';

  setUpAll(() {
    registerFallbackValue(FakeGroupEvent());
    registerFallbackValue(FakeGroupState());
  });

  setUp(() {
    mockGroupBloc = MockGroupBloc();
    mockAuthBloc = MockAuthenticationBloc();

    when(() => mockGroupBloc.state).thenReturn(const GroupInitial());

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
  });

  tearDown(() {
    mockGroupBloc.close();
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<GroupBloc>.value(value: mockGroupBloc),
          BlocProvider<AuthenticationBloc>.value(value: mockAuthBloc),
        ],
        child: const GroupCreationPage(),
      ),
    );
  }

  group('GroupCreationPage Widget Tests', () {
    group('Initial UI Rendering', () {
      testWidgets('renders app bar with Create Group title', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.byType(AppBar), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.text('Create Group'),
          ),
          findsOneWidget,
        );
      });

      testWidgets('renders header text', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(
          find.text('Create a new group for organizing volleyball games'),
          findsOneWidget,
        );
      });

      testWidgets('renders group name input field', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Group Name *'), findsOneWidget);
        expect(find.byIcon(Icons.group), findsOneWidget);
      });

      testWidgets('renders description input field', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Description (Optional)'), findsOneWidget);
        expect(find.byIcon(Icons.description), findsOneWidget);
      });

      testWidgets('renders info card', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(
          find.text(
              'You will automatically become the group admin and first member'),
          findsOneWidget,
        );
        expect(find.byIcon(Icons.info_outline), findsOneWidget);
      });

      testWidgets('renders create group button', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Scroll to make button visible
        final createButton = find.text('Create Group');
        await tester.ensureVisible(createButton.last);
        await tester.pumpAndSettle();

        // Should find "Create Group" text (in button and possibly app bar)
        expect(createButton, findsWidgets);
      });

      testWidgets('renders cancel button', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Scroll to make button visible
        final cancelButton = find.text('Cancel');
        await tester.ensureVisible(cancelButton);
        await tester.pumpAndSettle();

        expect(cancelButton, findsOneWidget);
      });
    });

    group('Group Name Input Field', () {
      testWidgets('can enter group name', (tester) async {
        await tester.pumpWidget(createTestWidget());

        final nameField = find.widgetWithText(TextFormField, 'Group Name *');
        await tester.enterText(nameField, 'Beach Volleyball Crew');
        await tester.pump();

        expect(find.text('Beach Volleyball Crew'), findsOneWidget);
      });

      testWidgets('shows validation error for empty name', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Scroll to and tap create group button
        final createButton = find.byWidgetPredicate(
          (widget) => widget is FilledButton,
          description: 'FilledButton',
        );
        await tester.ensureVisible(createButton);
        await tester.pumpAndSettle();
        await tester.tap(createButton);
        await tester.pumpAndSettle();

        expect(find.text('Group name cannot be empty'), findsOneWidget);
      });

      testWidgets('shows validation error for short name', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Enter short name
        final nameField = find.widgetWithText(TextFormField, 'Group Name *');
        await tester.enterText(nameField, 'AB');
        await tester.pump();

        // Tap create group button
        final createButton = find.byWidgetPredicate((widget) => widget is FilledButton);
        await tester.ensureVisible(createButton);
        await tester.pumpAndSettle();
        await tester.tap(createButton);
        await tester.pumpAndSettle();

        expect(
            find.text('Group name must be at least 3 characters'), findsOneWidget);
      });

      testWidgets('shows character counter for max length', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // The character counter should show 0/50
        expect(find.textContaining('/50'), findsOneWidget);
      });
    });

    group('Description Input Field', () {
      testWidgets('can enter description', (tester) async {
        await tester.pumpWidget(createTestWidget());

        final descField =
            find.widgetWithText(TextFormField, 'Description (Optional)');
        await tester.enterText(descField, 'Weekly beach volleyball games');
        await tester.pump();

        expect(find.text('Weekly beach volleyball games'), findsOneWidget);
      });

      testWidgets('description is optional', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Enter only group name
        final nameField = find.widgetWithText(TextFormField, 'Group Name *');
        await tester.enterText(nameField, 'Beach Volleyball Crew');
        await tester.pump();

        // Tap create group button
        final createButton = find.byWidgetPredicate((widget) => widget is FilledButton);
        await tester.ensureVisible(createButton);
        await tester.pumpAndSettle();
        await tester.tap(createButton);
        await tester.pump();

        // Should trigger CreateGroup event (no validation errors)
        verify(
          () => mockGroupBloc.add(any(that: isA<CreateGroup>())),
        ).called(1);
      });

      testWidgets('shows character counter for max length', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // The character counter should show 0/200
        expect(find.textContaining('/200'), findsOneWidget);
      });
    });

    group('Create Button', () {
      testWidgets('triggers CreateGroup event on tap with valid data',
          (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Enter valid group name
        final nameField = find.widgetWithText(TextFormField, 'Group Name *');
        await tester.enterText(nameField, 'Beach Volleyball Crew');
        await tester.pump();

        // Enter optional description
        final descField =
            find.widgetWithText(TextFormField, 'Description (Optional)');
        await tester.enterText(descField, 'Weekly games at the beach');
        await tester.pump();

        // Tap create group button
        final createButton = find.byWidgetPredicate((widget) => widget is FilledButton);
        await tester.ensureVisible(createButton);
        await tester.pumpAndSettle();
        await tester.tap(createButton);
        await tester.pump();

        verify(
          () => mockGroupBloc.add(any(that: isA<CreateGroup>())),
        ).called(1);
      });

      testWidgets('does not trigger event with invalid form', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Tap create group button without entering data
        final createButton = find.byWidgetPredicate((widget) => widget is FilledButton);
        await tester.ensureVisible(createButton);
        await tester.pumpAndSettle();
        await tester.tap(createButton);
        await tester.pump();

        verifyNever(
          () => mockGroupBloc.add(any(that: isA<CreateGroup>())),
        );
      });
    });

    group('Loading State', () {
      testWidgets('shows loading indicator during creation', (tester) async {
        when(() => mockGroupBloc.state).thenReturn(const GroupLoading());

        await tester.pumpWidget(createTestWidget());

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Creating...'), findsOneWidget);
      });

      testWidgets('button is disabled during loading', (tester) async {
        when(() => mockGroupBloc.state).thenReturn(const GroupLoading());

        await tester.pumpWidget(createTestWidget());

        // Scroll to button
        final createButton = find.byWidgetPredicate((widget) => widget is FilledButton).first;
        await tester.ensureVisible(createButton);
        await tester.pump();

        final filledButton = tester.widget<FilledButton>(createButton);
        expect(filledButton.onPressed, isNull);
      });

      testWidgets('form fields are disabled during loading', (tester) async {
        when(() => mockGroupBloc.state).thenReturn(const GroupLoading());

        await tester.pumpWidget(createTestWidget());

        final nameField = tester.widget<TextFormField>(
          find.widgetWithText(TextFormField, 'Group Name *'),
        );
        expect(nameField.enabled, isFalse);
      });
    });

    group('Success Handling', () {
      testWidgets('shows success snackbar on group creation', (tester) async {
        final createdGroup = GroupModel(
          id: 'new-group-id',
          name: 'Beach Volleyball Crew',
          createdBy: testUserId,
          createdAt: DateTime.now(),
          memberIds: [testUserId],
          adminIds: [testUserId],
          lastActivity: DateTime.now(),
        );

        whenListen(
          mockGroupBloc,
          Stream.fromIterable([
            const GroupInitial(),
            const GroupLoading(),
            GroupCreated(groupId: 'new-group-id', group: createdGroup),
          ]),
          initialState: const GroupInitial(),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Group created successfully!'), findsOneWidget);
        expect(find.byType(SnackBar), findsOneWidget);

        // Complete the pending timer from Future.delayed in the source
        await tester.pump(const Duration(milliseconds: 600));
      });

      testWidgets('success snackbar has green background', (tester) async {
        final createdGroup = GroupModel(
          id: 'new-group-id',
          name: 'Beach Volleyball Crew',
          createdBy: testUserId,
          createdAt: DateTime.now(),
          memberIds: [testUserId],
          adminIds: [testUserId],
          lastActivity: DateTime.now(),
        );

        whenListen(
          mockGroupBloc,
          Stream.fromIterable([
            const GroupInitial(),
            GroupCreated(groupId: 'new-group-id', group: createdGroup),
          ]),
          initialState: const GroupInitial(),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
        expect(snackBar.backgroundColor, Colors.green);

        // Complete the pending timer
        await tester.pump(const Duration(milliseconds: 600));
      });
    });

    group('Error Handling', () {
      testWidgets('shows error snackbar on failure', (tester) async {
        whenListen(
          mockGroupBloc,
          Stream.fromIterable([
            const GroupInitial(),
            const GroupLoading(),
            const GroupError(message: 'Failed to create group'),
          ]),
          initialState: const GroupInitial(),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(
            find.textContaining('Failed to create group'), findsOneWidget);
        expect(find.byType(SnackBar), findsOneWidget);
      });

      testWidgets('error snackbar has red background', (tester) async {
        whenListen(
          mockGroupBloc,
          Stream.fromIterable([
            const GroupInitial(),
            const GroupError(message: 'Error message'),
          ]),
          initialState: const GroupInitial(),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
        expect(snackBar.backgroundColor, Colors.red);
      });
    });

    group('Cancel Button', () {
      testWidgets('cancel button navigates back', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MultiBlocProvider(
                          providers: [
                            BlocProvider<GroupBloc>.value(value: mockGroupBloc),
                            BlocProvider<AuthenticationBloc>.value(
                                value: mockAuthBloc),
                          ],
                          child: const GroupCreationPage(),
                        ),
                      ),
                    );
                  },
                  child: const Text('Go to Create Group'),
                ),
              ),
            ),
          ),
        );

        // Navigate to group creation page
        await tester.tap(find.text('Go to Create Group'));
        await tester.pumpAndSettle();

        // Verify we're on group creation page
        expect(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.text('Create Group'),
          ),
          findsOneWidget,
        );

        // Scroll to and tap Cancel
        final cancelButton = find.text('Cancel');
        await tester.ensureVisible(cancelButton);
        await tester.pumpAndSettle();
        await tester.tap(cancelButton);
        await tester.pumpAndSettle();

        // Should navigate back
        expect(find.text('Go to Create Group'), findsOneWidget);
      });
    });

    group('Unauthenticated State', () {
      testWidgets('shows login message when not authenticated', (tester) async {
        when(() => mockAuthBloc.state)
            .thenReturn(const AuthenticationUnauthenticated());

        await tester.pumpWidget(createTestWidget());

        expect(
            find.text('You must be logged in to create a group'), findsOneWidget);
      });
    });
  });
}
