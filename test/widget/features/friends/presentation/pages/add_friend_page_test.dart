// Widget tests for AddFriendPage verifying search and friend request functionality (Story 16.3.3.3).

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
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_event.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_state.dart';
import 'package:play_with_me/features/friends/presentation/bloc/friend_bloc.dart';
import 'package:play_with_me/features/friends/presentation/bloc/friend_event.dart';
import 'package:play_with_me/features/friends/presentation/bloc/friend_state.dart';
import 'package:play_with_me/features/friends/presentation/pages/add_friend_page.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

class MockFriendBloc extends MockBloc<FriendEvent, FriendState>
    implements FriendBloc {}

class MockAuthenticationBloc
    extends MockBloc<AuthenticationEvent, AuthenticationState>
    implements AuthenticationBloc {}

class MockInvitationBloc
    extends MockBloc<InvitationEvent, InvitationState>
    implements InvitationBloc {}

class FakeFriendEvent extends Fake implements FriendEvent {}

class FakeFriendState extends Fake implements FriendState {}

class FakeAuthenticationEvent extends Fake implements AuthenticationEvent {}

class FakeAuthenticationState extends Fake implements AuthenticationState {}

void main() {
  late MockFriendBloc mockFriendBloc;
  late MockAuthenticationBloc mockAuthBloc;
  late MockInvitationBloc mockInvitationBloc;

  final testUser = UserEntity(
    uid: 'test-user-123',
    email: 'test@example.com',
    displayName: 'Test User',
    isEmailVerified: true,
    isAnonymous: false,
  );

  final searchedUser = UserEntity(
    uid: 'found-user-456',
    email: 'found@example.com',
    displayName: 'Found User',
    isEmailVerified: true,
    isAnonymous: false,
  );

  setUpAll(() {
    registerFallbackValue(FakeFriendEvent());
    registerFallbackValue(FakeFriendState());
    registerFallbackValue(FakeAuthenticationEvent());
    registerFallbackValue(FakeAuthenticationState());
  });

  setUp(() {
    mockFriendBloc = MockFriendBloc();
    mockAuthBloc = MockAuthenticationBloc();
    mockInvitationBloc = MockInvitationBloc();
    when(() => mockInvitationBloc.state).thenReturn(const InvitationInitial());

    when(() => mockFriendBloc.state).thenReturn(const FriendState.initial());
    when(() => mockAuthBloc.state)
        .thenReturn(AuthenticationAuthenticated(testUser));
  });

  tearDown(() {
    mockFriendBloc.close();
    mockAuthBloc.close();
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
          BlocProvider<FriendBloc>.value(value: mockFriendBloc),
          BlocProvider<AuthenticationBloc>.value(value: mockAuthBloc),
          BlocProvider<InvitationBloc>.value(value: mockInvitationBloc),
        ],
        child: const AddFriendPage(),
      ),
    );
  }

  group('AddFriendPage Widget Tests', () {
    group('Initial UI Rendering', () {
      testWidgets('renders app bar with Add Friend title', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byType(AppBar), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.text('Add Friend'),
          ),
          findsOneWidget,
        );
      });

      testWidgets('renders search input field with email icon', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byType(TextField), findsOneWidget);
        expect(find.byIcon(Icons.email_outlined), findsOneWidget);
      });

      testWidgets('renders search button with icon', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // FilledButton.icon creates a _FilledButtonWithIcon internally
        // Find by search icon instead
        expect(find.byIcon(Icons.search), findsOneWidget);
      });

      testWidgets('renders empty state with search icon', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byIcon(Icons.person_search), findsOneWidget);
      });

      testWidgets('search button is disabled when input is empty',
          (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // The button is disabled when input is empty
        // Find button by using byWidgetPredicate to find exactly _FilledButtonWithIcon
        final buttonFinder = find.byWidgetPredicate((widget) =>
            widget.runtimeType.toString() == '_FilledButtonWithIcon');
        expect(buttonFinder, findsOneWidget);

        // Check button is disabled by tapping it and verifying no event is dispatched
        await tester.tap(buttonFinder);
        await tester.pump();
        verifyNever(() => mockFriendBloc.add(any()));
      });
    });

    group('Unauthenticated State', () {
      testWidgets('shows login prompt when not authenticated', (tester) async {
        when(() => mockAuthBloc.state)
            .thenReturn(const AuthenticationUnauthenticated());

        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.text('Please log in to add friends'), findsOneWidget);
      });
    });

    group('Search Input', () {
      testWidgets('can enter email text', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        final textField = find.byType(TextField);
        await tester.enterText(textField, 'friend@example.com');
        await tester.pump();

        expect(find.text('friend@example.com'), findsOneWidget);
      });

      testWidgets('search button becomes enabled when text is entered',
          (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        final textField = find.byType(TextField);
        await tester.enterText(textField, 'friend@example.com');
        await tester.pump();

        // Tap the search icon to trigger search - button should be enabled
        final searchIcon = find.byIcon(Icons.search);
        expect(searchIcon, findsOneWidget);
        await tester.tap(searchIcon);
        await tester.pump();

        // Verify the search event was dispatched (button was enabled)
        verify(
          () => mockFriendBloc.add(
            const FriendEvent.searchRequested(email: 'friend@example.com'),
          ),
        ).called(1);
      });

      testWidgets('shows clear button when text is entered', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        final textField = find.byType(TextField);
        await tester.enterText(textField, 'test@example.com');
        await tester.pump();

        expect(find.byIcon(Icons.clear), findsOneWidget);
      });

      testWidgets('clears text and dispatches event when clear button tapped',
          (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        final textField = find.byType(TextField);
        await tester.enterText(textField, 'test@example.com');
        await tester.pump();

        await tester.tap(find.byIcon(Icons.clear));
        await tester.pump();

        verify(() => mockFriendBloc.add(const FriendEvent.searchCleared()))
            .called(1);
      });
    });

    group('Search Action', () {
      testWidgets('dispatches search event when search button tapped',
          (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        final textField = find.byType(TextField);
        await tester.enterText(textField, 'friend@example.com');
        await tester.pump();

        // Tap the search icon (inside the button)
        await tester.tap(find.byIcon(Icons.search));
        await tester.pump();

        verify(
          () => mockFriendBloc.add(
            const FriendEvent.searchRequested(email: 'friend@example.com'),
          ),
        ).called(1);
      });

      testWidgets('dispatches search event when submitting via keyboard',
          (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        final textField = find.byType(TextField);
        await tester.enterText(textField, 'friend@example.com');
        await tester.pump();

        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pump();

        verify(
          () => mockFriendBloc.add(
            const FriendEvent.searchRequested(email: 'friend@example.com'),
          ),
        ).called(1);
      });

      testWidgets('does not dispatch search event when input is empty',
          (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pump();

        verifyNever(() => mockFriendBloc.add(any()));
      });
    });

    group('Loading State', () {
      testWidgets('shows loading indicator during search', (tester) async {
        when(() => mockFriendBloc.state)
            .thenReturn(const FriendState.searchLoading());

        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsWidgets);
      });

      testWidgets('disables search input during loading', (tester) async {
        when(() => mockFriendBloc.state)
            .thenReturn(const FriendState.searchLoading());

        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.enabled, isFalse);
      });

      testWidgets('search button shows loading indicator when searching',
          (tester) async {
        when(() => mockFriendBloc.state)
            .thenReturn(const FriendState.searchLoading());

        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // The button should have a CircularProgressIndicator inside it when loading
        // Find button using predicate since FilledButton.icon creates _FilledButtonWithIcon
        final buttonFinder = find.byWidgetPredicate((widget) =>
            widget.runtimeType.toString() == '_FilledButtonWithIcon');
        expect(buttonFinder, findsOneWidget);

        // There should be loading indicator in the button
        expect(
          find.descendant(
            of: buttonFinder,
            matching: find.byType(CircularProgressIndicator),
          ),
          findsOneWidget,
        );
      });
    });

    group('Search Results', () {
      testWidgets('displays search result when user found', (tester) async {
        when(() => mockFriendBloc.state).thenReturn(
          FriendState.searchResult(
            user: searchedUser,
            isFriend: false,
            hasPendingRequest: false,
            searchedEmail: 'found@example.com',
          ),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byType(ListView), findsOneWidget);
      });

      testWidgets('displays result for already friends', (tester) async {
        when(() => mockFriendBloc.state).thenReturn(
          FriendState.searchResult(
            user: searchedUser,
            isFriend: true,
            hasPendingRequest: false,
            searchedEmail: 'found@example.com',
          ),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byType(ListView), findsOneWidget);
      });

      testWidgets('displays result for pending request sent', (tester) async {
        when(() => mockFriendBloc.state).thenReturn(
          FriendState.searchResult(
            user: searchedUser,
            isFriend: false,
            hasPendingRequest: true,
            requestDirection: 'sent',
            searchedEmail: 'found@example.com',
          ),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byType(ListView), findsOneWidget);
      });

      testWidgets('displays result for pending request received',
          (tester) async {
        when(() => mockFriendBloc.state).thenReturn(
          FriendState.searchResult(
            user: searchedUser,
            isFriend: false,
            hasPendingRequest: true,
            requestDirection: 'received',
            searchedEmail: 'found@example.com',
          ),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byType(ListView), findsOneWidget);
      });

      testWidgets('displays result when user not found', (tester) async {
        when(() => mockFriendBloc.state).thenReturn(
          const FriendState.searchResult(
            user: null,
            isFriend: false,
            hasPendingRequest: false,
            searchedEmail: 'notfound@example.com',
          ),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byType(ListView), findsOneWidget);
      });
    });

    group('Error Handling', () {
      testWidgets('shows snackbar on error state', (tester) async {
        whenListen(
          mockFriendBloc,
          Stream.fromIterable([
            const FriendState.initial(),
            const FriendState.error(message: 'Network error'),
          ]),
          initialState: const FriendState.initial(),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Network error'), findsOneWidget);
        expect(find.byType(SnackBar), findsOneWidget);
      });

      testWidgets('snackbar has red background on error', (tester) async {
        whenListen(
          mockFriendBloc,
          Stream.fromIterable([
            const FriendState.initial(),
            const FriendState.error(message: 'Error occurred'),
          ]),
          initialState: const FriendState.initial(),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
        expect(snackBar.backgroundColor, Colors.red);
      });
    });

    group('Success Handling', () {
      testWidgets('shows success snackbar after friend request sent',
          (tester) async {
        whenListen(
          mockFriendBloc,
          Stream.fromIterable([
            const FriendState.initial(),
            const FriendState.actionSuccess(
                message: 'Friend request sent successfully'),
          ]),
          initialState: const FriendState.initial(),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Friend request sent successfully'), findsOneWidget);
        expect(find.byType(SnackBar), findsOneWidget);
      });

      testWidgets('snackbar has green background on success', (tester) async {
        whenListen(
          mockFriendBloc,
          Stream.fromIterable([
            const FriendState.initial(),
            const FriendState.actionSuccess(message: 'Success!'),
          ]),
          initialState: const FriendState.initial(),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
        expect(snackBar.backgroundColor, Colors.green);
      });

      testWidgets('clears search after successful action', (tester) async {
        whenListen(
          mockFriendBloc,
          Stream.fromIterable([
            const FriendState.initial(),
            const FriendState.actionSuccess(message: 'Success!'),
          ]),
          initialState: const FriendState.initial(),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        verify(() => mockFriendBloc.add(const FriendEvent.searchCleared()))
            .called(1);
      });
    });
  });
}
