// Widget displaying the in-game chat section with real-time messages and send input.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:play_with_me/core/data/models/chat_message_model.dart';
import 'package:play_with_me/core/domain/repositories/game_repository.dart';
import 'package:play_with_me/core/services/service_locator.dart';
import 'package:play_with_me/core/theme/app_colors.dart';
import 'package:play_with_me/l10n/app_localizations.dart';
import '../bloc/game_chat/game_chat_bloc.dart';
import '../bloc/game_chat/game_chat_event.dart';
import '../bloc/game_chat/game_chat_state.dart';

class GameChatSection extends StatelessWidget {
  final String gameId;
  final String currentUserId;
  final String currentUserDisplayName;
  final bool isPlayer;
  final GameRepository? gameRepository;

  const GameChatSection({
    super.key,
    required this.gameId,
    required this.currentUserId,
    required this.currentUserDisplayName,
    required this.isPlayer,
    this.gameRepository,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GameChatBloc(
        gameRepository: gameRepository ?? sl<GameRepository>(),
      )..add(LoadGameChat(gameId: gameId)),
      child: _GameChatView(
        gameId: gameId,
        currentUserId: currentUserId,
        currentUserDisplayName: currentUserDisplayName,
        isPlayer: isPlayer,
      ),
    );
  }
}

class _GameChatView extends StatefulWidget {
  final String gameId;
  final String currentUserId;
  final String currentUserDisplayName;
  final bool isPlayer;

  const _GameChatView({
    required this.gameId,
    required this.currentUserId,
    required this.currentUserDisplayName,
    required this.isPlayer,
  });

  @override
  State<_GameChatView> createState() => _GameChatViewState();
}

class _GameChatViewState extends State<_GameChatView> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(BuildContext context) {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    context.read<GameChatBloc>().add(
      SendChatMessage(
        gameId: widget.gameId,
        senderId: widget.currentUserId,
        senderDisplayName: widget.currentUserDisplayName,
        text: text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.chat_bubble_outline,
                  color: AppColors.secondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.chatSectionTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            BlocConsumer<GameChatBloc, GameChatState>(
              listener: (context, state) {
                if (state is GameChatLoaded) {
                  _scrollToBottom();
                }
              },
              builder: (context, state) {
                if (state is GameChatLoading || state is GameChatInitial) {
                  return const SizedBox(
                    height: 120,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final messages = state is GameChatLoaded
                    ? state.messages
                    : <ChatMessageModel>[];
                final isSending =
                    state is GameChatLoaded ? state.isSending : false;

                return Column(
                  children: [
                    SizedBox(
                      height: 240,
                      child: messages.isEmpty
                          ? Center(
                              child: Text(
                                l10n.chatEmpty,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textMuted,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              itemCount: messages.length,
                              itemBuilder: (context, index) => _MessageBubble(
                                message: messages[index],
                                isCurrentUser:
                                    messages[index].senderId ==
                                    widget.currentUserId,
                              ),
                            ),
                    ),
                    const SizedBox(height: 8),
                    if (widget.isPlayer)
                      _ChatInput(
                        controller: _textController,
                        isSending: isSending,
                        onSend: () => _sendMessage(context),
                        hint: l10n.chatInputHint,
                      )
                    else
                      Text(
                        l10n.chatPlayersOnly,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool isCurrentUser;

  const _MessageBubble({required this.message, required this.isCurrentUser});

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Align(
        alignment:
            isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: isCurrentUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (!isCurrentUser)
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 2),
                child: Text(
                  message.senderDisplayName,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            Row(
              mainAxisAlignment: isCurrentUser
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!isCurrentUser) const SizedBox(width: 4),
                Flexible(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.65,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isCurrentUser
                          ? AppColors.secondary
                          : AppColors.divider,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isCurrentUser ? 16 : 4),
                        bottomRight: Radius.circular(isCurrentUser ? 4 : 16),
                      ),
                    ),
                    child: Text(
                      message.text,
                      style: TextStyle(
                        color: isCurrentUser
                            ? Colors.white
                            : AppColors.onSurface,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  timeFormat.format(message.sentAt),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;
  final String hint;

  const _ChatInput({
    required this.controller,
    required this.isSending,
    required this.onSend,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.textMuted),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              isDense: true,
            ),
            maxLines: null,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => onSend(),
            enabled: !isSending,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: isSending ? null : onSend,
          icon: isSending
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.send),
          color: AppColors.secondary,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: const CircleBorder(),
          ),
        ),
      ],
    );
  }
}
