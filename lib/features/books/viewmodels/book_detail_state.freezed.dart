// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'book_detail_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BookDetailState {

 BookModel get book;
/// Create a copy of BookDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookDetailStateCopyWith<BookDetailState> get copyWith => _$BookDetailStateCopyWithImpl<BookDetailState>(this as BookDetailState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookDetailState&&(identical(other.book, book) || other.book == book));
}


@override
int get hashCode => Object.hash(runtimeType,book);

@override
String toString() {
  return 'BookDetailState(book: $book)';
}


}

/// @nodoc
abstract mixin class $BookDetailStateCopyWith<$Res>  {
  factory $BookDetailStateCopyWith(BookDetailState value, $Res Function(BookDetailState) _then) = _$BookDetailStateCopyWithImpl;
@useResult
$Res call({
 BookModel book
});


$BookModelCopyWith<$Res> get book;

}
/// @nodoc
class _$BookDetailStateCopyWithImpl<$Res>
    implements $BookDetailStateCopyWith<$Res> {
  _$BookDetailStateCopyWithImpl(this._self, this._then);

  final BookDetailState _self;
  final $Res Function(BookDetailState) _then;

/// Create a copy of BookDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? book = null,}) {
  return _then(_self.copyWith(
book: null == book ? _self.book : book // ignore: cast_nullable_to_non_nullable
as BookModel,
  ));
}
/// Create a copy of BookDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BookModelCopyWith<$Res> get book {
  
  return $BookModelCopyWith<$Res>(_self.book, (value) {
    return _then(_self.copyWith(book: value));
  });
}
}


/// Adds pattern-matching-related methods to [BookDetailState].
extension BookDetailStatePatterns on BookDetailState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BookDetailState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BookDetailState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BookDetailState value)  $default,){
final _that = this;
switch (_that) {
case _BookDetailState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BookDetailState value)?  $default,){
final _that = this;
switch (_that) {
case _BookDetailState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( BookModel book)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BookDetailState() when $default != null:
return $default(_that.book);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( BookModel book)  $default,) {final _that = this;
switch (_that) {
case _BookDetailState():
return $default(_that.book);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( BookModel book)?  $default,) {final _that = this;
switch (_that) {
case _BookDetailState() when $default != null:
return $default(_that.book);case _:
  return null;

}
}

}

/// @nodoc


class _BookDetailState implements BookDetailState {
  const _BookDetailState({required this.book});
  

@override final  BookModel book;

/// Create a copy of BookDetailState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookDetailStateCopyWith<_BookDetailState> get copyWith => __$BookDetailStateCopyWithImpl<_BookDetailState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BookDetailState&&(identical(other.book, book) || other.book == book));
}


@override
int get hashCode => Object.hash(runtimeType,book);

@override
String toString() {
  return 'BookDetailState(book: $book)';
}


}

/// @nodoc
abstract mixin class _$BookDetailStateCopyWith<$Res> implements $BookDetailStateCopyWith<$Res> {
  factory _$BookDetailStateCopyWith(_BookDetailState value, $Res Function(_BookDetailState) _then) = __$BookDetailStateCopyWithImpl;
@override @useResult
$Res call({
 BookModel book
});


@override $BookModelCopyWith<$Res> get book;

}
/// @nodoc
class __$BookDetailStateCopyWithImpl<$Res>
    implements _$BookDetailStateCopyWith<$Res> {
  __$BookDetailStateCopyWithImpl(this._self, this._then);

  final _BookDetailState _self;
  final $Res Function(_BookDetailState) _then;

/// Create a copy of BookDetailState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? book = null,}) {
  return _then(_BookDetailState(
book: null == book ? _self.book : book // ignore: cast_nullable_to_non_nullable
as BookModel,
  ));
}

/// Create a copy of BookDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BookModelCopyWith<$Res> get book {
  
  return $BookModelCopyWith<$Res>(_self.book, (value) {
    return _then(_self.copyWith(book: value));
  });
}
}

// dart format on
