# Fix: Series Card Text Overflow on Dashboard

## Problem

On the dashboard, `SeriesPoster` widgets inside `SeriesHorizontalList` (fixed height: 200px) overflow when series titles span 2+ lines. The layout is:
- Image: 120×180px
- SizedBox: 4px
- Text: `maxLines: 2`

Remaining space after image + spacing is ~16px (~1 line of `bodySmall`), but `maxLines: 2` allows the text to request more height than available → Flutter's "Bottom Overflowed by X pixels" error.

## Root Cause

`SeriesHorizontalList` wraps items in a `SizedBox(height: 200)` that constrains the column height. Inside `SeriesPoster`, the `Text` widget with `maxLines: 2` asks for more height than the 16px left after accounting for the image (180px) and gap (4px).

## Solution

Change `maxLines: 2` to `maxLines: 1` in `SeriesPoster` (`lib/features/series/widgets/series_poster.dart:53`).

This is appropriate because:
- Cards are only 120px wide — 2-line titles are barely legible at that width
- `TextOverflow.ellipsis` already handles truncation
- Single line fits within the natural ~16px budget
- One-line labels are consistent with poster-card conventions (Netflix, TMDB, etc.)

## Files Changed

- `lib/features/series/widgets/series_poster.dart` — change `maxLines: 2` to `maxLines: 1`

## Testing

- Verify existing `series_card_test.dart` and `dashboard_page_test.dart` still pass
- No new tests needed — overflow is prevented by constraint satisfaction
