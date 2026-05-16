import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/dashboard/data/models/dashboard_section_model.dart';
import 'package:lorebase/features/tracking/data/models/tracked_media_summary_model.dart';

void main() {
  group('DashboardSectionModel', () {
    final completeJson = {
      'items': [
        {'mediaId': 1, 'title': 'Series A', 'mediaType': 'series'},
        {'mediaId': 2, 'title': 'Movie B', 'mediaType': 'movie'},
      ],
      'total': 10,
      'hasMore': true,
    };

    final emptyJson = <String, dynamic>{};

    test('fromJson with complete JSON maps all fields correctly', () {
      final model = DashboardSectionModel.fromJson(completeJson);

      expect(model.items, hasLength(2));
      expect(model.items[0], isA<TrackedMediaSummaryModel>());
      expect(model.items[0].mediaId, '1');
      expect(model.items[0].title, 'Series A');
      expect(model.items[1].mediaId, '2');
      expect(model.items[1].title, 'Movie B');
      expect(model.total, 10);
      expect(model.hasMore, true);
    });

    test('fromJson with empty JSON uses defaults', () {
      final model = DashboardSectionModel.fromJson(emptyJson);

      expect(model.items, isEmpty);
      expect(model.total, 0);
      expect(model.hasMore, false);
    });

    test('toJson() → fromJson() roundtrip preserves data', () {
      final original = DashboardSectionModel.fromJson(completeJson);
      final jsonString = jsonEncode(original.toJson());
      final restored = DashboardSectionModel.fromJson(
          jsonDecode(jsonString) as Map<String, dynamic>);

      expect(restored.items, hasLength(original.items.length));
      expect(restored.items[0].mediaId, original.items[0].mediaId);
      expect(restored.items[0].title, original.items[0].title);
      expect(restored.total, original.total);
      expect(restored.hasMore, original.hasMore);
    });
  });
}
