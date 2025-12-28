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
  gamesLost: (json['gamesLost'] as num?)?.toInt() ?? 0,
  totalScore: (json['totalScore'] as num?)?.toInt() ?? 0,
  currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
  recentGameIds:
      (json['recentGameIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  lastGameDate: const TimestampConverter().fromJson(json['lastGameDate']),
  teammateStats: json['teammateStats'] as Map<String, dynamic>? ?? const {},
  eloRating: (json['eloRating'] as num?)?.toDouble() ?? 1600.0,
  eloLastUpdated: const TimestampConverter().fromJson(json['eloLastUpdated']),
  eloPeak: (json['eloPeak'] as num?)?.toDouble() ?? 1600.0,
  eloPeakDate: const TimestampConverter().fromJson(json['eloPeakDate']),
  eloGamesPlayed: (json['eloGamesPlayed'] as num?)?.toInt() ?? 0,
  nemesis: json['nemesis'] == null
      ? null
      : NemesisRecord.fromJson(json['nemesis'] as Map<String, dynamic>),
  bestWin: json['bestWin'] == null
      ? null
      : BestWinRecord.fromJson(json['bestWin'] as Map<String, dynamic>),
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
  'gamesLost': instance.gamesLost,
  'totalScore': instance.totalScore,
  'currentStreak': instance.currentStreak,
  'recentGameIds': instance.recentGameIds,
  'lastGameDate': const TimestampConverter().toJson(instance.lastGameDate),
  'teammateStats': instance.teammateStats,
  'eloRating': instance.eloRating,
  'eloLastUpdated': const TimestampConverter().toJson(instance.eloLastUpdated),
  'eloPeak': instance.eloPeak,
  'eloPeakDate': const TimestampConverter().toJson(instance.eloPeakDate),
  'eloGamesPlayed': instance.eloGamesPlayed,
  'nemesis': instance.nemesis,
  'bestWin': instance.bestWin,
};

const _$UserPrivacyLevelEnumMap = {
  UserPrivacyLevel.public: 'public',
  UserPrivacyLevel.friends: 'friends',
  UserPrivacyLevel.private: 'private',
};

_$NemesisRecordImpl _$$NemesisRecordImplFromJson(Map<String, dynamic> json) =>
    _$NemesisRecordImpl(
      opponentId: json['opponentId'] as String,
      opponentName: json['opponentName'] as String,
      gamesLost: (json['gamesLost'] as num).toInt(),
      gamesWon: (json['gamesWon'] as num).toInt(),
      gamesPlayed: (json['gamesPlayed'] as num).toInt(),
      winRate: (json['winRate'] as num).toDouble(),
    );

Map<String, dynamic> _$$NemesisRecordImplToJson(_$NemesisRecordImpl instance) =>
    <String, dynamic>{
      'opponentId': instance.opponentId,
      'opponentName': instance.opponentName,
      'gamesLost': instance.gamesLost,
      'gamesWon': instance.gamesWon,
      'gamesPlayed': instance.gamesPlayed,
      'winRate': instance.winRate,
    };

_$BestWinRecordImpl _$$BestWinRecordImplFromJson(Map<String, dynamic> json) =>
    _$BestWinRecordImpl(
      gameId: json['gameId'] as String,
      opponentTeamElo: (json['opponentTeamElo'] as num).toDouble(),
      opponentTeamAvgElo: (json['opponentTeamAvgElo'] as num).toDouble(),
      eloGained: (json['eloGained'] as num).toDouble(),
      date: _dateFromJson(json['date']),
      gameTitle: json['gameTitle'] as String,
    );

Map<String, dynamic> _$$BestWinRecordImplToJson(_$BestWinRecordImpl instance) =>
    <String, dynamic>{
      'gameId': instance.gameId,
      'opponentTeamElo': instance.opponentTeamElo,
      'opponentTeamAvgElo': instance.opponentTeamAvgElo,
      'eloGained': instance.eloGained,
      'date': _dateToJson(instance.date),
      'gameTitle': instance.gameTitle,
    };
