# Flexible `tmdbId` Parsing — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `MovieModel.fromJson` and `SeriesModel.fromJson` resilient to both `int` and `String` values for `tmdbId`, fixing the crash when the movie detail API returns `tmdbId` as a String.

**Architecture:** Add a shared `flexibleIntFromJson` / `flexibleIntToJson` converter pair in `lib/core/utils/json_converters.dart`. Annotate the `tmdbId` field in both `MovieModel` and `SeriesModel` with `@JsonKey(fromJson: flexibleIntFromJson, toJson: flexibleIntToJson)`. Regenerate `.g.dart` files. Add tests for the String-input case.

**Tech Stack:** Dart, Freezed, json_serializable, flutter_test

---

## File Structure

| File | Action | Responsibility |
|------|--------|----------------|
| `lib/core/utils/json_converters.dart` | **Create** | `flexibleIntFromJson`, `flexibleIntToJson` converter functions |
| `test/core/utils/json_converters_test.dart` | **Create** | Unit tests for converter functions |
| `lib/features/movies/data/models/movie_model.dart` | **Modify** | Add `@JsonKey` on `tmdbId` + import |
| `lib/features/series/data/models/series_model.dart` | **Modify** | Add `@JsonKey` on `tmdbId` + import |
| `lib/features/movies/data/models/movie_model.g.dart` | **Regenerate** | Output of build_runner |
| `lib/features/series/data/models/series_model.g.dart` | **Regenerate** | Output of build_runner |
| `test/features/movies/data/models/movie_model_test.dart` | **Modify** | Add test for `tmdbId` as String in JSON |
| `test/features/series/data/models/series_model_test.dart` | **Modify** | Add test for `tmdbId` as String in JSON |

---

### Task 1: Create `flexibleIntFromJson` / `flexibleIntToJson` converters

**Files:**
- Create: `lib/core/utils/json_converters.dart`
- Create: `test/core/utils/json_converters_test.dart`

- [ ] **Step 1: Write the failing test for `flexibleIntFromJson`**

Create `test/core/utils/json_converters_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/core/utils/json_converters.dart';

void main() {
  group('flexibleIntFromJson', () {
    test('returns int when input is int', () {
      expect(flexibleIntFromJson(42), 42);
      expect(flexibleIntFromJson(0), 0);
      expect(flexibleIntFromJson(-1), -1);
    });

    test('parses int when input is String', () {
      expect(flexibleIntFromJson('42'), 42);
      expect(flexibleIntFromJson('0'), 0);
      expect(flexibleIntFromJson('123456'), 123456);
    });

    test('throws FormatException for unsupported types', () {
      expect(
        () => flexibleIntFromJson(true),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => flexibleIntFromJson(null),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => flexibleIntFromJson(3.14),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException for non-numeric String', () {
      expect(
        () => flexibleIntFromJson('abc'),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('flexibleIntToJson', () {
    test('returns the int unchanged', () {
      expect(flexibleIntToJson(42), 42);
      expect(flexibleIntToJson(0), 0);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/utils/json_converters_test.dart`
Expected: FAIL — file not found or import cannot be resolved

- [ ] **Step 3: Write minimal implementation**

Create `lib/core/utils/json_converters.dart`:

```dart
/// Parses a [value] that may be either [int] or [String] into an [int].
///
/// Throws [FormatException] if [value] is neither [int] nor [String],
/// or if the String cannot be parsed as an integer.
int flexibleIntFromJson(dynamic value) {
  if (value is int) return value;
  if (value is String) return int.parse(value);
  throw FormatException(
    'Cannot convert $value (${value.runtimeType}) to int',
  );
}

/// Returns the [int] value unchanged for JSON serialization.
///
/// Exists so the `@JsonKey` annotation has a symmetric toJson companion
/// for the fromJson converter.
int flexibleIntToJson(int value) => value;
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/utils/json_converters_test.dart`
Expected: PASS (all 6 tests)

- [ ] **Step 5: Commit**

```bash
git add lib/core/utils/json_converters.dart test/core/utils/json_converters_test.dart
git commit -m "feat: add flexibleIntFromJson / flexibleIntToJson converters"
```

---

### Task 2: Add String-tmdbId test cases to existing model tests

**Files:**
- Modify: `test/features/movies/data/models/movie_model_test.dart`
- Modify: `test/features/series/data/models/series_model_test.dart`

- [ ] **Step 1: Add MovieModel String-tmdbId test — verify it fails**

Add this test to the `MovieModel` group in `test/features/movies/data/models/movie_model_test.dart`, right before the closing `});` of the `group('MovieModel'` block:

```dart
    test('fromJson accepts tmdbId as String', () {
      const jsonWithStringId = {
        'tmdbId': '550',
        'title': 'Fight Club',
        'overview': 'A film about an underground fight club',
        'posterPath': '/fight.jpg',
        'backdropPath': '/fight-bg.jpg',
        'releaseDate': '1999-10-15',
        'genres': ['Drama'],
        'runtimeMinutes': 139,
        'status': 'Released',
      };
      final movie = MovieModel.fromJson(jsonWithStringId);

      expect(movie.tmdbId, 550);
      expect(movie.title, 'Fight Club');
    });
```

