// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'movie_detail_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MovieDetailState {

 MovieModel get movie; TrackedMediaModel? get tracking;
/// Create a copy of MovieDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MovieDetailStateCopyWith<MovieDetailState> get copyWith => _$MovieDetailStateCopyWithImpl<MovieDetailState>(this as MovieDetailState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MovieDetailState&&(identical(other.movie, movie) || other.movie == movie)&&(identical(other.tracking, tracking) || other.tracking == tracking));
}


@override
int get hashCode => Object.hash(runtimeType,movie,tracking);

@override
String toString() {
  return 'MovieDetailState(movie: $movie, tracking: $tracking)';
}


}

/// @nodoc
abstract mixin class $MovieDetailStateCopyWith<$Res>  {
  factory $MovieDetailStateCopyWith(MovieDetailState value, $Res Function(MovieDetailState) _then) = _$MovieDetailStateCopyWithImpl;
@useResult
$Res call({
 MovieModel movie, TrackedMediaModel? tracking
});


$MovieModelCopyWith<$Res> get movie;$TrackedMediaModelCopyWith<$Res>? get tracking;

}
/// @nodoc
class _$MovieDetailStateCopyWithImpl<$Res>
    implements $MovieDetailStateCopyWith<$Res> {
  _$MovieDetailStateCopyWithImpl(this._self, this._then);

  final MovieDetailState _self;
  final $Res Function(MovieDetailState) _then;

/// Create a copy of MovieDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? movie = null,Object? tracking = freezed,}) {
  return _then(_self.copyWith(
movie: null == movie ? _self.movie : movie // ignore: cast_nullable_to_non_nullable
as MovieModel,tracking: freezed == tracking ? _self.tracking : tracking // ignore: cast_nullable_to_non_nullable
as TrackedMediaModel?,
  ));
}
/// Create a copy of MovieDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MovieModelCopyWith<$Res> get movie {
  
  return $MovieModelCopyWith<$Res>(_self.movie, (value) {
    return _then(_self.copyWith(movie: value));
  });
}/// Create a copy of MovieDetailState
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


/// Adds pattern-matching-related methods to [MovieDetailState].
extension MovieDetailStatePatterns on MovieDetailState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MovieDetailState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MovieDetailState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MovieDetailState value)  $default,){
final _that = this;
switch (_that) {
case _MovieDetailState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MovieDetailState value)?  $default,){
final _that = this;
switch (_that) {
case _MovieDetailState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MovieModel movie,  TrackedMediaModel? tracking)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MovieDetailState() when $default != null:
return $default(_that.movie,_that.tracking);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MovieModel movie,  TrackedMediaModel? tracking)  $default,) {final _that = this;
switch (_that) {
case _MovieDetailState():
return $default(_that.movie,_that.tracking);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MovieModel movie,  TrackedMediaModel? tracking)?  $default,) {final _that = this;
switch (_that) {
case _MovieDetailState() when $default != null:
return $default(_that.movie,_that.tracking);case _:
  return null;

}
}

}

/// @nodoc


class _MovieDetailState implements MovieDetailState {
  const _MovieDetailState({required this.movie, this.tracking});
  

@override final  MovieModel movie;
@override final  TrackedMediaModel? tracking;

/// Create a copy of MovieDetailState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MovieDetailStateCopyWith<_MovieDetailState> get copyWith => __$MovieDetailStateCopyWithImpl<_MovieDetailState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MovieDetailState&&(identical(other.movie, movie) || other.movie == movie)&&(identical(other.tracking, tracking) || other.tracking == tracking));
}


@override
int get hashCode => Object.hash(runtimeType,movie,tracking);

@override
String toString() {
  return 'MovieDetailState(movie: $movie, tracking: $tracking)';
}


}

/// @nodoc
abstract mixin class _$MovieDetailStateCopyWith<$Res> implements $MovieDetailStateCopyWith<$Res> {
  factory _$MovieDetailStateCopyWith(_MovieDetailState value, $Res Function(_MovieDetailState) _then) = __$MovieDetailStateCopyWithImpl;
@override @useResult
$Res call({
 MovieModel movie, TrackedMediaModel? tracking
});


@override $MovieModelCopyWith<$Res> get movie;@override $TrackedMediaModelCopyWith<$Res>? get tracking;

}
/// @nodoc
class __$MovieDetailStateCopyWithImpl<$Res>
    implements _$MovieDetailStateCopyWith<$Res> {
  __$MovieDetailStateCopyWithImpl(this._self, this._then);

  final _MovieDetailState _self;
  final $Res Function(_MovieDetailState) _then;

/// Create a copy of MovieDetailState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? movie = null,Object? tracking = freezed,}) {
  return _then(_MovieDetailState(
movie: null == movie ? _self.movie : movie // ignore: cast_nullable_to_non_nullable
as MovieModel,tracking: freezed == tracking ? _self.tracking : tracking // ignore: cast_nullable_to_non_nullable
as TrackedMediaModel?,
  ));
}

/// Create a copy of MovieDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MovieModelCopyWith<$Res> get movie {
  
  return $MovieModelCopyWith<$Res>(_self.movie, (value) {
    return _then(_self.copyWith(movie: value));
  });
}/// Create a copy of MovieDetailState
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
