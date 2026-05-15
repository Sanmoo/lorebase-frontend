# Movie tracking implementation plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add end-to-end movie tracking while keeping the UI segmented by
media type and migrating the tracking domain away from series-specific models.

**Architecture:** Keep catalog and detail flows media-specific
(`series` and `movies`), but move tracking, tracking lists, and dashboard to a
generic tracked-media domain keyed by `MediaType`. Reuse a shared media-type
selector and a shared tracking editor sheet so Search, My Lists, Dashboard,
Series Detail, and Movie Detail all stay consistent.

**Tech Stack:** Flutter, Dart, Riverpod with codegen, Freezed, Dio,
GoRouter, slang i18n, Material 3

---

## File map

| File | Responsibility |
| --- | --- |
| `lib/features/tracking/data/models/media_type.dart` | `MediaType` enum and shared labels/API values |
| `lib/core/widgets/media_type_toggle.dart` | Shared segmented selector for `series` and `movie` |
| `lib/features/tracking/data/models/tracked_media_summary_model.dart` | Compact media payload for tracking lists and dashboard |
| `lib/features/tracking/data/models/tracked_media_model.dart` | Generic tracking record used by repository, detail pages, and lists |
| `lib/features/tracking/data/repositories/tracking_repository.dart` | Media-aware tracking CRUD and list queries |
| `lib/features/tracking/widgets/tracking_editor_sheet.dart` | Shared editor for status, rating, review, and removal |
| `lib/features/tracking/widgets/tracked_media_poster.dart` | Poster + title widget for tracked summaries |
| `lib/features/movies/data/models/movie_model.dart` | Movie detail/search model |
| `lib/features/movies/data/repositories/movie_repository.dart` | `/movies` API access |
| `lib/features/movies/viewmodels/movie_search_viewmodel.dart` | Debounced movie search state |
| `lib/features/movies/viewmodels/movie_detail_state.dart` | Detail state for movies |
| `lib/features/movies/viewmodels/movie_detail_viewmodel.dart` | Movie detail + tracking orchestration |
| `lib/features/movies/pages/movie_detail_page.dart` | Movie detail UI and tracking entry point |
| `lib/features/movies/widgets/movie_card.dart` | Search result card for movies |
| `lib/features/series/pages/series_search_page.dart` | Shared `/search` page with media toggle |
| `lib/features/series/viewmodels/series_detail_state.dart` | Series detail state switched to generic tracking model |
| `lib/features/series/viewmodels/series_detail_viewmodel.dart` | Series detail logic using media-aware tracking repository |
| `lib/features/series/pages/series_detail_page.dart` | Series detail page using shared tracking editor |
| `lib/features/tracking/viewmodels/tracking_list_viewmodel.dart` | Tracking list state keyed by status + media type |
| `lib/features/tracking/pages/tracking_list_page.dart` | Media-segmented My Lists page |
| `lib/features/dashboard/data/models/dashboard_section_model.dart` | Dashboard sections with generic tracked summaries |
| `lib/features/dashboard/data/models/dashboard_model.dart` | Dashboard response model |
| `lib/features/dashboard/data/repositories/dashboard_repository.dart` | `/dashboard` fetch with `mediaType` filter |
| `lib/features/dashboard/viewmodels/dashboard_viewmodel.dart` | Dashboard cache/load logic keyed by `mediaType` |
| `lib/features/dashboard/widgets/tracked_media_horizontal_list.dart` | Horizontal list of tracked summaries |
| `lib/features/dashboard/widgets/watching_section.dart` | Generic dashboard section wrapper |
| `lib/features/dashboard/pages/dashboard_page.dart` | Media-segmented Dashboard page |
| `lib/router.dart` | Add `/movies/:tmdbId` route |
| `lib/l10n/en_US.i18n.json` | English strings for media toggle, movies, and segmented empty states |
| `lib/l10n/pt_BR.i18n.json` | Portuguese strings for the same keys |
| `lib/l10n/es.i18n.json` | Spanish strings for the same keys |

### Task 1: Add shared media-type primitives

**Files:**
- Create: `lib/features/tracking/data/models/media_type.dart`
- Create: `lib/core/widgets/media_type_toggle.dart`
- Create: `test/features/tracking/data/models/media_type_test.dart`
- Create: `test/core/widgets/media_type_toggle_test.dart`
- Modify: `lib/l10n/en_US.i18n.json`
- Modify: `lib/l10n/pt_BR.i18n.json`
- Modify: `lib/l10n/es.i18n.json`

- [ ] **Step 1: Write the failing tests for `MediaType` and
  `MediaTypeToggle`**

Create `test/features/tracking/data/models/media_type_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/tracking/data/models/media_type.dart';

void main() {
  group('MediaType', () {
    test('apiValue exposes stable backend values', () {
      expect(MediaType.series.apiValue, 'series');
      expect(MediaType.movie.apiValue, 'movie');
    });

    test('fromApiValue parses known values and rejects unknown ones', () {
      expect(MediaTypeX.fromApiValue('series'), MediaType.series);
      expect(MediaTypeX.fromApiValue('movie'), MediaType.movie);
      expect(
        () => MediaTypeX.fromApiValue('board_game'),
        throwsArgumentError,
      );
    });
  });
}
```

Create `test/core/widgets/media_type_toggle_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/core/widgets/media_type_toggle.dart';
import 'package:lorebase/features/tracking/data/models/media_type.dart';
import 'package:lorebase/l10n/strings.g.dart';

Future<void> main() async {
  await LocaleSettings.setLocale(AppLocale.enUs);

  testWidgets('renders both labels and forwards selection', (tester) async {
    MediaType? selected;

    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: MediaTypeToggle(
              selectedType: MediaType.series,
              onChanged: (value) => selected = value,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Series'), findsOneWidget);
    expect(find.text('Movies'), findsOneWidget);

    await tester.tap(find.text('Movies'));
    await tester.pumpAndSettle();

    expect(selected, MediaType.movie);
  });
}
```

- [ ] **Step 2: Run the new tests and confirm they fail**

Run:

```bash
flutter test test/features/tracking/data/models/media_type_test.dart test/core/widgets/media_type_toggle_test.dart -v
```

Expected: FAIL with missing `MediaType`, `MediaTypeToggle`, and i18n keys.

- [ ] **Step 3: Add `MediaType` and the shared toggle widget**

Create `lib/features/tracking/data/models/media_type.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../l10n/strings.g.dart';

enum MediaType {
  series('series'),
  movie('movie');

  const MediaType(this.apiValue);

  final String apiValue;

  String label(Translations t) {
    switch (this) {
      case MediaType.series:
        return t.media_type_series;
      case MediaType.movie:
        return t.media_type_movies;
    }
  }
}

extension MediaTypeX on MediaType {
  static MediaType fromApiValue(String value) {
    return MediaType.values.firstWhere(
      (type) => type.apiValue == value,
      orElse: () => throw ArgumentError.value(
        value,
        'value',
        'Unsupported media type',
      ),
    );
  }
}

MediaType mediaTypeFromJson(String value) => MediaTypeX.fromApiValue(value);
String mediaTypeToJson(MediaType value) => value.apiValue;
```

Create `lib/core/widgets/media_type_toggle.dart`:

```dart
import 'package:flutter/material.dart';
import '../../features/tracking/data/models/media_type.dart';
import '../../l10n/strings.g.dart';

class MediaTypeToggle extends StatelessWidget {
  final MediaType selectedType;
  final ValueChanged<MediaType> onChanged;

  const MediaTypeToggle({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<MediaType>(
      showSelectedIcon: false,
      segments: MediaType.values
          .map(
            (type) => ButtonSegment<MediaType>(
              value: type,
              label: Text(type.label(context.t)),
            ),
          )
          .toList(),
      selected: {selectedType},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}
```

- [ ] **Step 4: Add the new localization keys**

Add to `lib/l10n/en_US.i18n.json` after `locale_es`:

```json
  "media_type_series": "Series",
  "media_type_movies": "Movies",
  "search_hint_movies": "Search movies...",
  "search_no_results_movies": "No movies found",
  "tracking_empty_movies": "No {status} movies yet",
  "dashboard_empty_movies": "No movies tracked yet.\nSearch and add your first movie!",
  "movie_detail_loading": "Loading movie details...",
  "movie_detail_release_date": "Release Date",
  "movie_detail_runtime": "Runtime",
  "movie_detail_runtime_minutes": "{minutes} min"
```

Add to `lib/l10n/pt_BR.i18n.json` after `locale_es`:

```json
  "media_type_series": "Séries",
  "media_type_movies": "Filmes",
  "search_hint_movies": "Buscar filmes...",
  "search_no_results_movies": "Nenhum filme encontrado",
  "tracking_empty_movies": "Nenhum filme {status} ainda",
  "dashboard_empty_movies": "Nenhum filme registrado ainda.\nBusque e adicione seu primeiro filme!",
  "movie_detail_loading": "Carregando detalhes do filme...",
  "movie_detail_release_date": "Data de Lançamento",
  "movie_detail_runtime": "Duração",
  "movie_detail_runtime_minutes": "{minutes} min"
```

Add to `lib/l10n/es.i18n.json` after `locale_es`:

```json
  "media_type_series": "Series",
  "media_type_movies": "Películas",
  "search_hint_movies": "Buscar películas...",
  "search_no_results_movies": "No se encontraron películas",
  "tracking_empty_movies": "Aún no hay películas en {status}",
  "dashboard_empty_movies": "Todavía no hay películas registradas.\nBusca y agrega tu primera película!",
  "movie_detail_loading": "Cargando detalles de la película...",
  "movie_detail_release_date": "Fecha de estreno",
  "movie_detail_runtime": "Duración",
  "movie_detail_runtime_minutes": "{minutes} min"
```

- [ ] **Step 5: Regenerate generated localization output**

Run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: PASS with regenerated `lib/l10n/strings.g.dart`.

- [ ] **Step 6: Run the targeted tests again**

Run:

```bash
flutter test test/features/tracking/data/models/media_type_test.dart test/core/widgets/media_type_toggle_test.dart -v
```

Expected: PASS.

- [ ] **Step 7: Commit the primitives**

