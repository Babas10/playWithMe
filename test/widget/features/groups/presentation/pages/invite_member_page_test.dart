// Widget tests for InviteMemberPage with friend selector
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/core/domain/repositories/friend_repository.dart';
import 'package:play_with_me/core/domain/repositories/group_repository.dart';
import 'package:play_with_me/core/domain/repositories/invitation_repository.dart';
import 'package:play_with_me/core/presentation/bloc/invitation/invitation_bloc.dart';
import 'package:play_with_me/core/presentation/bloc/invitation/invitation_state.dart';
import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_state.dart';
import 'package:play_with_me/features/groups/presentation/pages/invite_member_page.dart';
import 'package:play_with_me/core/data/models/group_model.dart';

class MockFriendRepository extends Mock implements FriendRepository {}
class MockGroupRepository extends Mock implements GroupRepository {}
class MockInvitationRepository extends Mock implements InvitationRepository {}
class MockAuthenticationBloc extends Mock implements AuthenticationBloc {}
class MockInvitationBloc extends Mock implements InvitationBloc {}

void main() {
  late MockFriendRepository mockFriendRepository;
  late MockGroupRepository mockGroupRepository;
  late MockInvitationRepository mockInvitationRepository;
  late MockAuthenticationBloc mockAuthenticationBloc;
  late MockInvitationBloc mockInvitationBloc;

  setUp(() {
    mockFriendRepository = MockFriendRepository();
    mockGroupRepository = MockGroupRepository();
    mockInvitationRepository = MockInvitationRepository();
    mockAuthenticationBloc = MockAuthenticationBloc();
    mockInvitationBloc = MockInvitationBloc();
    when(() => mockInvitationBloc.state).thenReturn(const InvitationInitial());
    when(() => mockInvitationBloc.stream).thenAnswer((_) => const Stream.empty());

    // Default group data setup
    when(() => mockGroupRepository.getGroupById(any())).thenAnswer(
      (_) async => GroupModel(
        id: 'test-group',
        name: 'Test Group',
        createdBy: 'creator-id',
        createdAt: DateTime.now(),
        memberIds: ['creator-id'],
      ),
    );
  });

  Widget createWidgetUnderTest({FriendRepository? friendRepository}) {
    const testUser = UserEntity(
      uid: 'test-user',
      email: 'test@example.com',
      displayName: 'Test User',
      isEmailVerified: true,
      isAnonymous: false,
    );

    when(() => mockAuthenticationBloc.state).thenReturn(
      const AuthenticationAuthenticated(testUser),
    );

    when(() => mockAuthenticationBloc.stream).thenAnswer(
      (_) => Stream.value(const AuthenticationAuthenticated(testUser)),
    );

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
          BlocProvider<AuthenticationBloc>.value(value: mockAuthenticationBloc),
          BlocProvider<InvitationBloc>.value(value: mockInvitationBloc),
        ],
        child: InviteMemberPage(
          groupId: 'test-group',
          groupName: 'Test Group',
          friendRepository: friendRepository ?? mockFriendRepository,
          groupRepositoryOverride: mockGroupRepository,
          invitationRepositoryOverride: mockInvitationRepository,
        ),
      ),
    );
  }

  group('InviteMemberPage', () {
    testWidgets('displays title and instructions', (tester) async {
      // Arrange
      when(() => mockFriendRepository.getFriends('test-user')).thenAnswer(
        (_) async => [],
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Invite Members'), findsOneWidget);
      expect(
        find.text('Select friends from your community to invite to this group'),
        findsOneWidget,
      );
    });

    testWidgets('renders FriendSelectorWidget with friends', (tester) async {
      // Arrange
      final friends = [
        const UserEntity(
          uid: 'friend-1',
          email: 'friend1@example.com',
          displayName: 'Friend One',
          isEmailVerified: true,
          isAnonymous: false,
        ),
      ];

      when(() => mockFriendRepository.getFriends('test-user')).thenAnswer(
        (_) async => friends,
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert - friend selector is rendering
      expect(find.text('Friend One'), findsOneWidget);
      expect(find.byType(CheckboxListTile), findsOneWidget);
    });

    testWidgets('shows disabled send button when no selection', (tester) async {
      // Arrange
      when(() => mockFriendRepository.getFriends('test-user')).thenAnswer(
        (_) async => [],
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Select friends to invite'), findsOneWidget);
    });

    // NOTE: Test for null FriendRepository requires GetIt setup refactoring
    // See: https://github.com/Babas10/playWithMe/issues/442
  });
}
