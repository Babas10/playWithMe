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
  final bool isRetryable;

  const ErrorState({
    required this.message,
    this.errorCode,
    this.isRetryable = true,
  });

  @override
  List<Object?> get props => [message, errorCode, isRetryable];
}

abstract class InitialState extends BaseBlocState {
  const InitialState();
}