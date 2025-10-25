// Simplified integration test for GroupListPage with real-time Firestore updates
// This verifies end-to-end flow with fake_cloud_firestore
// Most test coverage is in widget tests - this just validates real Firestore integration
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:play_with_me/core/data/models/group_model.dart';
import 'package:play_with_me/core/data/repositories/firestore_group_repository.dart';
import 'package:play_with_me/core/domain/repositories/group_repository.dart';
import 'package:play_with_me/core/presentation/bloc/group/group_bloc.dart';
import 'package:play_with_me/core/presentation/bloc/group/group_event.dart';
import 'package:play_with_me/core/services/service_locator.dart';
import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_state.dart';
import 'package:play_with_me/features/groups/presentation/pages/group_list_page.dart';
import 'package:play_with_me/features/groups/presentation/widgets/group_list_item.dart';
import 'package:play_with_me/features/groups/presentation/widgets/empty_group_list.dart';
import 'package:play_with_me/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';
import '../helpers/ci_test_helper.dart';

// Mock classes
class MockAuthenticationBloc extends Mock implements AuthenticationBloc {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('GroupListPage Real-time Integration',
    skip: !CITestHelper.isCIEnvironment
      ? 'CI-only integration tests - run only in GitHub Actions pipeline'
      : null, () {
    late FakeFirebaseFirestore fakeFirestore;
    late FirestoreGroupRepository repository;
    late MockAuthenticationBloc authBloc;
    late GroupBloc groupBloc;

    const testUserId = 'test-user-123';

    setUp(() {
      // Reset GetIt
      sl.reset();

      fakeFirestore = FakeFirebaseFirestore();
      repository = FirestoreGroupRepository(firestore: fakeFirestore);

      // Register the repository in GetIt (for group creation if needed)
      sl.registerLazySingleton<GroupRepository>(() => repository);

      // Create a GroupBloc instance for this test
      groupBloc = GroupBloc(groupRepository: repository);

      authBloc = MockAuthenticationBloc();
      when(() => authBloc.state).thenReturn(
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
      when(() => authBloc.stream).thenAnswer((_) => const Stream.empty());
    });

    tearDown(() {
      groupBloc.close();
      sl.reset();
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
          value: authBloc,
          child: GroupListPage(blocOverride: groupBloc),
        ),
      );
    }

    testWidgets('end-to-end: displays groups from Firestore', (tester) async {
      // Arrange - Create a group in fake Firestore
      final group = GroupModel(
        id: '',
        name: 'Beach Volleyball Crew',
        description: 'Weekly beach games',
        createdBy: testUserId,
        createdAt: DateTime(2024, 1, 1),
        memberIds: [testUserId, 'user-456'],
        adminIds: [testUserId],
      );
      await repository.createGroup(group);

      // Act
      await tester.pumpWidget(createApp());
      groupBloc.add(LoadGroupsForUser(userId: testUserId));

      // Use runAsync to properly handle async Firestore stream emissions
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 500));
      });
      // Use pump() instead of pumpAndSettle() to avoid timeout with continuous stream
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Assert - Verify real Firestore integration works
      expect(find.byType(GroupListItem), findsOneWidget);
      expect(find.text('Beach Volleyball Crew'), findsOneWidget);
      expect(find.textContaining('2 members'), findsOneWidget);
    }, skip: true); // TODO: Re-enable once Firestore emulator tests are stable (async stream timing issues in CI)

    testWidgets('end-to-end: real-time update when group is added', (tester) async {
      // Arrange - Start with empty Firestore
      await tester.pumpWidget(createApp());
      groupBloc.add(LoadGroupsForUser(userId: testUserId));

      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 500));
      });
      await tester.pumpAndSettle();

      // Verify empty state
      expect(find.byType(EmptyGroupList), findsOneWidget);

      // Act - Add a group to Firestore while stream is active
      final newGroup = GroupModel(
        id: '',
        name: 'New Volleyball Team',
        createdBy: testUserId,
        createdAt: DateTime.now(),
        memberIds: [testUserId],
        adminIds: [testUserId],
      );

      await tester.runAsync(() async {
        await repository.createGroup(newGroup);
        await Future.delayed(const Duration(milliseconds: 500));
      });
      await tester.pumpAndSettle();

      // Assert - Verify real-time update works
      expect(find.byType(GroupListItem), findsOneWidget);
      expect(find.text('New Volleyball Team'), findsOneWidget);
      expect(find.byType(EmptyGroupList), findsNothing);
    }, skip: true); // TODO: Re-enable once Firestore emulator tests are stable (async stream timing issues in CI)
  });
}
