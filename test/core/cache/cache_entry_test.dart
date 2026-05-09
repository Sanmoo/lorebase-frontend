import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/core/cache/cache_entry.dart';

void main() {
  group('CacheEntry', () {
    test('isFresh returns true when within TTL', () {
      final entry = CacheEntry(
        json: '{}',
        cachedAt: DateTime.now(),
        ttl: const Duration(hours: 6),
      );
      expect(entry.isFresh, true);
    });

    test('isFresh returns false when TTL exceeded', () {
      final entry = CacheEntry(
        json: '{}',
        cachedAt: DateTime.now().subtract(const Duration(hours: 7)),
        ttl: const Duration(hours: 6),
      );
      expect(entry.isFresh, false);
    });

    test('isFresh returns false at exact TTL boundary', () {
      final entry = CacheEntry(
        json: '{}',
        cachedAt: DateTime.now().subtract(const Duration(hours: 6)),
        ttl: const Duration(hours: 6),
      );
      expect(entry.isFresh, false);
    });

    test('round-trip serialization', () {
      final entry = CacheEntry(
        json: '{"key":"value"}',
        cachedAt: DateTime(2026, 5, 9),
        ttl: const Duration(hours: 6),
      );
      final json = entry.toJson();
      final restored = CacheEntry.fromJson(json);
      expect(restored.json, entry.json);
      expect(restored.cachedAt, entry.cachedAt);
      expect(restored.ttl, entry.ttl);
    });
  });
}
