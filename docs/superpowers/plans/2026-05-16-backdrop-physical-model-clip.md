# Backdrop PhysicalModel Clip Fix — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace `ClipRRect` with `PhysicalModel` on backdrop images to fix Android Skia glitch with only 24px overflow (instead of 48px), eliminating excessive vertical crop.

**Architecture:** In both detail pages, the backdrop's `ClipRRect(borderRadius: topLeft 1px)` + `SizedBox.expand` wrapper is replaced with a single `PhysicalModel(color: Colors.transparent, clipBehavior: Clip.hardEdge)`. Overflow reduced from 298px → 274px. `PhysicalModel` creates a GPU composition layer whose clip is performed by the platform compositor (HWUI on Android), bypassing the Skia canvas clip that fails on Android.

**Tech Stack:** Flutter widget tree only — no new dependencies.

---

### Task 1: Set up isolated worktree

- [ ] **Step 1: Create worktree and branch**

```bash
cd /home/sanmoo/dev/github.com/lorebase/lorebase-frontend
git worktree add -b fix/backdrop-physical-model .worktrees/fix/backdrop-physical-model
```

Expected: New worktree at `.worktrees/fix/backdrop-physical-model` on branch `fix/backdrop-physical-model`.

- [ ] **Step 2: Verify worktree is clean and on correct branch**

```bash
git -C .worktrees/fix/backdrop-physical-model branch --show-current
```

Expected: `fix/backdrop-physical-model`

---

### Task 2: Modify movie detail page backdrop

**Files:**
- Modify: `.worktrees/fix/backdrop-physical-model/lib/features/movies/pages/movie_detail_page.dart` (backdrop section)

- [ ] **Step 1: Replace ClipRRect + SizedBox.expand with PhysicalModel, reduce 298→274**

Find the backdrop code block (inside `if (hasBackdrop) Positioned.fill(...)`) and replace:

```dart
// BEFORE (current):
                  if (hasBackdrop)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(1),
                        ),
                        key: const ValueKey('backdrop_clip'),
                        child: SizedBox.expand(
                          child: OverflowBox(
                            minWidth: MediaQuery.of(context).size.width,
                            maxWidth: MediaQuery.of(context).size.width,
                            minHeight: 298,
                            maxHeight: 298,
                            alignment: Alignment.bottomCenter,
                            child: CachedNetworkImage(
                              imageUrl: movie.backdropPath!,
                              imageRenderMethodForWeb:
                                  ImageRenderMethodForWeb.HttpGet,
                              width: MediaQuery.of(context).size.width,
                              height: 298,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => Container(
                                color: theme.colorScheme.surfaceContainerHighest,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )

// AFTER:
                  if (hasBackdrop)
                    Positioned.fill(
                      child: PhysicalModel(
                        color: Colors.transparent,
                        clipBehavior: Clip.hardEdge,
                        key: const ValueKey('backdrop_clip'),
                        child: OverflowBox(
                          minWidth: MediaQuery.of(context).size.width,
                          maxWidth: MediaQuery.of(context).size.width,
                          minHeight: 274,
                          maxHeight: 274,
                          alignment: Alignment.bottomCenter,
                          child: CachedNetworkImage(
                            imageUrl: movie.backdropPath!,
                            imageRenderMethodForWeb:
                                ImageRenderMethodForWeb.HttpGet,
                            width: MediaQuery.of(context).size.width,
                            height: 274,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Container(
                              color: theme.colorScheme.surfaceContainerHighest,
                            ),
                          ),
                        ),
                      ),
                    )
```

Changes:
1. `ClipRRect(borderRadius: ..., key: ...)` → `PhysicalModel(color: Colors.transparent, clipBehavior: Clip.hardEdge, key: ...)`
2. Remove `SizedBox.expand` wrapper
3. `298` → `274` (in 4 places: minHeight, maxHeight, CachedNetworkImage height ×2)

- [ ] **Step 2: Format**

```bash
cd .worktrees/fix/backdrop-physical-model
dart format lib/features/movies/pages/movie_detail_page.dart
```

Expected: File formatted, 0 changes or minor formatting.

- [ ] **Step 3: Run movie detail page tests**

```bash
cd .worktrees/fix/backdrop-physical-model
flutter test test/features/movies/pages/movie_detail_page_test.dart
```

Expected: 7/7 All tests passed.

- [ ] **Step 4: Commit**

```bash
cd .worktrees/fix/backdrop-physical-model
git add lib/features/movies/pages/movie_detail_page.dart
git commit -m "fix(movies): replace ClipRRect with PhysicalModel on backdrop"
```

---

### Task 3: Modify series detail page backdrop

**Files:**
- Modify: `.worktrees/fix/backdrop-physical-model/lib/features/series/pages/series_detail_page.dart` (backdrop section)

- [ ] **Step 1: Replace ClipRRect + SizedBox.expand with PhysicalModel, reduce 298→274**

Find the backdrop code block (inside `if (hasBackdrop) Positioned.fill(...)`) and replace — same pattern as Task 2 but uses `series.backdropPath!` instead of `movie.backdropPath!`:

