// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_preferences_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

NotificationPreferencesEntity _$NotificationPreferencesEntityFromJson(
  Map<String, dynamic> json,
) {
  return _NotificationPreferencesEntity.fromJson(json);
}

/// @nodoc
mixin _$NotificationPreferencesEntity {
  bool get groupInvitations => throw _privateConstructorUsedError;
  bool get invitationAccepted => throw _privateConstructorUsedError;
  bool get gameCreated => throw _privateConstructorUsedError;
  bool get memberJoined => throw _privateConstructorUsedError;
  bool get memberLeft => throw _privateConstructorUsedError;
  bool get roleChanged => throw _privateConstructorUsedError;
  bool get friendRequestReceived => throw _privateConstructorUsedError;
  bool get friendRequestAccepted => throw _privateConstructorUsedError;
  bool get friendRemoved => throw _privateConstructorUsedError;
  bool get quietHoursEnabled => throw _privateConstructorUsedError;
  String? get quietHoursStart => throw _privateConstructorUsedError;
  String? get quietHoursEnd => throw _privateConstructorUsedError;
  Map<String, bool> get groupSpecific => throw _privateConstructorUsedError;

  /// Serializes this NotificationPreferencesEntity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationPreferencesEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationPreferencesEntityCopyWith<NotificationPreferencesEntity>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationPreferencesEntityCopyWith<$Res> {
  factory $NotificationPreferencesEntityCopyWith(
    NotificationPreferencesEntity value,
    $Res Function(NotificationPreferencesEntity) then,
  ) =
      _$NotificationPreferencesEntityCopyWithImpl<
        $Res,
        NotificationPreferencesEntity
      >;
  @useResult
  $Res call({
    bool groupInvitations,
    bool invitationAccepted,
    bool gameCreated,
    bool memberJoined,
    bool memberLeft,
    bool roleChanged,
    bool friendRequestReceived,
    bool friendRequestAccepted,
    bool friendRemoved,
    bool quietHoursEnabled,
    String? quietHoursStart,
    String? quietHoursEnd,
    Map<String, bool> groupSpecific,
  });
}

/// @nodoc
class _$NotificationPreferencesEntityCopyWithImpl<
  $Res,
  $Val extends NotificationPreferencesEntity
