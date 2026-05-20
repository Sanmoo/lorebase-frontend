// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'series_detail_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SeriesDetailState {

 SeriesModel get series; TrackedMediaModel? get tracking;
/// Create a copy of SeriesDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SeriesDetailStateCopyWith<SeriesDetailState> get copyWith => _$SeriesDetailStateCopyWithImpl<SeriesDetailState>(this as SeriesDetailState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SeriesDetailState&&(identical(other.series, series) || other.series == series)&&(identical(other.tracking, tracking) || other.tracking == tracking));
}


@override
int get hashCode => Object.hash(runtimeType,series,tracking);

@override
String toString() {
  return 'SeriesDetailState(series: $series, tracking: $tracking)';
}


}

/// @nodoc
abstract mixin class $SeriesDetailStateCopyWith<$Res>  {
  factory $SeriesDetailStateCopyWith(SeriesDetailState value, $Res Function(SeriesDetailState) _then) = _$SeriesDetailStateCopyWithImpl;
@useResult
$Res call({
 SeriesModel series, TrackedMediaModel? tracking
});


$SeriesModelCopyWith<$Res> get series;$TrackedMediaModelCopyWith<$Res>? get tracking;

}
/// @nodoc
class _$SeriesDetailStateCopyWithImpl<$Res>
    implements $SeriesDetailStateCopyWith<$Res> {
  _$SeriesDetailStateCopyWithImpl(this._self, this._then);

  final SeriesDetailState _self;
  final $Res Function(SeriesDetailState) _then;

/// Create a copy of SeriesDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? series = null,Object? tracking = freezed,}) {
  return _then(_self.copyWith(
series: null == series ? _self.series : series // ignore: cast_nullable_to_non_nullable
as SeriesModel,tracking: freezed == tracking ? _self.tracking : tracking // ignore: cast_nullable_to_non_nullable
as TrackedMediaModel?,
  ));
}
/// Create a copy of SeriesDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SeriesModelCopyWith<$Res> get series {
  
  return $SeriesModelCopyWith<$Res>(_self.series, (value) {
    return _then(_self.copyWith(series: value));
  });
}/// Create a copy of SeriesDetailState
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


/// Adds pattern-matching-related methods to [SeriesDetailState].
extension SeriesDetailStatePatterns on SeriesDetailState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SeriesDetailState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SeriesDetailState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SeriesDetailState value)  $default,){
final _that = this;
switch (_that) {
case _SeriesDetailState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SeriesDetailState value)?  $default,){
final _that = this;
switch (_that) {
case _SeriesDetailState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SeriesModel series,  TrackedMediaModel? tracking)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SeriesDetailState() when $default != null:
return $default(_that.series,_that.tracking);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SeriesModel series,  TrackedMediaModel? tracking)  $default,) {final _that = this;
switch (_that) {
case _SeriesDetailState():
return $default(_that.series,_that.tracking);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SeriesModel series,  TrackedMediaModel? tracking)?  $default,) {final _that = this;
switch (_that) {
case _SeriesDetailState() when $default != null:
return $default(_that.series,_that.tracking);case _:
  return null;

}
}

}

/// @nodoc


class _SeriesDetailState implements SeriesDetailState {
  const _SeriesDetailState({required this.series, this.tracking});
  

@override final  SeriesModel series;
@override final  TrackedMediaModel? tracking;

/// Create a copy of SeriesDetailState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SeriesDetailStateCopyWith<_SeriesDetailState> get copyWith => __$SeriesDetailStateCopyWithImpl<_SeriesDetailState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SeriesDetailState&&(identical(other.series, series) || other.series == series)&&(identical(other.tracking, tracking) || other.tracking == tracking));
}


@override
int get hashCode => Object.hash(runtimeType,series,tracking);

@override
String toString() {
  return 'SeriesDetailState(series: $series, tracking: $tracking)';
}


}

/// @nodoc
abstract mixin class _$SeriesDetailStateCopyWith<$Res> implements $SeriesDetailStateCopyWith<$Res> {
  factory _$SeriesDetailStateCopyWith(_SeriesDetailState value, $Res Function(_SeriesDetailState) _then) = __$SeriesDetailStateCopyWithImpl;
@override @useResult
$Res call({
 SeriesModel series, TrackedMediaModel? tracking
});


@override $SeriesModelCopyWith<$Res> get series;@override $TrackedMediaModelCopyWith<$Res>? get tracking;

}
/// @nodoc
class __$SeriesDetailStateCopyWithImpl<$Res>
    implements _$SeriesDetailStateCopyWith<$Res> {
  __$SeriesDetailStateCopyWithImpl(this._self, this._then);

  final _SeriesDetailState _self;
  final $Res Function(_SeriesDetailState) _then;

/// Create a copy of SeriesDetailState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? series = null,Object? tracking = freezed,}) {
  return _then(_SeriesDetailState(
series: null == series ? _self.series : series // ignore: cast_nullable_to_non_nullable
as SeriesModel,tracking: freezed == tracking ? _self.tracking : tracking // ignore: cast_nullable_to_non_nullable
as TrackedMediaModel?,
  ));
}

/// Create a copy of SeriesDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SeriesModelCopyWith<$Res> get series {
  
  return $SeriesModelCopyWith<$Res>(_self.series, (value) {
    return _then(_self.copyWith(series: value));
  });
}/// Create a copy of SeriesDetailState
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
