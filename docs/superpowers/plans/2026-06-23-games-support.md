# Games Support Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add games as a third media type in the Lorebase Flutter app, integrating with the backend's `/games` endpoints, game tracking fields (`selectedPlatform`, `hoursPlayed`), dashboard, and social feed.

**Architecture:** Follow the existing isolated-feature pattern by creating `lib/features/games/` alongside `series/` and `movies/`. Expand `MediaType` to include `game`, add a separate `GameTrackingStatus` enum, and introduce a configurable `GamePlatform` enum. Reuse shared widgets (`TrackingEditorSheet`, `TrackingStatusChip`, `MediaTypeToggle`) with game-specific branches.

**Tech Stack:** Flutter 3.27, Dart >=3.3.0, Riverpod + codegen, GoRouter, Dio, Freezed, Mockito, flutter_test.

## Global Constraints

- Never edit `*.g.dart` or `*.freezed.dart`.
- Use single quotes, const constructors, final locals.
- Maintain 100% line + branch coverage for new code (`make test-coverage`).
- Pages and coverage-excluded files must include `// coverage:ignore-file`.
- Models use `@freezed` with `part '...freezed.dart'` and `part '...g.dart'`.
- ViewModels use `@riverpod class Foo extends _$Foo` with `part '...g.dart'`.
- Navigation uses `context.go()` (not `push()`).
- Add i18n strings to `pt_BR.i18n.json`, `en.i18n.json`, and `es.i18n.json`, then run codegen.

---

## File Structure

**New files:**

- `lib/features/tracking/data/models/game_tracking_status.dart`
- `lib/features/tracking/data/models/game_platform.dart`
- `lib/features/games/data/models/game_model.dart`
- `lib/features/games/data/repositories/game_repository.dart`
- `lib/features/games/viewmodels/game_search_viewmodel.dart`
- `lib/features/games/viewmodels/game_detail_state.dart`
- `lib/features/games/viewmodels/game_detail_viewmodel.dart`
- `lib/features/games/widgets/game_card.dart`
- `lib/features/games/widgets/game_platform_selector.dart`
- `lib/features/games/widgets/game_hours_field.dart`
- `lib/features/games/pages/game_detail_page.dart`

**Modified files:**

- `lib/features/tracking/data/models/media_type.dart`
- `lib/features/tracking/data/models/tracked_media_model.dart`
- `lib/features/tracking/data/repositories/tracking_repository.dart`
- `lib/features/tracking/widgets/tracking_editor_sheet.dart`
- `lib/features/tracking/widgets/tracking_status_chip.dart`
- `lib/features/tracking/pages/tracking_list_page.dart`
- `lib/features/series/pages/series_search_page.dart`
- `lib/features/dashboard/pages/dashboard_page.dart`
- `lib/features/social/widgets/social_activity_verb.dart`
- `lib/router.dart`
- `lib/l10n/*.i18n.json` (all three locales)

**New tests:**

- `test/features/tracking/data/models/game_tracking_status_test.dart`
- `test/features/tracking/data/models/game_platform_test.dart`
- `test/features/games/data/models/game_model_test.dart`
- `test/features/games/data/repositories/game_repository_test.dart`
- `test/features/games/viewmodels/game_search_viewmodel_test.dart`
- `test/features/games/viewmodels/game_detail_viewmodel_test.dart`
- `test/features/games/widgets/game_card_test.dart`
- `test/features/games/widgets/game_platform_selector_test.dart`
- `test/features/games/widgets/game_hours_field_test.dart`
- `test/visual/pages/game_detail_page_golden_test.dart`
- `test/visual/pages/game_search_page_golden_test.dart`

**Modified tests:**

- `test/features/tracking/data/repositories/tracking_repository_test.dart`
- `test/features/tracking/widgets/tracking_editor_sheet_test.dart`
- `test/features/tracking/widgets/tracking_status_chip_test.dart`
- `test/features/series/pages/series_search_page_test.dart`
- `test/features/dashboard/pages/dashboard_page_test.dart`
- `test/router_test.dart`

---

## Execution Order

Tasks are numbered for reference, but execute them in the following order to avoid compilation gaps:

1. Task 1: Domain enums
2. Task 2: GameModel
3. Task 3: GameRepository
4. Task 4: GameSearchViewModel + search page integration
5. Task 6: Game widgets (GameCard, GamePlatformSelector, GameHoursField)
6. Task 8: Extend TrackingRepository for game fields
7. Task 9: Extend TrackingEditorSheet for games
8. Task 10: Extend TrackingStatusChip for games
9. Task 5: GameDetailState and GameDetailViewModel
10. Task 7: GameDetailPage
11. Task 11: Adapt TrackingListPage for games
12. Task 12: Adapt DashboardPage for games
13. Task 13: Social feed verb for STARTED_PLAYING
14. Task 14: Router
15. Task 15: Game search golden test
16. Task 16: Final verification

**Rationale:** Tasks 8, 9, and 10 must be completed before Tasks 5 and 7 because the game detail viewmodel and page depend on the extended tracking repository and editor sheet signatures.

---

## Task 1: Domain enums (MediaType, GameTrackingStatus, GamePlatform)

**Files:**

- Modify: `lib/features/tracking/data/models/media_type.dart`
- Create: `lib/features/tracking/data/models/game_tracking_status.dart`
- Create: `lib/features/tracking/data/models/game_platform.dart`
- Test: `test/features/tracking/data/models/game_tracking_status_test.dart`
- Test: `test/features/tracking/data/models/game_platform_test.dart`
- Test: `test/features/tracking/data/models/media_type_test.dart` (extend existing)

**Interfaces:**

- Consumes: `Translations` from `l10n/strings.g.dart`.
- Produces: `MediaType.game`, `GameTrackingStatus.values`, `GamePlatform.values` with `apiValue` and `label(Translations)`.

- [ ] **Step 1: Write failing tests for MediaType.game**

In `test/features/tracking/data/models/media_type_test.dart`, add:

