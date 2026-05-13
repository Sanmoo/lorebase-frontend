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
  int get tmdbId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  @JsonKey(fromJson: mediaTypeFromJson, toJson: mediaTypeToJson)
  MediaType get mediaType => throw _privateConstructorUsedError;
  String? get posterPath => throw _privateConstructorUsedError;
  String? get backdropPath => throw _privateConstructorUsedError;

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
      {int tmdbId,
      String title,
      @JsonKey(fromJson: mediaTypeFromJson, toJson: mediaTypeToJson)
      MediaType mediaType,
      String? posterPath,
      String? backdropPath});
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
    Object? tmdbId = null,
    Object? title = null,
    Object? mediaType = null,
    Object? posterPath = freezed,
    Object? backdropPath = freezed,
  }) {
    return _then(_value.copyWith(
      tmdbId: null == tmdbId
          ? _value.tmdbId
          : tmdbId // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      mediaType: null == mediaType
          ? _value.mediaType
          : mediaType // ignore: cast_nullable_to_non_nullable
              as MediaType,
      posterPath: freezed == posterPath
          ? _value.posterPath
          : posterPath // ignore: cast_nullable_to_non_nullable
              as String?,
      backdropPath: freezed == backdropPath
          ? _value.backdropPath
          : backdropPath // ignore: cast_nullable_to_non_nullable
              as String?,
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
      {int tmdbId,
      String title,
      @JsonKey(fromJson: mediaTypeFromJson, toJson: mediaTypeToJson)
      MediaType mediaType,
      String? posterPath,
      String? backdropPath});
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
    Object? tmdbId = null,
    Object? title = null,
    Object? mediaType = null,
    Object? posterPath = freezed,
    Object? backdropPath = freezed,
  }) {
    return _then(_$TrackedMediaSummaryModelImpl(
      tmdbId: null == tmdbId
          ? _value.tmdbId
          : tmdbId // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      mediaType: null == mediaType
          ? _value.mediaType
          : mediaType // ignore: cast_nullable_to_non_nullable
              as MediaType,
      posterPath: freezed == posterPath
          ? _value.posterPath
          : posterPath // ignore: cast_nullable_to_non_nullable
              as String?,
      backdropPath: freezed == backdropPath
          ? _value.backdropPath
          : backdropPath // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TrackedMediaSummaryModelImpl implements _TrackedMediaSummaryModel {
  const _$TrackedMediaSummaryModelImpl(
      {required this.tmdbId,
      required this.title,
      @JsonKey(fromJson: mediaTypeFromJson, toJson: mediaTypeToJson)
      required this.mediaType,
      this.posterPath,
      this.backdropPath});

  factory _$TrackedMediaSummaryModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrackedMediaSummaryModelImplFromJson(json);

  @override
  final int tmdbId;
  @override
  final String title;
  @override
  @JsonKey(fromJson: mediaTypeFromJson, toJson: mediaTypeToJson)
  final MediaType mediaType;
  @override
  final String? posterPath;
  @override
  final String? backdropPath;

  @override
  String toString() {
    return 'TrackedMediaSummaryModel(tmdbId: $tmdbId, title: $title, mediaType: $mediaType, posterPath: $posterPath, backdropPath: $backdropPath)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrackedMediaSummaryModelImpl &&
            (identical(other.tmdbId, tmdbId) || other.tmdbId == tmdbId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.mediaType, mediaType) ||
                other.mediaType == mediaType) &&
            (identical(other.posterPath, posterPath) ||
                other.posterPath == posterPath) &&
            (identical(other.backdropPath, backdropPath) ||
                other.backdropPath == backdropPath));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, tmdbId, title, mediaType, posterPath, backdropPath);

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
      {required final int tmdbId,
      required final String title,
      @JsonKey(fromJson: mediaTypeFromJson, toJson: mediaTypeToJson)
      required final MediaType mediaType,
      final String? posterPath,
      final String? backdropPath}) = _$TrackedMediaSummaryModelImpl;

  factory _TrackedMediaSummaryModel.fromJson(Map<String, dynamic> json) =
      _$TrackedMediaSummaryModelImpl.fromJson;

  @override
  int get tmdbId;
  @override
  String get title;
  @override
  @JsonKey(fromJson: mediaTypeFromJson, toJson: mediaTypeToJson)
  MediaType get mediaType;
  @override
  String? get posterPath;
  @override
  String? get backdropPath;

  /// Create a copy of TrackedMediaSummaryModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrackedMediaSummaryModelImplCopyWith<_$TrackedMediaSummaryModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
