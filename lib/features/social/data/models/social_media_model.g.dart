// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_media_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SocialMediaModel _$SocialMediaModelFromJson(Map<String, dynamic> json) =>
    _SocialMediaModel(
      mediaId: json['mediaId'] as String,
      mediaType: json['mediaType'] as String,
      title: json['title'] as String,
      posterUrl: json['posterUrl'] as String?,
    );

Map<String, dynamic> _$SocialMediaModelToJson(_SocialMediaModel instance) =>
    <String, dynamic>{
      'mediaId': instance.mediaId,
      'mediaType': instance.mediaType,
      'title': instance.title,
      'posterUrl': instance.posterUrl,
    };
