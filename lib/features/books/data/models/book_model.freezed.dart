// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'book_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BookModel {

 String get bookId; String get title; List<String> get authors; String? get isbn; int? get pageCount; String? get coverUrl; String? get publisher; String? get publishedDate; String? get description; String? get genre;
/// Create a copy of BookModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookModelCopyWith<BookModel> get copyWith => _$BookModelCopyWithImpl<BookModel>(this as BookModel, _$identity);

  /// Serializes this BookModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookModel&&(identical(other.bookId, bookId) || other.bookId == bookId)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.authors, authors)&&(identical(other.isbn, isbn) || other.isbn == isbn)&&(identical(other.pageCount, pageCount) || other.pageCount == pageCount)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.publisher, publisher) || other.publisher == publisher)&&(identical(other.publishedDate, publishedDate) || other.publishedDate == publishedDate)&&(identical(other.description, description) || other.description == description)&&(identical(other.genre, genre) || other.genre == genre));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bookId,title,const DeepCollectionEquality().hash(authors),isbn,pageCount,coverUrl,publisher,publishedDate,description,genre);

@override
String toString() {
  return 'BookModel(bookId: $bookId, title: $title, authors: $authors, isbn: $isbn, pageCount: $pageCount, coverUrl: $coverUrl, publisher: $publisher, publishedDate: $publishedDate, description: $description, genre: $genre)';
}


}

