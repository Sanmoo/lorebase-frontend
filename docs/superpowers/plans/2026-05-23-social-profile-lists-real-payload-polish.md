# Social Profile Lists Real Payload and Card Polish Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make Social profile Lists use the real backend payload (`title`/`posterUrl` top-level) and improve horizontal poster card borders/alignment while preserving the approved infinite horizontal carousel.

**Architecture:** Normalize backend list items in `SocialRepositoryImpl._publicListItemFromJson` so UI widgets can continue consuming `PublicListItemModel.media`. Then polish `PublicMediaListSection` card presentation with a bordered card container and consistent text area, without changing the data flow from `SocialProfilePage`.

**Tech Stack:** Flutter, Dart, Dio repository tests, widget tests, Freezed social models, `CachedNetworkImage`.

---

## Evidence

Authenticated backend response from `GET /profiles/{userId}/lists?limit=20` returns items shaped like:

```json
{
  "mediaId": "1422",
  "mediaType": "SERIES",
  "status": "WATCHING",
  "title": "The Middle: Uma Família Perdida no Meio do Nada",
  "posterUrl": "https://image.tmdb.org/t/p/w500/a3hPMvgOe9vOpEEHkuta63AtYnJ.jpg",
  "rating": 6,
  "updatedAt": ""
}
```

The current UI reads `item.media?.posterUrl`, so top-level `posterUrl` is ignored when `media` is absent and the UI falls back to movie/TV icons.

---

## Files

- Modify: `lib/features/social/data/repositories/social_repository.dart`
  - Responsibility: normalize BFF public-list payloads before `PublicListItemModel.fromJson`.
- Modify: `test/features/social/data/social_repository_test.dart`
  - Responsibility: prove real top-level `title`/`posterUrl` payload becomes nested `media` data.
- Modify: `lib/features/social/widgets/public_media_list_section.dart`
  - Responsibility: polish horizontal poster card borders, spacing, and text alignment.
- Modify: `test/features/social/widgets/public_media_list_section_test.dart`
  - Responsibility: cover card polish behavior through stable widget-level assertions and preserve no-overflow coverage.

Do not edit generated files (`*.g.dart`, `*.freezed.dart`). Do not edit `.tasks` manually.

---

### Task 1: Normalize real backend public-list payload

**Files:**
- Modify: `test/features/social/data/social_repository_test.dart`
- Modify: `lib/features/social/data/repositories/social_repository.dart`

- [ ] **Step 1: Write failing repository test for real top-level payload**

In `test/features/social/data/social_repository_test.dart`, add this test immediately before `getPublicLists calls lists endpoint and parses list items`:

```dart
    test(
      'getPublicLists normalizes top-level media title and posterUrl',
      () async {
        final dio = Dio()
          ..httpClientAdapter = MockAdapter(
            onFetch: (_) => _jsonBody({
              'items': [
                {
                  'mediaId': '1422',
                  'mediaType': 'SERIES',
                  'status': 'WATCHING',
                  'title': 'The Middle: Uma Família Perdida no Meio do Nada',
                  'posterUrl':
                      'https://image.tmdb.org/t/p/w500/a3hPMvgOe9vOpEEHkuta63AtYnJ.jpg',
                  'rating': 6,
                  'updatedAt': '',
                },
              ],
              'nextCursor': '',
              'hasMore': false,
            }),
          );
        final repo = SocialRepositoryImpl(dio);

        final result = await repo.getPublicLists('user-1');
        final item = result.items.single;

        expect(item.mediaId, '1422');
        expect(item.mediaType, 'SERIES');
        expect(item.status, 'WATCHING');
        expect(item.rating, 6);
        expect(item.updatedAt, isNull);
        expect(item.media?.mediaId, '1422');
        expect(item.media?.mediaType, 'SERIES');
        expect(
          item.media?.title,
          'The Middle: Uma Família Perdida no Meio do Nada',
        );
        expect(
          item.media?.posterUrl,
          'https://image.tmdb.org/t/p/w500/a3hPMvgOe9vOpEEHkuta63AtYnJ.jpg',
        );
      },
    );
```

- [ ] **Step 2: Run test and verify it fails for missing media normalization**

Run:

```bash
cd /home/sanmoo/dev/github.com/lorebase/lorebase-frontend/.worktrees/task-000008-social-lists
flutter test test/features/social/data/social_repository_test.dart --plain-name 'getPublicLists normalizes top-level media title and posterUrl'
```

Expected: FAIL because `item.media` is currently null for top-level-only payloads.

- [ ] **Step 3: Implement normalization in repository**

In `lib/features/social/data/repositories/social_repository.dart`, replace `_publicListItemFromJson` with:

```dart
  PublicListItemModel _publicListItemFromJson(Map<String, dynamic> json) {
    final normalizedJson = Map<String, dynamic>.from(json);
    if (normalizedJson['updatedAt'] == '') {
      normalizedJson['updatedAt'] = null;
    }
    normalizedJson['media'] ??= _mediaFromPublicListJson(normalizedJson);
    return PublicListItemModel.fromJson(normalizedJson);
  }

  Map<String, dynamic>? _mediaFromPublicListJson(Map<String, dynamic> json) {
    final title = (json['title'] as String?)?.trim();
    if (title == null || title.isEmpty) {
      return null;
    }

    return {
      'mediaId': json['mediaId'],
      'mediaType': json['mediaType'],
      'title': title,
      'posterUrl': json['posterUrl'],
    };
  }
```

