# Tracking Sheet Keyboard Overflow Fix — Design

**Date:** 2026-05-07
**Status:** Pending User Review
**Scope:** Fix "Bottom overflowed by 143 pixels" when keyboard opens in "Add to List" / "Manage Tracking" bottom sheet on Android
**Problem:** The showModalBottomSheet in `_showTrackingSheet` uses `isScrollControlled: true` combined with `Column(MainAxisSize.min)` without any scroll wrapper. When the Android keyboard opens, the viewInsets reduce available vertical space, but the content cannot scroll, causing a render overflow.

---

## 1. Root Cause

The bottom sheet at `series_detail_page.dart:55-209` uses:
- `isScrollControlled: true` (allows full-screen height)
- `Column` with `MainAxisSize.min` (no scroll mechanism)
- `Padding` with `viewInsets.bottom + 24` (pushes content up when keyboard opens)

When the keyboard inflates `viewInsets.bottom`, the Column's natural content height (~500px) exceeds the remaining viewport area, but there is no scroll mechanism to handle it. Result: the Column overflows by ~143px.

---

## 2. Solution

Wrap the existing `Column` inside a `SingleChildScrollView` in `_showTrackingSheet`.

### File: `lib/features/series/pages/series_detail_page.dart`

Change at line ~68, from:

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

Add closing `)` for `SingleChildScrollView` between the Column close (line 204) and Padding close (line 205).

### How it works

- `SingleChildScrollView` provides unbounded height to its child, allowing it to size to natural content
- When keyboard is closed: content fits without scroll (identical to current behavior)
- When keyboard opens: `viewInsets` shrink the viewport, content scrolls automatically
- `CrossAxisAlignment.stretch` still works because `SingleChildScrollView` (vertical) constrains width to viewport width

---

## 3. Verification

| Check | Command | Expected |
|-------|---------|----------|
| Static analysis | `flutter analyze` | 0 errors |
| Widget tests | `flutter test` | All pass |
| Manual: tap review field on Android | Device/emulator | Content scrolls, no overflow error |
| Manual: tap review field on iOS | Device/emulator | No regression |
| Manual: keyboard closed behavior | Device/emulator | Identical to before (no scroll, all buttons visible) |
| Manual: remove from list dialog | Device/emulator | Dialog still works normally |
