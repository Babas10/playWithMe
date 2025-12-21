import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/services/service_locator.dart';
import 'package:play_with_me/features/auth/domain/repositories/auth_repository.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/registration/registration_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/password_reset/password_reset_bloc.dart';
import 'package:play_with_me/core/domain/repositories/group_repository.dart';
import 'package:play_with_me/core/domain/repositories/user_repository.dart';
import 'package:play_with_me/core/domain/repositories/invitation_repository.dart';
import 'package:play_with_me/core/domain/repositories/friend_repository.dart';
import 'package:play_with_me/core/data/models/user_model.dart';
import 'package:play_with_me/core/presentation/bloc/group/group_bloc.dart';
import 'package:play_with_me/core/presentation/bloc/invitation/invitation_bloc.dart';
import 'package:play_with_me/features/friends/presentation/bloc/friend_bloc.dart';
import 'package:play_with_me/features/friends/presentation/bloc/friend_request_count_bloc.dart';
import 'package:play_with_me/features/profile/domain/entities/locale_preferences_entity.dart';
import 'package:play_with_me/features/profile/domain/repositories/locale_preferences_repository.dart';
import '../features/auth/data/mock_auth_repository.dart';
import '../core/data/repositories/mock_group_repository.dart';

// Mock for LocalePreferencesRepository
class MockLocalePreferencesRepository extends Mock implements LocalePreferencesRepository {}

// Mock for UserRepository
class MockUserRepository extends Mock implements UserRepository {}

// Mock for InvitationRepository
class MockInvitationRepository extends Mock implements InvitationRepository {}

// Mock for FriendRepository
class MockFriendRepository extends Mock implements FriendRepository {}

// Fake for UserModel (required for mocktail's any() matcher)
class FakeUserModel extends Fake implements UserModel {}

// Global test repository instances for control during tests
MockAuthRepository? _globalMockRepo;
MockGroupRepository? _globalMockGroupRepo;
MockUserRepository? _globalMockUserRepo;
MockInvitationRepository? _globalMockInvitationRepo;
MockFriendRepository? _globalMockFriendRepo;