```bash
git add lib/features/tracking/data/models/media_type.dart lib/core/widgets/media_type_toggle.dart lib/l10n/en_US.i18n.json lib/l10n/pt_BR.i18n.json lib/l10n/es.i18n.json lib/l10n/strings.g.dart test/features/tracking/data/models/media_type_test.dart test/core/widgets/media_type_toggle_test.dart
git commit -m "feat: add shared media type primitives"
```

### Task 2: Replace series-only tracking with generic tracked media

**Files:**
- Create: `lib/features/tracking/data/models/tracked_media_summary_model.dart`
- Create: `lib/features/tracking/data/models/tracked_media_model.dart`
- Create: `test/features/tracking/data/models/tracked_media_summary_model_test.dart`
- Create: `test/features/tracking/data/models/tracked_media_model_test.dart`
- Modify: `lib/features/tracking/data/repositories/tracking_repository.dart`
- Modify: `lib/features/tracking/viewmodels/tracking_list_viewmodel.dart`
- Modify: `lib/features/tracking/pages/tracking_list_page.dart`
- Modify: `lib/features/series/viewmodels/series_detail_state.dart`
- Modify: `lib/features/series/viewmodels/series_detail_viewmodel.dart`
- Modify: `lib/features/series/pages/series_detail_page.dart`
- Modify: `test/features/tracking/data/repositories/tracking_repository_test.dart`
- Modify: `test/features/tracking/viewmodels/tracking_list_viewmodel_test.dart`
- Modify: `test/features/tracking/pages/tracking_list_page_test.dart`
- Modify: `test/features/series/viewmodels/series_detail_viewmodel_test.dart`
- Modify: `test/features/series/pages/series_detail_page_test.dart`
- Delete: `lib/features/tracking/data/models/tracked_series_model.dart`
- Delete: `test/features/tracking/data/models/tracked_series_model_test.dart`

- [ ] **Step 1: Write the new model and repository tests**

Create `test/features/tracking/data/models/tracked_media_summary_model_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/tracking/data/models/tracked_media_summary_model.dart';

void main() {
  const json = {
    'tmdbId': 10,
    'title': 'The Batman',
    'mediaType': 'movie',
    'posterPath': '/poster.jpg',
    'backdropPath': '/backdrop.jpg',
  };

  test('fromJson parses summary payload', () {
    final model = TrackedMediaSummaryModel.fromJson(json);

    expect(model.tmdbId, 10);
    expect(model.title, 'The Batman');
    expect(model.mediaType.apiValue, 'movie');
    expect(model.posterPath, '/poster.jpg');
  });
}
```

Create `test/features/tracking/data/models/tracked_media_model_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/tracking/data/models/tracked_media_model.dart';

void main() {
  final now = DateTime.now().toIso8601String();

  final json = {
    'trackingId': 'trk-1',
    'userId': 'user-1',
    'mediaType': 'series',
    'mediaId': '42',
    'status': 'WATCHING',
    'rating': 8,
    'review': 'Great',
    'seasonRatings': [
      {'seasonNumber': 1, 'rating': 8},
    ],
    'media': {
      'tmdbId': 42,
      'title': 'Test Show',
      'mediaType': 'series',
    },
    'addedAt': now,
    'lastUpdated': now,
  };

  test('fromJson parses nested media payload', () {
    final model = TrackedMediaModel.fromJson(json);

    expect(model.mediaType.apiValue, 'series');
    expect(model.mediaId, '42');
    expect(model.rating, 8);
    expect(model.review, 'Great');
    expect(model.media!.title, 'Test Show');
  });
}
```

Replace `_trackingJson` and the query assertion in
`test/features/tracking/data/repositories/tracking_repository_test.dart` with:

```dart
Map<String, dynamic> _trackingJson(String id, String mediaType) => {
      'trackingId': id,
      'userId': 'user-1',
      'mediaType': mediaType,
      'mediaId': '123',
      'status': 'WATCHING',
      'rating': 8,
      'review': 'Great!',
      'addedAt': now,
      'lastUpdated': now,
      'media': {
        'tmdbId': 123,
        'title': mediaType == 'movie' ? 'Movie 123' : 'Series 123',
        'mediaType': mediaType,
      },
    };

test('getTracking() passes status, mediaType, page, pageSize, includeMedia',
    () async {
  Map<String, dynamic>? capturedParams;
  final dio = Dio()
    ..httpClientAdapter = MockAdapter(
      onFetch: (options) {
        capturedParams = options.queryParameters;
        return _json({'items': <Map<String, dynamic>>[]});
      },
    );
  final repo = TrackingRepositoryImpl(dio);

  await repo.getTracking(
    status: 'WATCHING',
    mediaType: MediaType.movie,
    page: 2,
    pageSize: 10,
  );

  expect(capturedParams!['status'], 'WATCHING');
  expect(capturedParams!['mediaType'], 'movie');
  expect(capturedParams!['page'], 2);
  expect(capturedParams!['pageSize'], 10);
  expect(capturedParams!['includeMedia'], true);
});
```

- [ ] **Step 2: Update the series and tracking ViewModel tests to the new
  contract**

In `test/features/series/viewmodels/series_detail_viewmodel_test.dart`, switch
the fake repo and expectations to `TrackedMediaModel`:

```dart
class FakeTrackingRepo implements TrackingRepository {
  List<TrackedMediaModel> trackingResults = [];
  bool shouldThrowTracking = false;
  TrackedMediaModel? lastStartedTracking;
  TrackedMediaModel? lastUpdatedTracking;
  String? lastDeletedMediaId;
  MediaType? lastMediaType;
  Map<String, dynamic>? lastUpdatedFields;

  @override
  Future<List<TrackedMediaModel>> getTracking({
    String? status,
    MediaType? mediaType,
    int pageSize = 20,
    int page = 1,
  }) async {
    lastMediaType = mediaType;
    if (shouldThrowTracking) throw Exception('failed');
    return trackingResults;
  }

  @override
  Future<TrackedMediaModel> startTracking(
    String mediaId,
    MediaType mediaType,
    String status,
  ) async {
    final now = DateTime.now();
    final result = TrackedMediaModel(
      trackingId: 'track-$mediaId',
      userId: 'user-1',
      mediaType: mediaType,
      mediaId: mediaId,
      status: status,
      addedAt: now,
      lastUpdated: now,
    );
    lastStartedTracking = result;
    return result;
  }
```

Add this expectation to `build() returns SeriesDetailState with series and
tracking`:

```dart
expect(trackingRepo.lastMediaType, MediaType.series);
```

In `test/features/tracking/viewmodels/tracking_list_viewmodel_test.dart`, make
the fake repo generic and assert the default type stays `series`:

```dart
MediaType? lastMediaType;

@override
Future<List<TrackedMediaModel>> getTracking({
  String? status,
  MediaType? mediaType,
  int page = 1,
  int pageSize = 20,
}) async {
  lastMediaType = mediaType;
  if (shouldThrow) throw Exception('Failed');
  return results ?? [];
}

test('loadTracking() defaults to series media type', () async {
  final repo = FakeTrackingRepo()..results = [_makeTracking('t-1', 'WATCHING')];
  final container = createContainer(repo);
  addTearDown(container.dispose);

  await container.read(trackingListViewModelProvider.notifier).loadTracking(
        status: 'WATCHING',
      );

  expect(repo.lastMediaType, MediaType.series);
});
```

- [ ] **Step 3: Run the changed tests and confirm they fail**

Run:

```bash
flutter test test/features/tracking/data/models/tracked_media_summary_model_test.dart test/features/tracking/data/models/tracked_media_model_test.dart test/features/tracking/data/repositories/tracking_repository_test.dart test/features/tracking/viewmodels/tracking_list_viewmodel_test.dart test/features/series/viewmodels/series_detail_viewmodel_test.dart test/features/series/pages/series_detail_page_test.dart -v
```

Expected: FAIL with missing models, missing generic repository methods, and old
`TrackedSeriesModel` references.

- [ ] **Step 4: Add the generic tracked media models**

Create `lib/features/tracking/data/models/tracked_media_summary_model.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'media_type.dart';

part 'tracked_media_summary_model.freezed.dart';
part 'tracked_media_summary_model.g.dart';

@freezed
class TrackedMediaSummaryModel with _$TrackedMediaSummaryModel {
  const factory TrackedMediaSummaryModel({
    required int tmdbId,
    required String title,
    @JsonKey(fromJson: mediaTypeFromJson, toJson: mediaTypeToJson)
    required MediaType mediaType,
    String? posterPath,
    String? backdropPath,
  }) = _TrackedMediaSummaryModel;

  factory TrackedMediaSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$TrackedMediaSummaryModelFromJson(json);
}
```

Create `lib/features/tracking/data/models/tracked_media_model.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'media_type.dart';
import 'season_rating_model.dart';
import 'tracked_media_summary_model.dart';

part 'tracked_media_model.freezed.dart';
part 'tracked_media_model.g.dart';

@freezed
class TrackedMediaModel with _$TrackedMediaModel {
  const factory TrackedMediaModel({
    required String trackingId,
    required String userId,
    @JsonKey(fromJson: mediaTypeFromJson, toJson: mediaTypeToJson)
    required MediaType mediaType,
    required String mediaId,
    required String status,
    int? rating,
    String? review,
    @Default([]) List<SeasonRatingModel> seasonRatings,
    TrackedMediaSummaryModel? media,
    required DateTime addedAt,
    required DateTime lastUpdated,
  }) = _TrackedMediaModel;

  factory TrackedMediaModel.fromJson(Map<String, dynamic> json) =>
      _$TrackedMediaModelFromJson(json);
}
```

- [ ] **Step 5: Make the tracking repository media-aware**

Replace the abstract contract and implementation in
`lib/features/tracking/data/repositories/tracking_repository.dart` with:

```dart
abstract class TrackingRepository {
  Future<List<TrackedMediaModel>> getTracking({
    String? status,
    MediaType? mediaType,
    int page = 1,
    int pageSize = 20,
  });

  Future<TrackedMediaModel> startTracking(
    String mediaId,
    MediaType mediaType,
    String status,
  );

  Future<TrackedMediaModel> updateTracking(
    String mediaId, {
    required MediaType mediaType,
    String? status,
    int? rating,
    String? review,
    List<Map<String, dynamic>>? seasonRatings,
  });

  Future<void> deleteTracking(
    String mediaId, {
    required MediaType mediaType,
  });
}
```

