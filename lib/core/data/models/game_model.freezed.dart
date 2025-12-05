// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GameModel _$GameModelFromJson(Map<String, dynamic> json) {
  return _GameModel.fromJson(json);
}

/// @nodoc
mixin _$GameModel {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String get groupId => throw _privateConstructorUsedError;
  String get createdBy => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get scheduledAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get startedAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get endedAt => throw _privateConstructorUsedError;
  GameLocation get location => throw _privateConstructorUsedError;
  GameStatus get status => throw _privateConstructorUsedError;
  int get maxPlayers => throw _privateConstructorUsedError;
  int get minPlayers => throw _privateConstructorUsedError;
  List<String> get playerIds => throw _privateConstructorUsedError;
  List<String> get waitlistIds =>
      throw _privateConstructorUsedError; // Game settings
  bool get allowWaitlist => throw _privateConstructorUsedError;
  bool get allowPlayerInvites => throw _privateConstructorUsedError;
  GameVisibility get visibility =>
      throw _privateConstructorUsedError; // Game details
  String? get notes => throw _privateConstructorUsedError;
  List<String> get equipment => throw _privateConstructorUsedError;
  Duration? get estimatedDuration =>
      throw _privateConstructorUsedError; // Court/Game specific info
  String? get courtInfo => throw _privateConstructorUsedError;
  GameType? get gameType => throw _privateConstructorUsedError;
  GameSkillLevel? get skillLevel =>
      throw _privateConstructorUsedError; // Scoring
  List<GameScore> get scores => throw _privateConstructorUsedError;
  String? get winnerId =>
      throw _privateConstructorUsedError; // Teams (for completed games)
  GameTeams? get teams =>
      throw _privateConstructorUsedError; // Game result (for completed games with entered scores)
  GameResult? get result =>
      throw _privateConstructorUsedError; // ELO calculation flag (set to false when result is saved, true after Python function processes)
  bool get eloCalculated =>
      throw _privateConstructorUsedError; // Timestamp when the game result was entered and completed
  @TimestampConverter()
  DateTime? get completedAt => throw _privateConstructorUsedError; // Weather considerations
  bool get weatherDependent => throw _privateConstructorUsedError;
  String? get weatherNotes => throw _privateConstructorUsedError;

  /// Serializes this GameModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameModelCopyWith<GameModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameModelCopyWith<$Res> {
  factory $GameModelCopyWith(GameModel value, $Res Function(GameModel) then) =
      _$GameModelCopyWithImpl<$Res, GameModel>;
  @useResult
  $Res call({
    String id,
    String title,
    String? description,
    String groupId,
    String createdBy,
    @TimestampConverter() DateTime createdAt,
    @TimestampConverter() DateTime? updatedAt,
    @TimestampConverter() DateTime scheduledAt,
    @TimestampConverter() DateTime? startedAt,
    @TimestampConverter() DateTime? endedAt,
    GameLocation location,
    GameStatus status,
    int maxPlayers,
    int minPlayers,
    List<String> playerIds,
    List<String> waitlistIds,
    bool allowWaitlist,
    bool allowPlayerInvites,
    GameVisibility visibility,
    String? notes,
    List<String> equipment,
    Duration? estimatedDuration,
    String? courtInfo,
    GameType? gameType,
    GameSkillLevel? skillLevel,
    List<GameScore> scores,
    String? winnerId,
    GameTeams? teams,
    GameResult? result,
    bool eloCalculated,
    @TimestampConverter() DateTime? completedAt,
    bool weatherDependent,
    String? weatherNotes,
  });

  $GameLocationCopyWith<$Res> get location;
  $GameTeamsCopyWith<$Res>? get teams;
  $GameResultCopyWith<$Res>? get result;
}

