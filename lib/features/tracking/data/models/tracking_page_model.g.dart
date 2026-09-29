// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_page_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TrackingPage _$TrackingPageFromJson(Map<String, dynamic> json) =>
    _TrackingPage(
      items:
          (json['items'] as List<dynamic>?)
              ?.map(
                (e) => TrackedMediaModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      nextCursor: json['nextCursor'] as String?,
      totalCount: (json['totalCount'] as num?)?.toInt(),
      page: (json['page'] as num?)?.toInt(),
      pageSize: (json['pageSize'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TrackingPageToJson(_TrackingPage instance) =>
    <String, dynamic>{
      'items': instance.items.map((e) => e.toJson()).toList(),
      'nextCursor': instance.nextCursor,
      'totalCount': instance.totalCount,
      'page': instance.page,
      'pageSize': instance.pageSize,
    };
