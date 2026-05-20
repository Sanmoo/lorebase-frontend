// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'social_media_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SocialMediaModel {

 String get mediaId; String get mediaType; String get title; String? get posterUrl;
/// Create a copy of SocialMediaModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SocialMediaModelCopyWith<SocialMediaModel> get copyWith => _$SocialMediaModelCopyWithImpl<SocialMediaModel>(this as SocialMediaModel, _$identity);

  /// Serializes this SocialMediaModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SocialMediaModel&&(identical(other.mediaId, mediaId) || other.mediaId == mediaId)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.title, title) || other.title == title)&&(identical(other.posterUrl, posterUrl) || other.posterUrl == posterUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mediaId,mediaType,title,posterUrl);

@override
String toString() {
  return 'SocialMediaModel(mediaId: $mediaId, mediaType: $mediaType, title: $title, posterUrl: $posterUrl)';
}


}

/// @nodoc
abstract mixin class $SocialMediaModelCopyWith<$Res>  {
  factory $SocialMediaModelCopyWith(SocialMediaModel value, $Res Function(SocialMediaModel) _then) = _$SocialMediaModelCopyWithImpl;
@useResult
$Res call({
 String mediaId, String mediaType, String title, String? posterUrl
});




}
/// @nodoc
class _$SocialMediaModelCopyWithImpl<$Res>
    implements $SocialMediaModelCopyWith<$Res> {
  _$SocialMediaModelCopyWithImpl(this._self, this._then);

  final SocialMediaModel _self;
  final $Res Function(SocialMediaModel) _then;

/// Create a copy of SocialMediaModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mediaId = null,Object? mediaType = null,Object? title = null,Object? posterUrl = freezed,}) {
  return _then(_self.copyWith(
mediaId: null == mediaId ? _self.mediaId : mediaId // ignore: cast_nullable_to_non_nullable
as String,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,posterUrl: freezed == posterUrl ? _self.posterUrl : posterUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SocialMediaModel].
extension SocialMediaModelPatterns on SocialMediaModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SocialMediaModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SocialMediaModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SocialMediaModel value)  $default,){
final _that = this;
switch (_that) {
case _SocialMediaModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SocialMediaModel value)?  $default,){
final _that = this;
switch (_that) {
case _SocialMediaModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String mediaId,  String mediaType,  String title,  String? posterUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SocialMediaModel() when $default != null:
return $default(_that.mediaId,_that.mediaType,_that.title,_that.posterUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String mediaId,  String mediaType,  String title,  String? posterUrl)  $default,) {final _that = this;
switch (_that) {
case _SocialMediaModel():
return $default(_that.mediaId,_that.mediaType,_that.title,_that.posterUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String mediaId,  String mediaType,  String title,  String? posterUrl)?  $default,) {final _that = this;
switch (_that) {
case _SocialMediaModel() when $default != null:
return $default(_that.mediaId,_that.mediaType,_that.title,_that.posterUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SocialMediaModel implements SocialMediaModel {
  const _SocialMediaModel({required this.mediaId, required this.mediaType, required this.title, this.posterUrl});
  factory _SocialMediaModel.fromJson(Map<String, dynamic> json) => _$SocialMediaModelFromJson(json);

@override final  String mediaId;
@override final  String mediaType;
@override final  String title;
@override final  String? posterUrl;

/// Create a copy of SocialMediaModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SocialMediaModelCopyWith<_SocialMediaModel> get copyWith => __$SocialMediaModelCopyWithImpl<_SocialMediaModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SocialMediaModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SocialMediaModel&&(identical(other.mediaId, mediaId) || other.mediaId == mediaId)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.title, title) || other.title == title)&&(identical(other.posterUrl, posterUrl) || other.posterUrl == posterUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mediaId,mediaType,title,posterUrl);

@override
String toString() {
  return 'SocialMediaModel(mediaId: $mediaId, mediaType: $mediaType, title: $title, posterUrl: $posterUrl)';
}


}

/// @nodoc
abstract mixin class _$SocialMediaModelCopyWith<$Res> implements $SocialMediaModelCopyWith<$Res> {
  factory _$SocialMediaModelCopyWith(_SocialMediaModel value, $Res Function(_SocialMediaModel) _then) = __$SocialMediaModelCopyWithImpl;
@override @useResult
$Res call({
 String mediaId, String mediaType, String title, String? posterUrl
});




}
/// @nodoc
class __$SocialMediaModelCopyWithImpl<$Res>
    implements _$SocialMediaModelCopyWith<$Res> {
  __$SocialMediaModelCopyWithImpl(this._self, this._then);

  final _SocialMediaModel _self;
  final $Res Function(_SocialMediaModel) _then;

/// Create a copy of SocialMediaModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mediaId = null,Object? mediaType = null,Object? title = null,Object? posterUrl = freezed,}) {
  return _then(_SocialMediaModel(
mediaId: null == mediaId ? _self.mediaId : mediaId // ignore: cast_nullable_to_non_nullable
as String,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,posterUrl: freezed == posterUrl ? _self.posterUrl : posterUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
