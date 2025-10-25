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
import 'package:play_with_me/core/presentation/bloc/group/group_bloc.dart';
import 'package:play_with_me/features/profile/domain/entities/locale_preferences_entity.dart';
import 'package:play_with_me/features/profile/domain/repositories/locale_preferences_repository.dart';
import '../features/auth/data/mock_auth_repository.dart';
import '../core/data/repositories/mock_group_repository.dart';

// Mock for LocalePreferencesRepository
class MockLocalePreferencesRepository extends Mock implements LocalePreferencesRepository {}

// Global test repository instances for control during tests
MockAuthRepository? _globalMockRepo;
MockGroupRepository? _globalMockGroupRepo;

/// Initialize test dependencies with mock services instead of real Firebase
Future<void> initializeTestDependencies({
  bool startUnauthenticated = true,
}) async {
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

  // Register BLoCs with mock repository
  sl.registerFactory<AuthenticationBloc>(
    () => AuthenticationBloc(authRepository: sl<AuthRepository>()),
  );

  sl.registerFactory<LoginBloc>(
    () => LoginBloc(authRepository: sl<AuthRepository>()),
  );

  sl.registerFactory<RegistrationBloc>(
    () => RegistrationBloc(authRepository: sl<AuthRepository>()),
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
    () => GroupBloc(groupRepository: sl<GroupRepository>()),
  );
}

/// Get the mock repository for test control
MockAuthRepository? getTestAuthRepository() => _globalMockRepo;

/// Get the mock group repository for test control
MockGroupRepository? getTestGroupRepository() => _globalMockGroupRepo;

/// Clean up test dependencies
void cleanupTestDependencies() {
  _globalMockRepo?.dispose();
  _globalMockRepo = null;
  _globalMockGroupRepo?.dispose();
  _globalMockGroupRepo = null;
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