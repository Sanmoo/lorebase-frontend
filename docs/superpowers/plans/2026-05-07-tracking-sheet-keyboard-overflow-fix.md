# Tracking Sheet Keyboard Overflow Fix — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix "Bottom overflowed by 143 pixels" error when tapping the review TextField in the "Add to List" / "Manage Tracking" bottom sheet on Android.

**Architecture:** Wrap the `Column` inside `_showTrackingSheet`'s builder with a `SingleChildScrollView` so the content scrolls when the keyboard reduces available viewport space. The Column keeps `MainAxisSize.min` so behavior is identical when the keyboard is closed.

**Tech Stack:** Flutter 3.x, Dart, Material 3

**Spec:** `docs/superpowers/specs/2026-05-07-tracking-sheet-keyboard-overflow-fix-design.md`

---

### File Structure

| Action | File | Purpose |
|--------|------|---------|
| Modify | `lib/features/series/pages/series_detail_page.dart:61-206` | Wrap Column with SingleChildScrollView |

---

### Task 1: Wrap bottom sheet Column with SingleChildScrollView

**Files:**
- Modify: `lib/features/series/pages/series_detail_page.dart:61-206`

- [ ] **Step 1: Read the current `_showTrackingSheet` builder structure to confirm line numbers**

Run: `sed -n '60,70p' lib/features/series/pages/series_detail_page.dart`
Run: `sed -n '200,210p' lib/features/series/pages/series_detail_page.dart`

- [ ] **Step 2: Wrap the Column in SingleChildScrollView**

In `lib/features/series/pages/series_detail_page.dart`, change:

```dart
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
```

To:

```dart
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
```

And change the closing:

```dart
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
```

To:

```dart
                  ],
                ),
              ),
              ),
            ),
          ),
        ),
      ),
    );
```

- [ ] **Step 3: Run static analysis**

Run: `flutter analyze`
Expected: 0 errors (LSP errors in `.worktrees/` and pre-existing test files are unrelated and pre-existing)

- [ ] **Step 4: Run existing tests**

Run: `flutter test`
Expected: All tests pass, no regressions

- [ ] **Step 5: Commit**

```bash
git add lib/features/series/pages/series_detail_page.dart
git commit -m "fix: wrap tracking bottom sheet Column with SingleChildScrollView to prevent keyboard overflow"
```
