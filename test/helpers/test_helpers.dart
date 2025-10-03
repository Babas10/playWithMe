import 'package:play_with_me/core/services/service_locator.dart';
import 'package:play_with_me/features/auth/domain/repositories/auth_repository.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/registration/registration_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/password_reset/password_reset_bloc.dart';
import '../features/auth/data/mock_auth_repository.dart';

/// Initialize test dependencies with mock services instead of real Firebase
Future<void> initializeTestDependencies() async {
  // Reset service locator
  sl.reset();

  // Create and configure mock repository with initial state
  final mockRepo = MockAuthRepository();
  // Set initial state to unauthenticated (null user)
  mockRepo.setCurrentUser(null);

  // Register mock repository
  sl.registerLazySingleton<AuthRepository>(
    () => mockRepo,
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
}

/// Clean up test dependencies
void cleanupTestDependencies() {
  sl.reset();
}