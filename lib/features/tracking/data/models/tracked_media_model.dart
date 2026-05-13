import 'package:freezed_annotation/freezed_annotation.dart';
import 'media_type.dart';
import 'season_rating_model.dart';
import 'tracked_media_summary_model.dart';

part 'tracked_media_model.freezed.dart';
part 'tracked_media_model.g.dart';

@freezed
class TrackedMediaModel with _$TrackedMediaModel {
  const factory TrackedMediaModel({
    required String trackingId,
    required String userId,
    @JsonKey(fromJson: mediaTypeFromJson, toJson: mediaTypeToJson)
    required MediaType mediaType,
    required String mediaId,
    required String status,
    int? rating,
    String? review,
    @Default([]) List<SeasonRatingModel> seasonRatings,
    TrackedMediaSummaryModel? media,
    required DateTime addedAt,
    required DateTime lastUpdated,
  }) = _TrackedMediaModel;

  factory TrackedMediaModel.fromJson(Map<String, dynamic> json) =>
      _$TrackedMediaModelFromJson(json);
}
