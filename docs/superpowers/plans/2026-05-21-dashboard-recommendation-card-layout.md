# Dashboard Recommendation Card Layout Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the dashboard recommendation CTA card match the social activity card layout so its text uses the full card width.

**Architecture:** This is a focused widget layout change in `DashboardPage`. The private `_RecommendationCard` keeps the same callback API and navigation behavior, but changes its internal composition from `ListTile` to `Card > InkWell > Padding > Column`, mirroring `_SocialPreviewSection`.

**Tech Stack:** Flutter 3.27, Dart, flutter_test, GoRouter, Riverpod, Slang localization.

---

## File Structure

- Modify: `lib/features/dashboard/pages/dashboard_page.dart`
  - Responsibility: dashboard screen and private dashboard-only cards/sections.
  - Change: replace `_RecommendationCard`'s `ListTile` layout with a social-preview-like column layout.
- Modify: `test/features/dashboard/pages/dashboard_page_test.dart`
  - Responsibility: widget tests for dashboard page behavior.
  - Change: add tests proving the recommendation card renders its content and keeps CTA/card tap navigation.

---

### Task 1: Add failing recommendation card layout/navigation tests

**Files:**
- Modify: `test/features/dashboard/pages/dashboard_page_test.dart`

- [ ] **Step 1: Add the failing tests**

Add these tests inside the existing `group('DashboardPage', () { ... })`, near the existing recommendation test:

```dart
    testWidgets('recommendation card renders social-style content', (
      tester,
    ) async {
      final fakeVM = FakeDashboardVM(
        testState: AsyncValue.data(_emptyDashboard()),
      );
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      await tester.drag(find.byType(Scrollable), const Offset(0, -500));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.auto_awesome_outlined), findsOneWidget);
      expect(find.text('Recommendations for you'), findsOneWidget);
      expect(
        find.text('Find something tailored to watch next.'),
        findsOneWidget,
      );
      expect(find.text('Get recommendations'), findsOneWidget);
    });

    testWidgets('tapping recommendation card surface navigates to recommend', (
      tester,
    ) async {
      final fakeVM = FakeDashboardVM(
        testState: AsyncValue.data(_emptyDashboard()),
      );
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      await tester.drag(find.byType(Scrollable), const Offset(0, -500));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Recommendations for you'));
      await tester.pumpAndSettle();

      expect(find.text('Recommend page'), findsOneWidget);
    });
```

Keep the existing test `recommendation content is reachable from dashboard`; it covers CTA button navigation.

- [ ] **Step 2: Run tests to verify RED**

Run:

```bash
flutter test test/features/dashboard/pages/dashboard_page_test.dart --plain-name "recommendation card renders social-style content"
flutter test test/features/dashboard/pages/dashboard_page_test.dart --plain-name "tapping recommendation card surface navigates to recommend"
```

Expected:

- The first test fails because the current card does not expose the new social-style structure reliably under the current layout expectations.
- The second test fails because tapping the title area in the old `ListTile` layout may be constrained differently than the desired full card surface behavior.

If either test passes immediately, continue only after confirming it still protects the desired behavior. Add a stricter assertion if needed, such as verifying there is no `ListTile` ancestor for the recommendation title:

```dart
      final titleContext = tester.element(find.text('Recommendations for you'));
      expect(
        find.ancestor(
          of: find.byWidgetPredicate((widget) => widget is Text &&
              widget.data == 'Recommendations for you'),
          matching: find.byType(ListTile),
        ),
        findsNothing,
      );
```

---

### Task 2: Implement the social-style recommendation card

**Files:**
- Modify: `lib/features/dashboard/pages/dashboard_page.dart`

- [ ] **Step 1: Replace `_RecommendationCard.build` internals**

Replace the current `_RecommendationCard` `return Padding(...)` block with this code:

```dart
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome_outlined),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        t.dashboard_recommendation_title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  t.dashboard_recommendation_body,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: onTap,
                    child: Text(t.dashboard_recommendation_cta),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
```

The resulting `_RecommendationCard` should be:

```dart
class _RecommendationCard extends StatelessWidget {
  final VoidCallback onTap;

  const _RecommendationCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.t;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome_outlined),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        t.dashboard_recommendation_title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  t.dashboard_recommendation_body,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: onTap,
                    child: Text(t.dashboard_recommendation_cta),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Run targeted tests to verify GREEN**

Run:

```bash
flutter test test/features/dashboard/pages/dashboard_page_test.dart --plain-name "recommendation card renders social-style content"
flutter test test/features/dashboard/pages/dashboard_page_test.dart --plain-name "tapping recommendation card surface navigates to recommend"
flutter test test/features/dashboard/pages/dashboard_page_test.dart --plain-name "recommendation content is reachable from dashboard"
```

Expected: all three tests pass.

---

### Task 3: Validate and commit

**Files:**
- Check: `lib/features/dashboard/pages/dashboard_page.dart`
- Check: `test/features/dashboard/pages/dashboard_page_test.dart`

- [ ] **Step 1: Run LSP diagnostics**

Run:

```bash
# Use the harness LSP diagnostics tool for these files:
# lib/features/dashboard/pages/dashboard_page.dart
# test/features/dashboard/pages/dashboard_page_test.dart
```

Expected: no errors for the touched files.

- [ ] **Step 2: Run the dashboard test file**

Run:

```bash
flutter test test/features/dashboard/pages/dashboard_page_test.dart
```

Expected: all tests in the file pass.

- [ ] **Step 3: Run analyzer wrapper**

Run:

```bash
make analyze
```

Expected: analyzer completes successfully according to project wrapper behavior.

- [ ] **Step 4: Commit implementation**

Run:

```bash
git add lib/features/dashboard/pages/dashboard_page.dart test/features/dashboard/pages/dashboard_page_test.dart
git commit -m "fix: align recommendation card layout"
```

Expected: commit succeeds and includes only the implementation/test changes.

---

## Self-Review

- Spec coverage: The plan changes only `_RecommendationCard`, preserves `/recommend` navigation, mirrors `_SocialPreviewSection`, and adds widget coverage for rendering and taps.
- Placeholder scan: No TBD/TODO placeholders remain.
- Type consistency: All referenced classes and strings already exist in `dashboard_page_test.dart` and localization is set to `enUs` in the test file.
