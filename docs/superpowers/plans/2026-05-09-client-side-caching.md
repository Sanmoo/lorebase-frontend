# Client-Side Caching Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Cache dashboard and tracking list data in memory + Hive disk with 6h TTL and stale-while-revalidate.

**Architecture:** `CacheService` coordinates a `Map<String, CacheEntry>` memory cache and a Hive `Box` disk cache. ViewModels check cache synchronously before falling back to network. Background refresh updates state silently; errors show a SnackBar via `backgroundErrorProvider`. Mutations invalidate relevant cache keys.

**Tech Stack:** Hive 2.x + hive_flutter for disk persistence, existing Riverpod + Freezed patterns.

---

### Task 1: Add Hive dependencies

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Add `hive` and `hive_flutter` to dependencies**

```yaml
  # Storage
  flutter_secure_storage: ^9.0.0
  hive: ^2.2.3
  hive_flutter: ^1.1.0
```

- [ ] **Run `flutter pub get`**

```bash
flutter pub get
```

- [ ] **Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "feat: add Hive dependencies for client-side caching"
```

---

### Task 2: Create CacheEntry model + tests

**Files:**
- Create: `lib/core/cache/cache_entry.dart`
- Create: `test/core/cache/cache_entry_test.dart`

- [ ] **Create `lib/core/cache/cache_entry.dart`**

```dart
import 'dart:convert';

class CacheEntry {
  final String json;
  final DateTime cachedAt;
  final Duration ttl;

  const CacheEntry({
    required this.json,
    required this.cachedAt,
    required this.ttl,
  });

  bool get isFresh => DateTime.now().isBefore(cachedAt.add(ttl));

  Map<String, dynamic> toJson() => {
        'json': json,
        'cachedAt': cachedAt.toIso8601String(),
        'ttl': ttl.inSeconds,
      };

  factory CacheEntry.fromJson(Map<String, dynamic> map) => CacheEntry(
        json: map['json'] as String,
        cachedAt: DateTime.parse(map['cachedAt'] as String),
        ttl: Duration(seconds: map['ttl'] as int),
      );
}
```

- [ ] **Create `test/core/cache/cache_entry_test.dart`**

```dart
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
```

- [ ] **Run tests**

```bash
flutter test test/core/cache/cache_entry_test.dart
```

Expected: 4/4 PASS

- [ ] **Commit**

```bash
git add lib/core/cache/cache_entry.dart test/core/cache/cache_entry_test.dart
git commit -m "feat: add CacheEntry model with TTL and serialization"
```

---

### Task 3: Create CacheService + tests

**Files:**
- Create: `lib/core/cache/cache_service.dart`
- Create: `test/core/cache/cache_service_test.dart`

- [ ] **Create `lib/core/cache/cache_service.dart`**

```dart
import 'package:hive/hive.dart';
import 'cache_entry.dart';

class CacheService {
  final Map<String, CacheEntry> _memory = {};
  final Box? _hiveBox;

  CacheService([this._hiveBox]);

  CacheEntry? getSync(String key) => _memory[key];

  CacheEntry? getFromDiskSync(String key) {
    final raw = _hiveBox?.get(key);
    if (raw == null) return null;
    final entry = CacheEntry.fromJson(
      Map<String, dynamic>.from(raw as Map),
    );
    _memory[key] = entry;
    return entry;
  }

  Future<void> set(String key, CacheEntry entry) async {
    _memory[key] = entry;
    await _hiveBox?.put(key, entry.toJson());
  }

  Future<void> remove(String key) async {
    _memory.remove(key);
    await _hiveBox?.delete(key);
  }

  Future<void> removeByPrefix(String prefix) async {
    if (_hiveBox == null) {
      _memory.removeWhere((k, _) => k.startsWith(prefix));
      return;
    }
    final keysToRemove = _hiveBox!.keys
        .where((k) => k.toString().startsWith(prefix))
        .toList();
    for (final key in keysToRemove) {
      _memory.remove(key);
      await _hiveBox!.delete(key);
    }
  }

