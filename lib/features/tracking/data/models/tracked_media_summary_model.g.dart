// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracked_media_summary_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TrackedMediaSummaryModelImpl _$$TrackedMediaSummaryModelImplFromJson(
        Map<String, dynamic> json) =>
    _$TrackedMediaSummaryModelImpl(
      mediaId: flexibleStringFromJson(json['tmdbId']),
      title: json['title'] as String,
      mediaType: _nullableMediaTypeFromJson(json['mediaType']),
      overview: json['overview'] as String?,
      posterPath: json['posterPath'] as String?,
      status: json['status'] as String?,
      trackingRating: json['trackingRating'] as int?,
      seasonCount: json['seasonCount'] as int?,
      addedAt: json['addedAt'] == null
          ? null
          : DateTime.parse(json['addedAt'] as String),
    );

Map<String, dynamic> _$$TrackedMediaSummaryModelImplToJson(
        _$TrackedMediaSummaryModelImpl instance) =>
    <String, dynamic>{
      'tmdbId': flexibleStringToJson(instance.mediaId),
      'title': instance.title,
      'mediaType': _nullableMediaTypeToJson(instance.mediaType),
      'overview': instance.overview,
      'posterPath': instance.posterPath,
      'status': instance.status,
      'trackingRating': instance.trackingRating,
      'seasonCount': instance.seasonCount,
      'addedAt': instance.addedAt?.toIso8601String(),
    };
