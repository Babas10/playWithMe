// Validates JoinGroupConfirmationPage renders correct UI states for validation, confirmation, joining, and error states.

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/features/invitations/presentation/bloc/invite_join/invite_join_bloc.dart';
import 'package:play_with_me/features/invitations/presentation/bloc/invite_join/invite_join_event.dart';
import 'package:play_with_me/features/invitations/presentation/bloc/invite_join/invite_join_state.dart';
import 'package:play_with_me/features/invitations/presentation/pages/join_group_confirmation_page.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

class MockInviteJoinBloc
    extends MockBloc<InviteJoinEvent, InviteJoinState>
    implements InviteJoinBloc {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late MockInviteJoinBloc mockBloc;

  setUpAll(() {
    registerFallbackValue(const ValidateInviteToken(''));
    registerFallbackValue(const InviteJoinInitial());
  });

  setUp(() {
    mockBloc = MockInviteJoinBloc();
  });

  tearDown(() {
    mockBloc.close();
  });

  Widget createTestWidget({String token = 'test-token'}) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: BlocProvider<InviteJoinBloc>.value(
        value: mockBloc,
        child: JoinGroupConfirmationPage(token: token),
      ),
    );
  }

  group('JoinGroupConfirmationPage', () {
    group('app bar', () {
      testWidgets('shows Join Group? title', (tester) async {
        when(() => mockBloc.state).thenReturn(const InviteJoinValidating());

        await tester.pumpWidget(createTestWidget());

        expect(find.text('Join Group?'), findsOneWidget);
      });
    });

    group('loading states', () {
      testWidgets('shows validating message when validating', (tester) async {
        when(() => mockBloc.state).thenReturn(const InviteJoinValidating());

        await tester.pumpWidget(createTestWidget());

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Validating invite...'), findsOneWidget);
      });

      testWidgets('shows joining message when joining', (tester) async {
        when(() => mockBloc.state).thenReturn(const InviteJoinJoining());

        await tester.pumpWidget(createTestWidget());

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Joining group...'), findsOneWidget);
      });
    });

    group('confirmation state', () {
      const validatedState = InviteJoinValidated(
        groupId: 'group-123',
        groupName: 'Beach Volleyball Crew',
        groupDescription: 'Weekend players at the beach',
        memberCount: 12,
        inviterName: 'Jane Smith',
        token: 'test-token',
      );

      testWidgets('shows group details', (tester) async {
        when(() => mockBloc.state).thenReturn(validatedState);

        await tester.pumpWidget(createTestWidget());

        expect(find.text('Beach Volleyball Crew'), findsOneWidget);
        expect(find.text('Weekend players at the beach'), findsOneWidget);
        expect(find.text('Invited by Jane Smith'), findsOneWidget);
        expect(find.text('12 members'), findsOneWidget);
      });

      testWidgets('shows group without description when null',
          (tester) async {
        const stateNoDesc = InviteJoinValidated(
          groupId: 'group-123',
          groupName: 'Volleyball Club',
          memberCount: 5,
          inviterName: 'Alice',
          token: 'test-token',
        );
        when(() => mockBloc.state).thenReturn(stateNoDesc);

        await tester.pumpWidget(createTestWidget());

        expect(find.text('Volleyball Club'), findsOneWidget);
        expect(find.text('Invited by Alice'), findsOneWidget);
        expect(find.text('5 members'), findsOneWidget);
      });

      testWidgets('shows join and cancel buttons', (tester) async {
        when(() => mockBloc.state).thenReturn(validatedState);

        await tester.pumpWidget(createTestWidget());

        expect(find.text('Join Group'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
      });

      testWidgets('join button dispatches JoinGroupViaInvite event',
          (tester) async {
        when(() => mockBloc.state).thenReturn(validatedState);

        await tester.pumpWidget(createTestWidget());
        await tester.tap(find.text('Join Group'));

        verify(
          () => mockBloc.add(const JoinGroupViaInvite('test-token')),
        ).called(1);
      });

      testWidgets('cancel button pops the page', (tester) async {
        when(() => mockBloc.state).thenReturn(validatedState);

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
                body: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider<InviteJoinBloc>.value(
                          value: mockBloc,
                          child: const JoinGroupConfirmationPage(
                            token: 'test-token',
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text('Go'),
                ),
              ),
            ),
          ),
        );

        // Navigate to the confirmation page
        await tester.tap(find.text('Go'));
        await tester.pumpAndSettle();

        // Tap cancel
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // Should have popped back
        expect(find.text('Go'), findsOneWidget);
        expect(find.text('Cancel'), findsNothing);
      });
    });

    group('error states', () {
      testWidgets('shows invalid token error', (tester) async {
        when(() => mockBloc.state).thenReturn(
          const InviteJoinInvalidToken(reason: 'This link has expired'),
        );

        await tester.pumpWidget(createTestWidget());

        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.text('This link has expired'), findsOneWidget);
        expect(find.text('Continue to app'), findsOneWidget);
      });

      testWidgets('shows generic error', (tester) async {
        when(() => mockBloc.state).thenReturn(
          const InviteJoinError(message: 'Something went wrong'),
        );

        await tester.pumpWidget(createTestWidget());

        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.text('Something went wrong'), findsOneWidget);
        expect(find.text('Continue to app'), findsOneWidget);
      });
    });

    group('joined state', () {
      testWidgets('renders initial loading state for joined', (tester) async {
        // Verify the builder shows loading for InviteJoinInitial (default state before joined)
        when(() => mockBloc.state).thenReturn(const InviteJoinInitial());

        await tester.pumpWidget(createTestWidget());

        // Initial/default state shows validating loading
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });
  });
}
