// Tests GameResultViewPage: ELO card with win/loss counts + per-game team display (Story 14.13).
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/data/models/game_model.dart';
import 'package:play_with_me/core/data/models/rating_history_entry.dart';
import 'package:play_with_me/core/data/models/user_model.dart';
import 'package:play_with_me/core/presentation/bloc/invitation/invitation_bloc.dart';
import 'package:play_with_me/core/presentation/bloc/invitation/invitation_state.dart';
import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_state.dart';
import 'package:play_with_me/features/games/presentation/pages/game_result_view_page.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

class MockInvitationBloc extends Mock implements InvitationBloc {}

class MockAuthenticationBloc extends Mock implements AuthenticationBloc {}

RatingHistoryEntry _elo({
  required double oldRating,
  required double newRating,
}) => RatingHistoryEntry(
  entryId: 'entry-test',
  gameId: 'game1',
  oldRating: oldRating,
  newRating: newRating,
  ratingChange: newRating - oldRating,
  opponentTeam: '',
  won: newRating >= oldRating,
  timestamp: DateTime(2024),
);

Widget _buildApp({
  required GameModel game,
  Map<String, UserModel>? players,
  Map<String, RatingHistoryEntry?> playerEloUpdates = const {},
  required MockInvitationBloc invitationBloc,
  required MockAuthenticationBloc authBloc,
}) {
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
        BlocProvider<InvitationBloc>.value(value: invitationBloc),
        BlocProvider<AuthenticationBloc>.value(value: authBloc),
      ],
      child: GameResultViewPage(
        game: game,
        players: players,
        playerEloUpdates: playerEloUpdates,
      ),
    ),
  );
}