Update the three request builders:

```dart
final response = await _dio.get(
  '/tracking',
  queryParameters: {
    if (status != null) 'status': status,
    if (mediaType != null) 'mediaType': mediaType.apiValue,
    'page': page,
    'pageSize': pageSize,
    'includeMedia': true,
  },
);

final response = await _dio.post(
  '/tracking',
  data: {
    'mediaId': mediaId,
    'mediaType': mediaType.apiValue,
    'status': status,
  },
);

final data = <String, dynamic>{
  'mediaType': mediaType.apiValue,
  if (status != null) 'status': status,
  if (rating != null) 'rating': rating,
  if (review != null) 'review': review,
  if (seasonRatings != null) 'seasonRatings': seasonRatings,
};
```

Use `TrackedMediaModel.fromJson` everywhere in the repository.

- [ ] **Step 6: Migrate the current series flows to `TrackedMediaModel`**

In `lib/features/series/viewmodels/series_detail_state.dart`:

```dart
import '../../tracking/data/models/tracked_media_model.dart';

@freezed
class SeriesDetailState with _$SeriesDetailState {
  const factory SeriesDetailState({
    required SeriesModel series,
    TrackedMediaModel? tracking,
  }) = _SeriesDetailState;
}
```

In `lib/features/series/viewmodels/series_detail_viewmodel.dart`:

```dart
final allTracking = await trackingRepo.getTracking(
  mediaType: MediaType.series,
  pageSize: 1000,
);
tracking = allTracking.firstWhere(
  (t) =>
      (t.media != null && t.media!.tmdbId == tmdbId) ||
      t.mediaId == tmdbId.toString(),
);
```

Update mutations:

```dart
final tracking = await trackingRepo.startTracking(
  currentState.series.tmdbId.toString(),
  MediaType.series,
  status,
);

await trackingRepo.updateTracking(
  tracking.mediaId,
  mediaType: MediaType.series,
  rating: rating,
  review: review,
);

await trackingRepo.deleteTracking(
  current.mediaId,
  mediaType: MediaType.series,
);
```

In `lib/features/tracking/viewmodels/tracking_list_viewmodel.dart`:

```dart
class TrackingListViewModel extends _$TrackingListViewModel {
  String? _currentStatus;
  MediaType _currentMediaType = MediaType.series;
  int _page = 1;

  Future<void> loadTracking({
    String? status,
    MediaType mediaType = MediaType.series,
  }) async {
    _currentStatus = status;
    _currentMediaType = mediaType;
    _page = 1;

    final cacheKey = _buildCacheKey();
    final cacheService = ref.read(cacheServiceProvider);

    var hit = cacheService.getSync(cacheKey);
    hit ??= cacheService.getFromDiskSync(cacheKey);

    if (hit != null) {
      state = AsyncValue.data(_parseItems(hit.json));
      if (!hit.isFresh) {
        _backgroundRefresh(cacheKey);
      }
      return;
    }

    state = const AsyncValue.loading();
    await _fetch(append: false);
  }

  String _buildCacheKey() =>
      'tracking:${_currentMediaType.apiValue}:${_currentStatus ?? "all"}:$_page';
```

Update `lib/features/tracking/pages/tracking_list_page.dart` to read the
generic fields while keeping the existing series-only page structure:

```dart
final media = tracking.media;
if (media == null) {
  return const Center(child: Icon(Icons.tv_off, color: Colors.grey));
}

return Column(
  children: [
    Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) => TrackedMediaPoster(
          media: media,
          width: constraints.maxWidth,
          onTap: media.tmdbId != 0
              ? () => context.push('/series/${media.tmdbId}')
              : null,
        ),
      ),
    ),
    const SizedBox(height: 4),
    RatingStars(
      rating: tracking.rating,
      size: 10,
      maxRating: 10,
    ),
  ],
);
```

In `lib/features/series/pages/series_detail_page.dart`, rename the local
tracking fields:

```dart
int? selectedRating = tracking?.rating;
final reviewController = TextEditingController(text: tracking?.review ?? '');
```

And update the notifier calls:

```dart
Future<void> addTracking(
  String status, {
  int? rating,
  String? review,
}) async {
  final currentState = state.valueOrNull;
  if (currentState == null) return;
  final trackingRepo = ref.read(trackingRepositoryProvider);
  final tracking = await trackingRepo.startTracking(
    currentState.series.tmdbId.toString(),
    MediaType.series,
    status,
  );
  if (rating != null || (review != null && review.isNotEmpty)) {
    await trackingRepo.updateTracking(
      tracking.mediaId,
      mediaType: MediaType.series,
      rating: rating,
      review: review,
    );
  }
  await ref.read(cacheServiceProvider).remove('dashboard:series');
  await ref.read(cacheServiceProvider).removeByPrefix('tracking:');
  ref.invalidateSelf();
}

Future<void> updateTracking({
  String? status,
  int? rating,
  String? review,
}) async {
  final current = state.valueOrNull?.tracking;
  if (current == null) return;
  await ref.read(trackingRepositoryProvider).updateTracking(
        current.mediaId,
        mediaType: MediaType.series,
        status: status,
        rating: rating,
        review: review,
      );
  await ref.read(cacheServiceProvider).remove('dashboard:series');
  await ref.read(cacheServiceProvider).removeByPrefix('tracking:');
  ref.invalidateSelf();
}

Future<void> removeTracking() async {
  final current = state.valueOrNull?.tracking;
  if (current == null) return;
  await ref.read(trackingRepositoryProvider).deleteTracking(
        current.mediaId,
        mediaType: MediaType.series,
      );
  await ref.read(cacheServiceProvider).remove('dashboard:series');
  await ref.read(cacheServiceProvider).removeByPrefix('tracking:');
  ref.invalidateSelf();
}

await notifier.updateTracking(
  status: selectedStatus,
  rating: selectedRating,
  review: reviewController.text.isNotEmpty ? reviewController.text : null,
);
```

- [ ] **Step 7: Add the shared poster and remove the old series-only tracking
  model**

Create `lib/features/tracking/widgets/tracked_media_poster.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image_platform_interface/cached_network_image_platform_interface.dart';
import '../data/models/tracked_media_summary_model.dart';

class TrackedMediaPoster extends StatelessWidget {
  final TrackedMediaSummaryModel media;
  final double width;
  final VoidCallback? onTap;

  const TrackedMediaPoster({
    super.key,
    required this.media,
    this.width = 120,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: width,
              height: width * 1.5,
              color: Colors.grey[300],
              child: CachedNetworkImage(
                imageUrl: media.posterPath ?? '',
                imageRenderMethodForWeb: ImageRenderMethodForWeb.HttpGet,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => const Icon(Icons.broken_image),
              ),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: width,
            child: Text(
              media.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
```

Delete the old source and test files:

```bash
rm lib/features/tracking/data/models/tracked_series_model.dart
rm test/features/tracking/data/models/tracked_series_model_test.dart
```

- [ ] **Step 8: Regenerate code and rerun the targeted suite**

Run:

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/features/tracking/data/models/tracked_media_summary_model_test.dart test/features/tracking/data/models/tracked_media_model_test.dart test/features/tracking/data/repositories/tracking_repository_test.dart test/features/tracking/viewmodels/tracking_list_viewmodel_test.dart test/features/tracking/pages/tracking_list_page_test.dart test/features/series/viewmodels/series_detail_viewmodel_test.dart test/features/series/pages/series_detail_page_test.dart -v
```

Expected: PASS.

- [ ] **Step 9: Commit the generic tracking migration**

```bash
git add -A lib/features/tracking/data/models test/features/tracking/data/models
git add lib/features/tracking/data/repositories/tracking_repository.dart lib/features/tracking/viewmodels/tracking_list_viewmodel.dart lib/features/tracking/viewmodels/tracking_list_viewmodel.g.dart lib/features/tracking/pages/tracking_list_page.dart lib/features/tracking/widgets/tracked_media_poster.dart lib/features/series/viewmodels/series_detail_state.dart lib/features/series/viewmodels/series_detail_state.freezed.dart lib/features/series/viewmodels/series_detail_viewmodel.dart lib/features/series/pages/series_detail_page.dart test/features/tracking/data/repositories/tracking_repository_test.dart test/features/tracking/viewmodels/tracking_list_viewmodel_test.dart test/features/tracking/pages/tracking_list_page_test.dart test/features/series/viewmodels/series_detail_viewmodel_test.dart test/features/series/pages/series_detail_page_test.dart
git commit -m "refactor: migrate tracking to generic media models"
```

### Task 3: Add the movie catalog data layer

**Files:**
- Create: `lib/features/movies/data/models/movie_model.dart`
- Create: `lib/features/movies/data/repositories/movie_repository.dart`
- Create: `lib/features/movies/viewmodels/movie_search_viewmodel.dart`
- Create: `test/features/movies/data/models/movie_model_test.dart`
- Create: `test/features/movies/data/repositories/movie_repository_test.dart`
- Create: `test/features/movies/viewmodels/movie_search_viewmodel_test.dart`

- [ ] **Step 1: Write the failing movie model, repository, and ViewModel
  tests**

Create `test/features/movies/data/models/movie_model_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/movies/data/models/movie_model.dart';

