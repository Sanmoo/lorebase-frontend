# Profile Activity Actor Label Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make profile Activity cards show `Você` on my own profile and the profile display name on another user's profile.

**Architecture:** Keep `SocialActivityCard` reusable by adding an optional actor label override. Use the profile page context to pass the correct label only for profile Activity tabs, leaving the Social feed unchanged.

**Tech Stack:** Flutter 3.27, Dart, flutter_test, GoRouter, Riverpod.

---

## File Structure

- Modify `lib/features/social/widgets/social_activity_card.dart`
  - Add optional `actorLabel` parameter and use it for displayed actor text.
- Modify `lib/features/social/pages/social_profile_page.dart`
  - Pass `isMe` into `_ActivityTab` and compute the profile-specific actor label.
- Modify `test/features/social/widgets/social_activity_card_test.dart`
  - Add focused widget coverage for actor label override.
- Modify `test/features/social/pages/social_pages_test.dart`
  - Add/adjust profile page coverage for own profile and other profile actor labels.

---

### Task 1: Add actor label override to activity card

**Files:**
- Modify: `test/features/social/widgets/social_activity_card_test.dart`
- Modify: `lib/features/social/widgets/social_activity_card.dart`

- [ ] **Step 1: Write failing widget test**

In `test/features/social/widgets/social_activity_card_test.dart`, update `pumpCard` signature to accept `String? actorLabel` and pass it to `SocialActivityCard`:

```dart
Future<void> pumpCard(
  WidgetTester tester,
  ActivityEventModel event, {
  String? actorLabel,
  VoidCallback? onUserTap,
  VoidCallback? onMediaTap,
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SocialActivityCard(
          event: event,
          actorLabel: actorLabel,
          onUserTap: onUserTap ?? () {},
          onMediaTap: onMediaTap ?? () {},
        ),
      ),
    ),
  );
}
```

Add this test after `RATED renders "avaliou" and rating`:

```dart
testWidgets('actorLabel overrides displayed actor name', (tester) async {
  await pumpCard(tester, event(), actorLabel: 'Você');

  expect(find.text('Você'), findsOneWidget);
  expect(find.text('Fulano'), findsNothing);
  expect(find.textContaining('avaliou'), findsOneWidget);
  expect(find.text('One Piece'), findsOneWidget);
});
```

- [ ] **Step 2: Run test and verify RED**

Run:

```bash
flutter test test/features/social/widgets/social_activity_card_test.dart
```

Expected: FAIL because `SocialActivityCard` has no `actorLabel` parameter yet.

- [ ] **Step 3: Implement minimal widget change**

In `lib/features/social/widgets/social_activity_card.dart`, update constructor and fields:

```dart
const SocialActivityCard({
  super.key,
  required this.event,
  this.actorLabel,
  required this.onUserTap,
  required this.onMediaTap,
});

final ActivityEventModel event;
final String? actorLabel;
final VoidCallback onUserTap;
final VoidCallback onMediaTap;
```

In `build`, add after `showsNamedList`:

```dart
final displayedActor = actorLabel ?? event.user.displayName;
```

Replace:

```dart
event.user.displayName,
```

with:

```dart
displayedActor,
```

- [ ] **Step 4: Run test and verify GREEN**

Run:

```bash
flutter test test/features/social/widgets/social_activity_card_test.dart
```

Expected: PASS.

---

### Task 2: Use profile context actor label in profile Activity tab

**Files:**
- Modify: `test/features/social/pages/social_pages_test.dart`
- Modify: `lib/features/social/pages/social_profile_page.dart`

- [ ] **Step 1: Add own-profile page expectation**

In `test/features/social/pages/social_pages_test.dart`, in `Profile edit and activity cards navigate`, after `await tester.pumpAndSettle();`, add:

```dart
expect(find.text('Você'), findsOneWidget);
expect(find.text('Fulano'), findsOneWidget);
```

