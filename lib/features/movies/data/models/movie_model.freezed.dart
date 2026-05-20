// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'movie_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MovieModel {

@JsonKey(fromJson: flexibleIntFromJson, toJson: flexibleIntToJson) int get tmdbId; String get title; String? get overview; String? get posterPath; String? get backdropPath; String? get releaseDate; List<String> get genres;@JsonKey(readValue: _readRuntimeMinutes, fromJson: flexibleNullableIntFromJson, toJson: flexibleNullableIntToJson) int? get runtimeMinutes; String? get status;
/// Create a copy of MovieModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MovieModelCopyWith<MovieModel> get copyWith => _$MovieModelCopyWithImpl<MovieModel>(this as MovieModel, _$identity);

  /// Serializes this MovieModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MovieModel&&(identical(other.tmdbId, tmdbId) || other.tmdbId == tmdbId)&&(identical(other.title, title) || other.title == title)&&(identical(other.overview, overview) || other.overview == overview)&&(identical(other.posterPath, posterPath) || other.posterPath == posterPath)&&(identical(other.backdropPath, backdropPath) || other.backdropPath == backdropPath)&&(identical(other.releaseDate, releaseDate) || other.releaseDate == releaseDate)&&const DeepCollectionEquality().equals(other.genres, genres)&&(identical(other.runtimeMinutes, runtimeMinutes) || other.runtimeMinutes == runtimeMinutes)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tmdbId,title,overview,posterPath,backdropPath,releaseDate,const DeepCollectionEquality().hash(genres),runtimeMinutes,status);

@override
String toString() {
  return 'MovieModel(tmdbId: $tmdbId, title: $title, overview: $overview, posterPath: $posterPath, backdropPath: $backdropPath, releaseDate: $releaseDate, genres: $genres, runtimeMinutes: $runtimeMinutes, status: $status)';
}


}