  Future<void> clearAll() async {
    _memory.clear();
    await _hiveBox?.clear();
  }
}
```

- [ ] **Create `test/core/cache/cache_service_test.dart`**

```dart
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
```

- [ ] **Run tests**

```bash
flutter test test/core/cache/cache_service_test.dart
```

Expected: 7/7 PASS

- [ ] **Commit**

```bash
git add lib/core/cache/cache_service.dart test/core/cache/cache_service_test.dart
git commit -m "feat: add CacheService with memory + Hive disk layers"
```

---

### Task 4: Create cache providers

**Files:**
- Create: `lib/core/cache/cache_providers.dart`

- [ ] **Create `lib/core/cache/cache_providers.dart`**

```dart
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
```

- [ ] **Commit**

```bash
git add lib/core/cache/cache_providers.dart
git commit -m "feat: add cache and background error providers"
```

---

### Task 5: Initialize Hive in main.dart

**Files:**
- Modify: `lib/main.dart`

- [ ] **Add Hive init before runApp**

```dart
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();
  try {
    await dotenv.load();
  } catch (e) {
    debugPrint('Warning: .env file not found, using defaults');
  }
  await _configureHive();
  await _configureAmplify();
  runApp(
    const ProviderScope(
      child: LorebaseApp(),
    ),
  );
}

Future<void> _configureHive() async {
  await Hive.initFlutter();
  await Hive.openBox('cache');
}
```

- [ ] **Commit**

```bash
git add lib/main.dart
git commit -m "feat: initialize Hive at app startup"
```

---

### Task 6: Update DashboardViewModel with caching

**Files:**
- Modify: `lib/features/dashboard/viewmodels/dashboard_viewmodel.dart`

- [ ] **Rewrite dashboard_viewmodel.dart with cache logic**

```dart
import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/cache/cache_entry.dart';
import '../../../core/cache/cache_providers.dart';
import '../data/models/dashboard_model.dart';
import '../data/repositories/dashboard_repository.dart';

part 'dashboard_viewmodel.g.dart';

@riverpod
class DashboardViewModel extends _$DashboardViewModel {
  @override
  AsyncValue<DashboardModel> build() {
    final cacheService = ref.read(cacheServiceProvider);

    var hit = cacheService.getSync('dashboard');
    if (hit == null) {
      hit = cacheService.getFromDiskSync('dashboard');
    }

    if (hit != null) {
      final data = DashboardModel.fromJson(
        jsonDecode(hit.json) as Map<String, dynamic>,
      );
      if (!hit.isFresh) {
        _backgroundRefresh();
      }
      return AsyncValue.data(data);
    }

    _loadFromNetwork();
    return const AsyncValue.loading();
  }

