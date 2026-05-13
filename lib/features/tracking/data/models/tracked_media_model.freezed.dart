// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tracked_media_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TrackedMediaModel _$TrackedMediaModelFromJson(Map<String, dynamic> json) {
  return _TrackedMediaModel.fromJson(json);
}

/// @nodoc
mixin _$TrackedMediaModel {
  String get trackingId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(fromJson: mediaTypeFromJson, toJson: mediaTypeToJson)
  MediaType get mediaType => throw _privateConstructorUsedError;
  String get mediaId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  int? get rating => throw _privateConstructorUsedError;
  String? get review => throw _privateConstructorUsedError;
  List<SeasonRatingModel> get seasonRatings =>
      throw _privateConstructorUsedError;
  TrackedMediaSummaryModel? get media => throw _privateConstructorUsedError;
  DateTime get addedAt => throw _privateConstructorUsedError;
  DateTime get lastUpdated => throw _privateConstructorUsedError;

  /// Serializes this TrackedMediaModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TrackedMediaModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrackedMediaModelCopyWith<TrackedMediaModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrackedMediaModelCopyWith<$Res> {
  factory $TrackedMediaModelCopyWith(
          TrackedMediaModel value, $Res Function(TrackedMediaModel) then) =
      _$TrackedMediaModelCopyWithImpl<$Res, TrackedMediaModel>;
  @useResult
  $Res call(
      {String trackingId,
      String userId,
      @JsonKey(fromJson: mediaTypeFromJson, toJson: mediaTypeToJson)
      MediaType mediaType,
      String mediaId,
      String status,
      int? rating,
      String? review,
      List<SeasonRatingModel> seasonRatings,
      TrackedMediaSummaryModel? media,
      DateTime addedAt,
      DateTime lastUpdated});

  $TrackedMediaSummaryModelCopyWith<$Res>? get media;
}

