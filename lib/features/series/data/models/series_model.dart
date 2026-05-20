import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/utils/json_converters.dart';

part 'series_model.freezed.dart';
part 'series_model.g.dart';

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
  }) = _SeriesModel;

  factory SeriesModel.fromJson(Map<String, dynamic> json) =>
      _$SeriesModelFromJson(json);
}