/// @nodoc
class _$GameModelCopyWithImpl<$Res, $Val extends GameModel>
    implements $GameModelCopyWith<$Res> {
  _$GameModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? groupId = null,
    Object? createdBy = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? scheduledAt = null,
    Object? startedAt = freezed,
    Object? endedAt = freezed,
    Object? location = null,
    Object? status = null,
    Object? maxPlayers = null,
    Object? minPlayers = null,
    Object? playerIds = null,
    Object? waitlistIds = null,
    Object? allowWaitlist = null,
    Object? allowPlayerInvites = null,
    Object? visibility = null,
    Object? notes = freezed,
    Object? equipment = null,
    Object? estimatedDuration = freezed,
    Object? courtInfo = freezed,
    Object? gameType = freezed,
    Object? skillLevel = freezed,
    Object? scores = null,
    Object? winnerId = freezed,
    Object? teams = freezed,
    Object? result = freezed,
    Object? eloCalculated = null,
    Object? completedAt = freezed,
    Object? weatherDependent = null,
    Object? weatherNotes = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            groupId: null == groupId
                ? _value.groupId
                : groupId // ignore: cast_nullable_to_non_nullable
                      as String,
            createdBy: null == createdBy
                ? _value.createdBy
                : createdBy // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            scheduledAt: null == scheduledAt
                ? _value.scheduledAt
                : scheduledAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            startedAt: freezed == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            endedAt: freezed == endedAt
                ? _value.endedAt
                : endedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            location: null == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as GameLocation,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as GameStatus,
            maxPlayers: null == maxPlayers
                ? _value.maxPlayers
                : maxPlayers // ignore: cast_nullable_to_non_nullable
                      as int,
            minPlayers: null == minPlayers
                ? _value.minPlayers
                : minPlayers // ignore: cast_nullable_to_non_nullable
                      as int,
            playerIds: null == playerIds
                ? _value.playerIds
                : playerIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            waitlistIds: null == waitlistIds
                ? _value.waitlistIds
                : waitlistIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            allowWaitlist: null == allowWaitlist
                ? _value.allowWaitlist
                : allowWaitlist // ignore: cast_nullable_to_non_nullable
                      as bool,
            allowPlayerInvites: null == allowPlayerInvites
                ? _value.allowPlayerInvites
                : allowPlayerInvites // ignore: cast_nullable_to_non_nullable
                      as bool,
            visibility: null == visibility
                ? _value.visibility
                : visibility // ignore: cast_nullable_to_non_nullable
                      as GameVisibility,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            equipment: null == equipment
                ? _value.equipment
                : equipment // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            estimatedDuration: freezed == estimatedDuration
                ? _value.estimatedDuration
                : estimatedDuration // ignore: cast_nullable_to_non_nullable
                      as Duration?,
            courtInfo: freezed == courtInfo
                ? _value.courtInfo
                : courtInfo // ignore: cast_nullable_to_non_nullable
                      as String?,
            gameType: freezed == gameType
                ? _value.gameType
                : gameType // ignore: cast_nullable_to_non_nullable
                      as GameType?,
            skillLevel: freezed == skillLevel
                ? _value.skillLevel
                : skillLevel // ignore: cast_nullable_to_non_nullable
                      as GameSkillLevel?,
            scores: null == scores
                ? _value.scores
                : scores // ignore: cast_nullable_to_non_nullable
                      as List<GameScore>,
            winnerId: freezed == winnerId
                ? _value.winnerId
                : winnerId // ignore: cast_nullable_to_non_nullable
                      as String?,
            teams: freezed == teams
                ? _value.teams
                : teams // ignore: cast_nullable_to_non_nullable
                      as GameTeams?,
            result: freezed == result
                ? _value.result
                : result // ignore: cast_nullable_to_non_nullable
                      as GameResult?,
            eloCalculated: null == eloCalculated
                ? _value.eloCalculated
                : eloCalculated // ignore: cast_nullable_to_non_nullable
                      as bool,
            completedAt: freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            weatherDependent: null == weatherDependent
                ? _value.weatherDependent
                : weatherDependent // ignore: cast_nullable_to_non_nullable
                      as bool,
            weatherNotes: freezed == weatherNotes
                ? _value.weatherNotes
                : weatherNotes // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of GameModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GameLocationCopyWith<$Res> get location {
    return $GameLocationCopyWith<$Res>(_value.location, (value) {
      return _then(_value.copyWith(location: value) as $Val);
    });
  }

  /// Create a copy of GameModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GameTeamsCopyWith<$Res>? get teams {
    if (_value.teams == null) {
      return null;
    }

    return $GameTeamsCopyWith<$Res>(_value.teams!, (value) {
      return _then(_value.copyWith(teams: value) as $Val);
    });
  }

  /// Create a copy of GameModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GameResultCopyWith<$Res>? get result {
    if (_value.result == null) {
      return null;
    }

    return $GameResultCopyWith<$Res>(_value.result!, (value) {
      return _then(_value.copyWith(result: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GameModelImplCopyWith<$Res>
    implements $GameModelCopyWith<$Res> {
  factory _$$GameModelImplCopyWith(
    _$GameModelImpl value,
    $Res Function(_$GameModelImpl) then,
  ) = __$$GameModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String? description,
    String groupId,
    String createdBy,
    @TimestampConverter() DateTime createdAt,
    @TimestampConverter() DateTime? updatedAt,
    @TimestampConverter() DateTime scheduledAt,
    @TimestampConverter() DateTime? startedAt,
    @TimestampConverter() DateTime? endedAt,
    GameLocation location,
    GameStatus status,
    int maxPlayers,
    int minPlayers,
    List<String> playerIds,
    List<String> waitlistIds,
    bool allowWaitlist,
    bool allowPlayerInvites,
    GameVisibility visibility,
    String? notes,
    List<String> equipment,
    Duration? estimatedDuration,
    String? courtInfo,
    GameType? gameType,
    GameSkillLevel? skillLevel,
    List<GameScore> scores,
    String? winnerId,
    GameTeams? teams,
    GameResult? result,
    bool eloCalculated,
    @TimestampConverter() DateTime? completedAt,
    bool weatherDependent,
    String? weatherNotes,
  });

  @override
  $GameLocationCopyWith<$Res> get location;
  @override
  $GameTeamsCopyWith<$Res>? get teams;
  @override
  $GameResultCopyWith<$Res>? get result;
}

/// @nodoc
class __$$GameModelImplCopyWithImpl<$Res>
    extends _$GameModelCopyWithImpl<$Res, _$GameModelImpl>
    implements _$$GameModelImplCopyWith<$Res> {
  __$$GameModelImplCopyWithImpl(
    _$GameModelImpl _value,
    $Res Function(_$GameModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? groupId = null,
    Object? createdBy = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? scheduledAt = null,
    Object? startedAt = freezed,
    Object? endedAt = freezed,
    Object? location = null,
    Object? status = null,
    Object? maxPlayers = null,
    Object? minPlayers = null,
    Object? playerIds = null,
    Object? waitlistIds = null,
    Object? allowWaitlist = null,
    Object? allowPlayerInvites = null,
    Object? visibility = null,
    Object? notes = freezed,
    Object? equipment = null,
    Object? estimatedDuration = freezed,
    Object? courtInfo = freezed,
    Object? gameType = freezed,
    Object? skillLevel = freezed,
    Object? scores = null,
    Object? winnerId = freezed,
    Object? teams = freezed,
    Object? result = freezed,
    Object? eloCalculated = null,
    Object? completedAt = freezed,
    Object? weatherDependent = null,
    Object? weatherNotes = freezed,
  }) {
    return _then(
      _$GameModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        groupId: null == groupId
            ? _value.groupId
            : groupId // ignore: cast_nullable_to_non_nullable
                  as String,
        createdBy: null == createdBy
            ? _value.createdBy
            : createdBy // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        scheduledAt: null == scheduledAt
            ? _value.scheduledAt
            : scheduledAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        startedAt: freezed == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        endedAt: freezed == endedAt
            ? _value.endedAt
            : endedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        location: null == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as GameLocation,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as GameStatus,
        maxPlayers: null == maxPlayers
            ? _value.maxPlayers
            : maxPlayers // ignore: cast_nullable_to_non_nullable
                  as int,
        minPlayers: null == minPlayers
            ? _value.minPlayers
            : minPlayers // ignore: cast_nullable_to_non_nullable
                  as int,
        playerIds: null == playerIds
            ? _value._playerIds
            : playerIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        waitlistIds: null == waitlistIds
            ? _value._waitlistIds
            : waitlistIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        allowWaitlist: null == allowWaitlist
            ? _value.allowWaitlist
            : allowWaitlist // ignore: cast_nullable_to_non_nullable
                  as bool,
        allowPlayerInvites: null == allowPlayerInvites
            ? _value.allowPlayerInvites
            : allowPlayerInvites // ignore: cast_nullable_to_non_nullable
                  as bool,
        visibility: null == visibility
            ? _value.visibility
            : visibility // ignore: cast_nullable_to_non_nullable
                  as GameVisibility,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        equipment: null == equipment
            ? _value._equipment
            : equipment // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        estimatedDuration: freezed == estimatedDuration
            ? _value.estimatedDuration
            : estimatedDuration // ignore: cast_nullable_to_non_nullable
                  as Duration?,
        courtInfo: freezed == courtInfo
            ? _value.courtInfo
            : courtInfo // ignore: cast_nullable_to_non_nullable
                  as String?,
        gameType: freezed == gameType
            ? _value.gameType
            : gameType // ignore: cast_nullable_to_non_nullable
                  as GameType?,
        skillLevel: freezed == skillLevel
            ? _value.skillLevel
            : skillLevel // ignore: cast_nullable_to_non_nullable
                  as GameSkillLevel?,
        scores: null == scores
            ? _value._scores
            : scores // ignore: cast_nullable_to_non_nullable
                  as List<GameScore>,
        winnerId: freezed == winnerId
            ? _value.winnerId
            : winnerId // ignore: cast_nullable_to_non_nullable
                  as String?,
        teams: freezed == teams
            ? _value.teams
            : teams // ignore: cast_nullable_to_non_nullable
                  as GameTeams?,
        result: freezed == result
            ? _value.result
            : result // ignore: cast_nullable_to_non_nullable
                  as GameResult?,
        eloCalculated: null == eloCalculated
            ? _value.eloCalculated
            : eloCalculated // ignore: cast_nullable_to_non_nullable
                  as bool,
        completedAt: freezed == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        weatherDependent: null == weatherDependent
            ? _value.weatherDependent
            : weatherDependent // ignore: cast_nullable_to_non_nullable
                  as bool,
        weatherNotes: freezed == weatherNotes
            ? _value.weatherNotes
            : weatherNotes // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GameModelImpl extends _GameModel {
  const _$GameModelImpl({
    required this.id,
    required this.title,
    this.description,
    required this.groupId,
    required this.createdBy,
    @TimestampConverter() required this.createdAt,
    @TimestampConverter() this.updatedAt,
    @TimestampConverter() required this.scheduledAt,
    @TimestampConverter() this.startedAt,
    @TimestampConverter() this.endedAt,
    required this.location,
    this.status = GameStatus.scheduled,
    this.maxPlayers = 4,
    this.minPlayers = 2,
    final List<String> playerIds = const [],
    final List<String> waitlistIds = const [],
    this.allowWaitlist = true,
    this.allowPlayerInvites = true,
    this.visibility = GameVisibility.group,
    this.notes,
    final List<String> equipment = const [],
    this.estimatedDuration,
    this.courtInfo,
    this.gameType,
    this.skillLevel,
    final List<GameScore> scores = const [],
    this.winnerId,
    this.teams,
    this.result,
    this.eloCalculated = false,
    @TimestampConverter() this.completedAt,
    this.weatherDependent = true,
    this.weatherNotes,
  }) : _playerIds = playerIds,
       _waitlistIds = waitlistIds,
       _equipment = equipment,
       _scores = scores,
       super._();

  factory _$GameModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameModelImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String? description;
  @override
  final String groupId;
  @override
  final String createdBy;
  @override
  @TimestampConverter()
  final DateTime createdAt;
  @override
  @TimestampConverter()
  final DateTime? updatedAt;
  @override
  @TimestampConverter()
  final DateTime scheduledAt;
  @override
  @TimestampConverter()
  final DateTime? startedAt;
  @override
  @TimestampConverter()
  final DateTime? endedAt;
  @override
  final GameLocation location;
  @override
  @JsonKey()
  final GameStatus status;
  @override
  @JsonKey()
  final int maxPlayers;
  @override
  @JsonKey()
  final int minPlayers;
  final List<String> _playerIds;
  @override
  @JsonKey()
  List<String> get playerIds {
    if (_playerIds is EqualUnmodifiableListView) return _playerIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_playerIds);
  }

  final List<String> _waitlistIds;
  @override
  @JsonKey()
  List<String> get waitlistIds {
    if (_waitlistIds is EqualUnmodifiableListView) return _waitlistIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_waitlistIds);
  }

  // Game settings
  @override
  @JsonKey()
  final bool allowWaitlist;
  @override
  @JsonKey()
  final bool allowPlayerInvites;
  @override
  @JsonKey()
  final GameVisibility visibility;
  // Game details
  @override
  final String? notes;
  final List<String> _equipment;
  @override
  @JsonKey()
  List<String> get equipment {
    if (_equipment is EqualUnmodifiableListView) return _equipment;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_equipment);
  }

  @override
  final Duration? estimatedDuration;
  // Court/Game specific info
  @override
  final String? courtInfo;
  @override
  final GameType? gameType;
  @override
  final GameSkillLevel? skillLevel;
  // Scoring
  final List<GameScore> _scores;
  // Scoring
  @override
  @JsonKey()
  List<GameScore> get scores {
    if (_scores is EqualUnmodifiableListView) return _scores;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_scores);
  }

  @override
  final String? winnerId;
  // Teams (for completed games)
  @override
  final GameTeams? teams;
  // Game result (for completed games with entered scores)
  @override
  final GameResult? result;
  // ELO calculation flag (set to false when result is saved, true after Python function processes)
  @override
  @JsonKey()
  final bool eloCalculated;
  // Timestamp when the game result was entered and completed
  @override
  @TimestampConverter()
  final DateTime? completedAt;
  // Weather considerations
  @override
  @JsonKey()
  final bool weatherDependent;
  @override
  final String? weatherNotes;

  @override
  String toString() {
    return 'GameModel(id: $id, title: $title, description: $description, groupId: $groupId, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt, scheduledAt: $scheduledAt, startedAt: $startedAt, endedAt: $endedAt, location: $location, status: $status, maxPlayers: $maxPlayers, minPlayers: $minPlayers, playerIds: $playerIds, waitlistIds: $waitlistIds, allowWaitlist: $allowWaitlist, allowPlayerInvites: $allowPlayerInvites, visibility: $visibility, notes: $notes, equipment: $equipment, estimatedDuration: $estimatedDuration, courtInfo: $courtInfo, gameType: $gameType, skillLevel: $skillLevel, scores: $scores, winnerId: $winnerId, teams: $teams, result: $result, eloCalculated: $eloCalculated, completedAt: $completedAt, weatherDependent: $weatherDependent, weatherNotes: $weatherNotes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.scheduledAt, scheduledAt) ||
                other.scheduledAt == scheduledAt) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.endedAt, endedAt) || other.endedAt == endedAt) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.maxPlayers, maxPlayers) ||
                other.maxPlayers == maxPlayers) &&
            (identical(other.minPlayers, minPlayers) ||
                other.minPlayers == minPlayers) &&
            const DeepCollectionEquality().equals(
              other._playerIds,
              _playerIds,
            ) &&
            const DeepCollectionEquality().equals(
              other._waitlistIds,
              _waitlistIds,
            ) &&
            (identical(other.allowWaitlist, allowWaitlist) ||
                other.allowWaitlist == allowWaitlist) &&
            (identical(other.allowPlayerInvites, allowPlayerInvites) ||
                other.allowPlayerInvites == allowPlayerInvites) &&
            (identical(other.visibility, visibility) ||
                other.visibility == visibility) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            const DeepCollectionEquality().equals(
              other._equipment,
              _equipment,
            ) &&
            (identical(other.estimatedDuration, estimatedDuration) ||
                other.estimatedDuration == estimatedDuration) &&
            (identical(other.courtInfo, courtInfo) ||
                other.courtInfo == courtInfo) &&
            (identical(other.gameType, gameType) ||
                other.gameType == gameType) &&
            (identical(other.skillLevel, skillLevel) ||
                other.skillLevel == skillLevel) &&
            const DeepCollectionEquality().equals(other._scores, _scores) &&
            (identical(other.winnerId, winnerId) ||
                other.winnerId == winnerId) &&
            (identical(other.teams, teams) || other.teams == teams) &&
            (identical(other.result, result) || other.result == result) &&
            (identical(other.eloCalculated, eloCalculated) ||
                other.eloCalculated == eloCalculated) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.weatherDependent, weatherDependent) ||
                other.weatherDependent == weatherDependent) &&
            (identical(other.weatherNotes, weatherNotes) ||
                other.weatherNotes == weatherNotes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    title,
    description,
    groupId,
    createdBy,
    createdAt,
    updatedAt,
    scheduledAt,
    startedAt,
    endedAt,
    location,
    status,
    maxPlayers,
    minPlayers,
    const DeepCollectionEquality().hash(_playerIds),
    const DeepCollectionEquality().hash(_waitlistIds),
    allowWaitlist,
    allowPlayerInvites,
    visibility,
    notes,
    const DeepCollectionEquality().hash(_equipment),
    estimatedDuration,
    courtInfo,
    gameType,
    skillLevel,
    const DeepCollectionEquality().hash(_scores),
    winnerId,
    teams,
    result,
    eloCalculated,
    completedAt,
    weatherDependent,
    weatherNotes,
  ]);

  /// Create a copy of GameModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameModelImplCopyWith<_$GameModelImpl> get copyWith =>
      __$$GameModelImplCopyWithImpl<_$GameModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GameModelImplToJson(this);
  }
}

