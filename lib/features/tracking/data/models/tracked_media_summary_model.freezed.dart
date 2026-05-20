// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tracked_media_summary_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TrackedMediaSummaryModel {

@JsonKey(name: 'mediaId', fromJson: flexibleStringFromJson, toJson: flexibleStringToJson) String get mediaId; String get title;@JsonKey(fromJson: _nullableMediaTypeFromJson, toJson: _nullableMediaTypeToJson) MediaType? get mediaType; String? get overview; String? get posterPath; String? get status; int? get trackingRating; int? get seasonCount; DateTime? get addedAt;
/// Create a copy of TrackedMediaSummaryModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrackedMediaSummaryModelCopyWith<TrackedMediaSummaryModel> get copyWith => _$TrackedMediaSummaryModelCopyWithImpl<TrackedMediaSummaryModel>(this as TrackedMediaSummaryModel, _$identity);

  /// Serializes this TrackedMediaSummaryModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrackedMediaSummaryModel&&(identical(other.mediaId, mediaId) || other.mediaId == mediaId)&&(identical(other.title, title) || other.title == title)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.overview, overview) || other.overview == overview)&&(identical(other.posterPath, posterPath) || other.posterPath == posterPath)&&(identical(other.status, status) || other.status == status)&&(identical(other.trackingRating, trackingRating) || other.trackingRating == trackingRating)&&(identical(other.seasonCount, seasonCount) || other.seasonCount == seasonCount)&&(identical(other.addedAt, addedAt) || other.addedAt == addedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mediaId,title,mediaType,overview,posterPath,status,trackingRating,seasonCount,addedAt);

@override
String toString() {
  return 'TrackedMediaSummaryModel(mediaId: $mediaId, title: $title, mediaType: $mediaType, overview: $overview, posterPath: $posterPath, status: $status, trackingRating: $trackingRating, seasonCount: $seasonCount, addedAt: $addedAt)';
}


}

