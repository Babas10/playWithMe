import 'package:equatable/equatable.dart';
import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object?> get props => [];
}

/// Initial state when authentication state is unknown
class AuthenticationUnknown extends AuthenticationState {
  const AuthenticationUnknown();
}

/// State when user is authenticated
class AuthenticationAuthenticated extends AuthenticationState {
  const AuthenticationAuthenticated(this.user);

  final UserEntity user;

  @override
  List<Object?> get props => [user];
}

/// State when user is not authenticated
class AuthenticationUnauthenticated extends AuthenticationState {
  const AuthenticationUnauthenticated();
}