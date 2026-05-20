// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_list_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PublicListItemModel _$PublicListItemModelFromJson(Map<String, dynamic> json) =>
    _PublicListItemModel(
      mediaId: json['mediaId'] as String,
      mediaType: json['mediaType'] as String,
      status: json['status'] as String,
      rating: (json['rating'] as num?)?.toInt(),
      review: json['review'] as String?,
      media: json['media'] == null
          ? null
          : SocialMediaModel.fromJson(json['media'] as Map<String, dynamic>),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PublicListItemModelToJson(
  _PublicListItemModel instance,
) => <String, dynamic>{
  'mediaId': instance.mediaId,
  'mediaType': instance.mediaType,
  'status': instance.status,
  'rating': instance.rating,
  'review': instance.review,
  'media': instance.media,
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
