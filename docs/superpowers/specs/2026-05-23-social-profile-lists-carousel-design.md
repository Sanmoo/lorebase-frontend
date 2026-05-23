# Design: Social profile Lists carousel

## Context

The current Social profile **Lists** tab was changed from raw IDs/enums to grouped list tiles, but the resulting UI is still unsatisfactory: it reads like a record list rather than a media collection. The intended experience is closer to the app's existing **My Lists** and dashboard media rows, where users browse posters and titles.

## Goal

Render public profile lists as a social media showcase: vertically stacked public list sections, each containing a horizontal carousel of media posters.

## User-facing behavior

- The tab is vertically scrollable and does not overflow near the bottom navigation.
- Public list items are grouped by tracking status/list:
  - `PLAN_TO_WATCH` → **Quero ver**
  - `WATCHING` → **Assistindo**
  - `COMPLETED` → **Concluído**
  - `DROPPED` → **Abandonado**
- Empty groups are hidden.
- If there are no public list items at all, the existing empty message is shown.
- Each visible item presents media-first content:
  - poster image from `posterUrl` when available;
  - a simple fallback poster area when unavailable;
  - title from the API as the main text;
  - rating as compact secondary metadata when available;
  - media type as secondary metadata if it can be shown without clutter.
- Numeric media IDs are not used as primary user-facing text.
- Raw technical status enums are not displayed.

## Component design

`PublicMediaListSection` remains the entry widget used by `SocialProfilePage`, but its internal presentation changes:

1. Group incoming `PublicListItemModel` values by normalized status.
2. Render the outer widget as a vertical `ListView`.
3. For each non-empty group, render:
   - a localized section heading;
   - a fixed-height horizontal `ListView` of poster cards.
4. Render each card with a small reusable private widget based on `PublicListItemModel`.

This keeps the change scoped to the social widget and avoids coupling public social list models to tracking/dashboard models.

## Visual direction

Use the same visual language as `TrackedMediaPoster` / dashboard horizontal lists:

- poster aspect ratio around 2:3;
- rounded corners;
- title below poster with ellipsis;
- compact metadata below or overlaid only if simple;
- horizontal spacing similar to dashboard media rows.

The design should look like media collections, not a settings/list management screen.

## Data and navigation

The widget already accepts `onItemTap`. The carousel cards should call this callback when provided. Navigation behavior remains the responsibility of the parent.

If a media item lacks `media.title`, use a friendly fallback such as localized media type, not the numeric ID. The ID can remain internal for navigation only.

## Error handling and edge cases

- Missing `posterUrl`: show fallback poster with a media icon.
- Missing `media`: still render a card using friendly fallback text and metadata; do not expose `mediaId` as the title.
- Unknown status: render a humanized label derived from the status string rather than the raw enum format.
- Large lists: vertical and horizontal scrolling must avoid Flutter overflow exceptions.

## Testing

Widget tests should cover:

- grouped sections use friendly localized labels;
- raw enums are not rendered;
- media titles are rendered as primary text;
- numeric media IDs are not rendered as primary text when media data is missing;
- many items fit in constrained height without overflow and are horizontally scrollable;
- ratings render when present;
- tap callback still receives the selected `PublicListItemModel`.

## Out of scope

- Backend/API changes.
- Pagination or "show all" interactions.
- Editing lists from the social profile.
- Global localization infrastructure beyond local labels already needed for this widget.
