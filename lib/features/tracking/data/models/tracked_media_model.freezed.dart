// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tracked_media_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TrackedMediaModel {

 String get trackingId; String get userId;@JsonKey(fromJson: mediaTypeFromJson, toJson: mediaTypeToJson) MediaType get mediaType; String get mediaId; String get status; int? get rating; String? get review; List<SeasonRatingModel> get seasonRatings; TrackedMediaSummaryModel? get media; DateTime get addedAt; DateTime get lastUpdated;
/// Create a copy of TrackedMediaModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrackedMediaModelCopyWith<TrackedMediaModel> get copyWith => _$TrackedMediaModelCopyWithImpl<TrackedMediaModel>(this as TrackedMediaModel, _$identity);

  /// Serializes this TrackedMediaModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrackedMediaModel&&(identical(other.trackingId, trackingId) || other.trackingId == trackingId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.mediaId, mediaId) || other.mediaId == mediaId)&&(identical(other.status, status) || other.status == status)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.review, review) || other.review == review)&&const DeepCollectionEquality().equals(other.seasonRatings, seasonRatings)&&(identical(other.media, media) || other.media == media)&&(identical(other.addedAt, addedAt) || other.addedAt == addedAt)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,trackingId,userId,mediaType,mediaId,status,rating,review,const DeepCollectionEquality().hash(seasonRatings),media,addedAt,lastUpdated);

@override
String toString() {
  return 'TrackedMediaModel(trackingId: $trackingId, userId: $userId, mediaType: $mediaType, mediaId: $mediaId, status: $status, rating: $rating, review: $review, seasonRatings: $seasonRatings, media: $media, addedAt: $addedAt, lastUpdated: $lastUpdated)';
}


}