  Future<void> _loadFromNetwork() async {
    try {
      final data = await _fetchAndCache();
      state = AsyncValue.data(data);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<DashboardModel> _fetchAndCache() async {
    final repository = ref.read(dashboardRepositoryProvider);
    final cacheService = ref.read(cacheServiceProvider);
    final data = await repository.getDashboard();
    final entry = CacheEntry(
      json: jsonEncode(data.toJson()),
      cachedAt: DateTime.now(),
      ttl: const Duration(hours: 6),
    );
    await cacheService.set('dashboard', entry);
    return data;
  }

  void _backgroundRefresh() {
    Future(() async {
      try {
        final data = await _fetchAndCache();
        state = AsyncValue.data(data);
      } catch (_) {
        ref.read(dashboardBackgroundErrorProvider.notifier).state =
            'Could not refresh. Pull down to retry.';
      }
    });
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final cacheService = ref.read(cacheServiceProvider);
      await cacheService.remove('dashboard');
      final data = await _fetchAndCache();
      state = AsyncValue.data(data);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
```

- [ ] **Update tests to use cache service override**

Add to `test/features/dashboard/viewmodels/dashboard_viewmodel_test.dart`:

```dart
// Update imports at the top
import 'package:lorebase/core/cache/cache_entry.dart';

// Add import for CacheService
import 'package:lorebase/core/cache/cache_service.dart';
```

Replace `ProviderContainer` creation in each test to override `cacheServiceProvider`:

```dart
final container = ProviderContainer(overrides: [
  dashboardRepositoryProvider.overrideWith((ref) => repo),
  cacheServiceProvider.overrideWith((ref) => CacheService()),
]);
```

The existing tests will continue to pass because `CacheService()` (no Hive box) returns null for `getSync` and `getFromDiskSync`, forcing the VM to fetch from network.

- [ ] **Add new test for cache-hit scenario**

```dart
test('build() returns cached data from memory', () async {
  final cacheService = CacheService();
  await cacheService.set('dashboard', CacheEntry(
    json: jsonEncode(const DashboardModel(
      watching: DashboardSectionModel(),
      wantToWatch: DashboardSectionModel(),
      completed: DashboardSectionModel(),
      dropped: DashboardSectionModel(),
      stats: DashboardStatsModel(watchingCount: 3),
    ).toJson()),
    cachedAt: DateTime.now(),
    ttl: const Duration(hours: 6),
  ));
  final container = ProviderContainer(overrides: [
    dashboardRepositoryProvider.overrideWith((ref) => FakeDashboardRepo()),
    cacheServiceProvider.overrideWith((ref) => cacheService),
  ]);
  addTearDown(container.dispose);

  final state = container.read(dashboardViewModelProvider);
  expect(state.hasValue, true);
  expect(state.value!.stats.watchingCount, 3);
});
```

- [ ] **Run tests**

```bash
flutter test test/features/dashboard/viewmodels/dashboard_viewmodel_test.dart test/core/cache/cache_entry_test.dart test/core/cache/cache_service_test.dart
```

Expected: all PASS

- [ ] **Run build_runner**

```bash
dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Run analyzer**

```bash
dart analyze --fatal-infos
```

- [ ] **Commit**

```bash
git add lib/features/dashboard/viewmodels/dashboard_viewmodel.dart lib/features/dashboard/viewmodels/dashboard_viewmodel.g.dart test/features/dashboard/viewmodels/dashboard_viewmodel_test.dart
git commit -m "feat: add caching to DashboardViewModel"
```

---

### Task 7: Show SnackBar on background refresh error (Dashboard)

**Files:**
- Modify: `lib/features/dashboard/pages/dashboard_page.dart`

- [ ] **Add background error listener**

Add import:
```dart
import '../../../core/cache/cache_providers.dart';
```

Inside the `build` method, before the `final dashboardState` line, add the listener:
```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  ref.listen<String?>(dashboardBackgroundErrorProvider, (prev, next) {
    if (next != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(next)),
      );
      ref.read(dashboardBackgroundErrorProvider.notifier).state = null;
    }
  });

  final dashboardState = ref.watch(dashboardViewModelProvider);
  // ... rest unchanged
```

- [ ] **Commit**

```bash
git add lib/features/dashboard/pages/dashboard_page.dart
git commit -m "feat: show SnackBar on dashboard background refresh error"
```

---

### Task 8: Update TrackingListViewModel with caching

**Files:**
- Modify: `lib/features/tracking/viewmodels/tracking_list_viewmodel.dart`

- [ ] **Rewrite tracking_list_viewmodel.dart with cache logic**

```dart
import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/cache/cache_entry.dart';
import '../../../core/cache/cache_providers.dart';
import '../data/models/tracked_series_model.dart';
import '../data/repositories/tracking_repository.dart';

part 'tracking_list_viewmodel.g.dart';

@riverpod
class TrackingListViewModel extends _$TrackingListViewModel {
  String? _currentStatus;
  int _page = 1;
  static const int _pageSize = 20;

  @override
  AsyncValue<List<TrackedSeriesModel>> build() {
    return const AsyncValue.data([]);
  }

  Future<void> loadTracking({String? status}) async {
    _currentStatus = status;
    _page = 1;

    final cacheKey = _buildCacheKey();
    final cacheService = ref.read(cacheServiceProvider);

    var hit = cacheService.getSync(cacheKey);
    if (hit == null) {
      hit = cacheService.getFromDiskSync(cacheKey);
    }

    if (hit != null) {
      final items = _parseItems(hit.json);
      state = AsyncValue.data(items);
      if (!hit.isFresh) {
        _backgroundRefresh(cacheKey);
      }
      return;
    }

    state = const AsyncValue.loading();
    await _fetch(append: false);
  }

  Future<void> loadMore() async {
    if (state.isLoading) return;
    _page++;
    await _fetch(append: true);
  }

  Future<void> refresh() async {
    final cacheService = ref.read(cacheServiceProvider);
    await cacheService.removeByPrefix('tracking:');
    await loadTracking(status: _currentStatus);
  }

  Future<void> _fetch({bool append = false}) async {
    try {
      final repository = ref.read(trackingRepositoryProvider);
      final cacheService = ref.read(cacheServiceProvider);

      final items = await repository.getTracking(
        status: _currentStatus,
        page: _page,
        pageSize: _pageSize,
      );

      final entry = CacheEntry(
        json: jsonEncode(items.map((e) => e.toJson()).toList()),
        cachedAt: DateTime.now(),
        ttl: const Duration(hours: 6),
      );
      await cacheService.set(_buildCacheKey(), entry);

      if (append && state.hasValue) {
        state = AsyncValue.data([...state.value!, ...items]);
      } else {
        state = AsyncValue.data(items);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void _backgroundRefresh(String key) {
    Future(() async {
      try {
        final repository = ref.read(trackingRepositoryProvider);
        final cacheService = ref.read(cacheServiceProvider);
        final items = await repository.getTracking(
          status: _currentStatus,
          page: _page,
          pageSize: _pageSize,
        );
        final entry = CacheEntry(
          json: jsonEncode(items.map((e) => e.toJson()).toList()),
          cachedAt: DateTime.now(),
          ttl: const Duration(hours: 6),
        );
        await cacheService.set(key, entry);
        state = AsyncValue.data(items);
      } catch (_) {
        ref.read(trackingBackgroundErrorProvider.notifier).state =
            'Could not refresh. Pull down to retry.';
      }
    });
  }

  String _buildCacheKey() => 'tracking:${_currentStatus ?? "all"}:$_page';

  List<TrackedSeriesModel> _parseItems(String json) {
    final list = jsonDecode(json) as List;
    return list
        .map((e) => TrackedSeriesModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
```

- [ ] **Update tests to use fake cache service**

In `test/features/tracking/viewmodels/tracking_list_viewmodel_test.dart`:

```dart
// Add imports
import 'package:lorebase/core/cache/cache_entry.dart';
import 'package:lorebase/core/cache/cache_providers.dart';
import 'package:lorebase/core/cache/cache_service.dart';

// Update createContainer
ProviderContainer createContainer(FakeTrackingRepo repo, {CacheService? cache}) {
  return ProviderContainer(overrides: [
    trackingRepositoryProvider.overrideWith((ref) => repo),
    cacheServiceProvider.overrideWith((ref) => cache ?? CacheService()),
  ]);
}
```

- [ ] **Run build_runner, analyze, tests**

```bash
dart run build_runner build --delete-conflicting-outputs
dart analyze --fatal-infos
flutter test test/features/tracking/viewmodels/tracking_list_viewmodel_test.dart
```

- [ ] **Commit**

```bash
git add lib/features/tracking/viewmodels/tracking_list_viewmodel.dart lib/features/tracking/viewmodels/tracking_list_viewmodel.g.dart test/features/tracking/viewmodels/tracking_list_viewmodel_test.dart
git commit -m "feat: add caching to TrackingListViewModel"
```

---

### Task 9: Show SnackBar on background refresh error (Tracking)

**Files:**
- Modify: `lib/features/tracking/pages/tracking_list_page.dart`

- [ ] **Add background error listener**

```dart
import '../../../../core/cache/cache_providers.dart';
```

Inside `build`, before `final trackingState`:
```dart
ref.listen<String?>(trackingBackgroundErrorProvider, (prev, next) {
  if (next != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(next)),
    );
    ref.read(trackingBackgroundErrorProvider.notifier).state = null;
  }
});
```

The `_TrackingListPageState` is already a `ConsumerState`, so `ref` is available.

- [ ] **Commit**

```bash
git add lib/features/tracking/pages/tracking_list_page.dart
git commit -m "feat: show SnackBar on tracking background refresh error"
```

---

### Task 10: Invalidate cache on tracking mutations

**Files:**
- Modify: `lib/features/tracking/viewmodels/tracking_list_viewmodel.dart` (add invalidation methods)

- [ ] **Add `_invalidateCache` method and call it from mutation entry points**

Add to the TrackingListViewModel:

```dart
Future<void> _invalidateCache() async {
  final cacheService = ref.read(cacheServiceProvider);
  await cacheService.remove('dashboard');
  await cacheService.removeByPrefix('tracking:');
}
```

The mutation methods (`startTracking`, `updateTracking`, `deleteTracking`) are called from widgets by reading the notifier. Add these methods to the ViewModel:

```dart
Future<void> startTracking(String seriesId, String status) async {
  await _invalidateCache();
  try {
    final repository = ref.read(trackingRepositoryProvider);
    await repository.startTracking(seriesId, status);
    await refresh();
  } catch (error, stackTrace) {
    state = AsyncValue.error(error, stackTrace);
  }
}

Future<void> updateTracking(
  String seriesId, {
  String? status,
  int? seriesRating,
  String? seriesReview,
  List<Map<String, dynamic>>? seasonRatings,
}) async {
  await _invalidateCache();
  try {
    final repository = ref.read(trackingRepositoryProvider);
    await repository.updateTracking(
      seriesId,
      status: status,
      seriesRating: seriesRating,
      seriesReview: seriesReview,
      seasonRatings: seasonRatings,
    );
    await refresh();
  } catch (error, stackTrace) {
    state = AsyncValue.error(error, stackTrace);
  }
}

Future<void> deleteTracking(String seriesId) async {
  await _invalidateCache();
  try {
    final repository = ref.read(trackingRepositoryProvider);
    await repository.deleteTracking(seriesId);
    await refresh();
  } catch (error, stackTrace) {
    state = AsyncValue.error(error, stackTrace);
  }
}
```

These methods are called from `SeriesDetailViewModel` (which calls `trackingRepo.startTracking/updateTracking/deleteTracking` directly). Update it to also invalidate cache.

Also modify `lib/features/series/viewmodels/series_detail_viewmodel.dart`:

```dart
// Add import
import '../../../core/cache/cache_providers.dart';

// In addTracking, updateTracking, removeTracking — add cache invalidation before ref.invalidateSelf()
Future<void> addTracking(...) async {
  // ... existing code up to ref.invalidateSelf() ...
  await ref.read(cacheServiceProvider).remove('dashboard');
  await ref.read(cacheServiceProvider).removeByPrefix('tracking:');
  ref.invalidateSelf();
}

Future<void> updateTracking(...) async {
  // ... existing code ...
  await ref.read(cacheServiceProvider).remove('dashboard');
  await ref.read(cacheServiceProvider).removeByPrefix('tracking:');
  ref.invalidateSelf();
}

Future<void> removeTracking() async {
  // ... existing code ...
  await ref.read(cacheServiceProvider).remove('dashboard');
  await ref.read(cacheServiceProvider).removeByPrefix('tracking:');
  ref.invalidateSelf();
}
```

- [ ] **Update `createContainer` in `test/features/series/viewmodels/series_detail_viewmodel_test.dart`**

Add `fakeCacheServiceProvider` override to `createContainer`:

```dart
// At top of file, add import
import 'package:lorebase/core/cache/cache_providers.dart';
import 'package:lorebase/core/cache/cache_entry.dart';

// Add import
import 'package:lorebase/core/cache/cache_service.dart';

// Update createContainer to add cache service override
ProviderContainer createContainer({
  required FakeSeriesRepo seriesRepo,
  required FakeTrackingRepo trackingRepo,
}) {
  return ProviderContainer(overrides: [
    seriesRepositoryProvider.overrideWith((ref) => seriesRepo),
    trackingRepositoryProvider.overrideWith((ref) => trackingRepo),
    cacheServiceProvider.overrideWith((ref) => CacheService()),
  ]);
}
```

- [ ] **Update tracking_list_viewmodel_test.dart** similarly (add cacheServiceProvider override with `CacheService()`)

- [ ] **Add test for cache invalidation**

```dart
test('startTracking invalidates cache and refreshes', () async {
  final repo = FakeTrackingRepo();
  final cache = CacheService();
  await cache.set('dashboard', CacheEntry(
    json: '{}', cachedAt: DateTime.now(), ttl: const Duration(hours: 6),
  ));
  final container = ProviderContainer(overrides: [
    trackingRepositoryProvider.overrideWith((ref) => repo),
    cacheServiceProvider.overrideWith((ref) => cache),
  ]);
  addTearDown(container.dispose);

  await container.read(trackingListViewModelProvider.notifier).startTracking('123', 'WATCHING');

  expect(cache.getSync('dashboard'), isNull);
});
```

- [ ] **Check for direct repository mutations in widgets**

Grep for `trackingRepositoryProvider` usage outside test files:

```bash
grep -rn "trackingRepositoryProvider" lib/ --include="*.dart" | grep -v ".g.dart"
```

If any widget calls `ref.read(trackingRepositoryProvider).startTracking(...)`, replace with `ref.read(trackingListViewModelProvider.notifier).startTracking(...)`.

- [ ] **Run build_roller, analyze, tests**

```bash
dart run build_runner build --delete-conflicting-outputs
dart analyze --fatal-infos
flutter test
```

- [ ] **Commit**

```bash
git add lib/features/tracking/viewmodels/tracking_list_viewmodel.dart lib/features/tracking/viewmodels/tracking_list_viewmodel.g.dart test/features/tracking/viewmodels/tracking_list_viewmodel_test.dart
git commit -m "feat: invalidate cache on tracking mutations"
```

---

### Task 11: Clear cache on logout

**Files:**
- Modify: `lib/features/auth/viewmodels/auth_viewmodel.dart`

- [ ] **Add cache clearing to signOut**

```dart
import '../../../core/cache/cache_providers.dart';

Future<void> signOut() async {
  try {
    final repository = ref.read(authRepositoryProvider);
    await repository.signOut();
  } catch (_) {
    // Ignore sign-out errors
  }
  await ref.read(cacheServiceProvider).clearAll();
  state = const AuthState.unauthenticated();
}
```

- [ ] **Commit**

```bash
git add lib/features/auth/viewmodels/auth_viewmodel.dart
git commit -m "feat: clear cache on logout"
```

---

### Task 12: Final verification

- [ ] **Run full build_runner, analyze, and tests**

```bash
dart run build_runner build --delete-conflicting-outputs
dart analyze --fatal-infos
flutter test
make analyze
make test-coverage
```

Expected: all green

- [ ] **Commit any remaining generated files**

```bash
git add -A
git commit -m "chore: finalize client-side caching implementation"
```
