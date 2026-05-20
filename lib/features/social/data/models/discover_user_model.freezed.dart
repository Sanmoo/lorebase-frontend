// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'discover_user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DiscoverUserModel {

 String get userId; String get displayName; String? get avatarUrl; double get affinityScore; List<String> get commonGenres; List<SocialMediaModel> get commonMedia; bool get isFollowedByMe;
/// Create a copy of DiscoverUserModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DiscoverUserModelCopyWith<DiscoverUserModel> get copyWith => _$DiscoverUserModelCopyWithImpl<DiscoverUserModel>(this as DiscoverUserModel, _$identity);

  /// Serializes this DiscoverUserModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DiscoverUserModel&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.affinityScore, affinityScore) || other.affinityScore == affinityScore)&&const DeepCollectionEquality().equals(other.commonGenres, commonGenres)&&const DeepCollectionEquality().equals(other.commonMedia, commonMedia)&&(identical(other.isFollowedByMe, isFollowedByMe) || other.isFollowedByMe == isFollowedByMe));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,displayName,avatarUrl,affinityScore,const DeepCollectionEquality().hash(commonGenres),const DeepCollectionEquality().hash(commonMedia),isFollowedByMe);

@override
String toString() {
  return 'DiscoverUserModel(userId: $userId, displayName: $displayName, avatarUrl: $avatarUrl, affinityScore: $affinityScore, commonGenres: $commonGenres, commonMedia: $commonMedia, isFollowedByMe: $isFollowedByMe)';
}


}

/// @nodoc
abstract mixin class $DiscoverUserModelCopyWith<$Res>  {
  factory $DiscoverUserModelCopyWith(DiscoverUserModel value, $Res Function(DiscoverUserModel) _then) = _$DiscoverUserModelCopyWithImpl;
@useResult
$Res call({
 String userId, String displayName, String? avatarUrl, double affinityScore, List<String> commonGenres, List<SocialMediaModel> commonMedia, bool isFollowedByMe
});




}
/// @nodoc
class _$DiscoverUserModelCopyWithImpl<$Res>
    implements $DiscoverUserModelCopyWith<$Res> {
  _$DiscoverUserModelCopyWithImpl(this._self, this._then);

  final DiscoverUserModel _self;
  final $Res Function(DiscoverUserModel) _then;

/// Create a copy of DiscoverUserModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? displayName = null,Object? avatarUrl = freezed,Object? affinityScore = null,Object? commonGenres = null,Object? commonMedia = null,Object? isFollowedByMe = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,affinityScore: null == affinityScore ? _self.affinityScore : affinityScore // ignore: cast_nullable_to_non_nullable
as double,commonGenres: null == commonGenres ? _self.commonGenres : commonGenres // ignore: cast_nullable_to_non_nullable
as List<String>,commonMedia: null == commonMedia ? _self.commonMedia : commonMedia // ignore: cast_nullable_to_non_nullable
as List<SocialMediaModel>,isFollowedByMe: null == isFollowedByMe ? _self.isFollowedByMe : isFollowedByMe // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DiscoverUserModel].
extension DiscoverUserModelPatterns on DiscoverUserModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DiscoverUserModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DiscoverUserModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DiscoverUserModel value)  $default,){
final _that = this;
switch (_that) {
case _DiscoverUserModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DiscoverUserModel value)?  $default,){
final _that = this;
switch (_that) {
case _DiscoverUserModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String displayName,  String? avatarUrl,  double affinityScore,  List<String> commonGenres,  List<SocialMediaModel> commonMedia,  bool isFollowedByMe)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DiscoverUserModel() when $default != null:
return $default(_that.userId,_that.displayName,_that.avatarUrl,_that.affinityScore,_that.commonGenres,_that.commonMedia,_that.isFollowedByMe);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String displayName,  String? avatarUrl,  double affinityScore,  List<String> commonGenres,  List<SocialMediaModel> commonMedia,  bool isFollowedByMe)  $default,) {final _that = this;
switch (_that) {
case _DiscoverUserModel():
return $default(_that.userId,_that.displayName,_that.avatarUrl,_that.affinityScore,_that.commonGenres,_that.commonMedia,_that.isFollowedByMe);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String displayName,  String? avatarUrl,  double affinityScore,  List<String> commonGenres,  List<SocialMediaModel> commonMedia,  bool isFollowedByMe)?  $default,) {final _that = this;
switch (_that) {
case _DiscoverUserModel() when $default != null:
return $default(_that.userId,_that.displayName,_that.avatarUrl,_that.affinityScore,_that.commonGenres,_that.commonMedia,_that.isFollowedByMe);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DiscoverUserModel implements DiscoverUserModel {
  const _DiscoverUserModel({required this.userId, required this.displayName, this.avatarUrl, required this.affinityScore, final  List<String> commonGenres = const <String>[], final  List<SocialMediaModel> commonMedia = const <SocialMediaModel>[], this.isFollowedByMe = false}): _commonGenres = commonGenres,_commonMedia = commonMedia;
  factory _DiscoverUserModel.fromJson(Map<String, dynamic> json) => _$DiscoverUserModelFromJson(json);

@override final  String userId;
@override final  String displayName;
@override final  String? avatarUrl;
@override final  double affinityScore;
 final  List<String> _commonGenres;
@override@JsonKey() List<String> get commonGenres {
  if (_commonGenres is EqualUnmodifiableListView) return _commonGenres;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_commonGenres);
}

 final  List<SocialMediaModel> _commonMedia;
@override@JsonKey() List<SocialMediaModel> get commonMedia {
  if (_commonMedia is EqualUnmodifiableListView) return _commonMedia;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_commonMedia);
}

@override@JsonKey() final  bool isFollowedByMe;

/// Create a copy of DiscoverUserModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DiscoverUserModelCopyWith<_DiscoverUserModel> get copyWith => __$DiscoverUserModelCopyWithImpl<_DiscoverUserModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DiscoverUserModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DiscoverUserModel&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.affinityScore, affinityScore) || other.affinityScore == affinityScore)&&const DeepCollectionEquality().equals(other._commonGenres, _commonGenres)&&const DeepCollectionEquality().equals(other._commonMedia, _commonMedia)&&(identical(other.isFollowedByMe, isFollowedByMe) || other.isFollowedByMe == isFollowedByMe));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,displayName,avatarUrl,affinityScore,const DeepCollectionEquality().hash(_commonGenres),const DeepCollectionEquality().hash(_commonMedia),isFollowedByMe);

@override
String toString() {
  return 'DiscoverUserModel(userId: $userId, displayName: $displayName, avatarUrl: $avatarUrl, affinityScore: $affinityScore, commonGenres: $commonGenres, commonMedia: $commonMedia, isFollowedByMe: $isFollowedByMe)';
}


}