abstract class _GameModel extends GameModel {
  const factory _GameModel({
    required final String id,
    required final String title,
    final String? description,
    required final String groupId,
    required final String createdBy,
    @TimestampConverter() required final DateTime createdAt,
    @TimestampConverter() final DateTime? updatedAt,
    @TimestampConverter() required final DateTime scheduledAt,
    @TimestampConverter() final DateTime? startedAt,
    @TimestampConverter() final DateTime? endedAt,
    required final GameLocation location,
    final GameStatus status,
    final int maxPlayers,
    final int minPlayers,
    final List<String> playerIds,
    final List<String> waitlistIds,
    final bool allowWaitlist,
    final bool allowPlayerInvites,
    final GameVisibility visibility,
    final String? notes,
    final List<String> equipment,
    final Duration? estimatedDuration,
    final String? courtInfo,
    final GameType? gameType,
    final GameSkillLevel? skillLevel,
    final List<GameScore> scores,
    final String? winnerId,
    final GameTeams? teams,
    final GameResult? result,
    final bool eloCalculated,
    @TimestampConverter() final DateTime? completedAt,
    final bool weatherDependent,
    final String? weatherNotes,
  }) = _$GameModelImpl;
  const _GameModel._() : super._();

  factory _GameModel.fromJson(Map<String, dynamic> json) =
      _$GameModelImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String? get description;
  @override
  String get groupId;
  @override
  String get createdBy;
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  @TimestampConverter()
  DateTime? get updatedAt;
  @override
  @TimestampConverter()
  DateTime get scheduledAt;
  @override
  @TimestampConverter()
  DateTime? get startedAt;
  @override
  @TimestampConverter()
  DateTime? get endedAt;
  @override
  GameLocation get location;
  @override
  GameStatus get status;
  @override
  int get maxPlayers;
  @override
  int get minPlayers;
  @override
  List<String> get playerIds;
  @override
  List<String> get waitlistIds; // Game settings
  @override
  bool get allowWaitlist;
  @override
  bool get allowPlayerInvites;
  @override
  GameVisibility get visibility; // Game details
  @override
  String? get notes;
  @override
  List<String> get equipment;
  @override
  Duration? get estimatedDuration; // Court/Game specific info
  @override
  String? get courtInfo;
  @override
  GameType? get gameType;
  @override
  GameSkillLevel? get skillLevel; // Scoring
  @override
  List<GameScore> get scores;
  @override
  String? get winnerId; // Teams (for completed games)
  @override
  GameTeams? get teams; // Game result (for completed games with entered scores)
  @override
  GameResult? get result; // ELO calculation flag (set to false when result is saved, true after Python function processes)
  @override
  bool get eloCalculated; // Timestamp when the game result was entered and completed
  @override
  @TimestampConverter()
  DateTime? get completedAt; // Weather considerations
  @override
  bool get weatherDependent;
  @override
  String? get weatherNotes;

