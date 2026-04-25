// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tracked_series_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TrackedSeriesModel _$TrackedSeriesModelFromJson(Map<String, dynamic> json) {
  return _TrackedSeriesModel.fromJson(json);
}

/// @nodoc
mixin _$TrackedSeriesModel {
  String get trackingId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get seriesId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  int? get seriesRating => throw _privateConstructorUsedError;
  String? get seriesReview => throw _privateConstructorUsedError;
  List<SeasonRatingModel> get seasonRatings =>
      throw _privateConstructorUsedError;
  SeriesModel? get series => throw _privateConstructorUsedError;
  DateTime get addedAt => throw _privateConstructorUsedError;
  DateTime get lastUpdated => throw _privateConstructorUsedError;

  /// Serializes this TrackedSeriesModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TrackedSeriesModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrackedSeriesModelCopyWith<TrackedSeriesModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrackedSeriesModelCopyWith<$Res> {
  factory $TrackedSeriesModelCopyWith(
          TrackedSeriesModel value, $Res Function(TrackedSeriesModel) then) =
      _$TrackedSeriesModelCopyWithImpl<$Res, TrackedSeriesModel>;
  @useResult
  $Res call(
      {String trackingId,
      String userId,
      String seriesId,
      String status,
      int? seriesRating,
      String? seriesReview,
      List<SeasonRatingModel> seasonRatings,
      SeriesModel? series,
      DateTime addedAt,
      DateTime lastUpdated});

  $SeriesModelCopyWith<$Res>? get series;
}

