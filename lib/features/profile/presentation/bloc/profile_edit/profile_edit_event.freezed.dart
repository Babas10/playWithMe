// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_edit_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ProfileEditEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String currentDisplayName,
      String? currentPhotoUrl,
    )
    started,
    required TResult Function(String displayName) displayNameChanged,
    required TResult Function(String photoUrl) photoUrlChanged,
    required TResult Function() saveRequested,
    required TResult Function() cancelled,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String currentDisplayName, String? currentPhotoUrl)?
    started,
    TResult? Function(String displayName)? displayNameChanged,
    TResult? Function(String photoUrl)? photoUrlChanged,
    TResult? Function()? saveRequested,
    TResult? Function()? cancelled,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String currentDisplayName, String? currentPhotoUrl)?
    started,
    TResult Function(String displayName)? displayNameChanged,
    TResult Function(String photoUrl)? photoUrlChanged,
    TResult Function()? saveRequested,
    TResult Function()? cancelled,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ProfileEditStarted value) started,
    required TResult Function(ProfileEditDisplayNameChanged value)
    displayNameChanged,
    required TResult Function(ProfileEditPhotoUrlChanged value) photoUrlChanged,
    required TResult Function(ProfileEditSaveRequested value) saveRequested,
    required TResult Function(ProfileEditCancelled value) cancelled,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ProfileEditStarted value)? started,
    TResult? Function(ProfileEditDisplayNameChanged value)? displayNameChanged,
    TResult? Function(ProfileEditPhotoUrlChanged value)? photoUrlChanged,
    TResult? Function(ProfileEditSaveRequested value)? saveRequested,
    TResult? Function(ProfileEditCancelled value)? cancelled,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ProfileEditStarted value)? started,
    TResult Function(ProfileEditDisplayNameChanged value)? displayNameChanged,
    TResult Function(ProfileEditPhotoUrlChanged value)? photoUrlChanged,
    TResult Function(ProfileEditSaveRequested value)? saveRequested,
    TResult Function(ProfileEditCancelled value)? cancelled,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileEditEventCopyWith<$Res> {
  factory $ProfileEditEventCopyWith(
    ProfileEditEvent value,
    $Res Function(ProfileEditEvent) then,
  ) = _$ProfileEditEventCopyWithImpl<$Res, ProfileEditEvent>;
}

/// @nodoc
class _$ProfileEditEventCopyWithImpl<$Res, $Val extends ProfileEditEvent>
    implements $ProfileEditEventCopyWith<$Res> {
  _$ProfileEditEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProfileEditEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$ProfileEditStartedImplCopyWith<$Res> {
  factory _$$ProfileEditStartedImplCopyWith(
    _$ProfileEditStartedImpl value,
    $Res Function(_$ProfileEditStartedImpl) then,
  ) = __$$ProfileEditStartedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String currentDisplayName, String? currentPhotoUrl});
}

