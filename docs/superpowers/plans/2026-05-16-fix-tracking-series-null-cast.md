# Fix Tracking Series Null Cast — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix `TrackedMediaSummaryModel` deserialization to match actual API response shape (key `tmdbId` int → `mediaId` String; `mediaType` nullable).

**Architecture:** Add 4 flexible JSON converter functions to `json_converters.dart`, update `@JsonKey` annotations on `TrackedMediaSummaryModel`, regenerate codegen files, update test fixtures.

**Tech Stack:** Dart, Freezed, json_serializable, build_runner

---

### Task 1: Add flexible JSON converters

**Files:**
- Modify: `lib/core/utils/json_converters.dart`

- [ ] **Step 1: Add converter functions**

Add the following after the existing `flexibleIntToJson` function (before the end of the file):

```dart
/// Converts a [value] that may be [int] or [String] to a [String].
///
/// Used for fields like [TrackedMediaSummaryModel.mediaId] where the API
/// sends an integer (e.g. `tmdbId`) but the model uses a [String].
String flexibleStringFromJson(dynamic value) {
  if (value is String) return value;
  if (value is int) return value.toString();
  throw FormatException(
    'Cannot convert $value (${value.runtimeType}) to String',
  );
}

/// Returns the [String] value unchanged for JSON serialization.
String flexibleStringToJson(String value) => value;

/// Parses a nullable API value into [MediaType].
///
/// Returns `null` when [value] is `null` (field absent from API response).
MediaType? nullableMediaTypeFromJson(dynamic value) {
  if (value == null) return null;
  if (value is String) return mediaTypeFromJson(value);
  throw FormatException(
    'Cannot convert $value (${value.runtimeType}) to MediaType',
  );
}

/// Returns the API string or `null` for JSON serialization.
dynamic? nullableMediaTypeToJson(MediaType? value) => value?.apiValue;
```

`nullableMediaTypeFromJson` depends on `mediaTypeFromJson` which is in `lib/features/tracking/data/models/media_type.dart`. Add the import at the top of `json_converters.dart`:

```dart
import 'package:lorebase/features/tracking/data/models/media_type.dart';
```

Wait — this creates a dependency from `core/utils/` to `features/tracking/`. To avoid this, place the `nullableMediaType*` converters directly in `tracked_media_summary_model.dart` where `mediaTypeFromJson` is already imported.

**Revised locations:**

`lib/core/utils/json_converters.dart` — only `flexibleStringFromJson` + `flexibleStringToJson`:

```dart
/// Converts a [value] that may be [int] or [String] to a [String].
///
/// Used for fields where the API sends an integer but the model uses a [String].
String flexibleStringFromJson(dynamic value) {
  if (value is String) return value;
  if (value is int) return value.toString();
  throw FormatException(
    'Cannot convert $value (${value.runtimeType}) to String',
  );
}

/// Returns the [String] value unchanged for JSON serialization.
String flexibleStringToJson(String value) => value;
```

- [ ] **Step 2: Verify the file compiles**

```bash
dart analyze lib/core/utils/json_converters.dart
```

Expected: no errors.

---

### Task 2: Update TrackedMediaSummaryModel annotations

**Files:**
- Modify: `lib/features/tracking/data/models/tracked_media_summary_model.dart`

- [ ] **Step 1: Add nullable mediaType converters and update model fields**

Replace the entire file content:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/utils/json_converters.dart';
import 'media_type.dart';

part 'tracked_media_summary_model.freezed.dart';
part 'tracked_media_summary_model.g.dart';

MediaType? _nullableMediaTypeFromJson(dynamic value) {
  if (value == null) return null;
  if (value is String) return mediaTypeFromJson(value);
  throw FormatException(
    'Cannot convert $value (${value.runtimeType}) to MediaType',
  );
}

dynamic? _nullableMediaTypeToJson(MediaType? value) => value?.apiValue;

@freezed
class TrackedMediaSummaryModel with _$TrackedMediaSummaryModel {
  const factory TrackedMediaSummaryModel({
    @JsonKey(
      name: 'tmdbId',
      fromJson: flexibleStringFromJson,
      toJson: flexibleStringToJson,
    )
    required String mediaId,
    required String title,
    @JsonKey(
      fromJson: _nullableMediaTypeFromJson,
      toJson: _nullableMediaTypeToJson,
    )
    MediaType? mediaType,
    String? overview,
    String? posterPath,
    String? status,
    int? trackingRating,
    int? seasonCount,
    DateTime? addedAt,
  }) = _TrackedMediaSummaryModel;