/// Initialize test dependencies with mock services instead of real Firebase
Future<void> initializeTestDependencies({
  bool startUnauthenticated = true,
}) async {
  // Register fallback values for mocktail's any() matcher
  registerFallbackValue(FakeUserModel());

  // Reset service locator
  sl.reset();

  // Dispose of previous mock repositories if they exist
  _globalMockRepo?.dispose();
  _globalMockGroupRepo?.dispose();

  // Create and configure mock repository with initial state
  _globalMockRepo = MockAuthRepository();

  if (startUnauthenticated) {
    // Set initial state to unauthenticated (null user) immediately
    _globalMockRepo!.setCurrentUser(null);
    // Ensure the stream immediately emits the initial state
    await Future.delayed(Duration.zero);
  }

  // Register mock repository
  sl.registerLazySingleton<AuthRepository>(
    () => _globalMockRepo!,
  );

  // Register mock UserRepository
  _globalMockUserRepo = MockUserRepository();
  when(() => _globalMockUserRepo!.createOrUpdateUser(any())).thenAnswer((_) async {});
  // Stub getUserStream to return an empty stream (for PlayerStatsBloc)
  when(() => _globalMockUserRepo!.getUserStream(any())).thenAnswer((_) => Stream.value(null));
  // Stub getRatingHistory to return an empty stream (for PlayerStatsBloc)
  when(() => _globalMockUserRepo!.getRatingHistory(any(), limit: any(named: 'limit')))
      .thenAnswer((_) => Stream.value([]));
  sl.registerLazySingleton<UserRepository>(
    () => _globalMockUserRepo!,
  );

  // Register BLoCs with mock repository
  sl.registerFactory<AuthenticationBloc>(
    () => AuthenticationBloc(authRepository: sl<AuthRepository>()),
  );

  sl.registerFactory<LoginBloc>(
    () => LoginBloc(authRepository: sl<AuthRepository>()),
  );

  sl.registerFactory<RegistrationBloc>(
    () => RegistrationBloc(
      authRepository: sl<AuthRepository>(),
      userRepository: sl<UserRepository>(),
    ),
  );

  sl.registerFactory<PasswordResetBloc>(
    () => PasswordResetBloc(authRepository: sl<AuthRepository>()),
  );

  // Register mock LocalePreferencesRepository
  final mockLocalePrefsRepo = MockLocalePreferencesRepository();
  when(() => mockLocalePrefsRepo.loadPreferences()).thenAnswer(
    (_) async => LocalePreferencesEntity.defaultPreferences(),
  );
  when(() => mockLocalePrefsRepo.savePreferences(any())).thenAnswer(
    (_) async {},
  );
  when(() => mockLocalePrefsRepo.syncToFirestore(any(), any())).thenAnswer(
    (_) async {},
  );
  when(() => mockLocalePrefsRepo.loadFromFirestore(any())).thenAnswer(
    (_) async => null,
  );
  when(() => mockLocalePrefsRepo.getDeviceTimeZone()).thenReturn('UTC');

  sl.registerLazySingleton<LocalePreferencesRepository>(
    () => mockLocalePrefsRepo,
  );

  // Register MockGroupRepository for group-related tests
  _globalMockGroupRepo = MockGroupRepository();
  sl.registerLazySingleton<GroupRepository>(() => _globalMockGroupRepo!);

  // Register GroupBloc factory that uses the mock repository
  sl.registerFactory<GroupBloc>(
    () => GroupBloc(
      groupRepository: sl<GroupRepository>(),
      invitationRepository: sl<InvitationRepository>(),
    ),
  );

  // Register MockInvitationRepository for invitation-related tests
  _globalMockInvitationRepo = MockInvitationRepository();
  sl.registerLazySingleton<InvitationRepository>(() => _globalMockInvitationRepo!);

  // Register InvitationBloc factory that uses the mock repository
  sl.registerFactory<InvitationBloc>(
    () => InvitationBloc(invitationRepository: sl<InvitationRepository>()),
  );

  // Register MockFriendRepository for friend-related tests
  _globalMockFriendRepo = MockFriendRepository();
  // Mock the getPendingFriendRequestCount stream to return 0 by default
  when(() => _globalMockFriendRepo!.getPendingFriendRequestCount(any()))
      .thenAnswer((_) => Stream.value(0));
  sl.registerLazySingleton<FriendRepository>(() => _globalMockFriendRepo!);

  // Register FriendBloc factory that uses the mock repository
  sl.registerFactory<FriendBloc>(
    () => FriendBloc(
      friendRepository: sl<FriendRepository>(),
      authRepository: sl<AuthRepository>(),
    ),
  );

  // Register FriendRequestCountBloc factory that uses the mock repository
  sl.registerFactory<FriendRequestCountBloc>(
    () => FriendRequestCountBloc(
      friendRepository: sl<FriendRepository>(),
    ),
  );
}

/// Get the mock repository for test control
MockAuthRepository? getTestAuthRepository() => _globalMockRepo;

/// Get the mock group repository for test control
MockGroupRepository? getTestGroupRepository() => _globalMockGroupRepo;

/// Get the mock user repository for test control
MockUserRepository? getTestUserRepository() => _globalMockUserRepo;

/// Get the mock invitation repository for test control
MockInvitationRepository? getTestInvitationRepository() => _globalMockInvitationRepo;

/// Get the mock friend repository for test control
MockFriendRepository? getTestFriendRepository() => _globalMockFriendRepo;

/// Clean up test dependencies
void cleanupTestDependencies() {
  _globalMockRepo?.dispose();
  _globalMockRepo = null;
  _globalMockGroupRepo?.dispose();
  _globalMockGroupRepo = null;
  _globalMockUserRepo = null;
  _globalMockInvitationRepo = null;
  _globalMockFriendRepo = null;
  sl.reset();
}

/// Wait for authentication state to stabilize
Future<void> waitForAuthState(Duration timeout) async {
  final completer = Completer<void>();
  Timer(timeout, () {
    if (!completer.isCompleted) {
      completer.complete();
    }
  });
  await completer.future;
}