/// @nodoc
abstract mixin class $TrackedMediaSummaryModelCopyWith<$Res>  {
  factory $TrackedMediaSummaryModelCopyWith(TrackedMediaSummaryModel value, $Res Function(TrackedMediaSummaryModel) _then) = _$TrackedMediaSummaryModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'mediaId', fromJson: flexibleStringFromJson, toJson: flexibleStringToJson) String mediaId, String title,@JsonKey(fromJson: _nullableMediaTypeFromJson, toJson: _nullableMediaTypeToJson) MediaType? mediaType, String? overview, String? posterPath, String? status, int? trackingRating, int? seasonCount, DateTime? addedAt
});




}
/// @nodoc
class _$TrackedMediaSummaryModelCopyWithImpl<$Res>
    implements $TrackedMediaSummaryModelCopyWith<$Res> {
  _$TrackedMediaSummaryModelCopyWithImpl(this._self, this._then);

  final TrackedMediaSummaryModel _self;
  final $Res Function(TrackedMediaSummaryModel) _then;

/// Create a copy of TrackedMediaSummaryModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mediaId = null,Object? title = null,Object? mediaType = freezed,Object? overview = freezed,Object? posterPath = freezed,Object? status = freezed,Object? trackingRating = freezed,Object? seasonCount = freezed,Object? addedAt = freezed,}) {
  return _then(_self.copyWith(
mediaId: null == mediaId ? _self.mediaId : mediaId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,mediaType: freezed == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as MediaType?,overview: freezed == overview ? _self.overview : overview // ignore: cast_nullable_to_non_nullable
as String?,posterPath: freezed == posterPath ? _self.posterPath : posterPath // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,trackingRating: freezed == trackingRating ? _self.trackingRating : trackingRating // ignore: cast_nullable_to_non_nullable
as int?,seasonCount: freezed == seasonCount ? _self.seasonCount : seasonCount // ignore: cast_nullable_to_non_nullable
as int?,addedAt: freezed == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [TrackedMediaSummaryModel].
extension TrackedMediaSummaryModelPatterns on TrackedMediaSummaryModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrackedMediaSummaryModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrackedMediaSummaryModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrackedMediaSummaryModel value)  $default,){
final _that = this;
switch (_that) {
case _TrackedMediaSummaryModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrackedMediaSummaryModel value)?  $default,){
final _that = this;
switch (_that) {
case _TrackedMediaSummaryModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'mediaId', fromJson: flexibleStringFromJson, toJson: flexibleStringToJson)  String mediaId,  String title, @JsonKey(fromJson: _nullableMediaTypeFromJson, toJson: _nullableMediaTypeToJson)  MediaType? mediaType,  String? overview,  String? posterPath,  String? status,  int? trackingRating,  int? seasonCount,  DateTime? addedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrackedMediaSummaryModel() when $default != null:
return $default(_that.mediaId,_that.title,_that.mediaType,_that.overview,_that.posterPath,_that.status,_that.trackingRating,_that.seasonCount,_that.addedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'mediaId', fromJson: flexibleStringFromJson, toJson: flexibleStringToJson)  String mediaId,  String title, @JsonKey(fromJson: _nullableMediaTypeFromJson, toJson: _nullableMediaTypeToJson)  MediaType? mediaType,  String? overview,  String? posterPath,  String? status,  int? trackingRating,  int? seasonCount,  DateTime? addedAt)  $default,) {final _that = this;
switch (_that) {
case _TrackedMediaSummaryModel():
return $default(_that.mediaId,_that.title,_that.mediaType,_that.overview,_that.posterPath,_that.status,_that.trackingRating,_that.seasonCount,_that.addedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'mediaId', fromJson: flexibleStringFromJson, toJson: flexibleStringToJson)  String mediaId,  String title, @JsonKey(fromJson: _nullableMediaTypeFromJson, toJson: _nullableMediaTypeToJson)  MediaType? mediaType,  String? overview,  String? posterPath,  String? status,  int? trackingRating,  int? seasonCount,  DateTime? addedAt)?  $default,) {final _that = this;
switch (_that) {
case _TrackedMediaSummaryModel() when $default != null:
return $default(_that.mediaId,_that.title,_that.mediaType,_that.overview,_that.posterPath,_that.status,_that.trackingRating,_that.seasonCount,_that.addedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrackedMediaSummaryModel implements TrackedMediaSummaryModel {
  const _TrackedMediaSummaryModel({@JsonKey(name: 'mediaId', fromJson: flexibleStringFromJson, toJson: flexibleStringToJson) this.mediaId = '', required this.title, @JsonKey(fromJson: _nullableMediaTypeFromJson, toJson: _nullableMediaTypeToJson) this.mediaType, this.overview, this.posterPath, this.status, this.trackingRating, this.seasonCount, this.addedAt});
  factory _TrackedMediaSummaryModel.fromJson(Map<String, dynamic> json) => _$TrackedMediaSummaryModelFromJson(json);

@override@JsonKey(name: 'mediaId', fromJson: flexibleStringFromJson, toJson: flexibleStringToJson) final  String mediaId;
@override final  String title;
@override@JsonKey(fromJson: _nullableMediaTypeFromJson, toJson: _nullableMediaTypeToJson) final  MediaType? mediaType;
@override final  String? overview;
@override final  String? posterPath;
@override final  String? status;
@override final  int? trackingRating;
@override final  int? seasonCount;
@override final  DateTime? addedAt;

/// Create a copy of TrackedMediaSummaryModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrackedMediaSummaryModelCopyWith<_TrackedMediaSummaryModel> get copyWith => __$TrackedMediaSummaryModelCopyWithImpl<_TrackedMediaSummaryModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrackedMediaSummaryModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrackedMediaSummaryModel&&(identical(other.mediaId, mediaId) || other.mediaId == mediaId)&&(identical(other.title, title) || other.title == title)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.overview, overview) || other.overview == overview)&&(identical(other.posterPath, posterPath) || other.posterPath == posterPath)&&(identical(other.status, status) || other.status == status)&&(identical(other.trackingRating, trackingRating) || other.trackingRating == trackingRating)&&(identical(other.seasonCount, seasonCount) || other.seasonCount == seasonCount)&&(identical(other.addedAt, addedAt) || other.addedAt == addedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mediaId,title,mediaType,overview,posterPath,status,trackingRating,seasonCount,addedAt);

@override
String toString() {
  return 'TrackedMediaSummaryModel(mediaId: $mediaId, title: $title, mediaType: $mediaType, overview: $overview, posterPath: $posterPath, status: $status, trackingRating: $trackingRating, seasonCount: $seasonCount, addedAt: $addedAt)';
}


}

/// @nodoc
abstract mixin class _$TrackedMediaSummaryModelCopyWith<$Res> implements $TrackedMediaSummaryModelCopyWith<$Res> {
  factory _$TrackedMediaSummaryModelCopyWith(_TrackedMediaSummaryModel value, $Res Function(_TrackedMediaSummaryModel) _then) = __$TrackedMediaSummaryModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'mediaId', fromJson: flexibleStringFromJson, toJson: flexibleStringToJson) String mediaId, String title,@JsonKey(fromJson: _nullableMediaTypeFromJson, toJson: _nullableMediaTypeToJson) MediaType? mediaType, String? overview, String? posterPath, String? status, int? trackingRating, int? seasonCount, DateTime? addedAt
});




}
/// @nodoc
class __$TrackedMediaSummaryModelCopyWithImpl<$Res>
    implements _$TrackedMediaSummaryModelCopyWith<$Res> {
  __$TrackedMediaSummaryModelCopyWithImpl(this._self, this._then);

  final _TrackedMediaSummaryModel _self;
  final $Res Function(_TrackedMediaSummaryModel) _then;

/// Create a copy of TrackedMediaSummaryModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mediaId = null,Object? title = null,Object? mediaType = freezed,Object? overview = freezed,Object? posterPath = freezed,Object? status = freezed,Object? trackingRating = freezed,Object? seasonCount = freezed,Object? addedAt = freezed,}) {
  return _then(_TrackedMediaSummaryModel(
mediaId: null == mediaId ? _self.mediaId : mediaId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,mediaType: freezed == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as MediaType?,overview: freezed == overview ? _self.overview : overview // ignore: cast_nullable_to_non_nullable
as String?,posterPath: freezed == posterPath ? _self.posterPath : posterPath // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,trackingRating: freezed == trackingRating ? _self.trackingRating : trackingRating // ignore: cast_nullable_to_non_nullable
as int?,seasonCount: freezed == seasonCount ? _self.seasonCount : seasonCount // ignore: cast_nullable_to_non_nullable
as int?,addedAt: freezed == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
