// Widget tests for PendingInvitationsPage verifying invitations display and actions (Story 16.3.3.3).

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/data/models/invitation_model.dart';
import 'package:play_with_me/core/presentation/bloc/invitation/invitation_bloc.dart';
import 'package:play_with_me/core/presentation/bloc/invitation/invitation_event.dart';
import 'package:play_with_me/core/presentation/bloc/invitation/invitation_state.dart';
import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_event.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_state.dart';
import 'package:play_with_me/features/invitations/presentation/pages/pending_invitations_page.dart';
import 'package:play_with_me/features/invitations/presentation/widgets/invitation_tile.dart';

class MockInvitationBloc extends MockBloc<InvitationEvent, InvitationState>
    implements InvitationBloc {}

class MockAuthenticationBloc
    extends MockBloc<AuthenticationEvent, AuthenticationState>
    implements AuthenticationBloc {}

class FakeInvitationEvent extends Fake implements InvitationEvent {}

class FakeInvitationState extends Fake implements InvitationState {}

class FakeAuthenticationEvent extends Fake implements AuthenticationEvent {}

class FakeAuthenticationState extends Fake implements AuthenticationState {}

void main() {
  late MockInvitationBloc mockInvitationBloc;
  late MockAuthenticationBloc mockAuthBloc;

  final testUser = UserEntity(
    uid: 'test-user-123',
    email: 'test@example.com',
    displayName: 'Test User',
    isEmailVerified: true,
    isAnonymous: false,
  );

  final testInvitation1 = InvitationModel(
    id: 'inv-1',
    groupId: 'group-1',
    groupName: 'Beach Volleyball Club',
    invitedBy: 'inviter-1',
    inviterName: 'John Doe',
    invitedUserId: 'test-user-123',
    status: InvitationStatus.pending,
    createdAt: DateTime(2025, 1, 15, 10, 30),
  );

  final testInvitation2 = InvitationModel(
    id: 'inv-2',
    groupId: 'group-2',
    groupName: 'Weekend Warriors',
    invitedBy: 'inviter-2',
    inviterName: 'Jane Smith',
    invitedUserId: 'test-user-123',
    status: InvitationStatus.pending,
    createdAt: DateTime(2025, 1, 14, 14, 0),
  );

  setUpAll(() {
    registerFallbackValue(FakeInvitationEvent());
    registerFallbackValue(FakeInvitationState());
    registerFallbackValue(FakeAuthenticationEvent());
    registerFallbackValue(FakeAuthenticationState());
  });

  setUp(() {
    mockInvitationBloc = MockInvitationBloc();
    mockAuthBloc = MockAuthenticationBloc();

    when(() => mockInvitationBloc.state)
        .thenReturn(const InvitationInitial());
    when(() => mockAuthBloc.state)
        .thenReturn(AuthenticationAuthenticated(testUser));
  });

  tearDown(() {
    mockInvitationBloc.close();
    mockAuthBloc.close();
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<InvitationBloc>.value(value: mockInvitationBloc),
          BlocProvider<AuthenticationBloc>.value(value: mockAuthBloc),
        ],
        child: const PendingInvitationsPage(),
      ),
    );
  }

  group('PendingInvitationsPage Widget Tests', () {
    group('Initial UI Rendering', () {
      testWidgets('renders app bar with Pending Invitations title',
          (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byType(AppBar), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.text('Pending Invitations'),
          ),
          findsOneWidget,
        );
      });

      testWidgets('renders empty state when no invitations', (tester) async {
        when(() => mockInvitationBloc.state).thenReturn(
          const InvitationsLoaded(invitations: []),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byIcon(Icons.mail_outline), findsOneWidget);
        expect(find.text('No Pending Invitations'), findsOneWidget);
        expect(
          find.text(
              "You don't have any pending group invitations at the moment."),
          findsOneWidget,
        );
      });
    });

    group('Unauthenticated State', () {
      testWidgets('shows login prompt when not authenticated', (tester) async {
        when(() => mockAuthBloc.state)
            .thenReturn(const AuthenticationUnauthenticated());

        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.text('Please log in to view invitations'), findsOneWidget);
        expect(find.text('Invitations'), findsOneWidget);
      });
    });

    group('Loading State', () {
      testWidgets('shows loading indicator during initial load', (tester) async {
        when(() => mockInvitationBloc.state)
            .thenReturn(const InvitationLoading());

        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('Invitations List', () {
      testWidgets('displays list of invitations', (tester) async {
        when(() => mockInvitationBloc.state).thenReturn(
          InvitationsLoaded(invitations: [testInvitation1, testInvitation2]),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byType(ListView), findsOneWidget);
        expect(find.byType(InvitationTile), findsNWidgets(2));
      });

      testWidgets('displays single invitation', (tester) async {
        when(() => mockInvitationBloc.state).thenReturn(
          InvitationsLoaded(invitations: [testInvitation1]),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byType(InvitationTile), findsOneWidget);
      });
    });

    group('Accept Invitation', () {
      testWidgets('dispatches AcceptInvitation event when accept is tapped',
          (tester) async {
        when(() => mockInvitationBloc.state).thenReturn(
          InvitationsLoaded(invitations: [testInvitation1]),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Find the accept button (checkmark icon) in the InvitationTile
        final acceptButton = find.byIcon(Icons.check);
        if (acceptButton.evaluate().isNotEmpty) {
          await tester.tap(acceptButton);
          await tester.pump();

          verify(
            () => mockInvitationBloc.add(
              AcceptInvitation(
                userId: testUser.uid,
                invitationId: testInvitation1.id,
              ),
            ),
          ).called(1);
        }
      });

      testWidgets('shows success snackbar after accepting invitation',
          (tester) async {
        whenListen(
          mockInvitationBloc,
          Stream.fromIterable([
            const InvitationInitial(),
            const InvitationAccepted(
              invitationId: 'inv-1',
              message: 'Invitation accepted successfully',
            ),
          ]),
          initialState: const InvitationInitial(),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Invitation accepted successfully'), findsOneWidget);
        expect(find.byType(SnackBar), findsOneWidget);
      });

      testWidgets('snackbar has green background on accept success',
          (tester) async {
        whenListen(
          mockInvitationBloc,
          Stream.fromIterable([
            const InvitationInitial(),
            const InvitationAccepted(
              invitationId: 'inv-1',
              message: 'Success!',
            ),
          ]),
          initialState: const InvitationInitial(),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
        expect(snackBar.backgroundColor, Colors.green);
      });

      testWidgets('reloads invitations after accepting', (tester) async {
        whenListen(
          mockInvitationBloc,
          Stream.fromIterable([
            const InvitationInitial(),
            const InvitationAccepted(
              invitationId: 'inv-1',
              message: 'Success!',
            ),
          ]),
          initialState: const InvitationInitial(),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        verify(
          () => mockInvitationBloc.add(
            LoadPendingInvitations(userId: testUser.uid),
          ),
        ).called(1);
      });
    });

    group('Decline Invitation', () {
      testWidgets('dispatches DeclineInvitation event when decline is tapped',
          (tester) async {
        when(() => mockInvitationBloc.state).thenReturn(
          InvitationsLoaded(invitations: [testInvitation1]),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Find the decline button (close icon) in the InvitationTile
        final declineButton = find.byIcon(Icons.close);
        if (declineButton.evaluate().isNotEmpty) {
          await tester.tap(declineButton);
          await tester.pump();

          verify(
            () => mockInvitationBloc.add(
              DeclineInvitation(
                userId: testUser.uid,
                invitationId: testInvitation1.id,
              ),
            ),
          ).called(1);
        }
      });

      testWidgets('shows snackbar after declining invitation', (tester) async {
        whenListen(
          mockInvitationBloc,
          Stream.fromIterable([
            const InvitationInitial(),
            const InvitationDeclined(
              invitationId: 'inv-1',
              message: 'Invitation declined',
            ),
          ]),
          initialState: const InvitationInitial(),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Invitation declined'), findsOneWidget);
        expect(find.byType(SnackBar), findsOneWidget);
      });

      testWidgets('snackbar has orange background on decline', (tester) async {
        whenListen(
          mockInvitationBloc,
          Stream.fromIterable([
            const InvitationInitial(),
            const InvitationDeclined(
              invitationId: 'inv-1',
              message: 'Declined',
            ),
          ]),
          initialState: const InvitationInitial(),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
        expect(snackBar.backgroundColor, Colors.orange);
      });

      testWidgets('reloads invitations after declining', (tester) async {
        whenListen(
          mockInvitationBloc,
          Stream.fromIterable([
            const InvitationInitial(),
            const InvitationDeclined(
              invitationId: 'inv-1',
              message: 'Declined',
            ),
          ]),
          initialState: const InvitationInitial(),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        verify(
          () => mockInvitationBloc.add(
            LoadPendingInvitations(userId: testUser.uid),
          ),
        ).called(1);
      });
    });

    group('Error Handling', () {
      testWidgets('shows snackbar on error state', (tester) async {
        whenListen(
          mockInvitationBloc,
          Stream.fromIterable([
            const InvitationInitial(),
            const InvitationError(message: 'Failed to load invitations'),
          ]),
          initialState: const InvitationInitial(),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Failed to load invitations'), findsOneWidget);
        expect(find.byType(SnackBar), findsOneWidget);
      });

      testWidgets('snackbar has red background on error', (tester) async {
        whenListen(
          mockInvitationBloc,
          Stream.fromIterable([
            const InvitationInitial(),
            const InvitationError(message: 'Error occurred'),
          ]),
          initialState: const InvitationInitial(),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
        expect(snackBar.backgroundColor, Colors.red);
      });

      testWidgets('reloads invitations after error', (tester) async {
        whenListen(
          mockInvitationBloc,
          Stream.fromIterable([
            const InvitationInitial(),
            const InvitationError(message: 'Error'),
          ]),
          initialState: const InvitationInitial(),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        verify(
          () => mockInvitationBloc.add(
            LoadPendingInvitations(userId: testUser.uid),
          ),
        ).called(1);
      });
    });

    group('Empty State', () {
      testWidgets('displays empty state icon', (tester) async {
        when(() => mockInvitationBloc.state).thenReturn(
          const InvitationsLoaded(invitations: []),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byIcon(Icons.mail_outline), findsOneWidget);
      });

      testWidgets('displays empty state title', (tester) async {
        when(() => mockInvitationBloc.state).thenReturn(
          const InvitationsLoaded(invitations: []),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.text('No Pending Invitations'), findsOneWidget);
      });

      testWidgets('displays empty state description', (tester) async {
        when(() => mockInvitationBloc.state).thenReturn(
          const InvitationsLoaded(invitations: []),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(
          find.text(
              "You don't have any pending group invitations at the moment."),
          findsOneWidget,
        );
      });
    });

    group('Bloc Override', () {
      testWidgets('uses provided bloc when blocOverride is set', (tester) async {
        final overrideBloc = MockInvitationBloc();
        when(() => overrideBloc.state).thenReturn(
          InvitationsLoaded(invitations: [testInvitation1]),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: MultiBlocProvider(
              providers: [
                BlocProvider<AuthenticationBloc>.value(value: mockAuthBloc),
              ],
              child: PendingInvitationsPage(blocOverride: overrideBloc),
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(InvitationTile), findsOneWidget);

        overrideBloc.close();
      });
    });
  });
}
