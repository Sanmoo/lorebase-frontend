# SeriesModel API Contract Alignment — Design

**Date:** 2026-05-04
**Status:** Approved for Implementation
**Scope:** Fix `type 'Null' is not a subtype of type 'String'` crash on Search tab
**Bug:** Series search page crashes when API returns results — `seriesId` field is missing from response
**Tech Stack:** Flutter 3.x, Freezed, json_serializable, build_runner

---

## 1. Executive Summary

The search tab crashes with `type 'Null' is not a subtype of type 'String' in type cast` because the `SeriesModel` expects a required non-nullable `seriesId: String` field, but the remote API (`https://mp3qfskis4.execute-api.us-east-1.amazonaws.com`) does not include `seriesId` in its `/series` search response. The API uses `tmdbId` (integer) as the unique series identifier.

**Key Decision:** Remove `seriesId` from `SeriesModel` and use `tmdbId` as the canonical series identifier throughout the app. No UI code references `series.seriesId`, so this is a safe, low-impact change.

---

## 2. Root Cause Analysis

### API Response (actual, via `GET /series?q=breaking&limit=20`)

```json
{
  "items": [
    {
      "tmdbId": 1396,
      "title": "Breaking Bad",
      "overview": "Ao saber que tem câncer...",
      "posterPath": "https://image.tmdb.org/t/p/w500/...",
      "genres": ["Drama"]
    }
  ],
  "query": "breaking",
  "count": 20
}
```

Fields present in every item: `tmdbId`, `title`, `overview`, `genres`.
Fields sometimes present: `posterPath`.
Fields **never** present: `seriesId`, `backdropPath`, `firstAirDate`, `networks`, `seasonCount`, `status`.

### Crash Point

`series_model.g.dart:11`:

```dart
seriesId: json['seriesId'] as String,  // null as String → crash
```

`json['seriesId']` returns `null` (key doesn't exist), and the `as String` cast fails with `type 'Null' is not a subtype of type 'String' in type cast`.

### Affected vs. Unaffected Fields

| Field        | Model Type    | In API Response | Status           |
| ------------ | ------------- | --------------- | ---------------- |
| `seriesId`   | `String` (req)  | **No**              | **CRASH**            |
| `tmdbId`     | `int` (req)     | Yes             | OK               |
| `title`      | `String` (req)  | Yes             | OK               |
| `overview`   | `String?`       | Yes (sometimes "")   | OK               |
| `posterPath` | `String?`       | Sometimes       | OK               |
| `genres`     | `List<String>`  | Yes (default [])    | OK               |
| All others   | nullable/default| No              | OK               |

---

## 3. Design: Remove `seriesId` from SeriesModel

### Before

```dart
@freezed
class SeriesModel with _$SeriesModel {
  const factory SeriesModel({
    required String seriesId,   // ← REMOVED
    required int tmdbId,
    required String title,
    ...
  }) = _SeriesModel;
}
```

### After

```dart
@freezed
class SeriesModel with _$SeriesModel {
  const factory SeriesModel({
    required int tmdbId,
    required String title,
    String? overview,
    String? posterPath,
    String? backdropPath,
    String? firstAirDate,
    @Default([]) List<String> genres,
    @Default([]) List<String> networks,
    @Default(0) int seasonCount,
    String? status,
  }) = _SeriesModel;

  factory SeriesModel.fromJson(Map<String, dynamic> json) =>
      _$SeriesModelFromJson(json);
}
```

### Rationale

- `seriesId` is never consumed by any widget, viewmodel, or repository outside generated code
- The tracking module has its own `TrackedSeriesModel.seriesId` — a separate concept, not coupled to `SeriesModel`
- If a string identifier is ever needed, it can be derived: `tmdbId.toString()`
- Removing it is safer than making it nullable (which would silently propagate nulls)

---

## 4. Implementation Steps

1. Edit `lib/features/series/data/models/series_model.dart` — remove `seriesId` field
2. Run `dart run build_runner build --delete-conflicting-outputs` to regenerate `series_model.g.dart` and `series_model.freezed.dart`
3. Run `flutter analyze` — must pass with zero errors
4. Run `flutter test` — all existing tests must pass
5. Run `flutter build apk --debug` — build must succeed

### Files Modified

- `lib/features/series/data/models/series_model.dart` (hand-edited)
- `lib/features/series/data/models/series_model.g.dart` (regenerated)
- `lib/features/series/data/models/series_model.freezed.dart` (regenerated)

---

## 5. Verification

| Check                        | Command                     | Expected       |
| ---------------------------- | --------------------------- | -------------- |
| Static analysis              | `flutter analyze`             | 0 errors       |
| Unit/widget tests            | `flutter test`                | All pass       |
| Build (debug APK)            | `flutter build apk --debug`   | Success        |
| Runtime: search for "break"  | Manual on device             | Results render |

---

## 6. Risk Assessment

- **Risk:** Very low. No consumers of `seriesId` exist in the app code.
- **Rollback:** Trivial — restore the field and regenerate.
- **Side effects:** None expected.
