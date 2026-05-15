# Media Type apiValue Uppercase Fix

**Date:** 2026-05-15
**Status:** Draft

## Problem

When selecting "Filmes" (Movies) on the dashboard tab, the screen briefly shows loading and then displays the series dashboard instead of the movies dashboard.

### Root Cause

The backend API filters by `mediaType` parameter using case-sensitive comparison — it only recognizes uppercase `SERIES` and `MOVIE`. However, the frontend sends lowercase values:

```dart
// lib/features/tracking/data/models/media_type.dart
enum MediaType {
  series('series'),  // ← lowercase: backend doesn't recognize
  movie('movie'),    // ← lowercase: backend doesn't recognize
}
```

```dart
// Repository sends:
queryParameters: {'mediaType': mediaType.apiValue}  // 'movie' instead of 'MOVIE'
```

When the backend doesn't recognize `movie`, it falls back to default behavior (series data), so the frontend receives and displays series data after requesting movies.

## Design

Change `apiValue` in the `MediaType` enum to uppercase to match backend expectations:

```dart
// Before
enum MediaType {
  series('series'),
  movie('movie');

// After
enum MediaType {
  series('SERIES'),
  movie('MOVIE');
```

**2 lines changed** in `lib/features/tracking/data/models/media_type.dart`.

### Why Frontend Fix

- The `fromApiValue` extension already handles both cases (uses `.toLowerCase()`)
- Changing 2 lines on the frontend is faster than deploying a backend fix
- The backend should ideally be case-insensitive, but this unblocks the UI immediately

### Impact Analysis

| Area                            | Effect                                                                                                                                                        |
| ------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| API requests                    | Query parameter now sends `SERIES`/`MOVIE` (uppercase) — matches backend                                                                                      |
| Cache keys                      | Change from `dashboard:series` to `dashboard:SERIES`. Old lowercase cache entries become orphaned — no crash, just a cache miss on first load after update    |
| `fromApiValue` deserialization  | Unaffected — already uses `.toLowerCase()` internally                                                                                                         |
| `mediaTypeToJson` serialization | Now sends uppercase — this IS the fix                                                                                                                         |
| Serialized JSON in cache        | Dashboard cache entries were stored via `jsonEncode(data.toJson())` which uses `mediaTypeToJson` → now uppercase                                              |
| Rating models, tracking models  | Any model using `@JsonKey(fromJson: mediaTypeFromJson, toJson: mediaTypeToJson)` is affected for NEW writes — reading old data still works via `fromApiValue` |

### Tests to Update

- `test/features/dashboard/viewmodels/dashboard_viewmodel_test.dart`: cache key literals `'dashboard:series'` → `'dashboard:SERIES'`
- `test/features/tracking/data/models/media_type_test.dart`: verify `apiValue` returns uppercase

## Verification

1. `dart run build_runner build --delete-conflicting-outputs` — no codegen changes needed (enum change is plain Dart)
2. `dart analyze --fatal-infos` — no new warnings
3. `flutter test` — all tests pass
4. Manual: tap "Filmes" on dashboard, verify movies data loads correctly
