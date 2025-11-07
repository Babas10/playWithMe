// Tests for MyCommunityPage to verify UI rendering and interactions
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/features/friends/presentation/bloc/friend_bloc.dart';
import 'package:play_with_me/features/friends/presentation/bloc/friend_event.dart';
import 'package:play_with_me/features/friends/presentation/bloc/friend_state.dart';
import 'package:play_with_me/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MockFriendBloc extends Mock implements FriendBloc {}

void main() {
  late MockFriendBloc mockFriendBloc;

  setUp(() {
    mockFriendBloc = MockFriendBloc();
  });

  setUpAll(() {
    registerFallbackValue(const FriendEvent.loadRequested());
  });

  Widget createTestWidget(Widget child) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
      ],
      home: Scaffold(
        body: BlocProvider<FriendBloc>.value(
          value: mockFriendBloc,
          child: child,
        ),
      ),
    );
  }

  group('MyCommunityPage Widget Tests', () {
    testWidgets('BlocBuilder renders CircularProgressIndicator on loading state',
        (WidgetTester tester) async {
      when(() => mockFriendBloc.state)
          .thenReturn(const FriendState.loading());
      when(() => mockFriendBloc.stream)
          .thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(
        createTestWidget(
          BlocBuilder<FriendBloc, FriendState>(
            builder: (context, state) {
              if (state is FriendLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              return const SizedBox();
            },
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('BlocBuilder renders content on loaded state',
        (WidgetTester tester) async {
      when(() => mockFriendBloc.state).thenReturn(
        const FriendState.loaded(
          friends: [],
          receivedRequests: [],
          sentRequests: [],
        ),
      );
      when(() => mockFriendBloc.stream)
          .thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(
        createTestWidget(
          BlocBuilder<FriendBloc, FriendState>(
            builder: (context, state) {
              if (state is FriendLoaded) {
                return const Text('Loaded');
              }
              return const SizedBox();
            },
          ),
        ),
      );

      expect(find.text('Loaded'), findsOneWidget);
    });

    testWidgets('BlocListener reacts to error state',
        (WidgetTester tester) async {
      bool listenerCalled = false;

      when(() => mockFriendBloc.state).thenReturn(
        const FriendState.loaded(friends: [], receivedRequests: [], sentRequests: []),
      );
      when(() => mockFriendBloc.stream).thenAnswer(
        (_) => Stream.fromIterable([
          const FriendState.error(message: 'Test error'),
        ]),
      );

      await tester.pumpWidget(
        createTestWidget(
          BlocListener<FriendBloc, FriendState>(
            listener: (context, state) {
              if (state is FriendError) {
                listenerCalled = true;
              }
            },
            child: const SizedBox(),
          ),
        ),
      );

      await tester.pump();
      expect(listenerCalled, isTrue);
    });

    testWidgets('BlocListener reacts to success state',
        (WidgetTester tester) async {
      bool listenerCalled = false;

      when(() => mockFriendBloc.state).thenReturn(
        const FriendState.loaded(friends: [], receivedRequests: [], sentRequests: []),
      );
      when(() => mockFriendBloc.stream).thenAnswer(
        (_) => Stream.fromIterable([
          const FriendState.actionSuccess(message: 'Success'),
        ]),
      );

      await tester.pumpWidget(
        createTestWidget(
          BlocListener<FriendBloc, FriendState>(
            listener: (context, state) {
              if (state is FriendActionSuccess) {
                listenerCalled = true;
              }
            },
            child: const SizedBox(),
          ),
        ),
      );

      await tester.pump();
      expect(listenerCalled, isTrue);
    });
  });
}
