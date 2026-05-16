// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tracked_media_summary_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TrackedMediaSummaryModel _$TrackedMediaSummaryModelFromJson(
    Map<String, dynamic> json) {
  return _TrackedMediaSummaryModel.fromJson(json);
}

/// @nodoc
mixin _$TrackedMediaSummaryModel {
  @JsonKey(
      name: 'tmdbId',
      fromJson: flexibleStringFromJson,
      toJson: flexibleStringToJson)
  String get mediaId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  @JsonKey(
      fromJson: _nullableMediaTypeFromJson, toJson: _nullableMediaTypeToJson)
  MediaType? get mediaType => throw _privateConstructorUsedError;
  String? get overview => throw _privateConstructorUsedError;
  String? get posterPath => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  int? get trackingRating => throw _privateConstructorUsedError;
  int? get seasonCount => throw _privateConstructorUsedError;
  DateTime? get addedAt => throw _privateConstructorUsedError;

  /// Serializes this TrackedMediaSummaryModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TrackedMediaSummaryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrackedMediaSummaryModelCopyWith<TrackedMediaSummaryModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrackedMediaSummaryModelCopyWith<$Res> {
  factory $TrackedMediaSummaryModelCopyWith(TrackedMediaSummaryModel value,
          $Res Function(TrackedMediaSummaryModel) then) =
      _$TrackedMediaSummaryModelCopyWithImpl<$Res, TrackedMediaSummaryModel>;
  @useResult
  $Res call(
      {@JsonKey(
          name: 'tmdbId',
          fromJson: flexibleStringFromJson,
          toJson: flexibleStringToJson)
      String mediaId,
      String title,
      @JsonKey(
          fromJson: _nullableMediaTypeFromJson,
          toJson: _nullableMediaTypeToJson)
      MediaType? mediaType,
      String? overview,
      String? posterPath,
      String? status,
      int? trackingRating,
      int? seasonCount,
      DateTime? addedAt});
}

