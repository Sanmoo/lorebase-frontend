// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_search_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BookSearchResponse _$BookSearchResponseFromJson(Map<String, dynamic> json) =>
    _BookSearchResponse(
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => BookModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      query: json['query'] as String? ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
    );

Map<String, dynamic> _$BookSearchResponseToJson(_BookSearchResponse instance) =>
    <String, dynamic>{
      'items': instance.items,
      'query': instance.query,
      'count': instance.count,
      'page': instance.page,
      'limit': instance.limit,
    };
