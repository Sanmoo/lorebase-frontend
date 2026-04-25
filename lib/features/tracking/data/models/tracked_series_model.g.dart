// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracked_series_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TrackedSeriesModelImpl _$$TrackedSeriesModelImplFromJson(
        Map<String, dynamic> json) =>
    _$TrackedSeriesModelImpl(
      trackingId: json['trackingId'] as String,
      userId: json['userId'] as String,
      seriesId: json['seriesId'] as String,
      status: json['status'] as String,
      seriesRating: json['seriesRating'] as int?,
      seriesReview: json['seriesReview'] as String?,
      seasonRatings: (json['seasonRatings'] as List<dynamic>?)
              ?.map(
                  (e) => SeasonRatingModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      series: json['series'] == null
          ? null
          : SeriesModel.fromJson(json['series'] as Map<String, dynamic>),
      addedAt: DateTime.parse(json['addedAt'] as String),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$$TrackedSeriesModelImplToJson(
        _$TrackedSeriesModelImpl instance) =>
    <String, dynamic>{
      'trackingId': instance.trackingId,
      'userId': instance.userId,
      'seriesId': instance.seriesId,
      'status': instance.status,
      'seriesRating': instance.seriesRating,
      'seriesReview': instance.seriesReview,
      'seasonRatings': instance.seasonRatings,
      'series': instance.series,
      'addedAt': instance.addedAt.toIso8601String(),
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };
