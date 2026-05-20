import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'cache_service.dart';

final hiveCacheBoxProvider = Provider<Box>((ref) {
  return Hive.box('cache');
});

final cacheServiceProvider = Provider<CacheService>((ref) {
  return CacheService(ref.watch(hiveCacheBoxProvider));
});

final dashboardBackgroundErrorProvider = StateProvider<String?>((ref) => null);

final trackingBackgroundErrorProvider = StateProvider<String?>((ref) => null);
