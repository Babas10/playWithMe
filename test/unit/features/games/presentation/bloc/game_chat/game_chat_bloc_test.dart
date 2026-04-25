// Validates GameChatBloc state transitions for chat loading and sending.
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/data/models/chat_message_model.dart';
import 'package:play_with_me/core/domain/repositories/game_repository.dart';
import 'package:play_with_me/features/games/presentation/bloc/game_chat/game_chat_bloc.dart';
import 'package:play_with_me/features/games/presentation/bloc/game_chat/game_chat_event.dart';
import 'package:play_with_me/features/games/presentation/bloc/game_chat/game_chat_state.dart';

class MockGameRepository extends Mock implements GameRepository {}

void main() {
  late MockGameRepository mockGameRepository;

  final testMessage = ChatMessageModel(
    id: 'msg-1',
    senderId: 'user-1',
    senderDisplayName: 'Alice',
    text: 'Hello!',
    sentAt: DateTime(2025, 1, 1, 12, 0),
  );

  setUpAll(() {
    registerFallbackValue(Stream<List<ChatMessageModel>>.empty());
  });

  setUp(() {
    mockGameRepository = MockGameRepository();
  });

  group('GameChatBloc', () {
    group('LoadGameChat', () {
      blocTest<GameChatBloc, GameChatState>(
        'emits [loading, loaded] with messages from stream',
        build: () {
          when(() => mockGameRepository.getMessages('game-1'))
              .thenAnswer((_) => Stream.value([testMessage]));
          return GameChatBloc(gameRepository: mockGameRepository);
        },
        act: (bloc) => bloc.add(const LoadGameChat(gameId: 'game-1')),
        expect: () => [
          const GameChatLoading(),
          GameChatLoaded(messages: [testMessage]),
        ],
      );

      blocTest<GameChatBloc, GameChatState>(
        'emits [loading, loaded with empty list] on stream error',
        build: () {
          when(() => mockGameRepository.getMessages('game-1'))
              .thenAnswer((_) => Stream.error(Exception('error')));
          return GameChatBloc(gameRepository: mockGameRepository);
        },
        act: (bloc) => bloc.add(const LoadGameChat(gameId: 'game-1')),
        expect: () => [
          const GameChatLoading(),
          const GameChatLoaded(messages: []),
        ],
      );
    });

    group('SendChatMessage', () {
      blocTest<GameChatBloc, GameChatState>(
        'sends message and clears isSending flag',
        build: () {
          when(() => mockGameRepository.getMessages('game-1'))
              .thenAnswer((_) => Stream.value([testMessage]));
          when(
            () => mockGameRepository.sendMessage(
              gameId: any(named: 'gameId'),
              senderId: any(named: 'senderId'),
              senderDisplayName: any(named: 'senderDisplayName'),
              text: any(named: 'text'),
            ),
          ).thenAnswer((_) async {});
          return GameChatBloc(gameRepository: mockGameRepository);
        },
        seed: () => GameChatLoaded(messages: [testMessage]),
        act: (bloc) => bloc.add(
          const SendChatMessage(
            gameId: 'game-1',
            senderId: 'user-1',
            senderDisplayName: 'Alice',
            text: 'Hello!',
          ),
        ),
        expect: () => [
          GameChatLoaded(messages: [testMessage], isSending: true),
          GameChatLoaded(messages: [testMessage], isSending: false),
        ],
      );

      blocTest<GameChatBloc, GameChatState>(
        'does nothing when state is not loaded',
        build: () => GameChatBloc(gameRepository: mockGameRepository),
        act: (bloc) => bloc.add(
          const SendChatMessage(
            gameId: 'game-1',
            senderId: 'user-1',
            senderDisplayName: 'Alice',
            text: 'Hello!',
          ),
        ),
        expect: () => [],
      );
    });
  });
}