/// @nodoc
class _$TrackedSeriesModelCopyWithImpl<$Res, $Val extends TrackedSeriesModel>
    implements $TrackedSeriesModelCopyWith<$Res> {
  _$TrackedSeriesModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrackedSeriesModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? trackingId = null,
    Object? userId = null,
    Object? seriesId = null,
    Object? status = null,
    Object? seriesRating = freezed,
    Object? seriesReview = freezed,
    Object? seasonRatings = null,
    Object? series = freezed,
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
      seriesId: null == seriesId
          ? _value.seriesId
          : seriesId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      seriesRating: freezed == seriesRating
          ? _value.seriesRating
          : seriesRating // ignore: cast_nullable_to_non_nullable
              as int?,
      seriesReview: freezed == seriesReview
          ? _value.seriesReview
          : seriesReview // ignore: cast_nullable_to_non_nullable
              as String?,
      seasonRatings: null == seasonRatings
          ? _value.seasonRatings
          : seasonRatings // ignore: cast_nullable_to_non_nullable
              as List<SeasonRatingModel>,
      series: freezed == series
          ? _value.series
          : series // ignore: cast_nullable_to_non_nullable
              as SeriesModel?,
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

  /// Create a copy of TrackedSeriesModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SeriesModelCopyWith<$Res>? get series {
    if (_value.series == null) {
      return null;
    }

    return $SeriesModelCopyWith<$Res>(_value.series!, (value) {
      return _then(_value.copyWith(series: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TrackedSeriesModelImplCopyWith<$Res>
    implements $TrackedSeriesModelCopyWith<$Res> {
  factory _$$TrackedSeriesModelImplCopyWith(_$TrackedSeriesModelImpl value,
          $Res Function(_$TrackedSeriesModelImpl) then) =
      __$$TrackedSeriesModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String trackingId,
      String userId,
      String seriesId,
      String status,
      int? seriesRating,
      String? seriesReview,
      List<SeasonRatingModel> seasonRatings,
      SeriesModel? series,
      DateTime addedAt,
      DateTime lastUpdated});

  @override
  $SeriesModelCopyWith<$Res>? get series;
}

/// @nodoc
class __$$TrackedSeriesModelImplCopyWithImpl<$Res>
    extends _$TrackedSeriesModelCopyWithImpl<$Res, _$TrackedSeriesModelImpl>
    implements _$$TrackedSeriesModelImplCopyWith<$Res> {
  __$$TrackedSeriesModelImplCopyWithImpl(_$TrackedSeriesModelImpl _value,
      $Res Function(_$TrackedSeriesModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of TrackedSeriesModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? trackingId = null,
    Object? userId = null,
    Object? seriesId = null,
    Object? status = null,
    Object? seriesRating = freezed,
    Object? seriesReview = freezed,
    Object? seasonRatings = null,
    Object? series = freezed,
    Object? addedAt = null,
    Object? lastUpdated = null,
  }) {
    return _then(_$TrackedSeriesModelImpl(
      trackingId: null == trackingId
          ? _value.trackingId
          : trackingId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      seriesId: null == seriesId
          ? _value.seriesId
          : seriesId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      seriesRating: freezed == seriesRating
          ? _value.seriesRating
          : seriesRating // ignore: cast_nullable_to_non_nullable
              as int?,
      seriesReview: freezed == seriesReview
          ? _value.seriesReview
          : seriesReview // ignore: cast_nullable_to_non_nullable
              as String?,
      seasonRatings: null == seasonRatings
          ? _value._seasonRatings
          : seasonRatings // ignore: cast_nullable_to_non_nullable
              as List<SeasonRatingModel>,
      series: freezed == series
          ? _value.series
          : series // ignore: cast_nullable_to_non_nullable
              as SeriesModel?,
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
class _$TrackedSeriesModelImpl implements _TrackedSeriesModel {
  const _$TrackedSeriesModelImpl(
      {required this.trackingId,
      required this.userId,
      required this.seriesId,
      required this.status,
      this.seriesRating,
      this.seriesReview,
      final List<SeasonRatingModel> seasonRatings = const [],
      this.series,
      required this.addedAt,
      required this.lastUpdated})
      : _seasonRatings = seasonRatings;

  factory _$TrackedSeriesModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrackedSeriesModelImplFromJson(json);

  @override
  final String trackingId;
  @override
  final String userId;
  @override
  final String seriesId;
  @override
  final String status;
  @override
  final int? seriesRating;
  @override
  final String? seriesReview;
  final List<SeasonRatingModel> _seasonRatings;
  @override
  @JsonKey()
  List<SeasonRatingModel> get seasonRatings {
    if (_seasonRatings is EqualUnmodifiableListView) return _seasonRatings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_seasonRatings);
  }

  @override
  final SeriesModel? series;
  @override
  final DateTime addedAt;
  @override
  final DateTime lastUpdated;

  @override
  String toString() {
    return 'TrackedSeriesModel(trackingId: $trackingId, userId: $userId, seriesId: $seriesId, status: $status, seriesRating: $seriesRating, seriesReview: $seriesReview, seasonRatings: $seasonRatings, series: $series, addedAt: $addedAt, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrackedSeriesModelImpl &&
            (identical(other.trackingId, trackingId) ||
                other.trackingId == trackingId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.seriesId, seriesId) ||
                other.seriesId == seriesId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.seriesRating, seriesRating) ||
                other.seriesRating == seriesRating) &&
            (identical(other.seriesReview, seriesReview) ||
                other.seriesReview == seriesReview) &&
            const DeepCollectionEquality()
                .equals(other._seasonRatings, _seasonRatings) &&
            (identical(other.series, series) || other.series == series) &&
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
      seriesId,
      status,
      seriesRating,
      seriesReview,
      const DeepCollectionEquality().hash(_seasonRatings),
      series,
      addedAt,
      lastUpdated);

  /// Create a copy of TrackedSeriesModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrackedSeriesModelImplCopyWith<_$TrackedSeriesModelImpl> get copyWith =>
      __$$TrackedSeriesModelImplCopyWithImpl<_$TrackedSeriesModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrackedSeriesModelImplToJson(
      this,
    );
  }
}

abstract class _TrackedSeriesModel implements TrackedSeriesModel {
  const factory _TrackedSeriesModel(
      {required final String trackingId,
      required final String userId,
      required final String seriesId,
      required final String status,
      final int? seriesRating,
      final String? seriesReview,
      final List<SeasonRatingModel> seasonRatings,
      final SeriesModel? series,
      required final DateTime addedAt,
      required final DateTime lastUpdated}) = _$TrackedSeriesModelImpl;

  factory _TrackedSeriesModel.fromJson(Map<String, dynamic> json) =
      _$TrackedSeriesModelImpl.fromJson;

  @override
  String get trackingId;
  @override
  String get userId;
  @override
  String get seriesId;
  @override
  String get status;
  @override
  int? get seriesRating;
  @override
  String? get seriesReview;
  @override
  List<SeasonRatingModel> get seasonRatings;
  @override
  SeriesModel? get series;
  @override
  DateTime get addedAt;
  @override
  DateTime get lastUpdated;

  /// Create a copy of TrackedSeriesModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrackedSeriesModelImplCopyWith<_$TrackedSeriesModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
