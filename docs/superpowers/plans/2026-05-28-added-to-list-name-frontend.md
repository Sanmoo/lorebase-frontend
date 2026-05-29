# Added To List Name Frontend Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Render `ADDED_TO_LIST` social activity events with the list name when the API provides it in metadata, while preserving the current fallback when it does not.

**Architecture:** Keep `ActivityEventModel` unchanged because `metadata` already preserves arbitrary API fields. Add shared formatting helpers next to `socialActivityVerbFor`, use them in the Dashboard text row, and update `SocialActivityCard` to preserve tappable user/media spans while adding the list name suffix when available.

**Tech Stack:** Flutter 3.27, Dart, flutter_test, Riverpod test overrides, existing Freezed models without generated-file edits.

---

## File Structure

- Modify `lib/features/social/widgets/social_activity_verb.dart`
  - Responsibility: map social activity types to Portuguese display verbs and provide reusable formatting helpers for activity text.
  - Add `socialActivityListNameFor(ActivityEventModel event)`.
  - Add `socialActivityTextFor(ActivityEventModel event)` for one-line contexts such as Dashboard preview.
- Modify `lib/features/social/widgets/social_activity_card.dart`
  - Responsibility: render social activity cards with tappable user/media text.
  - For `ADDED_TO_LIST` with list name, render `adicionou` before media and `à lista <nome>` after media.
  - Keep fallback unchanged when list name is absent.
- Modify `lib/features/dashboard/pages/dashboard_page.dart`
  - Responsibility: render Dashboard social preview rows.
  - Replace inline string composition with `socialActivityTextFor(activity)`.
- Modify `test/features/social/widgets/social_activity_card_test.dart`
  - Responsibility: widget tests for card rendering and taps.
  - Add failing tests for list-name rendering and fallback.
- Modify `test/features/dashboard/pages/dashboard_page_test.dart`
  - Responsibility: widget tests for Dashboard social preview.
  - Add metadata support to `_activity` helper.
  - Add failing test for list-name rendering; keep existing fallback assertion.

## Task 1: SocialActivityCard list-name rendering

**Files:**
- Modify: `test/features/social/widgets/social_activity_card_test.dart`
- Modify: `lib/features/social/widgets/social_activity_verb.dart`
- Modify: `lib/features/social/widgets/social_activity_card.dart`

- [ ] **Step 1: Write failing widget tests for card list-name behavior**

In `test/features/social/widgets/social_activity_card_test.dart`, add this test after `renders all activity verbs and review metadata fallbacks`:

```dart
  testWidgets('ADDED_TO_LIST renders media followed by list name when present', (
    tester,
  ) async {
    await pumpCard(
      tester,
      event(
        type: 'ADDED_TO_LIST',
        metadata: const {'listName': 'Favoritos'},
      ),
    );

    expect(find.text('Fulano'), findsOneWidget);
    expect(find.text('adicionou'), findsOneWidget);
    expect(find.text('One Piece'), findsOneWidget);
    expect(find.text('à lista Favoritos'), findsOneWidget);
    expect(find.textContaining('adicionou à lista'), findsNothing);
  });

  testWidgets('ADDED_TO_LIST keeps current fallback without list name', (
    tester,
  ) async {
    await pumpCard(
      tester,
      event(type: 'ADDED_TO_LIST', metadata: const {'status': 'WANT_TO_WATCH'}),
    );

    expect(find.textContaining('adicionou à lista'), findsOneWidget);
    expect(find.text('One Piece'), findsOneWidget);
  });
```

- [ ] **Step 2: Run the card tests and verify RED**

Run:

```bash
flutter test test/features/social/widgets/social_activity_card_test.dart
```

Expected: FAIL. The first new test should fail because `adicionou` and `à lista Favoritos` are not rendered as separate text nodes yet.

- [ ] **Step 3: Add shared list-name helper**

In `lib/features/social/widgets/social_activity_verb.dart`, replace the file content with:

