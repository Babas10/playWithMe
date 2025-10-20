import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/services/service_locator.dart';
import 'package:play_with_me/features/auth/domain/repositories/auth_repository.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/registration/registration_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/password_reset/password_reset_bloc.dart';
import 'package:play_with_me/features/profile/domain/entities/locale_preferences_entity.dart';
import 'package:play_with_me/features/profile/domain/repositories/locale_preferences_repository.dart';
import '../features/auth/data/mock_auth_repository.dart';

// Mock for LocalePreferencesRepository
class MockLocalePreferencesRepository extends Mock implements LocalePreferencesRepository {}

// Global test repository instance for control during tests
MockAuthRepository? _globalMockRepo;

/// Initialize test dependencies with mock services instead of real Firebase
Future<void> initializeTestDependencies({
  bool startUnauthenticated = true,
}) async {
  // Reset service locator
  sl.reset();

  // Dispose of previous mock repository if it exists
  _globalMockRepo?.dispose();

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
}

/// Get the mock repository for test control
MockAuthRepository? getTestAuthRepository() => _globalMockRepo;

/// Clean up test dependencies
void cleanupTestDependencies() {
  _globalMockRepo?.dispose();
  _globalMockRepo = null;
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