```dart
test('MediaType includes game', () {
  expect(MediaType.game.apiValue, 'GAME');
});

test('mediaTypeFromJson parses GAME', () {
  expect(mediaTypeFromJson('GAME'), MediaType.game);
});
```

- [ ] **Step 2: Run tests and confirm failure**

Run: `flutter test test/features/tracking/data/models/media_type_test.dart`
Expected: FAIL — `game` not found.

- [ ] **Step 3: Add MediaType.game**

Modify `lib/features/tracking/data/models/media_type.dart`:

```dart
enum MediaType {
  series('SERIES'),
  movie('MOVIE'),
  game('GAME');

  const MediaType(this.apiValue);

  final String apiValue;

  String label(Translations t) {
    switch (this) {
      case MediaType.series:
        return t.media_type_series;
      case MediaType.movie:
        return t.media_type_movies;
      case MediaType.game:
        return t.media_type_games;
    }
  }
}
```

- [ ] **Step 4: Create GameTrackingStatus**

Create `lib/features/tracking/data/models/game_tracking_status.dart`:

```dart
import '../../../l10n/strings.g.dart';

enum GameTrackingStatus {
  wantToPlay('WANT_TO_PLAY'),
  playing('PLAYING'),
  completed('COMPLETED'),
  dropped('DROPPED');

  final String value;

  const GameTrackingStatus(this.value);

  String label(Translations t) {
    return switch (this) {
      GameTrackingStatus.wantToPlay => t.tracking_want_to_play_game,
      GameTrackingStatus.playing => t.tracking_playing_game,
      GameTrackingStatus.completed => t.tracking_completed_game,
      GameTrackingStatus.dropped => t.tracking_dropped_game,
    };
  }

  static GameTrackingStatus fromString(String value) {
    return GameTrackingStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => GameTrackingStatus.wantToPlay,
    );
  }
}
```

- [ ] **Step 5: Create GamePlatform**

Create `lib/features/tracking/data/models/game_platform.dart`:

```dart
import '../../../l10n/strings.g.dart';

enum GamePlatform {
  pc('PC'),
  nintendoSwitch('Switch'),
  switch2('Switch 2'),
  ps1('PS1'),
  ps2('PS2'),
  ps3('PS3'),
  ps4('PS4'),
  ps5('PS5'),
  xbox('Xbox'),
  xbox360('Xbox 360'),
  xboxOne('Xbox One'),
  snes('SNES'),
  nes('NES'),
  megaDrive('Mega Drive'),
  gba('GBA'),
  xboxSeriesXS('Xbox Series X/S'),
  mobile('Mobile'),
  vr('VR'),
  other('Other');

  final String apiValue;

  const GamePlatform(this.apiValue);

  String label(Translations t) {
    return switch (this) {
      GamePlatform.pc => t.game_platform_pc,
      GamePlatform.nintendoSwitch => t.game_platform_switch,
      GamePlatform.switch2 => t.game_platform_switch2,
      GamePlatform.ps1 => t.game_platform_ps1,
      GamePlatform.ps2 => t.game_platform_ps2,
      GamePlatform.ps3 => t.game_platform_ps3,
      GamePlatform.ps4 => t.game_platform_ps4,
      GamePlatform.ps5 => t.game_platform_ps5,
      GamePlatform.xbox => t.game_platform_xbox,
      GamePlatform.xbox360 => t.game_platform_xbox_360,
      GamePlatform.xboxOne => t.game_platform_xbox_one,
      GamePlatform.snes => t.game_platform_snes,
      GamePlatform.nes => t.game_platform_nes,
      GamePlatform.megaDrive => t.game_platform_mega_drive,
      GamePlatform.gba => t.game_platform_gba,
      GamePlatform.xboxSeriesXS => t.game_platform_xbox_series_xs,
      GamePlatform.mobile => t.game_platform_mobile,
      GamePlatform.vr => t.game_platform_vr,
      GamePlatform.other => t.game_platform_other,
    };
  }

  static GamePlatform fromApiValue(String value) {
    return GamePlatform.values.firstWhere(
      (p) => p.apiValue == value,
      orElse: () => GamePlatform.other,
    );
  }
}
```

- [ ] **Step 6: Add i18n strings for labels**

Add to `lib/l10n/pt_BR.i18n.json`, `lib/l10n/en.i18n.json`, and `lib/l10n/es.i18n.json`:

```json
"media_type_games": "Jogos",
"tracking_want_to_play_game": "Quero Jogar",
"tracking_playing_game": "Jogando",
"tracking_completed_game": "Concluído",
"tracking_dropped_game": "Abandonado",
"game_platform_pc": "PC",
"game_platform_switch": "Switch",
"game_platform_switch2": "Switch 2",
"game_platform_ps1": "PS1",
"game_platform_ps2": "PS2",
"game_platform_ps3": "PS3",
"game_platform_ps4": "PS4",
"game_platform_ps5": "PS5",
"game_platform_xbox": "Xbox",
"game_platform_xbox_360": "Xbox 360",
"game_platform_xbox_one": "Xbox One",
"game_platform_snes": "SNES",
"game_platform_nes": "NES",
"game_platform_mega_drive": "Mega Drive",
"game_platform_gba": "GBA",
"game_platform_xbox_series_xs": "Xbox Series X/S",
"game_platform_mobile": "Mobile",
"game_platform_vr": "VR",
"game_platform_other": "Outro"
```

- [ ] **Step 7: Run codegen**

Run: `dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 8: Write tests for GameTrackingStatus and GamePlatform**

Create `test/features/tracking/data/models/game_tracking_status_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/tracking/data/models/game_tracking_status.dart';
import 'package:lorebase/l10n/strings.g.dart';