/// @nodoc
class _$TrackedMediaSummaryModelCopyWithImpl<$Res,
        $Val extends TrackedMediaSummaryModel>
    implements $TrackedMediaSummaryModelCopyWith<$Res> {
  _$TrackedMediaSummaryModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrackedMediaSummaryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mediaId = null,
    Object? title = null,
    Object? mediaType = freezed,
    Object? overview = freezed,
    Object? posterPath = freezed,
    Object? status = freezed,
    Object? trackingRating = freezed,
    Object? seasonCount = freezed,
    Object? addedAt = freezed,
  }) {
    return _then(_value.copyWith(
      mediaId: null == mediaId
          ? _value.mediaId
          : mediaId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      mediaType: freezed == mediaType
          ? _value.mediaType
          : mediaType // ignore: cast_nullable_to_non_nullable
              as MediaType?,
      overview: freezed == overview
          ? _value.overview
          : overview // ignore: cast_nullable_to_non_nullable
              as String?,
      posterPath: freezed == posterPath
          ? _value.posterPath
          : posterPath // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      trackingRating: freezed == trackingRating
          ? _value.trackingRating
          : trackingRating // ignore: cast_nullable_to_non_nullable
              as int?,
      seasonCount: freezed == seasonCount
          ? _value.seasonCount
          : seasonCount // ignore: cast_nullable_to_non_nullable
              as int?,
      addedAt: freezed == addedAt
          ? _value.addedAt
          : addedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TrackedMediaSummaryModelImplCopyWith<$Res>
    implements $TrackedMediaSummaryModelCopyWith<$Res> {
  factory _$$TrackedMediaSummaryModelImplCopyWith(
          _$TrackedMediaSummaryModelImpl value,
          $Res Function(_$TrackedMediaSummaryModelImpl) then) =
      __$$TrackedMediaSummaryModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(
          name: 'tmdbId',
          fromJson: flexibleStringFromJson,
          toJson: flexibleStringToJson)
      String mediaId,
      String title,
      @JsonKey(
          fromJson: _nullableMediaTypeFromJson,
          toJson: _nullableMediaTypeToJson)
      MediaType? mediaType,
      String? overview,
      String? posterPath,
      String? status,
      int? trackingRating,
      int? seasonCount,
      DateTime? addedAt});
}

/// @nodoc
class __$$TrackedMediaSummaryModelImplCopyWithImpl<$Res>
    extends _$TrackedMediaSummaryModelCopyWithImpl<$Res,
        _$TrackedMediaSummaryModelImpl>
    implements _$$TrackedMediaSummaryModelImplCopyWith<$Res> {
  __$$TrackedMediaSummaryModelImplCopyWithImpl(
      _$TrackedMediaSummaryModelImpl _value,
      $Res Function(_$TrackedMediaSummaryModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of TrackedMediaSummaryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mediaId = null,
    Object? title = null,
    Object? mediaType = freezed,
    Object? overview = freezed,
    Object? posterPath = freezed,
    Object? status = freezed,
    Object? trackingRating = freezed,
    Object? seasonCount = freezed,
    Object? addedAt = freezed,
  }) {
    return _then(_$TrackedMediaSummaryModelImpl(
      mediaId: null == mediaId
          ? _value.mediaId
          : mediaId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      mediaType: freezed == mediaType
          ? _value.mediaType
          : mediaType // ignore: cast_nullable_to_non_nullable
              as MediaType?,
      overview: freezed == overview
          ? _value.overview
          : overview // ignore: cast_nullable_to_non_nullable
              as String?,
      posterPath: freezed == posterPath
          ? _value.posterPath
          : posterPath // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      trackingRating: freezed == trackingRating
          ? _value.trackingRating
          : trackingRating // ignore: cast_nullable_to_non_nullable
              as int?,
      seasonCount: freezed == seasonCount
          ? _value.seasonCount
          : seasonCount // ignore: cast_nullable_to_non_nullable
              as int?,
      addedAt: freezed == addedAt
          ? _value.addedAt
          : addedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TrackedMediaSummaryModelImpl implements _TrackedMediaSummaryModel {
  const _$TrackedMediaSummaryModelImpl(
      {@JsonKey(
          name: 'tmdbId',
          fromJson: flexibleStringFromJson,
          toJson: flexibleStringToJson)
      required this.mediaId,
      required this.title,
      @JsonKey(
          fromJson: _nullableMediaTypeFromJson,
          toJson: _nullableMediaTypeToJson)
      this.mediaType,
      this.overview,
      this.posterPath,
      this.status,
      this.trackingRating,
      this.seasonCount,
      this.addedAt});

  factory _$TrackedMediaSummaryModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrackedMediaSummaryModelImplFromJson(json);

  @override
  @JsonKey(
      name: 'tmdbId',
      fromJson: flexibleStringFromJson,
      toJson: flexibleStringToJson)
  final String mediaId;
  @override
  final String title;
  @override
  @JsonKey(
      fromJson: _nullableMediaTypeFromJson, toJson: _nullableMediaTypeToJson)
  final MediaType? mediaType;
  @override
  final String? overview;
  @override
  final String? posterPath;
  @override
  final String? status;
  @override
  final int? trackingRating;
  @override
  final int? seasonCount;
  @override
  final DateTime? addedAt;

  @override
  String toString() {
    return 'TrackedMediaSummaryModel(mediaId: $mediaId, title: $title, mediaType: $mediaType, overview: $overview, posterPath: $posterPath, status: $status, trackingRating: $trackingRating, seasonCount: $seasonCount, addedAt: $addedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrackedMediaSummaryModelImpl &&
            (identical(other.mediaId, mediaId) || other.mediaId == mediaId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.mediaType, mediaType) ||
                other.mediaType == mediaType) &&
            (identical(other.overview, overview) ||
                other.overview == overview) &&
            (identical(other.posterPath, posterPath) ||
                other.posterPath == posterPath) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.trackingRating, trackingRating) ||
                other.trackingRating == trackingRating) &&
            (identical(other.seasonCount, seasonCount) ||
                other.seasonCount == seasonCount) &&
            (identical(other.addedAt, addedAt) || other.addedAt == addedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, mediaId, title, mediaType,
      overview, posterPath, status, trackingRating, seasonCount, addedAt);

  /// Create a copy of TrackedMediaSummaryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrackedMediaSummaryModelImplCopyWith<_$TrackedMediaSummaryModelImpl>
      get copyWith => __$$TrackedMediaSummaryModelImplCopyWithImpl<
          _$TrackedMediaSummaryModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrackedMediaSummaryModelImplToJson(
      this,
    );
  }
}

abstract class _TrackedMediaSummaryModel implements TrackedMediaSummaryModel {
  const factory _TrackedMediaSummaryModel(
      {@JsonKey(
          name: 'tmdbId',
          fromJson: flexibleStringFromJson,
          toJson: flexibleStringToJson)
      required final String mediaId,
      required final String title,
      @JsonKey(
          fromJson: _nullableMediaTypeFromJson,
          toJson: _nullableMediaTypeToJson)
      final MediaType? mediaType,
      final String? overview,
      final String? posterPath,
      final String? status,
      final int? trackingRating,
      final int? seasonCount,
      final DateTime? addedAt}) = _$TrackedMediaSummaryModelImpl;

  factory _TrackedMediaSummaryModel.fromJson(Map<String, dynamic> json) =
      _$TrackedMediaSummaryModelImpl.fromJson;

  @override
  @JsonKey(
      name: 'tmdbId',
      fromJson: flexibleStringFromJson,
      toJson: flexibleStringToJson)
  String get mediaId;
  @override
  String get title;
  @override
  @JsonKey(
      fromJson: _nullableMediaTypeFromJson, toJson: _nullableMediaTypeToJson)
  MediaType? get mediaType;
  @override
  String? get overview;
  @override
  String? get posterPath;
  @override
  String? get status;
  @override
  int? get trackingRating;
  @override
  int? get seasonCount;
  @override
  DateTime? get addedAt;

  /// Create a copy of TrackedMediaSummaryModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrackedMediaSummaryModelImplCopyWith<_$TrackedMediaSummaryModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
