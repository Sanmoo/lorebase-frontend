// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'follow_relationship_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FollowRelationshipModel {

 String get userId; String? get username; String get displayName; String? get avatarUrl; bool get isFollowing;
/// Create a copy of FollowRelationshipModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FollowRelationshipModelCopyWith<FollowRelationshipModel> get copyWith => _$FollowRelationshipModelCopyWithImpl<FollowRelationshipModel>(this as FollowRelationshipModel, _$identity);

  /// Serializes this FollowRelationshipModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FollowRelationshipModel&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.isFollowing, isFollowing) || other.isFollowing == isFollowing));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,username,displayName,avatarUrl,isFollowing);

@override
String toString() {
  return 'FollowRelationshipModel(userId: $userId, username: $username, displayName: $displayName, avatarUrl: $avatarUrl, isFollowing: $isFollowing)';
}


}

/// @nodoc
abstract mixin class $FollowRelationshipModelCopyWith<$Res>  {
  factory $FollowRelationshipModelCopyWith(FollowRelationshipModel value, $Res Function(FollowRelationshipModel) _then) = _$FollowRelationshipModelCopyWithImpl;
@useResult
$Res call({
 String userId, String? username, String displayName, String? avatarUrl, bool isFollowing
});




}
/// @nodoc
class _$FollowRelationshipModelCopyWithImpl<$Res>
    implements $FollowRelationshipModelCopyWith<$Res> {
  _$FollowRelationshipModelCopyWithImpl(this._self, this._then);

  final FollowRelationshipModel _self;
  final $Res Function(FollowRelationshipModel) _then;

/// Create a copy of FollowRelationshipModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? username = freezed,Object? displayName = null,Object? avatarUrl = freezed,Object? isFollowing = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,isFollowing: null == isFollowing ? _self.isFollowing : isFollowing // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [FollowRelationshipModel].
extension FollowRelationshipModelPatterns on FollowRelationshipModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FollowRelationshipModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FollowRelationshipModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FollowRelationshipModel value)  $default,){
final _that = this;
switch (_that) {
case _FollowRelationshipModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FollowRelationshipModel value)?  $default,){
final _that = this;
switch (_that) {
case _FollowRelationshipModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String? username,  String displayName,  String? avatarUrl,  bool isFollowing)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FollowRelationshipModel() when $default != null:
return $default(_that.userId,_that.username,_that.displayName,_that.avatarUrl,_that.isFollowing);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String? username,  String displayName,  String? avatarUrl,  bool isFollowing)  $default,) {final _that = this;
switch (_that) {
case _FollowRelationshipModel():
return $default(_that.userId,_that.username,_that.displayName,_that.avatarUrl,_that.isFollowing);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String? username,  String displayName,  String? avatarUrl,  bool isFollowing)?  $default,) {final _that = this;
switch (_that) {
case _FollowRelationshipModel() when $default != null:
return $default(_that.userId,_that.username,_that.displayName,_that.avatarUrl,_that.isFollowing);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FollowRelationshipModel implements FollowRelationshipModel {
  const _FollowRelationshipModel({required this.userId, this.username, required this.displayName, this.avatarUrl, required this.isFollowing});
  factory _FollowRelationshipModel.fromJson(Map<String, dynamic> json) => _$FollowRelationshipModelFromJson(json);

@override final  String userId;
@override final  String? username;
@override final  String displayName;
@override final  String? avatarUrl;
@override final  bool isFollowing;

/// Create a copy of FollowRelationshipModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FollowRelationshipModelCopyWith<_FollowRelationshipModel> get copyWith => __$FollowRelationshipModelCopyWithImpl<_FollowRelationshipModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FollowRelationshipModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FollowRelationshipModel&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.isFollowing, isFollowing) || other.isFollowing == isFollowing));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,username,displayName,avatarUrl,isFollowing);

@override
String toString() {
  return 'FollowRelationshipModel(userId: $userId, username: $username, displayName: $displayName, avatarUrl: $avatarUrl, isFollowing: $isFollowing)';
}


}

/// @nodoc
abstract mixin class _$FollowRelationshipModelCopyWith<$Res> implements $FollowRelationshipModelCopyWith<$Res> {
  factory _$FollowRelationshipModelCopyWith(_FollowRelationshipModel value, $Res Function(_FollowRelationshipModel) _then) = __$FollowRelationshipModelCopyWithImpl;
@override @useResult
$Res call({
 String userId, String? username, String displayName, String? avatarUrl, bool isFollowing
});




}
/// @nodoc
class __$FollowRelationshipModelCopyWithImpl<$Res>
    implements _$FollowRelationshipModelCopyWith<$Res> {
  __$FollowRelationshipModelCopyWithImpl(this._self, this._then);

  final _FollowRelationshipModel _self;
  final $Res Function(_FollowRelationshipModel) _then;

/// Create a copy of FollowRelationshipModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? username = freezed,Object? displayName = null,Object? avatarUrl = freezed,Object? isFollowing = null,}) {
  return _then(_FollowRelationshipModel(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,isFollowing: null == isFollowing ? _self.isFollowing : isFollowing // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
