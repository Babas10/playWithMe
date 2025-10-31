import '../base_bloc_state.dart';
import '../../../data/models/group_model.dart';

abstract class GroupState extends BaseBlocState {
  const GroupState();
}

class GroupInitial extends GroupState implements InitialState {
  const GroupInitial();
}

class GroupLoading extends GroupState implements LoadingState {
  const GroupLoading();
}

class GroupLoaded extends GroupState implements SuccessState {
  final GroupModel group;

  const GroupLoaded({required this.group});

  @override
  List<Object?> get props => [group];
}

class GroupsLoaded extends GroupState implements SuccessState {
  final List<GroupModel> groups;

  const GroupsLoaded({required this.groups});

  @override
  List<Object?> get props => [groups];
}

class GroupCreated extends GroupState implements SuccessState {
  final String groupId;
  final GroupModel group;

  const GroupCreated({
    required this.groupId,
    required this.group,
  });

  @override
  List<Object?> get props => [groupId, group];
}

class GroupUpdated extends GroupState implements SuccessState {
  final GroupModel group;
  final String message;

  const GroupUpdated({
    required this.group,
    required this.message,
  });

  @override
  List<Object?> get props => [group, message];
}

class GroupOperationSuccess extends GroupState implements SuccessState {
  final String message;

  const GroupOperationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class GroupStatsLoaded extends GroupState implements SuccessState {
  final Map<String, dynamic> stats;

  const GroupStatsLoaded({required this.stats});

  @override
  List<Object?> get props => [stats];
}

class GroupError extends GroupState implements ErrorState {
  @override
  final String message;
  @override
  final String? errorCode;
  @override
  final bool isRetryable;

  const GroupError({
    required this.message,
    this.errorCode,
    this.isRetryable = true,
  });

  @override
  List<Object?> get props => [message, errorCode, isRetryable];
}

class GroupNotFound extends GroupState implements ErrorState {
  @override
  final String message;
  @override
  final String? errorCode;
  @override
  final bool isRetryable;

  const GroupNotFound({
    this.message = 'Group not found',
    this.errorCode,
    this.isRetryable = false,
  });

  @override
  List<Object?> get props => [message, errorCode, isRetryable];
}