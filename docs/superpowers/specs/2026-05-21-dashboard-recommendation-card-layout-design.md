# Dashboard Recommendation Card Layout Design

## Context

The Dashboard home page shows a “Recommendation” call-to-action card below the social activity preview. The current recommendation card uses `ListTile` with a trailing `TextButton`. On narrow layouts, the trailing button constrains the title and subtitle area, making the “Recommendations for you / Find something tailored…” text appear much narrower than the icon and CTA.

## Goal

Make the recommendation card visually match the existing “Social activity” card and prevent the title/subtitle text from being squeezed by the CTA button.

## Design

Update `_RecommendationCard` in `lib/features/dashboard/pages/dashboard_page.dart` to use the same structural pattern as `_SocialPreviewSection`:

- Keep the existing outer `Padding` and `Card`.
- Replace the `ListTile` with `Padding(all: 16)` and a `Column` aligned to the start.
- Add a top `Row` with `Icons.auto_awesome_outlined`, an 8px gap, and the recommendation title styled with `Theme.of(context).textTheme.titleMedium`.
- Add a 12px vertical gap.
- Render the recommendation body as `Text` using `Theme.of(context).textTheme.bodyMedium`, allowing it to occupy the full card width.
- Add a 12px vertical gap.
- Render the CTA as a `TextButton` inside `Align(alignment: Alignment.centerRight)`.
- Preserve navigation behavior by making both the card tap and the CTA button invoke the existing `onTap` callback.

## Scope

Only the recommendation card layout changes. No routing, localization, generated files, social card behavior, or dashboard data logic changes.

## Testing

Add or update a widget test that pumps the recommendation card in isolation and verifies:

- The recommendation title, body, CTA, and icon render.
- Tapping the CTA invokes the callback.
- Tapping the card surface invokes the callback.

Run targeted tests for the dashboard page/widget and LSP diagnostics for the touched Dart file.
