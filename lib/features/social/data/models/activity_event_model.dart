import 'package:freezed_annotation/freezed_annotation.dart';

import 'social_media_model.dart';
import 'social_user_model.dart';

part 'activity_event_model.freezed.dart';
part 'activity_event_model.g.dart';

@freezed
abstract class ActivityEventModel with _$ActivityEventModel {
  const factory ActivityEventModel({
    required String eventId,
    required SocialUserModel user,
    required String activityType,
    required SocialMediaModel media,
    @Default(<String, dynamic>{}) Map<String, dynamic> metadata,
    required DateTime createdAt,
  }) = _ActivityEventModel;

  factory ActivityEventModel.fromJson(Map<String, dynamic> json) =>
      _$ActivityEventModelFromJson(json);
}
