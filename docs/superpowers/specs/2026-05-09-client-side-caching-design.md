# Client-Side Caching for Dashboard and Tracking

## Problem

Every navigation to the Dashboard or Tracking List pages triggers a fresh HTTP request. This causes unnecessary network usage and a loading spinner on every visit, even when data hasn't changed.

## Goals

- Show cached data instantly on repeat visits (no loading flash)
- Refresh data in background when cache is stale (stale-while-revalidate)
- Persist cache to disk via Hive so it survives app restarts
- Keep pull-to-refresh working as a manual override
- Keep existing ViewModel/Repository patterns with minimal disruption

## Non-Goals

- Caching mutation endpoints (POST/PUT/DELETE) — only GET responses for dashboard and tracking list
- Offline-first mode — app still requires network; cache is a UX optimization, not an offline enabler
- Shared caching across users — cache is per-device, per-user session (cleared on logout)

## Architecture

### CacheEntry (`lib/core/cache/cache_entry.dart`)

```dart
class CacheEntry {
  final String json;         // Raw JSON payload
  final DateTime cachedAt;   // When it was stored
  final Duration ttl;        // Time-to-live (6 hours)

  bool get isFresh => DateTime.now().isBefore(cachedAt.add(ttl));
}
```

### CacheService (`lib/core/cache/cache_service.dart`)

Coordinates memory and disk layers:

- `getSync(key)` → `CacheEntry?` — synchronous memory lookup. Returns instantly or null.
- `getFromDisk(key)` → `Future<CacheEntry?>` — async Hive lookup.
- `set(key, entry)` → saves to memory + Hive.
- `remove(key)` → removes from memory + Hive.
- `removeByPrefix(prefix)` → iterates Hive box entries and removes matching keys.

Memory cache is a `Map<String, CacheEntry>`. Disk cache is a single Hive box (`cacheBox`).

### ViewModel Integration

**`DashboardViewModel`** and **`TrackingListViewModel`** follow the same flow:

```
build() / loadTracking():
  1. cacheService.getSync(key)
     → hit: return data synchronously (no loading state shown)
  2. cacheService.getFromDisk(key)
     → hit: hydrate memory cache
       → if fresh: return data (no background refresh)
       → if stale: return data + fire background refresh
  3. fetch from repository
     → cacheService.set(key, entry)
     → return data

refresh() (pull-to-refresh):
  → cacheService.remove(key)
  → fetch from repository
  → cacheService.set(key, entry)

background refresh:
  → fetch from repository
  → cacheService.set(key, entry)
  → state = AsyncData(data)  // silently updates UI
  → on error: stale data stays visible (state unchanged) + show SnackBar "Could not refresh. Pull down to retry."
```

### Cache Keys

| Data                      | Key pattern                     |
| ------------------------- | ------------------------------- |
| Dashboard                 | `dashboard`                     |
| Tracking list by status   | `tracking:<status>:<page>`      |
| e.g. watching page 1      | `tracking:WATCHING:1`           |
| e.g. completed page 2     | `tracking:COMPLETED:2`          |

## Cache Invalidation

| Trigger                         | Action                                         |
| ------------------------------- | ---------------------------------------------- |
| TTL expired (6h)                | Stale-while-revalidate (show stale, bg refresh) |
| Pull-to-refresh (dashboard)     | `remove('dashboard')` + fetch                    |
| Pull-to-refresh (tracking list) | `removeByPrefix('tracking:')` + fetch            |
| `startTracking(...)`              | `remove('dashboard')` + `removeByPrefix('tracking:')` |
| `updateTracking(...)`             | `remove('dashboard')` + `removeByPrefix('tracking:')` |
| `deleteTracking(...)`             | `remove('dashboard')` + `removeByPrefix('tracking:')` |
| Logout                          | Clear entire cache box                         |

## Files to Create

| File                           | Content                    |
| ------------------------------ | -------------------------- |
| `lib/core/cache/cache_entry.dart` | CacheEntry model         |
| `lib/core/cache/cache_service.dart` | CacheService class     |
| `lib/core/cache/cache_providers.dart` | `hiveCacheBoxProvider`, `cacheServiceProvider` |

## Files to Modify

| File                                                       | Change                                               |
| ---------------------------------------------------------- | ---------------------------------------------------- |
| `lib/features/dashboard/viewmodels/dashboard_viewmodel.dart` | build() uses cache; refresh() invalidates + fetches |
| `lib/features/tracking/viewmodels/tracking_list_viewmodel.dart` | build() uses cache; refresh/loadMore invalidate + fetch |
| `lib/features/tracking/viewmodels/tracking_list_viewmodel.dart` | Mutation methods invalidate cache before delegating to repository |
| `lib/main.dart`                                           | Initialize Hive before `runApp()`                    |
| `pubspec.yaml`                                            | Add `hive`, `hive_flutter` dependencies              |

## Testing

- **CacheService unit tests**: TTL boundary, stale-while-revalidate, sync vs async, invalidation
- **CacheEntry unit tests**: `isFresh` at exact TTL boundary
- **DashboardViewModel tests**: override `cacheServiceProvider` with fake to verify cache-hit vs cache-miss behavior
- **TrackingListViewModel tests**: same pattern, verify per-status cache keys
- **Mutation invalidation tests**: verify that tracking mutations call `remove` on relevant cache keys
