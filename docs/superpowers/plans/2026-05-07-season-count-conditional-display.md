# Season Count Conditional Display Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Hide season count text in the UI when `seasonCount` is 0, and show `'—'` in the InfoCard instead.

**Architecture:** Three UI-level conditional changes across two files. No model or JSON parsing changes. The rule `seasonCount > 0` gates text display; the InfoCard falls back to `'—'` following existing project convention.

**Tech Stack:** Flutter, Dart, flutter_test (widget tests)

---

### Task 1: Write widget test for SeriesCard — hides season text when count is 0

**Files:**
- Create: `test/features/series/widgets/series_card_test.dart`

- [ ] **Step 1: Write the failing widget test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/series/data/models/series_model.dart';
import 'package:lorebase/features/series/widgets/series_card.dart';

void main() {
  group('SeriesCard', () {
    testWidgets('hides season count text when seasonCount is 0', (tester) async {
      final series = SeriesModel(
        tmdbId: 1,
        title: 'Test Series',
        seasonCount: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SeriesCard(series: series),
          ),
        ),
      );

      expect(find.textContaining('0 season'), findsNothing);
    });

    testWidgets('shows season count text when seasonCount is greater than 0', (tester) async {
      final series = SeriesModel(
        tmdbId: 1,
        title: 'Test Series',
        seasonCount: 5,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SeriesCard(series: series),
          ),
        ),
      );

      expect(find.textContaining('5 season'), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/features/series/widgets/series_card_test.dart`
Expected: 1st test FAILS with "finds nothing" assertion error (finds "0 seasons" text currently)

- [ ] **Step 3: Commit test skeleton**

```bash
git add test/features/series/widgets/series_card_test.dart
git commit -m "test: add SeriesCard season count display tests"
```

---

### Task 2: Modify SeriesCard widget — conditionally hide season text

**Files:**
- Modify: `lib/features/series/widgets/series_card.dart:60-64`

- [ ] **Step 1: Wrap season count Text with conditional**

In `lib/features/series/widgets/series_card.dart`, change lines 60-64 from:

```dart
                    const SizedBox(height: 4),
                    Text(
                      '${series.seasonCount} season${series.seasonCount != 1 ? 's' : ''}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
```

To:

```dart
                    const SizedBox(height: 4),
                    if (series.seasonCount > 0)
                      Text(
                        '${series.seasonCount} season${series.seasonCount != 1 ? 's' : ''}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
```

- [ ] **Step 2: Run tests to verify they pass**

Run: `flutter test test/features/series/widgets/series_card_test.dart`
Expected: Both tests PASS

- [ ] **Step 3: Commit**

```bash
git add lib/features/series/widgets/series_card.dart
git commit -m "fix: hide season count text in SeriesCard when count is 0"
```

---

### Task 3: Modify series_detail_page.dart — conditionally hide season text and show '—' in InfoCard

**Files:**
- Modify: `lib/features/series/pages/series_detail_page.dart:356-367` (Row with season text)
- Modify: `lib/features/series/pages/series_detail_page.dart:390-395` (InfoCard Seasons)

- [ ] **Step 1: Wrap season text in Row with conditional (lines 356-367)**

Change:

```dart
                  Row(
                    children: [
                      Text(
                        '${series.seasonCount} season${series.seasonCount != 1 ? 's' : ''}',
                        style: theme.textTheme.bodyMedium,
                      ),
                      if (tracking != null) ...[
                        const SizedBox(width: 12),
                        TrackingStatusChip(status: tracking!.status),
                      ],
                    ],
                  ),
```

To:

```dart
                  Row(
                    children: [
                      if (series.seasonCount > 0)
                        Text(
                          '${series.seasonCount} season${series.seasonCount != 1 ? 's' : ''}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      if (tracking != null) ...[
                        const SizedBox(width: 12),
                        TrackingStatusChip(status: tracking!.status),
                      ],
                    ],
                  ),
```

- [ ] **Step 2: Change InfoCard value to show '—' when seasonCount is 0 (line 394)**

Change:

```dart
                          value: '${series.seasonCount}',
```

To:

```dart
                          value: series.seasonCount > 0 ? '${series.seasonCount}' : '—',
```

- [ ] **Step 3: Run static analysis**

Run: `flutter analyze lib/features/series/pages/series_detail_page.dart lib/features/series/widgets/series_card.dart`
Expected: No issues found

- [ ] **Step 4: Commit**

```bash
git add lib/features/series/pages/series_detail_page.dart
git commit -m "fix: hide season count in detail page when count is 0, show dash in InfoCard"
```

---

### Task 4: Run full test suite

- [ ] **Step 1: Run all tests**

Run: `flutter test`
Expected: All tests pass

---

### Task 5: Manual verification

- [ ] **Step 1: Run the app and verify behavior**

Run: `flutter run`

Verify scenarios:
| Scenario                  | SeriesCard     | Detail Page Text       | InfoCard "Seasons" |
| ------------------------- | -------------- | ---------------------- | ------------------ |
| Series with seasonCount 0 | No season text | No season text in Row  | Shows `'—'`        |
| Series with seasonCount 1 | "1 season"     | "1 season"            | Shows `'1'`        |
| Series with seasonCount 5 | "5 seasons"    | "5 seasons"           | Shows `'5'`        |
