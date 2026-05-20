// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracked_media_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TrackedMediaModelImpl _$$TrackedMediaModelImplFromJson(
  Map<String, dynamic> json,
) => _$TrackedMediaModelImpl(
  trackingId: json['trackingId'] as String,
  userId: json['userId'] as String,
  mediaType: mediaTypeFromJson(json['mediaType'] as String),
  mediaId: json['mediaId'] as String,
  status: json['status'] as String,
  rating: (json['rating'] as num?)?.toInt(),
  review: json['review'] as String?,
  seasonRatings:
      (json['seasonRatings'] as List<dynamic>?)
          ?.map((e) => SeasonRatingModel.fromJson(e as Map<String, dynamic>))
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

Map<String, dynamic> _$$TrackedMediaModelImplToJson(
  _$TrackedMediaModelImpl instance,
) => <String, dynamic>{
  'trackingId': instance.trackingId,
  'userId': instance.userId,
  'mediaType': mediaTypeToJson(instance.mediaType),
  'mediaId': instance.mediaId,
  'status': instance.status,
  'rating': instance.rating,
  'review': instance.review,
  'seasonRatings': instance.seasonRatings,
  'media': instance.media,
  'addedAt': instance.addedAt.toIso8601String(),
  'lastUpdated': instance.lastUpdated.toIso8601String(),
};