/// @nodoc
class __$$ProfileEditStartedImplCopyWithImpl<$Res>
    extends _$ProfileEditEventCopyWithImpl<$Res, _$ProfileEditStartedImpl>
    implements _$$ProfileEditStartedImplCopyWith<$Res> {
  __$$ProfileEditStartedImplCopyWithImpl(
    _$ProfileEditStartedImpl _value,
    $Res Function(_$ProfileEditStartedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProfileEditEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentDisplayName = null,
    Object? currentPhotoUrl = freezed,
  }) {
    return _then(
      _$ProfileEditStartedImpl(
        currentDisplayName: null == currentDisplayName
            ? _value.currentDisplayName
            : currentDisplayName // ignore: cast_nullable_to_non_nullable
                  as String,
        currentPhotoUrl: freezed == currentPhotoUrl
            ? _value.currentPhotoUrl
            : currentPhotoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$ProfileEditStartedImpl implements ProfileEditStarted {
  const _$ProfileEditStartedImpl({
    required this.currentDisplayName,
    this.currentPhotoUrl,
  });

  @override
  final String currentDisplayName;
  @override
  final String? currentPhotoUrl;

  @override
  String toString() {
    return 'ProfileEditEvent.started(currentDisplayName: $currentDisplayName, currentPhotoUrl: $currentPhotoUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileEditStartedImpl &&
            (identical(other.currentDisplayName, currentDisplayName) ||
                other.currentDisplayName == currentDisplayName) &&
            (identical(other.currentPhotoUrl, currentPhotoUrl) ||
                other.currentPhotoUrl == currentPhotoUrl));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, currentDisplayName, currentPhotoUrl);

  /// Create a copy of ProfileEditEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileEditStartedImplCopyWith<_$ProfileEditStartedImpl> get copyWith =>
      __$$ProfileEditStartedImplCopyWithImpl<_$ProfileEditStartedImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String currentDisplayName,
      String? currentPhotoUrl,
    )
    started,
    required TResult Function(String displayName) displayNameChanged,
    required TResult Function(String photoUrl) photoUrlChanged,
    required TResult Function() saveRequested,
    required TResult Function() cancelled,
  }) {
    return started(currentDisplayName, currentPhotoUrl);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String currentDisplayName, String? currentPhotoUrl)?
    started,
    TResult? Function(String displayName)? displayNameChanged,
    TResult? Function(String photoUrl)? photoUrlChanged,
    TResult? Function()? saveRequested,
    TResult? Function()? cancelled,
  }) {
    return started?.call(currentDisplayName, currentPhotoUrl);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String currentDisplayName, String? currentPhotoUrl)?
    started,
    TResult Function(String displayName)? displayNameChanged,
    TResult Function(String photoUrl)? photoUrlChanged,
    TResult Function()? saveRequested,
    TResult Function()? cancelled,
    required TResult orElse(),
  }) {
    if (started != null) {
      return started(currentDisplayName, currentPhotoUrl);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ProfileEditStarted value) started,
    required TResult Function(ProfileEditDisplayNameChanged value)
    displayNameChanged,
    required TResult Function(ProfileEditPhotoUrlChanged value) photoUrlChanged,
    required TResult Function(ProfileEditSaveRequested value) saveRequested,
    required TResult Function(ProfileEditCancelled value) cancelled,
  }) {
    return started(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ProfileEditStarted value)? started,
    TResult? Function(ProfileEditDisplayNameChanged value)? displayNameChanged,
    TResult? Function(ProfileEditPhotoUrlChanged value)? photoUrlChanged,
    TResult? Function(ProfileEditSaveRequested value)? saveRequested,
    TResult? Function(ProfileEditCancelled value)? cancelled,
  }) {
    return started?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ProfileEditStarted value)? started,
    TResult Function(ProfileEditDisplayNameChanged value)? displayNameChanged,
    TResult Function(ProfileEditPhotoUrlChanged value)? photoUrlChanged,
    TResult Function(ProfileEditSaveRequested value)? saveRequested,
    TResult Function(ProfileEditCancelled value)? cancelled,
    required TResult orElse(),
  }) {
    if (started != null) {
      return started(this);
    }
    return orElse();
  }
}

abstract class ProfileEditStarted implements ProfileEditEvent {
  const factory ProfileEditStarted({
    required final String currentDisplayName,
    final String? currentPhotoUrl,
  }) = _$ProfileEditStartedImpl;

  String get currentDisplayName;
  String? get currentPhotoUrl;

  /// Create a copy of ProfileEditEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProfileEditStartedImplCopyWith<_$ProfileEditStartedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ProfileEditDisplayNameChangedImplCopyWith<$Res> {
  factory _$$ProfileEditDisplayNameChangedImplCopyWith(
    _$ProfileEditDisplayNameChangedImpl value,
    $Res Function(_$ProfileEditDisplayNameChangedImpl) then,
  ) = __$$ProfileEditDisplayNameChangedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String displayName});
}

