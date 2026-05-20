// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'series_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SeriesModel {

@JsonKey(fromJson: flexibleIntFromJson, toJson: flexibleIntToJson) int get tmdbId; String get title; String? get overview; String? get posterPath; String? get backdropPath; String? get firstAirDate; List<String> get genres; List<String> get networks; int get seasonCount; String? get status;
/// Create a copy of SeriesModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SeriesModelCopyWith<SeriesModel> get copyWith => _$SeriesModelCopyWithImpl<SeriesModel>(this as SeriesModel, _$identity);

  /// Serializes this SeriesModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SeriesModel&&(identical(other.tmdbId, tmdbId) || other.tmdbId == tmdbId)&&(identical(other.title, title) || other.title == title)&&(identical(other.overview, overview) || other.overview == overview)&&(identical(other.posterPath, posterPath) || other.posterPath == posterPath)&&(identical(other.backdropPath, backdropPath) || other.backdropPath == backdropPath)&&(identical(other.firstAirDate, firstAirDate) || other.firstAirDate == firstAirDate)&&const DeepCollectionEquality().equals(other.genres, genres)&&const DeepCollectionEquality().equals(other.networks, networks)&&(identical(other.seasonCount, seasonCount) || other.seasonCount == seasonCount)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tmdbId,title,overview,posterPath,backdropPath,firstAirDate,const DeepCollectionEquality().hash(genres),const DeepCollectionEquality().hash(networks),seasonCount,status);

@override
String toString() {
  return 'SeriesModel(tmdbId: $tmdbId, title: $title, overview: $overview, posterPath: $posterPath, backdropPath: $backdropPath, firstAirDate: $firstAirDate, genres: $genres, networks: $networks, seasonCount: $seasonCount, status: $status)';
}


}

