// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'public_list_item_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PublicListItemModel {

 String get mediaId; String get mediaType; String get status; int? get rating; String? get review; SocialMediaModel? get media; DateTime? get updatedAt;
/// Create a copy of PublicListItemModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PublicListItemModelCopyWith<PublicListItemModel> get copyWith => _$PublicListItemModelCopyWithImpl<PublicListItemModel>(this as PublicListItemModel, _$identity);

  /// Serializes this PublicListItemModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PublicListItemModel&&(identical(other.mediaId, mediaId) || other.mediaId == mediaId)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.status, status) || other.status == status)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.review, review) || other.review == review)&&(identical(other.media, media) || other.media == media)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mediaId,mediaType,status,rating,review,media,updatedAt);

@override
String toString() {
  return 'PublicListItemModel(mediaId: $mediaId, mediaType: $mediaType, status: $status, rating: $rating, review: $review, media: $media, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $PublicListItemModelCopyWith<$Res>  {
  factory $PublicListItemModelCopyWith(PublicListItemModel value, $Res Function(PublicListItemModel) _then) = _$PublicListItemModelCopyWithImpl;
@useResult
$Res call({
 String mediaId, String mediaType, String status, int? rating, String? review, SocialMediaModel? media, DateTime? updatedAt
});


$SocialMediaModelCopyWith<$Res>? get media;

}
/// @nodoc
class _$PublicListItemModelCopyWithImpl<$Res>
    implements $PublicListItemModelCopyWith<$Res> {
  _$PublicListItemModelCopyWithImpl(this._self, this._then);

  final PublicListItemModel _self;
  final $Res Function(PublicListItemModel) _then;

/// Create a copy of PublicListItemModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mediaId = null,Object? mediaType = null,Object? status = null,Object? rating = freezed,Object? review = freezed,Object? media = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
mediaId: null == mediaId ? _self.mediaId : mediaId // ignore: cast_nullable_to_non_nullable
as String,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int?,review: freezed == review ? _self.review : review // ignore: cast_nullable_to_non_nullable
as String?,media: freezed == media ? _self.media : media // ignore: cast_nullable_to_non_nullable
as SocialMediaModel?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of PublicListItemModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SocialMediaModelCopyWith<$Res>? get media {
    if (_self.media == null) {
    return null;
  }

  return $SocialMediaModelCopyWith<$Res>(_self.media!, (value) {
    return _then(_self.copyWith(media: value));
  });
}
}


/// Adds pattern-matching-related methods to [PublicListItemModel].
extension PublicListItemModelPatterns on PublicListItemModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PublicListItemModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PublicListItemModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PublicListItemModel value)  $default,){
final _that = this;
switch (_that) {
case _PublicListItemModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PublicListItemModel value)?  $default,){
final _that = this;
switch (_that) {
case _PublicListItemModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String mediaId,  String mediaType,  String status,  int? rating,  String? review,  SocialMediaModel? media,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PublicListItemModel() when $default != null:
return $default(_that.mediaId,_that.mediaType,_that.status,_that.rating,_that.review,_that.media,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String mediaId,  String mediaType,  String status,  int? rating,  String? review,  SocialMediaModel? media,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _PublicListItemModel():
return $default(_that.mediaId,_that.mediaType,_that.status,_that.rating,_that.review,_that.media,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String mediaId,  String mediaType,  String status,  int? rating,  String? review,  SocialMediaModel? media,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _PublicListItemModel() when $default != null:
return $default(_that.mediaId,_that.mediaType,_that.status,_that.rating,_that.review,_that.media,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PublicListItemModel implements PublicListItemModel {
  const _PublicListItemModel({required this.mediaId, required this.mediaType, required this.status, this.rating, this.review, this.media, this.updatedAt});
  factory _PublicListItemModel.fromJson(Map<String, dynamic> json) => _$PublicListItemModelFromJson(json);

@override final  String mediaId;
@override final  String mediaType;
@override final  String status;
@override final  int? rating;
@override final  String? review;
@override final  SocialMediaModel? media;
@override final  DateTime? updatedAt;

/// Create a copy of PublicListItemModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PublicListItemModelCopyWith<_PublicListItemModel> get copyWith => __$PublicListItemModelCopyWithImpl<_PublicListItemModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PublicListItemModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PublicListItemModel&&(identical(other.mediaId, mediaId) || other.mediaId == mediaId)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.status, status) || other.status == status)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.review, review) || other.review == review)&&(identical(other.media, media) || other.media == media)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mediaId,mediaType,status,rating,review,media,updatedAt);

@override
String toString() {
  return 'PublicListItemModel(mediaId: $mediaId, mediaType: $mediaType, status: $status, rating: $rating, review: $review, media: $media, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PublicListItemModelCopyWith<$Res> implements $PublicListItemModelCopyWith<$Res> {
  factory _$PublicListItemModelCopyWith(_PublicListItemModel value, $Res Function(_PublicListItemModel) _then) = __$PublicListItemModelCopyWithImpl;
@override @useResult
$Res call({
 String mediaId, String mediaType, String status, int? rating, String? review, SocialMediaModel? media, DateTime? updatedAt
});


@override $SocialMediaModelCopyWith<$Res>? get media;

}
/// @nodoc
class __$PublicListItemModelCopyWithImpl<$Res>
    implements _$PublicListItemModelCopyWith<$Res> {
  __$PublicListItemModelCopyWithImpl(this._self, this._then);

  final _PublicListItemModel _self;
  final $Res Function(_PublicListItemModel) _then;

/// Create a copy of PublicListItemModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mediaId = null,Object? mediaType = null,Object? status = null,Object? rating = freezed,Object? review = freezed,Object? media = freezed,Object? updatedAt = freezed,}) {
  return _then(_PublicListItemModel(
mediaId: null == mediaId ? _self.mediaId : mediaId // ignore: cast_nullable_to_non_nullable
as String,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int?,review: freezed == review ? _self.review : review // ignore: cast_nullable_to_non_nullable
as String?,media: freezed == media ? _self.media : media // ignore: cast_nullable_to_non_nullable
as SocialMediaModel?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of PublicListItemModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SocialMediaModelCopyWith<$Res>? get media {
    if (_self.media == null) {
    return null;
  }

  return $SocialMediaModelCopyWith<$Res>(_self.media!, (value) {
    return _then(_self.copyWith(media: value));
  });
}
}

// dart format on
