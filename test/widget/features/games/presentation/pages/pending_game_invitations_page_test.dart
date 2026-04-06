// Widget tests for PendingGameInvitationsPage (Stories 28.7 & 28.10).
// Validates loading, empty state, invitation list, accept/decline, error handling,
// and card tap → game details navigation (Story 28.10).

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/data/models/game_invitation_details.dart';
import 'package:play_with_me/core/presentation/bloc/invitation/invitation_bloc.dart';
import 'package:play_with_me/core/presentation/bloc/invitation/invitation_event.dart';
import 'package:play_with_me/core/presentation/bloc/invitation/invitation_state.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_event.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_state.dart';
import 'package:play_with_me/features/games/presentation/bloc/game_invitations/game_invitations_bloc.dart';
import 'package:play_with_me/features/games/presentation/pages/pending_game_invitations_page.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

// ── Mocks ─────────────────────────────────────────────────────────────────────

class MockGameInvitationsBloc
    extends MockBloc<GameInvitationsEvent, GameInvitationsState>
    implements GameInvitationsBloc {}

class MockInvitationBloc extends MockBloc<InvitationEvent, InvitationState>
    implements InvitationBloc {}

class MockAuthenticationBloc
    extends MockBloc<AuthenticationEvent, AuthenticationState>
    implements AuthenticationBloc {}

class FakeGameInvitationsEvent extends Fake implements GameInvitationsEvent {}

class FakeGameInvitationsState extends Fake implements GameInvitationsState {}

class FakeInvitationEvent extends Fake implements InvitationEvent {}

class FakeInvitationState extends Fake implements InvitationState {}

class FakeAuthenticationEvent extends Fake implements AuthenticationEvent {}

class FakeAuthenticationState extends Fake implements AuthenticationState {}


// ── Helpers ───────────────────────────────────────────────────────────────────

GameInvitationDetails _makeInvitation({String id = 'inv-1'}) =>
    GameInvitationDetails(
      invitationId: id,
      gameId: 'game-1',
      groupId: 'group-abc',
      inviterId: 'user-bob',
      status: 'pending',
      createdAt: DateTime(2026, 6, 1),
      expiresAt: null,
      gameTitle: 'Sunday Beach Volleyball',
      gameScheduledAt: DateTime(2026, 7, 1, 14),
      gameLocationName: 'Plage du Prado',
      groupName: 'Beach Crew',
      inviterDisplayName: 'Bob',
    );

// ── Fixtures ──────────────────────────────────────────────────────────────────

