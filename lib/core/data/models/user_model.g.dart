// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$$UserModelImplFromJson(
  Map<String, dynamic> json,
) => _$UserModelImpl(
  uid: json['uid'] as String,
  email: json['email'] as String,
  displayName: json['displayName'] as String?,
  photoUrl: json['photoUrl'] as String?,
  isEmailVerified: json['isEmailVerified'] as bool,
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
  lastSignInAt: const TimestampConverter().fromJson(json['lastSignInAt']),
  updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
  isAnonymous: json['isAnonymous'] as bool,
  firstName: json['firstName'] as String?,
  lastName: json['lastName'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  dateOfBirth: json['dateOfBirth'] == null
      ? null
      : DateTime.parse(json['dateOfBirth'] as String),
  location: json['location'] as String?,
  bio: json['bio'] as String?,
  groupIds:
      (json['groupIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  gameIds:
      (json['gameIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  friendIds:
      (json['friendIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  friendCount: (json['friendCount'] as num?)?.toInt() ?? 0,
  friendsLastUpdated: const TimestampConverter().fromJson(
    json['friendsLastUpdated'],
  ),
  notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
  emailNotifications: json['emailNotifications'] as bool? ?? true,
  pushNotifications: json['pushNotifications'] as bool? ?? true,
  privacyLevel:
      $enumDecodeNullable(_$UserPrivacyLevelEnumMap, json['privacyLevel']) ??
      UserPrivacyLevel.public,
  showEmail: json['showEmail'] as bool? ?? true,
  showPhoneNumber: json['showPhoneNumber'] as bool? ?? true,
  gamesPlayed: (json['gamesPlayed'] as num?)?.toInt() ?? 0,
  gamesWon: (json['gamesWon'] as num?)?.toInt() ?? 0,
  totalScore: (json['totalScore'] as num?)?.toInt() ?? 0,
  eloRating: (json['eloRating'] as num?)?.toDouble() ?? 1600.0,
  eloLastUpdated: const TimestampConverter().fromJson(json['eloLastUpdated']),
  eloPeak: (json['eloPeak'] as num?)?.toDouble() ?? 1600.0,
  eloPeakDate: const TimestampConverter().fromJson(json['eloPeakDate']),
  eloGamesPlayed: (json['eloGamesPlayed'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$UserModelImplToJson(
  _$UserModelImpl instance,
) => <String, dynamic>{
  'uid': instance.uid,
  'email': instance.email,
  'displayName': instance.displayName,
  'photoUrl': instance.photoUrl,
  'isEmailVerified': instance.isEmailVerified,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'lastSignInAt': const TimestampConverter().toJson(instance.lastSignInAt),
  'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
  'isAnonymous': instance.isAnonymous,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'phoneNumber': instance.phoneNumber,
  'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
  'location': instance.location,
  'bio': instance.bio,
  'groupIds': instance.groupIds,
  'gameIds': instance.gameIds,
  'friendIds': instance.friendIds,
  'friendCount': instance.friendCount,
  'friendsLastUpdated': const TimestampConverter().toJson(
    instance.friendsLastUpdated,
  ),
  'notificationsEnabled': instance.notificationsEnabled,
  'emailNotifications': instance.emailNotifications,
  'pushNotifications': instance.pushNotifications,
  'privacyLevel': _$UserPrivacyLevelEnumMap[instance.privacyLevel]!,
  'showEmail': instance.showEmail,
  'showPhoneNumber': instance.showPhoneNumber,
  'gamesPlayed': instance.gamesPlayed,
  'gamesWon': instance.gamesWon,
  'totalScore': instance.totalScore,
  'eloRating': instance.eloRating,
  'eloLastUpdated': const TimestampConverter().toJson(instance.eloLastUpdated),
  'eloPeak': instance.eloPeak,
  'eloPeakDate': const TimestampConverter().toJson(instance.eloPeakDate),
  'eloGamesPlayed': instance.eloGamesPlayed,
};

const _$UserPrivacyLevelEnumMap = {
  UserPrivacyLevel.public: 'public',
  UserPrivacyLevel.friends: 'friends',
  UserPrivacyLevel.private: 'private',
};
