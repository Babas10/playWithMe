// Tests ChatMessageModel serialisation, fromFirestore factory, toFirestore, and TimestampConverter.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/chat_message_model.dart';

void main() {
  group('ChatMessageModel', () {
    final testSentAt = DateTime(2025, 6, 15, 10, 30);

    group('constructor', () {
      test('creates instance with all required fields', () {
        final message = ChatMessageModel(
          id: 'msg-123',
          senderId: 'user-456',
          senderDisplayName: 'Alice',
          text: 'Hello team!',
          sentAt: testSentAt,
        );

        expect(message.id, 'msg-123');
        expect(message.senderId, 'user-456');
        expect(message.senderDisplayName, 'Alice');
        expect(message.text, 'Hello team!');
        expect(message.sentAt, testSentAt);
      });
    });

    group('fromJson', () {
      test('deserializes JSON with Firestore Timestamp for sentAt', () {
        final json = {
          'id': 'msg-123',
          'senderId': 'user-456',
          'senderDisplayName': 'Alice',
          'text': 'Hello team!',
          'sentAt': Timestamp.fromDate(testSentAt),
        };

        final message = ChatMessageModel.fromJson(json);

        expect(message.id, 'msg-123');
        expect(message.senderId, 'user-456');
        expect(message.senderDisplayName, 'Alice');
        expect(message.text, 'Hello team!');
        expect(message.sentAt, testSentAt);
      });

      test('deserializes JSON with ISO string for sentAt', () {
        final json = {
          'id': 'msg-123',
          'senderId': 'user-456',
          'senderDisplayName': 'Alice',
          'text': 'Hello team!',
          'sentAt': testSentAt.toIso8601String(),
        };

        final message = ChatMessageModel.fromJson(json);

        expect(message.sentAt, testSentAt);
      });

      test('deserializes JSON with int milliseconds for sentAt', () {
        final json = {
          'id': 'msg-123',
          'senderId': 'user-456',
          'senderDisplayName': 'Alice',
          'text': 'Hello team!',
          'sentAt': testSentAt.millisecondsSinceEpoch,
        };

        final message = ChatMessageModel.fromJson(json);

        expect(message.sentAt, testSentAt);
      });
    });

    group('toJson', () {
      test('serializes all fields to JSON', () {
        final message = ChatMessageModel(
          id: 'msg-123',
          senderId: 'user-456',
          senderDisplayName: 'Alice',
          text: 'Hello team!',
          sentAt: testSentAt,
        );

        final json = message.toJson();

        expect(json['id'], 'msg-123');
        expect(json['senderId'], 'user-456');
        expect(json['senderDisplayName'], 'Alice');
        expect(json['text'], 'Hello team!');
        expect(json['sentAt'], isA<Timestamp>());
        expect((json['sentAt'] as Timestamp).toDate(), testSentAt);
      });
    });

    group('toFirestore', () {
      test('excludes id from Firestore data', () {
        final message = ChatMessageModel(
          id: 'msg-123',
          senderId: 'user-456',
          senderDisplayName: 'Alice',
          text: 'Hello team!',
          sentAt: testSentAt,
        );

        final firestoreData = message.toFirestore();

        expect(firestoreData.containsKey('id'), isFalse);
      });

      test('includes all other fields', () {
        final message = ChatMessageModel(
          id: 'msg-123',
          senderId: 'user-456',
          senderDisplayName: 'Alice',
          text: 'Hello team!',
          sentAt: testSentAt,
        );

        final firestoreData = message.toFirestore();

        expect(firestoreData['senderId'], 'user-456');
        expect(firestoreData['senderDisplayName'], 'Alice');
        expect(firestoreData['text'], 'Hello team!');
        expect(firestoreData['sentAt'], isA<Timestamp>());
        expect(
          (firestoreData['sentAt'] as Timestamp).toDate(),
          testSentAt,
        );
      });
    });

    group('copyWith', () {
      test('creates copy with updated text', () {
        final message = ChatMessageModel(
          id: 'msg-123',
          senderId: 'user-456',
          senderDisplayName: 'Alice',
          text: 'Hello team!',
          sentAt: testSentAt,
        );

        final copy = message.copyWith(text: 'Updated message');

        expect(copy.text, 'Updated message');
        expect(copy.id, 'msg-123');
        expect(copy.senderId, 'user-456');
      });

      test('preserves unchanged fields', () {
        final message = ChatMessageModel(
          id: 'msg-123',
          senderId: 'user-456',
          senderDisplayName: 'Alice',
          text: 'Hello team!',
          sentAt: testSentAt,
        );

        final copy = message.copyWith(senderDisplayName: 'Bob');

        expect(copy.senderDisplayName, 'Bob');
        expect(copy.id, 'msg-123');
        expect(copy.senderId, 'user-456');
        expect(copy.text, 'Hello team!');
        expect(copy.sentAt, testSentAt);
      });
    });

    group('equality', () {
      test('two messages with same data are equal', () {
        final message1 = ChatMessageModel(
          id: 'msg-123',
          senderId: 'user-456',
          senderDisplayName: 'Alice',
          text: 'Hello team!',
          sentAt: testSentAt,
        );

        final message2 = ChatMessageModel(
          id: 'msg-123',
          senderId: 'user-456',
          senderDisplayName: 'Alice',
          text: 'Hello team!',
          sentAt: testSentAt,
        );

        expect(message1, message2);
        expect(message1.hashCode, message2.hashCode);
      });

      test('two messages with different ids are not equal', () {
        final message1 = ChatMessageModel(
          id: 'msg-123',
          senderId: 'user-456',
          senderDisplayName: 'Alice',
          text: 'Hello!',
          sentAt: testSentAt,
        );

        final message2 = ChatMessageModel(
          id: 'msg-999',
          senderId: 'user-456',
          senderDisplayName: 'Alice',
          text: 'Hello!',
          sentAt: testSentAt,
        );

        expect(message1, isNot(message2));
      });

      test('two messages with different text are not equal', () {
        final message1 = ChatMessageModel(
          id: 'msg-123',
          senderId: 'user-456',
          senderDisplayName: 'Alice',
          text: 'Hello!',
          sentAt: testSentAt,
        );

        final message2 = ChatMessageModel(
          id: 'msg-123',
          senderId: 'user-456',
          senderDisplayName: 'Alice',
          text: 'Goodbye!',
          sentAt: testSentAt,
        );

        expect(message1, isNot(message2));
      });
    });
  });

  group('TimestampConverter (ChatMessageModel)', () {
    const converter = TimestampConverter();
    final testDate = DateTime(2025, 6, 15, 12, 30, 45);

    group('fromJson', () {
      test('converts Timestamp to DateTime', () {
        final timestamp = Timestamp.fromDate(testDate);
        final result = converter.fromJson(timestamp);
        expect(result, testDate);
      });

      test('converts int milliseconds to DateTime', () {
        final millis = testDate.millisecondsSinceEpoch;
        final result = converter.fromJson(millis);
        expect(result, testDate);
      });

      test('converts ISO string to DateTime', () {
        final isoString = testDate.toIso8601String();
        final result = converter.fromJson(isoString);
        expect(result, testDate);
      });

      test('throws exception for unknown type', () {
        expect(
          () => converter.fromJson(12.34),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Unknown type for timestamp'),
            ),
          ),
        );
      });
    });

    group('toJson', () {
      test('converts DateTime to Timestamp', () {
        final result = converter.toJson(testDate);
        expect(result, isA<Timestamp>());
        expect((result as Timestamp).toDate(), testDate);
      });
    });

    group('round trip', () {
      test('fromJson and toJson are inverse operations', () {
        final original = DateTime(2025, 12, 25, 18, 30, 0);
        final timestamp = converter.toJson(original);
        final restored = converter.fromJson(timestamp);
        expect(restored, original);
      });
    });
  });
}
