// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_stats_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DashboardStatsModel _$DashboardStatsModelFromJson(Map<String, dynamic> json) {
  return _DashboardStatsModel.fromJson(json);
}

/// @nodoc
mixin _$DashboardStatsModel {
  int get watchingCount => throw _privateConstructorUsedError;
  int get wantToWatchCount => throw _privateConstructorUsedError;
  int get completedCount => throw _privateConstructorUsedError;
  int get droppedCount => throw _privateConstructorUsedError;
  int get totalTracked => throw _privateConstructorUsedError;

  /// Serializes this DashboardStatsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DashboardStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DashboardStatsModelCopyWith<DashboardStatsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DashboardStatsModelCopyWith<$Res> {
  factory $DashboardStatsModelCopyWith(
          DashboardStatsModel value, $Res Function(DashboardStatsModel) then) =
      _$DashboardStatsModelCopyWithImpl<$Res, DashboardStatsModel>;
  @useResult
  $Res call(
      {int watchingCount,
      int wantToWatchCount,
      int completedCount,
      int droppedCount,
      int totalTracked});
}

/// @nodoc
class _$DashboardStatsModelCopyWithImpl<$Res, $Val extends DashboardStatsModel>
    implements $DashboardStatsModelCopyWith<$Res> {
  _$DashboardStatsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DashboardStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? watchingCount = null,
    Object? wantToWatchCount = null,
    Object? completedCount = null,
    Object? droppedCount = null,
    Object? totalTracked = null,
  }) {
    return _then(_value.copyWith(
      watchingCount: null == watchingCount
          ? _value.watchingCount
          : watchingCount // ignore: cast_nullable_to_non_nullable
              as int,
      wantToWatchCount: null == wantToWatchCount
          ? _value.wantToWatchCount
          : wantToWatchCount // ignore: cast_nullable_to_non_nullable
              as int,
      completedCount: null == completedCount
          ? _value.completedCount
          : completedCount // ignore: cast_nullable_to_non_nullable
              as int,
      droppedCount: null == droppedCount
          ? _value.droppedCount
          : droppedCount // ignore: cast_nullable_to_non_nullable
              as int,
      totalTracked: null == totalTracked
          ? _value.totalTracked
          : totalTracked // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DashboardStatsModelImplCopyWith<$Res>
    implements $DashboardStatsModelCopyWith<$Res> {
  factory _$$DashboardStatsModelImplCopyWith(_$DashboardStatsModelImpl value,
          $Res Function(_$DashboardStatsModelImpl) then) =
      __$$DashboardStatsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int watchingCount,
      int wantToWatchCount,
      int completedCount,
      int droppedCount,
      int totalTracked});
}

/// @nodoc
class __$$DashboardStatsModelImplCopyWithImpl<$Res>
    extends _$DashboardStatsModelCopyWithImpl<$Res, _$DashboardStatsModelImpl>
    implements _$$DashboardStatsModelImplCopyWith<$Res> {
  __$$DashboardStatsModelImplCopyWithImpl(_$DashboardStatsModelImpl _value,
      $Res Function(_$DashboardStatsModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of DashboardStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? watchingCount = null,
    Object? wantToWatchCount = null,
    Object? completedCount = null,
    Object? droppedCount = null,
    Object? totalTracked = null,
  }) {
    return _then(_$DashboardStatsModelImpl(
      watchingCount: null == watchingCount
          ? _value.watchingCount
          : watchingCount // ignore: cast_nullable_to_non_nullable
              as int,
      wantToWatchCount: null == wantToWatchCount
          ? _value.wantToWatchCount
          : wantToWatchCount // ignore: cast_nullable_to_non_nullable
              as int,
      completedCount: null == completedCount
          ? _value.completedCount
          : completedCount // ignore: cast_nullable_to_non_nullable
              as int,
      droppedCount: null == droppedCount
          ? _value.droppedCount
          : droppedCount // ignore: cast_nullable_to_non_nullable
              as int,
      totalTracked: null == totalTracked
          ? _value.totalTracked
          : totalTracked // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DashboardStatsModelImpl implements _DashboardStatsModel {
  const _$DashboardStatsModelImpl(
      {this.watchingCount = 0,
      this.wantToWatchCount = 0,
      this.completedCount = 0,
      this.droppedCount = 0,
      this.totalTracked = 0});

  factory _$DashboardStatsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DashboardStatsModelImplFromJson(json);

  @override
  @JsonKey()
  final int watchingCount;
  @override
  @JsonKey()
  final int wantToWatchCount;
  @override
  @JsonKey()
  final int completedCount;
  @override
  @JsonKey()
  final int droppedCount;
  @override
  @JsonKey()
  final int totalTracked;

  @override
  String toString() {
    return 'DashboardStatsModel(watchingCount: $watchingCount, wantToWatchCount: $wantToWatchCount, completedCount: $completedCount, droppedCount: $droppedCount, totalTracked: $totalTracked)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DashboardStatsModelImpl &&
            (identical(other.watchingCount, watchingCount) ||
                other.watchingCount == watchingCount) &&
            (identical(other.wantToWatchCount, wantToWatchCount) ||
                other.wantToWatchCount == wantToWatchCount) &&
            (identical(other.completedCount, completedCount) ||
                other.completedCount == completedCount) &&
            (identical(other.droppedCount, droppedCount) ||
                other.droppedCount == droppedCount) &&
            (identical(other.totalTracked, totalTracked) ||
                other.totalTracked == totalTracked));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, watchingCount, wantToWatchCount,
      completedCount, droppedCount, totalTracked);

  /// Create a copy of DashboardStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DashboardStatsModelImplCopyWith<_$DashboardStatsModelImpl> get copyWith =>
      __$$DashboardStatsModelImplCopyWithImpl<_$DashboardStatsModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DashboardStatsModelImplToJson(
      this,
    );
  }
}

abstract class _DashboardStatsModel implements DashboardStatsModel {
  const factory _DashboardStatsModel(
      {final int watchingCount,
      final int wantToWatchCount,
      final int completedCount,
      final int droppedCount,
      final int totalTracked}) = _$DashboardStatsModelImpl;

  factory _DashboardStatsModel.fromJson(Map<String, dynamic> json) =
      _$DashboardStatsModelImpl.fromJson;

  @override
  int get watchingCount;
  @override
  int get wantToWatchCount;
  @override
  int get completedCount;
  @override
  int get droppedCount;
  @override
  int get totalTracked;

  /// Create a copy of DashboardStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DashboardStatsModelImplCopyWith<_$DashboardStatsModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
