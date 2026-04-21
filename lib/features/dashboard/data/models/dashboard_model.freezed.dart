// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DashboardModel _$DashboardModelFromJson(Map<String, dynamic> json) {
  return _DashboardModel.fromJson(json);
}

/// @nodoc
mixin _$DashboardModel {
  DashboardSectionModel get watching => throw _privateConstructorUsedError;
  DashboardSectionModel get wantToWatch => throw _privateConstructorUsedError;
  DashboardSectionModel get completed => throw _privateConstructorUsedError;
  DashboardSectionModel get dropped => throw _privateConstructorUsedError;
  DashboardStatsModel get stats => throw _privateConstructorUsedError;

  /// Serializes this DashboardModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DashboardModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DashboardModelCopyWith<DashboardModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DashboardModelCopyWith<$Res> {
  factory $DashboardModelCopyWith(
          DashboardModel value, $Res Function(DashboardModel) then) =
      _$DashboardModelCopyWithImpl<$Res, DashboardModel>;
  @useResult
  $Res call(
      {DashboardSectionModel watching,
      DashboardSectionModel wantToWatch,
      DashboardSectionModel completed,
      DashboardSectionModel dropped,
      DashboardStatsModel stats});

  $DashboardSectionModelCopyWith<$Res> get watching;
  $DashboardSectionModelCopyWith<$Res> get wantToWatch;
  $DashboardSectionModelCopyWith<$Res> get completed;
  $DashboardSectionModelCopyWith<$Res> get dropped;
  $DashboardStatsModelCopyWith<$Res> get stats;
}

