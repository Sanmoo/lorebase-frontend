# Lint & Code Quality Setup Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Enable `--fatal-infos` on `dart analyze`, configure `custom_lint` + `riverpod_lint`, and fix all existing info-level lint issues.

**Architecture:** Add `custom_lint` as a direct dev dependency (already transitive via `riverpod_lint`), register the `custom_lint` plugin in `analysis_options.yaml`, add `--fatal-infos` to the `make analyze` command, and fix the 92 `prefer_const_constructors` infos using `dart fix --apply`.

**Tech Stack:** Flutter, custom_lint, riverpod_lint, dart analyze, Makefile

---

### Task 1: Add `custom_lint` dev dependency

**Files:**
- Modify: `pubspec.yaml:51`

Add `custom_lint` as a direct dev_dependency after `riverpod_lint`:

```yaml
  riverpod_lint: ^2.3.0
  custom_lint: ^0.7.0
```

- [ ] **Step 1: Edit pubspec.yaml** — add `custom_lint: ^0.7.0` to `dev_dependencies`
- [ ] **Step 2: Run `flutter pub get`** to install the new dependency

### Task 2: Configure `analysis_options.yaml` with custom_lint plugin

**Files:**
- Modify: `analysis_options.yaml`

Add the `custom_lint` plugin to the `analyzer` section:

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    prefer_single_quotes: true
    prefer_const_constructors: true
    prefer_final_locals: true
    avoid_print: true

analyzer:
  plugins:
    - custom_lint
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
  errors:
    invalid_annotation_target: ignore
```

- [ ] **Step 1: Edit analysis_options.yaml** — add `plugins: [custom_lint]` under `analyzer:`
- [ ] **Step 2: Run `dart analyze`** — verify no new errors introduced. Expected: still only the 92 info-level `prefer_const_constructors` issues.

### Task 3: Enable `--fatal-infos` in Makefile

**Files:**
- Modify: `Makefile:10`

Change the analyze command to include `--fatal-infos`:

```makefile
analyze:
	dart analyze --fatal-infos; s=$$?; if [ $$s -ne 0 ] && [ $$s -ne 2 ]; then exit $$s; fi
```

Note: the `exit 2` handling is retained for compatibility but once all infos are fixed in Task 4, `--fatal-infos` will cause the command to exit with 0 instead of 2.

- [ ] **Step 1: Edit Makefile** — add `--fatal-infos` to the `dart analyze` command
- [ ] **Step 2: Run `make analyze`** — Expected: exits with code 2 (because infos are now fatal + still 92 issues), or the `s -ne 2` branch handles it. Either way, we proceed to fix the issues.

### Task 4: Fix all `prefer_const_constructors` issues

**Files:**
- Modify: multiple test files (92 occurrences across the test suite)

Run `dart fix --apply` to automatically add `const` to all eligible constructors:

```bash
dart fix --apply
```

This will mechanically add the `const` keyword to 92 constructor calls in test files.

- [ ] **Step 1: Run `dart fix --apply`** to auto-fix all issues
- [ ] **Step 2: Run `dart analyze --fatal-infos`** — Expected: 0 issues found

### Task 5: Verify everything passes

- [ ] **Step 1: Run `make check`** — Expected:
  - `dart analyze --fatal-infos` exits with 0 (0 errors, 0 warnings, 0 infos)
  - `flutter test --coverage --branch-coverage` passes
  - Coverage gate reports 100% line + branch
- [ ] **Step 2: Run `flutter test`** — all existing tests still pass
