import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/utils/json_converters.dart';

part 'movie_model.freezed.dart';
part 'movie_model.g.dart';

Object? _readRuntimeMinutes(Map<dynamic, dynamic> json, String key) =>
    json[key] ?? json['runtime'];

Object? _readGenres(Map<dynamic, dynamic> json, String key) {
  final genres = json[key];
  if (genres is List) return genres;
  final genre = json['genre'];
  if (genre is String && genre.isNotEmpty) return [genre];
  return genres;
}

@freezed
abstract class MovieModel with _$MovieModel {
  const factory MovieModel({
    @JsonKey(fromJson: flexibleIntFromJson, toJson: flexibleIntToJson)
    required int tmdbId,
    required String title,
    String? overview,
    String? posterPath,
    String? backdropPath,
    String? releaseDate,
    @JsonKey(readValue: _readGenres) @Default([]) List<String> genres,
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
