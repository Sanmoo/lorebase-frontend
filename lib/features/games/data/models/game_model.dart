import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_model.freezed.dart';
part 'game_model.g.dart';

@freezed
abstract class GameModel with _$GameModel {
  const factory GameModel({
    required String gameId,
    required String title,
    String? summary,
    String? genre,
    String? coverUrl,
    String? backdropUrl,
    String? releaseDate,
    @Default([]) List<String> platforms,
    String? developer,
    String? publisher,
    String? franchise,
    @Default([]) List<String> gameModes,
  }) = _GameModel;

  factory GameModel.fromJson(Map<String, dynamic> json) =>
      _$GameModelFromJson(json);
}