void main() {
  group('GameTrackingStatus', () {
    test('values map to backend strings', () {
      expect(GameTrackingStatus.wantToPlay.value, 'WANT_TO_PLAY');
      expect(GameTrackingStatus.playing.value, 'PLAYING');
      expect(GameTrackingStatus.completed.value, 'COMPLETED');
      expect(GameTrackingStatus.dropped.value, 'DROPPED');
    });

    test('fromString returns matching value', () {
      expect(GameTrackingStatus.fromString('PLAYING'), GameTrackingStatus.playing);
    });

    test('fromString defaults to wantToPlay for unknown', () {
      expect(GameTrackingStatus.fromString('INVALID'), GameTrackingStatus.wantToPlay);
    });
  });
}
```

Create `test/features/tracking/data/models/game_platform_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/tracking/data/models/game_platform.dart';

void main() {
  group('GamePlatform', () {
    test('fromApiValue returns matching platform', () {
      expect(GamePlatform.fromApiValue('PS5'), GamePlatform.ps5);
    });

    test('fromApiValue returns other for unknown', () {
      expect(GamePlatform.fromApiValue('Unknown'), GamePlatform.other);
    });
  });
}
```

- [ ] **Step 9: Run tests**

Run: `flutter test test/features/tracking/data/models/`
Expected: PASS.

- [ ] **Step 10: Commit**

```bash
git add lib/l10n/ lib/features/tracking/data/models/ test/features/tracking/data/models/
git commit -m "feat: add MediaType.game, GameTrackingStatus and GamePlatform"
```

---

## Task 2: GameModel

**Files:**

- Create: `lib/features/games/data/models/game_model.dart`
- Test: `test/features/games/data/models/game_model_test.dart`

**Interfaces:**

- Consumes: nothing.
- Produces: `GameModel` Freezed class with JSON serialization.

- [ ] **Step 1: Write failing test**

Create `test/features/games/data/models/game_model_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/games/data/models/game_model.dart';

void main() {
  group('GameModel', () {
    test('fromJson parses backend response', () {
      final json = {
        'gameId': '1234',
        'title': 'Hades',
        'summary': 'Roguelike',
        'genre': 'Action',
        'coverUrl': 'https://example.com/cover.jpg',
        'releaseDate': '2020-09-17',
        'platforms': ['PC', 'Switch', 'PS5'],
        'developer': 'Supergiant Games',
        'publisher': 'Supergiant Games',
        'franchise': 'Hades',
        'gameModes': ['Single player'],
      };

      final model = GameModel.fromJson(json);
      expect(model.gameId, '1234');
      expect(model.title, 'Hades');
      expect(model.platforms, ['PC', 'Switch', 'PS5']);
    });
  });
}
```

- [ ] **Step 2: Run test to confirm failure**

Run: `flutter test test/features/games/data/models/game_model_test.dart`
Expected: FAIL — `GameModel` not found.

- [ ] **Step 3: Implement GameModel**

Create `lib/features/games/data/models/game_model.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_model.freezed.dart';
part 'game_model.g.dart';

@freezed
abstract class GameModel with _$GameModel {
  const factory GameModel({
    required String gameId,
    required String title,
    String? summary,
    String? genre,
    String? coverUrl,
    String? backdropUrl,
    String? releaseDate,
    @Default([]) List<String> platforms,
    String? developer,
    String? publisher,
    String? franchise,
    @Default([]) List<String> gameModes,
  }) = _GameModel;

  factory GameModel.fromJson(Map<String, dynamic> json) =>
      _$GameModelFromJson(json);
}
```

- [ ] **Step 4: Run codegen**

Run: `dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 5: Run tests**

Run: `flutter test test/features/games/data/models/game_model_test.dart`
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/features/games/data/models/ test/features/games/data/models/
git commit -m "feat: add GameModel"
```

---

## Task 3: GameRepository

**Files:**

- Create: `lib/features/games/data/repositories/game_repository.dart`
- Test: `test/features/games/data/repositories/game_repository_test.dart`

**Interfaces:**

- Consumes: `Dio`, `GameModel`.
- Produces: `GameRepository` with `searchGames` and `getGameById`.

- [ ] **Step 1: Write failing test**

Create `test/features/games/data/repositories/game_repository_test.dart` using the same `MockAdapter` pattern as `series_repository_test.dart`.

Test cases:

- `searchGames() returns list of GameModel`
- `searchGames() passes query parameters`
- `searchGames() throws ServerException on DioException`
- `getGameById() returns GameModel`
- `getGameById() throws ServerException on DioException`
- `gameRepositoryProvider creates GameRepositoryImpl`

- [ ] **Step 2: Run test to confirm failure**

Run: `flutter test test/features/games/data/repositories/game_repository_test.dart`
Expected: FAIL — `GameRepository` not found.

- [ ] **Step 3: Implement GameRepository**

Create `lib/features/games/data/repositories/game_repository.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/providers/core_providers.dart';
import '../models/game_model.dart';

abstract class GameRepository {
  Future<List<GameModel>> searchGames(
    String query, {
    int page = 1,
    int limit = 20,
    CancelToken? cancelToken,
  });
  Future<GameModel> getGameById(String id);
}

class GameRepositoryImpl implements GameRepository {
  final Dio _dio;

  GameRepositoryImpl(this._dio);

  @override
  Future<List<GameModel>> searchGames(
    String query, {
    int page = 1,
    int limit = 20,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        '/games',
        queryParameters: {
          'q': query,
          'page': page,
          'limit': limit,
        },
        cancelToken: cancelToken,
      );
      final items = response.data['items'] as List;
      return items.map((json) => GameModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to search games',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<GameModel> getGameById(String id) async {
    try {
      final response = await _dio.get('/games/$id');
      return GameModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to load game',
        statusCode: e.response?.statusCode,
      );
    }
  }
}

