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
mixin _$EpisodeAirInfoModel {

 String? get airDate; int get episodeNumber; int get seasonNumber; String? get name; String? get overview;
/// Create a copy of EpisodeAirInfoModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EpisodeAirInfoModelCopyWith<EpisodeAirInfoModel> get copyWith => _$EpisodeAirInfoModelCopyWithImpl<EpisodeAirInfoModel>(this as EpisodeAirInfoModel, _$identity);

  /// Serializes this EpisodeAirInfoModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EpisodeAirInfoModel&&(identical(other.airDate, airDate) || other.airDate == airDate)&&(identical(other.episodeNumber, episodeNumber) || other.episodeNumber == episodeNumber)&&(identical(other.seasonNumber, seasonNumber) || other.seasonNumber == seasonNumber)&&(identical(other.name, name) || other.name == name)&&(identical(other.overview, overview) || other.overview == overview));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,airDate,episodeNumber,seasonNumber,name,overview);

@override
String toString() {
  return 'EpisodeAirInfoModel(airDate: $airDate, episodeNumber: $episodeNumber, seasonNumber: $seasonNumber, name: $name, overview: $overview)';
}


}

/// @nodoc
abstract mixin class $EpisodeAirInfoModelCopyWith<$Res>  {
  factory $EpisodeAirInfoModelCopyWith(EpisodeAirInfoModel value, $Res Function(EpisodeAirInfoModel) _then) = _$EpisodeAirInfoModelCopyWithImpl;
@useResult
$Res call({
 String? airDate, int episodeNumber, int seasonNumber, String? name, String? overview
});




}
/// @nodoc
class _$EpisodeAirInfoModelCopyWithImpl<$Res>
    implements $EpisodeAirInfoModelCopyWith<$Res> {
  _$EpisodeAirInfoModelCopyWithImpl(this._self, this._then);

  final EpisodeAirInfoModel _self;
  final $Res Function(EpisodeAirInfoModel) _then;

/// Create a copy of EpisodeAirInfoModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? airDate = freezed,Object? episodeNumber = null,Object? seasonNumber = null,Object? name = freezed,Object? overview = freezed,}) {
  return _then(_self.copyWith(
airDate: freezed == airDate ? _self.airDate : airDate // ignore: cast_nullable_to_non_nullable
as String?,episodeNumber: null == episodeNumber ? _self.episodeNumber : episodeNumber // ignore: cast_nullable_to_non_nullable
as int,seasonNumber: null == seasonNumber ? _self.seasonNumber : seasonNumber // ignore: cast_nullable_to_non_nullable
as int,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,overview: freezed == overview ? _self.overview : overview // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [EpisodeAirInfoModel].
extension EpisodeAirInfoModelPatterns on EpisodeAirInfoModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EpisodeAirInfoModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EpisodeAirInfoModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EpisodeAirInfoModel value)  $default,){
final _that = this;
switch (_that) {
case _EpisodeAirInfoModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EpisodeAirInfoModel value)?  $default,){
final _that = this;
switch (_that) {
case _EpisodeAirInfoModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? airDate,  int episodeNumber,  int seasonNumber,  String? name,  String? overview)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EpisodeAirInfoModel() when $default != null:
return $default(_that.airDate,_that.episodeNumber,_that.seasonNumber,_that.name,_that.overview);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? airDate,  int episodeNumber,  int seasonNumber,  String? name,  String? overview)  $default,) {final _that = this;
switch (_that) {
case _EpisodeAirInfoModel():
return $default(_that.airDate,_that.episodeNumber,_that.seasonNumber,_that.name,_that.overview);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? airDate,  int episodeNumber,  int seasonNumber,  String? name,  String? overview)?  $default,) {final _that = this;
switch (_that) {
case _EpisodeAirInfoModel() when $default != null:
return $default(_that.airDate,_that.episodeNumber,_that.seasonNumber,_that.name,_that.overview);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EpisodeAirInfoModel implements EpisodeAirInfoModel {
  const _EpisodeAirInfoModel({this.airDate, this.episodeNumber = 0, this.seasonNumber = 0, this.name, this.overview});
  factory _EpisodeAirInfoModel.fromJson(Map<String, dynamic> json) => _$EpisodeAirInfoModelFromJson(json);

@override final  String? airDate;
@override@JsonKey() final  int episodeNumber;
@override@JsonKey() final  int seasonNumber;
@override final  String? name;
@override final  String? overview;

/// Create a copy of EpisodeAirInfoModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EpisodeAirInfoModelCopyWith<_EpisodeAirInfoModel> get copyWith => __$EpisodeAirInfoModelCopyWithImpl<_EpisodeAirInfoModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EpisodeAirInfoModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EpisodeAirInfoModel&&(identical(other.airDate, airDate) || other.airDate == airDate)&&(identical(other.episodeNumber, episodeNumber) || other.episodeNumber == episodeNumber)&&(identical(other.seasonNumber, seasonNumber) || other.seasonNumber == seasonNumber)&&(identical(other.name, name) || other.name == name)&&(identical(other.overview, overview) || other.overview == overview));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,airDate,episodeNumber,seasonNumber,name,overview);

@override
String toString() {
  return 'EpisodeAirInfoModel(airDate: $airDate, episodeNumber: $episodeNumber, seasonNumber: $seasonNumber, name: $name, overview: $overview)';
}


}

/// @nodoc
abstract mixin class _$EpisodeAirInfoModelCopyWith<$Res> implements $EpisodeAirInfoModelCopyWith<$Res> {
  factory _$EpisodeAirInfoModelCopyWith(_EpisodeAirInfoModel value, $Res Function(_EpisodeAirInfoModel) _then) = __$EpisodeAirInfoModelCopyWithImpl;
@override @useResult
$Res call({
 String? airDate, int episodeNumber, int seasonNumber, String? name, String? overview
});




}
/// @nodoc
class __$EpisodeAirInfoModelCopyWithImpl<$Res>
    implements _$EpisodeAirInfoModelCopyWith<$Res> {
  __$EpisodeAirInfoModelCopyWithImpl(this._self, this._then);

  final _EpisodeAirInfoModel _self;
  final $Res Function(_EpisodeAirInfoModel) _then;

/// Create a copy of EpisodeAirInfoModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? airDate = freezed,Object? episodeNumber = null,Object? seasonNumber = null,Object? name = freezed,Object? overview = freezed,}) {
  return _then(_EpisodeAirInfoModel(
airDate: freezed == airDate ? _self.airDate : airDate // ignore: cast_nullable_to_non_nullable
as String?,episodeNumber: null == episodeNumber ? _self.episodeNumber : episodeNumber // ignore: cast_nullable_to_non_nullable
as int,seasonNumber: null == seasonNumber ? _self.seasonNumber : seasonNumber // ignore: cast_nullable_to_non_nullable
as int,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,overview: freezed == overview ? _self.overview : overview // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$SeriesModel {

@JsonKey(fromJson: flexibleIntFromJson, toJson: flexibleIntToJson) int get tmdbId; String get title; String? get overview; String? get posterPath; String? get backdropPath; String? get firstAirDate; List<String> get genres; List<String> get networks; int get seasonCount; String? get status; String? get seriesId; String? get createdAt; double? get voteAverage; int? get voteCount; double? get popularity; List<String> get originCountry; List<int> get episodeRunTime; int get numberOfEpisodes; List<String> get createdBy; String? get type; EpisodeAirInfoModel? get lastEpisodeToAir; EpisodeAirInfoModel? get nextEpisodeToAir;
/// Create a copy of SeriesModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SeriesModelCopyWith<SeriesModel> get copyWith => _$SeriesModelCopyWithImpl<SeriesModel>(this as SeriesModel, _$identity);

  /// Serializes this SeriesModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SeriesModel&&(identical(other.tmdbId, tmdbId) || other.tmdbId == tmdbId)&&(identical(other.title, title) || other.title == title)&&(identical(other.overview, overview) || other.overview == overview)&&(identical(other.posterPath, posterPath) || other.posterPath == posterPath)&&(identical(other.backdropPath, backdropPath) || other.backdropPath == backdropPath)&&(identical(other.firstAirDate, firstAirDate) || other.firstAirDate == firstAirDate)&&const DeepCollectionEquality().equals(other.genres, genres)&&const DeepCollectionEquality().equals(other.networks, networks)&&(identical(other.seasonCount, seasonCount) || other.seasonCount == seasonCount)&&(identical(other.status, status) || other.status == status)&&(identical(other.seriesId, seriesId) || other.seriesId == seriesId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.voteAverage, voteAverage) || other.voteAverage == voteAverage)&&(identical(other.voteCount, voteCount) || other.voteCount == voteCount)&&(identical(other.popularity, popularity) || other.popularity == popularity)&&const DeepCollectionEquality().equals(other.originCountry, originCountry)&&const DeepCollectionEquality().equals(other.episodeRunTime, episodeRunTime)&&(identical(other.numberOfEpisodes, numberOfEpisodes) || other.numberOfEpisodes == numberOfEpisodes)&&const DeepCollectionEquality().equals(other.createdBy, createdBy)&&(identical(other.type, type) || other.type == type)&&(identical(other.lastEpisodeToAir, lastEpisodeToAir) || other.lastEpisodeToAir == lastEpisodeToAir)&&(identical(other.nextEpisodeToAir, nextEpisodeToAir) || other.nextEpisodeToAir == nextEpisodeToAir));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,tmdbId,title,overview,posterPath,backdropPath,firstAirDate,const DeepCollectionEquality().hash(genres),const DeepCollectionEquality().hash(networks),seasonCount,status,seriesId,createdAt,voteAverage,voteCount,popularity,const DeepCollectionEquality().hash(originCountry),const DeepCollectionEquality().hash(episodeRunTime),numberOfEpisodes,const DeepCollectionEquality().hash(createdBy),type,lastEpisodeToAir,nextEpisodeToAir]);

@override
String toString() {
  return 'SeriesModel(tmdbId: $tmdbId, title: $title, overview: $overview, posterPath: $posterPath, backdropPath: $backdropPath, firstAirDate: $firstAirDate, genres: $genres, networks: $networks, seasonCount: $seasonCount, status: $status, seriesId: $seriesId, createdAt: $createdAt, voteAverage: $voteAverage, voteCount: $voteCount, popularity: $popularity, originCountry: $originCountry, episodeRunTime: $episodeRunTime, numberOfEpisodes: $numberOfEpisodes, createdBy: $createdBy, type: $type, lastEpisodeToAir: $lastEpisodeToAir, nextEpisodeToAir: $nextEpisodeToAir)';
}


}

/// @nodoc
abstract mixin class $SeriesModelCopyWith<$Res>  {
  factory $SeriesModelCopyWith(SeriesModel value, $Res Function(SeriesModel) _then) = _$SeriesModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: flexibleIntFromJson, toJson: flexibleIntToJson) int tmdbId, String title, String? overview, String? posterPath, String? backdropPath, String? firstAirDate, List<String> genres, List<String> networks, int seasonCount, String? status, String? seriesId, String? createdAt, double? voteAverage, int? voteCount, double? popularity, List<String> originCountry, List<int> episodeRunTime, int numberOfEpisodes, List<String> createdBy, String? type, EpisodeAirInfoModel? lastEpisodeToAir, EpisodeAirInfoModel? nextEpisodeToAir
});


$EpisodeAirInfoModelCopyWith<$Res>? get lastEpisodeToAir;$EpisodeAirInfoModelCopyWith<$Res>? get nextEpisodeToAir;

}
/// @nodoc
class _$SeriesModelCopyWithImpl<$Res>
    implements $SeriesModelCopyWith<$Res> {
  _$SeriesModelCopyWithImpl(this._self, this._then);

  final SeriesModel _self;
  final $Res Function(SeriesModel) _then;

/// Create a copy of SeriesModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tmdbId = null,Object? title = null,Object? overview = freezed,Object? posterPath = freezed,Object? backdropPath = freezed,Object? firstAirDate = freezed,Object? genres = null,Object? networks = null,Object? seasonCount = null,Object? status = freezed,Object? seriesId = freezed,Object? createdAt = freezed,Object? voteAverage = freezed,Object? voteCount = freezed,Object? popularity = freezed,Object? originCountry = null,Object? episodeRunTime = null,Object? numberOfEpisodes = null,Object? createdBy = null,Object? type = freezed,Object? lastEpisodeToAir = freezed,Object? nextEpisodeToAir = freezed,}) {
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
as String?,seriesId: freezed == seriesId ? _self.seriesId : seriesId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,voteAverage: freezed == voteAverage ? _self.voteAverage : voteAverage // ignore: cast_nullable_to_non_nullable
as double?,voteCount: freezed == voteCount ? _self.voteCount : voteCount // ignore: cast_nullable_to_non_nullable
as int?,popularity: freezed == popularity ? _self.popularity : popularity // ignore: cast_nullable_to_non_nullable
as double?,originCountry: null == originCountry ? _self.originCountry : originCountry // ignore: cast_nullable_to_non_nullable
as List<String>,episodeRunTime: null == episodeRunTime ? _self.episodeRunTime : episodeRunTime // ignore: cast_nullable_to_non_nullable
as List<int>,numberOfEpisodes: null == numberOfEpisodes ? _self.numberOfEpisodes : numberOfEpisodes // ignore: cast_nullable_to_non_nullable
as int,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as List<String>,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,lastEpisodeToAir: freezed == lastEpisodeToAir ? _self.lastEpisodeToAir : lastEpisodeToAir // ignore: cast_nullable_to_non_nullable
as EpisodeAirInfoModel?,nextEpisodeToAir: freezed == nextEpisodeToAir ? _self.nextEpisodeToAir : nextEpisodeToAir // ignore: cast_nullable_to_non_nullable
as EpisodeAirInfoModel?,
  ));
}
/// Create a copy of SeriesModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EpisodeAirInfoModelCopyWith<$Res>? get lastEpisodeToAir {
    if (_self.lastEpisodeToAir == null) {
    return null;
  }

  return $EpisodeAirInfoModelCopyWith<$Res>(_self.lastEpisodeToAir!, (value) {
    return _then(_self.copyWith(lastEpisodeToAir: value));
  });
}/// Create a copy of SeriesModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EpisodeAirInfoModelCopyWith<$Res>? get nextEpisodeToAir {
    if (_self.nextEpisodeToAir == null) {
    return null;
  }

  return $EpisodeAirInfoModelCopyWith<$Res>(_self.nextEpisodeToAir!, (value) {
    return _then(_self.copyWith(nextEpisodeToAir: value));
  });
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: flexibleIntFromJson, toJson: flexibleIntToJson)  int tmdbId,  String title,  String? overview,  String? posterPath,  String? backdropPath,  String? firstAirDate,  List<String> genres,  List<String> networks,  int seasonCount,  String? status,  String? seriesId,  String? createdAt,  double? voteAverage,  int? voteCount,  double? popularity,  List<String> originCountry,  List<int> episodeRunTime,  int numberOfEpisodes,  List<String> createdBy,  String? type,  EpisodeAirInfoModel? lastEpisodeToAir,  EpisodeAirInfoModel? nextEpisodeToAir)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SeriesModel() when $default != null:
return $default(_that.tmdbId,_that.title,_that.overview,_that.posterPath,_that.backdropPath,_that.firstAirDate,_that.genres,_that.networks,_that.seasonCount,_that.status,_that.seriesId,_that.createdAt,_that.voteAverage,_that.voteCount,_that.popularity,_that.originCountry,_that.episodeRunTime,_that.numberOfEpisodes,_that.createdBy,_that.type,_that.lastEpisodeToAir,_that.nextEpisodeToAir);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: flexibleIntFromJson, toJson: flexibleIntToJson)  int tmdbId,  String title,  String? overview,  String? posterPath,  String? backdropPath,  String? firstAirDate,  List<String> genres,  List<String> networks,  int seasonCount,  String? status,  String? seriesId,  String? createdAt,  double? voteAverage,  int? voteCount,  double? popularity,  List<String> originCountry,  List<int> episodeRunTime,  int numberOfEpisodes,  List<String> createdBy,  String? type,  EpisodeAirInfoModel? lastEpisodeToAir,  EpisodeAirInfoModel? nextEpisodeToAir)  $default,) {final _that = this;
switch (_that) {
case _SeriesModel():
return $default(_that.tmdbId,_that.title,_that.overview,_that.posterPath,_that.backdropPath,_that.firstAirDate,_that.genres,_that.networks,_that.seasonCount,_that.status,_that.seriesId,_that.createdAt,_that.voteAverage,_that.voteCount,_that.popularity,_that.originCountry,_that.episodeRunTime,_that.numberOfEpisodes,_that.createdBy,_that.type,_that.lastEpisodeToAir,_that.nextEpisodeToAir);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: flexibleIntFromJson, toJson: flexibleIntToJson)  int tmdbId,  String title,  String? overview,  String? posterPath,  String? backdropPath,  String? firstAirDate,  List<String> genres,  List<String> networks,  int seasonCount,  String? status,  String? seriesId,  String? createdAt,  double? voteAverage,  int? voteCount,  double? popularity,  List<String> originCountry,  List<int> episodeRunTime,  int numberOfEpisodes,  List<String> createdBy,  String? type,  EpisodeAirInfoModel? lastEpisodeToAir,  EpisodeAirInfoModel? nextEpisodeToAir)?  $default,) {final _that = this;
switch (_that) {
case _SeriesModel() when $default != null:
return $default(_that.tmdbId,_that.title,_that.overview,_that.posterPath,_that.backdropPath,_that.firstAirDate,_that.genres,_that.networks,_that.seasonCount,_that.status,_that.seriesId,_that.createdAt,_that.voteAverage,_that.voteCount,_that.popularity,_that.originCountry,_that.episodeRunTime,_that.numberOfEpisodes,_that.createdBy,_that.type,_that.lastEpisodeToAir,_that.nextEpisodeToAir);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _SeriesModel implements SeriesModel {
  const _SeriesModel({@JsonKey(fromJson: flexibleIntFromJson, toJson: flexibleIntToJson) required this.tmdbId, required this.title, this.overview, this.posterPath, this.backdropPath, this.firstAirDate, final  List<String> genres = const [], final  List<String> networks = const [], this.seasonCount = 0, this.status, this.seriesId, this.createdAt, this.voteAverage, this.voteCount, this.popularity, final  List<String> originCountry = const [], final  List<int> episodeRunTime = const [], this.numberOfEpisodes = 0, final  List<String> createdBy = const [], this.type, this.lastEpisodeToAir, this.nextEpisodeToAir}): _genres = genres,_networks = networks,_originCountry = originCountry,_episodeRunTime = episodeRunTime,_createdBy = createdBy;
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
@override final  String? seriesId;
@override final  String? createdAt;
@override final  double? voteAverage;
@override final  int? voteCount;
@override final  double? popularity;
 final  List<String> _originCountry;
@override@JsonKey() List<String> get originCountry {
  if (_originCountry is EqualUnmodifiableListView) return _originCountry;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_originCountry);
}

 final  List<int> _episodeRunTime;
@override@JsonKey() List<int> get episodeRunTime {
  if (_episodeRunTime is EqualUnmodifiableListView) return _episodeRunTime;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_episodeRunTime);
}

@override@JsonKey() final  int numberOfEpisodes;
 final  List<String> _createdBy;
@override@JsonKey() List<String> get createdBy {
  if (_createdBy is EqualUnmodifiableListView) return _createdBy;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_createdBy);
}

