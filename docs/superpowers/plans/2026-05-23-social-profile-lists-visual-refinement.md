# Social Profile Lists Visual Refinement Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refine the Social profile Lists tab so the horizontal carousel has page padding, stronger section/page title hierarchy, and vertical 2:3 posters rather than square posters.

**Architecture:** Keep `PublicMediaListSection` as the only UI component to modify. Preserve the existing horizontal carousel and repository payload normalization. Adjust constants/layout so card dimensions reserve a fixed poster area and text area instead of using `Expanded` to squeeze posters.

**Tech Stack:** Flutter widgets, Dart, Flutter widget tests.

---

## Files

- Modify: `lib/features/social/widgets/public_media_list_section.dart`
  - Responsibility: visual spacing, typography, card/poster sizing.
- Modify: `test/features/social/widgets/public_media_list_section_test.dart`
  - Responsibility: cover page padding/section hierarchy and 2:3 poster shape.

Do not edit generated files or `.tasks`.

---

### Task 1: Refine Lists tab spacing, headings, and poster aspect

**Files:**
- Modify: `test/features/social/widgets/public_media_list_section_test.dart`
- Modify: `lib/features/social/widgets/public_media_list_section.dart`

- [ ] **Step 1: Add widget test for padded content and vertical poster shape**

In `test/features/social/widgets/public_media_list_section_test.dart`, add this test after `renders public media cards with bordered aligned layout`:

```dart
  testWidgets('uses padded content and vertical poster cards', (tester) async {
    await pumpSection(
      tester,
      items: [
        item(status: 'WATCHING', title: 'The Middle'),
      ],
    );

    final listView = tester.widget<ListView>(find.byType(ListView).first);
    expect(listView.padding, const EdgeInsets.fromLTRB(16, 12, 16, 24));

    final pageTitle = tester.widget<Text>(find.text('Favoritos'));
    expect(pageTitle.style?.fontWeight, FontWeight.w700);

    final sectionTitle = tester.widget<Text>(find.text('Assistindo'));
    expect(sectionTitle.style?.fontWeight, FontWeight.w700);

    final posterSizedBox = tester.widget<SizedBox>(
      find.ancestor(
        of: find.byIcon(Icons.movie),
        matching: find.byWidgetPredicate(
          (widget) => widget is SizedBox && widget.width == 124,
        ),
      ),
    );

    expect(posterSizedBox.height, 186);
  });
```

- [ ] **Step 2: Run the new test and verify it fails**

```bash
cd /home/sanmoo/dev/github.com/lorebase/lorebase-frontend/.worktrees/task-000008-social-lists
flutter test test/features/social/widgets/public_media_list_section_test.dart --plain-name 'uses padded content and vertical poster cards'
```

Expected: FAIL because the current outer list has zero padding, headings are not bold enough, and poster height is not fixed to 2:3.

- [ ] **Step 3: Implement visual refinement**

In `lib/features/social/widgets/public_media_list_section.dart`:

1. Add sizing constants near existing constants:

```dart
  static const double _cardWidth = 124;
  static const double _posterHeight = 186;
  static const double _textAreaHeight = 64;
  static const double _cardPadding = 8;
```

2. Change carousel height calculation to preserve poster shape and text scale:

```dart
    final carouselHeight = _posterHeight +
        textScaler.scale(_textAreaHeight) +
        (_cardPadding * 2);
```

3. Change outer `ListView` padding:

```dart
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
```

4. Make the page title more prominent:

```dart
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
```

5. Make section titles more prominent and spaced:

```dart
                padding: const EdgeInsets.only(top: 16, bottom: 10),
                child: Text(
                  _statusLabel(entry.key),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
```

6. In `_PublicMediaCard`, replace `Expanded(child: _Poster(item: item))` with:

```dart
                  SizedBox(
                    width: double.infinity,
                    height: PublicMediaListSection._posterHeight,
                    child: _Poster(item: item),
                  ),
```

7. Replace padding literal with constant:

```dart
              padding: const EdgeInsets.all(PublicMediaListSection._cardPadding),
```

- [ ] **Step 4: Run focused visual test and full widget test file**

```bash
flutter test test/features/social/widgets/public_media_list_section_test.dart --plain-name 'uses padded content and vertical poster cards'
flutter test test/features/social/widgets/public_media_list_section_test.dart
```

Expected: both pass.

- [ ] **Step 5: Run LSP diagnostics**

Use `lsp_diagnostics` for:

```text
lib/features/social/widgets/public_media_list_section.dart
test/features/social/widgets/public_media_list_section_test.dart
```

Expected: no diagnostics.

- [ ] **Step 6: Commit visual refinement**

```bash
git add lib/features/social/widgets/public_media_list_section.dart test/features/social/widgets/public_media_list_section_test.dart
git commit -m "style: refine social list carousel layout"
```

---

### Task 2: Final verification

**Files:**
- Verify only.

- [ ] **Step 1: Run focused Social tests**

```bash
cd /home/sanmoo/dev/github.com/lorebase/lorebase-frontend/.worktrees/task-000008-social-lists
flutter test test/features/social/data/social_repository_test.dart test/features/social/widgets/public_media_list_section_test.dart
```

Expected: all pass.

- [ ] **Step 2: Run analyzer**

```bash
make analyze
```

Expected: `No issues found!`

- [ ] **Step 3: Run full tests**

```bash
flutter test
```

Expected: all pass.

- [ ] **Step 4: Report status without marking WorkQ done**

Report commits and verification. Do not run `workq done` unless explicitly requested.
