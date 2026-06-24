import 'package:freezed_annotation/freezed_annotation.dart';
import '../data/models/game_model.dart';
import '../../tracking/data/models/tracked_media_model.dart';

part 'game_detail_state.freezed.dart';

@freezed
abstract class GameDetailState with _$GameDetailState {
  const factory GameDetailState({
    required GameModel game,
    TrackedMediaModel? tracking,
  }) = _GameDetailState;
}
