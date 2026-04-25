// Events for GameChatBloc managing in-game chat.
import 'package:equatable/equatable.dart';
import 'package:play_with_me/core/data/models/chat_message_model.dart';

abstract class GameChatEvent extends Equatable {
  const GameChatEvent();
  @override
  List<Object?> get props => [];
}

class LoadGameChat extends GameChatEvent {
  final String gameId;
  const LoadGameChat({required this.gameId});
  @override
  List<Object?> get props => [gameId];
}

class GameChatMessagesUpdated extends GameChatEvent {
  final List<ChatMessageModel> messages;
  const GameChatMessagesUpdated({required this.messages});
  @override
  List<Object?> get props => [messages];
}

class SendChatMessage extends GameChatEvent {
  final String gameId;
  final String senderId;
  final String senderDisplayName;
  final String text;
  const SendChatMessage({
    required this.gameId,
    required this.senderId,
    required this.senderDisplayName,
    required this.text,
  });
  @override
  List<Object?> get props => [gameId, senderId, senderDisplayName, text];
}
