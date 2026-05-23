# Media Detail Additional Data Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add already-available series detail metadata to the frontend with a progressive layout, and fix movie genre parsing without inventing unavailable movie metrics.

**Architecture:** Extend Freezed data models first, then render only trustworthy fields through small helper widgets in the existing detail pages. Series gets the richer UI now; movies only get contract-correct genre parsing while backend parity is tracked in `lorebase-backend:3`.

**Tech Stack:** Flutter 3.27, Dart, Riverpod codegen, Freezed/json_serializable, slang i18n, widget tests, golden tests.

---

## File Structure

- Modify `lib/features/series/data/models/series_model.dart`: add `EpisodeAirInfoModel` and optional metadata fields to `SeriesModel`.
- Modify `test/features/series/data/models/series_model_test.dart`: prove new fields parse, default, and round-trip.
- Modify `lib/features/movies/data/models/movie_model.dart`: accept backend `genre` singular as a fallback for `genres`.
- Modify `test/features/movies/data/models/movie_model_test.dart`: prove singular and plural genre parsing.
- Modify `lib/l10n/*.i18n.json`: add labels for new series detail fields.
- Regenerate generated Dart files with `dart run build_runner build --delete-conflicting-outputs` and `dart run slang` if needed by the project generator setup. Do not hand-edit `*.g.dart` or `*.freezed.dart`.
- Modify `lib/features/series/pages/series_detail_page.dart`: add conditional cards and a progressive “More details” section.
- Modify `test/features/series/pages/series_detail_page_test.dart`: cover new visible fields and omitted empty fields.
- Update visual golden baselines only after reviewing the rendered change.

## Task 1: Extend series model for backend metadata

**Files:**
- Modify: `lib/features/series/data/models/series_model.dart`
- Modify: `test/features/series/data/models/series_model_test.dart`

- [ ] **Step 1: Write failing model tests**

Add this test inside `group('SeriesModel', () { ... })` in `test/features/series/data/models/series_model_test.dart`:

```dart
test('fromJson maps additional detail metadata', () {
  final model = SeriesModel.fromJson({
    ...completeJson,
    'seriesId': 'series-123',
    'createdAt': '2026-05-23T19:49:39Z',
    'voteAverage': 8.461,
    'voteCount': 26839,
    'popularity': 188.7155,
    'originCountry': ['US'],
    'episodeRunTime': [57, 60],
    'numberOfEpisodes': 73,
    'createdBy': ['David Benioff', 'D. B. Weiss'],
    'type': 'Scripted',
    'lastEpisodeToAir': {
      'airDate': '2019-05-19',
      'episodeNumber': 6,
      'seasonNumber': 8,
      'name': 'The Iron Throne',
      'overview': 'Final episode.',
    },
    'nextEpisodeToAir': {
      'airDate': '2026-01-01',
      'episodeNumber': 1,
      'seasonNumber': 9,
      'name': 'Future Episode',
      'overview': 'A future episode.',
    },
  });

  expect(model.seriesId, 'series-123');
  expect(model.createdAt, '2026-05-23T19:49:39Z');
  expect(model.voteAverage, 8.461);
  expect(model.voteCount, 26839);
  expect(model.popularity, 188.7155);
  expect(model.originCountry, ['US']);
  expect(model.episodeRunTime, [57, 60]);
  expect(model.numberOfEpisodes, 73);
  expect(model.createdBy, ['David Benioff', 'D. B. Weiss']);
  expect(model.type, 'Scripted');
  expect(model.lastEpisodeToAir?.airDate, '2019-05-19');
  expect(model.lastEpisodeToAir?.episodeNumber, 6);
  expect(model.lastEpisodeToAir?.seasonNumber, 8);
  expect(model.lastEpisodeToAir?.name, 'The Iron Throne');
  expect(model.lastEpisodeToAir?.overview, 'Final episode.');
  expect(model.nextEpisodeToAir?.name, 'Future Episode');
});

test('fromJson with missing additional metadata uses safe defaults', () {
  final model = SeriesModel.fromJson(minimalJson);

  expect(model.seriesId, isNull);
  expect(model.createdAt, isNull);
  expect(model.voteAverage, isNull);
  expect(model.voteCount, isNull);
  expect(model.popularity, isNull);
  expect(model.originCountry, isEmpty);
  expect(model.episodeRunTime, isEmpty);
  expect(model.numberOfEpisodes, 0);
  expect(model.createdBy, isEmpty);
  expect(model.type, isNull);
  expect(model.lastEpisodeToAir, isNull);
  expect(model.nextEpisodeToAir, isNull);
});
```

