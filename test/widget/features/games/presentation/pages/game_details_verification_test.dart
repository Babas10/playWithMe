import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:play_with_me/l10n/app_localizations.dart';
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

import '../../../../../unit/core/data/repositories/mock_game_repository.dart';
import '../../../../../unit/core/data/repositories/mock_user_repository.dart';

class MockAuthenticationBloc extends MockBloc<AuthenticationEvent, AuthenticationState>
    implements AuthenticationBloc {}

void main() {
  late MockGameRepository mockGameRepository;
  late MockUserRepository mockUserRepository;
  late MockAuthenticationBloc mockAuthBloc;
  final sl = GetIt.instance;

  const submitterId = 'user-1';
  const verifierId = 'user-2';
  
  final verificationGame = TestGameData.testGame.copyWith(
    id: 'verify-game-1',
    status: GameStatus.verification,
    playerIds: [submitterId, verifierId],
    resultSubmittedBy: submitterId,
    result: const GameResult(
      games: [], // Empty for test, not validated by UI
      overallWinner: 'teamA',
    ),
  );

  setUp(() {
    mockGameRepository = MockGameRepository();
    mockUserRepository = MockUserRepository();
    mockAuthBloc = MockAuthenticationBloc();
    
    if (sl.isRegistered<GameRepository>()) {
      sl.unregister<GameRepository>();
    }
    sl.registerSingleton<GameRepository>(mockGameRepository);
  });

  tearDown(() {
    sl.reset();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],      home: BlocProvider<AuthenticationBloc>.value(
        value: mockAuthBloc,
        child: GameDetailsPage(
          gameId: verificationGame.id,
          gameRepository: mockGameRepository,
          userRepository: mockUserRepository,
        ),
      ),
    );
  }

  testWidgets('GameDetailsPage shows "Result Submitted" for submitter', (tester) async {
    mockGameRepository.addGame(verificationGame);
    when(() => mockAuthBloc.state).thenReturn(
      AuthenticationAuthenticated(UserEntity(uid: submitterId, email: '', isEmailVerified: true, isAnonymous: false)),
    );

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Result Submitted'), findsOneWidget);
    expect(find.text('Confirm'), findsNothing);
    expect(find.text('Edit / Dispute'), findsOneWidget);
  });

  testWidgets('GameDetailsPage shows "Verification Pending" and Confirm button for verifier', (tester) async {
    mockGameRepository.addGame(verificationGame);
    when(() => mockAuthBloc.state).thenReturn(
      AuthenticationAuthenticated(UserEntity(uid: verifierId, email: '', isEmailVerified: true, isAnonymous: false)),
    );

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Result Verification Pending'), findsOneWidget);
    expect(find.text('Confirm'), findsOneWidget);
    expect(find.text('Edit / Dispute'), findsOneWidget);
  });

  testWidgets('GameDetailsPage shows "Confirmed" for user who already confirmed', (tester) async {
    final confirmedGame = verificationGame.copyWith(
      confirmedBy: [verifierId],
    );
    mockGameRepository.addGame(confirmedGame);
    
    when(() => mockAuthBloc.state).thenReturn(
      AuthenticationAuthenticated(UserEntity(uid: verifierId, email: '', isEmailVerified: true, isAnonymous: false)),
    );

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Confirmed'), findsOneWidget);
    expect(find.text('Confirm'), findsNothing);
    expect(find.text('Edit / Dispute'), findsOneWidget);
  });
}
