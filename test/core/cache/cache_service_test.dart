import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:lorebase/core/cache/cache_entry.dart';
import 'package:lorebase/core/cache/cache_service.dart';

void main() {
  late Box box;
  late CacheService service;

  setUp(() async {
    final dir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(dir.path);
    box = await Hive.openBox('test');
    service = CacheService(box);
  });

  tearDown(() async {
    await box.close();
    await Hive.deleteBoxFromDisk('test');
  });

  group('CacheService without Hive', () {
    late CacheService memoryOnlyService;

    setUp(() {
      memoryOnlyService = CacheService();
    });

    test('getSync returns null for unknown key', () {
      expect(memoryOnlyService.getSync('x'), isNull);
    });

    test('set and getSync work with memory only', () async {
      final entry = CacheEntry(
        json: '{}', cachedAt: DateTime.now(), ttl: const Duration(hours: 1),
      );
      await memoryOnlyService.set('k', entry);
      expect(memoryOnlyService.getSync('k'), same(entry));
    });

    test('getFromDiskSync returns null without Hive', () {
      expect(memoryOnlyService.getFromDiskSync('x'), isNull);
    });

    test('remove works without Hive', () async {
      await memoryOnlyService.set('k', CacheEntry(
        json: '{}', cachedAt: DateTime.now(), ttl: const Duration(hours: 1),
      ));
      await memoryOnlyService.remove('k');
      expect(memoryOnlyService.getSync('k'), isNull);
    });

    test('removeByPrefix works without Hive', () async {
      await memoryOnlyService.set('a:1', CacheEntry(json: '{}', cachedAt: DateTime.now(), ttl: const Duration(hours: 1)));
      await memoryOnlyService.set('b:1', CacheEntry(json: '{}', cachedAt: DateTime.now(), ttl: const Duration(hours: 1)));
      await memoryOnlyService.removeByPrefix('a:');
      expect(memoryOnlyService.getSync('a:1'), isNull);
      expect(memoryOnlyService.getSync('b:1'), isNotNull);
    });

    test('clearAll works without Hive', () async {
      await memoryOnlyService.set('k', CacheEntry(
        json: '{}', cachedAt: DateTime.now(), ttl: const Duration(hours: 1),
      ));
      await memoryOnlyService.clearAll();
      expect(memoryOnlyService.getSync('k'), isNull);
    });
  });

  group('CacheService', () {
    test('getSync returns null for unknown key', () {
      expect(service.getSync('unknown'), isNull);
    });

    test('getSync returns entry after set', () async {
      final entry = CacheEntry(
        json: '{"a":1}',
        cachedAt: DateTime.now(),
        ttl: const Duration(hours: 1),
      );
      await service.set('key1', entry);
      expect(service.getSync('key1'), same(entry));
    });

    test('getFromDiskSync returns null for unknown key', () {
      expect(service.getFromDiskSync('unknown'), isNull);
    });

    test('getFromDiskSync returns entry after set', () async {
      final entry = CacheEntry(
        json: '{"a":1}',
        cachedAt: DateTime.now(),
        ttl: const Duration(hours: 1),
      );
      await service.set('key1', entry);
      final result = service.getFromDiskSync('key1');
      expect(result, isNotNull);
      expect(result!.json, '{"a":1}');
      expect(result.ttl, const Duration(hours: 1));
    });

    test('remove clears memory and disk', () async {
      final entry = CacheEntry(
        json: '{}',
        cachedAt: DateTime.now(),
        ttl: const Duration(hours: 1),
      );
      await service.set('key1', entry);
      await service.remove('key1');
      expect(service.getSync('key1'), isNull);
      expect(service.getFromDiskSync('key1'), isNull);
    });

    test('removeByPrefix removes matching entries', () async {
      await service.set(
        'tracking:WATCHING:1',
        CacheEntry(json: '[]', cachedAt: DateTime.now(), ttl: const Duration(hours: 1)),
      );
      await service.set(
        'tracking:COMPLETED:1',
        CacheEntry(json: '[]', cachedAt: DateTime.now(), ttl: const Duration(hours: 1)),
      );
      await service.set(
        'dashboard',
        CacheEntry(json: '{}', cachedAt: DateTime.now(), ttl: const Duration(hours: 1)),
      );
      await service.removeByPrefix('tracking:');
      expect(service.getSync('tracking:WATCHING:1'), isNull);
      expect(service.getSync('tracking:COMPLETED:1'), isNull);
      expect(service.getSync('dashboard'), isNotNull);
    });

    test('clearAll removes everything', () async {
      await service.set(
        'a',
        CacheEntry(json: '{}', cachedAt: DateTime.now(), ttl: const Duration(hours: 1)),
      );
      await service.set(
        'b',
        CacheEntry(json: '{}', cachedAt: DateTime.now(), ttl: const Duration(hours: 1)),
      );
      await service.clearAll();
      expect(service.getSync('a'), isNull);
      expect(service.getSync('b'), isNull);
    });
  });
}
