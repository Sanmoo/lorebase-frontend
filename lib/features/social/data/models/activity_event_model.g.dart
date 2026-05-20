// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_event_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ActivityEventModel _$ActivityEventModelFromJson(Map<String, dynamic> json) =>
    _ActivityEventModel(
      eventId: json['eventId'] as String,
      user: SocialUserModel.fromJson(json['user'] as Map<String, dynamic>),
      activityType: json['activityType'] as String,
      media: SocialMediaModel.fromJson(json['media'] as Map<String, dynamic>),
      metadata:
          json['metadata'] as Map<String, dynamic>? ??
          const <String, dynamic>{},
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ActivityEventModelToJson(_ActivityEventModel instance) =>
    <String, dynamic>{
      'eventId': instance.eventId,
      'user': instance.user,
      'activityType': instance.activityType,
      'media': instance.media,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
    };
