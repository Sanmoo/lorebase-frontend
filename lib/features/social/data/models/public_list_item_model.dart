import 'package:freezed_annotation/freezed_annotation.dart';

import 'social_media_model.dart';

part 'public_list_item_model.freezed.dart';
part 'public_list_item_model.g.dart';

@freezed
abstract class PublicListItemModel with _$PublicListItemModel {
  const factory PublicListItemModel({
    required String mediaId,
    required String mediaType,
    required String status,
    int? rating,
    String? review,
    SocialMediaModel? media,
    DateTime? updatedAt,
  }) = _PublicListItemModel;

  factory PublicListItemModel.fromJson(Map<String, dynamic> json) =>
      _$PublicListItemModelFromJson(json);
}
