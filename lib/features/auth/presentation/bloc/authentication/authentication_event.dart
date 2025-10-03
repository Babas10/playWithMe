import 'package:equatable/equatable.dart';
import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object?> get props => [];
}

/// Event to start monitoring authentication state
class AuthenticationStarted extends AuthenticationEvent {
  const AuthenticationStarted();
}

/// Event when authentication state changes
class AuthenticationUserChanged extends AuthenticationEvent {
  const AuthenticationUserChanged(this.user);

  final UserEntity? user;

  @override
  List<Object?> get props => [user];
}

/// Event to log out the user
class AuthenticationLogoutRequested extends AuthenticationEvent {
  const AuthenticationLogoutRequested();
}