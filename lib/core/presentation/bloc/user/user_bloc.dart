import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/user_repository.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _userRepository;
  StreamSubscription<dynamic>? _userSubscription;

  UserBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(const UserInitial()) {
    on<LoadCurrentUser>(_onLoadCurrentUser);
    on<LoadUserById>(_onLoadUserById);
    on<UpdateUserProfile>(_onUpdateUserProfile);
    on<UpdateUserPreferences>(_onUpdateUserPreferences);
    on<UpdateUserPrivacy>(_onUpdateUserPrivacy);
    on<JoinGroup>(_onJoinGroup);
    on<LeaveGroup>(_onLeaveGroup);
    on<SearchUsers>(_onSearchUsers);
    on<DeleteUser>(_onDeleteUser);
  }

  Future<void> _onLoadCurrentUser(
    LoadCurrentUser event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(const UserLoading());

      await _userSubscription?.cancel();
      _userSubscription = _userRepository.currentUser.listen(
        (user) {
          if (user != null) {
            emit(UserLoaded(user: user));
          } else {
            emit(const UserNotFound(message: 'No current user found'));
          }
        },
        onError: (error) {
          emit(UserError(
            message: 'Failed to load current user: ${error.toString()}',
            errorCode: 'CURRENT_USER_ERROR',
          ));
        },
      );
    } catch (e) {
      emit(UserError(
        message: 'Failed to load current user: ${e.toString()}',
        errorCode: 'CURRENT_USER_ERROR',
      ));
    }
  }

  Future<void> _onLoadUserById(
    LoadUserById event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(const UserLoading());

      final user = await _userRepository.getUserById(event.uid);
      if (user != null) {
        emit(UserLoaded(user: user));
      } else {
        emit(const UserNotFound(message: 'User not found'));
      }
    } catch (e) {
      emit(UserError(
        message: 'Failed to load user: ${e.toString()}',
        errorCode: 'LOAD_USER_ERROR',
      ));
    }
  }

  Future<void> _onUpdateUserProfile(
    UpdateUserProfile event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(const UserLoading());

      await _userRepository.updateUserProfile(
        event.uid,
        displayName: event.displayName,
        firstName: event.firstName,
        lastName: event.lastName,
        phoneNumber: event.phoneNumber,
        location: event.location,
        bio: event.bio,
        dateOfBirth: event.dateOfBirth,
      );

      // Load updated user
      final updatedUser = await _userRepository.getUserById(event.uid);
      if (updatedUser != null) {
        emit(UserUpdated(
          user: updatedUser,
          message: 'Profile updated successfully',
        ));
      } else {
        emit(const UserError(
          message: 'Failed to load updated profile',
          errorCode: 'UPDATE_PROFILE_ERROR',
        ));
      }
    } catch (e) {
      emit(UserError(
        message: 'Failed to update profile: ${e.toString()}',
        errorCode: 'UPDATE_PROFILE_ERROR',
      ));
    }
  }

  Future<void> _onUpdateUserPreferences(
    UpdateUserPreferences event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(const UserLoading());

      await _userRepository.updateUserPreferences(
        event.uid,
        notificationsEnabled: event.notificationsEnabled,
        emailNotifications: event.emailNotifications,
        pushNotifications: event.pushNotifications,
      );

      final updatedUser = await _userRepository.getUserById(event.uid);
      if (updatedUser != null) {
        emit(UserUpdated(
          user: updatedUser,
          message: 'Preferences updated successfully',
        ));
      } else {
        emit(const UserError(
          message: 'Failed to load updated preferences',
          errorCode: 'UPDATE_PREFERENCES_ERROR',
        ));
      }
    } catch (e) {
      emit(UserError(
        message: 'Failed to update preferences: ${e.toString()}',
        errorCode: 'UPDATE_PREFERENCES_ERROR',
      ));
    }
  }

  Future<void> _onUpdateUserPrivacy(
    UpdateUserPrivacy event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(const UserLoading());

      await _userRepository.updateUserPrivacy(
        event.uid,
        privacyLevel: event.privacyLevel,
        showEmail: event.showEmail,
        showPhoneNumber: event.showPhoneNumber,
      );

      final updatedUser = await _userRepository.getUserById(event.uid);
      if (updatedUser != null) {
        emit(UserUpdated(
          user: updatedUser,
          message: 'Privacy settings updated successfully',
        ));
      } else {
        emit(const UserError(
          message: 'Failed to load updated privacy settings',
          errorCode: 'UPDATE_PRIVACY_ERROR',
        ));
      }
    } catch (e) {
      emit(UserError(
        message: 'Failed to update privacy settings: ${e.toString()}',
        errorCode: 'UPDATE_PRIVACY_ERROR',
      ));
    }
  }

  Future<void> _onJoinGroup(
    JoinGroup event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(const UserLoading());

      await _userRepository.joinGroup(event.uid, event.groupId);

      final updatedUser = await _userRepository.getUserById(event.uid);
      if (updatedUser != null) {
        emit(UserUpdated(
          user: updatedUser,
          message: 'Successfully joined group',
        ));
      } else {
        emit(const UserOperationSuccess(
          message: 'Successfully joined group',
        ));
      }
    } catch (e) {
      emit(UserError(
        message: 'Failed to join group: ${e.toString()}',
        errorCode: 'JOIN_GROUP_ERROR',
      ));
    }
  }

  Future<void> _onLeaveGroup(
    LeaveGroup event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(const UserLoading());

      await _userRepository.leaveGroup(event.uid, event.groupId);

      final updatedUser = await _userRepository.getUserById(event.uid);
      if (updatedUser != null) {
        emit(UserUpdated(
          user: updatedUser,
          message: 'Successfully left group',
        ));
      } else {
        emit(const UserOperationSuccess(
          message: 'Successfully left group',
        ));
      }
    } catch (e) {
      emit(UserError(
        message: 'Failed to leave group: ${e.toString()}',
        errorCode: 'LEAVE_GROUP_ERROR',
      ));
    }
  }

  Future<void> _onSearchUsers(
    SearchUsers event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(const UserLoading());

      final users = await _userRepository.searchUsers(
        event.query,
        limit: event.limit,
      );

      emit(UsersLoaded(users: users));
    } catch (e) {
      emit(UserError(
        message: 'Failed to search users: ${e.toString()}',
        errorCode: 'SEARCH_USERS_ERROR',
      ));
    }
  }

  Future<void> _onDeleteUser(
    DeleteUser event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(const UserLoading());

      await _userRepository.deleteUser(event.uid);

      emit(const UserOperationSuccess(
        message: 'User account deleted successfully',
      ));
    } catch (e) {
      emit(UserError(
        message: 'Failed to delete user: ${e.toString()}',
        errorCode: 'DELETE_USER_ERROR',
      ));
    }
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}