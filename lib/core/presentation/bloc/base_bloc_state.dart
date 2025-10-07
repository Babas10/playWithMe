import 'package:equatable/equatable.dart';

abstract class BaseBlocState extends Equatable {
  const BaseBlocState();

  @override
  List<Object?> get props => [];
}

abstract class LoadingState extends BaseBlocState {
  const LoadingState();
}

abstract class SuccessState extends BaseBlocState {
  const SuccessState();
}

abstract class ErrorState extends BaseBlocState {
  final String message;
  final String? errorCode;

  const ErrorState({
    required this.message,
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, errorCode];
}

abstract class InitialState extends BaseBlocState {
  const InitialState();
}