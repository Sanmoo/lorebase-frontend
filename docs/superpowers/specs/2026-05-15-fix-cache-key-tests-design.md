# Fix Cache Key Mismatch in TrackingListViewModel Tests

## Problem

3 tests in `tracking_list_viewmodel_test.dart` fail because cache keys are hardcoded
with lowercase `series`, but `MediaType.series.apiValue` was changed to uppercase
`SERIES` in commit `fe0f4a7`.

**Root cause**: The viewmodel's `_buildCacheKey()` uses `_currentMediaType.apiValue`
(`SERIES`), but tests populate the cache with hardcoded `tracking:series:...` keys
(lowercase). This causes a cache miss, and the fake repository has no results
configured for the fallback path.

### Failing tests

| Test | Expected | Actual | Reason |
|------|----------|--------|--------|
| `returns cached data from memory` | length=1 | 0 | Cache miss → `_fetch` with empty repo results |
| `triggers background refresh when cache is stale` | getTrackingCallCount=1 | 2 | Cache miss → `_fetch` path instead of stale-cache path |
| `background refresh failure sets error provider on stale cache` | error!=null | null | Cache miss → `_fetch` succeeds (repo not throwing yet) |

## Design

### Approach

Replace hardcoded cache key strings with references to `MediaType.series.apiValue`
so tests stay in sync with the enum contract.

### Changes (single file)

**File**: `test/features/tracking/viewmodels/tracking_list_viewmodel_test.dart`

Three string replacements:

```
'tracking:series:WATCHING:1' → 'tracking:${MediaType.series.apiValue}:WATCHING:1'
```

The file already imports `media_type.dart`, no new imports needed.

### Verification

```bash
flutter test test/features/tracking/viewmodels/tracking_list_viewmodel_test.dart
```

All tests in the file must pass.