void main() {
  const json = {
    'tmdbId': 550,
    'title': 'Fight Club',
    'overview': 'A film',
    'posterPath': '/fight.jpg',
    'backdropPath': '/fight-bg.jpg',
    'releaseDate': '1999-10-15',
    'genres': ['Drama'],
    'runtimeMinutes': 139,
    'status': 'Released',
  };

  test('fromJson maps movie fields', () {
    final movie = MovieModel.fromJson(json);

    expect(movie.tmdbId, 550);
    expect(movie.title, 'Fight Club');
    expect(movie.releaseDate, '1999-10-15');
    expect(movie.runtimeMinutes, 139);
  });
}
```

Create `test/features/movies/data/repositories/movie_repository_test.dart` with
the same `MockAdapter` pattern as `series_repository_test.dart`, but target the
movie routes:

```dart
test('searchMovies() passes q and limit to /movies', () async {
  String? capturedQuery;
  final dio = Dio()
    ..httpClientAdapter = MockAdapter(
      onFetch: (options) {
        capturedQuery = options.queryParameters['q'] as String?;
        return _json({'items': <Map<String, dynamic>>[]});
      },
    );
  final repo = MovieRepositoryImpl(dio);

  await repo.searchMovies('fight', limit: 10);
  expect(capturedQuery, 'fight');
});
```

Create `test/features/movies/viewmodels/movie_search_viewmodel_test.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/movies/data/models/movie_model.dart';
import 'package:lorebase/features/movies/data/repositories/movie_repository.dart';
import 'package:lorebase/features/movies/viewmodels/movie_search_viewmodel.dart';

class FakeMovieRepo implements MovieRepository {
  List<MovieModel>? results;
  bool shouldThrow = false;
  CancelToken? lastCancelToken;

  @override
  Future<List<MovieModel>> searchMovies(
    String query, {
    int limit = 20,
    CancelToken? cancelToken,
  }) async {
    lastCancelToken = cancelToken;
    if (shouldThrow) {
      throw DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: ''),
      );
    }
    return results ?? [];
  }

  @override
  Future<MovieModel> getMovieById(String id) async {
    throw UnimplementedError();
  }
}
```

Add one success test:

```dart
test('search() returns movie results', () async {
  final repo = FakeMovieRepo()
    ..results = [const MovieModel(tmdbId: 1, title: 'Movie')];
  final container = ProviderContainer(overrides: [
    movieRepositoryProvider.overrideWith((ref) => repo),
  ]);
  addTearDown(container.dispose);

  await container.read(movieSearchViewModelProvider.notifier).search('movie');

  expect(container.read(movieSearchViewModelProvider).value!.single.title, 'Movie');
});
```

- [ ] **Step 2: Run the new movie data tests and confirm they fail**

Run:

```bash
flutter test test/features/movies/data/models/movie_model_test.dart test/features/movies/data/repositories/movie_repository_test.dart test/features/movies/viewmodels/movie_search_viewmodel_test.dart -v
```

Expected: FAIL with missing movie files and providers.

- [ ] **Step 3: Implement `MovieModel`, `MovieRepository`, and
  `MovieSearchViewModel`**

Create `lib/features/movies/data/models/movie_model.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'movie_model.freezed.dart';
part 'movie_model.g.dart';

@freezed
class MovieModel with _$MovieModel {
  const factory MovieModel({
    required int tmdbId,
    required String title,
    String? overview,
    String? posterPath,
    String? backdropPath,
    String? releaseDate,
    @Default([]) List<String> genres,
    int? runtimeMinutes,
    String? status,
  }) = _MovieModel;

  factory MovieModel.fromJson(Map<String, dynamic> json) =>
      _$MovieModelFromJson(json);
}
```

Create `lib/features/movies/data/repositories/movie_repository.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/providers/core_providers.dart';
import '../models/movie_model.dart';

abstract class MovieRepository {
  Future<List<MovieModel>> searchMovies(
    String query, {
    int limit = 20,
    CancelToken? cancelToken,
  });

  Future<MovieModel> getMovieById(String id);
}

class MovieRepositoryImpl implements MovieRepository {
  final Dio _dio;

  MovieRepositoryImpl(this._dio);

  @override
  Future<List<MovieModel>> searchMovies(
    String query, {
    int limit = 20,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        '/movies',
        queryParameters: {'q': query, 'limit': limit},
        cancelToken: cancelToken,
      );
      final items = response.data['items'] as List;
      return items.map((json) => MovieModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to search movies',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<MovieModel> getMovieById(String id) async {
    try {
      final response = await _dio.get('/movies/$id');
      return MovieModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to load movie',
        statusCode: e.response?.statusCode,
      );
    }
  }
}

final movieRepositoryProvider = Provider<MovieRepository>((ref) {
  return MovieRepositoryImpl(ref.watch(dioProvider));
});
```

Create `lib/features/movies/viewmodels/movie_search_viewmodel.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/movie_model.dart';
import '../data/repositories/movie_repository.dart';

part 'movie_search_viewmodel.g.dart';

@riverpod
class MovieSearchViewModel extends _$MovieSearchViewModel {
  CancelToken? _cancelToken;

  @override
  AsyncValue<List<MovieModel>> build() {
    return const AsyncValue.data([]);
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    _cancelToken?.cancel();
    final cancelToken = CancelToken();
    _cancelToken = cancelToken;

    state = const AsyncValue.loading();
    try {
      final results = await ref.read(movieRepositoryProvider).searchMovies(
            query,
            cancelToken: cancelToken,
          );
      state = AsyncValue.data(results);
    } catch (error, stackTrace) {
      if (error is DioException && error.type == DioExceptionType.cancel) return;
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void clear() {
    _cancelToken?.cancel();
    _cancelToken = null;
    state = const AsyncValue.data([]);
  }
}
```

- [ ] **Step 4: Run codegen and the movie data tests**

Run:

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/features/movies/data/models/movie_model_test.dart test/features/movies/data/repositories/movie_repository_test.dart test/features/movies/viewmodels/movie_search_viewmodel_test.dart -v
```

Expected: PASS.

- [ ] **Step 5: Commit the movie data layer**

```bash
git add lib/features/movies/data/models/movie_model.dart lib/features/movies/data/repositories/movie_repository.dart lib/features/movies/viewmodels/movie_search_viewmodel.dart test/features/movies/data/models/movie_model_test.dart test/features/movies/data/repositories/movie_repository_test.dart test/features/movies/viewmodels/movie_search_viewmodel_test.dart lib/features/movies/data/models/movie_model.freezed.dart lib/features/movies/data/models/movie_model.g.dart lib/features/movies/viewmodels/movie_search_viewmodel.g.dart
git commit -m "feat: add movie catalog data layer"
```

### Task 4: Segment `/search` by media type

**Files:**
- Create: `lib/features/movies/widgets/movie_card.dart`
- Create: `test/features/movies/widgets/movie_card_test.dart`
- Modify: `lib/features/series/pages/series_search_page.dart`
- Modify: `test/features/series/pages/series_search_page_test.dart`
- Modify: `lib/l10n/strings.g.dart` via codegen

- [ ] **Step 1: Add failing tests for the movie card and the segmented search
  page**

Create `test/features/movies/widgets/movie_card_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/movies/data/models/movie_model.dart';
import 'package:lorebase/features/movies/widgets/movie_card.dart';

void main() {
  testWidgets('renders movie title and release date', (tester) async {
    const movie = MovieModel(
      tmdbId: 1,
      title: 'Movie Title',
      releaseDate: '2024-01-01',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: MovieCard(movie: movie)),
      ),
    );

    expect(find.text('Movie Title'), findsOneWidget);
    expect(find.text('2024-01-01'), findsOneWidget);
  });
}
```

In `test/features/series/pages/series_search_page_test.dart`, add a movie-mode
fake ViewModel and a toggle test:

```dart
class FakeMovieSearchVM extends MovieSearchViewModel {
  final AsyncValue<List<MovieModel>> testState;
  bool searchCalled = false;

  FakeMovieSearchVM({AsyncValue<List<MovieModel>>? state})
      : testState = state ?? const AsyncValue.data([]);

  @override
  AsyncValue<List<MovieModel>> build() => testState;

  @override
  Future<void> search(String query) async {
    searchCalled = true;
  }

  @override
  void clear() {}
}

testWidgets('switching to Movies shows the movie hint', (tester) async {
  final container = ProviderContainer(overrides: [
    seriesSearchViewModelProvider.overrideWith(() => FakeSearchVM()),
    movieSearchViewModelProvider.overrideWith(() => FakeMovieSearchVM()),
    authViewModelProvider.overrideWith(() => FakeAuthVM()),
  ]);
  addTearDown(container.dispose);

  await tester.pumpWidget(_wrap(container));
  await tester.pump();

  await tester.tap(find.text('Movies'));
  await tester.pumpAndSettle();

  expect(find.text('Search movies...'), findsOneWidget);
});
```

- [ ] **Step 2: Run the segmented search tests and confirm they fail**

Run:

```bash
flutter test test/features/movies/widgets/movie_card_test.dart test/features/series/pages/series_search_page_test.dart -v
```

Expected: FAIL because the movie card, movie provider override, and media
toggle do not exist in the page.

- [ ] **Step 3: Add `MovieCard` and update the search page**

Create `lib/features/movies/widgets/movie_card.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image_platform_interface/cached_network_image_platform_interface.dart';
import '../data/models/movie_model.dart';

class MovieCard extends StatelessWidget {
  final MovieModel movie;
  final VoidCallback? onTap;

  const MovieCard({super.key, required this.movie, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            SizedBox(
              width: 100,
              height: 150,
              child: CachedNetworkImage(
                imageUrl: movie.posterPath ?? '',
                imageRenderMethodForWeb: ImageRenderMethodForWeb.HttpGet,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => const Icon(Icons.broken_image),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(movie.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    if (movie.genres.isNotEmpty) Text(movie.genres.join(', ')),
                    const SizedBox(height: 4),
                    if (movie.releaseDate != null) Text(movie.releaseDate!),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

Update `lib/features/series/pages/series_search_page.dart` so the page keeps
the `/search` route but stores the selected media type locally:

```dart
class _SeriesSearchPageState extends ConsumerState<SeriesSearchPage> {
  Timer? _debounceTimer;
  final _searchController = TextEditingController();
  MediaType _selectedType = MediaType.series;

  void _onTypeChanged(MediaType type) {
    setState(() {
      _selectedType = type;
    });
    _searchController.clear();
    ref.read(seriesSearchViewModelProvider.notifier).clear();
    ref.read(movieSearchViewModelProvider.notifier).clear();
  }
```

Replace the AppBar title and body wiring:

```dart
appBar: AppBar(
  title: TextField(
    controller: _searchController,
    autofocus: true,
    decoration: InputDecoration(
      hintText: _selectedType == MediaType.series
          ? context.t.search_hint
          : context.t.search_hint_movies,
      border: InputBorder.none,
    ),
    onChanged: _onSearchChanged,
  ),
),
body: Column(
  children: [
    Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: MediaTypeToggle(
        selectedType: _selectedType,
        onChanged: _onTypeChanged,
      ),
    ),
    Expanded(
      child: _SearchResultsBody(
        query: _searchController.text,
        mediaType: _selectedType,
        onRetry: () => _onSearchChanged(_searchController.text),
      ),
    ),
  ],
),
```

Update `_SearchResultsBody` to watch the active provider and render the correct
card type:

```dart
final seriesState = ref.watch(seriesSearchViewModelProvider);
final movieState = ref.watch(movieSearchViewModelProvider);
final activeState = mediaType == MediaType.series ? seriesState : movieState;
```

For movie results:

```dart
if (mediaType == MediaType.movie) {
  final movies = activeState.valueOrNull ?? const <MovieModel>[];
  return ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: movies.length,
    itemBuilder: (context, index) {
      final item = movies[index];
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: MovieCard(
          movie: item,
          onTap: item.tmdbId != 0
              ? () => context.push('/movies/${item.tmdbId}')
              : null,
        ),
      );
    },
  );
}
```

- [ ] **Step 4: Regenerate code and rerun the segmented search suite**

Run:

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/features/movies/widgets/movie_card_test.dart test/features/series/pages/series_search_page_test.dart test/features/movies/viewmodels/movie_search_viewmodel_test.dart -v
```

