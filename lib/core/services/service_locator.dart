import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
import 'package:play_with_me/core/domain/repositories/training_session_repository.dart';
import 'package:play_with_me/core/domain/repositories/exercise_repository.dart';
import 'package:play_with_me/core/domain/repositories/training_feedback_repository.dart';
import 'package:play_with_me/core/domain/repositories/image_storage_repository.dart';
import 'package:play_with_me/core/domain/repositories/invitation_repository.dart';
import 'package:play_with_me/core/domain/repositories/friend_repository.dart';
import 'package:play_with_me/core/domain/repositories/group_invite_link_repository.dart';
import 'package:play_with_me/core/data/repositories/firestore_user_repository.dart';
import 'package:play_with_me/core/data/repositories/firestore_group_repository.dart';
import 'package:play_with_me/core/data/repositories/firestore_game_repository.dart';
import 'package:play_with_me/core/data/repositories/firestore_training_session_repository.dart';
import 'package:play_with_me/core/data/repositories/firestore_exercise_repository.dart';
import 'package:play_with_me/core/data/repositories/firestore_training_feedback_repository.dart';
import 'package:play_with_me/core/data/repositories/firebase_image_storage_repository.dart';
import 'package:play_with_me/core/data/repositories/firestore_invitation_repository.dart';
import 'package:play_with_me/core/data/repositories/firestore_friend_repository.dart';
import 'package:play_with_me/core/data/repositories/firestore_group_invite_link_repository.dart';
import 'package:play_with_me/core/services/image_picker_service.dart';
import 'package:play_with_me/core/presentation/bloc/user/user_bloc.dart';
import 'package:play_with_me/core/presentation/bloc/group/group_bloc.dart';
import 'package:play_with_me/core/presentation/bloc/game/game_bloc.dart';
import 'package:play_with_me/core/presentation/bloc/invitation/invitation_bloc.dart';
import 'package:play_with_me/core/presentation/bloc/group_member/group_member_bloc.dart';
import 'package:play_with_me/features/profile/data/repositories/locale_preferences_repository_impl.dart';
import 'package:play_with_me/features/profile/domain/repositories/locale_preferences_repository.dart';
import 'package:play_with_me/features/notifications/data/repositories/firestore_notification_repository.dart';
import 'package:play_with_me/features/notifications/data/services/notification_service.dart';
import 'package:play_with_me/features/notifications/domain/repositories/notification_repository.dart';
import 'package:play_with_me/features/friends/presentation/bloc/friend_bloc.dart';
import 'package:play_with_me/features/friends/presentation/bloc/friend_request_count_bloc.dart';
import 'package:play_with_me/features/games/presentation/bloc/game_creation/game_creation_bloc.dart';
import 'package:play_with_me/features/games/presentation/bloc/game_details/game_details_bloc.dart';
import 'package:play_with_me/features/games/presentation/bloc/games_list/games_list_bloc.dart';
import 'package:play_with_me/features/training/presentation/bloc/training_session_creation/training_session_creation_bloc.dart';
import 'package:play_with_me/features/training/presentation/bloc/training_session_participation/training_session_participation_bloc.dart';
import 'package:play_with_me/features/training/presentation/bloc/exercise/exercise_bloc.dart';
import 'package:play_with_me/features/training/presentation/bloc/feedback/training_feedback_bloc.dart';
import 'package:play_with_me/features/groups/presentation/bloc/group_invite_link/group_invite_link_bloc.dart';
import 'package:play_with_me/core/services/pending_invite_storage.dart';
import 'package:play_with_me/core/services/deep_link_service.dart';
import 'package:play_with_me/core/services/app_links_deep_link_service.dart';
import 'package:play_with_me/core/presentation/bloc/deep_link/deep_link_bloc.dart';
import 'package:play_with_me/features/invitations/presentation/bloc/invite_join/invite_join_bloc.dart';
import 'package:play_with_me/features/invitations/presentation/bloc/invite_registration/invite_registration_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // Firebase service is initialized statically, no need to register

  // Register SharedPreferences
  if (!sl.isRegistered<SharedPreferences>()) {
    final sharedPreferences = await SharedPreferences.getInstance();
    sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  }

  // Register Firestore with offline persistence enabled
  if (!sl.isRegistered<FirebaseFirestore>()) {
    sl.registerLazySingleton<FirebaseFirestore>(() {
      final firestore = FirebaseFirestore.instance;
      // Configure offline persistence (will only apply on first access)
      try {
        firestore.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        );
      } catch (e) {
        // Settings can only be set once before first Firestore operation
        // If it fails, we can safely ignore as it's already configured
      }
      return firestore;
    });
  }

  if (!sl.isRegistered<FirebaseAuth>()) {
    sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  }

  if (!sl.isRegistered<FirebaseMessaging>()) {
    sl.registerLazySingleton<FirebaseMessaging>(() => FirebaseMessaging.instance);
  }

  if (!sl.isRegistered<FirebaseFunctions>()) {
    sl.registerLazySingleton<FirebaseFunctions>(() => FirebaseFunctions.instance);
  }

  if (!sl.isRegistered<FlutterLocalNotificationsPlugin>()) {
    sl.registerLazySingleton<FlutterLocalNotificationsPlugin>(
      () => FlutterLocalNotificationsPlugin(),
    );
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

  if (!sl.isRegistered<TrainingSessionRepository>()) {
    sl.registerLazySingleton<TrainingSessionRepository>(
      () => FirestoreTrainingSessionRepository(
        groupRepository: sl(),
      ),
    );
  }

  if (!sl.isRegistered<ExerciseRepository>()) {
    sl.registerLazySingleton<ExerciseRepository>(
      () => FirestoreExerciseRepository(
        trainingSessionRepository: sl(),
      ),
    );
  }

  if (!sl.isRegistered<TrainingFeedbackRepository>()) {
    sl.registerLazySingleton<TrainingFeedbackRepository>(
      () => FirestoreTrainingFeedbackRepository(),
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

  if (!sl.isRegistered<InvitationRepository>()) {
    sl.registerLazySingleton<InvitationRepository>(
      () => FirestoreInvitationRepository(
        groupRepository: sl(),
      ),
    );
  }

  if (!sl.isRegistered<NotificationRepository>()) {
    sl.registerLazySingleton<NotificationRepository>(
      () => FirestoreNotificationRepository(
        firestore: sl(),
        auth: sl(),
      ),
    );
  }

  if (!sl.isRegistered<FriendRepository>()) {
    sl.registerLazySingleton<FriendRepository>(
      () => FirestoreFriendRepository(
        functions: sl(),
        firestore: sl(),
        auth: sl(),
      ),
    );
  }

  if (!sl.isRegistered<GroupInviteLinkRepository>()) {
    sl.registerLazySingleton<GroupInviteLinkRepository>(
      () => FirestoreGroupInviteLinkRepository(
        functions: sl(),
      ),
    );
  }

  // Register services
  if (!sl.isRegistered<ImagePickerService>()) {
    sl.registerLazySingleton<ImagePickerService>(
      () => ImagePickerService(),
    );
  }

  if (!sl.isRegistered<NotificationService>()) {
    sl.registerLazySingleton<NotificationService>(
      () => NotificationService(
        fcm: sl(),
        localNotifications: sl(),
        firestore: sl(),
        auth: sl(),
      ),
    );
  }

  if (!sl.isRegistered<PendingInviteStorage>()) {
    sl.registerLazySingleton<PendingInviteStorage>(
      () => PendingInviteStorage(prefs: sl()),
    );
  }

  if (!sl.isRegistered<DeepLinkService>()) {
    sl.registerLazySingleton<DeepLinkService>(
      () => AppLinksDeepLinkService(),
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
      () => RegistrationBloc(
        authRepository: sl(),
      ),
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
      () => GroupBloc(
        groupRepository: sl(),
        invitationRepository: sl(),
      ),
    );
  }

  if (!sl.isRegistered<GameBloc>()) {
    sl.registerFactory<GameBloc>(
      () => GameBloc(gameRepository: sl()),
    );
  }

  if (!sl.isRegistered<InvitationBloc>()) {
    sl.registerFactory<InvitationBloc>(
      () => InvitationBloc(invitationRepository: sl()),
    );
  }

  if (!sl.isRegistered<GroupMemberBloc>()) {
    sl.registerFactory<GroupMemberBloc>(
      () => GroupMemberBloc(groupRepository: sl()),
    );
  }

  if (!sl.isRegistered<FriendBloc>()) {
    sl.registerFactory<FriendBloc>(
      () => FriendBloc(
        friendRepository: sl(),
        authRepository: sl(),
      ),
    );
  }

  if (!sl.isRegistered<FriendRequestCountBloc>()) {
    sl.registerFactory<FriendRequestCountBloc>(
      () => FriendRequestCountBloc(
        friendRepository: sl(),
      ),
    );
  }

  if (!sl.isRegistered<GameCreationBloc>()) {
    sl.registerFactory<GameCreationBloc>(
      () => GameCreationBloc(gameRepository: sl()),
    );
  }

  if (!sl.isRegistered<GameDetailsBloc>()) {
    sl.registerFactory<GameDetailsBloc>(
      () => GameDetailsBloc(
        gameRepository: sl(),
        userRepository: sl(),
      ),
    );
  }

  if (!sl.isRegistered<GamesListBloc>()) {
    sl.registerFactory<GamesListBloc>(
      () => GamesListBloc(
        gameRepository: sl(),
        trainingSessionRepository: sl(),
      ),
    );
  }

  if (!sl.isRegistered<TrainingSessionCreationBloc>()) {
    sl.registerFactory<TrainingSessionCreationBloc>(
      () => TrainingSessionCreationBloc(
        trainingSessionRepository: sl(),
      ),
    );
  }

  if (!sl.isRegistered<ExerciseBloc>()) {
    sl.registerFactory<ExerciseBloc>(
      () => ExerciseBloc(
        exerciseRepository: sl(),
      ),
    );
  }

  if (!sl.isRegistered<TrainingFeedbackBloc>()) {
    sl.registerFactory<TrainingFeedbackBloc>(
      () => TrainingFeedbackBloc(
        feedbackRepository: sl(),
      ),
    );
  }

  if (!sl.isRegistered<TrainingSessionParticipationBloc>()) {
    sl.registerFactory<TrainingSessionParticipationBloc>(
      () => TrainingSessionParticipationBloc(
        trainingSessionRepository: sl(),
      ),
    );
  }

  if (!sl.isRegistered<GroupInviteLinkBloc>()) {
    sl.registerFactory<GroupInviteLinkBloc>(
      () => GroupInviteLinkBloc(repository: sl()),
    );
  }

  if (!sl.isRegistered<InviteRegistrationBloc>()) {
    sl.registerFactory<InviteRegistrationBloc>(
      () => InviteRegistrationBloc(
        authRepository: sl(),
        groupInviteLinkRepository: sl(),
        pendingInviteStorage: sl(),
      ),
    );
  }

  if (!sl.isRegistered<InviteJoinBloc>()) {
    sl.registerFactory<InviteJoinBloc>(
      () => InviteJoinBloc(
        repository: sl(),
        pendingInviteStorage: sl(),
      ),
    );
  }

  if (!sl.isRegistered<DeepLinkBloc>()) {
    sl.registerFactory<DeepLinkBloc>(
      () => DeepLinkBloc(
        deepLinkService: sl(),
        pendingInviteStorage: sl(),
      ),
    );
  }
}