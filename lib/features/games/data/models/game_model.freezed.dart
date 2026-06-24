// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GameModel {

 String get gameId; String get title; String? get summary; String? get genre; String? get coverUrl; String? get backdropUrl; String? get releaseDate; List<String> get platforms; String? get developer; String? get publisher; String? get franchise; List<String> get gameModes;
/// Create a copy of GameModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameModelCopyWith<GameModel> get copyWith => _$GameModelCopyWithImpl<GameModel>(this as GameModel, _$identity);

  /// Serializes this GameModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameModel&&(identical(other.gameId, gameId) || other.gameId == gameId)&&(identical(other.title, title) || other.title == title)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.genre, genre) || other.genre == genre)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.backdropUrl, backdropUrl) || other.backdropUrl == backdropUrl)&&(identical(other.releaseDate, releaseDate) || other.releaseDate == releaseDate)&&const DeepCollectionEquality().equals(other.platforms, platforms)&&(identical(other.developer, developer) || other.developer == developer)&&(identical(other.publisher, publisher) || other.publisher == publisher)&&(identical(other.franchise, franchise) || other.franchise == franchise)&&const DeepCollectionEquality().equals(other.gameModes, gameModes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,gameId,title,summary,genre,coverUrl,backdropUrl,releaseDate,const DeepCollectionEquality().hash(platforms),developer,publisher,franchise,const DeepCollectionEquality().hash(gameModes));

@override
String toString() {
  return 'GameModel(gameId: $gameId, title: $title, summary: $summary, genre: $genre, coverUrl: $coverUrl, backdropUrl: $backdropUrl, releaseDate: $releaseDate, platforms: $platforms, developer: $developer, publisher: $publisher, franchise: $franchise, gameModes: $gameModes)';
}


}

