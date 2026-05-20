import 'package:freezed_annotation/freezed_annotation.dart';
import '../data/models/series_model.dart';
import '../../tracking/data/models/tracked_media_model.dart';

part 'series_detail_state.freezed.dart';

@freezed
abstract class SeriesDetailState with _$SeriesDetailState {
  const factory SeriesDetailState({
    required SeriesModel series,
    TrackedMediaModel? tracking,
  }) = _SeriesDetailState;
}
