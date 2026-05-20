// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_stats_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DashboardStatsModel {

 int get watchingCount; int get wantToWatchCount; int get completedCount; int get droppedCount; int get totalTracked;
/// Create a copy of DashboardStatsModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardStatsModelCopyWith<DashboardStatsModel> get copyWith => _$DashboardStatsModelCopyWithImpl<DashboardStatsModel>(this as DashboardStatsModel, _$identity);

  /// Serializes this DashboardStatsModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardStatsModel&&(identical(other.watchingCount, watchingCount) || other.watchingCount == watchingCount)&&(identical(other.wantToWatchCount, wantToWatchCount) || other.wantToWatchCount == wantToWatchCount)&&(identical(other.completedCount, completedCount) || other.completedCount == completedCount)&&(identical(other.droppedCount, droppedCount) || other.droppedCount == droppedCount)&&(identical(other.totalTracked, totalTracked) || other.totalTracked == totalTracked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,watchingCount,wantToWatchCount,completedCount,droppedCount,totalTracked);

@override
String toString() {
  return 'DashboardStatsModel(watchingCount: $watchingCount, wantToWatchCount: $wantToWatchCount, completedCount: $completedCount, droppedCount: $droppedCount, totalTracked: $totalTracked)';
}


}

/// @nodoc
abstract mixin class $DashboardStatsModelCopyWith<$Res>  {
  factory $DashboardStatsModelCopyWith(DashboardStatsModel value, $Res Function(DashboardStatsModel) _then) = _$DashboardStatsModelCopyWithImpl;
@useResult
$Res call({
 int watchingCount, int wantToWatchCount, int completedCount, int droppedCount, int totalTracked
});




}
/// @nodoc
class _$DashboardStatsModelCopyWithImpl<$Res>
    implements $DashboardStatsModelCopyWith<$Res> {
  _$DashboardStatsModelCopyWithImpl(this._self, this._then);

  final DashboardStatsModel _self;
  final $Res Function(DashboardStatsModel) _then;

/// Create a copy of DashboardStatsModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? watchingCount = null,Object? wantToWatchCount = null,Object? completedCount = null,Object? droppedCount = null,Object? totalTracked = null,}) {
  return _then(_self.copyWith(
watchingCount: null == watchingCount ? _self.watchingCount : watchingCount // ignore: cast_nullable_to_non_nullable
as int,wantToWatchCount: null == wantToWatchCount ? _self.wantToWatchCount : wantToWatchCount // ignore: cast_nullable_to_non_nullable
as int,completedCount: null == completedCount ? _self.completedCount : completedCount // ignore: cast_nullable_to_non_nullable
as int,droppedCount: null == droppedCount ? _self.droppedCount : droppedCount // ignore: cast_nullable_to_non_nullable
as int,totalTracked: null == totalTracked ? _self.totalTracked : totalTracked // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DashboardStatsModel].
extension DashboardStatsModelPatterns on DashboardStatsModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardStatsModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardStatsModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardStatsModel value)  $default,){
final _that = this;
switch (_that) {
case _DashboardStatsModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardStatsModel value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardStatsModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int watchingCount,  int wantToWatchCount,  int completedCount,  int droppedCount,  int totalTracked)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardStatsModel() when $default != null:
return $default(_that.watchingCount,_that.wantToWatchCount,_that.completedCount,_that.droppedCount,_that.totalTracked);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int watchingCount,  int wantToWatchCount,  int completedCount,  int droppedCount,  int totalTracked)  $default,) {final _that = this;
switch (_that) {
case _DashboardStatsModel():
return $default(_that.watchingCount,_that.wantToWatchCount,_that.completedCount,_that.droppedCount,_that.totalTracked);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int watchingCount,  int wantToWatchCount,  int completedCount,  int droppedCount,  int totalTracked)?  $default,) {final _that = this;
switch (_that) {
case _DashboardStatsModel() when $default != null:
return $default(_that.watchingCount,_that.wantToWatchCount,_that.completedCount,_that.droppedCount,_that.totalTracked);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DashboardStatsModel implements DashboardStatsModel {
  const _DashboardStatsModel({this.watchingCount = 0, this.wantToWatchCount = 0, this.completedCount = 0, this.droppedCount = 0, this.totalTracked = 0});
  factory _DashboardStatsModel.fromJson(Map<String, dynamic> json) => _$DashboardStatsModelFromJson(json);

@override@JsonKey() final  int watchingCount;
@override@JsonKey() final  int wantToWatchCount;
@override@JsonKey() final  int completedCount;
@override@JsonKey() final  int droppedCount;
@override@JsonKey() final  int totalTracked;

/// Create a copy of DashboardStatsModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardStatsModelCopyWith<_DashboardStatsModel> get copyWith => __$DashboardStatsModelCopyWithImpl<_DashboardStatsModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DashboardStatsModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardStatsModel&&(identical(other.watchingCount, watchingCount) || other.watchingCount == watchingCount)&&(identical(other.wantToWatchCount, wantToWatchCount) || other.wantToWatchCount == wantToWatchCount)&&(identical(other.completedCount, completedCount) || other.completedCount == completedCount)&&(identical(other.droppedCount, droppedCount) || other.droppedCount == droppedCount)&&(identical(other.totalTracked, totalTracked) || other.totalTracked == totalTracked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,watchingCount,wantToWatchCount,completedCount,droppedCount,totalTracked);

@override
String toString() {
  return 'DashboardStatsModel(watchingCount: $watchingCount, wantToWatchCount: $wantToWatchCount, completedCount: $completedCount, droppedCount: $droppedCount, totalTracked: $totalTracked)';
}


}

/// @nodoc
abstract mixin class _$DashboardStatsModelCopyWith<$Res> implements $DashboardStatsModelCopyWith<$Res> {
  factory _$DashboardStatsModelCopyWith(_DashboardStatsModel value, $Res Function(_DashboardStatsModel) _then) = __$DashboardStatsModelCopyWithImpl;
@override @useResult
$Res call({
 int watchingCount, int wantToWatchCount, int completedCount, int droppedCount, int totalTracked
});




}
/// @nodoc
class __$DashboardStatsModelCopyWithImpl<$Res>
    implements _$DashboardStatsModelCopyWith<$Res> {
  __$DashboardStatsModelCopyWithImpl(this._self, this._then);

  final _DashboardStatsModel _self;
  final $Res Function(_DashboardStatsModel) _then;

/// Create a copy of DashboardStatsModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? watchingCount = null,Object? wantToWatchCount = null,Object? completedCount = null,Object? droppedCount = null,Object? totalTracked = null,}) {
  return _then(_DashboardStatsModel(
watchingCount: null == watchingCount ? _self.watchingCount : watchingCount // ignore: cast_nullable_to_non_nullable
as int,wantToWatchCount: null == wantToWatchCount ? _self.wantToWatchCount : wantToWatchCount // ignore: cast_nullable_to_non_nullable
as int,completedCount: null == completedCount ? _self.completedCount : completedCount // ignore: cast_nullable_to_non_nullable
as int,droppedCount: null == droppedCount ? _self.droppedCount : droppedCount // ignore: cast_nullable_to_non_nullable
as int,totalTracked: null == totalTracked ? _self.totalTracked : totalTracked // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
