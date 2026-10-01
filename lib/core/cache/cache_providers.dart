import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../constants/api_constants.dart';
import 'cache_service.dart';
import 'env_fingerprint.dart';

final hiveCacheBoxProvider = Provider<Box>((ref) {
  return Hive.box('cache');
});

/// Fingerprint of the environment the app is currently pointing at.
///
/// Derived from [ApiConstants.baseUrl] (not from `ENV_FILE`, which only
/// selects the env file and may diverge from the actual data origin).
/// Overridable in tests to simulate an environment switch without Hive.
final envFingerprintProvider = Provider<String>((ref) {
  return envFingerprintOf(ApiConstants.baseUrl);
});

final cacheServiceProvider = Provider<CacheService>((ref) {
  return CacheService(
    envFingerprint: ref.watch(envFingerprintProvider),
    hiveBox: ref.watch(hiveCacheBoxProvider),
  );
});

final dashboardBackgroundErrorProvider = StateProvider<String?>((ref) => null);

final trackingBackgroundErrorProvider = StateProvider<String?>((ref) => null);
