import 'package:freezed_annotation/freezed_annotation.dart';
import '../data/models/series_model.dart';
import '../../tracking/data/models/tracked_series_model.dart';

part 'series_detail_state.freezed.dart';

@freezed
class SeriesDetailState with _$SeriesDetailState {
  const factory SeriesDetailState({
    required SeriesModel series,
    TrackedSeriesModel? tracking,
  }) = _SeriesDetailState;
}