final gameRepositoryProvider = Provider<GameRepository>((ref) {
  return GameRepositoryImpl(ref.watch(dioProvider));
});
```

- [ ] **Step 4: Run tests**

Run: `flutter test test/features/games/data/repositories/game_repository_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/games/data/repositories/ test/features/games/data/repositories/
git commit -m "feat: add GameRepository"
```

---

## Task 4: GameSearchViewModel + integration into SeriesSearchPage

**Files:**

- Create: `lib/features/games/viewmodels/game_search_viewmodel.dart`
- Modify: `lib/features/series/pages/series_search_page.dart`
- Test: `test/features/games/viewmodels/game_search_viewmodel_test.dart`
- Test: `test/features/series/pages/series_search_page_test.dart` (extend)

**Interfaces:**

- Consumes: `GameRepository`.
- Produces: `gameSearchViewModelProvider` exposing `AsyncValue<List<GameModel>>`.

- [ ] **Step 1: Write failing test for GameSearchViewModel**

Create `test/features/games/viewmodels/game_search_viewmodel_test.dart` using a fake `GameRepository`.

Test cases:

- `search() returns results`
- `search() cancels previous request`
- `search() handles empty query`
- `clear() cancels and resets`

- [ ] **Step 2: Run test to confirm failure**

Run: `flutter test test/features/games/viewmodels/game_search_viewmodel_test.dart`
Expected: FAIL — `GameSearchViewModel` not found.

- [ ] **Step 3: Implement GameSearchViewModel**

Create `lib/features/games/viewmodels/game_search_viewmodel.dart` mirroring `SeriesSearchViewModel`:

```dart
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/game_model.dart';
import '../data/repositories/game_repository.dart';

part 'game_search_viewmodel.g.dart';

@riverpod
class GameSearchViewModel extends _$GameSearchViewModel {
  CancelToken? _cancelToken;

