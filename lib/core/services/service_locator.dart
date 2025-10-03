import 'package:get_it/get_it.dart';
import 'package:play_with_me/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:play_with_me/features/auth/domain/repositories/auth_repository.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/registration/registration_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/password_reset/password_reset_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // Firebase service is initialized statically, no need to register

  // Register repositories only if not already registered
  if (!sl.isRegistered<AuthRepository>()) {
    sl.registerLazySingleton<AuthRepository>(
      () => FirebaseAuthRepository(),
    );
  }

  // Register BLoCs only if not already registered
  if (!sl.isRegistered<AuthenticationBloc>()) {
    sl.registerFactory<AuthenticationBloc>(
      () => AuthenticationBloc(authRepository: sl()),
    );
  }

  if (!sl.isRegistered<LoginBloc>()) {
    sl.registerFactory<LoginBloc>(
      () => LoginBloc(authRepository: sl()),
    );
  }

  if (!sl.isRegistered<RegistrationBloc>()) {
    sl.registerFactory<RegistrationBloc>(
      () => RegistrationBloc(authRepository: sl()),
    );
  }

  if (!sl.isRegistered<PasswordResetBloc>()) {
    sl.registerFactory<PasswordResetBloc>(
      () => PasswordResetBloc(authRepository: sl()),
    );
  }
}