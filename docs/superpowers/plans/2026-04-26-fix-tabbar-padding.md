# Fix TabBar Padding for Tracking List

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix asymmetric left/right padding on scrollable TabBar in tracking list page by zeroing out the default Material insets.

**Architecture:** Add `padding: EdgeInsets.zero` and `indicatorPadding: EdgeInsets.zero` to the existing `TabBar` widget while keeping `isScrollable: true`.

**Tech Stack:** Flutter 3.x, Material 3

---

## Task 1: Fix TabBar Padding

**Files:**
- Modify: `lib/features/tracking/pages/tracking_list_page.dart:57-63`

- [ ] **Step 1: Update TabBar padding**

Replace the `TabBar` configuration in `tracking_list_page.dart` lines 57-63:

```dart
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          padding: EdgeInsets.zero,
          indicatorPadding: EdgeInsets.zero,
          tabs: TrackingStatus.values
              .map((s) => Tab(text: s.label))
              .toList(),
        ),
```

The two added lines:
- `padding: EdgeInsets.zero` — removes the default 52dp horizontal padding that Material 3 applies to scrollable TabBars
- `indicatorPadding: EdgeInsets.zero` — aligns the ink indicator with the tab edges

- [ ] **Step 2: Verify with hot reload**

Run `flutter run` and navigate to the My Lists page. Verify that:
- First tab "Watching" left margin matches "Dropped" right margin
- All four tabs are evenly spaced

Expected: Symmetric padding on both ends of the TabBar.

- [ ] **Step 3: Commit**

```bash
git add lib/features/tracking/pages/tracking_list_page.dart
git commit -m "fix(tracking): fix asymmetric TabBar padding in tracking list"
```

---

*End of Implementation Plan*