Expected: PASS.

- [ ] **Step 5: Commit the segmented search page**

```bash
git add lib/features/movies/widgets/movie_card.dart lib/features/series/pages/series_search_page.dart test/features/movies/widgets/movie_card_test.dart test/features/series/pages/series_search_page_test.dart
git commit -m "feat: segment search by media type"
```

### Task 5: Add a shared tracking editor and the movie detail route

**Files:**
- Create: `lib/features/tracking/widgets/tracking_editor_sheet.dart`
- Create: `lib/features/movies/viewmodels/movie_detail_state.dart`
- Create: `lib/features/movies/viewmodels/movie_detail_viewmodel.dart`
- Create: `lib/features/movies/pages/movie_detail_page.dart`
- Create: `test/features/tracking/widgets/tracking_editor_sheet_test.dart`
- Create: `test/features/movies/viewmodels/movie_detail_viewmodel_test.dart`
- Create: `test/features/movies/pages/movie_detail_page_test.dart`
- Modify: `lib/features/series/pages/series_detail_page.dart`
- Modify: `lib/router.dart`
- Modify: `test/router_test.dart`
- Delete: `lib/features/tracking/widgets/status_bottom_sheet.dart`
- Delete: `test/features/tracking/widgets/status_bottom_sheet_test.dart`

- [ ] **Step 1: Write failing tests for the shared editor, movie detail, and
  router path**

Create `test/features/tracking/widgets/tracking_editor_sheet_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/tracking/widgets/tracking_editor_sheet.dart';
import 'package:lorebase/l10n/strings.g.dart';

Future<void> main() async {
  await LocaleSettings.setLocale(AppLocale.enUs);

  testWidgets('saves status, rating, and review', (tester) async {
    String? savedStatus;
    int? savedRating;
    String? savedReview;

    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: TrackingEditorSheet(
              title: 'Add to List',
              initialStatus: 'WATCHING',
              initialRating: 7,
              initialReview: 'Nice',
              onSave: ({required status, rating, review}) async {
                savedStatus = status;
                savedRating = rating;
                savedReview = review;
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    expect(savedStatus, 'WATCHING');
    expect(savedRating, 7);
    expect(savedReview, 'Nice');
  });
}
```

Create `test/features/movies/pages/movie_detail_page_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lorebase/features/auth/viewmodels/auth_state.dart';
import 'package:lorebase/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:lorebase/features/movies/data/models/movie_model.dart';
import 'package:lorebase/features/movies/pages/movie_detail_page.dart';
import 'package:lorebase/features/movies/viewmodels/movie_detail_state.dart';
import 'package:lorebase/features/movies/viewmodels/movie_detail_viewmodel.dart';
import 'package:lorebase/l10n/strings.g.dart';

class FakeMovieDetailVM extends MovieDetailViewModel {
  final MovieDetailState data;

  FakeMovieDetailVM(this.data);

  @override
  Future<MovieDetailState> build(int tmdbId) async => data;
}

class FakeAuthVM extends AuthViewModel {
  @override
  AuthState build() => const AuthState.authenticated('user-1');

  @override
  void setAuthenticated(String userId) {}

  @override
  void setUnauthenticated() {}

  @override
  Future<void> signOut() async {}
}

Future<void> main() async {
  await LocaleSettings.setLocale(AppLocale.enUs);

  testWidgets('renders Add to List and movie metadata', (tester) async {
    final container = ProviderContainer(overrides: [
      movieDetailViewModelProvider(7).overrideWith(
        () => FakeMovieDetailVM(
          const MovieDetailState(
            movie: MovieModel(
              tmdbId: 7,
              title: 'Se7en',
              releaseDate: '1995-09-22',
              runtimeMinutes: 127,
            ),
          ),
        ),
      ),
      authViewModelProvider.overrideWith(() => FakeAuthVM()),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TranslationProvider(
          child: MaterialApp.router(
            routerConfig: GoRouter(
              initialLocation: '/movies/7',
              routes: [
                GoRoute(
                  path: '/movies/:tmdbId',
                  builder: (_, state) => MovieDetailPage(
                    tmdbId: int.parse(state.pathParameters['tmdbId']!),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Se7en'), findsWidgets);
    expect(find.text('Release Date'), findsOneWidget);
    expect(find.text('1995-09-22'), findsOneWidget);
    expect(find.text('Runtime'), findsOneWidget);
    expect(find.text('127 min'), findsOneWidget);
    expect(find.text('Add to List'), findsOneWidget);
  });
}
```

Create `test/features/movies/viewmodels/movie_detail_viewmodel_test.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/core/cache/cache_providers.dart';
import 'package:lorebase/core/cache/cache_service.dart';
import 'package:lorebase/features/movies/data/models/movie_model.dart';
import 'package:lorebase/features/movies/data/repositories/movie_repository.dart';
import 'package:lorebase/features/movies/viewmodels/movie_detail_viewmodel.dart';
import 'package:lorebase/features/tracking/data/models/media_type.dart';
import 'package:lorebase/features/tracking/data/models/tracked_media_model.dart';
import 'package:lorebase/features/tracking/data/models/tracked_media_summary_model.dart';
import 'package:lorebase/features/tracking/data/repositories/tracking_repository.dart';

class FakeMovieRepo implements MovieRepository {
  MovieModel? movieResult;

  @override
  Future<MovieModel> getMovieById(String id) async => movieResult!;

  @override
  Future<List<MovieModel>> searchMovies(
    String query, {
    int limit = 20,
    CancelToken? cancelToken,
  }) async {
    throw UnimplementedError();
  }
}

class FakeTrackingRepo implements TrackingRepository {
  List<TrackedMediaModel> trackingResults = [];

  @override
  Future<List<TrackedMediaModel>> getTracking({
    String? status,
    MediaType? mediaType,
    int page = 1,
    int pageSize = 20,
  }) async => trackingResults;

  @override
  Future<TrackedMediaModel> startTracking(
    String mediaId,
    MediaType mediaType,
    String status,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<TrackedMediaModel> updateTracking(
    String mediaId, {
    required MediaType mediaType,
    String? status,
    int? rating,
    String? review,
    List<Map<String, dynamic>>? seasonRatings,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteTracking(
    String mediaId, {
    required MediaType mediaType,
  }) async {}
}

test('build() loads movie and matching movie tracking', () async {
  final movieRepo = FakeMovieRepo()
    ..movieResult = const MovieModel(tmdbId: 7, title: 'Se7en');
  final trackingRepo = FakeTrackingRepo()
    ..trackingResults = [
      TrackedMediaModel(
        trackingId: 'track-7',
        userId: 'user-1',
        mediaType: MediaType.movie,
        mediaId: '7',
        status: 'WATCHING',
        media: const TrackedMediaSummaryModel(
          tmdbId: 7,
          title: 'Se7en',
          mediaType: MediaType.movie,
        ),
        addedAt: DateTime.now(),
        lastUpdated: DateTime.now(),
      ),
    ];

  final container = ProviderContainer(overrides: [
    movieRepositoryProvider.overrideWith((ref) => movieRepo),
    trackingRepositoryProvider.overrideWith((ref) => trackingRepo),
    cacheServiceProvider.overrideWith((ref) => CacheService()),
  ]);
  addTearDown(container.dispose);

  final state = await container.read(movieDetailViewModelProvider(7).future);

  expect(state.movie.title, 'Se7en');
  expect(state.tracking, isNotNull);
  expect(state.tracking!.mediaType, MediaType.movie);
});
```

Add a router assertion to `test/router_test.dart`:

```dart
expect(authRedirect(unauthenticated, '/movies/123'), '/login');
expect(authRedirect(authenticated, '/movies/123'), isNull);
```

- [ ] **Step 2: Run the new movie detail tests and confirm they fail**

Run:

```bash
flutter test test/features/tracking/widgets/tracking_editor_sheet_test.dart test/features/movies/viewmodels/movie_detail_viewmodel_test.dart test/features/movies/pages/movie_detail_page_test.dart test/router_test.dart -v
```

Expected: FAIL with missing sheet, movie detail files, and router path.

- [ ] **Step 3: Implement the shared tracking editor and move series detail to
  it**

Create `lib/features/tracking/widgets/tracking_editor_sheet.dart`:

```dart
import 'package:flutter/material.dart';
import '../../../l10n/strings.g.dart';
import '../data/tracking_status.dart';
import 'rating_stars.dart';

class TrackingEditorSheet extends StatefulWidget {
  final String title;
  final String initialStatus;
  final int? initialRating;
  final String initialReview;
  final Future<void> Function({
    required String status,
    int? rating,
    String? review,
  }) onSave;
  final Future<void> Function()? onRemove;
  final String? removeLabel;
  final String? removeConfirmTitle;
  final String? removeConfirmMessage;

  const TrackingEditorSheet({
    super.key,
    required this.title,
    required this.initialStatus,
    required this.initialRating,
    required this.initialReview,
    required this.onSave,
    this.onRemove,
    this.removeLabel,
    this.removeConfirmTitle,
    this.removeConfirmMessage,
  });

  @override
  State<TrackingEditorSheet> createState() => _TrackingEditorSheetState();
}

class _TrackingEditorSheetState extends State<TrackingEditorSheet> {
  late String _status = widget.initialStatus;
  late int? _rating = widget.initialRating;
  late final TextEditingController _reviewController =
      TextEditingController(text: widget.initialReview);
  bool _saving = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              ...TrackingStatus.values.map(
                (status) => ListTile(
                  leading: Icon(
                    status.value == _status
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                  ),
                  title: Text(status.label(context.t)),
                  onTap: () => setState(() => _status = status.value),
                ),
              ),
              const SizedBox(height: 24),
              Text(context.t.series_detail_rating),
              const SizedBox(height: 8),
              RatingStars(
                rating: _rating,
                maxRating: 10,
                onRatingChanged: (value) => setState(() => _rating = value),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _reviewController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: context.t.series_detail_review,
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving
                    ? null
                    : () async {
                        setState(() => _saving = true);
                        try {
                          await widget.onSave(
                            status: _status,
                            rating: _rating,
                            review: _reviewController.text.isEmpty
                                ? null
                                : _reviewController.text,
                          );
                        } finally {
                          if (mounted) {
                            setState(() => _saving = false);
                          }
                        }
                      },
                child: Text(context.t.series_detail_save_changes),
              ),
              if (widget.onRemove != null) ...[
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: Text(widget.removeConfirmTitle!),
                        content: Text(widget.removeConfirmMessage!),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext, false),
                            child: Text(context.t.series_detail_cancel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext, true),
                            child: Text(context.t.series_detail_remove),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await widget.onRemove!();
                      if (mounted) Navigator.pop(context);
                    }
                  },
                  child: Text(widget.removeLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
```

In `lib/features/series/pages/series_detail_page.dart`, replace the inline
`showModalBottomSheet` builder with:

```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (ctx) => TrackingEditorSheet(
    title: isEditing
        ? ctx.t.series_detail_manage_tracking
        : ctx.t.series_detail_add_to_list,
    initialStatus: tracking?.status ?? TrackingStatus.wantToWatch.value,
    initialRating: tracking?.rating,
    initialReview: tracking?.review ?? '',
    onSave: ({required status, rating, review}) async {
      final notifier = ref.read(seriesDetailViewModelProvider(tmdbId).notifier);
      if (isEditing) {
        await notifier.updateTracking(
          status: status,
          rating: rating,
          review: review,
        );
      } else {
        await notifier.addTracking(
          status,
          rating: rating,
          review: review,
        );
      }
      if (ctx.mounted) Navigator.pop(ctx);
    },
    onRemove: isEditing ? () => ref.read(seriesDetailViewModelProvider(tmdbId).notifier).removeTracking() : null,
    removeLabel: ctx.t.series_detail_remove_from_list,
    removeConfirmTitle: ctx.t.series_detail_remove_from_list,
    removeConfirmMessage: ctx.t.series_detail_remove_confirm
        .replaceFirst('{title}', series.title),
  ),
);
```

- [ ] **Step 4: Implement movie detail state, ViewModel, page, and route**

Create `lib/features/movies/viewmodels/movie_detail_state.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../tracking/data/models/tracked_media_model.dart';
import '../data/models/movie_model.dart';

part 'movie_detail_state.freezed.dart';

@freezed
class MovieDetailState with _$MovieDetailState {
  const factory MovieDetailState({
    required MovieModel movie,
    TrackedMediaModel? tracking,
  }) = _MovieDetailState;
}
```

Create `lib/features/movies/viewmodels/movie_detail_viewmodel.dart`:

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/cache/cache_providers.dart';
import '../../tracking/data/models/media_type.dart';
import '../../tracking/data/repositories/tracking_repository.dart';
import '../data/repositories/movie_repository.dart';
import 'movie_detail_state.dart';

part 'movie_detail_viewmodel.g.dart';

@riverpod
class MovieDetailViewModel extends _$MovieDetailViewModel {
  @override
  Future<MovieDetailState> build(int tmdbId) async {
    final movie = await ref.read(movieRepositoryProvider).getMovieById(
          tmdbId.toString(),
        );
    TrackedMediaModel? tracking;
    try {
      final allTracking = await ref.read(trackingRepositoryProvider).getTracking(
            mediaType: MediaType.movie,
            pageSize: 1000,
          );
      tracking = allTracking.firstWhere(
        (t) =>
            (t.media != null && t.media!.tmdbId == tmdbId) ||
            t.mediaId == tmdbId.toString(),
      );
    } catch (_) {
      tracking = null;
    }
    return MovieDetailState(movie: movie, tracking: tracking);
  }

  Future<void> addTracking(
    String status, {
    int? rating,
    String? review,
  }) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;
    final tracking = await ref.read(trackingRepositoryProvider).startTracking(
          currentState.movie.tmdbId.toString(),
          MediaType.movie,
          status,
        );
    if (rating != null || (review != null && review.isNotEmpty)) {
      await ref.read(trackingRepositoryProvider).updateTracking(
            tracking.mediaId,
            mediaType: MediaType.movie,
            rating: rating,
            review: review,
          );
    }
    await ref.read(cacheServiceProvider).remove('dashboard:movie');
    await ref.read(cacheServiceProvider).removeByPrefix('tracking:');
    ref.invalidateSelf();
  }

  Future<void> updateTracking({
    String? status,
    int? rating,
    String? review,
  }) async {
    final current = state.valueOrNull?.tracking;
    if (current == null) return;
    await ref.read(trackingRepositoryProvider).updateTracking(
          current.mediaId,
          mediaType: MediaType.movie,
          status: status,
          rating: rating,
          review: review,
        );
    await ref.read(cacheServiceProvider).remove('dashboard:movie');
    await ref.read(cacheServiceProvider).removeByPrefix('tracking:');
    ref.invalidateSelf();
  }

  Future<void> removeTracking() async {
    final current = state.valueOrNull?.tracking;
    if (current == null) return;
    await ref.read(trackingRepositoryProvider).deleteTracking(
          current.mediaId,
          mediaType: MediaType.movie,
        );
    await ref.read(cacheServiceProvider).remove('dashboard:movie');
    await ref.read(cacheServiceProvider).removeByPrefix('tracking:');
    ref.invalidateSelf();
  }
}
```

Create `lib/features/movies/pages/movie_detail_page.dart` with a route-driven
`ConsumerWidget`, a fixed bottom CTA, and the shared editor sheet:

```dart
class MovieDetailPage extends ConsumerWidget {
  final int tmdbId;

  const MovieDetailPage({super.key, required this.tmdbId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(movieDetailViewModelProvider(tmdbId));

    return detailAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: LoadingWidget(message: context.t.movie_detail_loading),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(movieDetailViewModelProvider(tmdbId)),
        ),
      ),
      data: (detail) => Scaffold(
        appBar: AppBar(title: Text(detail.movie.title)),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton.icon(
              onPressed: () => _showTrackingSheet(context, ref, detail),
              icon: Icon(detail.tracking != null ? Icons.edit : Icons.add),
              label: Text(
                detail.tracking != null
                    ? context.t.series_detail_manage_tracking
                    : context.t.series_detail_add_to_list,
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(detail.movie.title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              _InfoCard(
                icon: Icons.calendar_today,
                label: context.t.movie_detail_release_date,
                value: detail.movie.releaseDate ?? '—',
              ),
              const SizedBox(height: 12),
              _InfoCard(
                icon: Icons.schedule,
                label: context.t.movie_detail_runtime,
                value: detail.movie.runtimeMinutes != null
                    ? context.t.movie_detail_runtime_minutes.replaceFirst(
                        '{minutes}',
                        '${detail.movie.runtimeMinutes}',
                      )
                    : '—',
              ),
              const SizedBox(height: 24),
              Text(context.t.series_detail_overview),
              const SizedBox(height: 8),
              Text(detail.movie.overview ?? context.t.series_detail_no_description),
            ],
          ),
        ),
      ),
    );
  }
}
```

Add a private `_showTrackingSheet` helper in the same file:

```dart
void _showTrackingSheet(
  BuildContext context,
  WidgetRef ref,
  MovieDetailState detail,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) => TrackingEditorSheet(
      title: detail.tracking != null
          ? sheetContext.t.series_detail_manage_tracking
          : sheetContext.t.series_detail_add_to_list,
      initialStatus: detail.tracking?.status ?? TrackingStatus.wantToWatch.value,
      initialRating: detail.tracking?.rating,
      initialReview: detail.tracking?.review ?? '',
      onSave: ({required status, rating, review}) async {
        final notifier = ref.read(movieDetailViewModelProvider(detail.movie.tmdbId).notifier);
        if (detail.tracking == null) {
          await notifier.addTracking(status, rating: rating, review: review);
        } else {
          await notifier.updateTracking(
            status: status,
            rating: rating,
            review: review,
          );
        }
        if (sheetContext.mounted) Navigator.pop(sheetContext);
      },
      onRemove: detail.tracking == null
          ? null
          : () => ref
              .read(movieDetailViewModelProvider(detail.movie.tmdbId).notifier)
              .removeTracking(),
      removeLabel: sheetContext.t.series_detail_remove_from_list,
      removeConfirmTitle: sheetContext.t.series_detail_remove_from_list,
      removeConfirmMessage: sheetContext.t.series_detail_remove_confirm
          .replaceFirst('{title}', detail.movie.title),
    ),
  );
}
```

Add to `lib/router.dart` inside the `ShellRoute`:

```dart
GoRoute(
  path: '/movies/:tmdbId',
  builder: (context, state) {
    final tmdbId = int.parse(state.pathParameters['tmdbId']!);
    return MovieDetailPage(tmdbId: tmdbId);
  },
),
```

- [ ] **Step 5: Remove the unused old sheet and rerun codegen/tests**

Run:

```bash
rm lib/features/tracking/widgets/status_bottom_sheet.dart
rm test/features/tracking/widgets/status_bottom_sheet_test.dart
dart run build_runner build --delete-conflicting-outputs
flutter test test/features/tracking/widgets/tracking_editor_sheet_test.dart test/features/movies/viewmodels/movie_detail_viewmodel_test.dart test/features/movies/pages/movie_detail_page_test.dart test/features/series/pages/series_detail_page_test.dart test/router_test.dart -v
```

Expected: PASS.

- [ ] **Step 6: Commit the shared editor and movie detail flow**

```bash
git add -A lib/features/tracking/widgets test/features/tracking/widgets
git add lib/features/movies/viewmodels/movie_detail_state.dart lib/features/movies/viewmodels/movie_detail_viewmodel.dart lib/features/movies/pages/movie_detail_page.dart lib/features/series/pages/series_detail_page.dart lib/router.dart test/features/movies/viewmodels/movie_detail_viewmodel_test.dart test/features/movies/pages/movie_detail_page_test.dart test/router_test.dart lib/features/movies/viewmodels/movie_detail_state.freezed.dart lib/features/movies/viewmodels/movie_detail_viewmodel.g.dart
git commit -m "feat: add movie detail tracking flow"
```

### Task 6: Segment My Lists by media type

**Files:**
- Modify: `lib/features/tracking/viewmodels/tracking_list_viewmodel.dart`
- Modify: `lib/features/tracking/pages/tracking_list_page.dart`
- Modify: `test/features/tracking/viewmodels/tracking_list_viewmodel_test.dart`
- Modify: `test/features/tracking/pages/tracking_list_page_test.dart`
- Create: `test/features/tracking/widgets/tracked_media_poster_test.dart`

- [ ] **Step 1: Add failing tests for movie filtering and movie navigation**

Create `test/features/tracking/widgets/tracked_media_poster_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/tracking/data/models/media_type.dart';
import 'package:lorebase/features/tracking/data/models/tracked_media_summary_model.dart';
import 'package:lorebase/features/tracking/widgets/tracked_media_poster.dart';