/// @nodoc
abstract mixin class $BookModelCopyWith<$Res>  {
  factory $BookModelCopyWith(BookModel value, $Res Function(BookModel) _then) = _$BookModelCopyWithImpl;
@useResult
$Res call({
 String bookId, String title, List<String> authors, String? isbn, int? pageCount, String? coverUrl, String? publisher, String? publishedDate, String? description, String? genre
});




}
/// @nodoc
class _$BookModelCopyWithImpl<$Res>
    implements $BookModelCopyWith<$Res> {
  _$BookModelCopyWithImpl(this._self, this._then);

  final BookModel _self;
  final $Res Function(BookModel) _then;

/// Create a copy of BookModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bookId = null,Object? title = null,Object? authors = null,Object? isbn = freezed,Object? pageCount = freezed,Object? coverUrl = freezed,Object? publisher = freezed,Object? publishedDate = freezed,Object? description = freezed,Object? genre = freezed,}) {
  return _then(_self.copyWith(
bookId: null == bookId ? _self.bookId : bookId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,authors: null == authors ? _self.authors : authors // ignore: cast_nullable_to_non_nullable
as List<String>,isbn: freezed == isbn ? _self.isbn : isbn // ignore: cast_nullable_to_non_nullable
as String?,pageCount: freezed == pageCount ? _self.pageCount : pageCount // ignore: cast_nullable_to_non_nullable
as int?,coverUrl: freezed == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String?,publisher: freezed == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as String?,publishedDate: freezed == publishedDate ? _self.publishedDate : publishedDate // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,genre: freezed == genre ? _self.genre : genre // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BookModel].
extension BookModelPatterns on BookModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BookModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BookModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BookModel value)  $default,){
final _that = this;
switch (_that) {
case _BookModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BookModel value)?  $default,){
final _that = this;
switch (_that) {
case _BookModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String bookId,  String title,  List<String> authors,  String? isbn,  int? pageCount,  String? coverUrl,  String? publisher,  String? publishedDate,  String? description,  String? genre)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BookModel() when $default != null:
return $default(_that.bookId,_that.title,_that.authors,_that.isbn,_that.pageCount,_that.coverUrl,_that.publisher,_that.publishedDate,_that.description,_that.genre);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String bookId,  String title,  List<String> authors,  String? isbn,  int? pageCount,  String? coverUrl,  String? publisher,  String? publishedDate,  String? description,  String? genre)  $default,) {final _that = this;
switch (_that) {
case _BookModel():
return $default(_that.bookId,_that.title,_that.authors,_that.isbn,_that.pageCount,_that.coverUrl,_that.publisher,_that.publishedDate,_that.description,_that.genre);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String bookId,  String title,  List<String> authors,  String? isbn,  int? pageCount,  String? coverUrl,  String? publisher,  String? publishedDate,  String? description,  String? genre)?  $default,) {final _that = this;
switch (_that) {
case _BookModel() when $default != null:
return $default(_that.bookId,_that.title,_that.authors,_that.isbn,_that.pageCount,_that.coverUrl,_that.publisher,_that.publishedDate,_that.description,_that.genre);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BookModel implements BookModel {
  const _BookModel({required this.bookId, required this.title, final  List<String> authors = const [], this.isbn, this.pageCount, this.coverUrl, this.publisher, this.publishedDate, this.description, this.genre}): _authors = authors;
  factory _BookModel.fromJson(Map<String, dynamic> json) => _$BookModelFromJson(json);

@override final  String bookId;
@override final  String title;
 final  List<String> _authors;
@override@JsonKey() List<String> get authors {
  if (_authors is EqualUnmodifiableListView) return _authors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_authors);
}

@override final  String? isbn;
@override final  int? pageCount;
@override final  String? coverUrl;
@override final  String? publisher;
@override final  String? publishedDate;
@override final  String? description;
@override final  String? genre;

/// Create a copy of BookModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookModelCopyWith<_BookModel> get copyWith => __$BookModelCopyWithImpl<_BookModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BookModel&&(identical(other.bookId, bookId) || other.bookId == bookId)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other._authors, _authors)&&(identical(other.isbn, isbn) || other.isbn == isbn)&&(identical(other.pageCount, pageCount) || other.pageCount == pageCount)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.publisher, publisher) || other.publisher == publisher)&&(identical(other.publishedDate, publishedDate) || other.publishedDate == publishedDate)&&(identical(other.description, description) || other.description == description)&&(identical(other.genre, genre) || other.genre == genre));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bookId,title,const DeepCollectionEquality().hash(_authors),isbn,pageCount,coverUrl,publisher,publishedDate,description,genre);

@override
String toString() {
  return 'BookModel(bookId: $bookId, title: $title, authors: $authors, isbn: $isbn, pageCount: $pageCount, coverUrl: $coverUrl, publisher: $publisher, publishedDate: $publishedDate, description: $description, genre: $genre)';
}


}

/// @nodoc
abstract mixin class _$BookModelCopyWith<$Res> implements $BookModelCopyWith<$Res> {
  factory _$BookModelCopyWith(_BookModel value, $Res Function(_BookModel) _then) = __$BookModelCopyWithImpl;
@override @useResult
$Res call({
 String bookId, String title, List<String> authors, String? isbn, int? pageCount, String? coverUrl, String? publisher, String? publishedDate, String? description, String? genre
});




}
/// @nodoc
class __$BookModelCopyWithImpl<$Res>
    implements _$BookModelCopyWith<$Res> {
  __$BookModelCopyWithImpl(this._self, this._then);

  final _BookModel _self;
  final $Res Function(_BookModel) _then;

/// Create a copy of BookModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bookId = null,Object? title = null,Object? authors = null,Object? isbn = freezed,Object? pageCount = freezed,Object? coverUrl = freezed,Object? publisher = freezed,Object? publishedDate = freezed,Object? description = freezed,Object? genre = freezed,}) {
  return _then(_BookModel(
bookId: null == bookId ? _self.bookId : bookId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,authors: null == authors ? _self._authors : authors // ignore: cast_nullable_to_non_nullable
as List<String>,isbn: freezed == isbn ? _self.isbn : isbn // ignore: cast_nullable_to_non_nullable
as String?,pageCount: freezed == pageCount ? _self.pageCount : pageCount // ignore: cast_nullable_to_non_nullable
as int?,coverUrl: freezed == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String?,publisher: freezed == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as String?,publishedDate: freezed == publishedDate ? _self.publishedDate : publishedDate // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,genre: freezed == genre ? _self.genre : genre // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
