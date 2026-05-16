# Fix Dashboard Posters Not Clickable — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Align `TrackedMediaSummaryModel` JSON deserialization key from `tmdbId` to `mediaId` so the Dashboard and Tracking List posters become navigable again.

**Architecture:** Single-line model fix — change `@JsonKey(name:)` in `TrackedMediaSummaryModel`. Update all test fixtures that use `TrackedMediaSummaryModel` JSON to use `mediaId` key. Regenerate Freezed/json_serializable code. The navigation guard `mediaId.isEmpty` stays as safety net.

**Tech Stack:** Dart, Freezed, json_serializable, build_runner

---

### Task 1: Fix the model — align JSON key

**Files:**

- Modify: `lib/features/tracking/data/models/tracked_media_summary_model.dart`

- [ ] **Step 1: Change `@JsonKey(name: 'tmdbId')` to `@JsonKey(name: 'mediaId')`**

```dart
// Before (line 22):
      name: 'tmdbId',

// After:
      name: 'mediaId',
```

- [ ] **Step 2: Verify the change looks correct**

Read the file; line 22 should now read `name: 'mediaId'`.

---

### Task 2: Update test fixtures — Dashboard tests

**Files:**

- Modify: `test/features/dashboard/data/models/dashboard_model_test.dart`
- Modify: `test/features/dashboard/data/models/dashboard_section_model_test.dart`
- Modify: `test/features/dashboard/data/repositories/dashboard_repository_test.dart`

- [ ] **Step 1: Update `dashboard_model_test.dart`**

Two fixtures use `'tmdbId'` — change key to `'mediaId'`:

```dart
// Line 13:
{'mediaId': 1, 'title': 'Watching Series', 'mediaType': 'series'},

// Line 20:
{'mediaId': 2, 'title': 'Want To Watch Series', 'mediaType': 'series'},
```

- [ ] **Step 2: Update `dashboard_section_model_test.dart`**

```dart
// Line 11:
{'mediaId': 1, 'title': 'Series A', 'mediaType': 'series'},

// Line 12:
{'mediaId': 2, 'title': 'Movie B', 'mediaType': 'movie'},
```

- [ ] **Step 3: Update `dashboard_repository_test.dart`**

```dart
// Line 44, inside _dashboardJson():
'mediaId': 1,
```

---

### Task 3: Update test fixtures — Tracking tests

**Files:**

- Modify: `test/features/tracking/data/models/tracked_media_summary_model_test.dart`
- Modify: `test/features/tracking/data/models/tracked_media_model_test.dart`
- Modify: `test/features/tracking/data/repositories/tracking_repository_test.dart`

- [ ] **Step 1: Update `tracked_media_summary_model_test.dart`**

Four JSON fixtures use `'tmdbId'` — change all to `'mediaId'`:

```dart
// Line 8 (test: "parses summary payload with tmdbId as int"):
'mediaId': 10,

// Line 22 (test: "handles missing mediaType"):
'mediaId': 42,

// Line 33 (test: "defaults mediaId to empty string when tmdbId is absent"):
// This test's JSON has NO mediaId key — keep it that way (tests absence).

// Line 69 (test: "throws FormatException for invalid mediaType type"):
'mediaId': 1,
```

Also update test description strings that mention "tmdbId":

```dart
// Line 6: rename test from "with tmdbId" to "with mediaId"
test('fromJson parses summary payload with mediaId as int (API shape)', () {

// Line 31: rename test from "when tmdbId is absent" to "when mediaId is absent"
test('fromJson defaults mediaId to empty string when mediaId is absent', () {
```

- [ ] **Step 2: Update `tracked_media_model_test.dart`**

The nested `media` field uses `TrackedMediaSummaryModel.fromJson`:

```dart
// Line 21:
'mediaId': 42,
```

- [ ] **Step 3: Update `tracking_repository_test.dart`**

The nested `media` field in `_trackingJson()`:

```dart
// Line 48:
'mediaId': 123,
```

---

### Task 4: Regenerate codegen and run tests

- [ ] **Step 1: Run build_runner**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: completes without errors. Confirm `tracked_media_summary_model.g.dart` was regenerated.

- [ ] **Step 2: Run all tests**

```bash
flutter test
```

Expected: all tests pass (including the previously-passing ones).

- [ ] **Step 3: Run analyze and coverage gate**

```bash
make check
```

Expected: `dart analyze --fatal-infos` passes, coverage at 100%.

- [ ] **Step 4: Commit**

```bash
git add lib/features/tracking/data/models/tracked_media_summary_model.dart
git add lib/features/tracking/data/models/tracked_media_summary_model.freezed.dart
git add lib/features/tracking/data/models/tracked_media_summary_model.g.dart
git add test/features/dashboard/data/models/dashboard_model_test.dart
git add test/features/dashboard/data/models/dashboard_section_model_test.dart
git add test/features/dashboard/data/repositories/dashboard_repository_test.dart
git add test/features/tracking/data/models/tracked_media_summary_model_test.dart
git add test/features/tracking/data/models/tracked_media_model_test.dart
git add test/features/tracking/data/repositories/tracking_repository_test.dart
git commit -m "fix: align TrackedMediaSummaryModel JSON key from tmdbId to mediaId

API returns mediaId, not tmdbId. Model @JsonKey(name:) was reading the
wrong key, causing mediaId to always be empty string. The navigation
guard then silently blocked all poster taps on Dashboard and Tracking."

git add docs/superpowers/plans/2026-05-16-fix-dashboard-posters-not-clickable.md
git commit -m "docs: add implementation plan for dashboard posters clickable fix"
```
