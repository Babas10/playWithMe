// Widget tests for InviteLinkSection covering all UI states and user interactions.

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/features/groups/presentation/bloc/group_invite_link/group_invite_link_bloc.dart';
import 'package:play_with_me/features/groups/presentation/bloc/group_invite_link/group_invite_link_event.dart';
import 'package:play_with_me/features/groups/presentation/bloc/group_invite_link/group_invite_link_state.dart';
import 'package:play_with_me/features/groups/presentation/widgets/invite_link_section.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

class MockGroupInviteLinkBloc
    extends MockBloc<GroupInviteLinkEvent, GroupInviteLinkState>
    implements GroupInviteLinkBloc {}

void main() {
  late MockGroupInviteLinkBloc mockBloc;

  setUp(() {
    mockBloc = MockGroupInviteLinkBloc();
  });

  Widget buildTestWidget({String groupId = 'group-123'}) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: Scaffold(
        body: BlocProvider<GroupInviteLinkBloc>.value(
          value: mockBloc,
          child: InviteLinkSection(groupId: groupId),
        ),
      ),
    );
  }

  group('InviteLinkSection', () {
    testWidgets('shows section title and description', (tester) async {
      when(() => mockBloc.state).thenReturn(const GroupInviteLinkInitial());

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Invite Members'), findsOneWidget);
      expect(
        find.text(
            'Share this link to invite people to join the group.'),
        findsOneWidget,
      );
    });

    testWidgets('shows generate button in initial state', (tester) async {
      when(() => mockBloc.state).thenReturn(const GroupInviteLinkInitial());

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Generate Invite Link'), findsOneWidget);
      expect(find.byIcon(Icons.link), findsOneWidget);
    });

    testWidgets('tapping generate button dispatches GenerateInvite event',
        (tester) async {
      when(() => mockBloc.state).thenReturn(const GroupInviteLinkInitial());

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Generate Invite Link'));

      verify(
        () => mockBloc.add(const GenerateInvite(groupId: 'group-123')),
      ).called(1);
    });

    testWidgets('shows loading indicator in loading state', (tester) async {
      when(() => mockBloc.state).thenReturn(const GroupInviteLinkLoading());

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Generate Invite Link'), findsNothing);
    });

    testWidgets('shows generated link with copy and share buttons',
        (tester) async {
      when(() => mockBloc.state).thenReturn(const GroupInviteLinkGenerated(
        deepLinkUrl: 'https://playwithme.app/invite/abc123',
        inviteId: 'invite-456',
      ));

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(
        find.text('https://playwithme.app/invite/abc123'),
        findsOneWidget,
      );
      expect(find.text('Copy Link'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
      expect(find.text('Revoke Invite'), findsOneWidget);
    });

    testWidgets('copy button copies link to clipboard', (tester) async {
      when(() => mockBloc.state).thenReturn(const GroupInviteLinkGenerated(
        deepLinkUrl: 'https://playwithme.app/invite/abc123',
        inviteId: 'invite-456',
      ));

      // Set up clipboard mock
      final List<MethodCall> clipboardCalls = [];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall methodCall) async {
          clipboardCalls.add(methodCall);
          return null;
        },
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Copy Link'));
      await tester.pump();

      // Verify clipboard was called with the right data
      expect(
        clipboardCalls.any((call) => call.method == 'Clipboard.setData'),
        isTrue,
      );

      // Verify snackbar appears
      expect(find.text('Link copied to clipboard'), findsOneWidget);

      // Clean up
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      );
    });

    testWidgets('revoke button dispatches RevokeInvite event',
        (tester) async {
      when(() => mockBloc.state).thenReturn(const GroupInviteLinkGenerated(
        deepLinkUrl: 'https://playwithme.app/invite/abc123',
        inviteId: 'invite-456',
      ));

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Revoke Invite'));

      verify(
        () => mockBloc.add(const RevokeInvite(
          groupId: 'group-123',
          inviteId: 'invite-456',
        )),
      ).called(1);
    });

    testWidgets('shows generate button after revocation', (tester) async {
      when(() => mockBloc.state).thenReturn(const GroupInviteLinkRevoked());

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Generate Invite Link'), findsOneWidget);
    });

    testWidgets('shows generate button after error', (tester) async {
      when(() => mockBloc.state).thenReturn(const GroupInviteLinkError(
        message: 'Some error',
      ));

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Generate Invite Link'), findsOneWidget);
    });

    testWidgets('shows error snackbar when error state emitted',
        (tester) async {
      when(() => mockBloc.state).thenReturn(const GroupInviteLinkInitial());
      whenListen(
        mockBloc,
        Stream<GroupInviteLinkState>.fromIterable([
          const GroupInviteLinkError(
              message: 'Failed to generate invite link'),
        ]),
        initialState: const GroupInviteLinkInitial(),
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(
        find.text('Failed to generate invite link'),
        findsOneWidget,
      );
    });

    testWidgets('shows revoked snackbar when revoked state emitted',
        (tester) async {
      when(() => mockBloc.state).thenReturn(const GroupInviteLinkInitial());
      whenListen(
        mockBloc,
        Stream<GroupInviteLinkState>.fromIterable([
          const GroupInviteLinkRevoked(),
        ]),
        initialState: const GroupInviteLinkInitial(),
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Invite link revoked'), findsOneWidget);
    });

    testWidgets('shows copy and share icons', (tester) async {
      when(() => mockBloc.state).thenReturn(const GroupInviteLinkGenerated(
        deepLinkUrl: 'https://playwithme.app/invite/test',
        inviteId: 'inv-1',
      ));

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.copy), findsOneWidget);
      expect(find.byIcon(Icons.share), findsOneWidget);
      expect(find.byIcon(Icons.link_off), findsOneWidget);
    });
  });
}
