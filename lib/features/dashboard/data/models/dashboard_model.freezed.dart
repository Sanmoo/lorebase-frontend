// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DashboardModel {

 DashboardSectionModel get watching; DashboardSectionModel get wantToWatch; DashboardSectionModel get completed; DashboardSectionModel get dropped; DashboardStatsModel get stats;
/// Create a copy of DashboardModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardModelCopyWith<DashboardModel> get copyWith => _$DashboardModelCopyWithImpl<DashboardModel>(this as DashboardModel, _$identity);

  /// Serializes this DashboardModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardModel&&(identical(other.watching, watching) || other.watching == watching)&&(identical(other.wantToWatch, wantToWatch) || other.wantToWatch == wantToWatch)&&(identical(other.completed, completed) || other.completed == completed)&&(identical(other.dropped, dropped) || other.dropped == dropped)&&(identical(other.stats, stats) || other.stats == stats));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,watching,wantToWatch,completed,dropped,stats);

@override
String toString() {
  return 'DashboardModel(watching: $watching, wantToWatch: $wantToWatch, completed: $completed, dropped: $dropped, stats: $stats)';
}


}

/// @nodoc
abstract mixin class $DashboardModelCopyWith<$Res>  {
  factory $DashboardModelCopyWith(DashboardModel value, $Res Function(DashboardModel) _then) = _$DashboardModelCopyWithImpl;
@useResult
$Res call({
 DashboardSectionModel watching, DashboardSectionModel wantToWatch, DashboardSectionModel completed, DashboardSectionModel dropped, DashboardStatsModel stats
});


$DashboardSectionModelCopyWith<$Res> get watching;$DashboardSectionModelCopyWith<$Res> get wantToWatch;$DashboardSectionModelCopyWith<$Res> get completed;$DashboardSectionModelCopyWith<$Res> get dropped;$DashboardStatsModelCopyWith<$Res> get stats;

}
/// @nodoc
class _$DashboardModelCopyWithImpl<$Res>
    implements $DashboardModelCopyWith<$Res> {
  _$DashboardModelCopyWithImpl(this._self, this._then);

  final DashboardModel _self;
  final $Res Function(DashboardModel) _then;

/// Create a copy of DashboardModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? watching = null,Object? wantToWatch = null,Object? completed = null,Object? dropped = null,Object? stats = null,}) {
  return _then(_self.copyWith(
watching: null == watching ? _self.watching : watching // ignore: cast_nullable_to_non_nullable
as DashboardSectionModel,wantToWatch: null == wantToWatch ? _self.wantToWatch : wantToWatch // ignore: cast_nullable_to_non_nullable
as DashboardSectionModel,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as DashboardSectionModel,dropped: null == dropped ? _self.dropped : dropped // ignore: cast_nullable_to_non_nullable
as DashboardSectionModel,stats: null == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as DashboardStatsModel,
  ));
}
/// Create a copy of DashboardModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DashboardSectionModelCopyWith<$Res> get watching {
  
  return $DashboardSectionModelCopyWith<$Res>(_self.watching, (value) {
    return _then(_self.copyWith(watching: value));
  });
}/// Create a copy of DashboardModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DashboardSectionModelCopyWith<$Res> get wantToWatch {
  
  return $DashboardSectionModelCopyWith<$Res>(_self.wantToWatch, (value) {
    return _then(_self.copyWith(wantToWatch: value));
  });
}/// Create a copy of DashboardModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DashboardSectionModelCopyWith<$Res> get completed {
  
  return $DashboardSectionModelCopyWith<$Res>(_self.completed, (value) {
    return _then(_self.copyWith(completed: value));
  });
}/// Create a copy of DashboardModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DashboardSectionModelCopyWith<$Res> get dropped {
  
  return $DashboardSectionModelCopyWith<$Res>(_self.dropped, (value) {
    return _then(_self.copyWith(dropped: value));
  });
}/// Create a copy of DashboardModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DashboardStatsModelCopyWith<$Res> get stats {
  
  return $DashboardStatsModelCopyWith<$Res>(_self.stats, (value) {
    return _then(_self.copyWith(stats: value));
  });
}
}


