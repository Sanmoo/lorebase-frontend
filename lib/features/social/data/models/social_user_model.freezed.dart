// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'social_user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SocialUserModel {

 String get userId; String get displayName; String? get avatarUrl;
/// Create a copy of SocialUserModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SocialUserModelCopyWith<SocialUserModel> get copyWith => _$SocialUserModelCopyWithImpl<SocialUserModel>(this as SocialUserModel, _$identity);

  /// Serializes this SocialUserModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SocialUserModel&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,displayName,avatarUrl);

@override
String toString() {
  return 'SocialUserModel(userId: $userId, displayName: $displayName, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class $SocialUserModelCopyWith<$Res>  {
  factory $SocialUserModelCopyWith(SocialUserModel value, $Res Function(SocialUserModel) _then) = _$SocialUserModelCopyWithImpl;
@useResult
$Res call({
 String userId, String displayName, String? avatarUrl
});




}
/// @nodoc
class _$SocialUserModelCopyWithImpl<$Res>
    implements $SocialUserModelCopyWith<$Res> {
  _$SocialUserModelCopyWithImpl(this._self, this._then);

  final SocialUserModel _self;
  final $Res Function(SocialUserModel) _then;

/// Create a copy of SocialUserModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? displayName = null,Object? avatarUrl = freezed,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SocialUserModel].
extension SocialUserModelPatterns on SocialUserModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SocialUserModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SocialUserModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SocialUserModel value)  $default,){
final _that = this;
switch (_that) {
case _SocialUserModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SocialUserModel value)?  $default,){
final _that = this;
switch (_that) {
case _SocialUserModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String displayName,  String? avatarUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SocialUserModel() when $default != null:
return $default(_that.userId,_that.displayName,_that.avatarUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String displayName,  String? avatarUrl)  $default,) {final _that = this;
switch (_that) {
case _SocialUserModel():
return $default(_that.userId,_that.displayName,_that.avatarUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String displayName,  String? avatarUrl)?  $default,) {final _that = this;
switch (_that) {
case _SocialUserModel() when $default != null:
return $default(_that.userId,_that.displayName,_that.avatarUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SocialUserModel implements SocialUserModel {
  const _SocialUserModel({required this.userId, required this.displayName, this.avatarUrl});
  factory _SocialUserModel.fromJson(Map<String, dynamic> json) => _$SocialUserModelFromJson(json);

@override final  String userId;
@override final  String displayName;
@override final  String? avatarUrl;

/// Create a copy of SocialUserModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SocialUserModelCopyWith<_SocialUserModel> get copyWith => __$SocialUserModelCopyWithImpl<_SocialUserModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SocialUserModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SocialUserModel&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,displayName,avatarUrl);

@override
String toString() {
  return 'SocialUserModel(userId: $userId, displayName: $displayName, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class _$SocialUserModelCopyWith<$Res> implements $SocialUserModelCopyWith<$Res> {
  factory _$SocialUserModelCopyWith(_SocialUserModel value, $Res Function(_SocialUserModel) _then) = __$SocialUserModelCopyWithImpl;
@override @useResult
$Res call({
 String userId, String displayName, String? avatarUrl
});




}
/// @nodoc
class __$SocialUserModelCopyWithImpl<$Res>
    implements _$SocialUserModelCopyWith<$Res> {
  __$SocialUserModelCopyWithImpl(this._self, this._then);

  final _SocialUserModel _self;
  final $Res Function(_SocialUserModel) _then;

/// Create a copy of SocialUserModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? displayName = null,Object? avatarUrl = freezed,}) {
  return _then(_SocialUserModel(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
