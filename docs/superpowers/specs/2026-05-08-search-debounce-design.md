# Increase Series Search Debounce to 1s

## Problem

The series search input uses a 300ms debounce before firing an API request to `GET /series`. This causes excessive requests to the API Gateway when users type quickly. The goal is to reduce request volume while maintaining acceptable UX.

## Solution

Increase the debounce duration from 300ms to 1000ms and extract the hardcoded value into a named constant.

## Changes

### 1. Add constant to `AppConstants`

**File:** `lib/core/constants/app_constants.dart`

Add a new static const:

```dart
static const kSearchDebounceDuration = Duration(seconds: 1);
```

### 2. Use constant in search page

**File:** `lib/features/series/pages/series_search_page.dart`

Replace the hardcoded `Duration(milliseconds: 300)` on line 33:

```dart
// Before:
Timer(const Duration(milliseconds: 300), () {
// After:
Timer(AppConstants.kSearchDebounceDuration, () {
```

### 3. Update tests

**File:** `test/features/series/pages/series_search_page_test.dart`

Adjust pump durations from 400ms to 1100ms in two debounce tests (lines ~176 and ~209) so they wait past the new 1s debounce.

### 4. Verification

- `dart analyze` — no new issues expected
- `flutter test` — all existing tests pass with adjusted timing

## Rationale

- 1s is long enough to cover a burst of typing (4-8 chars at moderate speed)
- The `CancelToken` mechanism already cancels in-flight requests, so the only wasted work eliminated is requests that would have been cancelled anyway — but reducing overall request count reduces API Gateway cost and backend load
- Extracting to `AppConstants` follows existing patterns and makes future tuning trivial
- Minimum query length (2 chars) stays unchanged