/// @nodoc
class __$$ProfileEditDisplayNameChangedImplCopyWithImpl<$Res>
    extends
        _$ProfileEditEventCopyWithImpl<
          $Res,
          _$ProfileEditDisplayNameChangedImpl
        >
    implements _$$ProfileEditDisplayNameChangedImplCopyWith<$Res> {
  __$$ProfileEditDisplayNameChangedImplCopyWithImpl(
    _$ProfileEditDisplayNameChangedImpl _value,
    $Res Function(_$ProfileEditDisplayNameChangedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProfileEditEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? displayName = null}) {
    return _then(
      _$ProfileEditDisplayNameChangedImpl(
        null == displayName
            ? _value.displayName
            : displayName // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$ProfileEditDisplayNameChangedImpl
    implements ProfileEditDisplayNameChanged {
  const _$ProfileEditDisplayNameChangedImpl(this.displayName);

  @override
  final String displayName;

  @override
  String toString() {
    return 'ProfileEditEvent.displayNameChanged(displayName: $displayName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileEditDisplayNameChangedImpl &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName));
  }

  @override
  int get hashCode => Object.hash(runtimeType, displayName);

  /// Create a copy of ProfileEditEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileEditDisplayNameChangedImplCopyWith<
    _$ProfileEditDisplayNameChangedImpl
  >
  get copyWith =>
      __$$ProfileEditDisplayNameChangedImplCopyWithImpl<
        _$ProfileEditDisplayNameChangedImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String currentDisplayName,
      String? currentPhotoUrl,
    )
    started,
    required TResult Function(String displayName) displayNameChanged,
    required TResult Function(String photoUrl) photoUrlChanged,
    required TResult Function() saveRequested,
    required TResult Function() cancelled,
  }) {
    return displayNameChanged(displayName);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String currentDisplayName, String? currentPhotoUrl)?
    started,
    TResult? Function(String displayName)? displayNameChanged,
    TResult? Function(String photoUrl)? photoUrlChanged,
    TResult? Function()? saveRequested,
    TResult? Function()? cancelled,
  }) {
    return displayNameChanged?.call(displayName);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String currentDisplayName, String? currentPhotoUrl)?
    started,
    TResult Function(String displayName)? displayNameChanged,
    TResult Function(String photoUrl)? photoUrlChanged,
    TResult Function()? saveRequested,
    TResult Function()? cancelled,
    required TResult orElse(),
  }) {
    if (displayNameChanged != null) {
      return displayNameChanged(displayName);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ProfileEditStarted value) started,
    required TResult Function(ProfileEditDisplayNameChanged value)
    displayNameChanged,
    required TResult Function(ProfileEditPhotoUrlChanged value) photoUrlChanged,
    required TResult Function(ProfileEditSaveRequested value) saveRequested,
    required TResult Function(ProfileEditCancelled value) cancelled,
  }) {
    return displayNameChanged(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ProfileEditStarted value)? started,
    TResult? Function(ProfileEditDisplayNameChanged value)? displayNameChanged,
    TResult? Function(ProfileEditPhotoUrlChanged value)? photoUrlChanged,
    TResult? Function(ProfileEditSaveRequested value)? saveRequested,
    TResult? Function(ProfileEditCancelled value)? cancelled,
  }) {
    return displayNameChanged?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ProfileEditStarted value)? started,
    TResult Function(ProfileEditDisplayNameChanged value)? displayNameChanged,
    TResult Function(ProfileEditPhotoUrlChanged value)? photoUrlChanged,
    TResult Function(ProfileEditSaveRequested value)? saveRequested,
    TResult Function(ProfileEditCancelled value)? cancelled,
    required TResult orElse(),
  }) {
    if (displayNameChanged != null) {
      return displayNameChanged(this);
    }
    return orElse();
  }
}

abstract class ProfileEditDisplayNameChanged implements ProfileEditEvent {
  const factory ProfileEditDisplayNameChanged(final String displayName) =
      _$ProfileEditDisplayNameChangedImpl;

