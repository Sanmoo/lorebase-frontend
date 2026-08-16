// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'book_search_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BookSearchResponse {

 List<BookModel> get items; String get query; int get count; int get page; int get limit;
/// Create a copy of BookSearchResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookSearchResponseCopyWith<BookSearchResponse> get copyWith => _$BookSearchResponseCopyWithImpl<BookSearchResponse>(this as BookSearchResponse, _$identity);

  /// Serializes this BookSearchResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookSearchResponse&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.query, query) || other.query == query)&&(identical(other.count, count) || other.count == count)&&(identical(other.page, page) || other.page == page)&&(identical(other.limit, limit) || other.limit == limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),query,count,page,limit);

@override
String toString() {
  return 'BookSearchResponse(items: $items, query: $query, count: $count, page: $page, limit: $limit)';
}


}

/// @nodoc
abstract mixin class $BookSearchResponseCopyWith<$Res>  {
  factory $BookSearchResponseCopyWith(BookSearchResponse value, $Res Function(BookSearchResponse) _then) = _$BookSearchResponseCopyWithImpl;
@useResult
$Res call({
 List<BookModel> items, String query, int count, int page, int limit
});




}
/// @nodoc
class _$BookSearchResponseCopyWithImpl<$Res>
    implements $BookSearchResponseCopyWith<$Res> {
  _$BookSearchResponseCopyWithImpl(this._self, this._then);

  final BookSearchResponse _self;
  final $Res Function(BookSearchResponse) _then;

/// Create a copy of BookSearchResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? query = null,Object? count = null,Object? page = null,Object? limit = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<BookModel>,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [BookSearchResponse].
extension BookSearchResponsePatterns on BookSearchResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BookSearchResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BookSearchResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BookSearchResponse value)  $default,){
final _that = this;
switch (_that) {
case _BookSearchResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BookSearchResponse value)?  $default,){
final _that = this;
switch (_that) {
case _BookSearchResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<BookModel> items,  String query,  int count,  int page,  int limit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BookSearchResponse() when $default != null:
return $default(_that.items,_that.query,_that.count,_that.page,_that.limit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<BookModel> items,  String query,  int count,  int page,  int limit)  $default,) {final _that = this;
switch (_that) {
case _BookSearchResponse():
return $default(_that.items,_that.query,_that.count,_that.page,_that.limit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<BookModel> items,  String query,  int count,  int page,  int limit)?  $default,) {final _that = this;
switch (_that) {
case _BookSearchResponse() when $default != null:
return $default(_that.items,_that.query,_that.count,_that.page,_that.limit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BookSearchResponse implements BookSearchResponse {
  const _BookSearchResponse({final  List<BookModel> items = const [], this.query = '', this.count = 0, this.page = 1, this.limit = 20}): _items = items;
  factory _BookSearchResponse.fromJson(Map<String, dynamic> json) => _$BookSearchResponseFromJson(json);

 final  List<BookModel> _items;
@override@JsonKey() List<BookModel> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  String query;
@override@JsonKey() final  int count;
@override@JsonKey() final  int page;
@override@JsonKey() final  int limit;

/// Create a copy of BookSearchResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookSearchResponseCopyWith<_BookSearchResponse> get copyWith => __$BookSearchResponseCopyWithImpl<_BookSearchResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookSearchResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BookSearchResponse&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.query, query) || other.query == query)&&(identical(other.count, count) || other.count == count)&&(identical(other.page, page) || other.page == page)&&(identical(other.limit, limit) || other.limit == limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),query,count,page,limit);

@override
String toString() {
  return 'BookSearchResponse(items: $items, query: $query, count: $count, page: $page, limit: $limit)';
}


}

/// @nodoc
abstract mixin class _$BookSearchResponseCopyWith<$Res> implements $BookSearchResponseCopyWith<$Res> {
  factory _$BookSearchResponseCopyWith(_BookSearchResponse value, $Res Function(_BookSearchResponse) _then) = __$BookSearchResponseCopyWithImpl;
@override @useResult
$Res call({
 List<BookModel> items, String query, int count, int page, int limit
});




}
/// @nodoc
class __$BookSearchResponseCopyWithImpl<$Res>
    implements _$BookSearchResponseCopyWith<$Res> {
  __$BookSearchResponseCopyWithImpl(this._self, this._then);

  final _BookSearchResponse _self;
  final $Res Function(_BookSearchResponse) _then;

/// Create a copy of BookSearchResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? query = null,Object? count = null,Object? page = null,Object? limit = null,}) {
  return _then(_BookSearchResponse(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<BookModel>,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
