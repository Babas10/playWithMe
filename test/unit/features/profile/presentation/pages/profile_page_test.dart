// Verifies that ProfilePage displays user identity and account settings correctly

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_event.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_state.dart';
import 'package:play_with_me/features/profile/presentation/pages/profile_page.dart';
import 'package:play_with_me/features/profile/presentation/widgets/profile_header.dart';
import 'package:play_with_me/features/profile/presentation/widgets/profile_info_card.dart';
import 'package:play_with_me/features/profile/presentation/widgets/profile_actions.dart';
import 'package:play_with_me/features/profile/presentation/widgets/expanded_stats_section.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

import 'package:get_it/get_it.dart';
import 'package:play_with_me/core/domain/repositories/game_repository.dart';
import '../../../../core/data/repositories/mock_game_repository.dart';

// Fake AuthenticationBloc for testing
class FakeAuthenticationBloc extends Fake implements AuthenticationBloc {
  final _controller = StreamController<AuthenticationState>.broadcast();
  AuthenticationState _state;

  FakeAuthenticationBloc(this._state);

  @override
  AuthenticationState get state => _state;

  @override
  Stream<AuthenticationState> get stream => _controller.stream;

  @override
  void add(AuthenticationEvent event) {
    // Handle events if needed
  }

  @override
  Future<void> close() async {
    await _controller.close();
  }
}

void main() {
  setUp(() {
    if (GetIt.I.isRegistered<GameRepository>()) {
      GetIt.I.unregister<GameRepository>();
    }
    GetIt.I.registerSingleton<GameRepository>(MockGameRepository());
  });

  tearDown(() {
    GetIt.I.reset();
  });

  Widget createWidgetUnderTest({required AuthenticationState state}) {
    final fakeBloc = FakeAuthenticationBloc(state);

    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: BlocProvider<AuthenticationBloc>.value(
        value: fakeBloc,
        child: const Scaffold(body: ProfilePage()),
      ),
    );
  }

  group('ProfilePage', () {
    testWidgets('displays profile content when user is authenticated', (tester) async {
      final testUser = UserEntity(
        uid: 'test-uid-123',
        email: 'test@example.com',
        displayName: 'Test User',
        photoUrl: null,
        isEmailVerified: true,
        createdAt: DateTime(2024, 1, 1),
        lastSignInAt: DateTime(2024, 10, 1),
        isAnonymous: false,
      );

      await tester.pumpWidget(
        createWidgetUnderTest(state: AuthenticationAuthenticated(testUser)),
      );

      // Verify components are present (ProfilePage is now a tab, no own AppBar)
      expect(find.byType(ProfileHeader), findsOneWidget);
      expect(find.byType(ProfileInfoCard), findsOneWidget);
      expect(find.byType(ProfileActions), findsOneWidget);

      // Verify user information is displayed
      expect(find.text('Test User'), findsOneWidget);
      // Email appears twice: once in ProfileHeader and once in ProfileInfoCard
      expect(find.text('test@example.com'), findsNWidgets(2));

      // Verify stats are NOT shown on profile page (moved to Stats tab)
      expect(find.byType(ExpandedStatsSection), findsNothing);
    });

    testWidgets('displays loading indicator when authentication is unknown', (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(state: const AuthenticationUnknown()),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(ProfileHeader), findsNothing);
    });

    testWidgets('displays login message when unauthenticated', (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(state: const AuthenticationUnauthenticated()),
      );

      expect(find.text('Please log in to view your profile'), findsOneWidget);
      expect(find.byType(ProfileHeader), findsNothing);
    });

    testWidgets('profile content is scrollable', (tester) async {
      final testUser = UserEntity(
        uid: 'test-uid-123',
        email: 'test@example.com',
        displayName: 'Test User',
        photoUrl: null,
        isEmailVerified: true,
        createdAt: DateTime(2024, 1, 1),
        lastSignInAt: DateTime(2024, 10, 1),
        isAnonymous: false,
      );

      await tester.pumpWidget(
        createWidgetUnderTest(state: AuthenticationAuthenticated(testUser)),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}
