import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_stats_model.freezed.dart';
part 'dashboard_stats_model.g.dart';

@freezed
class DashboardStatsModel with _$DashboardStatsModel {
  const factory DashboardStatsModel({
    @Default(0) int watchingCount,
    @Default(0) int wantToWatchCount,
    @Default(0) int completedCount,
    @Default(0) int droppedCount,
    @Default(0) int totalTracked,
  }) = _DashboardStatsModel;

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) =>
      _$DashboardStatsModelFromJson(json);
}