  factory TrackedMediaSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$TrackedMediaSummaryModelFromJson(json);
}
```

- [ ] **Step 2: Run build_runner to regenerate codegen**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: no errors, `.g.dart` and `.freezed.dart` updated.

- [ ] **Step 3: Verify the file compiles**

```bash
dart analyze lib/features/tracking/data/models/tracked_media_summary_model.dart
```

Expected: no errors.

---

### Task 3: Update fromJson test fixtures

**Files:**
- Modify: `test/features/tracking/data/models/tracked_media_summary_model_test.dart`
- Modify: `test/features/tracking/data/models/tracked_media_model_test.dart`

- [ ] **Step 1: Update `tracked_media_summary_model_test.dart`**

Replace the file content to use `'tmdbId'` key (matching the new `@JsonKey(name:)`):

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/tracking/data/models/tracked_media_summary_model.dart';
import 'package:lorebase/features/tracking/data/models/media_type.dart';

void main() {
  test('fromJson parses summary payload with tmdbId as int (API shape)', () {
    final model = TrackedMediaSummaryModel.fromJson(const {
      'tmdbId': 10,
      'title': 'The Batman',
      'mediaType': 'MOVIE',
      'posterPath': '/poster.jpg',
    });

    expect(model.mediaId, '10');
    expect(model.title, 'The Batman');
    expect(model.mediaType!.apiValue, 'MOVIE');
    expect(model.posterPath, '/poster.jpg');
  });

  test('fromJson handles missing mediaType', () {
    final model = TrackedMediaSummaryModel.fromJson(const {
      'tmdbId': 42,
      'title': 'Test Show',
    });

    expect(model.mediaId, '42');
    expect(model.title, 'Test Show');
    expect(model.mediaType, isNull);
  });

  test('toJson fromJson roundtrip', () {
    final original = TrackedMediaSummaryModel(
      mediaId: '10',
      title: 'The Batman',
      mediaType: MediaType.movie,
      posterPath: '/poster.jpg',
    );
    final jsonMap = original.toJson();
    final restored = TrackedMediaSummaryModel.fromJson(jsonMap);
    expect(restored.mediaId, '10');
    expect(restored.title, 'The Batman');
    expect(restored.mediaType!.apiValue, 'MOVIE');
  });

  test('toJson fromJson roundtrip with null mediaType', () {
    final original = TrackedMediaSummaryModel(
      mediaId: '42',
      title: 'Test Show',
    );
    final jsonMap = original.toJson();
    final restored = TrackedMediaSummaryModel.fromJson(jsonMap);
    expect(restored.mediaId, '42');
    expect(restored.title, 'Test Show');
    expect(restored.mediaType, isNull);
  });
}
```

- [ ] **Step 2: Update `tracked_media_model_test.dart`** — fix the `media` JSON fixture

In `test/features/tracking/data/models/tracked_media_model_test.dart`, change the nested `'media'` object's key from `'mediaId'` to `'tmdbId'` (int):

Old:
```dart
'media': {
  'mediaId': '42',
  'title': 'Test Show',
  'mediaType': 'SERIES',
},
```

New:
```dart
'media': {
  'tmdbId': 42,
  'title': 'Test Show',
  'mediaType': 'SERIES',
},
```

- [ ] **Step 3: Run the tests**

```bash
flutter test test/features/tracking/data/models/tracked_media_summary_model_test.dart
flutter test test/features/tracking/data/models/tracked_media_model_test.dart
```

Expected: all tests pass.

---

### Task 4: Run full test suite and quality gate

**Files:** none (verification only)

- [ ] **Step 1: Run all tracking tests**

```bash
flutter test test/features/tracking/
```

Expected: all tests pass.

- [ ] **Step 2: Run full test suite**

```bash
flutter test
```

Expected: all tests pass.

- [ ] **Step 3: Run static analysis**

```bash
dart analyze --fatal-infos
```

Expected: no errors, no warnings.

- [ ] **Step 4: Run quality gate**

```bash
make check
```

Expected: passes (analyze + coverage at 100%).

- [ ] **Step 5: Commit**

```bash
git add lib/core/utils/json_converters.dart
git add lib/features/tracking/data/models/tracked_media_summary_model.dart
git add lib/features/tracking/data/models/tracked_media_summary_model.g.dart
git add lib/features/tracking/data/models/tracked_media_summary_model.freezed.dart
git add test/features/tracking/data/models/tracked_media_summary_model_test.dart
git add test/features/tracking/data/models/tracked_media_model_test.dart
git commit -m "fix: align TrackedMediaSummaryModel with API response shape

- Map tmdbId (int) from API to mediaId (String) via flexibleStringFromJson
- Make mediaType nullable (absent from API media object)
- Add null-safe nullableMediaTypeFromJson/toJson converters
- Update test fixtures to match new JSON key names"
```
