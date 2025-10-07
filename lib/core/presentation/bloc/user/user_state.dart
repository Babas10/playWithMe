import '../base_bloc_state.dart';
import '../../../data/models/user_model.dart';

abstract class UserState extends BaseBlocState {
  const UserState();
}

class UserInitial extends UserState implements InitialState {
  const UserInitial();
}

class UserLoading extends UserState implements LoadingState {
  const UserLoading();
}

class UserLoaded extends UserState implements SuccessState {
  final UserModel user;

  const UserLoaded({required this.user});

  @override
  List<Object?> get props => [user];
}

class UsersLoaded extends UserState implements SuccessState {
  final List<UserModel> users;

  const UsersLoaded({required this.users});

  @override
  List<Object?> get props => [users];
}

class UserUpdated extends UserState implements SuccessState {
  final UserModel user;
  final String message;

  const UserUpdated({
    required this.user,
    required this.message,
  });

  @override
  List<Object?> get props => [user, message];
}

class UserOperationSuccess extends UserState implements SuccessState {
  final String message;

  const UserOperationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class UserError extends UserState implements ErrorState {
  @override
  final String message;
  @override
  final String? errorCode;

  const UserError({
    required this.message,
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, errorCode];
}

class UserNotFound extends UserState implements ErrorState {
  @override
  final String message;
  @override
  final String? errorCode;

  const UserNotFound({
    this.message = 'User not found',
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, errorCode];
}