@override final  String? type;
@override final  EpisodeAirInfoModel? lastEpisodeToAir;
@override final  EpisodeAirInfoModel? nextEpisodeToAir;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SeriesModel&&(identical(other.tmdbId, tmdbId) || other.tmdbId == tmdbId)&&(identical(other.title, title) || other.title == title)&&(identical(other.overview, overview) || other.overview == overview)&&(identical(other.posterPath, posterPath) || other.posterPath == posterPath)&&(identical(other.backdropPath, backdropPath) || other.backdropPath == backdropPath)&&(identical(other.firstAirDate, firstAirDate) || other.firstAirDate == firstAirDate)&&const DeepCollectionEquality().equals(other._genres, _genres)&&const DeepCollectionEquality().equals(other._networks, _networks)&&(identical(other.seasonCount, seasonCount) || other.seasonCount == seasonCount)&&(identical(other.status, status) || other.status == status)&&(identical(other.seriesId, seriesId) || other.seriesId == seriesId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.voteAverage, voteAverage) || other.voteAverage == voteAverage)&&(identical(other.voteCount, voteCount) || other.voteCount == voteCount)&&(identical(other.popularity, popularity) || other.popularity == popularity)&&const DeepCollectionEquality().equals(other._originCountry, _originCountry)&&const DeepCollectionEquality().equals(other._episodeRunTime, _episodeRunTime)&&(identical(other.numberOfEpisodes, numberOfEpisodes) || other.numberOfEpisodes == numberOfEpisodes)&&const DeepCollectionEquality().equals(other._createdBy, _createdBy)&&(identical(other.type, type) || other.type == type)&&(identical(other.lastEpisodeToAir, lastEpisodeToAir) || other.lastEpisodeToAir == lastEpisodeToAir)&&(identical(other.nextEpisodeToAir, nextEpisodeToAir) || other.nextEpisodeToAir == nextEpisodeToAir));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,tmdbId,title,overview,posterPath,backdropPath,firstAirDate,const DeepCollectionEquality().hash(_genres),const DeepCollectionEquality().hash(_networks),seasonCount,status,seriesId,createdAt,voteAverage,voteCount,popularity,const DeepCollectionEquality().hash(_originCountry),const DeepCollectionEquality().hash(_episodeRunTime),numberOfEpisodes,const DeepCollectionEquality().hash(_createdBy),type,lastEpisodeToAir,nextEpisodeToAir]);