  /// Create a copy of GameModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameModelImplCopyWith<_$GameModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GameTeams _$GameTeamsFromJson(Map<String, dynamic> json) {
  return _GameTeams.fromJson(json);
}

/// @nodoc
mixin _$GameTeams {
  List<String> get teamAPlayerIds => throw _privateConstructorUsedError;
  List<String> get teamBPlayerIds => throw _privateConstructorUsedError;

  /// Serializes this GameTeams to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameTeams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameTeamsCopyWith<GameTeams> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameTeamsCopyWith<$Res> {
  factory $GameTeamsCopyWith(GameTeams value, $Res Function(GameTeams) then) =
      _$GameTeamsCopyWithImpl<$Res, GameTeams>;
  @useResult
  $Res call({List<String> teamAPlayerIds, List<String> teamBPlayerIds});
}

/// @nodoc
class _$GameTeamsCopyWithImpl<$Res, $Val extends GameTeams>
    implements $GameTeamsCopyWith<$Res> {
  _$GameTeamsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameTeams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? teamAPlayerIds = null, Object? teamBPlayerIds = null}) {
    return _then(
      _value.copyWith(
            teamAPlayerIds: null == teamAPlayerIds
                ? _value.teamAPlayerIds
                : teamAPlayerIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            teamBPlayerIds: null == teamBPlayerIds
                ? _value.teamBPlayerIds
                : teamBPlayerIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GameTeamsImplCopyWith<$Res>
    implements $GameTeamsCopyWith<$Res> {
  factory _$$GameTeamsImplCopyWith(
    _$GameTeamsImpl value,
    $Res Function(_$GameTeamsImpl) then,
  ) = __$$GameTeamsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<String> teamAPlayerIds, List<String> teamBPlayerIds});
}

/// @nodoc
class __$$GameTeamsImplCopyWithImpl<$Res>
    extends _$GameTeamsCopyWithImpl<$Res, _$GameTeamsImpl>
    implements _$$GameTeamsImplCopyWith<$Res> {
  __$$GameTeamsImplCopyWithImpl(
    _$GameTeamsImpl _value,
    $Res Function(_$GameTeamsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameTeams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? teamAPlayerIds = null, Object? teamBPlayerIds = null}) {
    return _then(
      _$GameTeamsImpl(
        teamAPlayerIds: null == teamAPlayerIds
            ? _value._teamAPlayerIds
            : teamAPlayerIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        teamBPlayerIds: null == teamBPlayerIds
            ? _value._teamBPlayerIds
            : teamBPlayerIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GameTeamsImpl extends _GameTeams {
  const _$GameTeamsImpl({
    final List<String> teamAPlayerIds = const [],
    final List<String> teamBPlayerIds = const [],
  }) : _teamAPlayerIds = teamAPlayerIds,
       _teamBPlayerIds = teamBPlayerIds,
       super._();

  factory _$GameTeamsImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameTeamsImplFromJson(json);

  final List<String> _teamAPlayerIds;
  @override
  @JsonKey()
  List<String> get teamAPlayerIds {
    if (_teamAPlayerIds is EqualUnmodifiableListView) return _teamAPlayerIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_teamAPlayerIds);
  }

  final List<String> _teamBPlayerIds;
  @override
  @JsonKey()
  List<String> get teamBPlayerIds {
    if (_teamBPlayerIds is EqualUnmodifiableListView) return _teamBPlayerIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_teamBPlayerIds);
  }

  @override
  String toString() {
    return 'GameTeams(teamAPlayerIds: $teamAPlayerIds, teamBPlayerIds: $teamBPlayerIds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameTeamsImpl &&
            const DeepCollectionEquality().equals(
              other._teamAPlayerIds,
              _teamAPlayerIds,
            ) &&
            const DeepCollectionEquality().equals(
              other._teamBPlayerIds,
              _teamBPlayerIds,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_teamAPlayerIds),
    const DeepCollectionEquality().hash(_teamBPlayerIds),
  );

  /// Create a copy of GameTeams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameTeamsImplCopyWith<_$GameTeamsImpl> get copyWith =>
      __$$GameTeamsImplCopyWithImpl<_$GameTeamsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GameTeamsImplToJson(this);
  }
}

abstract class _GameTeams extends GameTeams {
  const factory _GameTeams({
    final List<String> teamAPlayerIds,
    final List<String> teamBPlayerIds,
  }) = _$GameTeamsImpl;
  const _GameTeams._() : super._();

  factory _GameTeams.fromJson(Map<String, dynamic> json) =
      _$GameTeamsImpl.fromJson;

  @override
  List<String> get teamAPlayerIds;
  @override
  List<String> get teamBPlayerIds;

  /// Create a copy of GameTeams
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameTeamsImplCopyWith<_$GameTeamsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GameLocation _$GameLocationFromJson(Map<String, dynamic> json) {
  return _GameLocation.fromJson(json);
}

/// @nodoc
mixin _$GameLocation {
  String get name => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get parkingInfo => throw _privateConstructorUsedError;
  String? get accessInstructions => throw _privateConstructorUsedError;

  /// Serializes this GameLocation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameLocation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameLocationCopyWith<GameLocation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameLocationCopyWith<$Res> {
  factory $GameLocationCopyWith(
    GameLocation value,
    $Res Function(GameLocation) then,
  ) = _$GameLocationCopyWithImpl<$Res, GameLocation>;
  @useResult
  $Res call({
    String name,
    String? address,
    double? latitude,
    double? longitude,
    String? description,
    String? parkingInfo,
    String? accessInstructions,
  });
}

/// @nodoc
class _$GameLocationCopyWithImpl<$Res, $Val extends GameLocation>
    implements $GameLocationCopyWith<$Res> {
  _$GameLocationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameLocation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? address = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? description = freezed,
    Object? parkingInfo = freezed,
    Object? accessInstructions = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            address: freezed == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String?,
            latitude: freezed == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            longitude: freezed == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            parkingInfo: freezed == parkingInfo
                ? _value.parkingInfo
                : parkingInfo // ignore: cast_nullable_to_non_nullable
                      as String?,
            accessInstructions: freezed == accessInstructions
                ? _value.accessInstructions
                : accessInstructions // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GameLocationImplCopyWith<$Res>
    implements $GameLocationCopyWith<$Res> {
  factory _$$GameLocationImplCopyWith(
    _$GameLocationImpl value,
    $Res Function(_$GameLocationImpl) then,
  ) = __$$GameLocationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    String? address,
    double? latitude,
    double? longitude,
    String? description,
    String? parkingInfo,
    String? accessInstructions,
  });
}

/// @nodoc
class __$$GameLocationImplCopyWithImpl<$Res>
    extends _$GameLocationCopyWithImpl<$Res, _$GameLocationImpl>
    implements _$$GameLocationImplCopyWith<$Res> {
  __$$GameLocationImplCopyWithImpl(
    _$GameLocationImpl _value,
    $Res Function(_$GameLocationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameLocation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? address = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? description = freezed,
    Object? parkingInfo = freezed,
    Object? accessInstructions = freezed,
  }) {
    return _then(
      _$GameLocationImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        address: freezed == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String?,
        latitude: freezed == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        longitude: freezed == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        parkingInfo: freezed == parkingInfo
            ? _value.parkingInfo
            : parkingInfo // ignore: cast_nullable_to_non_nullable
                  as String?,
        accessInstructions: freezed == accessInstructions
            ? _value.accessInstructions
            : accessInstructions // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GameLocationImpl implements _GameLocation {
  const _$GameLocationImpl({
    required this.name,
    this.address,
    this.latitude,
    this.longitude,
    this.description,
    this.parkingInfo,
    this.accessInstructions,
  });

  factory _$GameLocationImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameLocationImplFromJson(json);

  @override
  final String name;
  @override
  final String? address;
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  final String? description;
  @override
  final String? parkingInfo;
  @override
  final String? accessInstructions;

  @override
  String toString() {
    return 'GameLocation(name: $name, address: $address, latitude: $latitude, longitude: $longitude, description: $description, parkingInfo: $parkingInfo, accessInstructions: $accessInstructions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameLocationImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.parkingInfo, parkingInfo) ||
                other.parkingInfo == parkingInfo) &&
            (identical(other.accessInstructions, accessInstructions) ||
                other.accessInstructions == accessInstructions));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    address,
    latitude,
    longitude,
    description,
    parkingInfo,
    accessInstructions,
  );

  /// Create a copy of GameLocation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameLocationImplCopyWith<_$GameLocationImpl> get copyWith =>
      __$$GameLocationImplCopyWithImpl<_$GameLocationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GameLocationImplToJson(this);
  }
}

abstract class _GameLocation implements GameLocation {
  const factory _GameLocation({
    required final String name,
    final String? address,
    final double? latitude,
    final double? longitude,
    final String? description,
    final String? parkingInfo,
    final String? accessInstructions,
  }) = _$GameLocationImpl;

  factory _GameLocation.fromJson(Map<String, dynamic> json) =
      _$GameLocationImpl.fromJson;

  @override
  String get name;
  @override
  String? get address;
  @override
  double? get latitude;
  @override
  double? get longitude;
  @override
  String? get description;
  @override
  String? get parkingInfo;
  @override
  String? get accessInstructions;

  /// Create a copy of GameLocation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameLocationImplCopyWith<_$GameLocationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GameScore _$GameScoreFromJson(Map<String, dynamic> json) {
  return _GameScore.fromJson(json);
}

/// @nodoc
mixin _$GameScore {
  String get playerId => throw _privateConstructorUsedError;
  int get score => throw _privateConstructorUsedError;
  int get sets => throw _privateConstructorUsedError;
  int get gamesWon => throw _privateConstructorUsedError;
  Map<String, dynamic>? get additionalStats =>
      throw _privateConstructorUsedError;

  /// Serializes this GameScore to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameScore
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameScoreCopyWith<GameScore> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameScoreCopyWith<$Res> {
  factory $GameScoreCopyWith(GameScore value, $Res Function(GameScore) then) =
      _$GameScoreCopyWithImpl<$Res, GameScore>;
  @useResult
  $Res call({
    String playerId,
    int score,
    int sets,
    int gamesWon,
    Map<String, dynamic>? additionalStats,
  });
}

/// @nodoc
class _$GameScoreCopyWithImpl<$Res, $Val extends GameScore>
    implements $GameScoreCopyWith<$Res> {
  _$GameScoreCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameScore
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? playerId = null,
    Object? score = null,
    Object? sets = null,
    Object? gamesWon = null,
    Object? additionalStats = freezed,
  }) {
    return _then(
      _value.copyWith(
            playerId: null == playerId
                ? _value.playerId
                : playerId // ignore: cast_nullable_to_non_nullable
                      as String,
            score: null == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as int,
            sets: null == sets
                ? _value.sets
                : sets // ignore: cast_nullable_to_non_nullable
                      as int,
            gamesWon: null == gamesWon
                ? _value.gamesWon
                : gamesWon // ignore: cast_nullable_to_non_nullable
                      as int,
            additionalStats: freezed == additionalStats
                ? _value.additionalStats
                : additionalStats // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GameScoreImplCopyWith<$Res>
    implements $GameScoreCopyWith<$Res> {
  factory _$$GameScoreImplCopyWith(
    _$GameScoreImpl value,
    $Res Function(_$GameScoreImpl) then,
  ) = __$$GameScoreImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String playerId,
    int score,
    int sets,
    int gamesWon,
    Map<String, dynamic>? additionalStats,
  });
}

/// @nodoc
class __$$GameScoreImplCopyWithImpl<$Res>
    extends _$GameScoreCopyWithImpl<$Res, _$GameScoreImpl>
    implements _$$GameScoreImplCopyWith<$Res> {
  __$$GameScoreImplCopyWithImpl(
    _$GameScoreImpl _value,
    $Res Function(_$GameScoreImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameScore
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? playerId = null,
    Object? score = null,
    Object? sets = null,
    Object? gamesWon = null,
    Object? additionalStats = freezed,
  }) {
    return _then(
      _$GameScoreImpl(
        playerId: null == playerId
            ? _value.playerId
            : playerId // ignore: cast_nullable_to_non_nullable
                  as String,
        score: null == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as int,
        sets: null == sets
            ? _value.sets
            : sets // ignore: cast_nullable_to_non_nullable
                  as int,
        gamesWon: null == gamesWon
            ? _value.gamesWon
            : gamesWon // ignore: cast_nullable_to_non_nullable
                  as int,
        additionalStats: freezed == additionalStats
            ? _value._additionalStats
            : additionalStats // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GameScoreImpl implements _GameScore {
  const _$GameScoreImpl({
    required this.playerId,
    required this.score,
    this.sets = 0,
    this.gamesWon = 0,
    final Map<String, dynamic>? additionalStats,
  }) : _additionalStats = additionalStats;

  factory _$GameScoreImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameScoreImplFromJson(json);

  @override
  final String playerId;
  @override
  final int score;
  @override
  @JsonKey()
  final int sets;
  @override
  @JsonKey()
  final int gamesWon;
  final Map<String, dynamic>? _additionalStats;
  @override
  Map<String, dynamic>? get additionalStats {
    final value = _additionalStats;
    if (value == null) return null;
    if (_additionalStats is EqualUnmodifiableMapView) return _additionalStats;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'GameScore(playerId: $playerId, score: $score, sets: $sets, gamesWon: $gamesWon, additionalStats: $additionalStats)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameScoreImpl &&
            (identical(other.playerId, playerId) ||
                other.playerId == playerId) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.sets, sets) || other.sets == sets) &&
            (identical(other.gamesWon, gamesWon) ||
                other.gamesWon == gamesWon) &&
            const DeepCollectionEquality().equals(
              other._additionalStats,
              _additionalStats,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    playerId,
    score,
    sets,
    gamesWon,
    const DeepCollectionEquality().hash(_additionalStats),
  );

  /// Create a copy of GameScore
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameScoreImplCopyWith<_$GameScoreImpl> get copyWith =>
      __$$GameScoreImplCopyWithImpl<_$GameScoreImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GameScoreImplToJson(this);
  }
}

abstract class _GameScore implements GameScore {
  const factory _GameScore({
    required final String playerId,
    required final int score,
    final int sets,
    final int gamesWon,
    final Map<String, dynamic>? additionalStats,
  }) = _$GameScoreImpl;

  factory _GameScore.fromJson(Map<String, dynamic> json) =
      _$GameScoreImpl.fromJson;

  @override
  String get playerId;
  @override
  int get score;
  @override
  int get sets;
  @override
  int get gamesWon;
  @override
  Map<String, dynamic>? get additionalStats;

  /// Create a copy of GameScore
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameScoreImplCopyWith<_$GameScoreImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SetScore _$SetScoreFromJson(Map<String, dynamic> json) {
  return _SetScore.fromJson(json);
}

/// @nodoc
mixin _$SetScore {
  int get teamAPoints => throw _privateConstructorUsedError;
  int get teamBPoints => throw _privateConstructorUsedError;
  int get setNumber => throw _privateConstructorUsedError;

  /// Serializes this SetScore to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SetScore
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SetScoreCopyWith<SetScore> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SetScoreCopyWith<$Res> {
  factory $SetScoreCopyWith(SetScore value, $Res Function(SetScore) then) =
      _$SetScoreCopyWithImpl<$Res, SetScore>;
  @useResult
  $Res call({int teamAPoints, int teamBPoints, int setNumber});
}

/// @nodoc
class _$SetScoreCopyWithImpl<$Res, $Val extends SetScore>
    implements $SetScoreCopyWith<$Res> {
  _$SetScoreCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SetScore
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? teamAPoints = null,
    Object? teamBPoints = null,
    Object? setNumber = null,
  }) {
    return _then(
      _value.copyWith(
            teamAPoints: null == teamAPoints
                ? _value.teamAPoints
                : teamAPoints // ignore: cast_nullable_to_non_nullable
                      as int,
            teamBPoints: null == teamBPoints
                ? _value.teamBPoints
                : teamBPoints // ignore: cast_nullable_to_non_nullable
                      as int,
            setNumber: null == setNumber
                ? _value.setNumber
                : setNumber // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SetScoreImplCopyWith<$Res>
    implements $SetScoreCopyWith<$Res> {
  factory _$$SetScoreImplCopyWith(
    _$SetScoreImpl value,
    $Res Function(_$SetScoreImpl) then,
  ) = __$$SetScoreImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int teamAPoints, int teamBPoints, int setNumber});
}

/// @nodoc
class __$$SetScoreImplCopyWithImpl<$Res>
    extends _$SetScoreCopyWithImpl<$Res, _$SetScoreImpl>
    implements _$$SetScoreImplCopyWith<$Res> {
  __$$SetScoreImplCopyWithImpl(
    _$SetScoreImpl _value,
    $Res Function(_$SetScoreImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SetScore
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? teamAPoints = null,
    Object? teamBPoints = null,
    Object? setNumber = null,
  }) {
    return _then(
      _$SetScoreImpl(
        teamAPoints: null == teamAPoints
            ? _value.teamAPoints
            : teamAPoints // ignore: cast_nullable_to_non_nullable
                  as int,
        teamBPoints: null == teamBPoints
            ? _value.teamBPoints
            : teamBPoints // ignore: cast_nullable_to_non_nullable
                  as int,
        setNumber: null == setNumber
            ? _value.setNumber
            : setNumber // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SetScoreImpl extends _SetScore {
  const _$SetScoreImpl({
    required this.teamAPoints,
    required this.teamBPoints,
    required this.setNumber,
  }) : super._();

  factory _$SetScoreImpl.fromJson(Map<String, dynamic> json) =>
      _$$SetScoreImplFromJson(json);

  @override
  final int teamAPoints;
  @override
  final int teamBPoints;
  @override
  final int setNumber;

  @override
  String toString() {
    return 'SetScore(teamAPoints: $teamAPoints, teamBPoints: $teamBPoints, setNumber: $setNumber)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SetScoreImpl &&
            (identical(other.teamAPoints, teamAPoints) ||
                other.teamAPoints == teamAPoints) &&
            (identical(other.teamBPoints, teamBPoints) ||
                other.teamBPoints == teamBPoints) &&
            (identical(other.setNumber, setNumber) ||
                other.setNumber == setNumber));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, teamAPoints, teamBPoints, setNumber);

  /// Create a copy of SetScore
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SetScoreImplCopyWith<_$SetScoreImpl> get copyWith =>
      __$$SetScoreImplCopyWithImpl<_$SetScoreImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SetScoreImplToJson(this);
  }
}

abstract class _SetScore extends SetScore {
  const factory _SetScore({
    required final int teamAPoints,
    required final int teamBPoints,
    required final int setNumber,
  }) = _$SetScoreImpl;
  const _SetScore._() : super._();

  factory _SetScore.fromJson(Map<String, dynamic> json) =
      _$SetScoreImpl.fromJson;

  @override
  int get teamAPoints;
  @override
  int get teamBPoints;
  @override
  int get setNumber;

  /// Create a copy of SetScore
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SetScoreImplCopyWith<_$SetScoreImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

IndividualGame _$IndividualGameFromJson(Map<String, dynamic> json) {
  return _IndividualGame.fromJson(json);
}

/// @nodoc
mixin _$IndividualGame {
  int get gameNumber =>
      throw _privateConstructorUsedError; // 1, 2, 3, etc. within the session
  @SetScoreListConverter()
  List<SetScore> get sets => throw _privateConstructorUsedError;
  String get winner => throw _privateConstructorUsedError;

  /// Serializes this IndividualGame to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of IndividualGame
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $IndividualGameCopyWith<IndividualGame> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IndividualGameCopyWith<$Res> {
  factory $IndividualGameCopyWith(
    IndividualGame value,
    $Res Function(IndividualGame) then,
  ) = _$IndividualGameCopyWithImpl<$Res, IndividualGame>;
  @useResult
  $Res call({
    int gameNumber,
    @SetScoreListConverter() List<SetScore> sets,
    String winner,
  });
}

/// @nodoc
class _$IndividualGameCopyWithImpl<$Res, $Val extends IndividualGame>
    implements $IndividualGameCopyWith<$Res> {
  _$IndividualGameCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of IndividualGame
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gameNumber = null,
    Object? sets = null,
    Object? winner = null,
  }) {
    return _then(
      _value.copyWith(
            gameNumber: null == gameNumber
                ? _value.gameNumber
                : gameNumber // ignore: cast_nullable_to_non_nullable
                      as int,
            sets: null == sets
                ? _value.sets
                : sets // ignore: cast_nullable_to_non_nullable
                      as List<SetScore>,
            winner: null == winner
                ? _value.winner
                : winner // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$IndividualGameImplCopyWith<$Res>
    implements $IndividualGameCopyWith<$Res> {
  factory _$$IndividualGameImplCopyWith(
    _$IndividualGameImpl value,
    $Res Function(_$IndividualGameImpl) then,
  ) = __$$IndividualGameImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int gameNumber,
    @SetScoreListConverter() List<SetScore> sets,
    String winner,
  });
}

/// @nodoc
class __$$IndividualGameImplCopyWithImpl<$Res>
    extends _$IndividualGameCopyWithImpl<$Res, _$IndividualGameImpl>
    implements _$$IndividualGameImplCopyWith<$Res> {
  __$$IndividualGameImplCopyWithImpl(
    _$IndividualGameImpl _value,
    $Res Function(_$IndividualGameImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of IndividualGame
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gameNumber = null,
    Object? sets = null,
    Object? winner = null,
  }) {
    return _then(
      _$IndividualGameImpl(
        gameNumber: null == gameNumber
            ? _value.gameNumber
            : gameNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        sets: null == sets
            ? _value._sets
            : sets // ignore: cast_nullable_to_non_nullable
                  as List<SetScore>,
        winner: null == winner
            ? _value.winner
            : winner // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$IndividualGameImpl extends _IndividualGame {
  const _$IndividualGameImpl({
    required this.gameNumber,
    @SetScoreListConverter() required final List<SetScore> sets,
    required this.winner,
  }) : _sets = sets,
       super._();

  factory _$IndividualGameImpl.fromJson(Map<String, dynamic> json) =>
      _$$IndividualGameImplFromJson(json);

  @override
  final int gameNumber;
  // 1, 2, 3, etc. within the session
  final List<SetScore> _sets;
  // 1, 2, 3, etc. within the session
  @override
  @SetScoreListConverter()
  List<SetScore> get sets {
    if (_sets is EqualUnmodifiableListView) return _sets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sets);
  }

  @override
  final String winner;

  @override
  String toString() {
    return 'IndividualGame(gameNumber: $gameNumber, sets: $sets, winner: $winner)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IndividualGameImpl &&
            (identical(other.gameNumber, gameNumber) ||
                other.gameNumber == gameNumber) &&
            const DeepCollectionEquality().equals(other._sets, _sets) &&
            (identical(other.winner, winner) || other.winner == winner));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    gameNumber,
    const DeepCollectionEquality().hash(_sets),
    winner,
  );

  /// Create a copy of IndividualGame
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$IndividualGameImplCopyWith<_$IndividualGameImpl> get copyWith =>
      __$$IndividualGameImplCopyWithImpl<_$IndividualGameImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$IndividualGameImplToJson(this);
  }
}

abstract class _IndividualGame extends IndividualGame {
  const factory _IndividualGame({
    required final int gameNumber,
    @SetScoreListConverter() required final List<SetScore> sets,
    required final String winner,
  }) = _$IndividualGameImpl;
  const _IndividualGame._() : super._();

  factory _IndividualGame.fromJson(Map<String, dynamic> json) =
      _$IndividualGameImpl.fromJson;

  @override
  int get gameNumber; // 1, 2, 3, etc. within the session
  @override
  @SetScoreListConverter()
  List<SetScore> get sets;
  @override
  String get winner;

  /// Create a copy of IndividualGame
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$IndividualGameImplCopyWith<_$IndividualGameImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GameResult _$GameResultFromJson(Map<String, dynamic> json) {
  return _GameResult.fromJson(json);
}

/// @nodoc
mixin _$GameResult {
  @IndividualGameListConverter()
  List<IndividualGame> get games => throw _privateConstructorUsedError;
  String get overallWinner => throw _privateConstructorUsedError;

  /// Serializes this GameResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameResultCopyWith<GameResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameResultCopyWith<$Res> {
  factory $GameResultCopyWith(
    GameResult value,
    $Res Function(GameResult) then,
  ) = _$GameResultCopyWithImpl<$Res, GameResult>;
  @useResult
  $Res call({
    @IndividualGameListConverter() List<IndividualGame> games,
    String overallWinner,
  });
}

/// @nodoc
class _$GameResultCopyWithImpl<$Res, $Val extends GameResult>
    implements $GameResultCopyWith<$Res> {
  _$GameResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? games = null, Object? overallWinner = null}) {
    return _then(
      _value.copyWith(
            games: null == games
                ? _value.games
                : games // ignore: cast_nullable_to_non_nullable
                      as List<IndividualGame>,
            overallWinner: null == overallWinner
                ? _value.overallWinner
                : overallWinner // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GameResultImplCopyWith<$Res>
    implements $GameResultCopyWith<$Res> {
  factory _$$GameResultImplCopyWith(
    _$GameResultImpl value,
    $Res Function(_$GameResultImpl) then,
  ) = __$$GameResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @IndividualGameListConverter() List<IndividualGame> games,
    String overallWinner,
  });
}

/// @nodoc
class __$$GameResultImplCopyWithImpl<$Res>
    extends _$GameResultCopyWithImpl<$Res, _$GameResultImpl>
    implements _$$GameResultImplCopyWith<$Res> {
  __$$GameResultImplCopyWithImpl(
    _$GameResultImpl _value,
    $Res Function(_$GameResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? games = null, Object? overallWinner = null}) {
    return _then(
      _$GameResultImpl(
        games: null == games
            ? _value._games
            : games // ignore: cast_nullable_to_non_nullable
                  as List<IndividualGame>,
        overallWinner: null == overallWinner
            ? _value.overallWinner
            : overallWinner // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GameResultImpl extends _GameResult {
  const _$GameResultImpl({
    @IndividualGameListConverter() required final List<IndividualGame> games,
    required this.overallWinner,
  }) : _games = games,
       super._();

  factory _$GameResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameResultImplFromJson(json);

  final List<IndividualGame> _games;
  @override
  @IndividualGameListConverter()
  List<IndividualGame> get games {
    if (_games is EqualUnmodifiableListView) return _games;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_games);
  }

  @override
  final String overallWinner;

  @override
  String toString() {
    return 'GameResult(games: $games, overallWinner: $overallWinner)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameResultImpl &&
            const DeepCollectionEquality().equals(other._games, _games) &&
            (identical(other.overallWinner, overallWinner) ||
                other.overallWinner == overallWinner));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_games),
    overallWinner,
  );

  /// Create a copy of GameResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameResultImplCopyWith<_$GameResultImpl> get copyWith =>
      __$$GameResultImplCopyWithImpl<_$GameResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GameResultImplToJson(this);
  }
}

abstract class _GameResult extends GameResult {
  const factory _GameResult({
    @IndividualGameListConverter() required final List<IndividualGame> games,
    required final String overallWinner,
  }) = _$GameResultImpl;
  const _GameResult._() : super._();

  factory _GameResult.fromJson(Map<String, dynamic> json) =
      _$GameResultImpl.fromJson;

  @override
  @IndividualGameListConverter()
  List<IndividualGame> get games;
  @override
  String get overallWinner;

  /// Create a copy of GameResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameResultImplCopyWith<_$GameResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
