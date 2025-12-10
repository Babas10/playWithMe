import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/data/models/game_model.dart';
import 'package:play_with_me/core/domain/repositories/game_repository.dart';
import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_event.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_state.dart';
import 'package:play_with_me/features/games/presentation/pages/game_details_page.dart';
import 'package:play_with_me/features/games/presentation/pages/record_results_page.dart';

import '../../../../../unit/core/data/repositories/mock_game_repository.dart';

class MockAuthenticationBloc extends MockBloc<AuthenticationEvent, AuthenticationState>
    implements AuthenticationBloc {}

void main() {
  late MockGameRepository mockGameRepository;
  late MockAuthenticationBloc mockAuthBloc;
  final sl = GetIt.instance;

  const creatorId = 'user-creator';
  const participantId = 'user-participant';
  const outsiderId = 'user-outsider';
  
  final baseGame = TestGameData.testGame.copyWith(
    id: 'game-1',
    createdBy: creatorId,
    playerIds: [creatorId, participantId],
    status: GameStatus.scheduled,
    result: null,
  );

  setUp(() {
    mockGameRepository = MockGameRepository();
    mockAuthBloc = MockAuthenticationBloc();
    
    if (sl.isRegistered<GameRepository>()) {
      sl.unregister<GameRepository>();
    }
    sl.registerSingleton<GameRepository>(mockGameRepository);
  });

  tearDown(() {
    sl.reset();
  });

  Widget createWidgetUnderTest(String gameId) {
    return MaterialApp(
      home: BlocProvider<AuthenticationBloc>.value(
        value: mockAuthBloc,
        child: GameDetailsPage(gameId: gameId),
      ),
    );
  }

  testWidgets('Participant sees "Enter Results" button when game is past', (tester) async {
    final pastGame = baseGame.copyWith(
      scheduledAt: DateTime.now().subtract(const Duration(hours: 2)),
    );
    mockGameRepository.addGame(pastGame);
    
    when(() => mockAuthBloc.state).thenReturn(
      AuthenticationAuthenticated(UserEntity(uid: participantId, email: '', isEmailVerified: true, isAnonymous: false)),
    );

    await tester.pumpWidget(createWidgetUnderTest(pastGame.id));
    await tester.pumpAndSettle();

    expect(find.text('Enter Results'), findsOneWidget);
  });

  testWidgets('Participant does NOT see "Enter Results" button when game is future', (tester) async {
    final futureGame = baseGame.copyWith(
      scheduledAt: DateTime.now().add(const Duration(hours: 2)),
    );
    mockGameRepository.addGame(futureGame);
    
    when(() => mockAuthBloc.state).thenReturn(
      AuthenticationAuthenticated(UserEntity(uid: participantId, email: '', isEmailVerified: true, isAnonymous: false)),
    );

    await tester.pumpWidget(createWidgetUnderTest(futureGame.id));
    await tester.pumpAndSettle();

    expect(find.text('Enter Results'), findsNothing);
  });

  testWidgets('Creator sees "Enter Results" button even when game is future', (tester) async {
    final futureGame = baseGame.copyWith(
      scheduledAt: DateTime.now().add(const Duration(hours: 2)),
    );
    mockGameRepository.addGame(futureGame);
    
    when(() => mockAuthBloc.state).thenReturn(
      AuthenticationAuthenticated(UserEntity(uid: creatorId, email: '', isEmailVerified: true, isAnonymous: false)),
    );

    await tester.pumpWidget(createWidgetUnderTest(futureGame.id));
    await tester.pumpAndSettle();

    expect(find.text('Enter Results'), findsOneWidget);
  });

  testWidgets('Participant sees "Enter Results" button when game is in progress', (tester) async {
    final inProgressGame = baseGame.copyWith(
      status: GameStatus.inProgress,
      // Ensure scheduledAt is future to prove status overrides time check
      scheduledAt: DateTime.now().add(const Duration(hours: 1)),
    );
    mockGameRepository.addGame(inProgressGame);
    
    when(() => mockAuthBloc.state).thenReturn(
      AuthenticationAuthenticated(UserEntity(uid: participantId, email: '', isEmailVerified: true, isAnonymous: false)),
    );

    await tester.pumpWidget(createWidgetUnderTest(inProgressGame.id));
    await tester.pumpAndSettle();

    expect(find.text('Enter Results'), findsOneWidget);
  });

  testWidgets('Outsider does NOT see "Enter Results" button even when game is past', (tester) async {
    final pastGame = baseGame.copyWith(
      scheduledAt: DateTime.now().subtract(const Duration(hours: 2)),
    );
    mockGameRepository.addGame(pastGame);
    
    when(() => mockAuthBloc.state).thenReturn(
      AuthenticationAuthenticated(UserEntity(uid: outsiderId, email: '', isEmailVerified: true, isAnonymous: false)),
    );

    await tester.pumpWidget(createWidgetUnderTest(pastGame.id));
    await tester.pumpAndSettle();

    expect(find.text('Enter Results'), findsNothing);
  });

  testWidgets('"Enter Results" button navigates to RecordResultsPage', (tester) async {
    final pastGame = baseGame.copyWith(
      scheduledAt: DateTime.now().subtract(const Duration(hours: 2)),
    );
    mockGameRepository.addGame(pastGame);
    
    when(() => mockAuthBloc.state).thenReturn(
      AuthenticationAuthenticated(UserEntity(uid: participantId, email: '', isEmailVerified: true, isAnonymous: false)),
    );

    await tester.pumpWidget(createWidgetUnderTest(pastGame.id));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Enter Results'));
    await tester.pumpAndSettle();

    expect(find.byType(RecordResultsPage), findsOneWidget);
  });
}
