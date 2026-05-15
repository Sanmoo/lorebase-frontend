# Flexible `tmdbId` Parsing — Design Spec

**Date:** 2026-05-15
**Status:** draft
**Context:** Movie detail page crashes with `type 'String' is not a subtype of type 'int' in type cast` when clicking a movie from search results.

## Problem

The backend API returns `tmdbId` inconsistently:
- `GET /movies?q=...` (search): `tmdbId` as `int`
- `GET /movies/{id}` (detail): `tmdbId` as `String`

Both endpoints are parsed by `MovieModel.fromJson()`, whose generated code does `json['tmdbId'] as int`. The detail endpoint fails because the value is a String.

The same risk exists for `SeriesModel`, which follows the identical pattern.

## Solution

Make `fromJson` resilient to both `int` and `String` values for `tmdbId` using a custom `@JsonKey` converter — the same pattern already used in `TrackedMediaModel` for `mediaType`.

## Implementation

### 1. New utility file: `lib/core/utils/json_converters.dart`

Two free functions:

```dart
/// Parses a dynamic value (int or String) to int.
/// Throws [FormatException] if value is neither int nor String.
int flexibleIntFromJson(dynamic value) {
  if (value is int) return value;
  if (value is String) return int.parse(value);
  throw FormatException('Cannot convert $value (${value.runtimeType}) to int');
}

/// Converts int to String for JSON serialization (matches backend expectation).
int flexibleIntToJson(int value) => value;  // stays int — toJson will write as int
```

**Decision: `flexibleIntToJson` returns `int` (not `String`)**, so `toJson()` continues emitting `int`. This means:
- `fromJson` is tolerant (int ← String or int)
- `toJson` stays as-is (int → int)
- No behavioral change for serialization; only deserialization gains resilience

### 2. Annotate `MovieModel.tmdbId`

```dart
@freezed
class MovieModel with _$MovieModel {
  const factory MovieModel({
    @JsonKey(fromJson: flexibleIntFromJson, toJson: flexibleIntToJson)
    required int tmdbId,
    // ... rest unchanged
  }) = _MovieModel;
}
```

### 3. Annotate `SeriesModel.tmdbId` (preventive)

Same annotation — prevents the same bug if the series detail API has the same inconsistency.

### 4. Regenerate code

Run `dart run build_runner build --delete-conflicting-outputs`.

## Files changed

| File | Change |
|------|--------|
| `lib/core/utils/json_converters.dart` | **New** — `flexibleIntFromJson`, `flexibleIntToJson` |
| `lib/features/movies/data/models/movie_model.dart` | Add `@JsonKey` on `tmdbId` |
| `lib/features/series/data/models/series_model.dart` | Add `@JsonKey` on `tmdbId` |
| `lib/features/movies/data/models/movie_model.g.dart` | **Regenerated** |
| `lib/features/series/data/models/series_model.g.dart` | **Regenerated** |

## What this does NOT change

- `tmdbId` remains `int` in the model — all consumers (router, viewmodels, widgets) untouched
- `toJson()` continues writing `int` — no change to outgoing API calls
- Search flow, `TrackerMediaModel`, `TrackingRepository` — unaffected

## Testing

- Unit test for `flexibleIntFromJson`: verify `int` in → `int` out, `String` in → `int` out, invalid type throws
- Integration: run `flutter test --coverage --branch-coverage` and confirm no regressions
- Manual: search a movie → click it → detail page renders without crash

## Self-review

- [x] No placeholders or TODOs
- [x] Consistent with existing patterns (`@JsonKey` in `TrackedMediaModel`)
- [x] Focused scope — only `tmdbId` parsing, no unrelated changes
- [x] No ambiguity — behavior is explicit for both `int` and `String` inputs
