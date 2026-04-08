// Validates invite-from-other-groups sheet renders states correctly (Story 28.6).
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

final _carol = InvitablePlayerModel(
  uid: 'carol',
  displayName: 'Carol',
  sourceGroupId: 'group-x',
  sourceGroupName: 'Beach Crew',
);

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

  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
  late MockGameGuestInvitationRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(const LoadInvitablePlayers(gameId: 'x'));
    registerFallbackValue(const InviteGuestPlayer(gameId: 'x', inviteeId: 'y'));
    registerFallbackValue(const InviteGroupPlayers(gameId: 'x', groupId: 'g'));
  });

  setUp(() {
    mockRepo = MockGameGuestInvitationRepository();
  });

  group('InviteGuestPlayersSheet', () {
    testWidgets('shows loading indicator while fetching players', (
      tester,
    ) async {
      final completer = Completer<List<InvitablePlayerModel>>();
      when(
        () => mockRepo.getInvitablePlayers(any()),
      ).thenAnswer((_) => completer.future);
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
      await tester.pump();
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsWidgets);

      completer.complete([]);
    });

    testWidgets('shows empty state when no players available', (tester) async {
      when(
        () => mockRepo.getInvitablePlayers(any()),
      ).thenAnswer((_) async => []);
      final bloc = GameGuestInvitationBloc(repository: mockRepo);

      await pumpSheet(tester, bloc, 'game-1');
      await tester.pumpAndSettle();

      expect(find.text('No players available to invite'), findsOneWidget);
    });

    testWidgets('renders group cards with group names', (tester) async {
      when(
        () => mockRepo.getInvitablePlayers(any()),
      ).thenAnswer((_) async => [_alice, _bob, _carol]);
      final bloc = GameGuestInvitationBloc(repository: mockRepo);

      await pumpSheet(tester, bloc, 'game-1');
      await tester.pumpAndSettle();

      // One card per group (Beach Crew and Downtown Ballers)
      expect(find.text('Beach Crew'), findsOneWidget);
      expect(find.text('Downtown Ballers'), findsOneWidget);
    });

    testWidgets('shows correct member count on each group card', (
      tester,
    ) async {
      when(
        () => mockRepo.getInvitablePlayers(any()),
      ).thenAnswer((_) async => [_alice, _carol, _bob]);
      final bloc = GameGuestInvitationBloc(repository: mockRepo);

      await pumpSheet(tester, bloc, 'game-1');
      await tester.pumpAndSettle();

      expect(find.text('2 people'), findsOneWidget); // Beach Crew
      expect(find.text('1 person'), findsOneWidget); // Downtown Ballers
    });

    testWidgets('tapping a group card fires InviteGroupPlayers event', (
      tester,
    ) async {
      when(
        () => mockRepo.getInvitablePlayers(any()),
      ).thenAnswer((_) async => [_alice]);
      when(
        () => mockRepo.inviteGuestPlayer(
          gameId: any(named: 'gameId'),
          inviteeId: any(named: 'inviteeId'),
        ),
      ).thenAnswer((_) async => 'inv-1');
      final bloc = GameGuestInvitationBloc(repository: mockRepo);

      await pumpSheet(tester, bloc, 'game-1');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Beach Crew'));
      await tester.pumpAndSettle();

      verify(
        () => mockRepo.inviteGuestPlayer(gameId: 'game-1', inviteeId: 'alice'),
      ).called(1);
    });

    testWidgets('tapping a group invites all its members', (tester) async {
      when(
        () => mockRepo.getInvitablePlayers(any()),
      ).thenAnswer((_) async => [_alice, _carol]); // both in Beach Crew
      when(
        () => mockRepo.inviteGuestPlayer(
          gameId: any(named: 'gameId'),
          inviteeId: any(named: 'inviteeId'),
        ),
      ).thenAnswer((_) async => 'inv-1');
      final bloc = GameGuestInvitationBloc(repository: mockRepo);

      await pumpSheet(tester, bloc, 'game-1');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Beach Crew'));
      await tester.pumpAndSettle();

      // Both Alice and Carol should be invited
      verify(
        () => mockRepo.inviteGuestPlayer(gameId: 'game-1', inviteeId: 'alice'),
      ).called(1);
      verify(
        () => mockRepo.inviteGuestPlayer(gameId: 'game-1', inviteeId: 'carol'),
      ).called(1);
    });

    testWidgets('shows success snackbar after group invited', (tester) async {
      when(
        () => mockRepo.getInvitablePlayers(any()),
      ).thenAnswer((_) async => [_alice]);
      when(
        () => mockRepo.inviteGuestPlayer(
          gameId: any(named: 'gameId'),
          inviteeId: any(named: 'inviteeId'),
        ),
      ).thenAnswer((_) async => 'inv-1');
      final bloc = GameGuestInvitationBloc(repository: mockRepo);

      await pumpSheet(tester, bloc, 'game-1');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Beach Crew'));
      await tester.pumpAndSettle();

      expect(find.text('Group invited successfully'), findsOneWidget);
    });

    testWidgets('shows Invited badge after group is invited', (tester) async {
      when(
        () => mockRepo.getInvitablePlayers(any()),
      ).thenAnswer((_) async => [_alice]);
      when(
        () => mockRepo.inviteGuestPlayer(
          gameId: any(named: 'gameId'),
          inviteeId: any(named: 'inviteeId'),
        ),
      ).thenAnswer((_) async => 'inv-1');
      final bloc = GameGuestInvitationBloc(repository: mockRepo);

      await pumpSheet(tester, bloc, 'game-1');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Beach Crew'));
      await tester.pumpAndSettle();

      expect(find.text('Invited'), findsOneWidget);
    });

    testWidgets('shows retry button on load error', (tester) async {
      when(
        () => mockRepo.getInvitablePlayers(any()),
      ).thenThrow(Exception('network error'));
      final bloc = GameGuestInvitationBloc(repository: mockRepo);

      await pumpSheet(tester, bloc, 'game-1');
      await tester.pumpAndSettle();

      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('shows loading spinner on group card while sending', (
      tester,
    ) async {
      final inviteCompleter = Completer<String>();
      when(
        () => mockRepo.getInvitablePlayers(any()),
      ).thenAnswer((_) async => [_alice, _bob]);
      when(
        () => mockRepo.inviteGuestPlayer(
          gameId: any(named: 'gameId'),
          inviteeId: any(named: 'inviteeId'),
        ),
      ).thenAnswer((_) => inviteCompleter.future);
      final bloc = GameGuestInvitationBloc(repository: mockRepo);

      await pumpSheet(tester, bloc, 'game-1');
      await tester.pumpAndSettle();

      // Tap Beach Crew; the bloc emits InviteGroupSending which shows a spinner
      await tester.tap(find.text('Beach Crew'));
      await tester.pump(); // trigger event
      await tester.pump(); // rebuild after BLoC emits InviteGroupSending

      expect(find.byType(CircularProgressIndicator), findsWidgets);

      inviteCompleter.complete('inv-1');
    });
  });
}