  String get displayName;

  /// Create a copy of ProfileEditEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProfileEditDisplayNameChangedImplCopyWith<
    _$ProfileEditDisplayNameChangedImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ProfileEditPhotoUrlChangedImplCopyWith<$Res> {
  factory _$$ProfileEditPhotoUrlChangedImplCopyWith(
    _$ProfileEditPhotoUrlChangedImpl value,
    $Res Function(_$ProfileEditPhotoUrlChangedImpl) then,
  ) = __$$ProfileEditPhotoUrlChangedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String photoUrl});
}

/// @nodoc
class __$$ProfileEditPhotoUrlChangedImplCopyWithImpl<$Res>
    extends
        _$ProfileEditEventCopyWithImpl<$Res, _$ProfileEditPhotoUrlChangedImpl>
    implements _$$ProfileEditPhotoUrlChangedImplCopyWith<$Res> {
  __$$ProfileEditPhotoUrlChangedImplCopyWithImpl(
    _$ProfileEditPhotoUrlChangedImpl _value,
    $Res Function(_$ProfileEditPhotoUrlChangedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProfileEditEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? photoUrl = null}) {
    return _then(
      _$ProfileEditPhotoUrlChangedImpl(
        null == photoUrl
            ? _value.photoUrl
            : photoUrl // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$ProfileEditPhotoUrlChangedImpl implements ProfileEditPhotoUrlChanged {
  const _$ProfileEditPhotoUrlChangedImpl(this.photoUrl);

  @override
  final String photoUrl;

  @override
  String toString() {
    return 'ProfileEditEvent.photoUrlChanged(photoUrl: $photoUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileEditPhotoUrlChangedImpl &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl));
  }

  @override
  int get hashCode => Object.hash(runtimeType, photoUrl);

  /// Create a copy of ProfileEditEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileEditPhotoUrlChangedImplCopyWith<_$ProfileEditPhotoUrlChangedImpl>
  get copyWith =>
      __$$ProfileEditPhotoUrlChangedImplCopyWithImpl<
        _$ProfileEditPhotoUrlChangedImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String currentDisplayName,
      String? currentPhotoUrl,
    )
    started,
    required TResult Function(String displayName) displayNameChanged,
    required TResult Function(String photoUrl) photoUrlChanged,
    required TResult Function() saveRequested,
    required TResult Function() cancelled,
  }) {
    return photoUrlChanged(photoUrl);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String currentDisplayName, String? currentPhotoUrl)?
    started,
    TResult? Function(String displayName)? displayNameChanged,
    TResult? Function(String photoUrl)? photoUrlChanged,
    TResult? Function()? saveRequested,
    TResult? Function()? cancelled,
  }) {
    return photoUrlChanged?.call(photoUrl);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String currentDisplayName, String? currentPhotoUrl)?
    started,
    TResult Function(String displayName)? displayNameChanged,
    TResult Function(String photoUrl)? photoUrlChanged,
    TResult Function()? saveRequested,
    TResult Function()? cancelled,
    required TResult orElse(),
  }) {
    if (photoUrlChanged != null) {
      return photoUrlChanged(photoUrl);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ProfileEditStarted value) started,
    required TResult Function(ProfileEditDisplayNameChanged value)
    displayNameChanged,
    required TResult Function(ProfileEditPhotoUrlChanged value) photoUrlChanged,
    required TResult Function(ProfileEditSaveRequested value) saveRequested,
    required TResult Function(ProfileEditCancelled value) cancelled,
  }) {
    return photoUrlChanged(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ProfileEditStarted value)? started,
    TResult? Function(ProfileEditDisplayNameChanged value)? displayNameChanged,
    TResult? Function(ProfileEditPhotoUrlChanged value)? photoUrlChanged,
    TResult? Function(ProfileEditSaveRequested value)? saveRequested,
    TResult? Function(ProfileEditCancelled value)? cancelled,
  }) {
    return photoUrlChanged?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ProfileEditStarted value)? started,
    TResult Function(ProfileEditDisplayNameChanged value)? displayNameChanged,
    TResult Function(ProfileEditPhotoUrlChanged value)? photoUrlChanged,
    TResult Function(ProfileEditSaveRequested value)? saveRequested,
    TResult Function(ProfileEditCancelled value)? cancelled,
    required TResult orElse(),
  }) {
    if (photoUrlChanged != null) {
      return photoUrlChanged(this);
    }
    return orElse();
  }
}

