// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'season_rating_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SeasonRatingModel {

 int get seasonNumber; int get rating; DateTime get ratedAt;
/// Create a copy of SeasonRatingModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SeasonRatingModelCopyWith<SeasonRatingModel> get copyWith => _$SeasonRatingModelCopyWithImpl<SeasonRatingModel>(this as SeasonRatingModel, _$identity);

  /// Serializes this SeasonRatingModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SeasonRatingModel&&(identical(other.seasonNumber, seasonNumber) || other.seasonNumber == seasonNumber)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.ratedAt, ratedAt) || other.ratedAt == ratedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,seasonNumber,rating,ratedAt);

@override
String toString() {
  return 'SeasonRatingModel(seasonNumber: $seasonNumber, rating: $rating, ratedAt: $ratedAt)';
}


}

/// @nodoc
abstract mixin class $SeasonRatingModelCopyWith<$Res>  {
  factory $SeasonRatingModelCopyWith(SeasonRatingModel value, $Res Function(SeasonRatingModel) _then) = _$SeasonRatingModelCopyWithImpl;
@useResult
$Res call({
 int seasonNumber, int rating, DateTime ratedAt
});




}
/// @nodoc
class _$SeasonRatingModelCopyWithImpl<$Res>
    implements $SeasonRatingModelCopyWith<$Res> {
  _$SeasonRatingModelCopyWithImpl(this._self, this._then);

  final SeasonRatingModel _self;
  final $Res Function(SeasonRatingModel) _then;

/// Create a copy of SeasonRatingModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? seasonNumber = null,Object? rating = null,Object? ratedAt = null,}) {
  return _then(_self.copyWith(
seasonNumber: null == seasonNumber ? _self.seasonNumber : seasonNumber // ignore: cast_nullable_to_non_nullable
as int,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,ratedAt: null == ratedAt ? _self.ratedAt : ratedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [SeasonRatingModel].
extension SeasonRatingModelPatterns on SeasonRatingModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SeasonRatingModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SeasonRatingModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SeasonRatingModel value)  $default,){
final _that = this;
switch (_that) {
case _SeasonRatingModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SeasonRatingModel value)?  $default,){
final _that = this;
switch (_that) {
case _SeasonRatingModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int seasonNumber,  int rating,  DateTime ratedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SeasonRatingModel() when $default != null:
return $default(_that.seasonNumber,_that.rating,_that.ratedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int seasonNumber,  int rating,  DateTime ratedAt)  $default,) {final _that = this;
switch (_that) {
case _SeasonRatingModel():
return $default(_that.seasonNumber,_that.rating,_that.ratedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int seasonNumber,  int rating,  DateTime ratedAt)?  $default,) {final _that = this;
switch (_that) {
case _SeasonRatingModel() when $default != null:
return $default(_that.seasonNumber,_that.rating,_that.ratedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SeasonRatingModel implements SeasonRatingModel {
  const _SeasonRatingModel({required this.seasonNumber, required this.rating, required this.ratedAt});
  factory _SeasonRatingModel.fromJson(Map<String, dynamic> json) => _$SeasonRatingModelFromJson(json);

@override final  int seasonNumber;
@override final  int rating;
@override final  DateTime ratedAt;

/// Create a copy of SeasonRatingModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SeasonRatingModelCopyWith<_SeasonRatingModel> get copyWith => __$SeasonRatingModelCopyWithImpl<_SeasonRatingModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SeasonRatingModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SeasonRatingModel&&(identical(other.seasonNumber, seasonNumber) || other.seasonNumber == seasonNumber)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.ratedAt, ratedAt) || other.ratedAt == ratedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,seasonNumber,rating,ratedAt);

@override
String toString() {
  return 'SeasonRatingModel(seasonNumber: $seasonNumber, rating: $rating, ratedAt: $ratedAt)';
}


}

/// @nodoc
abstract mixin class _$SeasonRatingModelCopyWith<$Res> implements $SeasonRatingModelCopyWith<$Res> {
  factory _$SeasonRatingModelCopyWith(_SeasonRatingModel value, $Res Function(_SeasonRatingModel) _then) = __$SeasonRatingModelCopyWithImpl;
@override @useResult
$Res call({
 int seasonNumber, int rating, DateTime ratedAt
});




}
/// @nodoc
class __$SeasonRatingModelCopyWithImpl<$Res>
    implements _$SeasonRatingModelCopyWith<$Res> {
  __$SeasonRatingModelCopyWithImpl(this._self, this._then);

  final _SeasonRatingModel _self;
  final $Res Function(_SeasonRatingModel) _then;

/// Create a copy of SeasonRatingModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? seasonNumber = null,Object? rating = null,Object? ratedAt = null,}) {
  return _then(_SeasonRatingModel(
seasonNumber: null == seasonNumber ? _self.seasonNumber : seasonNumber // ignore: cast_nullable_to_non_nullable
as int,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,ratedAt: null == ratedAt ? _self.ratedAt : ratedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
