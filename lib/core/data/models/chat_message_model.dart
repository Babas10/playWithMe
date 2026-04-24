import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message_model.freezed.dart';
part 'chat_message_model.g.dart';

@freezed
class ChatMessageModel with _$ChatMessageModel {
  const factory ChatMessageModel({
    required String id,
    required String senderId,
    required String senderDisplayName,
    required String text,
    @TimestampConverter() required DateTime sentAt,
  }) = _ChatMessageModel;

  const ChatMessageModel._();

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageModelFromJson(json);

  /// Factory constructor for creating from Firestore DocumentSnapshot
  factory ChatMessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessageModel.fromJson({...data, 'id': doc.id});
  }

  /// Convert to Firestore-compatible map (excludes id since it's the document ID)
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id'); // Remove id as it's the document ID
    return json;
  }
}

/// Custom converter for Firestore Timestamp to DateTime
class TimestampConverter implements JsonConverter<DateTime, Object> {
  const TimestampConverter();

  @override
  DateTime fromJson(Object json) {
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.parse(json);
    if (json is int) return DateTime.fromMillisecondsSinceEpoch(json);
    throw Exception('Unknown type for timestamp: ${json.runtimeType}');
  }

  @override
  Object toJson(DateTime object) => Timestamp.fromDate(object);
}