abstract class ProfileEditPhotoUrlChanged implements ProfileEditEvent {
  const factory ProfileEditPhotoUrlChanged(final String photoUrl) =
      _$ProfileEditPhotoUrlChangedImpl;

  String get photoUrl;

  /// Create a copy of ProfileEditEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProfileEditPhotoUrlChangedImplCopyWith<_$ProfileEditPhotoUrlChangedImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ProfileEditSaveRequestedImplCopyWith<$Res> {
  factory _$$ProfileEditSaveRequestedImplCopyWith(
    _$ProfileEditSaveRequestedImpl value,
    $Res Function(_$ProfileEditSaveRequestedImpl) then,
  ) = __$$ProfileEditSaveRequestedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ProfileEditSaveRequestedImplCopyWithImpl<$Res>
    extends _$ProfileEditEventCopyWithImpl<$Res, _$ProfileEditSaveRequestedImpl>
    implements _$$ProfileEditSaveRequestedImplCopyWith<$Res> {
  __$$ProfileEditSaveRequestedImplCopyWithImpl(
    _$ProfileEditSaveRequestedImpl _value,
    $Res Function(_$ProfileEditSaveRequestedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProfileEditEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$ProfileEditSaveRequestedImpl implements ProfileEditSaveRequested {
  const _$ProfileEditSaveRequestedImpl();

  @override
  String toString() {
    return 'ProfileEditEvent.saveRequested()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileEditSaveRequestedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String currentDisplayName,
      String? currentPhotoUrl,
    )
    started,
    required TResult Function(String displayName) displayNameChanged,
    required TResult Function(String photoUrl) photoUrlChanged,
    required TResult Function() saveRequested,
    required TResult Function() cancelled,
  }) {
    return saveRequested();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String currentDisplayName, String? currentPhotoUrl)?
    started,
    TResult? Function(String displayName)? displayNameChanged,
    TResult? Function(String photoUrl)? photoUrlChanged,
    TResult? Function()? saveRequested,
    TResult? Function()? cancelled,
  }) {
    return saveRequested?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String currentDisplayName, String? currentPhotoUrl)?
    started,
    TResult Function(String displayName)? displayNameChanged,
    TResult Function(String photoUrl)? photoUrlChanged,
    TResult Function()? saveRequested,
    TResult Function()? cancelled,
    required TResult orElse(),
  }) {
    if (saveRequested != null) {
      return saveRequested();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ProfileEditStarted value) started,
    required TResult Function(ProfileEditDisplayNameChanged value)
    displayNameChanged,
    required TResult Function(ProfileEditPhotoUrlChanged value) photoUrlChanged,
    required TResult Function(ProfileEditSaveRequested value) saveRequested,
    required TResult Function(ProfileEditCancelled value) cancelled,
  }) {
    return saveRequested(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ProfileEditStarted value)? started,
    TResult? Function(ProfileEditDisplayNameChanged value)? displayNameChanged,
    TResult? Function(ProfileEditPhotoUrlChanged value)? photoUrlChanged,
    TResult? Function(ProfileEditSaveRequested value)? saveRequested,
    TResult? Function(ProfileEditCancelled value)? cancelled,
  }) {
    return saveRequested?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ProfileEditStarted value)? started,
    TResult Function(ProfileEditDisplayNameChanged value)? displayNameChanged,
    TResult Function(ProfileEditPhotoUrlChanged value)? photoUrlChanged,
    TResult Function(ProfileEditSaveRequested value)? saveRequested,
    TResult Function(ProfileEditCancelled value)? cancelled,
    required TResult orElse(),
  }) {
    if (saveRequested != null) {
      return saveRequested(this);
    }
    return orElse();
  }
}

