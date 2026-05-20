import 'package:freezed_annotation/freezed_annotation.dart';

part 'social_media_model.freezed.dart';
part 'social_media_model.g.dart';

@freezed
abstract class SocialMediaModel with _$SocialMediaModel {
  const factory SocialMediaModel({
    required String mediaId,
    required String mediaType,
    required String title,
    String? posterUrl,
  }) = _SocialMediaModel;

  factory SocialMediaModel.fromJson(Map<String, dynamic> json) =>
      _$SocialMediaModelFromJson(json);
}
