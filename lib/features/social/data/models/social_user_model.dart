import 'package:freezed_annotation/freezed_annotation.dart';

part 'social_user_model.freezed.dart';
part 'social_user_model.g.dart';

@freezed
abstract class SocialUserModel with _$SocialUserModel {
  const factory SocialUserModel({
    required String userId,
    required String displayName,
    String? avatarUrl,
  }) = _SocialUserModel;

  factory SocialUserModel.fromJson(Map<String, dynamic> json) =>
      _$SocialUserModelFromJson(json);
}