/// @nodoc
abstract mixin class $MovieModelCopyWith<$Res>  {
  factory $MovieModelCopyWith(MovieModel value, $Res Function(MovieModel) _then) = _$MovieModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: flexibleIntFromJson, toJson: flexibleIntToJson) int tmdbId, String title, String? overview, String? posterPath, String? backdropPath, String? releaseDate, List<String> genres,@JsonKey(readValue: _readRuntimeMinutes, fromJson: flexibleNullableIntFromJson, toJson: flexibleNullableIntToJson) int? runtimeMinutes, String? status
});




}
/// @nodoc
class _$MovieModelCopyWithImpl<$Res>
    implements $MovieModelCopyWith<$Res> {
  _$MovieModelCopyWithImpl(this._self, this._then);

  final MovieModel _self;
  final $Res Function(MovieModel) _then;

/// Create a copy of MovieModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tmdbId = null,Object? title = null,Object? overview = freezed,Object? posterPath = freezed,Object? backdropPath = freezed,Object? releaseDate = freezed,Object? genres = null,Object? runtimeMinutes = freezed,Object? status = freezed,}) {
  return _then(_self.copyWith(
tmdbId: null == tmdbId ? _self.tmdbId : tmdbId // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,overview: freezed == overview ? _self.overview : overview // ignore: cast_nullable_to_non_nullable
as String?,posterPath: freezed == posterPath ? _self.posterPath : posterPath // ignore: cast_nullable_to_non_nullable
as String?,backdropPath: freezed == backdropPath ? _self.backdropPath : backdropPath // ignore: cast_nullable_to_non_nullable
as String?,releaseDate: freezed == releaseDate ? _self.releaseDate : releaseDate // ignore: cast_nullable_to_non_nullable
as String?,genres: null == genres ? _self.genres : genres // ignore: cast_nullable_to_non_nullable
as List<String>,runtimeMinutes: freezed == runtimeMinutes ? _self.runtimeMinutes : runtimeMinutes // ignore: cast_nullable_to_non_nullable
as int?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MovieModel].
extension MovieModelPatterns on MovieModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MovieModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MovieModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MovieModel value)  $default,){
final _that = this;
switch (_that) {
case _MovieModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MovieModel value)?  $default,){
final _that = this;
switch (_that) {
case _MovieModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: flexibleIntFromJson, toJson: flexibleIntToJson)  int tmdbId,  String title,  String? overview,  String? posterPath,  String? backdropPath,  String? releaseDate,  List<String> genres, @JsonKey(readValue: _readRuntimeMinutes, fromJson: flexibleNullableIntFromJson, toJson: flexibleNullableIntToJson)  int? runtimeMinutes,  String? status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MovieModel() when $default != null:
return $default(_that.tmdbId,_that.title,_that.overview,_that.posterPath,_that.backdropPath,_that.releaseDate,_that.genres,_that.runtimeMinutes,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: flexibleIntFromJson, toJson: flexibleIntToJson)  int tmdbId,  String title,  String? overview,  String? posterPath,  String? backdropPath,  String? releaseDate,  List<String> genres, @JsonKey(readValue: _readRuntimeMinutes, fromJson: flexibleNullableIntFromJson, toJson: flexibleNullableIntToJson)  int? runtimeMinutes,  String? status)  $default,) {final _that = this;
switch (_that) {
case _MovieModel():
return $default(_that.tmdbId,_that.title,_that.overview,_that.posterPath,_that.backdropPath,_that.releaseDate,_that.genres,_that.runtimeMinutes,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: flexibleIntFromJson, toJson: flexibleIntToJson)  int tmdbId,  String title,  String? overview,  String? posterPath,  String? backdropPath,  String? releaseDate,  List<String> genres, @JsonKey(readValue: _readRuntimeMinutes, fromJson: flexibleNullableIntFromJson, toJson: flexibleNullableIntToJson)  int? runtimeMinutes,  String? status)?  $default,) {final _that = this;
switch (_that) {
case _MovieModel() when $default != null:
return $default(_that.tmdbId,_that.title,_that.overview,_that.posterPath,_that.backdropPath,_that.releaseDate,_that.genres,_that.runtimeMinutes,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MovieModel implements MovieModel {
  const _MovieModel({@JsonKey(fromJson: flexibleIntFromJson, toJson: flexibleIntToJson) required this.tmdbId, required this.title, this.overview, this.posterPath, this.backdropPath, this.releaseDate, final  List<String> genres = const [], @JsonKey(readValue: _readRuntimeMinutes, fromJson: flexibleNullableIntFromJson, toJson: flexibleNullableIntToJson) this.runtimeMinutes, this.status}): _genres = genres;
  factory _MovieModel.fromJson(Map<String, dynamic> json) => _$MovieModelFromJson(json);

@override@JsonKey(fromJson: flexibleIntFromJson, toJson: flexibleIntToJson) final  int tmdbId;
@override final  String title;
@override final  String? overview;
@override final  String? posterPath;
@override final  String? backdropPath;
@override final  String? releaseDate;
 final  List<String> _genres;
@override@JsonKey() List<String> get genres {
  if (_genres is EqualUnmodifiableListView) return _genres;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_genres);
}

@override@JsonKey(readValue: _readRuntimeMinutes, fromJson: flexibleNullableIntFromJson, toJson: flexibleNullableIntToJson) final  int? runtimeMinutes;
@override final  String? status;

/// Create a copy of MovieModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MovieModelCopyWith<_MovieModel> get copyWith => __$MovieModelCopyWithImpl<_MovieModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MovieModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MovieModel&&(identical(other.tmdbId, tmdbId) || other.tmdbId == tmdbId)&&(identical(other.title, title) || other.title == title)&&(identical(other.overview, overview) || other.overview == overview)&&(identical(other.posterPath, posterPath) || other.posterPath == posterPath)&&(identical(other.backdropPath, backdropPath) || other.backdropPath == backdropPath)&&(identical(other.releaseDate, releaseDate) || other.releaseDate == releaseDate)&&const DeepCollectionEquality().equals(other._genres, _genres)&&(identical(other.runtimeMinutes, runtimeMinutes) || other.runtimeMinutes == runtimeMinutes)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tmdbId,title,overview,posterPath,backdropPath,releaseDate,const DeepCollectionEquality().hash(_genres),runtimeMinutes,status);

@override
String toString() {
  return 'MovieModel(tmdbId: $tmdbId, title: $title, overview: $overview, posterPath: $posterPath, backdropPath: $backdropPath, releaseDate: $releaseDate, genres: $genres, runtimeMinutes: $runtimeMinutes, status: $status)';
}


}

/// @nodoc
abstract mixin class _$MovieModelCopyWith<$Res> implements $MovieModelCopyWith<$Res> {
  factory _$MovieModelCopyWith(_MovieModel value, $Res Function(_MovieModel) _then) = __$MovieModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: flexibleIntFromJson, toJson: flexibleIntToJson) int tmdbId, String title, String? overview, String? posterPath, String? backdropPath, String? releaseDate, List<String> genres,@JsonKey(readValue: _readRuntimeMinutes, fromJson: flexibleNullableIntFromJson, toJson: flexibleNullableIntToJson) int? runtimeMinutes, String? status
});




}
/// @nodoc
class __$MovieModelCopyWithImpl<$Res>
    implements _$MovieModelCopyWith<$Res> {
  __$MovieModelCopyWithImpl(this._self, this._then);

  final _MovieModel _self;
  final $Res Function(_MovieModel) _then;

/// Create a copy of MovieModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tmdbId = null,Object? title = null,Object? overview = freezed,Object? posterPath = freezed,Object? backdropPath = freezed,Object? releaseDate = freezed,Object? genres = null,Object? runtimeMinutes = freezed,Object? status = freezed,}) {
  return _then(_MovieModel(
tmdbId: null == tmdbId ? _self.tmdbId : tmdbId // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,overview: freezed == overview ? _self.overview : overview // ignore: cast_nullable_to_non_nullable
as String?,posterPath: freezed == posterPath ? _self.posterPath : posterPath // ignore: cast_nullable_to_non_nullable
as String?,backdropPath: freezed == backdropPath ? _self.backdropPath : backdropPath // ignore: cast_nullable_to_non_nullable
as String?,releaseDate: freezed == releaseDate ? _self.releaseDate : releaseDate // ignore: cast_nullable_to_non_nullable
as String?,genres: null == genres ? _self._genres : genres // ignore: cast_nullable_to_non_nullable
as List<String>,runtimeMinutes: freezed == runtimeMinutes ? _self.runtimeMinutes : runtimeMinutes // ignore: cast_nullable_to_non_nullable
as int?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