- [ ] **Step 2: Run tests to verify failure**

Run:

```bash
flutter test test/features/series/data/models/series_model_test.dart
```

Expected: FAIL because `SeriesModel` does not define the new getters yet.

- [ ] **Step 3: Implement the model fields**

Update `lib/features/series/data/models/series_model.dart` to include this helper class above `SeriesModel` and these fields in the existing factory:

```dart
@freezed
abstract class EpisodeAirInfoModel with _$EpisodeAirInfoModel {
  const factory EpisodeAirInfoModel({
    String? airDate,
    @Default(0) int episodeNumber,
    @Default(0) int seasonNumber,
    String? name,
    String? overview,
  }) = _EpisodeAirInfoModel;

  factory EpisodeAirInfoModel.fromJson(Map<String, dynamic> json) =>
      _$EpisodeAirInfoModelFromJson(json);
}
```

Add these parameters to `const factory SeriesModel({ ... })`:

```dart
String? seriesId,
String? createdAt,
double? voteAverage,
int? voteCount,
double? popularity,
@Default([]) List<String> originCountry,
@Default([]) List<int> episodeRunTime,
@Default(0) int numberOfEpisodes,
@Default([]) List<String> createdBy,
String? type,
EpisodeAirInfoModel? lastEpisodeToAir,
EpisodeAirInfoModel? nextEpisodeToAir,
```

- [ ] **Step 4: Regenerate Freezed/json code**

Run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: generated files update without errors.

- [ ] **Step 5: Run model tests again**

Run:

```bash
flutter test test/features/series/data/models/series_model_test.dart
```

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/features/series/data/models/series_model.dart \
  lib/features/series/data/models/series_model.freezed.dart \
  lib/features/series/data/models/series_model.g.dart \
  test/features/series/data/models/series_model_test.dart
git commit -m "feat: map additional series detail metadata"
```

## Task 2: Fix movie genre parsing from backend detail contract

**Files:**
- Modify: `lib/features/movies/data/models/movie_model.dart`
- Modify: `test/features/movies/data/models/movie_model_test.dart`

- [ ] **Step 1: Write failing movie model test**

Add this test inside `group('MovieModel', () { ... })`:

```dart
test('fromJson accepts singular genre field from movie detail API', () {
  final movie = MovieModel.fromJson({
    ...minimalJson,
    'genre': 'Drama',
  });

  expect(movie.genres, ['Drama']);
});

test('fromJson prefers genres list when both genre shapes are present', () {
  final movie = MovieModel.fromJson({
    ...minimalJson,
    'genre': 'Drama',
    'genres': ['Drama', 'Thriller'],
  });

  expect(movie.genres, ['Drama', 'Thriller']);
});
```

- [ ] **Step 2: Run tests to verify failure**

Run:

```bash
flutter test test/features/movies/data/models/movie_model_test.dart
```

Expected: FAIL because `genre` singular is ignored.

- [ ] **Step 3: Implement genre fallback**

In `lib/features/movies/data/models/movie_model.dart`, add this helper near `_readRuntimeMinutes`:

```dart
Object? _readGenres(Map<dynamic, dynamic> json, String key) {
  final genres = json[key];
  if (genres is List && genres.isNotEmpty) return genres;
  final genre = json['genre'];
  if (genre is String && genre.isNotEmpty) return [genre];
  return genres;
}
```

Change the `genres` field annotation to:

```dart
@JsonKey(readValue: _readGenres)
@Default([])
List<String> genres,
```

- [ ] **Step 4: Regenerate model code**

Run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: generated files update without errors.

- [ ] **Step 5: Run movie model tests**

Run:

```bash
flutter test test/features/movies/data/models/movie_model_test.dart
```

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/features/movies/data/models/movie_model.dart \
  lib/features/movies/data/models/movie_model.freezed.dart \
  lib/features/movies/data/models/movie_model.g.dart \
  test/features/movies/data/models/movie_model_test.dart
git commit -m "fix: parse singular movie genre"
```

## Task 3: Add i18n labels for new series detail fields

**Files:**
- Modify: `lib/l10n/en.i18n.json`
- Modify: `lib/l10n/en_US.i18n.json`
- Modify: `lib/l10n/es.i18n.json`
- Modify: `lib/l10n/pt_BR.i18n.json`
- Generated: `lib/l10n/strings*.g.dart`

- [ ] **Step 1: Add English labels**

