import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:lorebase/core/cache/cache_entry.dart';
import 'package:lorebase/core/cache/cache_providers.dart';
import 'package:lorebase/core/cache/env_fingerprint.dart';
import 'package:lorebase/core/constants/api_constants.dart';

void main() {
  late Box box;

  setUp(() async {
    final dir = await Directory.systemTemp.createTemp('hive_providers_test_');
    Hive.init(dir.path);
    box = await Hive.openBox('providers_test');
  });

  tearDown(() async {
    await box.close();
    await Hive.deleteBoxFromDisk('providers_test');
  });

  CacheEntry entry() => CacheEntry.test();

  ProviderContainer containerFor(String fingerprint) {
    return ProviderContainer(
      overrides: [
        hiveCacheBoxProvider.overrideWithValue(box),
        envFingerprintProvider.overrideWithValue(fingerprint),
      ],
    );
  }

  group('envFingerprintProvider', () {
    test('derives the fingerprint from ApiConstants.baseUrl', () {
      dotenv.loadFromString(
        envString: 'API_BASE_URL=https://api.example.com',
      );
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(envFingerprintProvider), '314dca91');
      expect(
        container.read(envFingerprintProvider),
        envFingerprintOf(ApiConstants.baseUrl),
      );
    });
  });

  group('cacheServiceProvider', () {
    test('scopes entries by the active environment fingerprint', () async {
      const key = 'dashboard:v2:SERIES';
      final envA = containerFor('env-a');
      final envB = containerFor('env-b');
      addTearDown(envA.dispose);
      addTearDown(envB.dispose);

      await envA.read(cacheServiceProvider).set(key, entry());

      expect(envB.read(cacheServiceProvider).getFromDiskSync(key), isNull);
      expect(envA.read(cacheServiceProvider).getFromDiskSync(key), isNotNull);
    });

    test('a boot purge in env B drops env A data before the UI reads it',
        () async {
      const key = 'tracking:v5:SERIES:all';
      final envA = containerFor('env-a');
      final envB = containerFor('env-b');
      addTearDown(envA.dispose);
      addTearDown(envB.dispose);

      await envA.read(cacheServiceProvider).set(key, entry());
      await envB.read(cacheServiceProvider).purgeForeignEnvironments();

      expect(envB.read(cacheServiceProvider).getFromDiskSync(key), isNull);
      expect(box.containsKey('env:env-a:$key'), false);
    });
  });
}
