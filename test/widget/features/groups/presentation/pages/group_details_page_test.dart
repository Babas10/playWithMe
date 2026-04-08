// Widget tests for GroupDetailsPage verifying UI rendering and user interactions.
import 'dart:async';

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
import 'package:play_with_me/core/domain/repositories/friend_repository.dart';
import 'package:play_with_me/core/presentation/bloc/group_member/group_member_bloc.dart';
import 'package:play_with_me/core/presentation/bloc/group_member/group_member_event.dart';
import 'package:play_with_me/core/presentation/bloc/group_member/group_member_state.dart';
import 'package:play_with_me/core/services/service_locator.dart';
import 'package:play_with_me/core/presentation/bloc/invitation/invitation_bloc.dart';
import 'package:play_with_me/core/presentation/bloc/invitation/invitation_event.dart';
import 'package:play_with_me/core/presentation/bloc/invitation/invitation_state.dart';
import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_event.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_state.dart';
import 'package:play_with_me/features/groups/presentation/pages/group_details_page.dart';
import 'package:play_with_me/features/groups/presentation/bloc/group_invite_link/group_invite_link_bloc.dart';
import 'package:play_with_me/features/groups/presentation/bloc/group_invite_link/group_invite_link_event.dart';
import 'package:play_with_me/features/groups/presentation/bloc/group_invite_link/group_invite_link_state.dart';
import 'package:play_with_me/core/domain/repositories/group_invite_link_repository.dart';
import 'package:play_with_me/features/games/presentation/bloc/games_list/games_list_bloc.dart';
import 'package:play_with_me/features/games/presentation/bloc/games_list/games_list_event.dart';
import 'package:play_with_me/features/games/presentation/bloc/games_list/games_list_state.dart';

class MockGroupMemberBloc extends MockBloc<GroupMemberEvent, GroupMemberState>
    implements GroupMemberBloc {}

class MockAuthenticationBloc
    extends MockBloc<AuthenticationEvent, AuthenticationState>
    implements AuthenticationBloc {}

class MockInvitationBloc extends MockBloc<InvitationEvent, InvitationState>
    implements InvitationBloc {}

class MockGroupRepository extends Mock implements GroupRepository {}

class MockUserRepository extends Mock implements UserRepository {}

class MockFriendRepository extends Mock implements FriendRepository {}

class MockGroupInviteLinkBloc
    extends MockBloc<GroupInviteLinkEvent, GroupInviteLinkState>
    implements GroupInviteLinkBloc {}

class MockGroupInviteLinkRepository extends Mock
    implements GroupInviteLinkRepository {}

class MockGamesListBloc extends MockBloc<GamesListEvent, GamesListState>
    implements GamesListBloc {}

class FakeGamesListEvent extends Fake implements GamesListEvent {}

class FakeGroupMemberEvent extends Fake implements GroupMemberEvent {}

class FakeGroupMemberState extends Fake implements GroupMemberState {}

