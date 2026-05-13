import 'package:freezed_annotation/freezed_annotation.dart';
import 'media_type.dart';

part 'tracked_media_summary_model.freezed.dart';
part 'tracked_media_summary_model.g.dart';

@freezed
class TrackedMediaSummaryModel with _$TrackedMediaSummaryModel {
  const factory TrackedMediaSummaryModel({
    required int tmdbId,
    required String title,
    @JsonKey(fromJson: mediaTypeFromJson, toJson: mediaTypeToJson)
    required MediaType mediaType,
    String? posterPath,
    String? backdropPath,
  }) = _TrackedMediaSummaryModel;

  factory TrackedMediaSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$TrackedMediaSummaryModelFromJson(json);
}