```dart
import '../data/models/activity_event_model.dart';

String socialActivityVerbFor(String type) {
  return switch (type.toUpperCase()) {
    'RATED' => 'avaliou',
    'REVIEWED' => 'escreveu uma review de',
    'COMPLETED' => 'completou',
    'STARTED_WATCHING' => 'começou',
    'DROPPED' => 'abandonou',
    'ADDED_TO_LIST' => 'adicionou à lista',
    _ => 'interagiu com',
  };
}

String? socialActivityListNameFor(ActivityEventModel event) {
  final raw = event.metadata['listName'] ?? event.metadata['list_name'];
  final value = raw?.toString().trim();
  if (value == null || value.isEmpty) {
    return null;
  }
  return value;
}

String socialActivityTextFor(ActivityEventModel event) {
  final listName = socialActivityListNameFor(event);
  if (event.activityType.toUpperCase() == 'ADDED_TO_LIST' &&
      listName != null) {
    return '${event.user.displayName} adicionou ${event.media.title} à lista $listName';
  }

  return '${event.user.displayName} ${socialActivityVerbFor(event.activityType)} ${event.media.title}';
}
```

- [ ] **Step 4: Update SocialActivityCard rendering minimally**

In `lib/features/social/widgets/social_activity_card.dart`, inside `build`, after the `review` local, add:

```dart
    final listName = socialActivityListNameFor(event);
    final showsNamedList =
        event.activityType.toUpperCase() == 'ADDED_TO_LIST' &&
        listName != null;
```

Then replace the existing verb `Text(...)` child:

```dart
                Text(socialActivityVerbFor(event.activityType)),
```

with:

```dart
                Text(
                  showsNamedList
                      ? 'adicionou'
                      : socialActivityVerbFor(event.activityType),
                ),
```

Then add this widget immediately after the media `InkWell` block in the same `Wrap` children list:

```dart
                if (showsNamedList) Text('à lista $listName'),
```

- [ ] **Step 5: Run the card tests and verify GREEN**

Run:

```bash
flutter test test/features/social/widgets/social_activity_card_test.dart
```

Expected: PASS.

- [ ] **Step 6: Commit Task 1**

Run:

```bash
git add lib/features/social/widgets/social_activity_verb.dart lib/features/social/widgets/social_activity_card.dart test/features/social/widgets/social_activity_card_test.dart
git commit -m "feat: show list name in social activity cards"
```

## Task 2: Dashboard social preview list-name rendering

**Files:**
- Modify: `test/features/dashboard/pages/dashboard_page_test.dart`
- Modify: `lib/features/dashboard/pages/dashboard_page.dart`

- [ ] **Step 1: Update the Dashboard test helper to allow metadata**

In `test/features/dashboard/pages/dashboard_page_test.dart`, change `_activity` from:

```dart
ActivityEventModel _activity(
  String id,
  String title, {
  String activityType = 'COMPLETED',
}) => ActivityEventModel(
  eventId: id,
  user: const SocialUserModel(userId: 'user-1', displayName: 'Fulano'),
  activityType: activityType,
  media: SocialMediaModel(mediaId: id, mediaType: 'SERIES', title: title),
  createdAt: DateTime.utc(2026, 5, 20),
);
```

To:

```dart
ActivityEventModel _activity(
  String id,
  String title, {
  String activityType = 'COMPLETED',
  Map<String, dynamic> metadata = const <String, dynamic>{},
}) => ActivityEventModel(
  eventId: id,
  user: const SocialUserModel(userId: 'user-1', displayName: 'Fulano'),
  activityType: activityType,
  media: SocialMediaModel(mediaId: id, mediaType: 'SERIES', title: title),
  metadata: metadata,
  createdAt: DateTime.utc(2026, 5, 20),
);
```

- [ ] **Step 2: Write failing Dashboard preview test**

In `test/features/dashboard/pages/dashboard_page_test.dart`, add this test after `social preview translates added to list activity rows`:

