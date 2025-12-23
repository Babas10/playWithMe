// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'partner_detail_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$PartnerDetailEvent {
  String get userId => throw _privateConstructorUsedError;
  String get partnerId => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String userId, String partnerId)
    loadPartnerDetails,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String userId, String partnerId)? loadPartnerDetails,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String userId, String partnerId)? loadPartnerDetails,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadPartnerDetails value) loadPartnerDetails,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadPartnerDetails value)? loadPartnerDetails,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadPartnerDetails value)? loadPartnerDetails,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Create a copy of PartnerDetailEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PartnerDetailEventCopyWith<PartnerDetailEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PartnerDetailEventCopyWith<$Res> {
  factory $PartnerDetailEventCopyWith(
    PartnerDetailEvent value,
    $Res Function(PartnerDetailEvent) then,
  ) = _$PartnerDetailEventCopyWithImpl<$Res, PartnerDetailEvent>;
  @useResult
  $Res call({String userId, String partnerId});
}

/// @nodoc
class _$PartnerDetailEventCopyWithImpl<$Res, $Val extends PartnerDetailEvent>
    implements $PartnerDetailEventCopyWith<$Res> {
  _$PartnerDetailEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PartnerDetailEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? userId = null, Object? partnerId = null}) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            partnerId: null == partnerId
                ? _value.partnerId
                : partnerId // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LoadPartnerDetailsImplCopyWith<$Res>
    implements $PartnerDetailEventCopyWith<$Res> {
  factory _$$LoadPartnerDetailsImplCopyWith(
    _$LoadPartnerDetailsImpl value,
    $Res Function(_$LoadPartnerDetailsImpl) then,
  ) = __$$LoadPartnerDetailsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String userId, String partnerId});
}

/// @nodoc
class __$$LoadPartnerDetailsImplCopyWithImpl<$Res>
    extends _$PartnerDetailEventCopyWithImpl<$Res, _$LoadPartnerDetailsImpl>
    implements _$$LoadPartnerDetailsImplCopyWith<$Res> {
  __$$LoadPartnerDetailsImplCopyWithImpl(
    _$LoadPartnerDetailsImpl _value,
    $Res Function(_$LoadPartnerDetailsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PartnerDetailEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? userId = null, Object? partnerId = null}) {
    return _then(
      _$LoadPartnerDetailsImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        partnerId: null == partnerId
            ? _value.partnerId
            : partnerId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$LoadPartnerDetailsImpl implements LoadPartnerDetails {
  const _$LoadPartnerDetailsImpl({
    required this.userId,
    required this.partnerId,
  });

  @override
  final String userId;
  @override
  final String partnerId;

  @override
  String toString() {
    return 'PartnerDetailEvent.loadPartnerDetails(userId: $userId, partnerId: $partnerId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoadPartnerDetailsImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.partnerId, partnerId) ||
                other.partnerId == partnerId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, userId, partnerId);

  /// Create a copy of PartnerDetailEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoadPartnerDetailsImplCopyWith<_$LoadPartnerDetailsImpl> get copyWith =>
      __$$LoadPartnerDetailsImplCopyWithImpl<_$LoadPartnerDetailsImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String userId, String partnerId)
    loadPartnerDetails,
  }) {
    return loadPartnerDetails(userId, partnerId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String userId, String partnerId)? loadPartnerDetails,
  }) {
    return loadPartnerDetails?.call(userId, partnerId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String userId, String partnerId)? loadPartnerDetails,
    required TResult orElse(),
  }) {
    if (loadPartnerDetails != null) {
      return loadPartnerDetails(userId, partnerId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadPartnerDetails value) loadPartnerDetails,
  }) {
    return loadPartnerDetails(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadPartnerDetails value)? loadPartnerDetails,
  }) {
    return loadPartnerDetails?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadPartnerDetails value)? loadPartnerDetails,
    required TResult orElse(),
  }) {
    if (loadPartnerDetails != null) {
      return loadPartnerDetails(this);
    }
    return orElse();
  }
}

abstract class LoadPartnerDetails implements PartnerDetailEvent {
  const factory LoadPartnerDetails({
    required final String userId,
    required final String partnerId,
  }) = _$LoadPartnerDetailsImpl;

  @override
  String get userId;
  @override
  String get partnerId;

  /// Create a copy of PartnerDetailEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoadPartnerDetailsImplCopyWith<_$LoadPartnerDetailsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
