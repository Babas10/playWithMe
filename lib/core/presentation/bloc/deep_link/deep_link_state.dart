// States for the DeepLinkBloc.
import 'package:equatable/equatable.dart';

sealed class DeepLinkState extends Equatable {
  const DeepLinkState();

  @override
  List<Object?> get props => [];
}

class DeepLinkInitial extends DeepLinkState {
  const DeepLinkInitial();
}

class DeepLinkPendingInvite extends DeepLinkState {
  final String token;

  const DeepLinkPendingInvite({required this.token});

  @override
  List<Object?> get props => [token];
}

class DeepLinkNoInvite extends DeepLinkState {
  const DeepLinkNoInvite();
}
