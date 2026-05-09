# Tracking List: Rating Stars Instead of Status Chip

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace redundant `TrackingStatusChip` with `RatingStars` in the tracking list grid items.

**Architecture:** Single-line swap in the grid `itemBuilder` of `tracking_list_page.dart` — replace `TrackingStatusChip(status: tracking.status)` with `RatingStars(rating: tracking.seriesRating, size: 12)`. The `RatingStars` widget already handles `null` rating (shows all empty stars).

**Tech Stack:** Flutter, Dart

---

### Task 1: Update test to verify RatingStars instead of chip

**Files:**
- Modify: `test/features/tracking/pages/tracking_list_page_test.dart:194-206`

- [ ] **Step 1: Replace the 'shows TrackingStatusChip' test with 'shows rating stars'**

Replace the `shows TrackingStatusChip per item` test:

```dart
    testWidgets('shows rating stars per item', (tester) async {
      final trackings = [
        _tracking('t1', 'WATCHING', series: _series(1)),
      ];
      final fakeVM = FakeTrackingListVM(state: AsyncValue.data(trackings));
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);
      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(RatingStars), findsOneWidget);
    });
```

- [ ] **Step 2: Add RatingStars import to test file**

Add after line 2 (`import 'package:flutter/material.dart';`):

```dart
import 'package:lorebase/features/tracking/widgets/rating_stars.dart';
```

- [ ] **Step 3: Run test to verify it fails**

Run: `flutter test test/features/tracking/pages/tracking_list_page_test.dart -v`
Expected: FAIL — RatingStars not found (still showing chip)

### Task 2: Replace chip with rating stars in tracking list page

**Files:**
- Modify: `lib/features/tracking/pages/tracking_list_page.dart:117-118`

- [ ] **Step 1: Replace TrackingStatusChip with RatingStars**

Change:

```dart
                            const SizedBox(height: 4),
                            TrackingStatusChip(status: tracking.status),
```

to:

```dart
                            const SizedBox(height: 4),
                            RatingStars(
                              rating: tracking.seriesRating,
                              size: 12,
                            ),
```

- [ ] **Step 2: Remove unused TrackingStatusChip import**

Remove line 11 in the file:

```dart
import '../widgets/tracking_status_chip.dart';
```

- [ ] **Step 3: Run the test to verify it passes**

Run: `flutter test test/features/tracking/pages/tracking_list_page_test.dart -v`
Expected: PASS — 9/9 tests pass

### Task 3: Verify full suite and commit

- [ ] **Step 1: Run full test suite**

Run: `flutter test`
Expected: All tests pass

- [ ] **Step 2: Commit**

```bash
git add lib/features/tracking/pages/tracking_list_page.dart \
       test/features/tracking/pages/tracking_list_page_test.dart
git commit -m "feat: replace redundant status chip with rating stars in tracking list"
```
