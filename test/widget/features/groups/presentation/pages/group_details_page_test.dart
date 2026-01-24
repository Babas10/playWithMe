// Widget tests for GroupDetailsPage verifying UI rendering and user interactions.
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:play_with_me/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/data/models/group_model.dart';
import 'package:play_with_me/core/data/models/user_model.dart';
import 'package:play_with_me/core/domain/repositories/group_repository.dart';
import 'package:play_with_me/core/domain/repositories/user_repository.dart';
import 'package:play_with_me/core/domain/repositories/game_repository.dart';
import 'package:play_with_me/core/domain/repositories/friend_repository.dart';
import 'package:play_with_me/core/presentation/bloc/group_member/group_member_bloc.dart';
import 'package:play_with_me/core/presentation/bloc/group_member/group_member_event.dart';
import 'package:play_with_me/core/presentation/bloc/group_member/group_member_state.dart';
import 'package:play_with_me/core/services/service_locator.dart';
import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_event.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_state.dart';
import 'package:play_with_me/features/groups/presentation/pages/group_details_page.dart';

class MockGroupMemberBloc
    extends MockBloc<GroupMemberEvent, GroupMemberState>
    implements GroupMemberBloc {}

class MockAuthenticationBloc
    extends MockBloc<AuthenticationEvent, AuthenticationState>
    implements AuthenticationBloc {}

class MockGroupRepository extends Mock implements GroupRepository {}

class MockUserRepository extends Mock implements UserRepository {}

class MockGameRepository extends Mock implements GameRepository {}

class MockFriendRepository extends Mock implements FriendRepository {}

class FakeGroupMemberEvent extends Fake implements GroupMemberEvent {}

class FakeGroupMemberState extends Fake implements GroupMemberState {}