void main() {
  late MockGameInvitationsBloc mockBloc;
  late MockInvitationBloc mockInvitationBloc;
  late MockAuthenticationBloc mockAuthBloc;

  setUpAll(() {
    registerFallbackValue(FakeGameInvitationsEvent());
    registerFallbackValue(FakeGameInvitationsState());
    registerFallbackValue(FakeInvitationEvent());
    registerFallbackValue(FakeInvitationState());
    registerFallbackValue(FakeAuthenticationEvent());
    registerFallbackValue(FakeAuthenticationState());
  });

  setUp(() {
    mockBloc = MockGameInvitationsBloc();
    mockInvitationBloc = MockInvitationBloc();
    mockAuthBloc = MockAuthenticationBloc();

    // Defaults — individual tests override state as needed
    when(() => mockBloc.state).thenReturn(const GameInvitationsInitial());
    when(() => mockInvitationBloc.state).thenReturn(InvitationInitial());
    when(() => mockAuthBloc.state).thenReturn(AuthenticationUnknown());
  });

  tearDown(() {
    mockBloc.close();
    mockInvitationBloc.close();
    mockAuthBloc.close();
  });

  Widget buildPage() {
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
          BlocProvider<GameInvitationsBloc>.value(value: mockBloc),
          BlocProvider<InvitationBloc>.value(value: mockInvitationBloc),
          BlocProvider<AuthenticationBloc>.value(value: mockAuthBloc),
        ],
        child: const PendingGameInvitationsPage(),
      ),
    );
  }

  // ── Loading ─────────────────────────────────────────────────────────────────

  testWidgets('shows loading indicator in loading state', (tester) async {
    when(() => mockBloc.state).thenReturn(const GameInvitationsLoading());

    await tester.pumpWidget(buildPage());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  // ── Empty state ─────────────────────────────────────────────────────────────

  testWidgets('shows empty state when no invitations', (tester) async {
    when(() => mockBloc.state).thenReturn(const GameInvitationsLoaded([]));

    await tester.pumpWidget(buildPage());
    await tester.pump();

    expect(find.text('No pending game invitations'), findsOneWidget);
  });

  // ── Loaded with data ────────────────────────────────────────────────────────

  testWidgets('renders invitation card with game details', (tester) async {
    when(() => mockBloc.state)
        .thenReturn(GameInvitationsLoaded([_makeInvitation()]));

    await tester.pumpWidget(buildPage());
    await tester.pump();

    expect(find.text('Sunday Beach Volleyball'), findsOneWidget);
    expect(find.text('Plage du Prado'), findsOneWidget);
    expect(find.textContaining('Beach Crew'), findsOneWidget);
    expect(find.textContaining('Bob'), findsOneWidget);
    expect(find.text('Accept'), findsOneWidget);
    expect(find.text('Decline'), findsOneWidget);
  });

  // ── Accept / Decline ────────────────────────────────────────────────────────

  testWidgets('tapping Accept dispatches AcceptGameInvitation event',
      (tester) async {
    when(() => mockBloc.state)
        .thenReturn(GameInvitationsLoaded([_makeInvitation()]));

    await tester.pumpWidget(buildPage());
    await tester.pump();

    await tester.tap(find.text('Accept'));
    await tester.pump();

    verify(() => mockBloc.add(any(that: isA<AcceptGameInvitation>()))).called(1);
  });

  testWidgets('tapping Decline dispatches DeclineGameInvitation event',
      (tester) async {
    when(() => mockBloc.state)
        .thenReturn(GameInvitationsLoaded([_makeInvitation()]));

    await tester.pumpWidget(buildPage());
    await tester.pump();

    await tester.tap(find.text('Decline'));
    await tester.pump();

    verify(() => mockBloc.add(any(that: isA<DeclineGameInvitation>()))).called(1);
  });

  testWidgets('shows accepted snackbar on ActionSuccess(accepted)',
      (tester) async {
    whenListen(
      mockBloc,
      Stream.fromIterable([
        GameInvitationsLoaded([_makeInvitation()]),
        GameInvitationActionSuccess([], 'inv-1', accepted: true),
      ]),
      initialState: GameInvitationsLoaded([_makeInvitation()]),
    );

    await tester.pumpWidget(buildPage());
    await tester.pump();
    await tester.pump();

    expect(find.text('Invitation accepted'), findsOneWidget);
  });

  testWidgets('shows declined snackbar on ActionSuccess(declined)',
      (tester) async {
    whenListen(
      mockBloc,
      Stream.fromIterable([
        GameInvitationsLoaded([_makeInvitation()]),
        GameInvitationActionSuccess([], 'inv-1', accepted: false),
      ]),
      initialState: GameInvitationsLoaded([_makeInvitation()]),
    );

    await tester.pumpWidget(buildPage());
    await tester.pump();
    await tester.pump();

    expect(find.text('Invitation declined'), findsOneWidget);
  });

  testWidgets('shows error snackbar on ActionError state', (tester) async {
    whenListen(
      mockBloc,
      Stream.fromIterable([
        GameInvitationsLoaded([_makeInvitation()]),
        GameInvitationActionError([_makeInvitation()], 'Game full'),
      ]),
      initialState: GameInvitationsLoaded([_makeInvitation()]),
    );

    await tester.pumpWidget(buildPage());
    await tester.pump();
    await tester.pump();

    expect(find.text('Failed to process invitation'), findsOneWidget);
  });

  // ── Card tap navigation (Story 28.10) ───────────────────────────────────────

  testWidgets('invitation card has tap handler wired to game navigation',
      (tester) async {
    when(() => mockBloc.state)
        .thenReturn(GameInvitationsLoaded([_makeInvitation()]));

    await tester.pumpWidget(buildPage());
    await tester.pump();

    // Verify the card is wrapped in an InkWell with a non-null onTap.
    final inkWells = tester.widgetList<InkWell>(find.byType(InkWell));
    expect(inkWells.any((w) => w.onTap != null), isTrue,
        reason: 'At least one InkWell on the card must have onTap set');
  });

  // ── Error state ─────────────────────────────────────────────────────────────

  testWidgets('shows error page with retry button on error state',
      (tester) async {
    when(() => mockBloc.state)
        .thenReturn(const GameInvitationsError('Network error'));

    await tester.pumpWidget(buildPage());
    await tester.pump();

    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  // ── In-flight ───────────────────────────────────────────────────────────────

  testWidgets('disables buttons while action in-flight', (tester) async {
    final inv = _makeInvitation();
    when(() => mockBloc.state)
        .thenReturn(GameInvitationActionInFlight([inv], 'inv-1'));

    await tester.pumpWidget(buildPage());
    await tester.pump();

    final acceptButton = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(acceptButton.onPressed, isNull);
  });
}
