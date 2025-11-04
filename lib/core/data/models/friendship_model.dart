import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:play_with_me/core/domain/entities/friendship_entity.dart';

part 'friendship_model.freezed.dart';
part 'friendship_model.g.dart';

/// Data model for friendship relationships stored in Firestore.
///
/// This model handles serialization/deserialization of friendship data
/// and provides conversion to/from the domain entity.
///
/// Firestore collection: /friendships/{friendshipId}
@freezed
class FriendshipModel with _$FriendshipModel {
  const factory FriendshipModel({
    required String id,
    required String initiatorId,
    required String recipientId,
    required FriendshipStatus status,
    @RequiredTimestampConverter() required DateTime createdAt,
    @RequiredTimestampConverter() required DateTime updatedAt,
    required String initiatorName,
    required String recipientName,
  }) = _FriendshipModel;

  const FriendshipModel._();

  factory FriendshipModel.fromJson(Map<String, dynamic> json) =>
      _$FriendshipModelFromJson(json);

  /// Factory constructor for creating from Firestore DocumentSnapshot
  factory FriendshipModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FriendshipModel.fromJson({
      ...data,
      'id': doc.id,
    });
  }

  /// Convert to Firestore-compatible map (excludes id since it's the document ID)
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id'); // Remove id as it's the document ID
    return json;
  }

  /// Convert to domain entity
  FriendshipEntity toEntity() {
    return FriendshipEntity(
      id: id,
      initiatorId: initiatorId,
      recipientId: recipientId,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      initiatorName: initiatorName,
      recipientName: recipientName,
    );
  }

  /// Create from domain entity
  factory FriendshipModel.fromEntity(FriendshipEntity entity) {
    return FriendshipModel(
      id: entity.id,
      initiatorId: entity.initiatorId,
      recipientId: entity.recipientId,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      initiatorName: entity.initiatorName,
      recipientName: entity.recipientName,
    );
  }

  /// Business logic methods

  /// Check if friendship is pending
  bool get isPending => status == FriendshipStatus.pending;

  /// Check if friendship is accepted
  bool get isAccepted => status == FriendshipStatus.accepted;

  /// Check if friendship is declined
  bool get isDeclined => status == FriendshipStatus.declined;

  /// Check if user is the initiator
  bool isInitiator(String userId) => initiatorId == userId;

  /// Check if user is the recipient
  bool isRecipient(String userId) => recipientId == userId;

  /// Check if user is involved in this friendship
  bool involves(String userId) => initiatorId == userId || recipientId == userId;

  /// Get the other user's ID given one user's ID
  String? getOtherUserId(String userId) {
    if (initiatorId == userId) return recipientId;
    if (recipientId == userId) return initiatorId;
    return null;
  }

  /// Get the other user's name given one user's ID
  String? getOtherUserName(String userId) {
    if (initiatorId == userId) return recipientName;
    if (recipientId == userId) return initiatorName;
    return null;
  }

  /// Update methods that return new instances

  /// Accept the friendship (status: pending → accepted)
  FriendshipModel accept() {
    if (!isPending) return this;
    return copyWith(
      status: FriendshipStatus.accepted,
      updatedAt: DateTime.now(),
    );
  }

  /// Decline the friendship (status: pending → declined)
  FriendshipModel decline() {
    if (!isPending) return this;
    return copyWith(
      status: FriendshipStatus.declined,
      updatedAt: DateTime.now(),
    );
  }

  /// Update denormalized user names (used when a user changes their display name)
  FriendshipModel updateUserName(String userId, String newName) {
    if (initiatorId == userId) {
      return copyWith(
        initiatorName: newName,
        updatedAt: DateTime.now(),
      );
    } else if (recipientId == userId) {
      return copyWith(
        recipientName: newName,
        updatedAt: DateTime.now(),
      );
    }
    return this;
  }

  /// Check if friendship involves both users (used for duplicate prevention)
  bool involvesBothUsers(String userId1, String userId2) {
    return (initiatorId == userId1 && recipientId == userId2) ||
        (initiatorId == userId2 && recipientId == userId1);
  }
}

/// Custom converter for Firestore Timestamp to DateTime (for nullable DateTime)
class TimestampConverter implements JsonConverter<DateTime?, Object?> {
  const TimestampConverter();

  @override
  DateTime? fromJson(Object? json) {
    if (json == null) return null;
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.parse(json);
    if (json is int) return DateTime.fromMillisecondsSinceEpoch(json);
    return null;
  }

  @override
  Object? toJson(DateTime? object) {
    if (object == null) return null;
    return Timestamp.fromDate(object);
  }
}

/// Custom converter for Firestore Timestamp to DateTime (for required DateTime)
class RequiredTimestampConverter implements JsonConverter<DateTime, Object?> {
  const RequiredTimestampConverter();

  @override
  DateTime fromJson(Object? json) {
    if (json == null) throw ArgumentError('DateTime cannot be null');
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.parse(json);
    if (json is int) return DateTime.fromMillisecondsSinceEpoch(json);
    throw ArgumentError('Invalid DateTime format: $json');
  }

  @override
  Object toJson(DateTime object) {
    return Timestamp.fromDate(object);
  }
}