void main() {
  late MockInvitationBloc mockInvitationBloc;
  late MockAuthenticationBloc mockAuthBloc;
  late Map<String, UserModel> players;
  late GameModel gameWithResult;

  setUp(() {
    mockInvitationBloc = MockInvitationBloc();
    mockAuthBloc = MockAuthenticationBloc();
    when(() => mockInvitationBloc.state).thenReturn(const InvitationInitial());
    when(
      () => mockInvitationBloc.stream,
    ).thenAnswer((_) => const Stream.empty());
    when(() => mockAuthBloc.state).thenReturn(
      const AuthenticationAuthenticated(
        UserEntity(
          uid: 'test-user',
          email: 'test@example.com',
          isEmailVerified: true,
        ),
      ),
    );
    when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());

    players = {
      'user1': const UserModel(
        uid: 'user1',
        email: 'alice@example.com',
        displayName: 'Alice',
        isEmailVerified: true,
      ),
      'user2': const UserModel(
        uid: 'user2',
        email: 'bob@example.com',
        displayName: 'Bob',
        isEmailVerified: true,
      ),
      'user3': const UserModel(
        uid: 'user3',
        email: 'charlie@example.com',
        displayName: null,
        isEmailVerified: true,
      ),
      'user4': const UserModel(
        uid: 'user4',
        email: 'diana@example.com',
        displayName: 'Diana',
        isEmailVerified: true,
      ),
    };

    gameWithResult = GameModel(
      id: 'game1',
      title: 'Beach Volleyball Match',
      groupId: 'group1',
      scheduledAt: DateTime(2024, 1, 15, 10, 0),
      status: GameStatus.completed,
      location: const GameLocation(
        name: 'Test Court',
        latitude: 40.7128,
        longitude: -74.0060,
      ),
      createdBy: 'user1',
      createdAt: DateTime(2024, 1, 1),
      playerIds: const ['user1', 'user2', 'user3', 'user4'],
      waitlistIds: const [],
      teams: const GameTeams(
        teamAPlayerIds: ['user1', 'user2'],
        teamBPlayerIds: ['user3', 'user4'],
      ),
      result: const GameResult(
        overallWinner: 'teamA',
        games: [
          IndividualGame(
            gameNumber: 1,
            winner: 'teamA',
            sets: [SetScore(setNumber: 1, teamAPoints: 21, teamBPoints: 19)],
          ),
        ],
      ),
    );
  });

  group('GameResultViewPage', () {
    testWidgets('shows empty state when no results', (tester) async {
      final gameWithoutResult = gameWithResult.copyWith(result: null);
      await tester.pumpWidget(
        _buildApp(
          game: gameWithoutResult,
          players: players,
          invitationBloc: mockInvitationBloc,
          authBloc: mockAuthBloc,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No results available yet'), findsOneWidget);
      expect(
        find.text('Scores will appear here once they are entered'),
        findsOneWidget,
      );
    });

    testWidgets('Final Score card is removed (Story 14.13)', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          game: gameWithResult,
          players: players,
          invitationBloc: mockInvitationBloc,
          authBloc: mockAuthBloc,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Final Score'), findsNothing);
    });

    testWidgets('shows Individual Games section', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          game: gameWithResult,
          players: players,
          invitationBloc: mockInvitationBloc,
          authBloc: mockAuthBloc,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Individual Games'), findsOneWidget);
      expect(find.text('Game 1'), findsOneWidget);
    });

    testWidgets(
      'shows per-game team names using session-level fallback (backward compat)',
      (tester) async {
        // Game has no per-game teams → must fall back to session-level teams
        await tester.pumpWidget(
          _buildApp(
            game: gameWithResult,
            players: players,
            invitationBloc: mockInvitationBloc,
            authBloc: mockAuthBloc,
          ),
        );
        await tester.pumpAndSettle();

        // Session teams: user1+user2 = "Alice & Bob", user3+user4 = "charlie & Diana"
        expect(find.text('Alice & Bob'), findsAtLeastNWidgets(1));
        expect(find.text('charlie & Diana'), findsAtLeastNWidgets(1));
      },
    );

    testWidgets('shows per-game team names from IndividualGame.teams override', (
      tester,
    ) async {
      // Game 1 uses a different split from session-level
      final gameWithPerGameTeams = gameWithResult.copyWith(
        result: const GameResult(
          overallWinner: 'teamA',
          games: [
            IndividualGame(
              gameNumber: 1,
              winner: 'teamA',
              sets: [SetScore(setNumber: 1, teamAPoints: 21, teamBPoints: 15)],
              teams: GameTeams(
                teamAPlayerIds: ['user1', 'user3'], // different split
                teamBPlayerIds: ['user2', 'user4'],
              ),
            ),
          ],
        ),
      );

      await tester.pumpWidget(
        _buildApp(
          game: gameWithPerGameTeams,
          players: players,
          invitationBloc: mockInvitationBloc,
          authBloc: mockAuthBloc,
        ),
      );
      await tester.pumpAndSettle();

      // Per-game teams: user1+user3 = "Alice & charlie", user2+user4 = "Bob & Diana"
      expect(find.text('Alice & charlie'), findsAtLeastNWidgets(1));
      expect(find.text('Bob & Diana'), findsAtLeastNWidgets(1));
    });

    testWidgets('ELO card shows win/loss record per player', (tester) async {
      // 2 games: game1 user1+user2 win, game2 user1+user3 win → user1: 2W 0L
      final gameWith2Games = gameWithResult.copyWith(
        result: const GameResult(
          overallWinner: 'teamA',
          games: [
            IndividualGame(
              gameNumber: 1,
              winner: 'teamA',
              sets: [SetScore(setNumber: 1, teamAPoints: 21, teamBPoints: 15)],
              // no per-game teams → uses session teams (user1+user2 vs user3+user4)
            ),
            IndividualGame(
              gameNumber: 2,
              winner: 'teamB',
              sets: [SetScore(setNumber: 1, teamAPoints: 15, teamBPoints: 21)],
              // no per-game teams → uses session teams (user1+user2 vs user3+user4)
            ),
          ],
        ),
      );

      final eloUpdates = <String, RatingHistoryEntry?>{
        'user1': _elo(oldRating: 1200, newRating: 1216),
        'user2': _elo(oldRating: 1200, newRating: 1208),
        'user3': _elo(oldRating: 1200, newRating: 1192),
        'user4': _elo(oldRating: 1200, newRating: 1184),
      };

      await tester.pumpWidget(
        _buildApp(
          game: gameWith2Games,
          players: players,
          playerEloUpdates: eloUpdates,
          invitationBloc: mockInvitationBloc,
          authBloc: mockAuthBloc,
        ),
      );
      await tester.pumpAndSettle();

      // user1+user2: 1 win (game 1 teamA won), 1 loss (game 2 teamB won)
      // user3+user4: 1 loss (game 1), 1 win (game 2)
      expect(find.text('1W - 1L'), findsNWidgets(4)); // all 4 players are 1W-1L
    });

    testWidgets('ELO card shows correct win/loss for rotating per-game teams', (
      tester,
    ) async {
      // Game 1: user1+user2 vs user3+user4, teamA (user1+user2) wins
      // Game 2: user1+user3 vs user2+user4, teamA (user1+user3) wins
      // user1: 2W 0L, user2: 1W 1L, user3: 1W 1L, user4: 0W 2L
      final gameWithRotating = gameWithResult.copyWith(
        result: const GameResult(
          overallWinner: 'teamA',
          games: [
            IndividualGame(
              gameNumber: 1,
              winner: 'teamA',
              sets: [SetScore(setNumber: 1, teamAPoints: 21, teamBPoints: 15)],
              // no per-game teams → session fallback: user1+user2 vs user3+user4
            ),
            IndividualGame(
              gameNumber: 2,
              winner: 'teamA',
              sets: [SetScore(setNumber: 1, teamAPoints: 21, teamBPoints: 15)],
              teams: GameTeams(
                teamAPlayerIds: ['user1', 'user3'],
                teamBPlayerIds: ['user2', 'user4'],
              ),
            ),
          ],
        ),
      );

      final eloUpdates = <String, RatingHistoryEntry?>{
        'user1': _elo(oldRating: 1200, newRating: 1232),
        'user2': _elo(oldRating: 1200, newRating: 1200),
        'user3': _elo(oldRating: 1200, newRating: 1200),
        'user4': _elo(oldRating: 1200, newRating: 1168),
      };

      await tester.pumpWidget(
        _buildApp(
          game: gameWithRotating,
          players: players,
          playerEloUpdates: eloUpdates,
          invitationBloc: mockInvitationBloc,
          authBloc: mockAuthBloc,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('2W - 0L'), findsOneWidget); // user1
      expect(find.text('1W - 1L'), findsNWidgets(2)); // user2 and user3
      expect(find.text('0W - 2L'), findsOneWidget); // user4
    });

    testWidgets('renders without crash when players map is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildApp(
          game: gameWithResult,
          players: null,
          invitationBloc: mockInvitationBloc,
          authBloc: mockAuthBloc,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(GameResultViewPage), findsOneWidget);
    });

    testWidgets('ELO card hidden when playerEloUpdates is empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildApp(
          game: gameWithResult,
          players: players,
          playerEloUpdates: const {},
          invitationBloc: mockInvitationBloc,
          authBloc: mockAuthBloc,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ELO Rating Changes'), findsNothing);
    });
  });
}