abstract class ProfileEditSaveRequested implements ProfileEditEvent {
  const factory ProfileEditSaveRequested() = _$ProfileEditSaveRequestedImpl;
}

/// @nodoc
abstract class _$$ProfileEditCancelledImplCopyWith<$Res> {
  factory _$$ProfileEditCancelledImplCopyWith(
    _$ProfileEditCancelledImpl value,
    $Res Function(_$ProfileEditCancelledImpl) then,
  ) = __$$ProfileEditCancelledImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ProfileEditCancelledImplCopyWithImpl<$Res>
    extends _$ProfileEditEventCopyWithImpl<$Res, _$ProfileEditCancelledImpl>
    implements _$$ProfileEditCancelledImplCopyWith<$Res> {
  __$$ProfileEditCancelledImplCopyWithImpl(
    _$ProfileEditCancelledImpl _value,
    $Res Function(_$ProfileEditCancelledImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProfileEditEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$ProfileEditCancelledImpl implements ProfileEditCancelled {
  const _$ProfileEditCancelledImpl();

  @override
  String toString() {
    return 'ProfileEditEvent.cancelled()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileEditCancelledImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String currentDisplayName,
      String? currentPhotoUrl,
    )
    started,
    required TResult Function(String displayName) displayNameChanged,
    required TResult Function(String photoUrl) photoUrlChanged,
    required TResult Function() saveRequested,
    required TResult Function() cancelled,
  }) {
    return cancelled();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String currentDisplayName, String? currentPhotoUrl)?
    started,
    TResult? Function(String displayName)? displayNameChanged,
    TResult? Function(String photoUrl)? photoUrlChanged,
    TResult? Function()? saveRequested,
    TResult? Function()? cancelled,
  }) {
    return cancelled?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String currentDisplayName, String? currentPhotoUrl)?
    started,
    TResult Function(String displayName)? displayNameChanged,
    TResult Function(String photoUrl)? photoUrlChanged,
    TResult Function()? saveRequested,
    TResult Function()? cancelled,
    required TResult orElse(),
  }) {
    if (cancelled != null) {
      return cancelled();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ProfileEditStarted value) started,
    required TResult Function(ProfileEditDisplayNameChanged value)
    displayNameChanged,
    required TResult Function(ProfileEditPhotoUrlChanged value) photoUrlChanged,
    required TResult Function(ProfileEditSaveRequested value) saveRequested,
    required TResult Function(ProfileEditCancelled value) cancelled,
  }) {
    return cancelled(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ProfileEditStarted value)? started,
    TResult? Function(ProfileEditDisplayNameChanged value)? displayNameChanged,
    TResult? Function(ProfileEditPhotoUrlChanged value)? photoUrlChanged,
    TResult? Function(ProfileEditSaveRequested value)? saveRequested,
    TResult? Function(ProfileEditCancelled value)? cancelled,
  }) {
    return cancelled?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ProfileEditStarted value)? started,
    TResult Function(ProfileEditDisplayNameChanged value)? displayNameChanged,
    TResult Function(ProfileEditPhotoUrlChanged value)? photoUrlChanged,
    TResult Function(ProfileEditSaveRequested value)? saveRequested,
    TResult Function(ProfileEditCancelled value)? cancelled,
    required TResult orElse(),
  }) {
    if (cancelled != null) {
      return cancelled(this);
    }
    return orElse();
  }
}

abstract class ProfileEditCancelled implements ProfileEditEvent {
  const factory ProfileEditCancelled() = _$ProfileEditCancelledImpl;
}
