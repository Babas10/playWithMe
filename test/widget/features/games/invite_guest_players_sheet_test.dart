// Validates invite-guest-players sheet renders states correctly (Story 28.6).
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/data/models/invitable_player_model.dart';
import 'package:play_with_me/core/domain/repositories/game_guest_invitation_repository.dart';
import 'package:play_with_me/features/games/presentation/bloc/game_guest_invitation/game_guest_invitation_bloc.dart';
import 'package:play_with_me/features/games/presentation/bloc/game_guest_invitation/game_guest_invitation_event.dart';
import 'package:play_with_me/features/games/presentation/bloc/game_guest_invitation/game_guest_invitation_state.dart';
import 'package:play_with_me/features/games/presentation/widgets/invite_guest_players_sheet.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

class MockGameGuestInvitationRepository extends Mock
    implements GameGuestInvitationRepository {}

final _alice = InvitablePlayerModel(
  uid: 'alice',
  displayName: 'Alice',
  sourceGroupId: 'group-x',
  sourceGroupName: 'Beach Crew',
);

final _bob = InvitablePlayerModel(
  uid: 'bob',
  displayName: 'Bob',
  sourceGroupId: 'group-y',
  sourceGroupName: 'Downtown Ballers',
);

/// Pumps a Material app with the sheet open via [showInviteGuestPlayersSheet].
Future<void> pumpSheet(
  WidgetTester tester,
  GameGuestInvitationBloc bloc,
  String gameId,
) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: BlocProvider.value(
        value: bloc,
        child: Builder(
          builder: (ctx) => Scaffold(
            body: ElevatedButton(
              onPressed: () => showInviteGuestPlayersSheet(ctx, gameId),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    ),
  );

  // Open the sheet
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
  late MockGameGuestInvitationRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(const LoadInvitablePlayers(gameId: 'x'));
    registerFallbackValue(const InviteGuestPlayer(gameId: 'x', inviteeId: 'y'));
  });

  setUp(() {
    mockRepo = MockGameGuestInvitationRepository();
  });

  group('InviteGuestPlayersSheet', () {
    testWidgets('shows loading indicator while fetching players',
        (tester) async {
      // Use a Completer so the future never resolves during the test.
      final completer = Completer<List<InvitablePlayerModel>>();
      when(() => mockRepo.getInvitablePlayers(any()))
          .thenAnswer((_) => completer.future);
      final bloc = GameGuestInvitationBloc(repository: mockRepo);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: BlocProvider.value(
            value: bloc,
            child: Builder(
              builder: (ctx) => Scaffold(
                body: ElevatedButton(
                  onPressed: () => showInviteGuestPlayersSheet(ctx, 'game-1'),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pump(); // sheet opens
      await tester.pump(); // bloc emits loading

      expect(find.byType(CircularProgressIndicator), findsWidgets);

      // Complete the future to avoid pending timer warning.
      completer.complete([]);
    });

    testWidgets('shows empty state when no players available', (tester) async {
      when(() => mockRepo.getInvitablePlayers(any()))
          .thenAnswer((_) async => []);
      final bloc = GameGuestInvitationBloc(repository: mockRepo);

      await pumpSheet(tester, bloc, 'game-1');
      await tester.pumpAndSettle();

      expect(find.text('No players available to invite'), findsOneWidget);
    });

    testWidgets('renders players grouped by source group name', (tester) async {
      when(() => mockRepo.getInvitablePlayers(any()))
          .thenAnswer((_) async => [_alice, _bob]);
      final bloc = GameGuestInvitationBloc(repository: mockRepo);

      await pumpSheet(tester, bloc, 'game-1');
      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('Beach Crew'), findsOneWidget);
      expect(find.text('Downtown Ballers'), findsOneWidget);
    });

    testWidgets('tapping Invite sends InviteGuestPlayer event', (tester) async {
      when(() => mockRepo.getInvitablePlayers(any()))
          .thenAnswer((_) async => [_alice]);
      when(() => mockRepo.inviteGuestPlayer(
            gameId: any(named: 'gameId'),
            inviteeId: any(named: 'inviteeId'),
          )).thenAnswer((_) async => 'inv-1');
      final bloc = GameGuestInvitationBloc(repository: mockRepo);

      await pumpSheet(tester, bloc, 'game-1');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Invite').first);
      await tester.pumpAndSettle();

      verify(() => mockRepo.inviteGuestPlayer(
            gameId: 'game-1',
            inviteeId: 'alice',
          )).called(1);
    });

    testWidgets('shows success snackbar after invitation sent', (tester) async {
      when(() => mockRepo.getInvitablePlayers(any()))
          .thenAnswer((_) async => [_alice]);
      when(() => mockRepo.inviteGuestPlayer(
            gameId: any(named: 'gameId'),
            inviteeId: any(named: 'inviteeId'),
          )).thenAnswer((_) async => 'inv-1');
      final bloc = GameGuestInvitationBloc(repository: mockRepo);

      await pumpSheet(tester, bloc, 'game-1');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Invite').first);
      await tester.pumpAndSettle();

      expect(find.text('Invitation sent successfully'), findsOneWidget);
    });

    testWidgets('shows error snackbar when invitation fails', (tester) async {
      when(() => mockRepo.getInvitablePlayers(any()))
          .thenAnswer((_) async => [_alice]);
      when(() => mockRepo.inviteGuestPlayer(
            gameId: any(named: 'gameId'),
            inviteeId: any(named: 'inviteeId'),
          )).thenThrow(Exception('network'));
      final bloc = GameGuestInvitationBloc(repository: mockRepo);

      await pumpSheet(tester, bloc, 'game-1');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Invite').first);
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (w) =>
              w is SnackBar &&
              (w.content as Text).data?.contains('Failed to send invitation') ==
                  true,
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows retry button on load error', (tester) async {
      when(() => mockRepo.getInvitablePlayers(any()))
          .thenThrow(Exception('network error'));
      final bloc = GameGuestInvitationBloc(repository: mockRepo);

      await pumpSheet(tester, bloc, 'game-1');
      await tester.pumpAndSettle();

      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('Invite buttons disabled while sending', (tester) async {
      final inviteCompleter = Completer<String>();
      when(() => mockRepo.getInvitablePlayers(any()))
          .thenAnswer((_) async => [_alice, _bob]);
      when(() => mockRepo.inviteGuestPlayer(
            gameId: any(named: 'gameId'),
            inviteeId: any(named: 'inviteeId'),
          )).thenAnswer((_) => inviteCompleter.future);
      final bloc = GameGuestInvitationBloc(repository: mockRepo);

      await pumpSheet(tester, bloc, 'game-1');
      await tester.pumpAndSettle();

      // Tap Invite for Alice; while in-flight, all Invite buttons should be disabled
      await tester.tap(find.text('Invite').first);
      await tester.pump();

      final buttons = tester.widgetList<TextButton>(find.byType(TextButton));
      final disabled = buttons.where((b) => b.onPressed == null).toList();
      expect(disabled, isNotEmpty);

      // Resolve completer to avoid pending timer warning.
      inviteCompleter.complete('inv-1');
    });
  });
}
