import 'package:freezed_annotation/freezed_annotation.dart';
import '../../tracking/data/models/tracked_media_model.dart';
import '../data/models/movie_model.dart';

part 'movie_detail_state.freezed.dart';

@freezed
class MovieDetailState with _$MovieDetailState {
  const factory MovieDetailState({
    required MovieModel movie,
    TrackedMediaModel? tracking,
  }) = _MovieDetailState;
}
