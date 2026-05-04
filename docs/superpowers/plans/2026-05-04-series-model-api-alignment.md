# SeriesModel API Contract Alignment — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix `type 'Null' is not a subtype of type 'String'` crash on Search tab by removing the non-existent `seriesId` field from `SeriesModel`.

**Architecture:** Drop `seriesId` from the Freezed model factory. The field is not returned by the API and not consumed by any widget, viewmodel, or repository. Regenerate serialization code via `build_runner`.

**Tech Stack:** Flutter 3.x, Freezed, json_serializable, build_runner

---

### Task 1: Remove `seriesId` and regenerate

**Files:**
- Modify: `lib/features/series/data/models/series_model.dart`
- Regenerate (auto): `lib/features/series/data/models/series_model.g.dart`
- Regenerate (auto): `lib/features/series/data/models/series_model.freezed.dart`

- [ ] **Step 1: Remove `seriesId` from the model factory**

In `lib/features/series/data/models/series_model.dart`, remove `required String seriesId,` from the factory constructor:

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

- [ ] **Step 2: Regenerate serialization code**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: Build completes without errors. `series_model.g.dart` and `series_model.freezed.dart` are regenerated.

- [ ] **Step 3: Run static analysis**

```bash
flutter analyze
```

Expected: `No issues found!` (0 errors, 0 warnings).

- [ ] **Step 4: Run existing tests**

```bash
flutter test
```

Expected: All tests pass. No regressions.

- [ ] **Step 5: Verify debug build succeeds**

```bash
flutter build apk --debug
```

Expected: `✓ Built build/app/outputs/flutter-apk/app-debug.apk`.

- [ ] **Step 6: Commit**

```bash
git add lib/features/series/data/models/series_model.dart \
        lib/features/series/data/models/series_model.g.dart \
        lib/features/series/data/models/series_model.freezed.dart
git commit -m "fix: remove seriesId from SeriesModel to align with API contract"
```
