import 'package:equatable/equatable.dart';

abstract class BaseBlocEvent extends Equatable {
  const BaseBlocEvent();

  @override
  List<Object?> get props => [];
}

abstract class LoadEvent extends BaseBlocEvent {
  const LoadEvent();
}

abstract class RefreshEvent extends BaseBlocEvent {
  const RefreshEvent();
}

abstract class CreateEvent extends BaseBlocEvent {
  const CreateEvent();
}

abstract class UpdateEvent extends BaseBlocEvent {
  const UpdateEvent();
}

abstract class DeleteEvent extends BaseBlocEvent {
  const DeleteEvent();
}