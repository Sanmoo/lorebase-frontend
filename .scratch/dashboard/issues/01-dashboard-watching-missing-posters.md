# Dashboard returns watching cards without poster metadata

Status: ready-for-human
Type: bug
Owner: backend

## Summary

`GET /dashboard?mediaType=SERIES` returns cards in the `watching` section without the media metadata required by the frontend to render them, specifically `title` and `posterPath`.

The cards still include a valid `mediaId`, so navigation works, but the dashboard renders the image fallback instead of the poster.

## Reproduction

1. Authenticate as a user with series in the `WATCHING` status.
2. Open `GET /dashboard?mediaType=SERIES` with that user's Bearer token.
3. Inspect `watching.items`.

## Actual result

In the QA environment, all 7 returned `watching.items` had this shape (values redacted/minimized):

```json
{
  "mediaId": "1422",
  "title": "",
  "posterPath": null,
  "status": "WATCHING"
}
```

The frontend can navigate using `mediaId`, but has no poster URL to display.

## Expected result

Every dashboard item that represents catalog media should include the same display metadata regardless of its tracking status:

```json
{
  "mediaId": "1422",
  "title": "<non-empty title>",
  "posterPath": "<non-empty poster URL or path when available>",
  "status": "WATCHING"
}
```

## Impact

The issue becomes visible whenever the frontend refreshes the dashboard after a tracking mutation. Previously cached dashboard data can hide the malformed response; a fresh response exposes blank posters in the `Assistindo` section.

## Suggested investigation

Compare the media-enrichment path used to build `watching` with the paths for `wantToWatch`, `completed`, and `dropped`. The latter sections returned populated `title` and `posterPath` values in the same API response.

## Acceptance criteria

- `GET /dashboard?mediaType=SERIES` returns non-empty `title` and populated `posterPath` for enrichable `watching.items`.
- The response contract is consistent across all dashboard status sections.
- Add a backend regression test covering a `WATCHING` tracking item and asserting its media metadata.

## Comments

### Verification — 2026-08-15

Rechecked the authenticated QA endpoint after the backend team reported a fix.

```text
GET /dashboard?mediaType=SERIES: 7/7 cards de Assistindo sem título ou posterPath
```

The endpoint still fails the acceptance criteria. The fix is either not deployed to QA or does not cover the `WATCHING` enrichment path.

### Revalidation — 2026-08-15

A subsequent authenticated QA check passed:

```text
GET /dashboard?mediaType=SERIES: 0/7 cards de Assistindo sem título ou posterPath
```

The endpoint now satisfies the ticket's metadata acceptance criterion for the current `WATCHING` items.

### Backend root-cause + fix — 2026-08-15

Root cause found by reproducing against the endpoint the QA app uses
(`mp3qfskis4` — the `experience-bff-api-dev` gateway): the user has **two**
WATCHING tracking rows for series `220102` (legacy `TRACKING#220102` SK + new
`TRACKING#SERIES#220102` SK). The dashboard enrichment sent the duplicate id to
the series-catalog batch endpoint, and DynamoDB `BatchGetItem` rejects
duplicate keys — so the batch returned 500 and **every** item in the
`watching` section lost its media metadata, deterministically.

Fix deployed (dev + qa): series-catalog, movie-catalog and game-catalog batch
use cases now dedupe ids before querying DynamoDB. A defensive dedupe was also
added to the user-tracking enrichment handler (its deploy is blocked by
book-catalog terraform — see follow-ups).

Rechecked after deploy, same authenticated endpoint:

```text
GET /dashboard?mediaType=SERIES: 7/7 cards de Assistindo com título e posterPath
```

Regression tests added: `TestGetSeriesUseCase_GetSeriesByIDs_DuplicateIdsSucceed`
(plus movie/game/book equivalents) and
`TestListTrackingSeriesEnrichment_DuplicateMediaIds`.

Follow-ups: (1) user-tracking dedupe deploy is blocked until book-catalog is
deployed (`GOOGLE_BOOKS_API_KEY` missing from the deploy env); (2) the QA app's
`.env` points `API_BASE_URL` at the **dev** API gateway — if QA intends to test
the qa stack, that URL should be reviewed.
