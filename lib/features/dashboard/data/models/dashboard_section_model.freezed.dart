// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_section_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DashboardSectionModel _$DashboardSectionModelFromJson(
    Map<String, dynamic> json) {
  return _DashboardSectionModel.fromJson(json);
}

/// @nodoc
mixin _$DashboardSectionModel {
  List<TrackedMediaSummaryModel> get items =>
      throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;
  bool get hasMore => throw _privateConstructorUsedError;

  /// Serializes this DashboardSectionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DashboardSectionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DashboardSectionModelCopyWith<DashboardSectionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DashboardSectionModelCopyWith<$Res> {
  factory $DashboardSectionModelCopyWith(DashboardSectionModel value,
          $Res Function(DashboardSectionModel) then) =
      _$DashboardSectionModelCopyWithImpl<$Res, DashboardSectionModel>;
  @useResult
  $Res call({List<TrackedMediaSummaryModel> items, int total, bool hasMore});
}

/// @nodoc
class _$DashboardSectionModelCopyWithImpl<$Res,
        $Val extends DashboardSectionModel>
    implements $DashboardSectionModelCopyWith<$Res> {
  _$DashboardSectionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DashboardSectionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? total = null,
    Object? hasMore = null,
  }) {
    return _then(_value.copyWith(
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<TrackedMediaSummaryModel>,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DashboardSectionModelImplCopyWith<$Res>
    implements $DashboardSectionModelCopyWith<$Res> {
  factory _$$DashboardSectionModelImplCopyWith(
          _$DashboardSectionModelImpl value,
          $Res Function(_$DashboardSectionModelImpl) then) =
      __$$DashboardSectionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<TrackedMediaSummaryModel> items, int total, bool hasMore});
}

/// @nodoc
class __$$DashboardSectionModelImplCopyWithImpl<$Res>
    extends _$DashboardSectionModelCopyWithImpl<$Res,
        _$DashboardSectionModelImpl>
    implements _$$DashboardSectionModelImplCopyWith<$Res> {
  __$$DashboardSectionModelImplCopyWithImpl(_$DashboardSectionModelImpl _value,
      $Res Function(_$DashboardSectionModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of DashboardSectionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? total = null,
    Object? hasMore = null,
  }) {
    return _then(_$DashboardSectionModelImpl(
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<TrackedMediaSummaryModel>,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DashboardSectionModelImpl implements _DashboardSectionModel {
  const _$DashboardSectionModelImpl(
      {final List<TrackedMediaSummaryModel> items = const [],
      this.total = 0,
      this.hasMore = false})
      : _items = items;

  factory _$DashboardSectionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DashboardSectionModelImplFromJson(json);

  final List<TrackedMediaSummaryModel> _items;
  @override
  @JsonKey()
  List<TrackedMediaSummaryModel> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  @JsonKey()
  final int total;
  @override
  @JsonKey()
  final bool hasMore;

  @override
  String toString() {
    return 'DashboardSectionModel(items: $items, total: $total, hasMore: $hasMore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DashboardSectionModelImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_items), total, hasMore);

  /// Create a copy of DashboardSectionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DashboardSectionModelImplCopyWith<_$DashboardSectionModelImpl>
      get copyWith => __$$DashboardSectionModelImplCopyWithImpl<
          _$DashboardSectionModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DashboardSectionModelImplToJson(
      this,
    );
  }
}

abstract class _DashboardSectionModel implements DashboardSectionModel {
  const factory _DashboardSectionModel(
      {final List<TrackedMediaSummaryModel> items,
      final int total,
      final bool hasMore}) = _$DashboardSectionModelImpl;

  factory _DashboardSectionModel.fromJson(Map<String, dynamic> json) =
      _$DashboardSectionModelImpl.fromJson;

  @override
  List<TrackedMediaSummaryModel> get items;
  @override
  int get total;
  @override
  bool get hasMore;

  /// Create a copy of DashboardSectionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DashboardSectionModelImplCopyWith<_$DashboardSectionModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
