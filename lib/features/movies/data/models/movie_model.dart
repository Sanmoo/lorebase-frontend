import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/utils/json_converters.dart';

part 'movie_model.freezed.dart';
part 'movie_model.g.dart';

Object? _readRuntimeMinutes(Map<dynamic, dynamic> json, String key) =>
    json[key] ?? json['runtime'];

@freezed
class MovieModel with _$MovieModel {
  const factory MovieModel({
    @JsonKey(fromJson: flexibleIntFromJson, toJson: flexibleIntToJson)
    required int tmdbId,
    required String title,
    String? overview,
    String? posterPath,
    String? backdropPath,
    String? releaseDate,
    @Default([]) List<String> genres,
    @JsonKey(
      readValue: _readRuntimeMinutes,
      fromJson: flexibleNullableIntFromJson,
      toJson: flexibleNullableIntToJson,
    )
    int? runtimeMinutes,
    String? status,
  }) = _MovieModel;

  factory MovieModel.fromJson(Map<String, dynamic> json) =>
      _$MovieModelFromJson(json);
}