Add these keys to both `lib/l10n/en.i18n.json` and `lib/l10n/en_US.i18n.json` near the existing `series_detail_*` keys:

```json
"series_detail_episodes": "Episodes",
"series_detail_tmdb_rating": "TMDB Rating",
"series_detail_vote_count": "{count} votes",
"series_detail_more_details": "More details",
"series_detail_created_by": "Created by",
"series_detail_origin_country": "Origin country",
"series_detail_type": "Type",
"series_detail_popularity": "Popularity",
"series_detail_last_episode": "Last episode",
"series_detail_next_episode": "Next episode",
"series_detail_episode_code": "S{season}E{episode}",
"series_detail_episode_date": "{code} · {date}",
"series_detail_not_available": "—"
```

- [ ] **Step 2: Add Spanish labels**

Add these keys to `lib/l10n/es.i18n.json`:

```json
"series_detail_episodes": "Episodios",
"series_detail_tmdb_rating": "Valoración TMDB",
"series_detail_vote_count": "{count} votos",
"series_detail_more_details": "Más detalles",
"series_detail_created_by": "Creado por",
"series_detail_origin_country": "País de origen",
"series_detail_type": "Tipo",
"series_detail_popularity": "Popularidad",
"series_detail_last_episode": "Último episodio",
"series_detail_next_episode": "Próximo episodio",
"series_detail_episode_code": "T{season}E{episode}",
"series_detail_episode_date": "{code} · {date}",
"series_detail_not_available": "—"
```

- [ ] **Step 3: Add Portuguese labels**

Add these keys to `lib/l10n/pt_BR.i18n.json`:

```json
"series_detail_episodes": "Episódios",
"series_detail_tmdb_rating": "Nota TMDB",
"series_detail_vote_count": "{count} votos",
"series_detail_more_details": "Mais detalhes",
"series_detail_created_by": "Criado por",
"series_detail_origin_country": "País de origem",
"series_detail_type": "Tipo",
"series_detail_popularity": "Popularidade",
"series_detail_last_episode": "Último episódio",
"series_detail_next_episode": "Próximo episódio",
"series_detail_episode_code": "T{season}E{episode}",
"series_detail_episode_date": "{code} · {date}",
"series_detail_not_available": "—"
```

- [ ] **Step 4: Regenerate slang files**

Run:

```bash
dart run slang
```

Expected: `lib/l10n/strings*.g.dart` update without errors.

- [ ] **Step 5: Verify generated getters compile**

Run:

```bash
dart analyze --fatal-infos
```

Expected: no missing translation getter errors. If analyze reports only pre-existing warnings unrelated to these files, use `make analyze` per project instructions.

- [ ] **Step 6: Commit**

```bash
git add lib/l10n/en.i18n.json lib/l10n/en_US.i18n.json \
  lib/l10n/es.i18n.json lib/l10n/pt_BR.i18n.json lib/l10n/strings*.g.dart
git commit -m "feat: add series detail metadata translations"
```

## Task 4: Render progressive series metadata UI

**Files:**
- Modify: `lib/features/series/pages/series_detail_page.dart`
- Test: `test/features/series/pages/series_detail_page_test.dart`

- [ ] **Step 1: Add richer fixture in page test**

Add this helper near `_testSeries()` in `test/features/series/pages/series_detail_page_test.dart`:

```dart
SeriesModel _richSeries() => const SeriesModel(
  tmdbId: 1399,
  title: 'Game of Thrones',
  overview: 'A fantasy series',
  genres: ['Sci-Fi'],
  seasonCount: 8,
  status: 'Ended',
  firstAirDate: '2011-04-17',
  networks: ['HBO'],
  voteAverage: 8.461,
  voteCount: 26839,
  popularity: 188.7155,
  originCountry: ['US'],
  numberOfEpisodes: 73,
  createdBy: ['David Benioff', 'D. B. Weiss'],
  type: 'Scripted',
  lastEpisodeToAir: EpisodeAirInfoModel(
    airDate: '2019-05-19',
    episodeNumber: 6,
    seasonNumber: 8,
    name: 'The Iron Throne',
    overview: 'The final episode.',
  ),
);
```

- [ ] **Step 2: Write failing widget tests**

Add these tests inside `group('SeriesDetailPage', () { ... })`:

