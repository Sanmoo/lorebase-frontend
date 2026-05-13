// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracked_media_summary_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TrackedMediaSummaryModelImpl _$$TrackedMediaSummaryModelImplFromJson(
        Map<String, dynamic> json) =>
    _$TrackedMediaSummaryModelImpl(
      tmdbId: json['tmdbId'] as int,
      title: json['title'] as String,
      mediaType: mediaTypeFromJson(json['mediaType'] as String),
      posterPath: json['posterPath'] as String?,
      backdropPath: json['backdropPath'] as String?,
    );

Map<String, dynamic> _$$TrackedMediaSummaryModelImplToJson(
        _$TrackedMediaSummaryModelImpl instance) =>
    <String, dynamic>{
      'tmdbId': instance.tmdbId,
      'title': instance.title,
      'mediaType': mediaTypeToJson(instance.mediaType),
      'posterPath': instance.posterPath,
      'backdropPath': instance.backdropPath,
    };
