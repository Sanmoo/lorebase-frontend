// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tracking_list_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TrackingListState {

 TrackingPage get page; bool get isLoadingMore; String? get loadMoreError;
/// Create a copy of TrackingListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrackingListStateCopyWith<TrackingListState> get copyWith => _$TrackingListStateCopyWithImpl<TrackingListState>(this as TrackingListState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrackingListState&&(identical(other.page, page) || other.page == page)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&(identical(other.loadMoreError, loadMoreError) || other.loadMoreError == loadMoreError));
}


@override
int get hashCode => Object.hash(runtimeType,page,isLoadingMore,loadMoreError);

@override
String toString() {
  return 'TrackingListState(page: $page, isLoadingMore: $isLoadingMore, loadMoreError: $loadMoreError)';
}


}

/// @nodoc
abstract mixin class $TrackingListStateCopyWith<$Res>  {
  factory $TrackingListStateCopyWith(TrackingListState value, $Res Function(TrackingListState) _then) = _$TrackingListStateCopyWithImpl;
@useResult
$Res call({
 TrackingPage page, bool isLoadingMore, String? loadMoreError
});


$TrackingPageCopyWith<$Res> get page;

}
/// @nodoc
class _$TrackingListStateCopyWithImpl<$Res>
    implements $TrackingListStateCopyWith<$Res> {
  _$TrackingListStateCopyWithImpl(this._self, this._then);

  final TrackingListState _self;
  final $Res Function(TrackingListState) _then;

/// Create a copy of TrackingListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? page = null,Object? isLoadingMore = null,Object? loadMoreError = freezed,}) {
  return _then(_self.copyWith(
page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as TrackingPage,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,loadMoreError: freezed == loadMoreError ? _self.loadMoreError : loadMoreError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of TrackingListState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TrackingPageCopyWith<$Res> get page {
  
  return $TrackingPageCopyWith<$Res>(_self.page, (value) {
    return _then(_self.copyWith(page: value));
  });
}
}


/// Adds pattern-matching-related methods to [TrackingListState].
extension TrackingListStatePatterns on TrackingListState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrackingListState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrackingListState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrackingListState value)  $default,){
final _that = this;
switch (_that) {
case _TrackingListState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrackingListState value)?  $default,){
final _that = this;
switch (_that) {
case _TrackingListState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TrackingPage page,  bool isLoadingMore,  String? loadMoreError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrackingListState() when $default != null:
return $default(_that.page,_that.isLoadingMore,_that.loadMoreError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TrackingPage page,  bool isLoadingMore,  String? loadMoreError)  $default,) {final _that = this;
switch (_that) {
case _TrackingListState():
return $default(_that.page,_that.isLoadingMore,_that.loadMoreError);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TrackingPage page,  bool isLoadingMore,  String? loadMoreError)?  $default,) {final _that = this;
switch (_that) {
case _TrackingListState() when $default != null:
return $default(_that.page,_that.isLoadingMore,_that.loadMoreError);case _:
  return null;

}
}

}

/// @nodoc


class _TrackingListState extends TrackingListState {
  const _TrackingListState({this.page = const TrackingPage(), this.isLoadingMore = false, this.loadMoreError}): super._();
  

@override@JsonKey() final  TrackingPage page;
@override@JsonKey() final  bool isLoadingMore;
@override final  String? loadMoreError;

/// Create a copy of TrackingListState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrackingListStateCopyWith<_TrackingListState> get copyWith => __$TrackingListStateCopyWithImpl<_TrackingListState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrackingListState&&(identical(other.page, page) || other.page == page)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&(identical(other.loadMoreError, loadMoreError) || other.loadMoreError == loadMoreError));
}


@override
int get hashCode => Object.hash(runtimeType,page,isLoadingMore,loadMoreError);

@override
String toString() {
  return 'TrackingListState(page: $page, isLoadingMore: $isLoadingMore, loadMoreError: $loadMoreError)';
}


}

/// @nodoc
abstract mixin class _$TrackingListStateCopyWith<$Res> implements $TrackingListStateCopyWith<$Res> {
  factory _$TrackingListStateCopyWith(_TrackingListState value, $Res Function(_TrackingListState) _then) = __$TrackingListStateCopyWithImpl;
@override @useResult
$Res call({
 TrackingPage page, bool isLoadingMore, String? loadMoreError
});


@override $TrackingPageCopyWith<$Res> get page;

}
/// @nodoc
class __$TrackingListStateCopyWithImpl<$Res>
    implements _$TrackingListStateCopyWith<$Res> {
  __$TrackingListStateCopyWithImpl(this._self, this._then);

  final _TrackingListState _self;
  final $Res Function(_TrackingListState) _then;

/// Create a copy of TrackingListState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? page = null,Object? isLoadingMore = null,Object? loadMoreError = freezed,}) {
  return _then(_TrackingListState(
page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as TrackingPage,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,loadMoreError: freezed == loadMoreError ? _self.loadMoreError : loadMoreError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of TrackingListState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TrackingPageCopyWith<$Res> get page {
  
  return $TrackingPageCopyWith<$Res>(_self.page, (value) {
    return _then(_self.copyWith(page: value));
  });
}
}

// dart format on
