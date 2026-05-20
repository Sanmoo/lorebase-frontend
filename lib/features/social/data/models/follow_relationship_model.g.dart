// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'follow_relationship_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FollowRelationshipModel _$FollowRelationshipModelFromJson(
  Map<String, dynamic> json,
) => _FollowRelationshipModel(
  followerId: json['followerId'] as String?,
  followedId: json['followedId'] as String?,
  followedAt: json['followedAt'] == null
      ? null
      : DateTime.parse(json['followedAt'] as String),
);

Map<String, dynamic> _$FollowRelationshipModelToJson(
  _FollowRelationshipModel instance,
) => <String, dynamic>{
  'followerId': instance.followerId,
  'followedId': instance.followedId,
  'followedAt': instance.followedAt?.toIso8601String(),
};