  @override
  AsyncValue<List<GameModel>> build() {
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

    final previousState = state;
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(gameRepositoryProvider);
      final results = await repository.searchGames(
        query,
        cancelToken: cancelToken,
      );
      state = AsyncValue.data(results);
    } catch (error, stackTrace) {
      if (error is DioException && error.type == DioExceptionType.cancel) {
        state = previousState;
        return;
      }
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

- [ ] **Step 4: Integrate into SeriesSearchPage**

Modify `lib/features/series/pages/series_search_page.dart`:

1. Import `GameSearchViewModel` and `GameCard`.
2. In `_onSearchChanged`, add a branch for `MediaType.game`.
3. In `_onClear`, clear `gameSearchViewModelProvider`.
4. In `_onTypeChanged`, clear `gameSearchViewModelProvider`.
5. In `_SearchResultsBody`, watch `gameSearchViewModelProvider` and render `GameCard` list when `mediaType == MediaType.game`.

- [ ] **Step 5: Update SeriesSearchPage tests**

Add tests covering:

- Switching to "Games" toggle clears other viewmodels.
- Searching while "Games" selected triggers `GameSearchViewModel`.

- [ ] **Step 6: Run tests**

Run: `flutter test test/features/games/viewmodels/game_search_viewmodel_test.dart test/features/series/pages/series_search_page_test.dart`
Expected: PASS.

- [ ] **Step 7: Commit**

```bash
git add lib/features/games/viewmodels/ lib/features/series/pages/series_search_page.dart test/features/games/viewmodels/ test/features/series/pages/series_search_page_test.dart
git commit -m "feat: add GameSearchViewModel and integrate into search page"
```

---

## Task 5: GameDetailState and GameDetailViewModel

**Files:**

- Create: `lib/features/games/viewmodels/game_detail_state.dart`
- Create: `lib/features/games/viewmodels/game_detail_viewmodel.dart`
- Test: `test/features/games/viewmodels/game_detail_viewmodel_test.dart`

**Interfaces:**

- Consumes: `GameRepository`, `TrackingRepository`, `CacheService`.
- Produces: `GameDetailState` and `gameDetailViewModelProvider(String gameId)`.

- [ ] **Step 1: Write failing test**

Create `test/features/games/viewmodels/game_detail_viewmodel_test.dart` using fake repositories.

Test cases:

- `build() loads game and tracking`
- `build() returns null tracking when none`
- `addTracking() calls startTracking with platform`
- `updateTracking() calls updateTracking with hoursPlayed and platform`
- `removeTracking() calls deleteTracking`

- [ ] **Step 2: Run test to confirm failure**

Run: `flutter test test/features/games/viewmodels/game_detail_viewmodel_test.dart`
Expected: FAIL — `GameDetailViewModel` not found.

- [ ] **Step 3: Implement GameDetailState**

Create `lib/features/games/viewmodels/game_detail_state.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../data/models/game_model.dart';
import '../../tracking/data/models/tracked_media_model.dart';

part 'game_detail_state.freezed.dart';

@freezed
abstract class GameDetailState with _$GameDetailState {
  const factory GameDetailState({
    required GameModel game,
    TrackedMediaModel? tracking,
  }) = _GameDetailState;
}
```

- [ ] **Step 4: Implement GameDetailViewModel**

Create `lib/features/games/viewmodels/game_detail_viewmodel.dart`:

```dart
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/cache/cache_providers.dart';
import '../data/models/game_model.dart';
import '../data/repositories/game_repository.dart';
import '../../tracking/data/models/media_type.dart';
import '../../tracking/data/repositories/tracking_repository.dart';
import 'game_detail_state.dart';

part 'game_detail_viewmodel.g.dart';

@riverpod
class GameDetailViewModel extends _$GameDetailViewModel {
  @override
  Future<GameDetailState> build(String gameId) async {
    final gameFuture = ref.read(gameRepositoryProvider).getGameById(gameId);
    final trackingFuture = ref
        .read(trackingRepositoryProvider)
        .getTrackingByMedia(gameId, MediaType.game)
        .catchError((Object e) {
      debugPrint('[GAME_VM] tracking lookup failed: $e');
      return null;
    });

    final game = await gameFuture;
    final tracking = await trackingFuture;
    return GameDetailState(game: game, tracking: tracking);
  }

  Future<void> addTracking(
    String status, {
    required String selectedPlatform,
    double? hoursPlayed,
    int? rating,
    String? review,
  }) async {
    final currentState = state.value;
    if (currentState == null) return;

    final tracking = await ref.read(trackingRepositoryProvider).startTracking(
      currentState.game.gameId,
      MediaType.game,
      status,
      selectedPlatform: selectedPlatform,
      hoursPlayed: hoursPlayed,
    );

    final hasExtra = rating != null || (review != null && review.isNotEmpty);
    if (hasExtra) {
      await ref.read(trackingRepositoryProvider).updateTracking(
        tracking.mediaId,
        mediaType: MediaType.game,
        rating: rating,
        review: review,
      );
    }

    await _invalidateCaches();
    ref.invalidateSelf();
  }

  Future<void> updateTracking({
    String? status,
    String? selectedPlatform,
    double? hoursPlayed,
    int? rating,
    String? review,
  }) async {
    final current = state.value?.tracking;
    if (current == null) return;

    await ref.read(trackingRepositoryProvider).updateTracking(
      current.mediaId,
      mediaType: MediaType.game,
      status: status,
      selectedPlatform: selectedPlatform,
      hoursPlayed: hoursPlayed,
      rating: rating,
      review: review,
    );

    await _invalidateCaches();
    ref.invalidateSelf();
  }

  Future<void> removeTracking() async {
    final current = state.value?.tracking;
    if (current == null) return;

    await ref
        .read(trackingRepositoryProvider)
        .deleteTracking(current.mediaId, mediaType: MediaType.game);

    await _invalidateCaches();
    ref.invalidateSelf();
  }

  Future<void> _invalidateCaches() async {
    final cacheService = ref.read(cacheServiceProvider);
    await cacheService.remove('dashboard:v2:GAME');
    await cacheService.removeByPrefix('tracking:v2:');
  }
}
```

Note: `startTracking` signature will be updated in Task 8. For now, write the viewmodel assuming the extended signature; if tests break before Task 8, stub the repository method or implement Task 8 first.

- [ ] **Step 5: Run codegen**

Run: `dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 6: Run tests**

Run: `flutter test test/features/games/viewmodels/game_detail_viewmodel_test.dart`
Expected: PASS.

- [ ] **Step 7: Commit**

```bash
git add lib/features/games/viewmodels/ test/features/games/viewmodels/
git commit -m "feat: add GameDetailState and GameDetailViewModel"
```

---

## Task 6: Game widgets (GameCard, GamePlatformSelector, GameHoursField)

**Files:**

- Create: `lib/features/games/widgets/game_card.dart`
- Create: `lib/features/games/widgets/game_platform_selector.dart`
- Create: `lib/features/games/widgets/game_hours_field.dart`
- Test: `test/features/games/widgets/game_card_test.dart`
- Test: `test/features/games/widgets/game_platform_selector_test.dart`
- Test: `test/features/games/widgets/game_hours_field_test.dart`

**Interfaces:**

- Consumes: `GameModel`, `GamePlatform`, `Translations`.
- Produces: Reusable game widgets.

- [ ] **Step 1: Write failing tests**

Create the three test files:

- `game_card_test.dart`: renders title, platforms, tap callback.
- `game_platform_selector_test.dart`: selects fixed platform, selects "Other" and types custom text.
- `game_hours_field_test.dart`: accepts valid double, rejects negative, calls onChanged.

- [ ] **Step 2: Run tests to confirm failure**

Run: `flutter test test/features/games/widgets/`
Expected: FAIL — widgets not found.

- [ ] **Step 3: Implement GameCard**

Create `lib/features/games/widgets/game_card.dart`. Mirror `SeriesCard`/`MovieCard` using `coverUrl` as poster. Include platform chips.

- [ ] **Step 4: Implement GamePlatformSelector**

Create `lib/features/games/widgets/game_platform_selector.dart`:

```dart
class GamePlatformSelector extends StatefulWidget {
  final String? selectedPlatform;
  final ValueChanged<String> onChanged;

  const GamePlatformSelector({
    super.key,
    required this.selectedPlatform,
    required this.onChanged,
  });

  @override
  State<GamePlatformSelector> createState() => _GamePlatformSelectorState();
}
```

Logic:

- Show dropdown / list of `GamePlatform.values`.
- When `GamePlatform.other` selected, show `TextField`.
- `onChanged` always emits the string value (either `platform.apiValue` or custom text).

- [ ] **Step 5: Implement GameHoursField**

Create `lib/features/games/widgets/game_hours_field.dart`:

```dart
class GameHoursField extends StatelessWidget {
  final double? hours;
  final ValueChanged<double?> onChanged;

  const GameHoursField({super.key, required this.hours, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: context.t.game_hours_played_label,
        border: const OutlineInputBorder(),
      ),
      controller: TextEditingController(
        text: hours?.toString() ?? '',
      ),
      onChanged: (value) {
        final parsed = double.tryParse(value);
        onChanged(parsed);
      },
    );
  }
}
```

- [ ] **Step 6: Add i18n strings**

Add to all locale files:

```json
"game_hours_played_label": "Horas jogadas"
```

- [ ] **Step 7: Run codegen and tests**

Run: `dart run build_runner build --delete-conflicting-outputs`
Run: `flutter test test/features/games/widgets/`
Expected: PASS.

- [ ] **Step 8: Commit**

```bash
git add lib/features/games/widgets/ lib/l10n/ test/features/games/widgets/
git commit -m "feat: add GameCard, GamePlatformSelector and GameHoursField"
```

---

## Task 7: GameDetailPage

**Files:**

- Create: `lib/features/games/pages/game_detail_page.dart`
- Test: `test/visual/pages/game_detail_page_golden_test.dart`

**Interfaces:**

- Consumes: `GameDetailViewModel`, `GameDetailState`, `TrackingEditorSheet`.
- Produces: `/games/:gameId` page UI.

- [ ] **Step 1: Create golden test scaffold**

Create `test/visual/pages/game_detail_page_golden_test.dart` mirroring `movie_detail_page_golden_test.dart`. It will fail until the page exists.

- [ ] **Step 2: Implement GameDetailPage**

Create `lib/features/games/pages/game_detail_page.dart`:

1. `ConsumerWidget` receiving `String gameId`.
2. Watch `gameDetailViewModelProvider(gameId)`.
3. Loading/error/data states like `MovieDetailPage`.
4. `_GameDetailLoaded` shows:
   - Backdrop/cover image (`coverUrl`)
   - Title
   - Genre chip
   - Platforms wrap
   - Tracking status chip if tracking exists
   - Overview section
   - Info cards: release date, developer, publisher, game modes
5. Bottom button opens `TrackingEditorSheet` configured for games.

- [ ] **Step 3: Add i18n strings**

Add to all locale files:

```json
"game_detail_developer": "Desenvolvedora",
"game_detail_publisher": "Publicadora",
"game_detail_game_modes": "Modos de jogo",
"game_detail_platforms": "Plataformas",
"game_detail_release_date": "Data de lançamento"
```

- [ ] **Step 4: Run codegen and golden test**

Run: `dart run build_runner build --delete-conflicting-outputs`
Run: `flutter test test/visual/pages/game_detail_page_golden_test.dart`
Expected: PASS (generates goldens if needed).

- [ ] **Step 5: Commit**

```bash
git add lib/features/games/pages/ test/visual/pages/game_detail_page_golden_test.dart lib/l10n/
git commit -m "feat: add GameDetailPage"
```

---

## Task 8: Extend TrackingRepository for game fields

**Files:**

- Modify: `lib/features/tracking/data/models/tracked_media_model.dart`
- Modify: `lib/features/tracking/data/repositories/tracking_repository.dart`
- Test: `test/features/tracking/data/repositories/tracking_repository_test.dart` (extend)

**Interfaces:**

- Consumes: `GamePlatform`, hours as `double`.
- Produces: Repository methods accept `selectedPlatform` and `hoursPlayed`.

- [ ] **Step 1: Add fields to TrackedMediaModel**

Modify `lib/features/tracking/data/models/tracked_media_model.dart`:

```dart
const factory TrackedMediaModel({
  required String trackingId,
  required String userId,
  @JsonKey(fromJson: mediaTypeFromJson, toJson: mediaTypeToJson)
  required MediaType mediaType,
  required String mediaId,
  required String status,
  int? rating,
  String? review,
  String? selectedPlatform,
  double? hoursPlayed,
  @Default([]) List<SeasonRatingModel> seasonRatings,
  TrackedMediaSummaryModel? media,
  required DateTime addedAt,
  required DateTime lastUpdated,
}) = _TrackedMediaModel;
```

- [ ] **Step 2: Update TrackingRepository signatures and payloads**

Modify `lib/features/tracking/data/repositories/tracking_repository.dart`:

```dart
Future<TrackedMediaModel> startTracking(
  String mediaId,
  MediaType mediaType,
  String status, {
  String? selectedPlatform,
  double? hoursPlayed,
});

Future<TrackedMediaModel> updateTracking(
  String mediaId, {
  required MediaType mediaType,
  String? status,
  int? rating,
  String? review,
  String? selectedPlatform,
  double? hoursPlayed,
  List<Map<String, dynamic>>? seasonRatings,
});
```

Update `TrackingRepositoryImpl.startTracking` data payload:

```dart
final data = <String, dynamic>{
  'mediaId': mediaId,
  'mediaType': mediaType.apiValue,
  'status': status,
  'selectedPlatform': selectedPlatform,
  'hoursPlayed': hoursPlayed,
};
```

Update `TrackingRepositoryImpl.updateTracking` data payload:

```dart
final data = <String, dynamic>{
  'mediaType': mediaType.apiValue,
  'status': status,
  'seriesRating': rating,
  'seriesReview': review,
  'selectedPlatform': selectedPlatform,
  'hoursPlayed': hoursPlayed,
  'seasonRatings': seasonRatings,
};
```

- [ ] **Step 3: Update tests**

Extend `test/features/tracking/data/repositories/tracking_repository_test.dart` with tests for:

- `startTracking() sends selectedPlatform and hoursPlayed`
- `updateTracking() sends selectedPlatform and hoursPlayed`

- [ ] **Step 4: Run codegen and tests**

Run: `dart run build_runner build --delete-conflicting-outputs`
Run: `flutter test test/features/tracking/data/repositories/tracking_repository_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/tracking/data/ test/features/tracking/data/repositories/
git commit -m "feat: extend TrackingRepository with selectedPlatform and hoursPlayed"
```

---

## Task 9: Extend TrackingEditorSheet for games

**Files:**

- Modify: `lib/features/tracking/widgets/tracking_editor_sheet.dart`
- Modify: `test/features/tracking/widgets/tracking_editor_sheet_test.dart`

**Interfaces:**

- Consumes: `GamePlatformSelector`, `GameHoursField`, `GameTrackingStatus`.
- Produces: `TrackingEditorSheet` can render game-specific controls.

- [ ] **Step 1: Write failing test**

Add to `test/features/tracking/widgets/tracking_editor_sheet_test.dart`:

```dart
testWidgets('saves platform and hours for games', (tester) async {
  String? savedStatus;
  String? savedPlatform;
  double? savedHours;

  await tester.pumpWidget(
    TranslationProvider(
      child: MaterialApp(
        home: Scaffold(
          body: TrackingEditorSheet(
            title: 'Add Game',
            initialStatus: 'WANT_TO_PLAY',
            initialRating: null,
            initialReview: '',
            initialSelectedPlatform: null,
            initialHoursPlayed: null,
            isGame: true,
            onSave: ({
              required status,
              rating,
              review,
              selectedPlatform,
              hoursPlayed,
            }) async {
              savedStatus = status;
              savedPlatform = selectedPlatform;
              savedHours = hoursPlayed;
            },
          ),
        ),
      ),
    ),
  );

  // Select PS5 and enter hours
  await tester.tap(find.text('PS5'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField).last, '12.5');
  await tester.tap(find.text('Save Changes'));
  await tester.pumpAndSettle();

  expect(savedStatus, 'WANT_TO_PLAY');
  expect(savedPlatform, 'PS5');
  expect(savedHours, 12.5);
});
```

- [ ] **Step 2: Run test to confirm failure**

Run: `flutter test test/features/tracking/widgets/tracking_editor_sheet_test.dart`
Expected: FAIL — new parameters not found.

- [ ] **Step 3: Extend TrackingEditorSheet**

Modify `lib/features/tracking/widgets/tracking_editor_sheet.dart`:

```dart
class TrackingEditorSheet extends StatefulWidget {
  final String title;
  final String initialStatus;
  final int? initialRating;
  final String initialReview;
  final String? initialSelectedPlatform;
  final double? initialHoursPlayed;
  final bool isGame;
  final Future<void> Function({
    required String status,
    int? rating,
    String? review,
    String? selectedPlatform,
    double? hoursPlayed,
  }) onSave;
  // ... rest
}
```

In `_TrackingEditorSheetState`:

- Add `_selectedPlatform` and `_hoursPlayed` state.
- When `widget.isGame`, render `GamePlatformSelector` and `GameHoursField` between status list and rating.
- Pass `selectedPlatform` and `hoursPlayed` to `widget.onSave`.

For non-game usage, default `isGame` to `false` and ensure existing callbacks work without changes.

- [ ] **Step 4: Run tests**

Run: `flutter test test/features/tracking/widgets/tracking_editor_sheet_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/tracking/widgets/tracking_editor_sheet.dart test/features/tracking/widgets/tracking_editor_sheet_test.dart
git commit -m "feat: extend TrackingEditorSheet with platform and hours for games"
```

---

## Task 10: Extend TrackingStatusChip for games

**Files:**

- Modify: `lib/features/tracking/widgets/tracking_status_chip.dart`
- Modify: `test/features/tracking/widgets/tracking_status_chip_test.dart`

**Interfaces:**

- Consumes: `status` string, optional `MediaType`.
- Produces: Correct label/color for game statuses.

- [ ] **Step 1: Write failing test**

Add to `test/features/tracking/widgets/tracking_status_chip_test.dart`:

```dart
testWidgets('renders game status label', (tester) async {
  await tester.pumpWidget(
    TranslationProvider(
      child: const MaterialApp(
        home: TrackingStatusChip(
          status: 'PLAYING',
          mediaType: MediaType.game,
        ),
      ),
    ),
  );
  expect(find.text('Jogando'), findsOneWidget);
});
```

- [ ] **Step 2: Run test to confirm failure**

Run: `flutter test test/features/tracking/widgets/tracking_status_chip_test.dart`
Expected: FAIL — `mediaType` parameter not found.

- [ ] **Step 3: Extend TrackingStatusChip**

Modify `lib/features/tracking/widgets/tracking_status_chip.dart`:

```dart
class TrackingStatusChip extends StatelessWidget {
  final String status;
  final MediaType? mediaType;