/// @nodoc
abstract mixin class $SeriesModelCopyWith<$Res>  {
  factory $SeriesModelCopyWith(SeriesModel value, $Res Function(SeriesModel) _then) = _$SeriesModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: flexibleIntFromJson, toJson: flexibleIntToJson) int tmdbId, String title, String? overview, String? posterPath, String? backdropPath, String? firstAirDate, List<String> genres, List<String> networks, int seasonCount, String? status
});




}
/// @nodoc
class _$SeriesModelCopyWithImpl<$Res>
    implements $SeriesModelCopyWith<$Res> {
  _$SeriesModelCopyWithImpl(this._self, this._then);

  final SeriesModel _self;
  final $Res Function(SeriesModel) _then;

/// Create a copy of SeriesModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tmdbId = null,Object? title = null,Object? overview = freezed,Object? posterPath = freezed,Object? backdropPath = freezed,Object? firstAirDate = freezed,Object? genres = null,Object? networks = null,Object? seasonCount = null,Object? status = freezed,}) {
  return _then(_self.copyWith(
tmdbId: null == tmdbId ? _self.tmdbId : tmdbId // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,overview: freezed == overview ? _self.overview : overview // ignore: cast_nullable_to_non_nullable
as String?,posterPath: freezed == posterPath ? _self.posterPath : posterPath // ignore: cast_nullable_to_non_nullable
as String?,backdropPath: freezed == backdropPath ? _self.backdropPath : backdropPath // ignore: cast_nullable_to_non_nullable
as String?,firstAirDate: freezed == firstAirDate ? _self.firstAirDate : firstAirDate // ignore: cast_nullable_to_non_nullable
as String?,genres: null == genres ? _self.genres : genres // ignore: cast_nullable_to_non_nullable
as List<String>,networks: null == networks ? _self.networks : networks // ignore: cast_nullable_to_non_nullable
as List<String>,seasonCount: null == seasonCount ? _self.seasonCount : seasonCount // ignore: cast_nullable_to_non_nullable
as int,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SeriesModel].
extension SeriesModelPatterns on SeriesModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SeriesModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SeriesModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SeriesModel value)  $default,){
final _that = this;
switch (_that) {
case _SeriesModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SeriesModel value)?  $default,){
final _that = this;
switch (_that) {
case _SeriesModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: flexibleIntFromJson, toJson: flexibleIntToJson)  int tmdbId,  String title,  String? overview,  String? posterPath,  String? backdropPath,  String? firstAirDate,  List<String> genres,  List<String> networks,  int seasonCount,  String? status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SeriesModel() when $default != null:
return $default(_that.tmdbId,_that.title,_that.overview,_that.posterPath,_that.backdropPath,_that.firstAirDate,_that.genres,_that.networks,_that.seasonCount,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: flexibleIntFromJson, toJson: flexibleIntToJson)  int tmdbId,  String title,  String? overview,  String? posterPath,  String? backdropPath,  String? firstAirDate,  List<String> genres,  List<String> networks,  int seasonCount,  String? status)  $default,) {final _that = this;
switch (_that) {
case _SeriesModel():
return $default(_that.tmdbId,_that.title,_that.overview,_that.posterPath,_that.backdropPath,_that.firstAirDate,_that.genres,_that.networks,_that.seasonCount,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: flexibleIntFromJson, toJson: flexibleIntToJson)  int tmdbId,  String title,  String? overview,  String? posterPath,  String? backdropPath,  String? firstAirDate,  List<String> genres,  List<String> networks,  int seasonCount,  String? status)?  $default,) {final _that = this;
switch (_that) {
case _SeriesModel() when $default != null:
return $default(_that.tmdbId,_that.title,_that.overview,_that.posterPath,_that.backdropPath,_that.firstAirDate,_that.genres,_that.networks,_that.seasonCount,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SeriesModel implements SeriesModel {
  const _SeriesModel({@JsonKey(fromJson: flexibleIntFromJson, toJson: flexibleIntToJson) required this.tmdbId, required this.title, this.overview, this.posterPath, this.backdropPath, this.firstAirDate, final  List<String> genres = const [], final  List<String> networks = const [], this.seasonCount = 0, this.status}): _genres = genres,_networks = networks;
  factory _SeriesModel.fromJson(Map<String, dynamic> json) => _$SeriesModelFromJson(json);

@override@JsonKey(fromJson: flexibleIntFromJson, toJson: flexibleIntToJson) final  int tmdbId;
@override final  String title;
@override final  String? overview;
@override final  String? posterPath;
@override final  String? backdropPath;
@override final  String? firstAirDate;
 final  List<String> _genres;
@override@JsonKey() List<String> get genres {
  if (_genres is EqualUnmodifiableListView) return _genres;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_genres);
}

 final  List<String> _networks;
@override@JsonKey() List<String> get networks {
  if (_networks is EqualUnmodifiableListView) return _networks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_networks);
}

@override@JsonKey() final  int seasonCount;
@override final  String? status;

/// Create a copy of SeriesModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SeriesModelCopyWith<_SeriesModel> get copyWith => __$SeriesModelCopyWithImpl<_SeriesModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SeriesModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SeriesModel&&(identical(other.tmdbId, tmdbId) || other.tmdbId == tmdbId)&&(identical(other.title, title) || other.title == title)&&(identical(other.overview, overview) || other.overview == overview)&&(identical(other.posterPath, posterPath) || other.posterPath == posterPath)&&(identical(other.backdropPath, backdropPath) || other.backdropPath == backdropPath)&&(identical(other.firstAirDate, firstAirDate) || other.firstAirDate == firstAirDate)&&const DeepCollectionEquality().equals(other._genres, _genres)&&const DeepCollectionEquality().equals(other._networks, _networks)&&(identical(other.seasonCount, seasonCount) || other.seasonCount == seasonCount)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tmdbId,title,overview,posterPath,backdropPath,firstAirDate,const DeepCollectionEquality().hash(_genres),const DeepCollectionEquality().hash(_networks),seasonCount,status);

@override
String toString() {
  return 'SeriesModel(tmdbId: $tmdbId, title: $title, overview: $overview, posterPath: $posterPath, backdropPath: $backdropPath, firstAirDate: $firstAirDate, genres: $genres, networks: $networks, seasonCount: $seasonCount, status: $status)';
}


}

/// @nodoc
abstract mixin class _$SeriesModelCopyWith<$Res> implements $SeriesModelCopyWith<$Res> {
  factory _$SeriesModelCopyWith(_SeriesModel value, $Res Function(_SeriesModel) _then) = __$SeriesModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: flexibleIntFromJson, toJson: flexibleIntToJson) int tmdbId, String title, String? overview, String? posterPath, String? backdropPath, String? firstAirDate, List<String> genres, List<String> networks, int seasonCount, String? status
});




}
/// @nodoc
class __$SeriesModelCopyWithImpl<$Res>
    implements _$SeriesModelCopyWith<$Res> {
  __$SeriesModelCopyWithImpl(this._self, this._then);

  final _SeriesModel _self;
  final $Res Function(_SeriesModel) _then;

/// Create a copy of SeriesModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tmdbId = null,Object? title = null,Object? overview = freezed,Object? posterPath = freezed,Object? backdropPath = freezed,Object? firstAirDate = freezed,Object? genres = null,Object? networks = null,Object? seasonCount = null,Object? status = freezed,}) {
  return _then(_SeriesModel(
tmdbId: null == tmdbId ? _self.tmdbId : tmdbId // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,overview: freezed == overview ? _self.overview : overview // ignore: cast_nullable_to_non_nullable
as String?,posterPath: freezed == posterPath ? _self.posterPath : posterPath // ignore: cast_nullable_to_non_nullable
as String?,backdropPath: freezed == backdropPath ? _self.backdropPath : backdropPath // ignore: cast_nullable_to_non_nullable
as String?,firstAirDate: freezed == firstAirDate ? _self.firstAirDate : firstAirDate // ignore: cast_nullable_to_non_nullable
as String?,genres: null == genres ? _self._genres : genres // ignore: cast_nullable_to_non_nullable
as List<String>,networks: null == networks ? _self._networks : networks // ignore: cast_nullable_to_non_nullable
as List<String>,seasonCount: null == seasonCount ? _self.seasonCount : seasonCount // ignore: cast_nullable_to_non_nullable
as int,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
