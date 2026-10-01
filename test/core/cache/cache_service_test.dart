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
    service = CacheService(envFingerprint: 'test', hiveBox: box);
  });

  tearDown(() async {
    await box.close();
    await Hive.deleteBoxFromDisk('test');
  });

  CacheEntry entry([String json = '{}']) => CacheEntry(
    json: json,
    cachedAt: DateTime.now(),
    ttl: const Duration(hours: 1),
  );

  group('CacheService without Hive', () {
    late CacheService memoryOnlyService;

    setUp(() {
      memoryOnlyService = CacheService(envFingerprint: 'test');
    });

    test('getSync returns null for unknown key', () {
      expect(memoryOnlyService.getSync('x'), isNull);
    });

    test('set and getSync work with memory only', () async {
      final value = entry();
      await memoryOnlyService.set('k', value);
      expect(memoryOnlyService.getSync('k'), same(value));
    });

    test('getFromDiskSync returns null without Hive', () {
      expect(memoryOnlyService.getFromDiskSync('x'), isNull);
    });

    test('remove works without Hive', () async {
      await memoryOnlyService.set('k', entry());
      await memoryOnlyService.remove('k');
      expect(memoryOnlyService.getSync('k'), isNull);
    });

    test('removeByPrefix works without Hive', () async {
      await memoryOnlyService.set('a:1', entry());
      await memoryOnlyService.set('b:1', entry());
      await memoryOnlyService.removeByPrefix('a:');
      expect(memoryOnlyService.getSync('a:1'), isNull);
      expect(memoryOnlyService.getSync('b:1'), isNotNull);
    });

    test('clearAll works without Hive', () async {
      await memoryOnlyService.set('k', entry());
      await memoryOnlyService.clearAll();
      expect(memoryOnlyService.getSync('k'), isNull);
    });

    test('purgeForeignEnvironments is a no-op without Hive', () async {
      await memoryOnlyService.set('k', entry());
      await memoryOnlyService.purgeForeignEnvironments();
      expect(memoryOnlyService.getSync('k'), isNotNull);
    });
  });

  group('CacheService', () {
    test('getSync returns null for unknown key', () {
      expect(service.getSync('unknown'), isNull);
    });

    test('getSync returns entry after set', () async {
      final value = entry('{"a":1}');
      await service.set('key1', value);
      expect(service.getSync('key1'), same(value));
    });

    test('getFromDiskSync returns null for unknown key', () {
      expect(service.getFromDiskSync('unknown'), isNull);
    });

    test('getFromDiskSync returns entry after set', () async {
      await service.set('key1', entry('{"a":1}'));
      final result = service.getFromDiskSync('key1');
      expect(result, isNotNull);
      expect(result!.json, '{"a":1}');
      expect(result.ttl, const Duration(hours: 1));
    });

    test('getFromDiskSync drops a corrupt entry and returns null', () async {
      await box.put('env:test:key1', 'not-a-map');
      expect(service.getFromDiskSync('key1'), isNull);
      expect(box.containsKey('env:test:key1'), false);
    });

    test('remove clears memory and disk', () async {
      await service.set('key1', entry());
      await service.remove('key1');
      expect(service.getSync('key1'), isNull);
      expect(service.getFromDiskSync('key1'), isNull);
    });

    test('removeByPrefix removes matching entries', () async {
      await service.set('tracking:WATCHING:1', entry('[]'));
      await service.set('tracking:COMPLETED:1', entry('[]'));
      await service.set('dashboard', entry());
      await service.removeByPrefix('tracking:');
      expect(service.getSync('tracking:WATCHING:1'), isNull);
      expect(service.getSync('tracking:COMPLETED:1'), isNull);
      expect(service.getSync('dashboard'), isNotNull);
    });

    test('clearAll removes everything', () async {
      await service.set('a', entry());
      await service.set('b', entry());
      await service.clearAll();
      expect(service.getSync('a'), isNull);
      expect(service.getSync('b'), isNull);
    });
  });

  group('CacheService environment scoping', () {
    late CacheService foreign;

    setUp(() {
      foreign = CacheService(envFingerprint: 'other', hiveBox: box);
    });

    test('writes keys prefixed with the environment fingerprint', () async {
      await service.set('dashboard:v2:SERIES', entry());
      expect(box.containsKey('env:test:dashboard:v2:SERIES'), true);
    });

    test('a hit from another environment is a miss', () async {
      await foreign.set('dashboard:v2:SERIES', entry());
      expect(service.getSync('dashboard:v2:SERIES'), isNull);
      expect(service.getFromDiskSync('dashboard:v2:SERIES'), isNull);
    });

    test('a fresh hit from the same environment is served', () async {
      await service.set('dashboard:v2:SERIES', entry('{"totalTracked":1}'));
      final hit = service.getFromDiskSync('dashboard:v2:SERIES');
      expect(hit, isNotNull);
      expect(hit!.isFresh, true);
      expect(hit.json, '{"totalTracked":1}');
    });

    test('switching A -> B -> A keeps each namespace intact', () async {
      await service.set('tracking:v5:SERIES:all', entry('["a"]'));
      await foreign.set('tracking:v5:SERIES:all', entry('["b"]'));
      service = CacheService(envFingerprint: 'test', hiveBox: box);
      expect(service.getFromDiskSync('tracking:v5:SERIES:all')!.json, '["a"]');
      foreign = CacheService(envFingerprint: 'other', hiveBox: box);
      expect(foreign.getFromDiskSync('tracking:v5:SERIES:all')!.json, '["b"]');
    });

    test('removeByPrefix only invalidates the current environment', () async {
      await service.set('tracking:v5:SERIES:all', entry());
      await foreign.set('tracking:v5:SERIES:all', entry());
      await service.removeByPrefix('tracking:');
      expect(service.getFromDiskSync('tracking:v5:SERIES:all'), isNull);
      expect(foreign.getFromDiskSync('tracking:v5:SERIES:all'), isNotNull);
    });

    test('clearAll clears every environment namespace', () async {
      await service.set('dashboard:v2:SERIES', entry());
      await foreign.set('dashboard:v2:SERIES', entry());
      await service.clearAll();
      expect(service.getFromDiskSync('dashboard:v2:SERIES'), isNull);
      expect(foreign.getFromDiskSync('dashboard:v2:SERIES'), isNull);
    });
  });

  group('CacheService.purgeForeignEnvironments', () {
    test('drops foreign and legacy keys, keeps the current environment',
        () async {
      final foreign = CacheService(envFingerprint: 'other', hiveBox: box);
      await service.set('dashboard:v2:SERIES', entry('{"source":"current"}'));
      await foreign.set('dashboard:v2:SERIES', entry('{"source":"other"}'));
      await box.put('dashboard:v2:SERIES', entry('{"legacy":true}').toJson());
      await box.put('tracking:v4:SERIES:all', entry().toJson());

      await service.purgeForeignEnvironments();

      expect(box.containsKey('env:other:dashboard:v2:SERIES'), false);
      expect(box.containsKey('dashboard:v2:SERIES'), false);
      expect(box.containsKey('tracking:v4:SERIES:all'), false);
      expect(
        service.getFromDiskSync('dashboard:v2:SERIES')!.json,
        '{"source":"current"}',
      );
      expect(foreign.getFromDiskSync('dashboard:v2:SERIES'), isNull);
    });

    test('is idempotent', () async {
      await service.set('dashboard:v2:SERIES', entry());
      await service.purgeForeignEnvironments();
      await service.purgeForeignEnvironments();
      expect(service.getFromDiskSync('dashboard:v2:SERIES'), isNotNull);
    });
  });
}
