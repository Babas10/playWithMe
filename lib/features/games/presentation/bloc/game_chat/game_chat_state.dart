// States for GameChatBloc managing in-game chat.
import 'package:equatable/equatable.dart';
import 'package:play_with_me/core/data/models/chat_message_model.dart';

abstract class GameChatState extends Equatable {
  const GameChatState();
  @override
  List<Object?> get props => [];
}

class GameChatInitial extends GameChatState {
  const GameChatInitial();
}

class GameChatLoading extends GameChatState {
  const GameChatLoading();
}

class GameChatLoaded extends GameChatState {
  final List<ChatMessageModel> messages;
  final bool isSending;

  const GameChatLoaded({required this.messages, this.isSending = false});

  @override
  List<Object?> get props => [messages, isSending];

  GameChatLoaded copyWith({List<ChatMessageModel>? messages, bool? isSending}) {
    return GameChatLoaded(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
    );
  }
}

class GameChatError extends GameChatState {
  final String message;
  const GameChatError({required this.message});
  @override
  List<Object?> get props => [message];
}
