// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'social_profile_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SocialProfileModel {

 String get userId; String get displayName; String? get avatarUrl; bool get isPublic; int get followingCount; int get followerCount; bool get isFollowedByMe; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of SocialProfileModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SocialProfileModelCopyWith<SocialProfileModel> get copyWith => _$SocialProfileModelCopyWithImpl<SocialProfileModel>(this as SocialProfileModel, _$identity);

  /// Serializes this SocialProfileModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SocialProfileModel&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.followingCount, followingCount) || other.followingCount == followingCount)&&(identical(other.followerCount, followerCount) || other.followerCount == followerCount)&&(identical(other.isFollowedByMe, isFollowedByMe) || other.isFollowedByMe == isFollowedByMe)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,displayName,avatarUrl,isPublic,followingCount,followerCount,isFollowedByMe,createdAt,updatedAt);

@override
String toString() {
  return 'SocialProfileModel(userId: $userId, displayName: $displayName, avatarUrl: $avatarUrl, isPublic: $isPublic, followingCount: $followingCount, followerCount: $followerCount, isFollowedByMe: $isFollowedByMe, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $SocialProfileModelCopyWith<$Res>  {
  factory $SocialProfileModelCopyWith(SocialProfileModel value, $Res Function(SocialProfileModel) _then) = _$SocialProfileModelCopyWithImpl;
@useResult
$Res call({
 String userId, String displayName, String? avatarUrl, bool isPublic, int followingCount, int followerCount, bool isFollowedByMe, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$SocialProfileModelCopyWithImpl<$Res>
    implements $SocialProfileModelCopyWith<$Res> {
  _$SocialProfileModelCopyWithImpl(this._self, this._then);

  final SocialProfileModel _self;
  final $Res Function(SocialProfileModel) _then;

/// Create a copy of SocialProfileModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? displayName = null,Object? avatarUrl = freezed,Object? isPublic = null,Object? followingCount = null,Object? followerCount = null,Object? isFollowedByMe = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,followingCount: null == followingCount ? _self.followingCount : followingCount // ignore: cast_nullable_to_non_nullable
as int,followerCount: null == followerCount ? _self.followerCount : followerCount // ignore: cast_nullable_to_non_nullable
as int,isFollowedByMe: null == isFollowedByMe ? _self.isFollowedByMe : isFollowedByMe // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [SocialProfileModel].
extension SocialProfileModelPatterns on SocialProfileModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SocialProfileModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SocialProfileModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SocialProfileModel value)  $default,){
final _that = this;
switch (_that) {
case _SocialProfileModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SocialProfileModel value)?  $default,){
final _that = this;
switch (_that) {
case _SocialProfileModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String displayName,  String? avatarUrl,  bool isPublic,  int followingCount,  int followerCount,  bool isFollowedByMe,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SocialProfileModel() when $default != null:
return $default(_that.userId,_that.displayName,_that.avatarUrl,_that.isPublic,_that.followingCount,_that.followerCount,_that.isFollowedByMe,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String displayName,  String? avatarUrl,  bool isPublic,  int followingCount,  int followerCount,  bool isFollowedByMe,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _SocialProfileModel():
return $default(_that.userId,_that.displayName,_that.avatarUrl,_that.isPublic,_that.followingCount,_that.followerCount,_that.isFollowedByMe,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String displayName,  String? avatarUrl,  bool isPublic,  int followingCount,  int followerCount,  bool isFollowedByMe,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _SocialProfileModel() when $default != null:
return $default(_that.userId,_that.displayName,_that.avatarUrl,_that.isPublic,_that.followingCount,_that.followerCount,_that.isFollowedByMe,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SocialProfileModel implements SocialProfileModel {
  const _SocialProfileModel({required this.userId, required this.displayName, this.avatarUrl, required this.isPublic, required this.followingCount, required this.followerCount, this.isFollowedByMe = false, required this.createdAt, required this.updatedAt});
  factory _SocialProfileModel.fromJson(Map<String, dynamic> json) => _$SocialProfileModelFromJson(json);

@override final  String userId;
@override final  String displayName;
@override final  String? avatarUrl;
@override final  bool isPublic;
@override final  int followingCount;
@override final  int followerCount;
@override@JsonKey() final  bool isFollowedByMe;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of SocialProfileModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SocialProfileModelCopyWith<_SocialProfileModel> get copyWith => __$SocialProfileModelCopyWithImpl<_SocialProfileModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SocialProfileModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SocialProfileModel&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.followingCount, followingCount) || other.followingCount == followingCount)&&(identical(other.followerCount, followerCount) || other.followerCount == followerCount)&&(identical(other.isFollowedByMe, isFollowedByMe) || other.isFollowedByMe == isFollowedByMe)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,displayName,avatarUrl,isPublic,followingCount,followerCount,isFollowedByMe,createdAt,updatedAt);

@override
String toString() {
  return 'SocialProfileModel(userId: $userId, displayName: $displayName, avatarUrl: $avatarUrl, isPublic: $isPublic, followingCount: $followingCount, followerCount: $followerCount, isFollowedByMe: $isFollowedByMe, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$SocialProfileModelCopyWith<$Res> implements $SocialProfileModelCopyWith<$Res> {
  factory _$SocialProfileModelCopyWith(_SocialProfileModel value, $Res Function(_SocialProfileModel) _then) = __$SocialProfileModelCopyWithImpl;
@override @useResult
$Res call({
 String userId, String displayName, String? avatarUrl, bool isPublic, int followingCount, int followerCount, bool isFollowedByMe, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$SocialProfileModelCopyWithImpl<$Res>
    implements _$SocialProfileModelCopyWith<$Res> {
  __$SocialProfileModelCopyWithImpl(this._self, this._then);

  final _SocialProfileModel _self;
  final $Res Function(_SocialProfileModel) _then;

/// Create a copy of SocialProfileModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? displayName = null,Object? avatarUrl = freezed,Object? isPublic = null,Object? followingCount = null,Object? followerCount = null,Object? isFollowedByMe = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_SocialProfileModel(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,followingCount: null == followingCount ? _self.followingCount : followingCount // ignore: cast_nullable_to_non_nullable
as int,followerCount: null == followerCount ? _self.followerCount : followerCount // ignore: cast_nullable_to_non_nullable
as int,isFollowedByMe: null == isFollowedByMe ? _self.isFollowedByMe : isFollowedByMe // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