@override
String toString() {
  return 'SeriesModel(tmdbId: $tmdbId, title: $title, overview: $overview, posterPath: $posterPath, backdropPath: $backdropPath, firstAirDate: $firstAirDate, genres: $genres, networks: $networks, seasonCount: $seasonCount, status: $status, seriesId: $seriesId, createdAt: $createdAt, voteAverage: $voteAverage, voteCount: $voteCount, popularity: $popularity, originCountry: $originCountry, episodeRunTime: $episodeRunTime, numberOfEpisodes: $numberOfEpisodes, createdBy: $createdBy, type: $type, lastEpisodeToAir: $lastEpisodeToAir, nextEpisodeToAir: $nextEpisodeToAir)';
}


}

/// @nodoc
abstract mixin class _$SeriesModelCopyWith<$Res> implements $SeriesModelCopyWith<$Res> {
  factory _$SeriesModelCopyWith(_SeriesModel value, $Res Function(_SeriesModel) _then) = __$SeriesModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: flexibleIntFromJson, toJson: flexibleIntToJson) int tmdbId, String title, String? overview, String? posterPath, String? backdropPath, String? firstAirDate, List<String> genres, List<String> networks, int seasonCount, String? status, String? seriesId, String? createdAt, double? voteAverage, int? voteCount, double? popularity, List<String> originCountry, List<int> episodeRunTime, int numberOfEpisodes, List<String> createdBy, String? type, EpisodeAirInfoModel? lastEpisodeToAir, EpisodeAirInfoModel? nextEpisodeToAir
});


