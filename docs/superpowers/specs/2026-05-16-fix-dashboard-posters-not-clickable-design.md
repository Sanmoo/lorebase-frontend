# Fix: Dashboard posters not clickable (JSON key mismatch)

**Date:** 2026-05-16
**Status:** Approved

## Problem

Posters on the Dashboard (and Tracking List) stopped being clickable/navigable.
Tapping a poster does nothing — no navigation to the series/movie detail page.

## Root Cause

`TrackedMediaSummaryModel` deserializes the `mediaId` field from JSON key `tmdbId`:

```dart
@JsonKey(name: 'tmdbId', ...)
@Default('') String mediaId;
```

The API, however, returns the field under the key `mediaId` (not `tmdbId`).
Because the key doesn't match, `mediaId` is always deserialized as `''` (the default).
The navigation guard `if (item.mediaId.isEmpty) return;` then silently blocks all navigation.

The mismatch was introduced in commit `d7db5ea` which changed the JSON key from the
old API shape (`tmdbId`) — but the API had already migrated to `mediaId` at that point.

## Solution

Change the `@JsonKey` annotation to read from the correct key:

```dart
// Before:
@JsonKey(name: 'tmdbId', fromJson: flexibleStringFromJson, toJson: flexibleStringToJson)
@Default('') String mediaId;

// After:
@JsonKey(name: 'mediaId', fromJson: flexibleStringFromJson, toJson: flexibleStringToJson)
@Default('') String mediaId;
```

## Files changed

| File                                                                       | Action                                                                         |
| -------------------------------------------------------------------------- | ------------------------------------------------------------------------------ |
| `lib/features/tracking/data/models/tracked_media_summary_model.dart`       | `name: 'tmdbId'` → `name: 'mediaId'`                                           |
| `test/features/dashboard/data/models/dashboard_model_test.dart`            | Fixture keys `'tmdbId'` → `'mediaId'`                                          |
| `test/features/dashboard/data/models/dashboard_section_model_test.dart`    | Fixture keys `'tmdbId'` → `'mediaId'`                                          |
| `test/features/dashboard/data/repositories/dashboard_repository_test.dart` | Fixture keys `'tmdbId'` → `'mediaId'`                                          |
| `test/features/tracking/data/models/tracked_media_summary_model_test.dart` | Fixture keys `'tmdbId'` → `'mediaId'` (where testing TrackedMediaSummaryModel) |
| `test/features/tracking/data/models/tracked_media_model_test.dart`         | Fixture keys `'tmdbId'` → `'mediaId'` (where testing TrackedMediaSummaryModel) |
| `test/features/tracking/data/repositories/tracking_repository_test.dart`   | Fixture keys `'tmdbId'` → `'mediaId'`                                          |
| `*.freezed.dart` / `*.g.dart`                                              | Regenerated via `build_runner`                                                 |

## What stays unchanged

- Navigation logic with `mediaId.isEmpty` guard — remains as safety net
- `SeriesModel.tmdbId`, `MovieModel.tmdbId`, routes `/series/:tmdbId` — different models, untouched
- `OverflowBox` in `TrackedMediaPoster` — required for Android rendering glitch workaround
- `flexibleStringFromJson` returning `''` for null — correct defensive behavior

## Verification

1. `dart analyze --fatal-infos` — no warnings/errors
2. `flutter test` — all tests pass
3. `make check` — coverage gate at 100%
4. Manual: tap a poster on Dashboard → navigates to detail page
