import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'invitation_model.freezed.dart';
part 'invitation_model.g.dart';

/// Status of an invitation
enum InvitationStatus {
  pending,
  accepted,
  declined,
}

@freezed
class InvitationModel with _$InvitationModel {
  const factory InvitationModel({
    required String id,
    required String groupId,
    required String groupName,
    required String invitedBy,
    required String inviterName,
    required String invitedUserId,
    @Default(InvitationStatus.pending) InvitationStatus status,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() DateTime? respondedAt,
  }) = _InvitationModel;

  const InvitationModel._();

  factory InvitationModel.fromJson(Map<String, dynamic> json) =>
      _$InvitationModelFromJson(json);

  /// Factory constructor for creating from Firestore DocumentSnapshot
  factory InvitationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InvitationModel.fromJson({
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

  /// Check if invitation is still pending
  bool get isPending => status == InvitationStatus.pending;

  /// Check if invitation was accepted
  bool get isAccepted => status == InvitationStatus.accepted;

  /// Check if invitation was declined
  bool get isDeclined => status == InvitationStatus.declined;

  /// Accept the invitation
  InvitationModel accept() {
    return copyWith(
      status: InvitationStatus.accepted,
      respondedAt: DateTime.now(),
    );
  }

  /// Decline the invitation
  InvitationModel decline() {
    return copyWith(
      status: InvitationStatus.declined,
      respondedAt: DateTime.now(),
    );
  }
}

/// Converter for Firestore Timestamp to DateTime
class TimestampConverter implements JsonConverter<DateTime, Object> {
  const TimestampConverter();

  @override
  DateTime fromJson(Object json) {
    if (json is Timestamp) {
      return json.toDate();
    } else if (json is int) {
      return DateTime.fromMillisecondsSinceEpoch(json);
    } else if (json is String) {
      return DateTime.parse(json);
    }
    throw Exception('Unknown type for timestamp: ${json.runtimeType}');
  }

  @override
  Object toJson(DateTime object) => Timestamp.fromDate(object);
}
