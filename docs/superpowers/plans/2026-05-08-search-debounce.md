# Search Debounce Increase Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Increase series search debounce from 300ms to 1s and extract the value to `AppConstants`.

**Architecture:** Extract hardcoded `Duration(milliseconds: 300)` on `series_search_page.dart:33` into a named constant `kSearchDebounceDuration` in `AppConstants`, then update the 3 test assertions that wait for the debounce to fire.

**Tech Stack:** Dart, Flutter, Riverpod

---

### Task 1: Add debounce constant to AppConstants

**Files:**
- Modify: `lib/core/constants/app_constants.dart:1-5`
- No test changes needed (pure constant extraction)

- [ ] **Step 1: Add constant**

```dart
abstract class AppConstants {
  static const double minTouchTarget = 48.0;
  static const double cardBorderRadius = 12.0;
  static const double posterAspectRatio = 2 / 3;
  static const kSearchDebounceDuration = Duration(seconds: 1);
}
```

- [ ] **Step 2: Verify file still parses**

Run: `dart analyze lib/core/constants/app_constants.dart`
Expected: No issues found

- [ ] **Step 3: Commit**

```bash
git add lib/core/constants/app_constants.dart
git commit -m "feat: add kSearchDebounceDuration constant to AppConstants"
```

---

### Task 2: Replace hardcoded debounce with constant

**Files:**
- Modify: `lib/features/series/pages/series_search_page.dart:6-9` (add import), `lib/features/series/pages/series_search_page.dart:33` (use constant)

- [ ] **Step 1: Add import for AppConstants**

Add after line 10 (`import '../widgets/series_card.dart';`):

```dart
import '../../../../core/constants/app_constants.dart';
```

- [ ] **Step 2: Replace hardcoded Duration**

Change line 33 from:

```dart
      _debounceTimer = Timer(const Duration(milliseconds: 300), () {
```

to:

```dart
      _debounceTimer = Timer(AppConstants.kSearchDebounceDuration, () {
```

- [ ] **Step 3: Verify file still parses**

Run: `dart analyze lib/features/series/pages/series_search_page.dart`
Expected: No issues found

- [ ] **Step 4: Commit**

```bash
git add lib/features/series/pages/series_search_page.dart
git commit -m "feat: use AppConstants.kSearchDebounceDuration in series search"
```

---

### Task 3: Update test timing for 1s debounce

**Files:**
- Modify: `test/features/series/pages/series_search_page_test.dart:176`, `:195`, `:209`

- [ ] **Step 1: Update pump durations from 400ms to 1100ms**

Three locations need the same change:

Line 176 (`test('typing text triggers debounced search')`):
```dart
      await tester.pump(const Duration(milliseconds: 1100));
```

Line 195 (`test('retry button calls search')`):
```dart
      await tester.pump(const Duration(milliseconds: 1100));
```

Line 209 (`test('typing text triggers onChanged with debounce')`):
```dart
      await tester.pump(const Duration(milliseconds: 1100));
```

- [ ] **Step 2: Run tests**

Run: `flutter test test/features/series/pages/series_search_page_test.dart`
Expected: All 11 tests PASS

- [ ] **Step 3: Run full analyze**

Run: `dart analyze`
Expected: No new issues (pre-existing authRedirect errors in router_test.dart are unrelated)

- [ ] **Step 4: Commit**

```bash
git add test/features/series/pages/series_search_page_test.dart
git commit -m "test: update debounce timing from 300ms to 1s"
```
