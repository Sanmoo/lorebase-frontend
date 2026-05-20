// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discover_user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DiscoverUserModel _$DiscoverUserModelFromJson(Map<String, dynamic> json) =>
    _DiscoverUserModel(
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      affinityScore: (json['affinityScore'] as num).toDouble(),
      commonGenres:
          (json['commonGenres'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      commonMedia:
          (json['commonMedia'] as List<dynamic>?)
              ?.map((e) => SocialMediaModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <SocialMediaModel>[],
      isFollowedByMe: json['isFollowedByMe'] as bool? ?? false,
    );

Map<String, dynamic> _$DiscoverUserModelToJson(_DiscoverUserModel instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'displayName': instance.displayName,
      'avatarUrl': instance.avatarUrl,
      'affinityScore': instance.affinityScore,
      'commonGenres': instance.commonGenres,
      'commonMedia': instance.commonMedia,
      'isFollowedByMe': instance.isFollowedByMe,
    };