/// @nodoc
class _$TrackedMediaModelCopyWithImpl<$Res, $Val extends TrackedMediaModel>
    implements $TrackedMediaModelCopyWith<$Res> {
  _$TrackedMediaModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrackedMediaModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? trackingId = null,
    Object? userId = null,
    Object? mediaType = null,
    Object? mediaId = null,
    Object? status = null,
    Object? rating = freezed,
    Object? review = freezed,
    Object? seasonRatings = null,
    Object? media = freezed,
    Object? addedAt = null,
    Object? lastUpdated = null,
  }) {
    return _then(_value.copyWith(
      trackingId: null == trackingId
          ? _value.trackingId
          : trackingId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      mediaType: null == mediaType
          ? _value.mediaType
          : mediaType // ignore: cast_nullable_to_non_nullable
              as MediaType,
      mediaId: null == mediaId
          ? _value.mediaId
          : mediaId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as int?,
      review: freezed == review
          ? _value.review
          : review // ignore: cast_nullable_to_non_nullable
              as String?,
      seasonRatings: null == seasonRatings
          ? _value.seasonRatings
          : seasonRatings // ignore: cast_nullable_to_non_nullable
              as List<SeasonRatingModel>,
      media: freezed == media
          ? _value.media
          : media // ignore: cast_nullable_to_non_nullable
              as TrackedMediaSummaryModel?,
      addedAt: null == addedAt
          ? _value.addedAt
          : addedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }

  /// Create a copy of TrackedMediaModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TrackedMediaSummaryModelCopyWith<$Res>? get media {
    if (_value.media == null) {
      return null;
    }

    return $TrackedMediaSummaryModelCopyWith<$Res>(_value.media!, (value) {
      return _then(_value.copyWith(media: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TrackedMediaModelImplCopyWith<$Res>
    implements $TrackedMediaModelCopyWith<$Res> {
  factory _$$TrackedMediaModelImplCopyWith(_$TrackedMediaModelImpl value,
          $Res Function(_$TrackedMediaModelImpl) then) =
      __$$TrackedMediaModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String trackingId,
      String userId,
      @JsonKey(fromJson: mediaTypeFromJson, toJson: mediaTypeToJson)
      MediaType mediaType,
      String mediaId,
      String status,
      int? rating,
      String? review,
      List<SeasonRatingModel> seasonRatings,
      TrackedMediaSummaryModel? media,
      DateTime addedAt,
      DateTime lastUpdated});

  @override
  $TrackedMediaSummaryModelCopyWith<$Res>? get media;
}

/// @nodoc
class __$$TrackedMediaModelImplCopyWithImpl<$Res>
    extends _$TrackedMediaModelCopyWithImpl<$Res, _$TrackedMediaModelImpl>
    implements _$$TrackedMediaModelImplCopyWith<$Res> {
  __$$TrackedMediaModelImplCopyWithImpl(_$TrackedMediaModelImpl _value,
      $Res Function(_$TrackedMediaModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of TrackedMediaModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? trackingId = null,
    Object? userId = null,
    Object? mediaType = null,
    Object? mediaId = null,
    Object? status = null,
    Object? rating = freezed,
    Object? review = freezed,
    Object? seasonRatings = null,
    Object? media = freezed,
    Object? addedAt = null,
    Object? lastUpdated = null,
  }) {
    return _then(_$TrackedMediaModelImpl(
      trackingId: null == trackingId
          ? _value.trackingId
          : trackingId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      mediaType: null == mediaType
          ? _value.mediaType
          : mediaType // ignore: cast_nullable_to_non_nullable
              as MediaType,
      mediaId: null == mediaId
          ? _value.mediaId
          : mediaId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as int?,
      review: freezed == review
          ? _value.review
          : review // ignore: cast_nullable_to_non_nullable
              as String?,
      seasonRatings: null == seasonRatings
          ? _value._seasonRatings
          : seasonRatings // ignore: cast_nullable_to_non_nullable
              as List<SeasonRatingModel>,
      media: freezed == media
          ? _value.media
          : media // ignore: cast_nullable_to_non_nullable
              as TrackedMediaSummaryModel?,
      addedAt: null == addedAt
          ? _value.addedAt
          : addedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TrackedMediaModelImpl implements _TrackedMediaModel {
  const _$TrackedMediaModelImpl(
      {required this.trackingId,
      required this.userId,
      @JsonKey(fromJson: mediaTypeFromJson, toJson: mediaTypeToJson)
      required this.mediaType,
      required this.mediaId,
      required this.status,
      this.rating,
      this.review,
      final List<SeasonRatingModel> seasonRatings = const [],
      this.media,
      required this.addedAt,
      required this.lastUpdated})
      : _seasonRatings = seasonRatings;

  factory _$TrackedMediaModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrackedMediaModelImplFromJson(json);

  @override
  final String trackingId;
  @override
  final String userId;
  @override
  @JsonKey(fromJson: mediaTypeFromJson, toJson: mediaTypeToJson)
  final MediaType mediaType;
  @override
  final String mediaId;
  @override
  final String status;
  @override
  final int? rating;
  @override
  final String? review;
  final List<SeasonRatingModel> _seasonRatings;
  @override
  @JsonKey()
  List<SeasonRatingModel> get seasonRatings {
    if (_seasonRatings is EqualUnmodifiableListView) return _seasonRatings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_seasonRatings);
  }

  @override
  final TrackedMediaSummaryModel? media;
  @override
  final DateTime addedAt;
  @override
  final DateTime lastUpdated;

  @override
  String toString() {
    return 'TrackedMediaModel(trackingId: $trackingId, userId: $userId, mediaType: $mediaType, mediaId: $mediaId, status: $status, rating: $rating, review: $review, seasonRatings: $seasonRatings, media: $media, addedAt: $addedAt, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrackedMediaModelImpl &&
            (identical(other.trackingId, trackingId) ||
                other.trackingId == trackingId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.mediaType, mediaType) ||
                other.mediaType == mediaType) &&
            (identical(other.mediaId, mediaId) || other.mediaId == mediaId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.review, review) || other.review == review) &&
            const DeepCollectionEquality()
                .equals(other._seasonRatings, _seasonRatings) &&
            (identical(other.media, media) || other.media == media) &&
            (identical(other.addedAt, addedAt) || other.addedAt == addedAt) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      trackingId,
      userId,
      mediaType,
      mediaId,
      status,
      rating,
      review,
      const DeepCollectionEquality().hash(_seasonRatings),
      media,
      addedAt,
      lastUpdated);

  /// Create a copy of TrackedMediaModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrackedMediaModelImplCopyWith<_$TrackedMediaModelImpl> get copyWith =>
      __$$TrackedMediaModelImplCopyWithImpl<_$TrackedMediaModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrackedMediaModelImplToJson(
      this,
    );
  }
}

abstract class _TrackedMediaModel implements TrackedMediaModel {
  const factory _TrackedMediaModel(
      {required final String trackingId,
      required final String userId,
      @JsonKey(fromJson: mediaTypeFromJson, toJson: mediaTypeToJson)
      required final MediaType mediaType,
      required final String mediaId,
      required final String status,
      final int? rating,
      final String? review,
      final List<SeasonRatingModel> seasonRatings,
      final TrackedMediaSummaryModel? media,
      required final DateTime addedAt,
      required final DateTime lastUpdated}) = _$TrackedMediaModelImpl;

  factory _TrackedMediaModel.fromJson(Map<String, dynamic> json) =
      _$TrackedMediaModelImpl.fromJson;

  @override
  String get trackingId;
  @override
  String get userId;
  @override
  @JsonKey(fromJson: mediaTypeFromJson, toJson: mediaTypeToJson)
  MediaType get mediaType;
  @override
  String get mediaId;
  @override
  String get status;
  @override
  int? get rating;
  @override
  String? get review;
  @override
  List<SeasonRatingModel> get seasonRatings;
  @override
  TrackedMediaSummaryModel? get media;
  @override
  DateTime get addedAt;
  @override
  DateTime get lastUpdated;

  /// Create a copy of TrackedMediaModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrackedMediaModelImplCopyWith<_$TrackedMediaModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
