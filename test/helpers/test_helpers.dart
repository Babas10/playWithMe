import 'dart:async';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/services/service_locator.dart';
import 'package:play_with_me/core/domain/repositories/user_repository.dart';
import 'package:play_with_me/core/presentation/bloc/deep_link/deep_link_bloc.dart';
import 'package:play_with_me/core/services/deep_link_service.dart';
import 'package:play_with_me/core/services/pending_invite_storage.dart';
import 'package:play_with_me/features/auth/domain/repositories/auth_repository.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/registration/registration_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/password_reset/password_reset_bloc.dart';
import 'package:play_with_me/core/domain/repositories/group_invite_link_repository.dart';
import 'package:play_with_me/core/domain/repositories/invitation_repository.dart';
import 'package:play_with_me/core/presentation/bloc/invitation/invitation_bloc.dart';
import 'package:play_with_me/features/invitations/presentation/bloc/invite_join/invite_join_bloc.dart';
import 'package:play_with_me/features/profile/domain/entities/locale_preferences_entity.dart';
import 'package:play_with_me/features/profile/domain/repositories/locale_preferences_repository.dart';
import '../unit/features/auth/data/mock_auth_repository.dart';
import '../unit/core/data/repositories/mock_user_repository.dart';

class MockDeepLinkService extends Mock implements DeepLinkService {}

class MockPendingInviteStorage extends Mock implements PendingInviteStorage {}

class MockGroupInviteLinkRepository extends Mock
    implements GroupInviteLinkRepository {}

class MockInvitationRepository extends Mock implements InvitationRepository {}

class MockLocalePreferencesRepository extends Mock
    implements LocalePreferencesRepository {}

// Global test repository instances for control during tests
MockAuthRepository? _globalMockRepo;
MockUserRepository? _globalMockUserRepo;

/// Initialize test dependencies with mock services instead of real Firebase
Future<void> initializeTestDependencies({
  bool startUnauthenticated = true,
}) async {
  // Reset service locator
  sl.reset();

  // Dispose of previous mock repositories if they exist
  _globalMockRepo?.dispose();

  // Create and configure mock repositories with initial state
  _globalMockRepo = MockAuthRepository();
  _globalMockUserRepo = MockUserRepository();

  if (startUnauthenticated) {
    // Set initial state to unauthenticated (null user) immediately
    _globalMockRepo!.setCurrentUser(null);
    // Ensure the stream immediately emits the initial state
    await Future.delayed(Duration.zero);
  }

  // Register mock repositories
  sl.registerLazySingleton<AuthRepository>(
    () => _globalMockRepo!,
  );

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
    ),
  );

  sl.registerFactory<PasswordResetBloc>(
    () => PasswordResetBloc(authRepository: sl<AuthRepository>()),
  );

  // Register InvitationBloc with mock repository
  final mockInvitationRepo = MockInvitationRepository();
  sl.registerLazySingleton<InvitationRepository>(() => mockInvitationRepo);
  sl.registerFactory<InvitationBloc>(
    () => InvitationBloc(invitationRepository: sl<InvitationRepository>()),
  );

  // Register LocalePreferencesRepository mock
  final mockLocalePreferencesRepo = MockLocalePreferencesRepository();
  when(() => mockLocalePreferencesRepo.loadPreferences()).thenAnswer(
    (_) async => LocalePreferencesEntity.defaultPreferences(),
  );
  sl.registerLazySingleton<LocalePreferencesRepository>(
      () => mockLocalePreferencesRepo);

  // Register deep link services and bloc
  final mockDeepLinkService = MockDeepLinkService();
  final mockPendingInviteStorage = MockPendingInviteStorage();
  when(() => mockDeepLinkService.inviteTokenStream)
      .thenAnswer((_) => const Stream.empty());
  when(() => mockDeepLinkService.getInitialInviteToken())
      .thenAnswer((_) async => null);
  when(() => mockPendingInviteStorage.retrieve())
      .thenAnswer((_) async => null);

  sl.registerLazySingleton<DeepLinkService>(() => mockDeepLinkService);
  sl.registerLazySingleton<PendingInviteStorage>(
      () => mockPendingInviteStorage);
  sl.registerFactory<DeepLinkBloc>(
    () => DeepLinkBloc(
      deepLinkService: sl<DeepLinkService>(),
      pendingInviteStorage: sl<PendingInviteStorage>(),
    ),
  );

  // Register InviteJoinBloc with mock repository
  final mockGroupInviteLinkRepo = MockGroupInviteLinkRepository();
  sl.registerLazySingleton<GroupInviteLinkRepository>(
      () => mockGroupInviteLinkRepo);
  sl.registerFactory<InviteJoinBloc>(
    () => InviteJoinBloc(
      repository: sl<GroupInviteLinkRepository>(),
      pendingInviteStorage: sl<PendingInviteStorage>(),
    ),
  );
}

/// Get the mock repository for test control
MockAuthRepository? getTestAuthRepository() => _globalMockRepo;

/// Clean up test dependencies
void cleanupTestDependencies() {
  _globalMockRepo?.dispose();
  _globalMockRepo = null;
  _globalMockUserRepo = null;
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