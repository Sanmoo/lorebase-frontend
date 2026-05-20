// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SocialProfileModel _$SocialProfileModelFromJson(Map<String, dynamic> json) =>
    _SocialProfileModel(
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      isPublic: json['isPublic'] as bool,
      followingCount: (json['followingCount'] as num).toInt(),
      followerCount: (json['followerCount'] as num).toInt(),
      isFollowedByMe: json['isFollowedByMe'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$SocialProfileModelToJson(_SocialProfileModel instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'displayName': instance.displayName,
      'avatarUrl': instance.avatarUrl,
      'isPublic': instance.isPublic,
      'followingCount': instance.followingCount,
      'followerCount': instance.followerCount,
      'isFollowedByMe': instance.isFollowedByMe,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
