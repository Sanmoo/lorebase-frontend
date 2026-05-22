# Global Media Type Filter Design

## Problem

`TrackingListPage` and `SeriesSearchPage` each keep their selected `MediaType` in local widget state, initialized to `MediaType.series`. If a user selects Movies in Minhas Listas and then navigates to Buscar, Buscar initializes its own local state as Series. This makes the selected media type inconsistent across screens during the same app session.

## Goal

Make the selected media type globally consistent between Buscar and Minhas Listas for the current app session. The value does not need to persist after the app restarts.

## Non-goals

- Do not persist the selected media type in secure storage, shared preferences, or backend state.
- Do not encode the selected media type in routes or query parameters.
- Do not change API contracts or tracking/search repository behavior.

## Architecture

Add a session-scoped Riverpod provider that stores the currently selected `MediaType`, with `MediaType.series` as the initial value.

Suggested location:

- `lib/core/providers/media_type_filter_provider.dart`

Suggested shape:

- `final selectedMediaTypeProvider = StateProvider<MediaType>((ref) => MediaType.series);`

`SeriesSearchPage` and `TrackingListPage` will read this provider instead of owning independent `_selectedType` fields.

## Data flow

### Buscar

- Watch `selectedMediaTypeProvider` in `SeriesSearchPage.build`.
- Pass the watched value to `MediaTypeToggle` and `_SearchResultsBody`.
- On toggle changes:
  - update `selectedMediaTypeProvider`;
  - clear the search text;
  - clear both series and movie search results, preserving current behavior.
- Search execution continues to dispatch to the series or movie search viewmodel based on the provider value.

### Minhas Listas

- Watch `selectedMediaTypeProvider` in `TrackingListPage.build`.
- Pass the watched value to `MediaTypeToggle`.
- On toggle changes:
  - update `selectedMediaTypeProvider`;
  - reload the current tracking tab using the new media type.
- Initial page load should load the first tab using the current provider value, so navigation from Buscar to Minhas Listas also respects the shared selection.

## Error handling

No error-handling behavior changes are needed. Existing viewmodels continue to own loading and error states:

- `seriesSearchViewModelProvider`
- `movieSearchViewModelProvider`
- `trackingListViewModelProvider`

## Testing strategy

- Update existing widget tests to account for `selectedMediaTypeProvider` when needed.
- Add coverage for shared behavior:
  - render a small router or shared `ProviderContainer` with both `/tracking` and `/search`;
  - select Movies in Minhas Listas;
  - navigate to Buscar;
  - assert that Buscar reflects Movies, such as showing the movie search hint.
- Preserve current behavior tests:
  - switching Buscar to Movies clears search state and shows movie copy;
  - switching Minhas Listas to Movies reloads tracking and shows movie empty-state copy.

## Acceptance criteria

- Selecting Movies in Minhas Listas makes Buscar show Movies when visited afterward in the same session.
- Selecting Series or Movies in Buscar makes Minhas Listas use that same selection afterward in the same session.
- Restarting the app resets the filter to Series.
- Existing search, tracking, navigation, and error behaviors remain unchanged.