void main() {
  late MockGroupMemberBloc mockGroupMemberBloc;
  late MockAuthenticationBloc mockAuthBloc;
  late MockInvitationBloc mockInvitationBloc;
  late MockGroupRepository mockGroupRepository;
  late MockUserRepository mockUserRepository;
  late MockFriendRepository mockFriendRepository;
  late MockGroupInviteLinkBloc mockGroupInviteLinkBloc;
  late MockGamesListBloc mockGamesListBloc;

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
    registerFallbackValue(FakeGamesListEvent());
  });

  setUp(() {
    mockGroupMemberBloc = MockGroupMemberBloc();
    mockAuthBloc = MockAuthenticationBloc();
    mockInvitationBloc = MockInvitationBloc();
    when(() => mockInvitationBloc.state).thenReturn(const InvitationInitial());
    mockGroupRepository = MockGroupRepository();
    mockUserRepository = MockUserRepository();
    mockFriendRepository = MockFriendRepository();
    mockGroupInviteLinkBloc = MockGroupInviteLinkBloc();
    when(
      () => mockGroupInviteLinkBloc.state,
    ).thenReturn(const GroupInviteLinkInitial());

    mockGamesListBloc = MockGamesListBloc();
    when(
      () => mockGamesListBloc.state,
    ).thenReturn(const GamesListEmpty(userId: testUserId));

    when(
      () => mockGroupMemberBloc.state,
    ).thenReturn(const GroupMemberInitial());

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
    // The page now uses watchGroupById (stream) instead of getGroupById.
    when(
      () => mockGroupRepository.watchGroupById(testGroupId),
    ).thenAnswer((_) => Stream.value(testGroup));
    when(
      () => mockGroupRepository.getGroupById(testGroupId),
    ).thenAnswer((_) async => testGroup);
    when(
      () => mockUserRepository.getUsersByIds(any()),
    ).thenAnswer((_) async => testMembers);
    when(
      () => mockFriendRepository.batchCheckFriendship(any()),
    ).thenAnswer((_) async => {'member-2': true, 'member-3': false});
    when(
      () => mockFriendRepository.batchCheckFriendRequestStatus(any()),
    ).thenAnswer((_) async => {'member-3': FriendRequestStatus.none});

    // Register service locator mocks
    if (sl.isRegistered<GroupMemberBloc>()) {
      sl.unregister<GroupMemberBloc>();
    }
    sl.registerFactory<GroupMemberBloc>(() => mockGroupMemberBloc);

    if (sl.isRegistered<GroupInviteLinkBloc>()) {
      sl.unregister<GroupInviteLinkBloc>();
    }
    sl.registerFactory<GroupInviteLinkBloc>(() => mockGroupInviteLinkBloc);

    if (sl.isRegistered<GamesListBloc>()) {
      sl.unregister<GamesListBloc>();
    }
    sl.registerFactory<GamesListBloc>(() => mockGamesListBloc);

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
    if (sl.isRegistered<GroupInviteLinkBloc>()) {
      sl.unregister<GroupInviteLinkBloc>();
    }
    if (sl.isRegistered<GamesListBloc>()) {
      sl.unregister<GamesListBloc>();
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
      supportedLocales: const [Locale('en')],
      home: MultiBlocProvider(
        providers: [
          BlocProvider<AuthenticationBloc>.value(value: mockAuthBloc),
          BlocProvider<InvitationBloc>.value(value: mockInvitationBloc),
        ],
        child: GroupDetailsPage(
          groupId: testGroupId,
          groupRepositoryOverride: mockGroupRepository,
          userRepositoryOverride: mockUserRepository,
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
            matching: find.text('Group'),
          ),
          findsOneWidget,
        );
      });

      testWidgets('shows loading indicator initially', (tester) async {
        // Use a StreamController that never emits to keep the page in loading state.
        final streamController = StreamController<GroupModel?>();
        when(
          () => mockGroupRepository.watchGroupById(testGroupId),
        ).thenAnswer((_) => streamController.stream);

        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Clean up: emit a value and close the controller.
        streamController.add(testGroup);
        await tester.pumpAndSettle();
        await streamController.close();
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

        // Invite entries are at the top, pushing some members below the fold.
        // Scroll down to ensure all members are built by the lazy list.
        await tester.drag(find.byType(ListView).first, const Offset(0, -200));
        await tester.pumpAndSettle();

        expect(find.text('Group Owner'), findsOneWidget);
        expect(find.text('Member Two'), findsOneWidget);
        expect(find.text('Member Three'), findsOneWidget);
      });
    });

    group('Error State', () {
      testWidgets('shows error message when group not found', (tester) async {
        // Stream emits null to signal group not found.
        when(
          () => mockGroupRepository.watchGroupById(testGroupId),
        ).thenAnswer((_) => Stream.value(null));

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Group not found'), findsOneWidget);
      });

      testWidgets('shows error state with retry button on load failure', (
        tester,
      ) async {
        // Stream emits an error to trigger the error state.
        when(
          () => mockGroupRepository.watchGroupById(testGroupId),
        ).thenAnswer((_) => Stream.error(Exception('Network error')));

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.text('Error'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
      });

      testWidgets('retry button reloads group details', (tester) async {
        // First subscription: error stream. Second subscription: success stream.
        var callCount = 0;
        when(() => mockGroupRepository.watchGroupById(testGroupId)).thenAnswer((
          _,
        ) {
          callCount++;
          if (callCount == 1) {
            return Stream.error(Exception('Network error'));
          }
          return Stream.value(testGroup);
        });

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Should show error state
        expect(find.text('Retry'), findsOneWidget);

        // Tap retry — this calls _subscribeToGroup() which re-subscribes
        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();

        // Should now show group name
        expect(find.text('Beach Volleyball Crew'), findsOneWidget);
      });
    });

    group('Unauthenticated State', () {
      testWidgets('shows login message when not authenticated', (tester) async {
        when(
          () => mockAuthBloc.state,
        ).thenReturn(const AuthenticationUnauthenticated());

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(
          find.text('Please log in to view group details'),
          findsOneWidget,
        );
      });
    });

    group('Leave Group Menu', () {
      testWidgets('shows more menu button', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // more_vert appears in the app bar AND on member rows for admins
        expect(find.byIcon(Icons.more_vert), findsWidgets);
      });

      testWidgets('shows Leave Group option in menu', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Tap the app bar's more menu specifically
        await tester.tap(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.byIcon(Icons.more_vert),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Leave Group'), findsOneWidget);
        expect(find.byIcon(Icons.exit_to_app), findsOneWidget);
      });
    });

    group('Bottom Navigation Bar', () {
      testWidgets('shows global bottom navigation bar after loading', (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // GlobalBottomNavBar uses BottomNavigationBar internally
        expect(find.byType(BottomNavigationBar), findsOneWidget);
      });

      testWidgets('global nav shows 4 items: Home, Stats, Groups, Community', (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Stats'), findsOneWidget);
        expect(find.text('Groups'), findsOneWidget);
        expect(find.text('Community'), findsOneWidget);
      });

      testWidgets('Groups tab is highlighted (selectedIndex == 2)', (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        final bottomNav = tester.widget<BottomNavigationBar>(
          find.byType(BottomNavigationBar),
        );
        expect(bottomNav.currentIndex, 2);
      });

      testWidgets('global bottom nav is visible while loading', (tester) async {
        final streamController = StreamController<GroupModel?>();
        when(
          () => mockGroupRepository.watchGroupById(testGroupId),
        ).thenAnswer((_) => streamController.stream);

        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Nav bar is always visible, even before group data loads
        expect(find.byType(BottomNavigationBar), findsOneWidget);

        streamController.add(testGroup);
        await tester.pumpAndSettle();
        await streamController.close();
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
      testWidgets('shows success message when member is promoted', (
        tester,
      ) async {
        whenListen(
          mockGroupMemberBloc,
          Stream.fromIterable([
            const GroupMemberInitial(),
            const MemberPromotedSuccess(
              groupId: testGroupId,
              userId: 'member-2',
            ),
          ]),
          initialState: const GroupMemberInitial(),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Member promoted to admin'), findsOneWidget);
      });

      testWidgets('shows success message when member is demoted', (
        tester,
      ) async {
        whenListen(
          mockGroupMemberBloc,
          Stream.fromIterable([
            const GroupMemberInitial(),
            const MemberDemotedSuccess(
              groupId: testGroupId,
              userId: 'member-2',
            ),
          ]),
          initialState: const GroupMemberInitial(),
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Member demoted to regular member'), findsOneWidget);
      });

      testWidgets('shows success message when member is removed', (
        tester,
      ) async {
        whenListen(
          mockGroupMemberBloc,
          Stream.fromIterable([
            const GroupMemberInitial(),
            const MemberRemovedSuccess(
              groupId: testGroupId,
              userId: 'member-2',
            ),
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

        expect(find.byIcon(Icons.people), findsWidgets);
      });
    });

    group('Tab Layout', () {
      testWidgets('shows Members and Activities tabs', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(TabBar), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(TabBar),
            matching: find.text('Members'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(TabBar),
            matching: find.text('Activities'),
          ),
          findsOneWidget,
        );
      });

      testWidgets('Members tab shows member list', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Scroll to build members pushed below the fold by invite entries.
        await tester.drag(find.byType(ListView).first, const Offset(0, -200));
        await tester.pumpAndSettle();

        expect(find.text('Group Owner'), findsOneWidget);
        expect(find.text('Member Two'), findsOneWidget);
        expect(find.text('Member Three'), findsOneWidget);
      });

      testWidgets(
        'Members tab shows Invite Member entry at the top for admins',
        (tester) async {
          await tester.pumpWidget(createTestWidget());
          await tester.pumpAndSettle();

          // Entries are at the top of the list — no scrolling needed
          expect(find.text('Invite Member'), findsOneWidget);
        },
      );

      testWidgets(
        'Members tab shows Invite with Link entry at the top for admins',
        (tester) async {
          await tester.pumpWidget(createTestWidget());
          await tester.pumpAndSettle();

          expect(find.text('Invite with Link'), findsOneWidget);
        },
      );

      testWidgets('Activities tab shows Create Game button', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Tap the Activities tab
        await tester.tap(find.text('Activities'));
        await tester.pumpAndSettle();

        expect(find.text('Create Game'), findsOneWidget);
      });

      testWidgets('Activities tab shows Create Training button', (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Activities'));
        await tester.pumpAndSettle();

        expect(find.text('Create Training'), findsOneWidget);
      });

      testWidgets('Activities tab shows empty state when no activities', (
        tester,
      ) async {
        when(
          () => mockGamesListBloc.state,
        ).thenReturn(const GamesListEmpty(userId: testUserId));

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Activities'));
        await tester.pumpAndSettle();

        expect(find.text('No activities yet'), findsOneWidget);
      });
    });
  });
}
