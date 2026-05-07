import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/dashboard/data/models/dashboard_stats_model.dart';

void main() {
  group('DashboardStatsModel', () {
    const completeJson = {
      'watchingCount': 5,
      'wantToWatchCount': 10,
      'completedCount': 20,
      'droppedCount': 2,
      'totalTracked': 37,
    };

    final emptyJson = <String, dynamic>{};

    test('fromJson with complete JSON maps all fields correctly', () {
      final model = DashboardStatsModel.fromJson(completeJson);

      expect(model.watchingCount, 5);
      expect(model.wantToWatchCount, 10);
      expect(model.completedCount, 20);
      expect(model.droppedCount, 2);
      expect(model.totalTracked, 37);
    });

    test('fromJson with empty JSON uses defaults (all 0)', () {
      final model = DashboardStatsModel.fromJson(emptyJson);

      expect(model.watchingCount, 0);
      expect(model.wantToWatchCount, 0);
      expect(model.completedCount, 0);
      expect(model.droppedCount, 0);
      expect(model.totalTracked, 0);
    });

    test('toJson() → fromJson() roundtrip preserves data', () {
      final original = DashboardStatsModel.fromJson(completeJson);
      final json = original.toJson();
      final restored = DashboardStatsModel.fromJson(json);

      expect(restored.watchingCount, original.watchingCount);
      expect(restored.wantToWatchCount, original.wantToWatchCount);
      expect(restored.completedCount, original.completedCount);
      expect(restored.droppedCount, original.droppedCount);
      expect(restored.totalTracked, original.totalTracked);
    });
  });
}