void main() {
  testWidgets('shows tracked media title', (tester) async {
    const media = TrackedMediaSummaryModel(
      tmdbId: 1,
      title: 'Movie Title',
      mediaType: MediaType.movie,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: TrackedMediaPoster(media: media)),
      ),
    );

    expect(find.text('Movie Title'), findsOneWidget);
  });
}
```

In `test/features/tracking/pages/tracking_list_page_test.dart`, add a movie
tracking fixture and a selector test:

```dart
TrackedMediaModel _movieTracking(String id, String status) => TrackedMediaModel(
      trackingId: id,
      userId: 'user-1',
      mediaType: MediaType.movie,
      mediaId: '500',
      status: status,
      media: const TrackedMediaSummaryModel(
        tmdbId: 500,
        title: 'Movie 500',
        mediaType: MediaType.movie,
      ),
      addedAt: now,
      lastUpdated: now,
    );

testWidgets('switching to Movies shows movie empty state copy', (tester) async {
  final container = createContainer(FakeTrackingListVM());
  addTearDown(container.dispose);

  await tester.pumpWidget(_wrap(container));
  await tester.pump();

  await tester.tap(find.text('Movies'));
  await tester.pumpAndSettle();

  expect(find.text('No Want to Watch movies yet'), findsOneWidget);
});
```

- [ ] **Step 2: Run the My Lists tests and confirm they fail**

Run:

```bash
flutter test test/features/tracking/widgets/tracked_media_poster_test.dart test/features/tracking/viewmodels/tracking_list_viewmodel_test.dart test/features/tracking/pages/tracking_list_page_test.dart -v
```

Expected: FAIL because the page has no media toggle and the ViewModel is still
hard-coded to the current page layout.

- [ ] **Step 3: Add the media selector and route by `MediaType`**

Update `lib/features/tracking/pages/tracking_list_page.dart`:

```dart
class _TrackingListPageState extends ConsumerState<TrackingListPage>
    with SingleTickerProviderStateMixin {
  MediaType _selectedType = MediaType.series;

  void _onMediaTypeChanged(MediaType type) {
    setState(() {
      _selectedType = type;
    });
    _loadTrackingForTab(_tabController.index);
  }

  void _loadTrackingForTab(int index) {
    final status = TrackingStatus.values[index].value;
    ref.read(trackingListViewModelProvider.notifier).loadTracking(
          status: status,
          mediaType: _selectedType,
        );
  }
}
```

Insert the selector above the `TabBar`:

```dart
Padding(
  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
  child: MediaTypeToggle(
    selectedType: _selectedType,
    onChanged: _onMediaTypeChanged,
  ),
),
```

Switch the empty copy and navigation by media type:

```dart
message: _selectedType == MediaType.series
    ? t.tracking_empty.replaceFirst('{status}', TrackingStatus.values[index].label(t))
    : t.tracking_empty_movies.replaceFirst('{status}', TrackingStatus.values[index].label(t)),
```

and

```dart
onTap: media.tmdbId == 0
    ? null
    : () {
        final path = tracking.mediaType == MediaType.series
            ? '/series/${media.tmdbId}'
            : '/movies/${media.tmdbId}';
        context.push(path);
      },
```

- [ ] **Step 4: Keep the ViewModel cache and query state keyed by media type**

In `lib/features/tracking/viewmodels/tracking_list_viewmodel.dart`, make sure
`refresh()`, `_fetch()`, and `_backgroundRefresh()` all pass the current media
type:

```dart
final items = await repository.getTracking(
  status: _currentStatus,
  mediaType: _currentMediaType,
  page: _page,
  pageSize: _pageSize,
);
```

Update `_invalidateCache()` so it clears both segmented caches:

```dart
Future<void> _invalidateCache() async {
  final cacheService = ref.read(cacheServiceProvider);
  await cacheService.removeByPrefix('dashboard:');
  await cacheService.removeByPrefix('tracking:');
}
```

- [ ] **Step 5: Rerun the My Lists suite**

Run:

```bash
flutter test test/features/tracking/widgets/tracked_media_poster_test.dart test/features/tracking/viewmodels/tracking_list_viewmodel_test.dart test/features/tracking/pages/tracking_list_page_test.dart -v
```

Expected: PASS.

- [ ] **Step 6: Commit the segmented My Lists page**

```bash
git add lib/features/tracking/viewmodels/tracking_list_viewmodel.dart lib/features/tracking/pages/tracking_list_page.dart test/features/tracking/widgets/tracked_media_poster_test.dart test/features/tracking/viewmodels/tracking_list_viewmodel_test.dart test/features/tracking/pages/tracking_list_page_test.dart
git commit -m "feat: segment tracking lists by media type"
```

### Task 7: Segment Dashboard by media type and generic summaries

**Files:**
- Create: `lib/features/dashboard/widgets/tracked_media_horizontal_list.dart`
- Modify: `lib/features/dashboard/data/models/dashboard_section_model.dart`
- Modify: `lib/features/dashboard/data/models/dashboard_model.dart`
- Modify: `lib/features/dashboard/data/repositories/dashboard_repository.dart`
- Modify: `lib/features/dashboard/viewmodels/dashboard_viewmodel.dart`
- Modify: `lib/features/dashboard/widgets/watching_section.dart`
- Modify: `lib/features/dashboard/pages/dashboard_page.dart`
- Modify: `test/features/dashboard/data/models/dashboard_section_model_test.dart`
- Modify: `test/features/dashboard/data/models/dashboard_model_test.dart`
- Modify: `test/features/dashboard/data/repositories/dashboard_repository_test.dart`
- Modify: `test/features/dashboard/viewmodels/dashboard_viewmodel_test.dart`
- Modify: `test/features/dashboard/widgets/dashboard_section_test.dart`
- Modify: `test/features/dashboard/pages/dashboard_page_test.dart`
- Delete: `lib/features/dashboard/widgets/series_horizontal_list.dart`
- Delete: `test/features/dashboard/widgets/series_horizontal_list_test.dart`

- [ ] **Step 1: Update the dashboard tests to expect generic summaries and a
  media toggle**

In `test/features/dashboard/data/models/dashboard_section_model_test.dart`, use
`mediaType` in the items:

```dart
final completeJson = {
  'items': [
    {'tmdbId': 1, 'title': 'Series A', 'mediaType': 'series'},
    {'tmdbId': 2, 'title': 'Movie B', 'mediaType': 'movie'},
  ],
  'total': 10,
  'hasMore': true,
};
```

In `test/features/dashboard/data/repositories/dashboard_repository_test.dart`,
capture the new query parameter:

```dart
test('getDashboard() sends mediaType to the API', () async {
  Map<String, dynamic>? capturedParams;
  final dio = Dio()
    ..httpClientAdapter = MockAdapter(
      onFetch: (options) {
        capturedParams = options.queryParameters;
        return _jsonBody(_dashboardJson());
      },
    );
  final repo = DashboardRepositoryImpl(dio);

  await repo.getDashboard(mediaType: MediaType.movie);

  expect(capturedParams!['mediaType'], 'movie');
});
```

In `test/features/dashboard/pages/dashboard_page_test.dart`, add a selector
assertion:

```dart
testWidgets('switching to Movies shows movie empty state copy', (tester) async {
  final fakeVM = FakeDashboardVM(testState: AsyncValue.data(_emptyDashboard()));
  final container = createContainer(fakeVM);
  addTearDown(container.dispose);

  await tester.pumpWidget(_wrap(container));
  await tester.pump();

  await tester.tap(find.text('Movies'));
  await tester.pumpAndSettle();

  expect(find.textContaining('No movies tracked'), findsOneWidget);
});
```

- [ ] **Step 2: Run the dashboard tests and confirm they fail**

Run:

```bash
flutter test test/features/dashboard/data/models/dashboard_section_model_test.dart test/features/dashboard/data/models/dashboard_model_test.dart test/features/dashboard/data/repositories/dashboard_repository_test.dart test/features/dashboard/viewmodels/dashboard_viewmodel_test.dart test/features/dashboard/widgets/dashboard_section_test.dart test/features/dashboard/pages/dashboard_page_test.dart -v
```

Expected: FAIL because the models, repository, and page still assume
`SeriesModel` and a single dashboard cache key.

- [ ] **Step 3: Switch the dashboard models and repository to tracked
  summaries**

Update `lib/features/dashboard/data/models/dashboard_section_model.dart`:

```dart
import '../../../tracking/data/models/tracked_media_summary_model.dart';