/// @nodoc
class _$DashboardModelCopyWithImpl<$Res, $Val extends DashboardModel>
    implements $DashboardModelCopyWith<$Res> {
  _$DashboardModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DashboardModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? watching = null,
    Object? wantToWatch = null,
    Object? completed = null,
    Object? dropped = null,
    Object? stats = null,
  }) {
    return _then(_value.copyWith(
      watching: null == watching
          ? _value.watching
          : watching // ignore: cast_nullable_to_non_nullable
              as DashboardSectionModel,
      wantToWatch: null == wantToWatch
          ? _value.wantToWatch
          : wantToWatch // ignore: cast_nullable_to_non_nullable
              as DashboardSectionModel,
      completed: null == completed
          ? _value.completed
          : completed // ignore: cast_nullable_to_non_nullable
              as DashboardSectionModel,
      dropped: null == dropped
          ? _value.dropped
          : dropped // ignore: cast_nullable_to_non_nullable
              as DashboardSectionModel,
      stats: null == stats
          ? _value.stats
          : stats // ignore: cast_nullable_to_non_nullable
              as DashboardStatsModel,
    ) as $Val);
  }

  /// Create a copy of DashboardModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DashboardSectionModelCopyWith<$Res> get watching {
    return $DashboardSectionModelCopyWith<$Res>(_value.watching, (value) {
      return _then(_value.copyWith(watching: value) as $Val);
    });
  }

  /// Create a copy of DashboardModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DashboardSectionModelCopyWith<$Res> get wantToWatch {
    return $DashboardSectionModelCopyWith<$Res>(_value.wantToWatch, (value) {
      return _then(_value.copyWith(wantToWatch: value) as $Val);
    });
  }

  /// Create a copy of DashboardModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DashboardSectionModelCopyWith<$Res> get completed {
    return $DashboardSectionModelCopyWith<$Res>(_value.completed, (value) {
      return _then(_value.copyWith(completed: value) as $Val);
    });
  }

  /// Create a copy of DashboardModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DashboardSectionModelCopyWith<$Res> get dropped {
    return $DashboardSectionModelCopyWith<$Res>(_value.dropped, (value) {
      return _then(_value.copyWith(dropped: value) as $Val);
    });
  }

  /// Create a copy of DashboardModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DashboardStatsModelCopyWith<$Res> get stats {
    return $DashboardStatsModelCopyWith<$Res>(_value.stats, (value) {
      return _then(_value.copyWith(stats: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DashboardModelImplCopyWith<$Res>
    implements $DashboardModelCopyWith<$Res> {
  factory _$$DashboardModelImplCopyWith(_$DashboardModelImpl value,
          $Res Function(_$DashboardModelImpl) then) =
      __$$DashboardModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DashboardSectionModel watching,
      DashboardSectionModel wantToWatch,
      DashboardSectionModel completed,
      DashboardSectionModel dropped,
      DashboardStatsModel stats});

  @override
  $DashboardSectionModelCopyWith<$Res> get watching;
  @override
  $DashboardSectionModelCopyWith<$Res> get wantToWatch;
  @override
  $DashboardSectionModelCopyWith<$Res> get completed;
  @override
  $DashboardSectionModelCopyWith<$Res> get dropped;
  @override
  $DashboardStatsModelCopyWith<$Res> get stats;
}

/// @nodoc
class __$$DashboardModelImplCopyWithImpl<$Res>
    extends _$DashboardModelCopyWithImpl<$Res, _$DashboardModelImpl>
    implements _$$DashboardModelImplCopyWith<$Res> {
  __$$DashboardModelImplCopyWithImpl(
      _$DashboardModelImpl _value, $Res Function(_$DashboardModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of DashboardModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? watching = null,
    Object? wantToWatch = null,
    Object? completed = null,
    Object? dropped = null,
    Object? stats = null,
  }) {
    return _then(_$DashboardModelImpl(
      watching: null == watching
          ? _value.watching
          : watching // ignore: cast_nullable_to_non_nullable
              as DashboardSectionModel,
      wantToWatch: null == wantToWatch
          ? _value.wantToWatch
          : wantToWatch // ignore: cast_nullable_to_non_nullable
              as DashboardSectionModel,
      completed: null == completed
          ? _value.completed
          : completed // ignore: cast_nullable_to_non_nullable
              as DashboardSectionModel,
      dropped: null == dropped
          ? _value.dropped
          : dropped // ignore: cast_nullable_to_non_nullable
              as DashboardSectionModel,
      stats: null == stats
          ? _value.stats
          : stats // ignore: cast_nullable_to_non_nullable
              as DashboardStatsModel,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DashboardModelImpl implements _DashboardModel {
  const _$DashboardModelImpl(
      {required this.watching,
      required this.wantToWatch,
      required this.completed,
      required this.dropped,
      required this.stats});

  factory _$DashboardModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DashboardModelImplFromJson(json);

  @override
  final DashboardSectionModel watching;
  @override
  final DashboardSectionModel wantToWatch;
  @override
  final DashboardSectionModel completed;
  @override
  final DashboardSectionModel dropped;
  @override
  final DashboardStatsModel stats;

  @override
  String toString() {
    return 'DashboardModel(watching: $watching, wantToWatch: $wantToWatch, completed: $completed, dropped: $dropped, stats: $stats)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DashboardModelImpl &&
            (identical(other.watching, watching) ||
                other.watching == watching) &&
            (identical(other.wantToWatch, wantToWatch) ||
                other.wantToWatch == wantToWatch) &&
            (identical(other.completed, completed) ||
                other.completed == completed) &&
            (identical(other.dropped, dropped) || other.dropped == dropped) &&
            (identical(other.stats, stats) || other.stats == stats));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, watching, wantToWatch, completed, dropped, stats);

  /// Create a copy of DashboardModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DashboardModelImplCopyWith<_$DashboardModelImpl> get copyWith =>
      __$$DashboardModelImplCopyWithImpl<_$DashboardModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DashboardModelImplToJson(
      this,
    );
  }
}

abstract class _DashboardModel implements DashboardModel {
  const factory _DashboardModel(
      {required final DashboardSectionModel watching,
      required final DashboardSectionModel wantToWatch,
      required final DashboardSectionModel completed,
      required final DashboardSectionModel dropped,
      required final DashboardStatsModel stats}) = _$DashboardModelImpl;

  factory _DashboardModel.fromJson(Map<String, dynamic> json) =
      _$DashboardModelImpl.fromJson;

  @override
  DashboardSectionModel get watching;
  @override
  DashboardSectionModel get wantToWatch;
  @override
  DashboardSectionModel get completed;
  @override
  DashboardSectionModel get dropped;
  @override
  DashboardStatsModel get stats;

  /// Create a copy of DashboardModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DashboardModelImplCopyWith<_$DashboardModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
