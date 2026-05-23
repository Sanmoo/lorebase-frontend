import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/utils/json_converters.dart';

part 'series_model.freezed.dart';
part 'series_model.g.dart';

@freezed
abstract class EpisodeAirInfoModel with _$EpisodeAirInfoModel {
  const factory EpisodeAirInfoModel({
    String? airDate,
    @Default(0) int episodeNumber,
    @Default(0) int seasonNumber,
    String? name,
    String? overview,
  }) = _EpisodeAirInfoModel;

  factory EpisodeAirInfoModel.fromJson(Map<String, dynamic> json) =>
      _$EpisodeAirInfoModelFromJson(json);
}

@freezed
abstract class SeriesModel with _$SeriesModel {
  const factory SeriesModel({
    @JsonKey(fromJson: flexibleIntFromJson, toJson: flexibleIntToJson)
    required int tmdbId,
    required String title,
    String? overview,
    String? posterPath,
    String? backdropPath,
    String? firstAirDate,
    @Default([]) List<String> genres,
    @Default([]) List<String> networks,
    @Default(0) int seasonCount,
    String? status,
    String? seriesId,
    String? createdAt,
    double? voteAverage,
    int? voteCount,
    double? popularity,
    @Default([]) List<String> originCountry,
    @Default([]) List<int> episodeRunTime,
    @Default(0) int numberOfEpisodes,
    @Default([]) List<String> createdBy,
    String? type,
    EpisodeAirInfoModel? lastEpisodeToAir,
    EpisodeAirInfoModel? nextEpisodeToAir,
  }) = _SeriesModel;

  factory SeriesModel.fromJson(Map<String, dynamic> json) =>
      _$SeriesModelFromJson(json);
}