void main() {
  late MockGroupMemberBloc mockGroupMemberBloc;
  late MockAuthenticationBloc mockAuthBloc;
  late MockGroupRepository mockGroupRepository;
  late MockUserRepository mockUserRepository;
  late MockGameRepository mockGameRepository;
  late MockFriendRepository mockFriendRepository;

  const testUserId = 'test-user-123';
  const testGroupId = 'test-group-123';

  final testGroup = GroupModel(
    id: testGroupId,
    name: 'Beach Volleyball Crew',
    description: 'Weekly games at the beach',
    createdBy: testUserId,
    createdAt: DateTime(2024, 1, 1),
    memberIds: [testUserId, 'member-2', 'member-3'],
    adminIds: [testUserId],
    lastActivity: DateTime(2024, 1, 1),
  );

  final List<UserModel> testMembers = [
    UserModel(
      uid: testUserId,
      email: 'owner@example.com',
      displayName: 'Group Owner',
      createdAt: DateTime(2024, 1, 1),
      isEmailVerified: true,
      isAnonymous: false,
    ),
    UserModel(
      uid: 'member-2',
      email: 'member2@example.com',
      displayName: 'Member Two',
      createdAt: DateTime(2024, 1, 1),
      isEmailVerified: true,
      isAnonymous: false,
    ),
    UserModel(
      uid: 'member-3',
      email: 'member3@example.com',
      displayName: 'Member Three',
      createdAt: DateTime(2024, 1, 1),
      isEmailVerified: true,
      isAnonymous: false,
    ),
  ];

  setUpAll(() {
    registerFallbackValue(FakeGroupMemberEvent());
    registerFallbackValue(FakeGroupMemberState());
  });

  setUp(() {
    mockGroupMemberBloc = MockGroupMemberBloc();
    mockAuthBloc = MockAuthenticationBloc();
    mockGroupRepository = MockGroupRepository();
    mockUserRepository = MockUserRepository();
    mockGameRepository = MockGameRepository();
    mockFriendRepository = MockFriendRepository();

    when(() => mockGroupMemberBloc.state)
        .thenReturn(const GroupMemberInitial());

    when(() => mockAuthBloc.state).thenReturn(
      AuthenticationAuthenticated(
        UserEntity(
          uid: testUserId,
          email: 'test@example.com',
          isEmailVerified: true,
          createdAt: DateTime(2024, 1, 1),
          lastSignInAt: DateTime(2024, 1, 1),
          isAnonymous: false,
        ),
      ),
    );

    // Setup default repository responses
    when(() => mockGroupRepository.getGroupById(testGroupId))
        .thenAnswer((_) async => testGroup);
    when(() => mockUserRepository.getUsersByIds(any()))
        .thenAnswer((_) async => testMembers);
    when(() => mockGameRepository.getUpcomingGamesCount(testGroupId))
        .thenAnswer((_) => Stream.value(2));
    when(() => mockFriendRepository.batchCheckFriendship(any()))
        .thenAnswer((_) async => {'member-2': true, 'member-3': false});
    when(() => mockFriendRepository.batchCheckFriendRequestStatus(any()))
        .thenAnswer((_) async => {'member-3': FriendRequestStatus.none});

    // Register service locator mocks
    if (sl.isRegistered<GroupMemberBloc>()) {
      sl.unregister<GroupMemberBloc>();
    }
    sl.registerFactory<GroupMemberBloc>(() => mockGroupMemberBloc);

    if (sl.isRegistered<FriendRepository>()) {
      sl.unregister<FriendRepository>();
    }
    sl.registerSingleton<FriendRepository>(mockFriendRepository);
  });

  tearDown(() {
    mockGroupMemberBloc.close();
    mockAuthBloc.close();

    if (sl.isRegistered<GroupMemberBloc>()) {
      sl.unregister<GroupMemberBloc>();
    }
    if (sl.isRegistered<FriendRepository>()) {
      sl.unregister<FriendRepository>();
    }
  });

  Widget createTestWidget() {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],      home: MultiBlocProvider(
        providers: [
          BlocProvider<AuthenticationBloc>.value(value: mockAuthBloc),
        ],
        child: GroupDetailsPage(
          groupId: testGroupId,
          groupRepositoryOverride: mockGroupRepository,
          userRepositoryOverride: mockUserRepository,
          gameRepositoryOverride: mockGameRepository,
        ),
      ),
    );
  }

  group('GroupDetailsPage Widget Tests', () {
    group('Initial UI Rendering', () {
      testWidgets('renders app bar with Group Details title', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.byType(AppBar), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.text('Group Details'),
          ),
          findsOneWidget,
        );
      });

      testWidgets('shows loading indicator initially', (tester) async {
        // Delay the group loading - use a completer so we can control when it completes
        when(() => mockGroupRepository.getGroupById(testGroupId))
            .thenAnswer((_) async {
          await Future.delayed(const Duration(seconds: 1));
          return testGroup;
        });

        await tester.pumpWidget(createTestWidget());
        // Pump frames but don't settle (async still running)
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Now complete the future to avoid pending timer warnings
        await tester.pumpAndSettle(const Duration(seconds: 2));
      });

      testWidgets('shows group name after loading', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Beach Volleyball Crew'), findsOneWidget);
      });

      testWidgets('shows group description after loading', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Weekly games at the beach'), findsOneWidget);
      });

      testWidgets('shows member count after loading', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('3 members'), findsOneWidget);
      });

      testWidgets('shows members section header', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Members (3)'), findsOneWidget);
      });
    });

    group('Members List', () {
      testWidgets('shows all member names', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Group Owner'), findsOneWidget);
        expect(find.text('Member Two'), findsOneWidget);
        expect(find.text('Member Three'), findsOneWidget);
      });
    });

    group('Error State', () {
      testWidgets('shows error message when group not found', (tester) async {
        when(() => mockGroupRepository.getGroupById(testGroupId))
            .thenAnswer((_) async => null);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Group not found'), findsOneWidget);
      });

      testWidgets('shows error state with retry button on load failure',
          (tester) async {
        when(() => mockGroupRepository.getGroupById(testGroupId))
            .thenThrow(Exception('Network error'));

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.text('Error'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
      });

      testWidgets('retry button reloads group details', (tester) async {
        // First call throws error, second call returns data
        var callCount = 0;
        when(() => mockGroupRepository.getGroupById(testGroupId)).thenAnswer(
          (_) async {
            callCount++;
            if (callCount == 1) {
              throw Exception('Network error');
            }
            return testGroup;
          },
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Should show error state
        expect(find.text('Retry'), findsOneWidget);

        // Tap retry
        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();

        // Should now show group name
        expect(find.text('Beach Volleyball Crew'), findsOneWidget);
      });
    });

    group('Unauthenticated State', () {
      testWidgets('shows login message when not authenticated', (tester) async {
        when(() => mockAuthBloc.state)
            .thenReturn(const AuthenticationUnauthenticated());

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(
            find.text('Please log in to view group details'), findsOneWidget);
      });
    });

    group('Leave Group Menu', () {
      testWidgets('shows more menu button', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.more_vert), findsOneWidget);
      });

      testWidgets('shows Leave Group option in menu', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Tap the more menu
        await tester.tap(find.byIcon(Icons.more_vert));
        await tester.pumpAndSettle();

        expect(find.text('Leave Group'), findsOneWidget);
        expect(find.byIcon(Icons.exit_to_app), findsOneWidget);
      });
    });

    group('Bottom Navigation Bar', () {
      testWidgets('shows bottom navigation bar after loading', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // GroupBottomNavBar uses BottomNavigationBar internally
        expect(find.byType(BottomNavigationBar), findsOneWidget);
      });
    });

    group('Pull to Refresh', () {
      testWidgets('has RefreshIndicator', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(RefreshIndicator), findsOneWidget);
      });
    });

    group('BlocListener State Changes', () {
      testWidgets('shows success message when member is promoted',
          (tester) async {
        whenListen(
          mockGroupMemberBloc,
          Stream.fromIterable([
            const GroupMemberInitial(),
            const MemberPromotedSuccess(groupId: testGroupId, userId: 'member-2'),
          ]),
          initialState: const GroupMemberInitial(),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Member promoted to admin'), findsOneWidget);
      });

      testWidgets('shows success message when member is demoted',
          (tester) async {
        whenListen(
          mockGroupMemberBloc,
          Stream.fromIterable([
            const GroupMemberInitial(),
            const MemberDemotedSuccess(groupId: testGroupId, userId: 'member-2'),
          ]),
          initialState: const GroupMemberInitial(),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Member demoted to regular member'), findsOneWidget);
      });

      testWidgets('shows success message when member is removed',
          (tester) async {
        whenListen(
          mockGroupMemberBloc,
          Stream.fromIterable([
            const GroupMemberInitial(),
            const MemberRemovedSuccess(groupId: testGroupId, userId: 'member-2'),
          ]),
          initialState: const GroupMemberInitial(),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Member removed from group'), findsOneWidget);
      });

      testWidgets('shows error message on GroupMemberError', (tester) async {
        whenListen(
          mockGroupMemberBloc,
          Stream.fromIterable([
            const GroupMemberInitial(),
            const GroupMemberError('Failed to update member'),
          ]),
          initialState: const GroupMemberInitial(),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Failed to update member'), findsOneWidget);
      });
    });

    group('People Icon', () {
      testWidgets('shows people icon next to member count', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.people), findsOneWidget);
      });
    });
  });
}