This test should continue finding `Fulano` in the profile header/edit button context, but the activity actor should be `Você`.

- [ ] **Step 2: Add other-profile page test**

Add this test near `Profile edit and activity cards navigate`:

```dart
testWidgets('Other profile activity cards use profile display name', (
  tester,
) async {
  final router = _router(
    const SocialProfilePage(userId: 'other-user'),
    _FakeSocialRepository(
      profile: _profile(userId: 'other-user', displayName: 'Maria Social'),
      activityItems: [_event(mediaType: 'MOVIE')],
    ),
  );

  await tester.pumpRouter(router);
  await tester.pumpAndSettle();

  expect(find.text('Maria Social'), findsWidgets);
  expect(find.text('Você'), findsNothing);
});
```

- [ ] **Step 3: Run page test and verify RED**

Run:

```bash
flutter test test/features/social/pages/social_pages_test.dart
```

Expected: FAIL because `_ActivityTab` still uses the activity event user display name.

- [ ] **Step 4: Pass `isMe` into `_ActivityTab`**

In `lib/features/social/pages/social_profile_page.dart`, change the TabBarView activity child from:

```dart
_ActivityTab(state: state),
```

to:

```dart
_ActivityTab(state: state, isMe: isMe),
```

Update `_ActivityTab` constructor and fields:

```dart
class _ActivityTab extends StatelessWidget {
  const _ActivityTab({required this.state, required this.isMe});

  final SocialProfileDetailState state;
  final bool isMe;
```

- [ ] **Step 5: Pass actor label to activity cards**

Inside `_ActivityTab.build`, before `return ListView.builder`, add:

```dart
final actorLabel = isMe ? 'Você' : state.profile.displayName;
```

Inside `SocialActivityCard`, add:

```dart
actorLabel: actorLabel,
```

so the card creation becomes:

```dart
return SocialActivityCard(
  event: event,
  actorLabel: actorLabel,
  onUserTap: () => context.go('/social/profile/${event.user.userId}'),
  onMediaTap: () => context.go(
    event.media.mediaType == 'SERIES'
        ? '/series/${event.media.mediaId}'
        : '/movies/${event.media.mediaId}',
  ),
);
```

- [ ] **Step 6: Run page test and verify GREEN**

Run:

```bash
flutter test test/features/social/pages/social_pages_test.dart
```

Expected: PASS.

---

### Task 3: Final verification and commit

**Files:**
- Commit all modified files from Tasks 1-2.

- [ ] **Step 1: Run focused tests**

Run:

```bash
flutter test test/features/social/widgets/social_activity_card_test.dart test/features/social/pages/social_pages_test.dart
```

Expected: PASS.

- [ ] **Step 2: Run broader focused social tests**

Run:

```bash
flutter test test/features/social/data/social_repository_test.dart test/features/social/viewmodels/social_profile_viewmodel_test.dart test/features/social/widgets/social_activity_card_test.dart test/features/social/pages/social_pages_test.dart
```

Expected: PASS.

- [ ] **Step 3: Run analyzer**

Run:

```bash
make analyze
```

Expected: PASS, `No issues found!`.

- [ ] **Step 4: Commit**

Run:

```bash
git add lib/features/social/widgets/social_activity_card.dart lib/features/social/pages/social_profile_page.dart test/features/social/widgets/social_activity_card_test.dart test/features/social/pages/social_pages_test.dart docs/superpowers/specs/2026-05-30-profile-activity-actor-label-design.md docs/superpowers/plans/2026-05-30-profile-activity-actor-label.md
git commit -m "fix: label profile activity actors"
```

- [ ] **Step 5: Add WorkQ progress comment**

Run:

```bash
workq comments add lorebase-frontend:task-000022 "Adjusted profile Activity actor labels: own profile now shows Você, other profiles show the profile display name; Social feed remains unchanged. Verification: <actual command results>."
```

Do not mark the WorkQ task done.