/// @nodoc
abstract mixin class $GameModelCopyWith<$Res>  {
  factory $GameModelCopyWith(GameModel value, $Res Function(GameModel) _then) = _$GameModelCopyWithImpl;
@useResult
$Res call({
 String gameId, String title, String? summary, String? genre, String? coverUrl, String? backdropUrl, String? releaseDate, List<String> platforms, String? developer, String? publisher, String? franchise, List<String> gameModes
});




}
/// @nodoc
class _$GameModelCopyWithImpl<$Res>
    implements $GameModelCopyWith<$Res> {
  _$GameModelCopyWithImpl(this._self, this._then);

  final GameModel _self;
  final $Res Function(GameModel) _then;

/// Create a copy of GameModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? gameId = null,Object? title = null,Object? summary = freezed,Object? genre = freezed,Object? coverUrl = freezed,Object? backdropUrl = freezed,Object? releaseDate = freezed,Object? platforms = null,Object? developer = freezed,Object? publisher = freezed,Object? franchise = freezed,Object? gameModes = null,}) {
  return _then(_self.copyWith(
gameId: null == gameId ? _self.gameId : gameId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String?,genre: freezed == genre ? _self.genre : genre // ignore: cast_nullable_to_non_nullable
as String?,coverUrl: freezed == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String?,backdropUrl: freezed == backdropUrl ? _self.backdropUrl : backdropUrl // ignore: cast_nullable_to_non_nullable
as String?,releaseDate: freezed == releaseDate ? _self.releaseDate : releaseDate // ignore: cast_nullable_to_non_nullable
as String?,platforms: null == platforms ? _self.platforms : platforms // ignore: cast_nullable_to_non_nullable
as List<String>,developer: freezed == developer ? _self.developer : developer // ignore: cast_nullable_to_non_nullable
as String?,publisher: freezed == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as String?,franchise: freezed == franchise ? _self.franchise : franchise // ignore: cast_nullable_to_non_nullable
as String?,gameModes: null == gameModes ? _self.gameModes : gameModes // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [GameModel].
extension GameModelPatterns on GameModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GameModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GameModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GameModel value)  $default,){
final _that = this;
switch (_that) {
case _GameModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GameModel value)?  $default,){
final _that = this;
switch (_that) {
case _GameModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String gameId,  String title,  String? summary,  String? genre,  String? coverUrl,  String? backdropUrl,  String? releaseDate,  List<String> platforms,  String? developer,  String? publisher,  String? franchise,  List<String> gameModes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GameModel() when $default != null:
return $default(_that.gameId,_that.title,_that.summary,_that.genre,_that.coverUrl,_that.backdropUrl,_that.releaseDate,_that.platforms,_that.developer,_that.publisher,_that.franchise,_that.gameModes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String gameId,  String title,  String? summary,  String? genre,  String? coverUrl,  String? backdropUrl,  String? releaseDate,  List<String> platforms,  String? developer,  String? publisher,  String? franchise,  List<String> gameModes)  $default,) {final _that = this;
switch (_that) {
case _GameModel():
return $default(_that.gameId,_that.title,_that.summary,_that.genre,_that.coverUrl,_that.backdropUrl,_that.releaseDate,_that.platforms,_that.developer,_that.publisher,_that.franchise,_that.gameModes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String gameId,  String title,  String? summary,  String? genre,  String? coverUrl,  String? backdropUrl,  String? releaseDate,  List<String> platforms,  String? developer,  String? publisher,  String? franchise,  List<String> gameModes)?  $default,) {final _that = this;
switch (_that) {
case _GameModel() when $default != null:
return $default(_that.gameId,_that.title,_that.summary,_that.genre,_that.coverUrl,_that.backdropUrl,_that.releaseDate,_that.platforms,_that.developer,_that.publisher,_that.franchise,_that.gameModes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GameModel implements GameModel {
  const _GameModel({required this.gameId, required this.title, this.summary, this.genre, this.coverUrl, this.backdropUrl, this.releaseDate, final  List<String> platforms = const [], this.developer, this.publisher, this.franchise, final  List<String> gameModes = const []}): _platforms = platforms,_gameModes = gameModes;
  factory _GameModel.fromJson(Map<String, dynamic> json) => _$GameModelFromJson(json);

@override final  String gameId;
@override final  String title;
@override final  String? summary;
@override final  String? genre;
@override final  String? coverUrl;
@override final  String? backdropUrl;
@override final  String? releaseDate;
 final  List<String> _platforms;
@override@JsonKey() List<String> get platforms {
  if (_platforms is EqualUnmodifiableListView) return _platforms;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_platforms);
}

@override final  String? developer;
@override final  String? publisher;
@override final  String? franchise;
 final  List<String> _gameModes;
@override@JsonKey() List<String> get gameModes {
  if (_gameModes is EqualUnmodifiableListView) return _gameModes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_gameModes);
}


/// Create a copy of GameModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameModelCopyWith<_GameModel> get copyWith => __$GameModelCopyWithImpl<_GameModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GameModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GameModel&&(identical(other.gameId, gameId) || other.gameId == gameId)&&(identical(other.title, title) || other.title == title)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.genre, genre) || other.genre == genre)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.backdropUrl, backdropUrl) || other.backdropUrl == backdropUrl)&&(identical(other.releaseDate, releaseDate) || other.releaseDate == releaseDate)&&const DeepCollectionEquality().equals(other._platforms, _platforms)&&(identical(other.developer, developer) || other.developer == developer)&&(identical(other.publisher, publisher) || other.publisher == publisher)&&(identical(other.franchise, franchise) || other.franchise == franchise)&&const DeepCollectionEquality().equals(other._gameModes, _gameModes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,gameId,title,summary,genre,coverUrl,backdropUrl,releaseDate,const DeepCollectionEquality().hash(_platforms),developer,publisher,franchise,const DeepCollectionEquality().hash(_gameModes));

@override
String toString() {
  return 'GameModel(gameId: $gameId, title: $title, summary: $summary, genre: $genre, coverUrl: $coverUrl, backdropUrl: $backdropUrl, releaseDate: $releaseDate, platforms: $platforms, developer: $developer, publisher: $publisher, franchise: $franchise, gameModes: $gameModes)';
}


}

/// @nodoc
abstract mixin class _$GameModelCopyWith<$Res> implements $GameModelCopyWith<$Res> {
  factory _$GameModelCopyWith(_GameModel value, $Res Function(_GameModel) _then) = __$GameModelCopyWithImpl;
@override @useResult
$Res call({
 String gameId, String title, String? summary, String? genre, String? coverUrl, String? backdropUrl, String? releaseDate, List<String> platforms, String? developer, String? publisher, String? franchise, List<String> gameModes
});




}
/// @nodoc
class __$GameModelCopyWithImpl<$Res>
    implements _$GameModelCopyWith<$Res> {
  __$GameModelCopyWithImpl(this._self, this._then);

  final _GameModel _self;
  final $Res Function(_GameModel) _then;

/// Create a copy of GameModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? gameId = null,Object? title = null,Object? summary = freezed,Object? genre = freezed,Object? coverUrl = freezed,Object? backdropUrl = freezed,Object? releaseDate = freezed,Object? platforms = null,Object? developer = freezed,Object? publisher = freezed,Object? franchise = freezed,Object? gameModes = null,}) {
  return _then(_GameModel(
gameId: null == gameId ? _self.gameId : gameId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String?,genre: freezed == genre ? _self.genre : genre // ignore: cast_nullable_to_non_nullable
as String?,coverUrl: freezed == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String?,backdropUrl: freezed == backdropUrl ? _self.backdropUrl : backdropUrl // ignore: cast_nullable_to_non_nullable
as String?,releaseDate: freezed == releaseDate ? _self.releaseDate : releaseDate // ignore: cast_nullable_to_non_nullable
as String?,platforms: null == platforms ? _self._platforms : platforms // ignore: cast_nullable_to_non_nullable
as List<String>,developer: freezed == developer ? _self.developer : developer // ignore: cast_nullable_to_non_nullable
as String?,publisher: freezed == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as String?,franchise: freezed == franchise ? _self.franchise : franchise // ignore: cast_nullable_to_non_nullable
as String?,gameModes: null == gameModes ? _self._gameModes : gameModes // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
