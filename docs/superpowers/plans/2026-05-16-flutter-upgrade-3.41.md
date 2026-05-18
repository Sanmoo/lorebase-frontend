# Flutter 3.27 → 3.41 Upgrade + Backdrop Glitch Fix — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Upgrade Flutter from 3.27 to 3.41.8 (latest stable as of May 2026) to get Impeller rendering fixes that should resolve the Android backdrop image glitch. Clean up any workaround code afterwards.

**Architecture:** Flutter 3.41 includes Impeller fixes for image rendering corruption on Android (issues #159935, #161283, #179872). The upgrade also brings Dart 3.10.x (from 3.3.0), Material 3 token updates, and several deprecations. Key risk areas: codegen packages (freezed, json_serializable, riverpod_generator), amplify_flutter compatibility, golden test rendering changes.

**Tech Stack:** mise (Flutter version manager), Flutter 3.41.8, Dart 3.10.x, build_runner, existing packages updated as needed.

---

### Pre-check: Verify mise supports the target Flutter version

- [ ] **Step 1: Check available Flutter versions in mise**

```bash
mise ls-remote flutter | grep "^3.41"
```

Expected: Shows `3.41.8` or similar 3.41.x versions.

---

### Task 1: Update Flutter to 3.41.8

- [ ] **Step 1: Update mise Flutter version**

```bash
cd /home/sanmoo/dev/github.com/lorebase/lorebase-frontend
mise use flutter@3.41.8
```

Or edit `.mise.toml` / `.tool-versions` if they exist.

- [ ] **Step 2: Verify Flutter version**

```bash
flutter --version
```

Expected: Flutter 3.41.8, Dart 3.10.x.

- [ ] **Step 3: Run flutter doctor**

```bash
flutter doctor
```

Expected: All checks pass (Android toolchain, etc.). If issues, fix before proceeding.

---

### Task 2: Update project configuration

- [ ] **Step 1: Update SDK constraint in pubspec.yaml**

Change:
```yaml
environment:
  sdk: ">=3.3.0 <4.0.0"
```
To:
```yaml
environment:
  sdk: ">=3.10.0 <4.0.0"
```

Also bump `flutter_lints` if needed (currently ^3.0.1).

- [ ] **Step 2: Update dependency versions for Dart 3.10 compatibility**

Run `flutter pub outdated` to identify packages that need updating. Key packages to check:

| Package | Current | Likely Action |
|---------|---------|---------------|
| flutter_riverpod ^2.5.0 | May need ^2.6+ | Update |
| riverpod_annotation ^2.3.0 | May need ^2.6+ | Update |
| riverpod_generator ^2.3.0 | May need ^2.6+ | Update |
| go_router ^13.0.0 | Likely compatible | Verify |
| freezed ^2.4.0 / freezed_annotation ^2.4.0 | May need ^3.0 | Update |
| json_serializable ^6.7.0 | Likely compatible | Verify |
| amplify_flutter ^1.6.0 | Risk area | Check compatibility |
| cached_network_image ^3.3.0 | Likely compatible | Verify |
| slang ^4.0.0 / slang_build_runner 4.11.0 | May need update | Update |
| mockito ^5.4.0 | May need update | Update |
| alchemist ^0.11.0 | Risk area | Check compatibility |
| flutter_dotenv ^5.1.0 | Likely compatible | Verify |
| shimmer ^3.0.0 | Likely compatible | Verify |
| build_runner ^2.4.0 | May need ^2.5+ | Update |

```bash
flutter pub outdated
```

- [ ] **Step 3: Update pubspec.yaml with new versions**

Based on `pub outdated` output, update version constraints. Run:
```bash
flutter pub upgrade
```

- [ ] **Step 4: Verify pub get succeeds**

```bash
flutter pub get
```

Expected: No resolution errors. If resolution fails, identify the conflicting package and either update its constraint or replace it.

- [ ] **Step 5: Commit pubspec changes**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore: upgrade Flutter to 3.41.8, update dependencies"
```

---

### Task 3: Run code generation

- [ ] **Step 1: Run build_runner**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: Build succeeds. If errors, fix them (see Task 4).

- [ ] **Step 2: Commit generated files**

```bash
git add .
git commit -m "chore: regenerate codegen files for Flutter 3.41.8"
```

---

### Task 4: Fix compilation errors and deprecation warnings

- [ ] **Step 1: Run dart analyze**

```bash
dart analyze --fatal-infos 2>&1
```

Expected: May have errors from:
- Material 3 token updates (4 color roles changed mapping)
- Deprecation: `containsSemantics` → `isSemantics`
- Deprecation: `findChildIndexCallback` → `findItemIndexCallback`
- Deprecation: `withOpacity` → `withValues()` (may already exist)
- Any API changes in updated packages

- [ ] **Step 2: Fix errors and warnings**

For Material 3 token color changes, if any visual tests fail, verify the color differences are acceptable. For deprecations, apply the recommended replacements.

- [ ] **Step 3: Run dart analyze again to verify clean**

```bash
make analyze
```

Expected: Exit 0 (may have pre-existing info-level issues).

- [ ] **Step 4: Commit fixes**

```bash
git add -A
git commit -m "fix: resolve compilation errors and deprecations for Flutter 3.41.8"
```

---

### Task 5: Run full test suite and coverage

- [ ] **Step 1: Run all tests**

```bash
flutter test
```

Expected: All tests pass. Golden tests may fail due to Material 3 token color changes — if so, regenerate goldens.

- [ ] **Step 2: If golden tests fail, regenerate**

```bash
flutter test test/visual/ --update-goldens
```

Then verify only expected files changed:
```bash
git diff --stat test/visual/
```

- [ ] **Step 3: Run coverage check**

```bash
make check
```

Expected: 100% line coverage, 100% branch coverage.

- [ ] **Step 4: Commit any golden updates**

```bash
git add test/visual/
git commit -m "test: update golden files for Flutter 3.41.8 Material 3 token changes"
```

---

### Task 6: Test on Android device

- [ ] **Step 1: Build and run on Android**

```bash
flutter run -d <android-device-id>
```

- [ ] **Step 2: Verify backdrop glitch is fixed**

Navigate to a movie detail page and series detail page. Check the top-left corner of the backdrop image for any pixel corruption.

- [ ] **Step 3: Report results**

If glitch is fixed: proceed to Task 7 (cleanup).
If glitch persists: investigate further (may need Impeller-specific configuration in AndroidManifest).

---

### Task 7: Clean up backdrop workaround code

Only proceed if Task 6 confirms the glitch is fixed.

- [ ] **Step 1: Remove ClipRect wrapper, use plain CachedNetworkImage**

Current (workaround):
```dart
Positioned.fill(
  child: ClipRect(
    key: const ValueKey('backdrop_clip'),
    child: CachedNetworkImage(
      imageUrl: ...,
      imageRenderMethodForWeb: ImageRenderMethodForWeb.HttpGet,
      height: 250,
      fit: BoxFit.fitHeight,
      alignment: Alignment.bottomCenter,
      errorWidget: ...,
    ),
  ),
)
```

Clean version:
```dart
Positioned.fill(
  child: CachedNetworkImage(
    imageUrl: ...,
    imageRenderMethodForWeb: ImageRenderMethodForWeb.HttpGet,
    fit: BoxFit.cover,
    errorWidget: ...,
  ),
)
```

Apply to both `movie_detail_page.dart` and `series_detail_page.dart`.

- [ ] **Step 2: Run tests**

```bash
flutter test test/features/movies/pages/movie_detail_page_test.dart test/features/series/pages/series_detail_page_test.dart
```

Expected: All tests pass (note: test names may reference `ClipRRect`/`backdrop_clip` key which will be removed — update test names if needed).

- [ ] **Step 3: Commit cleanup**

```bash
git add lib/features/movies/pages/movie_detail_page.dart lib/features/series/pages/series_detail_page.dart
git commit -m "refactor: remove backdrop workaround code, use plain BoxFit.cover"
```

---

### Task 8: Verify full quality gate

- [ ] **Step 1: Run make check**

```bash
make check
```

Expected: All tests pass, 100% coverage.

- [ ] **Step 2: Run dart analyze**

```bash
make analyze
```

Expected: Exit 0.

---

### Rollback Plan

If the upgrade causes unresolvable issues:
```bash
mise use flutter@3.27.4
git checkout pubspec.yaml pubspec.lock
flutter pub get
```