```dart
// BEFORE (current):
                  if (hasBackdrop)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(1),
                        ),
                        key: const ValueKey('backdrop_clip'),
                        child: SizedBox.expand(
                          child: OverflowBox(
                            minWidth: MediaQuery.of(context).size.width,
                            maxWidth: MediaQuery.of(context).size.width,
                            minHeight: 298,
                            maxHeight: 298,
                            alignment: Alignment.bottomCenter,
                            child: CachedNetworkImage(
                              imageUrl: series.backdropPath!,
                              imageRenderMethodForWeb:
                                  ImageRenderMethodForWeb.HttpGet,
                              width: MediaQuery.of(context).size.width,
                              height: 298,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => Container(
                                color: theme.colorScheme.surfaceContainerHighest,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )

// AFTER:
                  if (hasBackdrop)
                    Positioned.fill(
                      child: PhysicalModel(
                        color: Colors.transparent,
                        clipBehavior: Clip.hardEdge,
                        key: const ValueKey('backdrop_clip'),
                        child: OverflowBox(
                          minWidth: MediaQuery.of(context).size.width,
                          maxWidth: MediaQuery.of(context).size.width,
                          minHeight: 274,
                          maxHeight: 274,
                          alignment: Alignment.bottomCenter,
                          child: CachedNetworkImage(
                            imageUrl: series.backdropPath!,
                            imageRenderMethodForWeb:
                                ImageRenderMethodForWeb.HttpGet,
                            width: MediaQuery.of(context).size.width,
                            height: 274,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Container(
                              color: theme.colorScheme.surfaceContainerHighest,
                            ),
                          ),
                        ),
                      ),
                    )
```

- [ ] **Step 2: Format**

```bash
cd .worktrees/fix/backdrop-physical-model
dart format lib/features/series/pages/series_detail_page.dart
```

Expected: File formatted.

- [ ] **Step 3: Run series detail page tests**

```bash
cd .worktrees/fix/backdrop-physical-model
flutter test test/features/series/pages/series_detail_page_test.dart
```

Expected: 29/29 All tests passed.

- [ ] **Step 4: Commit**

```bash
cd .worktrees/fix/backdrop-physical-model
git add lib/features/series/pages/series_detail_page.dart
git commit -m "fix(series): replace ClipRRect with PhysicalModel on backdrop"
```

---

### Task 4: Run golden tests and verify no regressions

- [ ] **Step 1: Run golden tests**

```bash
cd .worktrees/fix/backdrop-physical-model
flutter test test/visual/
```

Expected: 16/16 All tests passed. If golden diffs appear for movie or series detail pages, the 24px→48px overflow reduction may have caused a visible difference.

- [ ] **Step 2: If golden diffs, regenerate goldens**

```bash
cd .worktrees/fix/backdrop-physical-model
flutter test test/visual/ --update-goldens
```

Then verify only the expected goldens changed:
```bash
git diff --stat
```

Expected: Only movie/series detail page goldens changed (max 2 files).

- [ ] **Step 3: Commit golden updates (if any)**

```bash
cd .worktrees/fix/backdrop-physical-model
git add test/visual/
git commit -m "test: update goldens for backdrop PhysicalModel change"
```

---

### Task 5: Full quality gate

- [ ] **Step 1: Run full test suite**

```bash
cd .worktrees/fix/backdrop-physical-model
flutter test
```

Expected: All 538+ tests pass (may have known flaky test in combined run of movie+series detail page tests).

- [ ] **Step 2: Run dart analyze**

```bash
cd .worktrees/fix/backdrop-physical-model
dart analyze --fatal-infos
```

Expected: No issues found.

- [ ] **Step 3: Run coverage check**

```bash
cd .worktrees/fix/backdrop-physical-model
make check
```

Expected: 100% line coverage, 100% branch coverage.

---

### Task 6: Rebase and merge

- [ ] **Step 1: Rebase onto origin/main**

```bash
cd .worktrees/fix/backdrop-physical-model
git fetch origin main
git rebase origin/main
```

Expected: Rebase succeeds without conflicts.

- [ ] **Step 2: Run tests after rebase**

```bash
cd .worktrees/fix/backdrop-physical-model
flutter test test/features/movies/pages/movie_detail_page_test.dart test/features/series/pages/series_detail_page_test.dart
```

Expected: 36/36 All tests passed (isolated runs pass; combined may have known flaky).

- [ ] **Step 3: Merge to main**

```bash
cd /home/sanmoo/dev/github.com/lorebase/lorebase-frontend
git checkout main
git merge fix/backdrop-physical-model
```

Expected: Fast-forward merge.

- [ ] **Step 4: Cleanup worktree and branch**

```bash
cd /home/sanmoo/dev/github.com/lorebase/lorebase-frontend
git worktree remove .worktrees/fix/backdrop-physical-model
git worktree prune
git branch -d fix/backdrop-physical-model
```

Expected: Worktree removed, branch deleted.
