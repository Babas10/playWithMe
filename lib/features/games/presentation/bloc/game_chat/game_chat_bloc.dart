// Manages real-time in-game chat messages and send actions.
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/core/domain/exceptions/repository_exceptions.dart';
import 'package:play_with_me/core/domain/repositories/game_repository.dart';
import 'game_chat_event.dart';
import 'game_chat_state.dart';

class GameChatBloc extends Bloc<GameChatEvent, GameChatState> {
  final GameRepository _gameRepository;
  StreamSubscription<dynamic>? _messagesSubscription;

  GameChatBloc({required GameRepository gameRepository})
      : _gameRepository = gameRepository,
        super(const GameChatInitial()) {
    on<LoadGameChat>(_onLoadGameChat);
    on<GameChatMessagesUpdated>(_onMessagesUpdated);
    on<SendChatMessage>(_onSendChatMessage);
  }

  Future<void> _onLoadGameChat(
    LoadGameChat event,
    Emitter<GameChatState> emit,
  ) async {
    emit(const GameChatLoading());
    await _messagesSubscription?.cancel();
    _messagesSubscription = _gameRepository.getMessages(event.gameId).listen(
      (messages) => add(GameChatMessagesUpdated(messages: messages)),
      onError: (_) => add(const GameChatMessagesUpdated(messages: [])),
    );
  }

  void _onMessagesUpdated(
    GameChatMessagesUpdated event,
    Emitter<GameChatState> emit,
  ) {
    final isSending =
        state is GameChatLoaded ? (state as GameChatLoaded).isSending : false;
    emit(GameChatLoaded(messages: event.messages, isSending: isSending));
  }

  Future<void> _onSendChatMessage(
    SendChatMessage event,
    Emitter<GameChatState> emit,
  ) async {
    if (state is! GameChatLoaded) return;
    final current = state as GameChatLoaded;
    emit(current.copyWith(isSending: true));
    try {
      await _gameRepository.sendMessage(
        gameId: event.gameId,
        senderId: event.senderId,
        senderDisplayName: event.senderDisplayName,
        text: event.text,
      );
      // Stream will update messages; just clear sending flag
      emit(current.copyWith(isSending: false));
    } on GameException catch (e) {
      emit(current.copyWith(isSending: false));
      // Don't emit error — just restore state (snackbar handled in widget)
      addError(Exception(e.message));
    } catch (e) {
      emit(current.copyWith(isSending: false));
      addError(e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
