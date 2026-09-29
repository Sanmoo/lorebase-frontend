import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/tracking/data/models/media_type.dart';
import 'package:lorebase/features/tracking/data/models/tracked_media_model.dart';
import 'package:lorebase/features/tracking/data/models/tracking_page_model.dart';

final _now = DateTime.now();

TrackedMediaModel _item(String id) => TrackedMediaModel(
  trackingId: id,
  userId: 'user-1',
  mediaType: MediaType.series,
  mediaId: '123',
  status: 'COMPLETED',
  addedAt: _now,
  lastUpdated: _now,
);

Map<String, dynamic> _itemJson(String id) => {
  'trackingId': id,
  'userId': 'user-1',
  'mediaType': 'series',
  'mediaId': '123',
  'status': 'COMPLETED',
  'addedAt': _now.toIso8601String(),
  'lastUpdated': _now.toIso8601String(),
};

void main() {
  group('TrackingPage', () {
    test('fromJson parses items, continuation token and first-page metadata', () {
      final page = TrackingPage.fromJson({
        'items': [_itemJson('t-1'), _itemJson('t-2')],
        'nextCursor': 'cursor-page-2',
        'totalCount': 42,
        'page': 1,
        'pageSize': 20,
      });

      expect(page.items.map((e) => e.trackingId), ['t-1', 't-2']);
      expect(page.nextCursor, 'cursor-page-2');
      expect(page.totalCount, 42);
      expect(page.page, 1);
      expect(page.pageSize, 20);
    });

    test('fromJson treats a missing nextCursor as the end of the list', () {
      final page = TrackingPage.fromJson({
        'items': [_itemJson('t-1')],
        'totalCount': 1,
        'page': 1,
        'pageSize': 20,
      });

      expect(page.nextCursor, isNull);
      expect(page.items, hasLength(1));
    });

    test('fromJson parses a cursor page without totalCount', () {
      final page = TrackingPage.fromJson({
        'items': [_itemJson('t-21')],
        'nextCursor': 'cursor-page-3',
      });

      expect(page.nextCursor, 'cursor-page-3');
      expect(page.totalCount, isNull);
      expect(page.page, isNull);
    });

    test('toJson round-trips items and the token for the cache', () {
      final page = TrackingPage(
        items: [_item('t-1')],
        nextCursor: 'cursor-page-2',
        totalCount: 42,
      );

      final restored = TrackingPage.fromJson(page.toJson());

      expect(restored.items.map((e) => e.trackingId), ['t-1']);
      expect(restored.nextCursor, 'cursor-page-2');
      expect(restored.totalCount, 42);
    });
  });
}
