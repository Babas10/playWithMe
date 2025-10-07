import '../base_bloc_event.dart';
import '../../../data/models/user_model.dart';

abstract class UserEvent extends BaseBlocEvent {
  const UserEvent();
}

class LoadCurrentUser extends UserEvent {
  const LoadCurrentUser();
}

class LoadUserById extends UserEvent {
  final String uid;

  const LoadUserById({required this.uid});

  @override
  List<Object?> get props => [uid];
}

class UpdateUserProfile extends UserEvent {
  final String uid;
  final String? displayName;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? location;
  final String? bio;
  final DateTime? dateOfBirth;

  const UpdateUserProfile({
    required this.uid,
    this.displayName,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.location,
    this.bio,
    this.dateOfBirth,
  });

  @override
  List<Object?> get props => [
        uid,
        displayName,
        firstName,
        lastName,
        phoneNumber,
        location,
        bio,
        dateOfBirth,
      ];
}

class UpdateUserPreferences extends UserEvent {
  final String uid;
  final bool? notificationsEnabled;
  final bool? emailNotifications;
  final bool? pushNotifications;

  const UpdateUserPreferences({
    required this.uid,
    this.notificationsEnabled,
    this.emailNotifications,
    this.pushNotifications,
  });

  @override
  List<Object?> get props => [
        uid,
        notificationsEnabled,
        emailNotifications,
        pushNotifications,
      ];
}

class UpdateUserPrivacy extends UserEvent {
  final String uid;
  final UserPrivacyLevel? privacyLevel;
  final bool? showEmail;
  final bool? showPhoneNumber;

  const UpdateUserPrivacy({
    required this.uid,
    this.privacyLevel,
    this.showEmail,
    this.showPhoneNumber,
  });

  @override
  List<Object?> get props => [uid, privacyLevel, showEmail, showPhoneNumber];
}

class JoinGroup extends UserEvent {
  final String uid;
  final String groupId;

  const JoinGroup({
    required this.uid,
    required this.groupId,
  });

  @override
  List<Object?> get props => [uid, groupId];
}

class LeaveGroup extends UserEvent {
  final String uid;
  final String groupId;

  const LeaveGroup({
    required this.uid,
    required this.groupId,
  });

  @override
  List<Object?> get props => [uid, groupId];
}

class SearchUsers extends UserEvent {
  final String query;
  final int limit;

  const SearchUsers({
    required this.query,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [query, limit];
}

class DeleteUser extends UserEvent {
  final String uid;

  const DeleteUser({required this.uid});

  @override
  List<Object?> get props => [uid];
}