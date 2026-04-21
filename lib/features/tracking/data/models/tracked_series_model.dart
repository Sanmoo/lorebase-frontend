import 'package:freezed_annotation/freezed_annotation.dart';
import 'season_rating_model.dart';

part 'tracked_series_model.freezed.dart';
part 'tracked_series_model.g.dart';

@freezed
class TrackedSeriesModel with _$TrackedSeriesModel {
  const factory TrackedSeriesModel({
    required String trackingId,
    required String userId,
    required String seriesId,
    required String status,
    int? seriesRating,
    String? seriesReview,
    @Default([]) List<SeasonRatingModel> seasonRatings,
    required DateTime addedAt,
    required DateTime lastUpdated,
  }) = _TrackedSeriesModel;

  factory TrackedSeriesModel.fromJson(Map<String, dynamic> json) =>
      _$TrackedSeriesModelFromJson(json);
}