>
    implements $NotificationPreferencesEntityCopyWith<$Res> {
  _$NotificationPreferencesEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationPreferencesEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? groupInvitations = null,
    Object? invitationAccepted = null,
    Object? gameCreated = null,
    Object? memberJoined = null,
    Object? memberLeft = null,
    Object? roleChanged = null,
    Object? friendRequestReceived = null,
    Object? friendRequestAccepted = null,
    Object? friendRemoved = null,
    Object? quietHoursEnabled = null,
    Object? quietHoursStart = freezed,
    Object? quietHoursEnd = freezed,
    Object? groupSpecific = null,
  }) {
    return _then(
      _value.copyWith(
            groupInvitations: null == groupInvitations
                ? _value.groupInvitations
                : groupInvitations // ignore: cast_nullable_to_non_nullable
                      as bool,
            invitationAccepted: null == invitationAccepted
                ? _value.invitationAccepted
                : invitationAccepted // ignore: cast_nullable_to_non_nullable
                      as bool,
            gameCreated: null == gameCreated
                ? _value.gameCreated
                : gameCreated // ignore: cast_nullable_to_non_nullable
                      as bool,
            memberJoined: null == memberJoined
                ? _value.memberJoined
                : memberJoined // ignore: cast_nullable_to_non_nullable
                      as bool,
            memberLeft: null == memberLeft
                ? _value.memberLeft
                : memberLeft // ignore: cast_nullable_to_non_nullable
                      as bool,
            roleChanged: null == roleChanged
                ? _value.roleChanged
                : roleChanged // ignore: cast_nullable_to_non_nullable
                      as bool,
            friendRequestReceived: null == friendRequestReceived
                ? _value.friendRequestReceived
                : friendRequestReceived // ignore: cast_nullable_to_non_nullable
                      as bool,
            friendRequestAccepted: null == friendRequestAccepted
                ? _value.friendRequestAccepted
                : friendRequestAccepted // ignore: cast_nullable_to_non_nullable
                      as bool,
            friendRemoved: null == friendRemoved
                ? _value.friendRemoved
                : friendRemoved // ignore: cast_nullable_to_non_nullable
                      as bool,
            quietHoursEnabled: null == quietHoursEnabled
                ? _value.quietHoursEnabled
                : quietHoursEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            quietHoursStart: freezed == quietHoursStart
                ? _value.quietHoursStart
                : quietHoursStart // ignore: cast_nullable_to_non_nullable
                      as String?,
            quietHoursEnd: freezed == quietHoursEnd
                ? _value.quietHoursEnd
                : quietHoursEnd // ignore: cast_nullable_to_non_nullable
                      as String?,
            groupSpecific: null == groupSpecific
                ? _value.groupSpecific
                : groupSpecific // ignore: cast_nullable_to_non_nullable
                      as Map<String, bool>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NotificationPreferencesEntityImplCopyWith<$Res>
    implements $NotificationPreferencesEntityCopyWith<$Res> {
  factory _$$NotificationPreferencesEntityImplCopyWith(
    _$NotificationPreferencesEntityImpl value,
    $Res Function(_$NotificationPreferencesEntityImpl) then,
  ) = __$$NotificationPreferencesEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool groupInvitations,
    bool invitationAccepted,
    bool gameCreated,
    bool memberJoined,
    bool memberLeft,
    bool roleChanged,
    bool friendRequestReceived,
    bool friendRequestAccepted,
    bool friendRemoved,
    bool quietHoursEnabled,
    String? quietHoursStart,
    String? quietHoursEnd,
    Map<String, bool> groupSpecific,
  });
}

/// @nodoc
class __$$NotificationPreferencesEntityImplCopyWithImpl<$Res>
    extends
        _$NotificationPreferencesEntityCopyWithImpl<
          $Res,
          _$NotificationPreferencesEntityImpl
        >
    implements _$$NotificationPreferencesEntityImplCopyWith<$Res> {
  __$$NotificationPreferencesEntityImplCopyWithImpl(
    _$NotificationPreferencesEntityImpl _value,
    $Res Function(_$NotificationPreferencesEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NotificationPreferencesEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? groupInvitations = null,
    Object? invitationAccepted = null,
    Object? gameCreated = null,
    Object? memberJoined = null,
    Object? memberLeft = null,
    Object? roleChanged = null,
    Object? friendRequestReceived = null,
    Object? friendRequestAccepted = null,
    Object? friendRemoved = null,
    Object? quietHoursEnabled = null,
    Object? quietHoursStart = freezed,
    Object? quietHoursEnd = freezed,
    Object? groupSpecific = null,
  }) {
    return _then(
      _$NotificationPreferencesEntityImpl(
        groupInvitations: null == groupInvitations
            ? _value.groupInvitations
            : groupInvitations // ignore: cast_nullable_to_non_nullable
                  as bool,
        invitationAccepted: null == invitationAccepted
            ? _value.invitationAccepted
            : invitationAccepted // ignore: cast_nullable_to_non_nullable
                  as bool,
        gameCreated: null == gameCreated
            ? _value.gameCreated
            : gameCreated // ignore: cast_nullable_to_non_nullable
                  as bool,
        memberJoined: null == memberJoined
            ? _value.memberJoined
            : memberJoined // ignore: cast_nullable_to_non_nullable
                  as bool,
        memberLeft: null == memberLeft
            ? _value.memberLeft
            : memberLeft // ignore: cast_nullable_to_non_nullable
                  as bool,
        roleChanged: null == roleChanged
            ? _value.roleChanged
            : roleChanged // ignore: cast_nullable_to_non_nullable
                  as bool,
        friendRequestReceived: null == friendRequestReceived
            ? _value.friendRequestReceived
            : friendRequestReceived // ignore: cast_nullable_to_non_nullable
                  as bool,
        friendRequestAccepted: null == friendRequestAccepted
            ? _value.friendRequestAccepted
            : friendRequestAccepted // ignore: cast_nullable_to_non_nullable
                  as bool,
        friendRemoved: null == friendRemoved
            ? _value.friendRemoved
            : friendRemoved // ignore: cast_nullable_to_non_nullable
                  as bool,
        quietHoursEnabled: null == quietHoursEnabled
            ? _value.quietHoursEnabled
            : quietHoursEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        quietHoursStart: freezed == quietHoursStart
            ? _value.quietHoursStart
            : quietHoursStart // ignore: cast_nullable_to_non_nullable
                  as String?,
        quietHoursEnd: freezed == quietHoursEnd
            ? _value.quietHoursEnd
            : quietHoursEnd // ignore: cast_nullable_to_non_nullable
                  as String?,
        groupSpecific: null == groupSpecific
            ? _value._groupSpecific
            : groupSpecific // ignore: cast_nullable_to_non_nullable
                  as Map<String, bool>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationPreferencesEntityImpl
    extends _NotificationPreferencesEntity {
  const _$NotificationPreferencesEntityImpl({
    this.groupInvitations = true,
    this.invitationAccepted = true,
    this.gameCreated = true,
    this.memberJoined = false,
    this.memberLeft = false,
    this.roleChanged = true,
    this.friendRequestReceived = true,
    this.friendRequestAccepted = true,
    this.friendRemoved = false,
    this.quietHoursEnabled = false,
    this.quietHoursStart,
    this.quietHoursEnd,
    final Map<String, bool> groupSpecific = const {},
  }) : _groupSpecific = groupSpecific,
       super._();

  factory _$NotificationPreferencesEntityImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$NotificationPreferencesEntityImplFromJson(json);

  @override
  @JsonKey()
  final bool groupInvitations;
  @override
  @JsonKey()
  final bool invitationAccepted;
  @override
  @JsonKey()
  final bool gameCreated;
  @override
  @JsonKey()
  final bool memberJoined;
  @override
  @JsonKey()
  final bool memberLeft;
  @override
  @JsonKey()
  final bool roleChanged;
  @override
  @JsonKey()
  final bool friendRequestReceived;
  @override
  @JsonKey()
  final bool friendRequestAccepted;
  @override
  @JsonKey()
  final bool friendRemoved;
  @override
  @JsonKey()
  final bool quietHoursEnabled;
  @override
  final String? quietHoursStart;
  @override
  final String? quietHoursEnd;
  final Map<String, bool> _groupSpecific;
  @override
  @JsonKey()
  Map<String, bool> get groupSpecific {
    if (_groupSpecific is EqualUnmodifiableMapView) return _groupSpecific;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_groupSpecific);
  }

  @override
  String toString() {
    return 'NotificationPreferencesEntity(groupInvitations: $groupInvitations, invitationAccepted: $invitationAccepted, gameCreated: $gameCreated, memberJoined: $memberJoined, memberLeft: $memberLeft, roleChanged: $roleChanged, friendRequestReceived: $friendRequestReceived, friendRequestAccepted: $friendRequestAccepted, friendRemoved: $friendRemoved, quietHoursEnabled: $quietHoursEnabled, quietHoursStart: $quietHoursStart, quietHoursEnd: $quietHoursEnd, groupSpecific: $groupSpecific)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationPreferencesEntityImpl &&
            (identical(other.groupInvitations, groupInvitations) ||
                other.groupInvitations == groupInvitations) &&
            (identical(other.invitationAccepted, invitationAccepted) ||
                other.invitationAccepted == invitationAccepted) &&
            (identical(other.gameCreated, gameCreated) ||
                other.gameCreated == gameCreated) &&
            (identical(other.memberJoined, memberJoined) ||
                other.memberJoined == memberJoined) &&
            (identical(other.memberLeft, memberLeft) ||
                other.memberLeft == memberLeft) &&
            (identical(other.roleChanged, roleChanged) ||
                other.roleChanged == roleChanged) &&
            (identical(other.friendRequestReceived, friendRequestReceived) ||
                other.friendRequestReceived == friendRequestReceived) &&
            (identical(other.friendRequestAccepted, friendRequestAccepted) ||
                other.friendRequestAccepted == friendRequestAccepted) &&
            (identical(other.friendRemoved, friendRemoved) ||
                other.friendRemoved == friendRemoved) &&
            (identical(other.quietHoursEnabled, quietHoursEnabled) ||
                other.quietHoursEnabled == quietHoursEnabled) &&
            (identical(other.quietHoursStart, quietHoursStart) ||
                other.quietHoursStart == quietHoursStart) &&
            (identical(other.quietHoursEnd, quietHoursEnd) ||
                other.quietHoursEnd == quietHoursEnd) &&
            const DeepCollectionEquality().equals(
              other._groupSpecific,
              _groupSpecific,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    groupInvitations,
    invitationAccepted,
    gameCreated,
    memberJoined,
    memberLeft,
    roleChanged,
    friendRequestReceived,
    friendRequestAccepted,
    friendRemoved,
    quietHoursEnabled,
    quietHoursStart,
    quietHoursEnd,
    const DeepCollectionEquality().hash(_groupSpecific),
  );

  /// Create a copy of NotificationPreferencesEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationPreferencesEntityImplCopyWith<
    _$NotificationPreferencesEntityImpl
  >
  get copyWith =>
      __$$NotificationPreferencesEntityImplCopyWithImpl<
        _$NotificationPreferencesEntityImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationPreferencesEntityImplToJson(this);
  }
}

abstract class _NotificationPreferencesEntity
    extends NotificationPreferencesEntity {
  const factory _NotificationPreferencesEntity({
    final bool groupInvitations,
    final bool invitationAccepted,
    final bool gameCreated,
    final bool memberJoined,
    final bool memberLeft,
    final bool roleChanged,
    final bool friendRequestReceived,
    final bool friendRequestAccepted,
    final bool friendRemoved,
    final bool quietHoursEnabled,
    final String? quietHoursStart,
    final String? quietHoursEnd,
    final Map<String, bool> groupSpecific,
  }) = _$NotificationPreferencesEntityImpl;
  const _NotificationPreferencesEntity._() : super._();

  factory _NotificationPreferencesEntity.fromJson(Map<String, dynamic> json) =
      _$NotificationPreferencesEntityImpl.fromJson;

  @override
  bool get groupInvitations;
  @override
  bool get invitationAccepted;
  @override
  bool get gameCreated;
  @override
  bool get memberJoined;
  @override
  bool get memberLeft;
  @override
  bool get roleChanged;
  @override
  bool get friendRequestReceived;
  @override
  bool get friendRequestAccepted;
  @override
  bool get friendRemoved;
  @override
  bool get quietHoursEnabled;
  @override
  String? get quietHoursStart;
  @override
  String? get quietHoursEnd;
  @override
  Map<String, bool> get groupSpecific;

  /// Create a copy of NotificationPreferencesEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationPreferencesEntityImplCopyWith<
    _$NotificationPreferencesEntityImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}