  const TrackingStatusChip({
    super.key,
    required this.status,
    this.mediaType,
  });

  // ...
}
```

In `build()`:

- If `mediaType == MediaType.game`, use `GameTrackingStatus.fromString(status)` for label and color mapping.
- Otherwise, use existing `TrackingStatus` logic.

- [ ] **Step 4: Run tests**

Run: `flutter test test/features/tracking/widgets/tracking_status_chip_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/tracking/widgets/tracking_status_chip.dart test/features/tracking/widgets/tracking_status_chip_test.dart
git commit -m "feat: extend TrackingStatusChip for game statuses"
```

---

## Task 11: Adapt TrackingListPage for games

**Files:**

- Modify: `lib/features/tracking/pages/tracking_list_page.dart`
- Modify: `test/features/tracking/pages/tracking_list_page_test.dart`

**Interfaces:**

- Consumes: `MediaType.game`, `GameTrackingStatus` labels.
- Produces: Game items render and navigate correctly.

- [ ] **Step 1: Update page logic**

Modify `lib/features/tracking/pages/tracking_list_page.dart`:

1. In grid item builder, add branch for `tracking.mediaType == MediaType.game` navigating to `/games/$id`.
2. Empty state: use `t.tracking_empty_games` for games.
3. Pass `mediaType` to `TrackingStatusChip`.

- [ ] **Step 2: Add i18n strings**

Add to all locale files:

```json
"tracking_empty_games": "Nenhum jogo {status} ainda"
```

- [ ] **Step 3: Update tests**

Add test in `test/features/tracking/pages/tracking_list_page_test.dart`:

- Game tracking item navigates to `/games/:id`.
- Empty state uses game-specific message.

- [ ] **Step 4: Run codegen and tests**

Run: `dart run build_runner build --delete-conflicting-outputs`
Run: `flutter test test/features/tracking/pages/tracking_list_page_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/tracking/pages/tracking_list_page.dart test/features/tracking/pages/tracking_list_page_test.dart lib/l10n/
git commit -m "feat: adapt TrackingListPage for games"
```

---

## Task 12: Adapt DashboardPage for games

**Files:**

- Modify: `lib/features/dashboard/pages/dashboard_page.dart`
- Modify: `test/features/dashboard/pages/dashboard_page_test.dart`

**Interfaces:**

- Consumes: `MediaType.game`.
- Produces: Game dashboard sections navigate correctly.

- [ ] **Step 1: Update page logic**

Modify `lib/features/dashboard/pages/dashboard_page.dart`:

1. In all `DashboardSection.onTap` callbacks, add branch for `item.mediaType == MediaType.game` navigating to `/games/${item.mediaId}`.
2. Empty state: use `t.dashboard_empty_games`.

- [ ] **Step 2: Add i18n strings**

Add to all locale files:

```json
"dashboard_empty_games": "Nenhum jogo registrado ainda.\nBusque e adicione seu primeiro jogo!"
```

- [ ] **Step 3: Update tests**

Add test in `test/features/dashboard/pages/dashboard_page_test.dart`:

- Game item in dashboard navigates to `/games/:id`.

- [ ] **Step 4: Run codegen and tests**

Run: `dart run build_runner build --delete-conflicting-outputs`
Run: `flutter test test/features/dashboard/pages/dashboard_page_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/dashboard/pages/dashboard_page.dart test/features/dashboard/pages/dashboard_page_test.dart lib/l10n/
git commit -m "feat: adapt DashboardPage for games"
```

---

## Task 13: Social feed verb for STARTED_PLAYING

**Files:**

- Modify: `lib/features/social/widgets/social_activity_verb.dart`
- Modify: `test/features/social/widgets/social_activity_card_test.dart` or create `social_activity_verb_test.dart`

**Interfaces:**

- Consumes: activity type string.
- Produces: Translated verb for `STARTED_PLAYING`.

- [ ] **Step 1: Write failing test**

Create `test/features/social/widgets/social_activity_verb_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/social/widgets/social_activity_verb.dart';
import 'package:lorebase/l10n/strings.g.dart';

void main() {
  test('STARTED_PLAYING returns game verb', () {
    expect(localizedSocialActivityVerb('STARTED_PLAYING'), t.social_activity_started_playing);
  });
}
```

- [ ] **Step 2: Run test to confirm failure**

Run: `flutter test test/features/social/widgets/social_activity_verb_test.dart`
Expected: FAIL — string/translation missing.

- [ ] **Step 3: Add translation and verb**

Modify `lib/features/social/widgets/social_activity_verb.dart`:

```dart
String localizedSocialActivityVerb(String type) {
  return switch (type.toUpperCase()) {
    'RATED' => t.social_activity_rated,
    'REVIEWED' => t.social_activity_reviewed,
    'COMPLETED' => t.social_activity_completed,
    'STARTED_WATCHING' => t.social_activity_started_watching,
    'STARTED_PLAYING' => t.social_activity_started_playing,
    'DROPPED' => t.social_activity_dropped,
    'ADDED_TO_LIST' => t.social_activity_added_to_list,
    _ => t.social_activity_interacted_with,
  };
}
```

Add to all locale files:

```json
"social_activity_started_playing": "começou a jogar"
```

- [ ] **Step 4: Run codegen and tests**

Run: `dart run build_runner build --delete-conflicting-outputs`
Run: `flutter test test/features/social/widgets/social_activity_verb_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/social/widgets/social_activity_verb.dart test/features/social/widgets/social_activity_verb_test.dart lib/l10n/
git commit -m "feat: add STARTED_PLAYING social activity verb for games"
```

---

## Task 14: Router

**Files:**

- Modify: `lib/router.dart`
- Modify: `test/router_test.dart`

**Interfaces:**

- Consumes: `GameDetailPage`.
- Produces: Route `/games/:gameId`.

- [ ] **Step 1: Write failing test**

Add to `test/router_test.dart`:

```dart
test('routes to GameDetailPage for /games/:gameId', () async {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  final router = container.read(routerProvider);
  router.go('/games/1234');
  await router.routerDelegate.ready;
  expect(router.location, '/games/1234');
});
```

- [ ] **Step 2: Run test to confirm failure**

Run: `flutter test test/router_test.dart`
Expected: FAIL — route not found.

- [ ] **Step 3: Add route**

Modify `lib/router.dart`:

1. Import `GameDetailPage`.
2. Add inside `ShellRoute`:

```dart
GoRoute(
  path: '/games/:gameId',
  builder: (context, state) {
    final gameId = state.pathParameters['gameId']!;
    return GameDetailPage(gameId: gameId);
  },
),
```

- [ ] **Step 4: Run tests**

Run: `flutter test test/router_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/router.dart test/router_test.dart
git commit -m "feat: add /games/:gameId route"
```

---

## Task 15: Game search golden test

**Files:**

- Create: `test/visual/pages/game_search_page_golden_test.dart`

**Interfaces:**

- Consumes: `SeriesSearchPage`, `GameSearchViewModel`.
- Produces: Golden image for game search results.

- [ ] **Step 1: Create golden test**

Mirror `series_search_page_golden_test.dart` with `MediaType.game` selected and a fake `GameSearchViewModel` state.

- [ ] **Step 2: Run golden test**

Run: `flutter test test/visual/pages/game_search_page_golden_test.dart`
Expected: PASS (generates/updates goldens).

- [ ] **Step 3: Commit**

```bash
git add test/visual/pages/game_search_page_golden_test.dart test/visual/goldens/
git commit -m "test: add game search golden test"
```

---

## Task 16: Final verification

**Files:**

- All of the above.

- [ ] **Step 1: Run full test suite**

Run: `flutter test`
Expected: PASS.

- [ ] **Step 2: Run lint**

Run: `make analyze`
Expected: PASS.

- [ ] **Step 3: Run coverage gate**

Run: `make test-coverage`
Expected: PASS with 100% line + branch.

- [ ] **Step 4: Fix any failures**

Iterate on failures until all gates pass.

- [ ] **Step 5: Final commit**

```bash
git commit -m "feat: complete games support" --allow-empty
```

---

## Self-Review

### Spec coverage

| Spec section | Task(s) |
|---|---|
| MediaType.game | Task 1 |
| GameTrackingStatus | Task 1 |
| GamePlatform | Task 1, Task 6 |
| GameModel | Task 2 |
| GameRepository | Task 3 |
| GameSearchViewModel + search page integration | Task 4 |
| GameDetailState/ViewModel | Task 5 |
| Game widgets | Task 6 |
| GameDetailPage | Task 7 |
| TrackingRepository extension | Task 8 |
| TrackingEditorSheet extension | Task 9 |
| TrackingStatusChip extension | Task 10 |
| TrackingListPage adaptation | Task 11 |
| DashboardPage adaptation | Task 12 |
| Social verb | Task 13 |
| Router | Task 14 |
| Golden tests | Task 7, Task 15 |
| Coverage gate | Task 16 |

### Placeholder scan

No `TBD`, `TODO`, "implement later", or vague "add error handling" steps. Each step has concrete code or exact command.

### Type consistency

- `GameDetailViewModel` uses `String gameId` consistently.
- `TrackingRepository` methods use `String? selectedPlatform` and `double? hoursPlayed` consistently.
- `TrackingEditorSheet` callback signature matches repository and viewmodel usage.
- `GamePlatform.fromApiValue` and `GamePlatform.apiValue` used for backend round-trip.
