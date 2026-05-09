# Tracking List: Fix Bottom Overflow in Cards

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix "bottom overflowed by xx pixels" in every tracking list card by making `SeriesPoster` adapt to the grid cell width.

**Architecture:** Wrap `SeriesPoster` in a `LayoutBuilder` so it receives the actual cell width from `constraints.maxWidth` instead of the hardcoded default `120`. The `SeriesPoster` already accepts `width` as a parameter — just needs to be passed the right value.

**Tech Stack:** Flutter, Dart

---

### Task 1: Wrap SeriesPoster in LayoutBuilder

**Files:**
- Modify: `lib/features/tracking/pages/tracking_list_page.dart:109-115`

- [ ] **Step 1: Wrap SeriesPoster in LayoutBuilder**

Change lines 109-115:

```dart
                            Expanded(
                              child: SeriesPoster(
                                series: series,
                                onTap: series.tmdbId != 0
                                    ? () => context.push('/series/${series.tmdbId}')
                                    : null,
                              ),
                            ),
```

to:

```dart
                            Expanded(
                              child: LayoutBuilder(
                                builder: (context, constraints) => SeriesPoster(
                                  series: series,
                                  width: constraints.maxWidth,
                                  onTap: series.tmdbId != 0
                                      ? () => context.push('/series/${series.tmdbId}')
                                      : null,
                                ),
                              ),
                            ),
```

- [ ] **Step 2: Run tests to verify nothing broke**

Run: `flutter test test/features/tracking/ -v`
Expected: All 54 tracking tests pass

### Task 2: Full suite and commit

- [ ] **Step 1: Run full test suite**

Run: `flutter test`
Expected: All tests pass

- [ ] **Step 2: Commit**

```bash
git add lib/features/tracking/pages/tracking_list_page.dart
git commit -m "fix: adapt SeriesPoster width to grid cell size via LayoutBuilder"
```
