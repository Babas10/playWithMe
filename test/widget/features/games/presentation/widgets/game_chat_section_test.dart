// Widget tests for GameChatSection verifying message rendering and send interaction.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/chat_message_model.dart';
import 'package:play_with_me/core/domain/repositories/game_repository.dart';
import 'package:play_with_me/features/games/presentation/widgets/game_chat_section.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

// Minimal fake repository for widget tests — no streams, no Firebase.
class _FakeGameRepository implements GameRepository {
  final List<ChatMessageModel> messages;
  final List<Map<String, String>> sentMessages = [];

  _FakeGameRepository({this.messages = const []});

  @override
  Stream<List<ChatMessageModel>> getMessages(String gameId) =>
      Stream.value(messages);

  @override
  Future<void> sendMessage({
    required String gameId,
    required String senderId,
    required String senderDisplayName,
    required String text,
  }) async {
    sentMessages.add({
      'gameId': gameId,
      'senderId': senderId,
      'senderDisplayName': senderDisplayName,
      'text': text,
    });
  }

  // All other methods throw UnimplementedError — they are not used by GameChatSection.
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError(
        '${invocation.memberName} is not implemented in _FakeGameRepository',
      );
}

Widget _buildWidget({
  required _FakeGameRepository repo,
  bool isPlayer = true,
}) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en')],
    home: Scaffold(
      body: SingleChildScrollView(
        child: GameChatSection(
          gameId: 'game-1',
          currentUserId: 'current-user',
          currentUserDisplayName: 'Alice',
          isPlayer: isPlayer,
          gameRepository: repo,
        ),
      ),
    ),
  );
}

void main() {
  final messageFromOther = ChatMessageModel(
    id: 'msg-1',
    senderId: 'other-user',
    senderDisplayName: 'Bob',
    text: 'Hello team!',
    sentAt: DateTime(2025, 1, 1, 12, 0),
  );

  final messageFromSelf = ChatMessageModel(
    id: 'msg-2',
    senderId: 'current-user',
    senderDisplayName: 'Alice',
    text: 'Ready to play!',
    sentAt: DateTime(2025, 1, 1, 12, 1),
  );

  group('GameChatSection', () {
    testWidgets('shows empty message when no messages', (tester) async {
      final repo = _FakeGameRepository(messages: []);
      await tester.pumpWidget(_buildWidget(repo: repo));
      await tester.pumpAndSettle();
      expect(
        find.text('No messages yet. Be the first to say something!'),
        findsOneWidget,
      );
    });

    testWidgets('renders other user messages', (tester) async {
      final repo = _FakeGameRepository(messages: [messageFromOther]);
      await tester.pumpWidget(_buildWidget(repo: repo));
      await tester.pumpAndSettle();
      expect(find.text('Hello team!'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
    });

    testWidgets('renders own messages without sender name', (tester) async {
      final repo = _FakeGameRepository(messages: [messageFromSelf]);
      await tester.pumpWidget(_buildWidget(repo: repo));
      await tester.pumpAndSettle();
      expect(find.text('Ready to play!'), findsOneWidget);
      // Own messages don't show the sender name above the bubble
      expect(find.text('Alice'), findsNothing);
    });

    testWidgets('shows input field for players', (tester) async {
      final repo = _FakeGameRepository(messages: []);
      await tester.pumpWidget(_buildWidget(repo: repo, isPlayer: true));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('shows players-only message for non-players', (tester) async {
      final repo = _FakeGameRepository(messages: []);
      await tester.pumpWidget(_buildWidget(repo: repo, isPlayer: false));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsNothing);
      expect(find.text('Only players can send messages'), findsOneWidget);
    });

    testWidgets('send button calls sendMessage on repository', (tester) async {
      final repo = _FakeGameRepository(messages: []);
      await tester.pumpWidget(_buildWidget(repo: repo));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Hello!');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      expect(repo.sentMessages, hasLength(1));
      expect(repo.sentMessages.first['text'], 'Hello!');
      expect(repo.sentMessages.first['gameId'], 'game-1');
      expect(repo.sentMessages.first['senderId'], 'current-user');
      expect(repo.sentMessages.first['senderDisplayName'], 'Alice');
    });

    testWidgets('shows chat section title', (tester) async {
      final repo = _FakeGameRepository(messages: []);
      await tester.pumpWidget(_buildWidget(repo: repo));
      await tester.pumpAndSettle();
      expect(find.text('Chat'), findsOneWidget);
    });

    testWidgets('clears text field after sending', (tester) async {
      final repo = _FakeGameRepository(messages: []);
      await tester.pumpWidget(_buildWidget(repo: repo));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Test message');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, isEmpty);
    });

    testWidgets('does not send empty message', (tester) async {
      final repo = _FakeGameRepository(messages: []);
      await tester.pumpWidget(_buildWidget(repo: repo));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      expect(repo.sentMessages, isEmpty);
    });
  });
}
