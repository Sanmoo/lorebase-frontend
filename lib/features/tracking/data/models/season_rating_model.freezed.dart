// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'season_rating_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SeasonRatingModel _$SeasonRatingModelFromJson(Map<String, dynamic> json) {
  return _SeasonRatingModel.fromJson(json);
}

/// @nodoc
mixin _$SeasonRatingModel {
  int get seasonNumber => throw _privateConstructorUsedError;
  int get rating => throw _privateConstructorUsedError;
  DateTime get ratedAt => throw _privateConstructorUsedError;

  /// Serializes this SeasonRatingModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SeasonRatingModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SeasonRatingModelCopyWith<SeasonRatingModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SeasonRatingModelCopyWith<$Res> {
  factory $SeasonRatingModelCopyWith(
          SeasonRatingModel value, $Res Function(SeasonRatingModel) then) =
      _$SeasonRatingModelCopyWithImpl<$Res, SeasonRatingModel>;
  @useResult
  $Res call({int seasonNumber, int rating, DateTime ratedAt});
}

/// @nodoc
class _$SeasonRatingModelCopyWithImpl<$Res, $Val extends SeasonRatingModel>
    implements $SeasonRatingModelCopyWith<$Res> {
  _$SeasonRatingModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SeasonRatingModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? seasonNumber = null,
    Object? rating = null,
    Object? ratedAt = null,
  }) {
    return _then(_value.copyWith(
      seasonNumber: null == seasonNumber
          ? _value.seasonNumber
          : seasonNumber // ignore: cast_nullable_to_non_nullable
              as int,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as int,
      ratedAt: null == ratedAt
          ? _value.ratedAt
          : ratedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SeasonRatingModelImplCopyWith<$Res>
    implements $SeasonRatingModelCopyWith<$Res> {
  factory _$$SeasonRatingModelImplCopyWith(_$SeasonRatingModelImpl value,
          $Res Function(_$SeasonRatingModelImpl) then) =
      __$$SeasonRatingModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int seasonNumber, int rating, DateTime ratedAt});
}

/// @nodoc
class __$$SeasonRatingModelImplCopyWithImpl<$Res>
    extends _$SeasonRatingModelCopyWithImpl<$Res, _$SeasonRatingModelImpl>
    implements _$$SeasonRatingModelImplCopyWith<$Res> {
  __$$SeasonRatingModelImplCopyWithImpl(_$SeasonRatingModelImpl _value,
      $Res Function(_$SeasonRatingModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of SeasonRatingModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? seasonNumber = null,
    Object? rating = null,
    Object? ratedAt = null,
  }) {
    return _then(_$SeasonRatingModelImpl(
      seasonNumber: null == seasonNumber
          ? _value.seasonNumber
          : seasonNumber // ignore: cast_nullable_to_non_nullable
              as int,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as int,
      ratedAt: null == ratedAt
          ? _value.ratedAt
          : ratedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SeasonRatingModelImpl implements _SeasonRatingModel {
  const _$SeasonRatingModelImpl(
      {required this.seasonNumber,
      required this.rating,
      required this.ratedAt});

  factory _$SeasonRatingModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SeasonRatingModelImplFromJson(json);

  @override
  final int seasonNumber;
  @override
  final int rating;
  @override
  final DateTime ratedAt;

  @override
  String toString() {
    return 'SeasonRatingModel(seasonNumber: $seasonNumber, rating: $rating, ratedAt: $ratedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SeasonRatingModelImpl &&
            (identical(other.seasonNumber, seasonNumber) ||
                other.seasonNumber == seasonNumber) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.ratedAt, ratedAt) || other.ratedAt == ratedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, seasonNumber, rating, ratedAt);

  /// Create a copy of SeasonRatingModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SeasonRatingModelImplCopyWith<_$SeasonRatingModelImpl> get copyWith =>
      __$$SeasonRatingModelImplCopyWithImpl<_$SeasonRatingModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SeasonRatingModelImplToJson(
      this,
    );
  }
}

abstract class _SeasonRatingModel implements SeasonRatingModel {
  const factory _SeasonRatingModel(
      {required final int seasonNumber,
      required final int rating,
      required final DateTime ratedAt}) = _$SeasonRatingModelImpl;

  factory _SeasonRatingModel.fromJson(Map<String, dynamic> json) =
      _$SeasonRatingModelImpl.fromJson;

  @override
  int get seasonNumber;
  @override
  int get rating;
  @override
  DateTime get ratedAt;

  /// Create a copy of SeasonRatingModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SeasonRatingModelImplCopyWith<_$SeasonRatingModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