/// @nodoc
abstract mixin class _$DiscoverUserModelCopyWith<$Res> implements $DiscoverUserModelCopyWith<$Res> {
  factory _$DiscoverUserModelCopyWith(_DiscoverUserModel value, $Res Function(_DiscoverUserModel) _then) = __$DiscoverUserModelCopyWithImpl;
@override @useResult
$Res call({
 String userId, String displayName, String? avatarUrl, double affinityScore, List<String> commonGenres, List<SocialMediaModel> commonMedia, bool isFollowedByMe
});




}
/// @nodoc
class __$DiscoverUserModelCopyWithImpl<$Res>
    implements _$DiscoverUserModelCopyWith<$Res> {
  __$DiscoverUserModelCopyWithImpl(this._self, this._then);

  final _DiscoverUserModel _self;
  final $Res Function(_DiscoverUserModel) _then;

/// Create a copy of DiscoverUserModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? displayName = null,Object? avatarUrl = freezed,Object? affinityScore = null,Object? commonGenres = null,Object? commonMedia = null,Object? isFollowedByMe = null,}) {
  return _then(_DiscoverUserModel(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,affinityScore: null == affinityScore ? _self.affinityScore : affinityScore // ignore: cast_nullable_to_non_nullable
as double,commonGenres: null == commonGenres ? _self._commonGenres : commonGenres // ignore: cast_nullable_to_non_nullable
as List<String>,commonMedia: null == commonMedia ? _self._commonMedia : commonMedia // ignore: cast_nullable_to_non_nullable
as List<SocialMediaModel>,isFollowedByMe: null == isFollowedByMe ? _self.isFollowedByMe : isFollowedByMe // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