```dart
testWidgets('renders additional series metadata when available', (tester) async {
  final detail = SeriesDetailState(series: _richSeries(), tracking: null);
  final container = ProviderContainer(
    overrides: [
      seriesDetailViewModelProvider(
        1399,
      ).overrideWith(() => FakeDetailVM(data: detail)),
      authViewModelProvider.overrideWith(() => FakeAuthVM()),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(_wrap(container));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));

  expect(find.text('Episodes'), findsOneWidget);
  expect(find.text('73'), findsOneWidget);
  expect(find.text('TMDB Rating'), findsOneWidget);
  expect(find.text('8.5 · 26839 votes'), findsOneWidget);
  expect(find.text('More details'), findsOneWidget);
  expect(find.text('Created by'), findsOneWidget);
  expect(find.text('David Benioff, D. B. Weiss'), findsOneWidget);
  expect(find.text('Origin country'), findsOneWidget);
  expect(find.text('US'), findsOneWidget);
  expect(find.text('Type'), findsOneWidget);
  expect(find.text('Scripted'), findsOneWidget);
  expect(find.text('Popularity'), findsOneWidget);
  expect(find.text('188.7'), findsOneWidget);
  expect(find.text('Last episode'), findsOneWidget);
  expect(find.text('The Iron Throne'), findsOneWidget);
});

testWidgets('omits additional metadata section when all extra fields are empty', (
  tester,
) async {
  final detail = SeriesDetailState(series: _testSeries(), tracking: null);
  final container = ProviderContainer(
    overrides: [
      seriesDetailViewModelProvider(
        1,
      ).overrideWith(() => FakeDetailVM(data: detail)),
      authViewModelProvider.overrideWith(() => FakeAuthVM()),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(_wrap(container));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));

  expect(find.text('More details'), findsNothing);
  expect(find.text('Episodes'), findsNothing);
  expect(find.text('TMDB Rating'), findsNothing);
});
```

- [ ] **Step 3: Run tests to verify failure**

Run:

```bash
flutter test test/features/series/pages/series_detail_page_test.dart
```

Expected: FAIL because the UI does not render these fields yet.

- [ ] **Step 4: Add formatting helpers to the page file**

In `lib/features/series/pages/series_detail_page.dart`, add these private helpers below `_OverviewSectionState`:

```dart
String _formatDecimal(double value) => value.toStringAsFixed(1);

String _formatRating(BuildContext context, SeriesModel series) {
  final t = context.t;
  final rating = series.voteAverage;
  if (rating == null || rating <= 0) return t.series_detail_not_available;
  final ratingText = _formatDecimal(rating);
  final voteText = series.voteCount != null && series.voteCount! > 0
      ? ' · ${t.series_detail_vote_count(count: series.voteCount!)}'
      : '';
  return '$ratingText$voteText';
}

String _formatEpisodeCode(BuildContext context, EpisodeAirInfoModel episode) {
  final t = context.t;
  return t.series_detail_episode_code(
    season: episode.seasonNumber,
    episode: episode.episodeNumber,
  );
}

bool _hasMoreDetails(SeriesModel series) =>
    series.createdBy.isNotEmpty ||
    series.originCountry.isNotEmpty ||
    (series.type != null && series.type!.isNotEmpty) ||
    (series.popularity != null && series.popularity! > 0) ||
    series.lastEpisodeToAir != null ||
    series.nextEpisodeToAir != null;
```

- [ ] **Step 5: Add detail row widget**

Add this widget below `_InfoCard`:

```dart
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 6: Add more details section widget**

Add this widget below `_DetailRow`:

```dart
class _MoreDetailsSection extends StatelessWidget {
  final SeriesModel series;

  const _MoreDetailsSection({required this.series});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final rows = <Widget>[];

    if (series.createdBy.isNotEmpty) {
      rows.add(
        _DetailRow(
          label: t.series_detail_created_by,
          value: series.createdBy.join(', '),
        ),
      );
    }
    if (series.originCountry.isNotEmpty) {
      rows.add(
        _DetailRow(
          label: t.series_detail_origin_country,
          value: series.originCountry.join(', '),
        ),
      );
    }
    if (series.type != null && series.type!.isNotEmpty) {
      rows.add(_DetailRow(label: t.series_detail_type, value: series.type!));
    }
    if (series.popularity != null && series.popularity! > 0) {
      rows.add(
        _DetailRow(
          label: t.series_detail_popularity,
          value: _formatDecimal(series.popularity!),
        ),
      );
    }
    if (series.lastEpisodeToAir != null) {
      final episode = series.lastEpisodeToAir!;
      rows.add(
        _DetailRow(
          label: t.series_detail_last_episode,
          value: episode.name ?? _formatEpisodeCode(context, episode),
        ),
      );
    }
    if (series.nextEpisodeToAir != null) {
      final episode = series.nextEpisodeToAir!;
      rows.add(
        _DetailRow(
          label: t.series_detail_next_episode,
          value: episode.name ?? _formatEpisodeCode(context, episode),
        ),
      );
    }

