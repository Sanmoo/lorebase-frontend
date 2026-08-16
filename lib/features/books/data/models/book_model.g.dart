// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BookModel _$BookModelFromJson(Map<String, dynamic> json) => _BookModel(
  bookId: json['bookId'] as String,
  title: json['title'] as String,
  authors:
      (json['authors'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  isbn: json['isbn'] as String?,
  pageCount: (json['pageCount'] as num?)?.toInt(),
  coverUrl: json['coverUrl'] as String?,
  publisher: json['publisher'] as String?,
  publishedDate: json['publishedDate'] as String?,
  description: json['description'] as String?,
  genre: json['genre'] as String?,
);

Map<String, dynamic> _$BookModelToJson(_BookModel instance) =>
    <String, dynamic>{
      'bookId': instance.bookId,
      'title': instance.title,
      'authors': instance.authors,
      'isbn': instance.isbn,
      'pageCount': instance.pageCount,
      'coverUrl': instance.coverUrl,
      'publisher': instance.publisher,
      'publishedDate': instance.publishedDate,
      'description': instance.description,
      'genre': instance.genre,
    };
