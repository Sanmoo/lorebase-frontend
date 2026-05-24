// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'follow_relationship_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FollowRelationshipModel _$FollowRelationshipModelFromJson(
  Map<String, dynamic> json,
) => _FollowRelationshipModel(
  userId: json['userId'] as String,
  username: json['username'] as String?,
  displayName: json['displayName'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  isFollowing: json['isFollowing'] as bool,
);

Map<String, dynamic> _$FollowRelationshipModelToJson(
  _FollowRelationshipModel instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'username': instance.username,
  'displayName': instance.displayName,
  'avatarUrl': instance.avatarUrl,
  'isFollowing': instance.isFollowing,
};
