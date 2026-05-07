# Design: Conditional Display of seasonCount

**Date**: 2026-05-07
**Status**: Approved

## Context

`seasonCount` in `SeriesModel` defaults to `0` (`@Default(0)`) and the JSON parser applies `?? 0` when the field is missing or null from the API. The UI currently displays `seasonCount` unconditionally, resulting in "0 seasons" / "0" being shown even when the data was not provided by the backend.

## Requirements

- Hide season count text when `seasonCount` is 0 or absent from the API
- Display season count normally when `seasonCount > 0`
- For the InfoCard on the detail page, show `'—'` (dash) instead of "0", following the existing project convention (e.g., `firstAirDate ?? '—'`)

## Decision: Approach A — UI-Level Conditional

Only the three UI display locations are modified. The model (`SeriesModel`) and JSON deserialization remain unchanged.

**Rationale**: Since the requirement is to hide both `0` and absent values, there is no need to distinguish between them at the model layer. UI-level conditionals are the simplest change with zero impact on other consumers of the model.

## Changes

### 1. `lib/features/series/widgets/series_card.dart` (line 62)

Wrap season count text with `if (series.seasonCount > 0)`:

```dart
if (series.seasonCount > 0)
  Text(
    '${series.seasonCount} season${series.seasonCount != 1 ? 's' : ''}',
    style: Theme.of(context).textTheme.bodySmall,
  ),
```

### 2. `lib/features/series/pages/series_detail_page.dart` (line 359)

Wrap season count text with `if (series.seasonCount > 0)`:

```dart
if (series.seasonCount > 0)
  Text(
    '${series.seasonCount} season${series.seasonCount != 1 ? 's' : ''}',
    style: theme.textTheme.bodyMedium,
  ),
```

### 3. `lib/features/series/pages/series_detail_page.dart` (line 394)

Replace `'${series.seasonCount}'` with conditional to show `'—'` when 0:

```dart
value: series.seasonCount > 0 ? '${series.seasonCount}' : '—',
```

## Unchanged

- `lib/features/series/data/models/series_model.dart` — `@Default(0) int seasonCount` stays
- `lib/features/series/data/models/series_model.g.dart` — `?? 0` stays
- No code regeneration needed

## Verification

| seasonCount | Detail Page Text (line 359) | InfoCard (line 394) | SeriesCard (line 62) |
| ----------- | --------------------------- | ------------------- | -------------------- |
| 0           | Hidden                      | `'—'`               | Hidden               |
| 1           | "1 season"                 | `'1'`               | "1 season"           |
| 5           | "5 seasons"                | `'5'`               | "5 seasons"          |