/// @nodoc
abstract mixin class $TrackedMediaModelCopyWith<$Res>  {
  factory $TrackedMediaModelCopyWith(TrackedMediaModel value, $Res Function(TrackedMediaModel) _then) = _$TrackedMediaModelCopyWithImpl;
@useResult
$Res call({
 String trackingId, String userId,@JsonKey(fromJson: mediaTypeFromJson, toJson: mediaTypeToJson) MediaType mediaType, String mediaId, String status, int? rating, String? review, List<SeasonRatingModel> seasonRatings, TrackedMediaSummaryModel? media, DateTime addedAt, DateTime lastUpdated
});


$TrackedMediaSummaryModelCopyWith<$Res>? get media;

}
/// @nodoc
class _$TrackedMediaModelCopyWithImpl<$Res>
    implements $TrackedMediaModelCopyWith<$Res> {
  _$TrackedMediaModelCopyWithImpl(this._self, this._then);

  final TrackedMediaModel _self;
  final $Res Function(TrackedMediaModel) _then;

/// Create a copy of TrackedMediaModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? trackingId = null,Object? userId = null,Object? mediaType = null,Object? mediaId = null,Object? status = null,Object? rating = freezed,Object? review = freezed,Object? seasonRatings = null,Object? media = freezed,Object? addedAt = null,Object? lastUpdated = null,}) {
  return _then(_self.copyWith(
trackingId: null == trackingId ? _self.trackingId : trackingId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as MediaType,mediaId: null == mediaId ? _self.mediaId : mediaId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int?,review: freezed == review ? _self.review : review // ignore: cast_nullable_to_non_nullable
as String?,seasonRatings: null == seasonRatings ? _self.seasonRatings : seasonRatings // ignore: cast_nullable_to_non_nullable
as List<SeasonRatingModel>,media: freezed == media ? _self.media : media // ignore: cast_nullable_to_non_nullable
as TrackedMediaSummaryModel?,addedAt: null == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastUpdated: null == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of TrackedMediaModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TrackedMediaSummaryModelCopyWith<$Res>? get media {
    if (_self.media == null) {
    return null;
  }

  return $TrackedMediaSummaryModelCopyWith<$Res>(_self.media!, (value) {
    return _then(_self.copyWith(media: value));
  });
}
}


/// Adds pattern-matching-related methods to [TrackedMediaModel].
extension TrackedMediaModelPatterns on TrackedMediaModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrackedMediaModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrackedMediaModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrackedMediaModel value)  $default,){
final _that = this;
switch (_that) {
case _TrackedMediaModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrackedMediaModel value)?  $default,){
final _that = this;
switch (_that) {
case _TrackedMediaModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String trackingId,  String userId, @JsonKey(fromJson: mediaTypeFromJson, toJson: mediaTypeToJson)  MediaType mediaType,  String mediaId,  String status,  int? rating,  String? review,  List<SeasonRatingModel> seasonRatings,  TrackedMediaSummaryModel? media,  DateTime addedAt,  DateTime lastUpdated)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrackedMediaModel() when $default != null:
return $default(_that.trackingId,_that.userId,_that.mediaType,_that.mediaId,_that.status,_that.rating,_that.review,_that.seasonRatings,_that.media,_that.addedAt,_that.lastUpdated);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String trackingId,  String userId, @JsonKey(fromJson: mediaTypeFromJson, toJson: mediaTypeToJson)  MediaType mediaType,  String mediaId,  String status,  int? rating,  String? review,  List<SeasonRatingModel> seasonRatings,  TrackedMediaSummaryModel? media,  DateTime addedAt,  DateTime lastUpdated)  $default,) {final _that = this;
switch (_that) {
case _TrackedMediaModel():
return $default(_that.trackingId,_that.userId,_that.mediaType,_that.mediaId,_that.status,_that.rating,_that.review,_that.seasonRatings,_that.media,_that.addedAt,_that.lastUpdated);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String trackingId,  String userId, @JsonKey(fromJson: mediaTypeFromJson, toJson: mediaTypeToJson)  MediaType mediaType,  String mediaId,  String status,  int? rating,  String? review,  List<SeasonRatingModel> seasonRatings,  TrackedMediaSummaryModel? media,  DateTime addedAt,  DateTime lastUpdated)?  $default,) {final _that = this;
switch (_that) {
case _TrackedMediaModel() when $default != null:
return $default(_that.trackingId,_that.userId,_that.mediaType,_that.mediaId,_that.status,_that.rating,_that.review,_that.seasonRatings,_that.media,_that.addedAt,_that.lastUpdated);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrackedMediaModel implements TrackedMediaModel {
  const _TrackedMediaModel({required this.trackingId, required this.userId, @JsonKey(fromJson: mediaTypeFromJson, toJson: mediaTypeToJson) required this.mediaType, required this.mediaId, required this.status, this.rating, this.review, final  List<SeasonRatingModel> seasonRatings = const [], this.media, required this.addedAt, required this.lastUpdated}): _seasonRatings = seasonRatings;
  factory _TrackedMediaModel.fromJson(Map<String, dynamic> json) => _$TrackedMediaModelFromJson(json);

@override final  String trackingId;
@override final  String userId;
@override@JsonKey(fromJson: mediaTypeFromJson, toJson: mediaTypeToJson) final  MediaType mediaType;
@override final  String mediaId;
@override final  String status;
@override final  int? rating;
@override final  String? review;
 final  List<SeasonRatingModel> _seasonRatings;
@override@JsonKey() List<SeasonRatingModel> get seasonRatings {
  if (_seasonRatings is EqualUnmodifiableListView) return _seasonRatings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_seasonRatings);
}

@override final  TrackedMediaSummaryModel? media;
@override final  DateTime addedAt;
@override final  DateTime lastUpdated;

/// Create a copy of TrackedMediaModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrackedMediaModelCopyWith<_TrackedMediaModel> get copyWith => __$TrackedMediaModelCopyWithImpl<_TrackedMediaModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrackedMediaModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrackedMediaModel&&(identical(other.trackingId, trackingId) || other.trackingId == trackingId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.mediaId, mediaId) || other.mediaId == mediaId)&&(identical(other.status, status) || other.status == status)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.review, review) || other.review == review)&&const DeepCollectionEquality().equals(other._seasonRatings, _seasonRatings)&&(identical(other.media, media) || other.media == media)&&(identical(other.addedAt, addedAt) || other.addedAt == addedAt)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,trackingId,userId,mediaType,mediaId,status,rating,review,const DeepCollectionEquality().hash(_seasonRatings),media,addedAt,lastUpdated);

@override
String toString() {
  return 'TrackedMediaModel(trackingId: $trackingId, userId: $userId, mediaType: $mediaType, mediaId: $mediaId, status: $status, rating: $rating, review: $review, seasonRatings: $seasonRatings, media: $media, addedAt: $addedAt, lastUpdated: $lastUpdated)';
}


}

/// @nodoc
abstract mixin class _$TrackedMediaModelCopyWith<$Res> implements $TrackedMediaModelCopyWith<$Res> {
  factory _$TrackedMediaModelCopyWith(_TrackedMediaModel value, $Res Function(_TrackedMediaModel) _then) = __$TrackedMediaModelCopyWithImpl;
@override @useResult
$Res call({
 String trackingId, String userId,@JsonKey(fromJson: mediaTypeFromJson, toJson: mediaTypeToJson) MediaType mediaType, String mediaId, String status, int? rating, String? review, List<SeasonRatingModel> seasonRatings, TrackedMediaSummaryModel? media, DateTime addedAt, DateTime lastUpdated
});


@override $TrackedMediaSummaryModelCopyWith<$Res>? get media;

}
/// @nodoc
class __$TrackedMediaModelCopyWithImpl<$Res>
    implements _$TrackedMediaModelCopyWith<$Res> {
  __$TrackedMediaModelCopyWithImpl(this._self, this._then);

  final _TrackedMediaModel _self;
  final $Res Function(_TrackedMediaModel) _then;

/// Create a copy of TrackedMediaModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? trackingId = null,Object? userId = null,Object? mediaType = null,Object? mediaId = null,Object? status = null,Object? rating = freezed,Object? review = freezed,Object? seasonRatings = null,Object? media = freezed,Object? addedAt = null,Object? lastUpdated = null,}) {
  return _then(_TrackedMediaModel(
trackingId: null == trackingId ? _self.trackingId : trackingId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as MediaType,mediaId: null == mediaId ? _self.mediaId : mediaId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int?,review: freezed == review ? _self.review : review // ignore: cast_nullable_to_non_nullable
as String?,seasonRatings: null == seasonRatings ? _self._seasonRatings : seasonRatings // ignore: cast_nullable_to_non_nullable
as List<SeasonRatingModel>,media: freezed == media ? _self.media : media // ignore: cast_nullable_to_non_nullable
as TrackedMediaSummaryModel?,addedAt: null == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastUpdated: null == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of TrackedMediaModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TrackedMediaSummaryModelCopyWith<$Res>? get media {
    if (_self.media == null) {
    return null;
  }

  return $TrackedMediaSummaryModelCopyWith<$Res>(_self.media!, (value) {
    return _then(_self.copyWith(media: value));
  });
}
}

// dart format on
