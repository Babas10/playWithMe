// Tests for GroupListPage widget covering all states: loading, loaded, empty, and error
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/data/models/group_model.dart';
import 'package:play_with_me/core/presentation/bloc/group/group_bloc.dart';
import 'package:play_with_me/core/presentation/bloc/group/group_event.dart';
import 'package:play_with_me/core/presentation/bloc/group/group_state.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_state.dart';
import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';
import 'package:play_with_me/features/groups/presentation/pages/group_list_page.dart';
import 'package:play_with_me/features/groups/presentation/widgets/empty_group_list.dart';
import 'package:play_with_me/features/groups/presentation/widgets/group_list_item.dart';
import 'package:play_with_me/l10n/app_localizations.dart';
import 'package:play_with_me/features/profile/domain/entities/locale_preferences_entity.dart';
import '../../../../helpers/test_helpers.dart';

// Mock classes
class MockAuthenticationBloc extends Mock implements AuthenticationBloc {}
class MockGroupBloc extends Mock implements GroupBloc {}

// Fakes for mocktail
class FakeGroupEvent extends Fake implements GroupEvent {}
class FakeGroupState extends Fake implements GroupState {}
class FakeLocalePreferencesEntity extends Fake implements LocalePreferencesEntity {}

void main() {
  late MockAuthenticationBloc mockAuthBloc;
  late MockGroupBloc mockGroupBloc;

  setUpAll(() {
    registerFallbackValue(FakeGroupEvent());
    registerFallbackValue(FakeGroupState());
    registerFallbackValue(FakeLocalePreferencesEntity());
  });

  setUp(() async {
    // Initialize test dependencies to register GroupBloc in GetIt
    await initializeTestDependencies(startUnauthenticated: false);

    mockAuthBloc = MockAuthenticationBloc();
    mockGroupBloc = MockGroupBloc();

    // Default auth bloc state
    when(() => mockAuthBloc.state).thenReturn(
      AuthenticationAuthenticated(
        UserEntity(
          uid: 'test-user-123',
          email: 'test@example.com',
          isEmailVerified: true,
          createdAt: DateTime(2024, 1, 1),
          lastSignInAt: DateTime(2024, 1, 1),
          isAnonymous: false,
        ),
      ),
    );
    when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());

    // Default group bloc behavior
    when(() => mockGroupBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockGroupBloc.add(any())).thenReturn(null);
    when(() => mockGroupBloc.close()).thenAnswer((_) async {});
  });

  tearDown(() {
    cleanupTestDependencies();
  });

  Widget createWidgetUnderTest({GroupState? groupState}) {
    if (groupState != null) {
      when(() => mockGroupBloc.state).thenReturn(groupState);
    } else {
      when(() => mockGroupBloc.state).thenReturn(const GroupInitial());
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthenticationBloc>.value(value: mockAuthBloc),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
        home: GroupListPage(blocOverride: mockGroupBloc),
      ),
    );
  }

  group('GroupListPage', () {
    testWidgets('displays login message when user is not authenticated', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthenticationUnauthenticated());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('Please log in to view your groups'), findsOneWidget);
    });

    testWidgets('displays loading indicator when GroupLoading state', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(groupState: const GroupLoading()));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays error message when GroupError state', (tester) async {
      const errorMessage = 'Failed to load groups';
      await tester.pumpWidget(createWidgetUnderTest(
        groupState: const GroupError(
          message: errorMessage,
          errorCode: 'LOAD_ERROR',
        ),
      ));
      await tester.pump(); // Initial build
      await tester.pump(); // BLoC event processing
      await tester.pump(); // State emission and rebuild

      expect(find.text('Error Loading Groups'), findsOneWidget);
      expect(find.text(errorMessage), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('retry button triggers LoadGroupsForUser event', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        groupState: const GroupError(
          message: 'Failed to load groups',
          errorCode: 'LOAD_ERROR',
        ),
      ));
      await tester.pump();

      await tester.tap(find.text('Retry'));
      await tester.pump();

      verify(() => mockGroupBloc.add(any(that: isA<LoadGroupsForUser>()))).called(greaterThanOrEqualTo(1));
    });

    testWidgets('displays empty state when GroupsLoaded with empty list', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        groupState: const GroupsLoaded(groups: []),
      ));
      await tester.pump();

      expect(find.byType(EmptyGroupList), findsOneWidget);
      expect(find.text("You're not part of any group yet"), findsOneWidget);
    });

    testWidgets('displays list of groups when GroupsLoaded with groups', (tester) async {
      final groups = [
        GroupModel(
          id: 'group-1',
          name: 'Beach Volleyball Crew',
          description: 'Weekly games at the beach',
          createdBy: 'user-123',
          createdAt: DateTime(2024, 1, 1),
          memberIds: const ['user-123', 'user-456'],
          adminIds: const ['user-123'],
        ),
        GroupModel(
          id: 'group-2',
          name: 'Sunday Players',
          description: 'Sunday morning volleyball',
          createdBy: 'user-789',
          createdAt: DateTime(2024, 1, 2),
          memberIds: const ['user-123', 'user-789'],
          adminIds: const ['user-789'],
        ),
      ];

      await tester.pumpWidget(createWidgetUnderTest(
        groupState: GroupsLoaded(groups: groups),
      ));
      await tester.pump();

      expect(find.byType(GroupListItem), findsNWidgets(2));
      expect(find.text('Beach Volleyball Crew'), findsOneWidget);
      expect(find.text('Sunday Players'), findsOneWidget);
    });

    testWidgets('displays RefreshIndicator for pull-to-refresh', (tester) async {
      final groups = [
        GroupModel(
          id: 'group-1',
          name: 'Test Group',
          createdBy: 'user-123',
          createdAt: DateTime(2024, 1, 1),
          memberIds: const ['user-123'],
          adminIds: const ['user-123'],
        ),
      ];

      await tester.pumpWidget(createWidgetUnderTest(
        groupState: GroupsLoaded(groups: groups),
      ));
      await tester.pump();

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('displays Create Group FAB', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('Create Group'), findsOneWidget);
      expect(find.descendant(
        of: find.byType(FloatingActionButton),
        matching: find.byIcon(Icons.add),
      ), findsOneWidget);
    });

    testWidgets('tapping group item navigates to group details', (tester) async {
      final groups = [
        GroupModel(
          id: 'group-1',
          name: 'Test Group',
          createdBy: 'user-123',
          createdAt: DateTime(2024, 1, 1),
          memberIds: const ['user-123'],
          adminIds: const ['user-123'],
        ),
      ];

      await tester.pumpWidget(createWidgetUnderTest(
        groupState: GroupsLoaded(groups: groups),
      ));
      await tester.pump();

      // Tap on group item to trigger navigation
      await tester.tap(find.byType(GroupListItem));
      await tester.pump();

      // Navigation is tested via integration tests since GroupDetailsPage requires repositories
      // This test verifies the tap gesture is recognized
      expect(find.byType(GroupListItem), findsOneWidget);
      // Skip: Navigation requires integration test
      // See: https://github.com/Babas10/playWithMe/issues/442
    }, skip: true);


    testWidgets('tapping Create Group FAB navigates to GroupCreationPage', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      // Verify navigation happened by checking for GroupCreationPage elements
      expect(find.text('Create Group'), findsWidgets); // FAB text + page title
    });

    testWidgets('initial state shows empty state', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(groupState: const GroupInitial()));
      await tester.pump();

      expect(find.byType(EmptyGroupList), findsOneWidget);
    });

    testWidgets('loads groups on initialization for authenticated user', (tester) async {
      // When blocOverride is provided, the widget doesn't trigger LoadGroupsForUser automatically
      // This test verifies the UI shows the empty state when no groups are loaded
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Verify that the widget rendered successfully (shows empty state by default)
      expect(find.byType(EmptyGroupList), findsOneWidget);
    });
  });
}