Run: `flutter test test/features/movies/data/models/movie_model_test.dart`
Expected: FAIL — `type 'String' is not a subtype of type 'int' in type cast`

- [ ] **Step 2: Add SeriesModel String-tmdbId test — verify it fails**

Add this test to the `SeriesModel` group in `test/features/series/data/models/series_model_test.dart`, right before the closing `});`:

```dart
    test('fromJson accepts tmdbId as String', () {
      const jsonWithStringId = {
        'tmdbId': '123',
        'title': 'Test Series',
        'overview': 'A test',
        'posterPath': '/p.jpg',
        'backdropPath': '/b.jpg',
        'firstAirDate': '2024-01-01',
        'genres': ['Drama'],
        'networks': ['HBO'],
        'seasonCount': 3,
        'status': 'Ended',
      };
      final model = SeriesModel.fromJson(jsonWithStringId);

      expect(model.tmdbId, 123);
      expect(model.title, 'Test Series');
    });
```

Run: `flutter test test/features/series/data/models/series_model_test.dart`
Expected: FAIL — `type 'String' is not a subtype of type 'int' in type cast`

- [ ] **Step 3: Commit the failing tests**

```bash
git add test/features/movies/data/models/movie_model_test.dart test/features/series/data/models/series_model_test.dart
git commit -m "test: add failing tests for tmdbId as String in MovieModel and SeriesModel"
```

---

### Task 3: Annotate `tmdbId` with `@JsonKey` in MovieModel and SeriesModel

**Files:**
- Modify: `lib/features/movies/data/models/movie_model.dart`
- Modify: `lib/features/series/data/models/series_model.dart`

- [ ] **Step 1: Annotate MovieModel**

In `lib/features/movies/data/models/movie_model.dart`, add the import and `@JsonKey` annotation:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/utils/json_converters.dart';

part 'movie_model.freezed.dart';
part 'movie_model.g.dart';

@freezed
class MovieModel with _$MovieModel {
  const factory MovieModel({
    @JsonKey(fromJson: flexibleIntFromJson, toJson: flexibleIntToJson)
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

- [ ] **Step 2: Annotate SeriesModel**

In `lib/features/series/data/models/series_model.dart`, add the import and `@JsonKey` annotation:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/utils/json_converters.dart';

part 'series_model.freezed.dart';
part 'series_model.g.dart';

@freezed
class SeriesModel with _$SeriesModel {
  const factory SeriesModel({
    @JsonKey(fromJson: flexibleIntFromJson, toJson: flexibleIntToJson)
    required int tmdbId,
    required String title,
    String? overview,
    String? posterPath,
    String? backdropPath,
    String? firstAirDate,
    @Default([]) List<String> genres,
    @Default([]) List<String> networks,
    @Default(0) int seasonCount,
    String? status,
  }) = _SeriesModel;

  factory SeriesModel.fromJson(Map<String, dynamic> json) =>
      _$SeriesModelFromJson(json);
}
```

- [ ] **Step 3: Commit model changes**

```bash
git add lib/features/movies/data/models/movie_model.dart lib/features/series/data/models/series_model.dart
git commit -m "feat: annotate tmdbId with flexibleIntFromJson JsonKey in MovieModel and SeriesModel"
```

---

### Task 4: Regenerate code and run all tests

**Files:**
- Regenerate: `lib/features/movies/data/models/movie_model.g.dart`
- Regenerate: `lib/features/series/data/models/series_model.g.dart`

- [ ] **Step 1: Run build_runner to regenerate .g.dart files**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: BUILD SUCCESS

- [ ] **Step 2: Run the String-tmdbId model tests — verify they pass**

Run: `flutter test test/features/movies/data/models/movie_model_test.dart test/features/series/data/models/series_model_test.dart`
Expected: PASS (all tests, including the new String-tmdbId tests)

- [ ] **Step 3: Run the full test suite — verify no regressions**

Run: `flutter test`
Expected: PASS (all tests)

- [ ] **Step 4: Run coverage quality gate**

Run: `make check`
Expected: PASS (100% line + branch coverage maintained)

- [ ] **Step 5: Commit regenerated code**

```bash
git add lib/features/movies/data/models/movie_model.g.dart lib/features/series/data/models/series_model.g.dart
git commit -m "chore: regenerate .g.dart after JsonKey annotation changes"
```

---

## Verification Checklist

- [x] `flexibleIntFromJson` handles both `int` and `String` inputs
- [x] `flexibleIntFromJson` throws `FormatException` for invalid inputs
- [x] `MovieModel.fromJson` accepts `tmdbId` as String
- [x] `SeriesModel.fromJson` accepts `tmdbId` as String
- [x] `MovieModel.toJson() → fromJson()` roundtrip continues working
- [x] `SeriesModel.toJson() → fromJson()` roundtrip continues working
- [x] Full test suite passes with no regressions
- [x] Coverage quality gate passes
