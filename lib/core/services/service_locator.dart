import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:play_with_me/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:play_with_me/features/auth/domain/repositories/auth_repository.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/registration/registration_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/password_reset/password_reset_bloc.dart';
import 'package:play_with_me/core/domain/repositories/user_repository.dart';
import 'package:play_with_me/core/domain/repositories/group_repository.dart';
import 'package:play_with_me/core/domain/repositories/game_repository.dart';
import 'package:play_with_me/core/domain/repositories/image_storage_repository.dart';
import 'package:play_with_me/core/data/repositories/firestore_user_repository.dart';
import 'package:play_with_me/core/data/repositories/firestore_group_repository.dart';
import 'package:play_with_me/core/data/repositories/firestore_game_repository.dart';
import 'package:play_with_me/core/data/repositories/firebase_image_storage_repository.dart';
import 'package:play_with_me/core/services/image_picker_service.dart';
import 'package:play_with_me/core/presentation/bloc/user/user_bloc.dart';
import 'package:play_with_me/core/presentation/bloc/group/group_bloc.dart';
import 'package:play_with_me/core/presentation/bloc/game/game_bloc.dart';
import 'package:play_with_me/features/profile/data/repositories/locale_preferences_repository_impl.dart';
import 'package:play_with_me/features/profile/domain/repositories/locale_preferences_repository.dart';

final GetIt sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // Firebase service is initialized statically, no need to register

  // Register SharedPreferences
  if (!sl.isRegistered<SharedPreferences>()) {
    final sharedPreferences = await SharedPreferences.getInstance();
    sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  }

  // Register Firestore
  if (!sl.isRegistered<FirebaseFirestore>()) {
    sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  }

  // Register repositories only if not already registered
  if (!sl.isRegistered<AuthRepository>()) {
    sl.registerLazySingleton<AuthRepository>(
      () => FirebaseAuthRepository(),
    );
  }

  // Register core data repositories
  if (!sl.isRegistered<UserRepository>()) {
    sl.registerLazySingleton<UserRepository>(
      () => FirestoreUserRepository(),
    );
  }

  if (!sl.isRegistered<GroupRepository>()) {
    sl.registerLazySingleton<GroupRepository>(
      () => FirestoreGroupRepository(),
    );
  }

  if (!sl.isRegistered<GameRepository>()) {
    sl.registerLazySingleton<GameRepository>(
      () => FirestoreGameRepository(),
    );
  }

  if (!sl.isRegistered<ImageStorageRepository>()) {
    sl.registerLazySingleton<ImageStorageRepository>(
      () => FirebaseImageStorageRepository(),
    );
  }

  if (!sl.isRegistered<LocalePreferencesRepository>()) {
    sl.registerLazySingleton<LocalePreferencesRepository>(
      () => LocalePreferencesRepositoryImpl(
        sharedPreferences: sl(),
        firestore: sl(),
      ),
    );
  }

  // Register services
  if (!sl.isRegistered<ImagePickerService>()) {
    sl.registerLazySingleton<ImagePickerService>(
      () => ImagePickerService(),
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

  // Register core BLoCs only if not already registered
  if (!sl.isRegistered<UserBloc>()) {
    sl.registerFactory<UserBloc>(
      () => UserBloc(userRepository: sl()),
    );
  }

  if (!sl.isRegistered<GroupBloc>()) {
    sl.registerFactory<GroupBloc>(
      () => GroupBloc(groupRepository: sl()),
    );
  }

  if (!sl.isRegistered<GameBloc>()) {
    sl.registerFactory<GameBloc>(
      () => GameBloc(gameRepository: sl()),
    );
  }
}