- [ ] **Step 4: Run focused repository test and verify pass**

```bash
flutter test test/features/social/data/social_repository_test.dart --plain-name 'getPublicLists normalizes top-level media title and posterUrl'
```

Expected: PASS.

- [ ] **Step 5: Run social repository tests**

```bash
flutter test test/features/social/data/social_repository_test.dart
```

Expected: all tests in the file pass.

- [ ] **Step 6: Commit repository normalization**

```bash
git add lib/features/social/data/repositories/social_repository.dart test/features/social/data/social_repository_test.dart
git commit -m "fix: normalize public list media payload"
```

---

### Task 2: Polish horizontal poster cards

**Files:**
- Modify: `test/features/social/widgets/public_media_list_section_test.dart`
- Modify: `lib/features/social/widgets/public_media_list_section.dart`

- [ ] **Step 1: Add widget test for bordered aligned cards**

In `test/features/social/widgets/public_media_list_section_test.dart`, add this test after `renders list items in friendly horizontal carousels`:

```dart
  testWidgets('renders public media cards with bordered aligned layout', (
    tester,
  ) async {
    await pumpSection(
      tester,
      items: [
        item(
          status: 'COMPLETED',
          title: 'Batman: O Cavaleiro das Trevas',
          rating: 10,
        ),
      ],
    );

    final decoratedBoxes = tester.widgetList<DecoratedBox>(
      find.descendant(
        of: find.byType(InkWell),
        matching: find.byType(DecoratedBox),
      ),
    );

    expect(
      decoratedBoxes.any((box) {
        final decoration = box.decoration;
        return decoration is BoxDecoration && decoration.border != null;
      }),
      isTrue,
    );
    expect(find.text('Batman: O Cavaleiro das Trevas'), findsOneWidget);
    expect(find.text('Filme • ⭐ 10/10'), findsOneWidget);
  });
```

- [ ] **Step 2: Run focused widget test and verify it fails for missing border/layout polish**

```bash
flutter test test/features/social/widgets/public_media_list_section_test.dart --plain-name 'renders public media cards with bordered aligned layout'
```

Expected: FAIL because the current card has no decorated bordered container and metadata may be split into separate text widgets.

- [ ] **Step 3: Implement bordered card container and aligned text area**

In `lib/features/social/widgets/public_media_list_section.dart`:

1. Increase card width for readability:

```dart
  static const double _cardWidth = 124;
```

2. In `_PublicMediaCard.build`, replace the `InkWell` child `Column(...)` with a decorated/padded card:

```dart
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _Poster(item: item)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _Metadata(
                    mediaTypeLabel:
                        showMediaTypeMetadata ? mediaTypeLabel : null,
                    ratingLabel: ratingLabel,
                  ),
                ],
              ),
            ),
          ),
```

3. Update `_Metadata` to produce one aligned text line instead of multiple flexible fragments:

```dart
  @override
  Widget build(BuildContext context) {
    final parts = [
      if (mediaTypeLabel != null) mediaTypeLabel!,
      if (ratingLabel != null) ratingLabel!,
    ];
    final textStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );

    return SizedBox(
      height: 18,
      child: Text(
        parts.join(' • '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: textStyle,
      ),
    );
  }
```

- [ ] **Step 4: Run focused widget test and verify pass**

```bash
flutter test test/features/social/widgets/public_media_list_section_test.dart --plain-name 'renders public media cards with bordered aligned layout'
```

Expected: PASS.

- [ ] **Step 5: Run full widget test file**

```bash
flutter test test/features/social/widgets/public_media_list_section_test.dart
```

Expected: all widget tests pass.

- [ ] **Step 6: Commit card polish**

```bash
git add lib/features/social/widgets/public_media_list_section.dart test/features/social/widgets/public_media_list_section_test.dart
git commit -m "style: polish public list media cards"
```

---

### Task 3: Validate real-payload fix and final checks

**Files:**
- Verify only unless tests fail.

- [ ] **Step 1: Run LSP diagnostics**

Use `lsp_diagnostics` on:

```text
lib/features/social/data/repositories/social_repository.dart
test/features/social/data/social_repository_test.dart
lib/features/social/widgets/public_media_list_section.dart
test/features/social/widgets/public_media_list_section_test.dart
```

Expected: no diagnostics.

- [ ] **Step 2: Run focused tests**

```bash
cd /home/sanmoo/dev/github.com/lorebase/lorebase-frontend/.worktrees/task-000008-social-lists
flutter test test/features/social/data/social_repository_test.dart test/features/social/widgets/public_media_list_section_test.dart
```

Expected: all focused tests pass.

- [ ] **Step 3: Run analyzer**

```bash
make analyze
```

Expected: `No issues found!`

- [ ] **Step 4: Run full test suite**

```bash
flutter test
```

Expected: all tests pass.

- [ ] **Step 5: Report status without marking WorkQ done**

Report commits, verification commands, and remaining unrelated untracked files. Do not run `workq done` unless explicitly requested by the human.