```dart
    testWidgets('social preview includes list name for added to list rows', (
      tester,
    ) async {
      final fakeVM = FakeDashboardVM(
        testState: AsyncValue.data(_emptyDashboard()),
      );
      final container = ProviderContainer(
        overrides: [
          dashboardViewModelProvider.overrideWith(() => fakeVM),
          socialFeedViewModelProvider.overrideWith(
            () => FakeSocialFeedVM(
              testState: AsyncValue.data(
                _feed([
                  _activity(
                    '1',
                    'Devoradores',
                    activityType: 'added_to_list',
                    metadata: const {'listName': 'Favoritos'},
                  ),
                ]),
              ),
            ),
          ),
          authViewModelProvider.overrideWith(() => FakeAuthVM()),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      expect(
        find.textContaining('Fulano adicionou Devoradores à lista Favoritos'),
        findsOneWidget,
      );
      expect(find.textContaining('Fulano adicionou à lista Devoradores'), findsNothing);
    });
```

- [ ] **Step 3: Run the Dashboard page tests and verify RED**

Run:

```bash
flutter test test/features/dashboard/pages/dashboard_page_test.dart
```

Expected: FAIL. The new test should fail because `_SocialActivityRow` still composes text with `socialActivityVerbFor(activity.activityType)` and ignores `metadata.listName`.

- [ ] **Step 4: Use the shared helper in Dashboard preview**

In `lib/features/dashboard/pages/dashboard_page.dart`, replace this string inside `_SocialActivityRow`:

```dart
              '${activity.user.displayName} ${socialActivityVerbFor(activity.activityType)} ${activity.media.title}',
```

with:

```dart
              socialActivityTextFor(activity),
```

The file already imports `social_activity_verb.dart`, so no new import is needed.

- [ ] **Step 5: Run the Dashboard tests and verify GREEN**

Run:

```bash
flutter test test/features/dashboard/pages/dashboard_page_test.dart
```

Expected: PASS.

- [ ] **Step 6: Re-run the card tests for regression safety**

Run:

```bash
flutter test test/features/social/widgets/social_activity_card_test.dart
```

Expected: PASS.

- [ ] **Step 7: Commit Task 2**

Run:

```bash
git add lib/features/dashboard/pages/dashboard_page.dart test/features/dashboard/pages/dashboard_page_test.dart
git commit -m "feat: show list name in dashboard activity preview"
```

## Task 3: Validation and WorkQ handoff note

**Files:**
- No production files expected.
- WorkQ CLI only for comment; do not mark the task done.

- [ ] **Step 1: Run LSP diagnostics on touched Dart files**

Run tool-equivalent diagnostics for these files:

```text
lib/features/social/widgets/social_activity_verb.dart
lib/features/social/widgets/social_activity_card.dart
lib/features/dashboard/pages/dashboard_page.dart
test/features/social/widgets/social_activity_card_test.dart
test/features/dashboard/pages/dashboard_page_test.dart
```

Expected: no errors.

- [ ] **Step 2: Run analyzer**

Run:

```bash
make analyze
```

Expected: command exits successfully.

- [ ] **Step 3: Run focused tests**

Run:

```bash
flutter test test/features/social/widgets/social_activity_card_test.dart test/features/dashboard/pages/dashboard_page_test.dart
```

Expected: all tests pass.

- [ ] **Step 4: Add a WorkQ comment with implementation summary**

Run:

```bash
workq comments add lorebase-frontend:task-000019 "Frontend now reads metadata.listName/list_name for ADDED_TO_LIST events, renders media + list name when present, and preserves the existing fallback when list metadata is absent. Backend task lorebase-backend:6 tracks emitting the metadata. Focused widget tests and analyzer were run."
```

Expected: comment added. Do not run `workq done` unless the human explicitly asks.

- [ ] **Step 5: Final git status check**

Run:

```bash
git status --short
```

Expected: clean or only intentional uncommitted files explicitly reported to the human.
