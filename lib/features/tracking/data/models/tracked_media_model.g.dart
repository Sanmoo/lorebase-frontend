// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracked_media_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TrackedMediaModel _$TrackedMediaModelFromJson(Map<String, dynamic> json) =>
    _TrackedMediaModel(
      trackingId: json['trackingId'] as String,
      userId: json['userId'] as String,
      mediaType: mediaTypeFromJson(json['mediaType'] as String),
      mediaId: json['mediaId'] as String,
      status: json['status'] as String,
      rating: (json['rating'] as num?)?.toInt(),
      review: json['review'] as String?,
      selectedPlatform: json['selectedPlatform'] as String?,
      hoursPlayed: (json['hoursPlayed'] as num?)?.toDouble(),
      seasonRatings:
          (json['seasonRatings'] as List<dynamic>?)
              ?.map(
                (e) => SeasonRatingModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      media: json['media'] == null
          ? null
          : TrackedMediaSummaryModel.fromJson(
              json['media'] as Map<String, dynamic>,
            ),
      addedAt: DateTime.parse(json['addedAt'] as String),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$TrackedMediaModelToJson(_TrackedMediaModel instance) =>
    <String, dynamic>{
      'trackingId': instance.trackingId,
      'userId': instance.userId,
      'mediaType': mediaTypeToJson(instance.mediaType),
      'mediaId': instance.mediaId,
      'status': instance.status,
      'rating': instance.rating,
      'review': instance.review,
      'selectedPlatform': instance.selectedPlatform,
      'hoursPlayed': instance.hoursPlayed,
      'seasonRatings': instance.seasonRatings,
      'media': instance.media,
      'addedAt': instance.addedAt.toIso8601String(),
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };
