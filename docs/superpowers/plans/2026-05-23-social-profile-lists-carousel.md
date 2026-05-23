# Social Profile Lists Carousel Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the Social profile Lists tab record-style list with vertically stacked, horizontally scrollable poster carousels grouped by friendly public list labels.

**Architecture:** Keep `PublicMediaListSection` as the public widget consumed by `SocialProfilePage`, but split presentation internally into small private widgets/helpers: status grouping, section header + carousel, and poster card. Use `PublicListItemModel` directly to avoid coupling social public lists to tracking/dashboard models.

**Tech Stack:** Flutter widgets, Dart, existing Freezed social models, `CachedNetworkImage` for posters, Flutter widget tests.

---

## Files

- Modify: `lib/features/social/widgets/public_media_list_section.dart`
  - Responsibility: group public list items by status and render the approved carousel UI.
- Modify: `test/features/social/widgets/public_media_list_section_test.dart`
  - Responsibility: cover grouped carousel rendering, friendly labels, title/rating behavior, no overflow, horizontal scrolling, and tap callback.

Do not edit generated files (`*.g.dart`, `*.freezed.dart`).

---

### Task 1: Update tests for carousel behavior

**Files:**
- Modify: `test/features/social/widgets/public_media_list_section_test.dart`

- [ ] **Step 1: Replace the current helper with poster-aware test data**

In `test/features/social/widgets/public_media_list_section_test.dart`, update the `item` helper near the top of `main()` to include `posterUrl` and varied statuses:

```dart
  PublicListItemModel item({
    String mediaId = 'media-1',
    String mediaType = 'MOVIE',
    String status = 'COMPLETED',
    int? rating,
    bool hasMedia = true,
    String title = 'One Piece',
    String? posterUrl = 'https://example.com/poster.jpg',
  }) => PublicListItemModel(
    mediaId: mediaId,
    mediaType: mediaType,
    status: status,
    rating: rating,
    media: hasMedia
        ? SocialMediaModel(
            mediaId: mediaId,
            mediaType: mediaType,
            title: title,
            posterUrl: posterUrl,
          )
        : null,
  );
```

- [ ] **Step 2: Replace the grouped labels test with carousel assertions**

Replace the existing `groups items by friendly localized list labels` test body with:

```dart
  testWidgets('groups items into poster carousels with friendly labels', (
    tester,
  ) async {
    await pumpSection(
      tester,
      items: [
        item(status: 'PLAN_TO_WATCH', title: 'Interestelar'),
        item(status: 'WATCHING', mediaType: 'SERIES', title: 'Reacher'),
        item(status: 'COMPLETED', title: 'Batman Begins', rating: 9),
        item(status: 'DROPPED', title: 'Série abandonada'),
      ],
    );

    expect(find.text('Quero ver'), findsOneWidget);
    expect(find.text('Assistindo'), findsOneWidget);
    expect(find.text('Concluído'), findsOneWidget);
    expect(find.text('Abandonado'), findsOneWidget);
    expect(find.text('Interestelar'), findsOneWidget);
    expect(find.text('Reacher'), findsOneWidget);
    expect(find.text('Batman Begins'), findsOneWidget);
    expect(find.text('⭐ 9/10'), findsOneWidget);
    expect(find.text('PLAN_TO_WATCH'), findsNothing);
    expect(find.text('WATCHING'), findsNothing);
    expect(find.text('COMPLETED'), findsNothing);
    expect(find.text('DROPPED'), findsNothing);
    expect(find.byType(ListTile), findsNothing);
    expect(
      tester.widgetList<ListView>(find.byType(ListView)).any(
            (listView) => listView.scrollDirection == Axis.horizontal,
          ),
      isTrue,
    );
  });
```

- [ ] **Step 3: Replace the missing-media fallback test**

Replace the existing `item without tap callback is disabled but visible` test with:

```dart
  testWidgets('missing media uses friendly fallback instead of media id', (
    tester,
  ) async {
    await pumpSection(tester, items: [item(hasMedia: false)]);

    expect(find.text('Filme'), findsOneWidget);
    expect(find.text('media-1'), findsNothing);
    expect(find.byIcon(Icons.movie), findsOneWidget);
  });
```

- [ ] **Step 4: Replace the overflow test with horizontal carousel scrolling**

Replace the existing `scrolls many public list items without overflow` test with:

```dart
  testWidgets('scrolls many public list items without overflow', (
    tester,
  ) async {
    final items = List.generate(
      12,
      (index) => item(
        mediaId: '$index',
        status: 'COMPLETED',
        title: 'Título $index',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 260,
            child: PublicMediaListSection(title: 'Favoritos', items: items),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Título 0'), findsOneWidget);
    expect(find.text('Título 11'), findsNothing);

    final horizontalList = find
        .byType(ListView)
        .evaluate()
        .map((element) => element.widget as ListView)
        .where((listView) => listView.scrollDirection == Axis.horizontal)
        .first;
    expect(horizontalList.scrollDirection, Axis.horizontal);

    await tester.drag(
      find.byWidget(horizontalList),
      const Offset(-900, 0),
    );
    await tester.pumpAndSettle();

    expect(find.text('Título 11'), findsOneWidget);
  });
```

- [ ] **Step 5: Update tap test expectation for card-based UI**

In `omits rating when absent and handles taps`, replace:

```dart
    await tester.tap(find.byType(ListTile));
```

with:

```dart
    await tester.tap(find.text('One Piece'));
```

Keep the assertions:

```dart
    expect(find.text('⭐ 9/10'), findsNothing);
    expect(tapped, listItem);
```

- [ ] **Step 6: Run the focused test and verify it fails for the expected reason**

Run:

```bash
cd /home/sanmoo/dev/github.com/lorebase/lorebase-frontend/.worktrees/task-000008-social-lists
flutter test test/features/social/widgets/public_media_list_section_test.dart
```

Expected: FAIL because the implementation still renders `ListTile` rows instead of horizontal poster carousels.

- [ ] **Step 7: Commit the failing tests**

```bash
git add test/features/social/widgets/public_media_list_section_test.dart
git commit -m "test: specify social profile list carousel"
```

---

### Task 2: Implement carousel UI in PublicMediaListSection

**Files:**
- Modify: `lib/features/social/widgets/public_media_list_section.dart`

- [ ] **Step 1: Add cached image import**

At the top of `lib/features/social/widgets/public_media_list_section.dart`, add:

```dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image_platform_interface/cached_network_image_platform_interface.dart';
```

Keep the existing Flutter and model imports.

- [ ] **Step 2: Replace list-tile rendering with sections and carousels**

Replace the current `PublicMediaListSection.build` method with:

```dart
  @override
  Widget build(BuildContext context) {
    final groupedItems = _groupItemsByStatus(items);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (items.isEmpty)
          Text(emptyMessage)
        else
          for (final entry in groupedItems.entries)
            if (entry.value.isNotEmpty)
              _PublicListCarousel(
                title: _statusLabel(entry.key),
                items: entry.value,
                onItemTap: onItemTap,
              ),
      ],
    );
  }
```

- [ ] **Step 3: Replace `_PublicListTile` with carousel and poster-card widgets**

Delete the existing `_PublicListTile` class and add these private widgets in its place:

```dart
class _PublicListCarousel extends StatelessWidget {
  const _PublicListCarousel({
    required this.title,
    required this.items,
    required this.onItemTap,
  });

  final String title;
  final List<PublicListItemModel> items;
  final ValueChanged<PublicListItemModel>? onItemTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          SizedBox(
            height: 190,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                return _PublicMediaPosterCard(
                  item: item,
                  onTap: onItemTap == null ? null : () => onItemTap!(item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PublicMediaPosterCard extends StatelessWidget {
  const _PublicMediaPosterCard({required this.item, required this.onTap});

  final PublicListItemModel item;
  final VoidCallback? onTap;

  static const double _width = 96;
  static const double _posterHeight = 144;

  @override
  Widget build(BuildContext context) {
    final media = item.media;
    final posterUrl = media?.posterUrl;
    final title = media?.title ?? _mediaTypeLabel(item.mediaType);
    final metadata = [
      _mediaTypeLabel(media?.mediaType ?? item.mediaType),
      if (item.rating != null) '⭐ ${item.rating}/10',
    ];

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: _width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: _width,
                height: _posterHeight,
                color: Colors.grey[300],
                child: posterUrl != null && posterUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: posterUrl,
                        imageRenderMethodForWeb:
                            ImageRenderMethodForWeb.HttpGet,
                        width: _width,
                        height: _posterHeight,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) =>
                            _FallbackPosterIcon(item.mediaType),
                      )
                    : _FallbackPosterIcon(item.mediaType),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (metadata.isNotEmpty)
              Text(
                metadata.join(' • '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }
}

class _FallbackPosterIcon extends StatelessWidget {
  const _FallbackPosterIcon(this.mediaType);

  final String mediaType;

  @override
  Widget build(BuildContext context) {
    return Icon(
      _mediaTypeIcon(mediaType),
      color: Colors.grey[600],
    );
  }
}
```

- [ ] **Step 4: Add media type icon helper**

Below `_mediaTypeLabel`, add:

```dart
IconData _mediaTypeIcon(String mediaType) {
  switch (mediaType.toUpperCase()) {
    case 'MOVIE':
    case 'FILME':
      return Icons.movie;
    case 'SERIES':
    case 'TV':
      return Icons.tv;
    default:
      return Icons.image;
  }
}
```

- [ ] **Step 5: Keep status/media labels friendly**

Verify `_statusLabel` and `_mediaTypeLabel` still include these mappings:

```dart
String _statusLabel(String status) {
  switch (status.toUpperCase()) {
    case 'PLAN_TO_WATCH':
      return 'Quero ver';
    case 'WATCHING':
      return 'Assistindo';
    case 'COMPLETED':
      return 'Concluído';
    case 'DROPPED':
      return 'Abandonado';
    default:
      return status
          .toLowerCase()
          .split('_')
          .where((part) => part.isNotEmpty)
          .map((part) => part[0].toUpperCase() + part.substring(1))
          .join(' ');
  }
}

String _mediaTypeLabel(String mediaType) {
  switch (mediaType.toUpperCase()) {
    case 'MOVIE':
    case 'FILME':
      return 'Filme';
    case 'SERIES':
    case 'TV':
      return 'Série';
    default:
      return mediaType;
  }
}
```

- [ ] **Step 6: Run diagnostics**

Run:

```bash
cd /home/sanmoo/dev/github.com/lorebase/lorebase-frontend/.worktrees/task-000008-social-lists
```

Then use LSP diagnostics on:

```text
lib/features/social/widgets/public_media_list_section.dart
test/features/social/widgets/public_media_list_section_test.dart
```

Expected: no diagnostics.

- [ ] **Step 7: Run focused test and verify it passes**

Run:

```bash
flutter test test/features/social/widgets/public_media_list_section_test.dart
```

Expected: all tests in that file pass.

- [ ] **Step 8: Commit implementation**

```bash
git add lib/features/social/widgets/public_media_list_section.dart test/features/social/widgets/public_media_list_section_test.dart
git commit -m "feat: show social profile lists as carousels"
```

---

### Task 3: Final verification

**Files:**
- Verify only; no code changes expected.

- [ ] **Step 1: Run analyzer**

```bash
cd /home/sanmoo/dev/github.com/lorebase/lorebase-frontend/.worktrees/task-000008-social-lists
make analyze
```

Expected: `No issues found!`

- [ ] **Step 2: Run full test suite**

```bash
flutter test
```

Expected: all tests pass. Existing non-fatal Flutter tap warnings in unrelated tests may appear, but the process must exit with code 0.

- [ ] **Step 3: Inspect worktree status**

```bash
git status --short
```

Expected: no uncommitted changes from the carousel implementation. If unrelated untracked files remain (`.tasks/task-000009.md`, `docs/superpowers/plans/2026-05-23-social-follow-button-fix.md`), report them separately and do not include them in this task unless the human explicitly asks.

- [ ] **Step 4: Report completion without marking WorkQ done**

Report changed files, commits, and verification commands. Do not run `workq done`; the human instructed that the WorkQ task should only be marked done if explicitly requested.
