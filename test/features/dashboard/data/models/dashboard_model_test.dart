import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/dashboard/data/models/dashboard_model.dart';
import 'package:lorebase/features/dashboard/data/models/dashboard_section_model.dart';
import 'package:lorebase/features/dashboard/data/models/dashboard_stats_model.dart';

void main() {
  group('DashboardModel', () {
    final completeJson = {
      'watching': {
        'items': [
          {'tmdbId': 1, 'title': 'Watching Series'},
        ],
        'total': 5,
        'hasMore': false,
      },
      'wantToWatch': {
        'items': [
          {'tmdbId': 2, 'title': 'Want To Watch Series'},
        ],
        'total': 10,
        'hasMore': true,
      },
      'completed': {
        'items': [],
        'total': 20,
        'hasMore': false,
      },
      'dropped': {
        'items': [],
        'total': 3,
        'hasMore': false,
      },
      'stats': {
        'watchingCount': 5,
        'wantToWatchCount': 10,
        'completedCount': 20,
        'droppedCount': 3,
        'totalTracked': 38,
      },
    };

    test('fromJson with complete JSON maps all sections and stats', () {
      final model = DashboardModel.fromJson(completeJson);

      expect(model.watching, isA<DashboardSectionModel>());
      expect(model.watching.items, hasLength(1));
      expect(model.watching.items[0].title, 'Watching Series');
      expect(model.watching.total, 5);

      expect(model.wantToWatch, isA<DashboardSectionModel>());
      expect(model.wantToWatch.items, hasLength(1));
      expect(model.wantToWatch.items[0].title, 'Want To Watch Series');
      expect(model.wantToWatch.total, 10);
      expect(model.wantToWatch.hasMore, true);

      expect(model.completed, isA<DashboardSectionModel>());
      expect(model.completed.items, isEmpty);
      expect(model.completed.total, 20);

      expect(model.dropped, isA<DashboardSectionModel>());
      expect(model.dropped.total, 3);

      expect(model.stats, isA<DashboardStatsModel>());
      expect(model.stats.watchingCount, 5);
      expect(model.stats.totalTracked, 38);
    });

    test('toJson() → fromJson() roundtrip preserves data', () {
      final original = DashboardModel.fromJson(completeJson);
      final jsonString = jsonEncode(original.toJson());
      final restored = DashboardModel.fromJson(
          jsonDecode(jsonString) as Map<String, dynamic>);

      expect(restored.watching.total, original.watching.total);
      expect(restored.watching.items[0].tmdbId,
          original.watching.items[0].tmdbId);
      expect(restored.wantToWatch.total, original.wantToWatch.total);
      expect(restored.wantToWatch.hasMore, original.wantToWatch.hasMore);
      expect(restored.completed.total, original.completed.total);
      expect(restored.dropped.total, original.dropped.total);
      expect(restored.stats.watchingCount, original.stats.watchingCount);
      expect(restored.stats.totalTracked, original.stats.totalTracked);
    });
  });
}
