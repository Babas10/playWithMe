// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group_activity_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$GroupActivityItem {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(GameModel game) game,
    required TResult Function(TrainingSessionModel session) training,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(GameModel game)? game,
    TResult? Function(TrainingSessionModel session)? training,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(GameModel game)? game,
    TResult Function(TrainingSessionModel session)? training,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GameActivityItem value) game,
    required TResult Function(TrainingActivityItem value) training,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GameActivityItem value)? game,
    TResult? Function(TrainingActivityItem value)? training,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GameActivityItem value)? game,
    TResult Function(TrainingActivityItem value)? training,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GroupActivityItemCopyWith<$Res> {
  factory $GroupActivityItemCopyWith(
    GroupActivityItem value,
    $Res Function(GroupActivityItem) then,
  ) = _$GroupActivityItemCopyWithImpl<$Res, GroupActivityItem>;
}

/// @nodoc
class _$GroupActivityItemCopyWithImpl<$Res, $Val extends GroupActivityItem>
    implements $GroupActivityItemCopyWith<$Res> {
  _$GroupActivityItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GroupActivityItem
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$GameActivityItemImplCopyWith<$Res> {
  factory _$$GameActivityItemImplCopyWith(
    _$GameActivityItemImpl value,
    $Res Function(_$GameActivityItemImpl) then,
  ) = __$$GameActivityItemImplCopyWithImpl<$Res>;
  @useResult
  $Res call({GameModel game});

  $GameModelCopyWith<$Res> get game;
}

/// @nodoc
class __$$GameActivityItemImplCopyWithImpl<$Res>
    extends _$GroupActivityItemCopyWithImpl<$Res, _$GameActivityItemImpl>
    implements _$$GameActivityItemImplCopyWith<$Res> {
  __$$GameActivityItemImplCopyWithImpl(
    _$GameActivityItemImpl _value,
    $Res Function(_$GameActivityItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GroupActivityItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? game = null}) {
    return _then(
      _$GameActivityItemImpl(
        null == game
            ? _value.game
            : game // ignore: cast_nullable_to_non_nullable
                  as GameModel,
      ),
    );
  }

  /// Create a copy of GroupActivityItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GameModelCopyWith<$Res> get game {
    return $GameModelCopyWith<$Res>(_value.game, (value) {
      return _then(_value.copyWith(game: value));
    });
  }
}

/// @nodoc

class _$GameActivityItemImpl extends GameActivityItem {
  const _$GameActivityItemImpl(this.game) : super._();

  @override
  final GameModel game;

  @override
  String toString() {
    return 'GroupActivityItem.game(game: $game)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameActivityItemImpl &&
            (identical(other.game, game) || other.game == game));
  }

  @override
  int get hashCode => Object.hash(runtimeType, game);

  /// Create a copy of GroupActivityItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameActivityItemImplCopyWith<_$GameActivityItemImpl> get copyWith =>
      __$$GameActivityItemImplCopyWithImpl<_$GameActivityItemImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(GameModel game) game,
    required TResult Function(TrainingSessionModel session) training,
  }) {
    return game(this.game);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(GameModel game)? game,
    TResult? Function(TrainingSessionModel session)? training,
  }) {
    return game?.call(this.game);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(GameModel game)? game,
    TResult Function(TrainingSessionModel session)? training,
    required TResult orElse(),
  }) {
    if (game != null) {
      return game(this.game);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GameActivityItem value) game,
    required TResult Function(TrainingActivityItem value) training,
  }) {
    return game(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GameActivityItem value)? game,
    TResult? Function(TrainingActivityItem value)? training,
  }) {
    return game?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GameActivityItem value)? game,
    TResult Function(TrainingActivityItem value)? training,
    required TResult orElse(),
  }) {
    if (game != null) {
      return game(this);
    }
    return orElse();
  }
}

abstract class GameActivityItem extends GroupActivityItem {
  const factory GameActivityItem(final GameModel game) = _$GameActivityItemImpl;
  const GameActivityItem._() : super._();

  GameModel get game;

  /// Create a copy of GroupActivityItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameActivityItemImplCopyWith<_$GameActivityItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$TrainingActivityItemImplCopyWith<$Res> {
  factory _$$TrainingActivityItemImplCopyWith(
    _$TrainingActivityItemImpl value,
    $Res Function(_$TrainingActivityItemImpl) then,
  ) = __$$TrainingActivityItemImplCopyWithImpl<$Res>;
  @useResult
  $Res call({TrainingSessionModel session});

  $TrainingSessionModelCopyWith<$Res> get session;
}

/// @nodoc
class __$$TrainingActivityItemImplCopyWithImpl<$Res>
    extends _$GroupActivityItemCopyWithImpl<$Res, _$TrainingActivityItemImpl>
    implements _$$TrainingActivityItemImplCopyWith<$Res> {
  __$$TrainingActivityItemImplCopyWithImpl(
    _$TrainingActivityItemImpl _value,
    $Res Function(_$TrainingActivityItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GroupActivityItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? session = null}) {
    return _then(
      _$TrainingActivityItemImpl(
        null == session
            ? _value.session
            : session // ignore: cast_nullable_to_non_nullable
                  as TrainingSessionModel,
      ),
    );
  }

  /// Create a copy of GroupActivityItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TrainingSessionModelCopyWith<$Res> get session {
    return $TrainingSessionModelCopyWith<$Res>(_value.session, (value) {
      return _then(_value.copyWith(session: value));
    });
  }
}

/// @nodoc

class _$TrainingActivityItemImpl extends TrainingActivityItem {
  const _$TrainingActivityItemImpl(this.session) : super._();

  @override
  final TrainingSessionModel session;

  @override
  String toString() {
    return 'GroupActivityItem.training(session: $session)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainingActivityItemImpl &&
            (identical(other.session, session) || other.session == session));
  }

  @override
  int get hashCode => Object.hash(runtimeType, session);

  /// Create a copy of GroupActivityItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainingActivityItemImplCopyWith<_$TrainingActivityItemImpl>
  get copyWith =>
      __$$TrainingActivityItemImplCopyWithImpl<_$TrainingActivityItemImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(GameModel game) game,
    required TResult Function(TrainingSessionModel session) training,
  }) {
    return training(session);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(GameModel game)? game,
    TResult? Function(TrainingSessionModel session)? training,
  }) {
    return training?.call(session);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(GameModel game)? game,
    TResult Function(TrainingSessionModel session)? training,
    required TResult orElse(),
  }) {
    if (training != null) {
      return training(session);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GameActivityItem value) game,
    required TResult Function(TrainingActivityItem value) training,
  }) {
    return training(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GameActivityItem value)? game,
    TResult? Function(TrainingActivityItem value)? training,
  }) {
    return training?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GameActivityItem value)? game,
    TResult Function(TrainingActivityItem value)? training,
    required TResult orElse(),
  }) {
    if (training != null) {
      return training(this);
    }
    return orElse();
  }
}

abstract class TrainingActivityItem extends GroupActivityItem {
  const factory TrainingActivityItem(final TrainingSessionModel session) =
      _$TrainingActivityItemImpl;
  const TrainingActivityItem._() : super._();

  TrainingSessionModel get session;

  /// Create a copy of GroupActivityItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrainingActivityItemImplCopyWith<_$TrainingActivityItemImpl>
  get copyWith => throw _privateConstructorUsedError;
}