    return Card(
      child: ExpansionTile(
        title: Text(t.series_detail_more_details),
        initiallyExpanded: true,
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: rows,
      ),
    );
  }
}
```

- [ ] **Step 7: Render extra cards and details**

In `_SeriesDetailLoaded.build`, keep existing cards and add conditional cards:

1. In the first card grid, keep the first row unchanged.
2. After the existing second row with networks/status, add this block before `const SizedBox(height: 32)`:

```dart
if (series.numberOfEpisodes > 0 ||
    (series.voteAverage != null && series.voteAverage! > 0)) ...[
  const SizedBox(height: 12),
  Row(
    children: [
      Expanded(
        child: _InfoCard(
          icon: Icons.movie_filter,
          label: t.series_detail_episodes,
          value: series.numberOfEpisodes > 0
              ? '${series.numberOfEpisodes}'
              : t.series_detail_not_available,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: _InfoCard(
          icon: Icons.star,
          label: t.series_detail_tmdb_rating,
          value: _formatRating(context, series),
        ),
      ),
    ],
  ),
],
if (_hasMoreDetails(series)) ...[
  const SizedBox(height: 16),
  _MoreDetailsSection(series: series),
],
```

- [ ] **Step 8: Run widget tests**

Run:

```bash
flutter test test/features/series/pages/series_detail_page_test.dart
```

Expected: PASS.

- [ ] **Step 9: Commit**

```bash
git add lib/features/series/pages/series_detail_page.dart \
  test/features/series/pages/series_detail_page_test.dart
git commit -m "feat: show additional series detail metadata"
```

## Task 5: Update golden coverage and run verification

**Files:**
- Possibly modify: `test/visual/pages/goldens/**/series_detail_page.png`
- Possibly modify: `test/visual/pages/goldens/**/movie_detail_page.png` only if movie genre rendering changes the golden.

- [ ] **Step 1: Run focused tests**

Run:

```bash
flutter test test/features/series/data/models/series_model_test.dart \
  test/features/movies/data/models/movie_model_test.dart \
  test/features/series/pages/series_detail_page_test.dart
```

Expected: PASS.

- [ ] **Step 2: Run golden tests without updating**

Run:

```bash
flutter test test/visual/pages/series_detail_page_golden_test.dart \
  test/visual/pages/movie_detail_page_golden_test.dart
```

Expected: series golden may FAIL because intentional metadata changed the rendered page; movie golden should PASS unless genre now appears in that fixture.

- [ ] **Step 3: Review intentional visual diffs**

Open the generated failure output paths reported by Flutter and confirm:

- Series detail still shows hero, poster, title, overview, tracking button.
- New cards do not overlap on mobile-sized golden viewport.
- “More details” section is visible only when the golden fixture includes extra metadata.
- Movie detail has no unexpected metric cards.

- [ ] **Step 4: Update golden baselines if diffs are intentional**

Run:

```bash
flutter test --update-goldens test/visual/pages/series_detail_page_golden_test.dart
```

If the movie golden changed only because genre now renders correctly from `genre`, run:

```bash
flutter test --update-goldens test/visual/pages/movie_detail_page_golden_test.dart
```

Expected: golden image files update.

- [ ] **Step 5: Run project checks**

Run:

```bash
make analyze
flutter test
```

Expected: analyze passes per project wrapper; full Flutter test suite passes.

- [ ] **Step 6: Commit verification/goldens**

```bash
git add test/visual/pages/goldens lib/features lib/l10n test/features
git commit -m "test: update media detail metadata coverage"
```

If no files remain after verification, skip the commit and note that no golden baseline changes were needed.

## Self-Review

- Spec coverage: Task 1 covers series backend fields; Task 2 covers movie `genre`; Task 3 covers i18n labels; Task 4 covers progressive series UI; Task 5 covers verification and goldens. Backend film parity is intentionally outside this frontend plan and tracked as `lorebase-backend:3`.
- Placeholder scan: no TBD/TODO/fill-in-later instructions remain.
- Type consistency: `EpisodeAirInfoModel`, `SeriesModel` fields, and translation key names are consistent across tasks.
