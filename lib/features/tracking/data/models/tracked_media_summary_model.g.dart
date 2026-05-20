// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracked_media_summary_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TrackedMediaSummaryModel _$TrackedMediaSummaryModelFromJson(
  Map<String, dynamic> json,
) => _TrackedMediaSummaryModel(
  mediaId: json['mediaId'] == null
      ? ''
      : flexibleStringFromJson(json['mediaId']),
  title: json['title'] as String,
  mediaType: _nullableMediaTypeFromJson(json['mediaType']),
  overview: json['overview'] as String?,
  posterPath: json['posterPath'] as String?,
  status: json['status'] as String?,
  trackingRating: (json['trackingRating'] as num?)?.toInt(),
  seasonCount: (json['seasonCount'] as num?)?.toInt(),
  addedAt: json['addedAt'] == null
      ? null
      : DateTime.parse(json['addedAt'] as String),
);

Map<String, dynamic> _$TrackedMediaSummaryModelToJson(
  _TrackedMediaSummaryModel instance,
) => <String, dynamic>{
  'mediaId': flexibleStringToJson(instance.mediaId),
  'title': instance.title,
  'mediaType': _nullableMediaTypeToJson(instance.mediaType),
  'overview': instance.overview,
  'posterPath': instance.posterPath,
  'status': instance.status,
  'trackingRating': instance.trackingRating,
  'seasonCount': instance.seasonCount,
  'addedAt': instance.addedAt?.toIso8601String(),
};
