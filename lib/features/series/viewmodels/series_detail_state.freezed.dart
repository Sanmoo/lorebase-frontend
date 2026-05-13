// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'series_detail_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SeriesDetailState {
  SeriesModel get series => throw _privateConstructorUsedError;
  TrackedMediaModel? get tracking => throw _privateConstructorUsedError;

  /// Create a copy of SeriesDetailState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SeriesDetailStateCopyWith<SeriesDetailState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SeriesDetailStateCopyWith<$Res> {
  factory $SeriesDetailStateCopyWith(
          SeriesDetailState value, $Res Function(SeriesDetailState) then) =
      _$SeriesDetailStateCopyWithImpl<$Res, SeriesDetailState>;
  @useResult
  $Res call({SeriesModel series, TrackedMediaModel? tracking});

  $SeriesModelCopyWith<$Res> get series;
  $TrackedMediaModelCopyWith<$Res>? get tracking;
}

/// @nodoc
class _$SeriesDetailStateCopyWithImpl<$Res, $Val extends SeriesDetailState>
    implements $SeriesDetailStateCopyWith<$Res> {
  _$SeriesDetailStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SeriesDetailState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? series = null,
    Object? tracking = freezed,
  }) {
    return _then(_value.copyWith(
      series: null == series
          ? _value.series
          : series // ignore: cast_nullable_to_non_nullable
              as SeriesModel,
      tracking: freezed == tracking
          ? _value.tracking
          : tracking // ignore: cast_nullable_to_non_nullable
              as TrackedMediaModel?,
    ) as $Val);
  }

  /// Create a copy of SeriesDetailState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SeriesModelCopyWith<$Res> get series {
    return $SeriesModelCopyWith<$Res>(_value.series, (value) {
      return _then(_value.copyWith(series: value) as $Val);
    });
  }

  /// Create a copy of SeriesDetailState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TrackedMediaModelCopyWith<$Res>? get tracking {
    if (_value.tracking == null) {
      return null;
    }

    return $TrackedMediaModelCopyWith<$Res>(_value.tracking!, (value) {
      return _then(_value.copyWith(tracking: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SeriesDetailStateImplCopyWith<$Res>
    implements $SeriesDetailStateCopyWith<$Res> {
  factory _$$SeriesDetailStateImplCopyWith(_$SeriesDetailStateImpl value,
          $Res Function(_$SeriesDetailStateImpl) then) =
      __$$SeriesDetailStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({SeriesModel series, TrackedMediaModel? tracking});

  @override
  $SeriesModelCopyWith<$Res> get series;
  @override
  $TrackedMediaModelCopyWith<$Res>? get tracking;
}

/// @nodoc
class __$$SeriesDetailStateImplCopyWithImpl<$Res>
    extends _$SeriesDetailStateCopyWithImpl<$Res, _$SeriesDetailStateImpl>
    implements _$$SeriesDetailStateImplCopyWith<$Res> {
  __$$SeriesDetailStateImplCopyWithImpl(_$SeriesDetailStateImpl _value,
      $Res Function(_$SeriesDetailStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of SeriesDetailState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? series = null,
    Object? tracking = freezed,
  }) {
    return _then(_$SeriesDetailStateImpl(
      series: null == series
          ? _value.series
          : series // ignore: cast_nullable_to_non_nullable
              as SeriesModel,
      tracking: freezed == tracking
          ? _value.tracking
          : tracking // ignore: cast_nullable_to_non_nullable
              as TrackedMediaModel?,
    ));
  }
}

/// @nodoc

class _$SeriesDetailStateImpl implements _SeriesDetailState {
  const _$SeriesDetailStateImpl({required this.series, this.tracking});

  @override
  final SeriesModel series;
  @override
  final TrackedMediaModel? tracking;

  @override
  String toString() {
    return 'SeriesDetailState(series: $series, tracking: $tracking)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SeriesDetailStateImpl &&
            (identical(other.series, series) || other.series == series) &&
            (identical(other.tracking, tracking) ||
                other.tracking == tracking));
  }

  @override
  int get hashCode => Object.hash(runtimeType, series, tracking);

  /// Create a copy of SeriesDetailState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SeriesDetailStateImplCopyWith<_$SeriesDetailStateImpl> get copyWith =>
      __$$SeriesDetailStateImplCopyWithImpl<_$SeriesDetailStateImpl>(
          this, _$identity);
}

abstract class _SeriesDetailState implements SeriesDetailState {
  const factory _SeriesDetailState(
      {required final SeriesModel series,
      final TrackedMediaModel? tracking}) = _$SeriesDetailStateImpl;

  @override
  SeriesModel get series;
  @override
  TrackedMediaModel? get tracking;

  /// Create a copy of SeriesDetailState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SeriesDetailStateImplCopyWith<_$SeriesDetailStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