/// Adds pattern-matching-related methods to [DashboardModel].
extension DashboardModelPatterns on DashboardModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardModel value)  $default,){
final _that = this;
switch (_that) {
case _DashboardModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardModel value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DashboardSectionModel watching,  DashboardSectionModel wantToWatch,  DashboardSectionModel completed,  DashboardSectionModel dropped,  DashboardStatsModel stats)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardModel() when $default != null:
return $default(_that.watching,_that.wantToWatch,_that.completed,_that.dropped,_that.stats);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DashboardSectionModel watching,  DashboardSectionModel wantToWatch,  DashboardSectionModel completed,  DashboardSectionModel dropped,  DashboardStatsModel stats)  $default,) {final _that = this;
switch (_that) {
case _DashboardModel():
return $default(_that.watching,_that.wantToWatch,_that.completed,_that.dropped,_that.stats);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DashboardSectionModel watching,  DashboardSectionModel wantToWatch,  DashboardSectionModel completed,  DashboardSectionModel dropped,  DashboardStatsModel stats)?  $default,) {final _that = this;
switch (_that) {
case _DashboardModel() when $default != null:
return $default(_that.watching,_that.wantToWatch,_that.completed,_that.dropped,_that.stats);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DashboardModel implements DashboardModel {
  const _DashboardModel({required this.watching, required this.wantToWatch, required this.completed, required this.dropped, required this.stats});
  factory _DashboardModel.fromJson(Map<String, dynamic> json) => _$DashboardModelFromJson(json);

@override final  DashboardSectionModel watching;
@override final  DashboardSectionModel wantToWatch;
@override final  DashboardSectionModel completed;
@override final  DashboardSectionModel dropped;
@override final  DashboardStatsModel stats;

/// Create a copy of DashboardModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardModelCopyWith<_DashboardModel> get copyWith => __$DashboardModelCopyWithImpl<_DashboardModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DashboardModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardModel&&(identical(other.watching, watching) || other.watching == watching)&&(identical(other.wantToWatch, wantToWatch) || other.wantToWatch == wantToWatch)&&(identical(other.completed, completed) || other.completed == completed)&&(identical(other.dropped, dropped) || other.dropped == dropped)&&(identical(other.stats, stats) || other.stats == stats));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,watching,wantToWatch,completed,dropped,stats);

@override
String toString() {
  return 'DashboardModel(watching: $watching, wantToWatch: $wantToWatch, completed: $completed, dropped: $dropped, stats: $stats)';
}


}

/// @nodoc
abstract mixin class _$DashboardModelCopyWith<$Res> implements $DashboardModelCopyWith<$Res> {
  factory _$DashboardModelCopyWith(_DashboardModel value, $Res Function(_DashboardModel) _then) = __$DashboardModelCopyWithImpl;
@override @useResult
$Res call({
 DashboardSectionModel watching, DashboardSectionModel wantToWatch, DashboardSectionModel completed, DashboardSectionModel dropped, DashboardStatsModel stats
});


@override $DashboardSectionModelCopyWith<$Res> get watching;@override $DashboardSectionModelCopyWith<$Res> get wantToWatch;@override $DashboardSectionModelCopyWith<$Res> get completed;@override $DashboardSectionModelCopyWith<$Res> get dropped;@override $DashboardStatsModelCopyWith<$Res> get stats;

}
/// @nodoc
class __$DashboardModelCopyWithImpl<$Res>
    implements _$DashboardModelCopyWith<$Res> {
  __$DashboardModelCopyWithImpl(this._self, this._then);

  final _DashboardModel _self;
  final $Res Function(_DashboardModel) _then;

/// Create a copy of DashboardModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? watching = null,Object? wantToWatch = null,Object? completed = null,Object? dropped = null,Object? stats = null,}) {
  return _then(_DashboardModel(
watching: null == watching ? _self.watching : watching // ignore: cast_nullable_to_non_nullable
as DashboardSectionModel,wantToWatch: null == wantToWatch ? _self.wantToWatch : wantToWatch // ignore: cast_nullable_to_non_nullable
as DashboardSectionModel,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as DashboardSectionModel,dropped: null == dropped ? _self.dropped : dropped // ignore: cast_nullable_to_non_nullable
as DashboardSectionModel,stats: null == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as DashboardStatsModel,
  ));
}

/// Create a copy of DashboardModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DashboardSectionModelCopyWith<$Res> get watching {
  
  return $DashboardSectionModelCopyWith<$Res>(_self.watching, (value) {
    return _then(_self.copyWith(watching: value));
  });
}/// Create a copy of DashboardModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DashboardSectionModelCopyWith<$Res> get wantToWatch {
  
  return $DashboardSectionModelCopyWith<$Res>(_self.wantToWatch, (value) {
    return _then(_self.copyWith(wantToWatch: value));
  });
}/// Create a copy of DashboardModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DashboardSectionModelCopyWith<$Res> get completed {
  
  return $DashboardSectionModelCopyWith<$Res>(_self.completed, (value) {
    return _then(_self.copyWith(completed: value));
  });
}/// Create a copy of DashboardModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DashboardSectionModelCopyWith<$Res> get dropped {
  
  return $DashboardSectionModelCopyWith<$Res>(_self.dropped, (value) {
    return _then(_self.copyWith(dropped: value));
  });
}/// Create a copy of DashboardModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DashboardStatsModelCopyWith<$Res> get stats {
  
  return $DashboardStatsModelCopyWith<$Res>(_self.stats, (value) {
    return _then(_self.copyWith(stats: value));
  });
}
}

// dart format on
