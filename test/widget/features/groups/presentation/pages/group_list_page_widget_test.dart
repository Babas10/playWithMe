// Widget tests for GroupListPage using mocked repository
// These tests verify UI behavior without real Firestore streams
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/group_model.dart';
import 'package:play_with_me/core/presentation/bloc/group/group_bloc.dart';
import 'package:play_with_me/core/presentation/bloc/group/group_event.dart';
import 'package:play_with_me/core/presentation/bloc/group/group_state.dart';
import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_state.dart';
import 'package:play_with_me/features/groups/presentation/pages/group_list_page.dart';
import 'package:play_with_me/features/groups/presentation/widgets/group_list_item.dart';
import 'package:play_with_me/features/groups/presentation/widgets/empty_group_list.dart';
import 'package:play_with_me/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';
import '../../../../../unit/core/data/repositories/mock_group_repository.dart';

// Mock classes
class MockAuthenticationBloc extends Mock implements AuthenticationBloc {}

void main() {
  late MockGroupRepository mockGroupRepository;
  late MockAuthenticationBloc mockAuthBloc;
  late GroupBloc groupBloc;

  const testUserId = 'test-user-123';

  setUp(() {
    mockGroupRepository = MockGroupRepository();
    mockAuthBloc = MockAuthenticationBloc();

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
    when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());

    // Ensure groups are cleared before each test
    mockGroupRepository.clearGroups();
    groupBloc = GroupBloc(groupRepository: mockGroupRepository);
  });

  tearDown(() {
    groupBloc.close();
    mockGroupRepository.dispose();
  });

  Widget createApp() {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: BlocProvider<AuthenticationBloc>.value(
        value: mockAuthBloc,
        child: GroupListPage(blocOverride: groupBloc),
      ),
    );
  }

  group('GroupListPage Widget Tests', () {
    testWidgets('displays empty state when user has no groups', (tester) async {
      // Arrange: MockGroupRepository starts with empty groups

      // Act
      await tester.pumpWidget(createApp());
      groupBloc.add(LoadGroupsForUser(userId: testUserId));
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(EmptyGroupList), findsOneWidget);
      expect(find.text("You're not part of any group yet"), findsOneWidget);
    });

    testWidgets('displays groups when user is a member', (tester) async {
      // Arrange
      final group = GroupModel(
        id: 'group-1',
        name: 'Beach Volleyball Crew',
        description: 'Weekly beach games',
        createdBy: testUserId,
        createdAt: DateTime(2024, 1, 1),
        memberIds: [testUserId, 'user-456'],
        adminIds: [testUserId],
      );
      mockGroupRepository.addGroup(group);

      // Act
      await tester.pumpWidget(createApp());
      groupBloc.add(LoadGroupsForUser(userId: testUserId));

      // Use runAsync to properly handle async stream emissions
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(GroupListItem), findsOneWidget);
      expect(find.text('Beach Volleyball Crew'), findsOneWidget);
      expect(find.textContaining('2 members'), findsOneWidget);
    });

    // NOTE: Real-time stream update test removed - stream timing cannot be reliably
    // tested with mocked repositories. Real-time updates are covered in integration tests.
    // See: integration_test/group_stream_integration_test.dart

    testWidgets('displays multiple groups correctly', (tester) async {
      // Arrange
      mockGroupRepository.addGroup(GroupModel(
        id: 'group-1',
        name: 'Group A',
        createdBy: testUserId,
        createdAt: DateTime(2024, 1, 1),
        memberIds: [testUserId],
        adminIds: [testUserId],
      ));
      mockGroupRepository.addGroup(GroupModel(
        id: 'group-2',
        name: 'Group B',
        createdBy: testUserId,
        createdAt: DateTime(2024, 1, 2),
        memberIds: [testUserId],
        adminIds: [testUserId],
      ));
      mockGroupRepository.addGroup(GroupModel(
        id: 'group-3',
        name: 'Group C',
        createdBy: testUserId,
        createdAt: DateTime(2024, 1, 3),
        memberIds: [testUserId],
        adminIds: [testUserId],
      ));

      // Act
      await tester.pumpWidget(createApp());
      groupBloc.add(LoadGroupsForUser(userId: testUserId));
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(GroupListItem), findsNWidgets(3));
      expect(find.text('Group A'), findsOneWidget);
      expect(find.text('Group B'), findsOneWidget);
      expect(find.text('Group C'), findsOneWidget);
    });

    testWidgets('does not display groups where user is not a member', (tester) async {
      // Arrange
      mockGroupRepository.addGroup(GroupModel(
        id: 'group-1',
        name: 'My Group',
        createdBy: testUserId,
        createdAt: DateTime(2024, 1, 1),
        memberIds: [testUserId],
        adminIds: [testUserId],
      ));
      mockGroupRepository.addGroup(GroupModel(
        id: 'group-2',
        name: 'Other Group',
        createdBy: 'other-user',
        createdAt: DateTime(2024, 1, 2),
        memberIds: ['other-user'],
        adminIds: ['other-user'],
      ));

      // Act
      await tester.pumpWidget(createApp());
      groupBloc.add(LoadGroupsForUser(userId: testUserId));
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      // Assert - Should only see "My Group"
      expect(find.byType(GroupListItem), findsOneWidget);
      expect(find.text('My Group'), findsOneWidget);
      expect(find.text('Other Group'), findsNothing);
    });

    testWidgets('displays correct member count', (tester) async {
      // Arrange
      final group = GroupModel(
        id: 'group-1',
        name: 'Big Team',
        createdBy: testUserId,
        createdAt: DateTime(2024, 1, 1),
        memberIds: [testUserId, 'user-2', 'user-3', 'user-4', 'user-5'],
        adminIds: [testUserId],
      );
      mockGroupRepository.addGroup(group);

      // Act
      await tester.pumpWidget(createApp());
      groupBloc.add(LoadGroupsForUser(userId: testUserId));
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('5 members'), findsOneWidget);
    });

    testWidgets('displays group privacy correctly', (tester) async {
      // Arrange
      final group = GroupModel(
        id: 'group-1',
        name: 'Public Group',
        createdBy: testUserId,
        createdAt: DateTime(2024, 1, 1),
        memberIds: [testUserId],
        adminIds: [testUserId],
        privacy: GroupPrivacy.public,
      );
      mockGroupRepository.addGroup(group);

      // Act
      await tester.pumpWidget(createApp());
      groupBloc.add(LoadGroupsForUser(userId: testUserId));
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Public'), findsOneWidget);
      expect(find.byIcon(Icons.public), findsOneWidget);
    });

    testWidgets('displays FAB for creating groups', (tester) async {
      // Act
      await tester.pumpWidget(createApp());
      groupBloc.add(LoadGroupsForUser(userId: testUserId));
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('Create Group'), findsOneWidget);
    });
  });
}
