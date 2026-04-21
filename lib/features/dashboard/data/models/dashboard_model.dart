import 'package:freezed_annotation/freezed_annotation.dart';
import 'dashboard_section_model.dart';
import 'dashboard_stats_model.dart';

part 'dashboard_model.freezed.dart';
part 'dashboard_model.g.dart';

@freezed
class DashboardModel with _$DashboardModel {
  const factory DashboardModel({
    required DashboardSectionModel watching,
    required DashboardSectionModel wantToWatch,
    required DashboardSectionModel completed,
    required DashboardSectionModel dropped,
    required DashboardStatsModel stats,
  }) = _DashboardModel;

  factory DashboardModel.fromJson(Map<String, dynamic> json) =>
      _$DashboardModelFromJson(json);
}