@override $EpisodeAirInfoModelCopyWith<$Res>? get lastEpisodeToAir;@override $EpisodeAirInfoModelCopyWith<$Res>? get nextEpisodeToAir;

}
/// @nodoc
class __$SeriesModelCopyWithImpl<$Res>
    implements _$SeriesModelCopyWith<$Res> {
  __$SeriesModelCopyWithImpl(this._self, this._then);

  final _SeriesModel _self;
  final $Res Function(_SeriesModel) _then;

/// Create a copy of SeriesModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tmdbId = null,Object? title = null,Object? overview = freezed,Object? posterPath = freezed,Object? backdropPath = freezed,Object? firstAirDate = freezed,Object? genres = null,Object? networks = null,Object? seasonCount = null,Object? status = freezed,Object? seriesId = freezed,Object? createdAt = freezed,Object? voteAverage = freezed,Object? voteCount = freezed,Object? popularity = freezed,Object? originCountry = null,Object? episodeRunTime = null,Object? numberOfEpisodes = null,Object? createdBy = null,Object? type = freezed,Object? lastEpisodeToAir = freezed,Object? nextEpisodeToAir = freezed,}) {
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
as String?,seriesId: freezed == seriesId ? _self.seriesId : seriesId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,voteAverage: freezed == voteAverage ? _self.voteAverage : voteAverage // ignore: cast_nullable_to_non_nullable
as double?,voteCount: freezed == voteCount ? _self.voteCount : voteCount // ignore: cast_nullable_to_non_nullable
as int?,popularity: freezed == popularity ? _self.popularity : popularity // ignore: cast_nullable_to_non_nullable
as double?,originCountry: null == originCountry ? _self._originCountry : originCountry // ignore: cast_nullable_to_non_nullable
as List<String>,episodeRunTime: null == episodeRunTime ? _self._episodeRunTime : episodeRunTime // ignore: cast_nullable_to_non_nullable
as List<int>,numberOfEpisodes: null == numberOfEpisodes ? _self.numberOfEpisodes : numberOfEpisodes // ignore: cast_nullable_to_non_nullable
as int,createdBy: null == createdBy ? _self._createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as List<String>,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,lastEpisodeToAir: freezed == lastEpisodeToAir ? _self.lastEpisodeToAir : lastEpisodeToAir // ignore: cast_nullable_to_non_nullable
as EpisodeAirInfoModel?,nextEpisodeToAir: freezed == nextEpisodeToAir ? _self.nextEpisodeToAir : nextEpisodeToAir // ignore: cast_nullable_to_non_nullable
as EpisodeAirInfoModel?,
  ));
}

/// Create a copy of SeriesModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EpisodeAirInfoModelCopyWith<$Res>? get lastEpisodeToAir {
    if (_self.lastEpisodeToAir == null) {
    return null;
  }

  return $EpisodeAirInfoModelCopyWith<$Res>(_self.lastEpisodeToAir!, (value) {
    return _then(_self.copyWith(lastEpisodeToAir: value));
  });
}/// Create a copy of SeriesModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EpisodeAirInfoModelCopyWith<$Res>? get nextEpisodeToAir {
    if (_self.nextEpisodeToAir == null) {
    return null;
  }

  return $EpisodeAirInfoModelCopyWith<$Res>(_self.nextEpisodeToAir!, (value) {
    return _then(_self.copyWith(nextEpisodeToAir: value));
  });
}
}

// dart format on
