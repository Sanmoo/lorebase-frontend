// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tracking_page_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TrackingPage {

 List<TrackedMediaModel> get items; String? get nextCursor; int? get totalCount; int? get page; int? get pageSize;
/// Create a copy of TrackingPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrackingPageCopyWith<TrackingPage> get copyWith => _$TrackingPageCopyWithImpl<TrackingPage>(this as TrackingPage, _$identity);

  /// Serializes this TrackingPage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrackingPage&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.page, page) || other.page == page)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),nextCursor,totalCount,page,pageSize);

@override
String toString() {
  return 'TrackingPage(items: $items, nextCursor: $nextCursor, totalCount: $totalCount, page: $page, pageSize: $pageSize)';
}


}

/// @nodoc
abstract mixin class $TrackingPageCopyWith<$Res>  {
  factory $TrackingPageCopyWith(TrackingPage value, $Res Function(TrackingPage) _then) = _$TrackingPageCopyWithImpl;
@useResult
$Res call({
 List<TrackedMediaModel> items, String? nextCursor, int? totalCount, int? page, int? pageSize
});




}
/// @nodoc
class _$TrackingPageCopyWithImpl<$Res>
    implements $TrackingPageCopyWith<$Res> {
  _$TrackingPageCopyWithImpl(this._self, this._then);

  final TrackingPage _self;
  final $Res Function(TrackingPage) _then;

/// Create a copy of TrackingPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? nextCursor = freezed,Object? totalCount = freezed,Object? page = freezed,Object? pageSize = freezed,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<TrackedMediaModel>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,totalCount: freezed == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int?,page: freezed == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int?,pageSize: freezed == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [TrackingPage].
extension TrackingPagePatterns on TrackingPage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrackingPage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrackingPage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrackingPage value)  $default,){
final _that = this;
switch (_that) {
case _TrackingPage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrackingPage value)?  $default,){
final _that = this;
switch (_that) {
case _TrackingPage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<TrackedMediaModel> items,  String? nextCursor,  int? totalCount,  int? page,  int? pageSize)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrackingPage() when $default != null:
return $default(_that.items,_that.nextCursor,_that.totalCount,_that.page,_that.pageSize);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<TrackedMediaModel> items,  String? nextCursor,  int? totalCount,  int? page,  int? pageSize)  $default,) {final _that = this;
switch (_that) {
case _TrackingPage():
return $default(_that.items,_that.nextCursor,_that.totalCount,_that.page,_that.pageSize);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<TrackedMediaModel> items,  String? nextCursor,  int? totalCount,  int? page,  int? pageSize)?  $default,) {final _that = this;
switch (_that) {
case _TrackingPage() when $default != null:
return $default(_that.items,_that.nextCursor,_that.totalCount,_that.page,_that.pageSize);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _TrackingPage implements TrackingPage {
  const _TrackingPage({final  List<TrackedMediaModel> items = const [], this.nextCursor, this.totalCount, this.page, this.pageSize}): _items = items;
  factory _TrackingPage.fromJson(Map<String, dynamic> json) => _$TrackingPageFromJson(json);

 final  List<TrackedMediaModel> _items;
@override@JsonKey() List<TrackedMediaModel> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  String? nextCursor;
@override final  int? totalCount;
@override final  int? page;
@override final  int? pageSize;

/// Create a copy of TrackingPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrackingPageCopyWith<_TrackingPage> get copyWith => __$TrackingPageCopyWithImpl<_TrackingPage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrackingPageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrackingPage&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.page, page) || other.page == page)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),nextCursor,totalCount,page,pageSize);

@override
String toString() {
  return 'TrackingPage(items: $items, nextCursor: $nextCursor, totalCount: $totalCount, page: $page, pageSize: $pageSize)';
}


}

/// @nodoc
abstract mixin class _$TrackingPageCopyWith<$Res> implements $TrackingPageCopyWith<$Res> {
  factory _$TrackingPageCopyWith(_TrackingPage value, $Res Function(_TrackingPage) _then) = __$TrackingPageCopyWithImpl;
@override @useResult
$Res call({
 List<TrackedMediaModel> items, String? nextCursor, int? totalCount, int? page, int? pageSize
});




}
/// @nodoc
class __$TrackingPageCopyWithImpl<$Res>
    implements _$TrackingPageCopyWith<$Res> {
  __$TrackingPageCopyWithImpl(this._self, this._then);

  final _TrackingPage _self;
  final $Res Function(_TrackingPage) _then;

/// Create a copy of TrackingPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? nextCursor = freezed,Object? totalCount = freezed,Object? page = freezed,Object? pageSize = freezed,}) {
  return _then(_TrackingPage(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<TrackedMediaModel>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,totalCount: freezed == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int?,page: freezed == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int?,pageSize: freezed == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