@freezed
class DashboardSectionModel with _$DashboardSectionModel {
  const factory DashboardSectionModel({
    @Default([]) List<TrackedMediaSummaryModel> items,
    @Default(0) int total,
    @Default(false) bool hasMore,
  }) = _DashboardSectionModel;
}
```

Update `lib/features/dashboard/data/repositories/dashboard_repository.dart`:

```dart
abstract class DashboardRepository {
  Future<DashboardModel> getDashboard({
    MediaType mediaType = MediaType.series,
  });
}

final response = await _dio.get(
  '/dashboard',
  queryParameters: {'mediaType': mediaType.apiValue},
);
```

Normalize old numeric fallbacks without guessing the type:

```dart
if (item['tmdbId'] == null && item['mediaId'] != null) {
  item['tmdbId'] = int.tryParse(item['mediaId'].toString()) ?? 0;
}
```

- [ ] **Step 4: Key the Dashboard ViewModel and page state by media type**

Update `lib/features/dashboard/viewmodels/dashboard_viewmodel.dart`:

```dart
class DashboardViewModel extends _$DashboardViewModel {
  MediaType _currentMediaType = MediaType.series;

  @override
  AsyncValue<DashboardModel> build() {
    final cacheService = ref.read(cacheServiceProvider);
    final cacheKey = _cacheKey;
    var hit = cacheService.getSync(cacheKey);
    hit ??= cacheService.getFromDiskSync(cacheKey);

    if (hit != null) {
      final data = DashboardModel.fromJson(
        jsonDecode(hit.json) as Map<String, dynamic>,
      );
      if (!hit.isFresh) {
        _backgroundRefresh();
      }
      return AsyncValue.data(data);
    }

    _loadFromNetwork();
    return const AsyncValue.loading();
  }

  String get _cacheKey => 'dashboard:${_currentMediaType.apiValue}';

  Future<void> loadDashboard({
    MediaType mediaType = MediaType.series,
  }) async {
    _currentMediaType = mediaType;
    state = const AsyncValue.loading();
    await _loadFromNetwork();
  }
}
```

Create `lib/features/dashboard/widgets/tracked_media_horizontal_list.dart`:

```dart
import 'package:flutter/material.dart';
import '../../tracking/data/models/tracked_media_summary_model.dart';
import '../../tracking/widgets/tracked_media_poster.dart';

class TrackedMediaHorizontalList extends StatelessWidget {
  final List<TrackedMediaSummaryModel> items;
  final ValueChanged<TrackedMediaSummaryModel>? onTap;

  const TrackedMediaHorizontalList({
    super.key,
    required this.items,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TrackedMediaPoster(
              media: item,
              onTap: onTap != null ? () => onTap!(item) : null,
            ),
          );
        },
      ),
    );
  }
}
```

Update `lib/features/dashboard/widgets/watching_section.dart` to use the new
list type:

```dart
final List<TrackedMediaSummaryModel> items;
final ValueChanged<TrackedMediaSummaryModel>? onTap;
TrackedMediaHorizontalList(items: items, onTap: onTap),
```

Update `lib/features/dashboard/pages/dashboard_page.dart` to hold the selected
type in local state, render `MediaTypeToggle`, and choose the route by
`item.mediaType`:

```dart
class _DashboardPageState extends ConsumerState<DashboardPage> {
  MediaType _selectedType = MediaType.series;

  void _onMediaTypeChanged(MediaType type) {
    setState(() => _selectedType = type);
    ref.read(dashboardViewModelProvider.notifier).loadDashboard(
          mediaType: type,
        );
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardViewModelProvider);
    final emptyMessage = _selectedType == MediaType.series
        ? context.t.dashboard_empty
        : context.t.dashboard_empty_movies;

    return RefreshIndicator(
      onRefresh: () => ref.read(dashboardViewModelProvider.notifier).refresh(),
      child: dashboardState.when(
        loading: () => LoadingWidget(message: context.t.dashboard_loading),
        error: (error, _) => AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.read(dashboardViewModelProvider.notifier).refresh(),
        ),
        data: (dashboard) => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: MediaTypeToggle(
                  selectedType: _selectedType,
                  onChanged: _onMediaTypeChanged,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: StatsCard(
                        title: context.t.dashboard_watching,
                        count: dashboard.stats.watchingCount,
                        icon: Icons.play_circle_outline,
                        color: AppColors.watching,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatsCard(
                        title: context.t.dashboard_want_to_watch,
                        count: dashboard.stats.wantToWatchCount,
                        icon: Icons.bookmark_border,
                        color: AppColors.wantToWatch,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (dashboard.watching.items.isNotEmpty)
              SliverToBoxAdapter(
                child: DashboardSection(
                  title: context.t.dashboard_watching,
                  items: dashboard.watching.items,
                  onTap: (item) => context.push(
                    item.mediaType == MediaType.series
                        ? '/series/${item.tmdbId}'
                        : '/movies/${item.tmdbId}',
                  ),
                ),
              ),
            if (dashboard.wantToWatch.items.isNotEmpty)
              SliverToBoxAdapter(
                child: DashboardSection(
                  title: context.t.dashboard_want_to_watch,
                  items: dashboard.wantToWatch.items,
                  onTap: (item) => context.push(
                    item.mediaType == MediaType.series
                        ? '/series/${item.tmdbId}'
                        : '/movies/${item.tmdbId}',
                  ),
                ),
              ),
            if (dashboard.completed.items.isNotEmpty)
              SliverToBoxAdapter(
                child: DashboardSection(
                  title: context.t.dashboard_completed,
                  items: dashboard.completed.items,
                  onTap: (item) => context.push(
                    item.mediaType == MediaType.series
                        ? '/series/${item.tmdbId}'
                        : '/movies/${item.tmdbId}',
                  ),
                ),
              ),
            if (dashboard.dropped.items.isNotEmpty)
              SliverToBoxAdapter(
                child: DashboardSection(
                  title: context.t.dashboard_dropped,
                  items: dashboard.dropped.items,
                  onTap: (item) => context.push(
                    item.mediaType == MediaType.series
                        ? '/series/${item.tmdbId}'
                        : '/movies/${item.tmdbId}',
                  ),
                ),
              ),
            if (dashboard.watching.items.isEmpty &&
                dashboard.wantToWatch.items.isEmpty &&
                dashboard.completed.items.isEmpty &&
                dashboard.dropped.items.isEmpty)
              SliverFillRemaining(
                child: EmptyStateWidget(
                  message: emptyMessage,
                  icon: _selectedType == MediaType.series
                      ? Icons.tv_off
                      : Icons.local_movies_outlined,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

final path = item.mediaType == MediaType.series
    ? '/series/${item.tmdbId}'
    : '/movies/${item.tmdbId}';
context.push(path);
```

- [ ] **Step 5: Remove the old series-only list helper and rerun codegen/tests**

Run:

```bash
rm lib/features/dashboard/widgets/series_horizontal_list.dart
rm test/features/dashboard/widgets/series_horizontal_list_test.dart
dart run build_runner build --delete-conflicting-outputs
flutter test test/features/dashboard/data/models/dashboard_section_model_test.dart test/features/dashboard/data/models/dashboard_model_test.dart test/features/dashboard/data/repositories/dashboard_repository_test.dart test/features/dashboard/viewmodels/dashboard_viewmodel_test.dart test/features/dashboard/widgets/dashboard_section_test.dart test/features/dashboard/pages/dashboard_page_test.dart -v
```

Expected: PASS.

- [ ] **Step 6: Commit the segmented dashboard**

```bash
git add -A lib/features/dashboard/widgets test/features/dashboard/widgets
git add lib/features/dashboard/data/models/dashboard_section_model.dart lib/features/dashboard/data/models/dashboard_model.dart lib/features/dashboard/data/repositories/dashboard_repository.dart lib/features/dashboard/viewmodels/dashboard_viewmodel.dart lib/features/dashboard/pages/dashboard_page.dart test/features/dashboard/data/models/dashboard_section_model_test.dart test/features/dashboard/data/models/dashboard_model_test.dart test/features/dashboard/data/repositories/dashboard_repository_test.dart test/features/dashboard/viewmodels/dashboard_viewmodel_test.dart test/features/dashboard/pages/dashboard_page_test.dart lib/features/dashboard/data/models/dashboard_section_model.freezed.dart lib/features/dashboard/data/models/dashboard_section_model.g.dart lib/features/dashboard/data/models/dashboard_model.freezed.dart lib/features/dashboard/data/models/dashboard_model.g.dart lib/features/dashboard/viewmodels/dashboard_viewmodel.g.dart
git commit -m "feat: segment dashboard by media type"
```

### Task 8: Run full verification and close the branch cleanly

**Files:**
- Verify: `lib/router.dart`
- Verify: `lib/features/tracking/data/repositories/tracking_repository.dart`
- Verify: `lib/features/tracking/pages/tracking_list_page.dart`
- Verify: `lib/features/series/pages/series_search_page.dart`
- Verify: `lib/features/series/pages/series_detail_page.dart`
- Verify: `lib/features/movies/pages/movie_detail_page.dart`
- Verify: `lib/features/dashboard/data/repositories/dashboard_repository.dart`
- Verify: `lib/features/dashboard/pages/dashboard_page.dart`

- [ ] **Step 1: Regenerate all code one last time**

Run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: PASS with no stale generated output.

- [ ] **Step 2: Run static analysis**

Run:

```bash
make analyze
```

Expected: PASS.

- [ ] **Step 3: Run the full Flutter test suite**

Run:

```bash
flutter test
```

Expected: PASS.

- [ ] **Step 4: Run the repository quality gate**

Run:

```bash
make check
```

Expected: PASS, including coverage gate.

- [ ] **Step 5: Commit the final integrated feature state**

```bash
git add lib test docs/superpowers/specs/2026-05-13-movie-tracking-design.md docs/superpowers/plans/2026-05-13-movie-tracking.md
git commit -m "feat: add segmented movie tracking support"
```
