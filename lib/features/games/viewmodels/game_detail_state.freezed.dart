// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_detail_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GameDetailState {

 GameModel get game; TrackedMediaModel? get tracking;
/// Create a copy of GameDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameDetailStateCopyWith<GameDetailState> get copyWith => _$GameDetailStateCopyWithImpl<GameDetailState>(this as GameDetailState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameDetailState&&(identical(other.game, game) || other.game == game)&&(identical(other.tracking, tracking) || other.tracking == tracking));
}


@override
int get hashCode => Object.hash(runtimeType,game,tracking);

@override
String toString() {
  return 'GameDetailState(game: $game, tracking: $tracking)';
}


}

/// @nodoc
abstract mixin class $GameDetailStateCopyWith<$Res>  {
  factory $GameDetailStateCopyWith(GameDetailState value, $Res Function(GameDetailState) _then) = _$GameDetailStateCopyWithImpl;
@useResult
$Res call({
 GameModel game, TrackedMediaModel? tracking
});


$GameModelCopyWith<$Res> get game;$TrackedMediaModelCopyWith<$Res>? get tracking;

}
/// @nodoc
class _$GameDetailStateCopyWithImpl<$Res>
    implements $GameDetailStateCopyWith<$Res> {
  _$GameDetailStateCopyWithImpl(this._self, this._then);

  final GameDetailState _self;
  final $Res Function(GameDetailState) _then;

/// Create a copy of GameDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? game = null,Object? tracking = freezed,}) {
  return _then(_self.copyWith(
game: null == game ? _self.game : game // ignore: cast_nullable_to_non_nullable
as GameModel,tracking: freezed == tracking ? _self.tracking : tracking // ignore: cast_nullable_to_non_nullable
as TrackedMediaModel?,
  ));
}
/// Create a copy of GameDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GameModelCopyWith<$Res> get game {
  
  return $GameModelCopyWith<$Res>(_self.game, (value) {
    return _then(_self.copyWith(game: value));
  });
}/// Create a copy of GameDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TrackedMediaModelCopyWith<$Res>? get tracking {
    if (_self.tracking == null) {
    return null;
  }

  return $TrackedMediaModelCopyWith<$Res>(_self.tracking!, (value) {
    return _then(_self.copyWith(tracking: value));
  });
}
}


/// Adds pattern-matching-related methods to [GameDetailState].
extension GameDetailStatePatterns on GameDetailState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GameDetailState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GameDetailState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GameDetailState value)  $default,){
final _that = this;
switch (_that) {
case _GameDetailState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GameDetailState value)?  $default,){
final _that = this;
switch (_that) {
case _GameDetailState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( GameModel game,  TrackedMediaModel? tracking)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GameDetailState() when $default != null:
return $default(_that.game,_that.tracking);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( GameModel game,  TrackedMediaModel? tracking)  $default,) {final _that = this;
switch (_that) {
case _GameDetailState():
return $default(_that.game,_that.tracking);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( GameModel game,  TrackedMediaModel? tracking)?  $default,) {final _that = this;
switch (_that) {
case _GameDetailState() when $default != null:
return $default(_that.game,_that.tracking);case _:
  return null;

}
}

}

/// @nodoc


class _GameDetailState implements GameDetailState {
  const _GameDetailState({required this.game, this.tracking});
  

@override final  GameModel game;
@override final  TrackedMediaModel? tracking;

/// Create a copy of GameDetailState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameDetailStateCopyWith<_GameDetailState> get copyWith => __$GameDetailStateCopyWithImpl<_GameDetailState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GameDetailState&&(identical(other.game, game) || other.game == game)&&(identical(other.tracking, tracking) || other.tracking == tracking));
}


@override
int get hashCode => Object.hash(runtimeType,game,tracking);

@override
String toString() {
  return 'GameDetailState(game: $game, tracking: $tracking)';
}


}

/// @nodoc
abstract mixin class _$GameDetailStateCopyWith<$Res> implements $GameDetailStateCopyWith<$Res> {
  factory _$GameDetailStateCopyWith(_GameDetailState value, $Res Function(_GameDetailState) _then) = __$GameDetailStateCopyWithImpl;
@override @useResult
$Res call({
 GameModel game, TrackedMediaModel? tracking
});


@override $GameModelCopyWith<$Res> get game;@override $TrackedMediaModelCopyWith<$Res>? get tracking;

}
/// @nodoc
class __$GameDetailStateCopyWithImpl<$Res>
    implements _$GameDetailStateCopyWith<$Res> {
  __$GameDetailStateCopyWithImpl(this._self, this._then);

  final _GameDetailState _self;
  final $Res Function(_GameDetailState) _then;

/// Create a copy of GameDetailState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? game = null,Object? tracking = freezed,}) {
  return _then(_GameDetailState(
game: null == game ? _self.game : game // ignore: cast_nullable_to_non_nullable
as GameModel,tracking: freezed == tracking ? _self.tracking : tracking // ignore: cast_nullable_to_non_nullable
as TrackedMediaModel?,
  ));
}

/// Create a copy of GameDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GameModelCopyWith<$Res> get game {
  
  return $GameModelCopyWith<$Res>(_self.game, (value) {
    return _then(_self.copyWith(game: value));
  });
}/// Create a copy of GameDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TrackedMediaModelCopyWith<$Res>? get tracking {
    if (_self.tracking == null) {
    return null;
  }

  return $TrackedMediaModelCopyWith<$Res>(_self.tracking!, (value) {
    return _then(_self.copyWith(tracking: value));
  });
}
}

// dart format on
