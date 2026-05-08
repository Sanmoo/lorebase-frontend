# Mutation Testing Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Set up mutation testing with `mutation_test` package for domain logic files, integrated into `make check` with 80% quality gate.

**Architecture:** Add `mutation_test` as dev dependency, create XML config targeting domain directories (models, viewmodels, repositories, core), wire into Makefile as `make mutation-test` and as a dependency of `make check`. Phase 1 scoped to ~30 domain files (~300-600 mutants, ~2-5 min runtime).

**Tech Stack:** Flutter/Dart, `mutation_test: ^1.8.0`, XML config

---

### Task 1: Add mutation_test dependency

**Files:**
- Modify: `pubspec.yaml` (dev_dependencies section)
- Run: `dart pub get`

- [ ] **Step 1: Add mutation_test to dev_dependencies**

Insert after `custom_lint: ^0.7.0`:

```yaml
  mutation_test: ^1.8.0
```

- [ ] **Step 2: Install dependencies**

Run:
```bash
dart pub get
```
Expected: Resolves `mutation_test` 1.8.0 and its transitive deps (`args`, `path`, `xml`).

- [ ] **Step 3: Verify CLI is accessible**

Run:
```bash
dart run mutation_test --help
```
Expected: Prints help text with flags (`-f`, `-o`, `-r`, etc.).

- [ ] **Step 4: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "build: add mutation_test dev dependency"
```

---

### Task 2: Create mutation_config.xml

**Files:**
- Create: `mutation_config.xml`

- [ ] **Step 1: Create mutation_config.xml**

Write to `mutation_config.xml`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<mutations version="1.2">
    <directories>
        <directory>lib/core/constants</directory>
        <directory>lib/core/errors</directory>
        <directory>lib/core/network</directory>
        <directory>lib/core/providers</directory>
        <directory>lib/core/responsive</directory>
        <directory>lib/features/auth/data</directory>
        <directory>lib/features/auth/viewmodels</directory>
        <directory>lib/features/dashboard/data</directory>
        <directory>lib/features/dashboard/viewmodels</directory>
        <directory>lib/features/series/data</directory>
        <directory>lib/features/series/viewmodels</directory>
        <directory>lib/features/tracking/data</directory>
        <directory>lib/features/tracking/viewmodels</directory>
    </directories>
    <commands>
        <command group="test" expected-return="0" timeout="180">flutter test</command>
    </commands>
    <exclude>
        <file>**/*.g.dart</file>
        <file>**/*.freezed.dart</file>
        <file>**/api_constants.dart</file>
        <file>**/core_providers.dart</file>
        <file>**/dio_client.dart</file>
        <file>**/auth_repository.dart</file>
        <file>**/auth_interceptor.dart</file>
    </exclude>
    <threshold failure="80"/>
</mutations>
```

- [ ] **Step 2: Commit**

```bash
git add mutation_config.xml
git commit -m "feat: add mutation test config for domain logic"
```

---

### Task 3: Update Makefile

**Files:**
- Modify: `Makefile`

- [ ] **Step 1: Add mutation-test target and update check**

Current `Makefile`:
```makefile
.PHONY: test test-coverage analyze check

test:
	flutter test

test-coverage:
	dart run scripts/check_coverage.dart

analyze:
	dart analyze --fatal-infos; s=$$?; if [ $$s -ne 0 ] && [ $$s -ne 2 ]; then exit $$s; fi

check: analyze test-coverage
```

Replace with:
```makefile
.PHONY: test test-coverage analyze mutation-test check

test:
	flutter test

test-coverage:
	dart run scripts/check_coverage.dart

mutation-test:
	dart run mutation_test -f md -o mutation-test-report mutation_config.xml

analyze:
	dart analyze --fatal-infos; s=$$?; if [ $$s -ne 0 ] && [ $$s -ne 2 ]; then exit $$s; fi

check: analyze mutation-test test-coverage
```

- [ ] **Step 2: Add mutation-test-report/ to .gitignore**

Check if `.gitignore` already has coverage exclusions. Add:
```
mutation-test-report/
```

- [ ] **Step 3: Commit**

```bash
git add Makefile .gitignore
git commit -m "feat: integrate mutation test into make check"
```

---

### Task 4: Run baseline mutation test

**Files:**
- Run: `make mutation-test`

- [ ] **Step 1: Run the mutation test**

Run:
```bash
make mutation-test
```
Expected: Processes all domain files, generates mutants, runs `flutter test` per mutant, produces report.

Command exits with code 0 if score >= 80%, or code non-zero if below threshold.

- [ ] **Step 2: Check the report**

```bash
cat mutation-test-report/mutation-test-report.md
```

Look for:
- Mutation score percentage
- List of surviving mutants (if any)
- Which files have undetected mutations

- [ ] **Step 3: If score < 80%, list survivors**

If any mutants survived, list the lines/files where tests failed to detect mutations. These are candidates for test improvements in the next task.

- [ ] **Step 4: Commit the report**

```bash
git add mutation-test-report/
git commit -m "test: add baseline mutation test report"
```

---

### Task 5: Fix surviving mutants (iterative, if score < 80%)

**Files:**
- Modify: Test files for modules with surviving mutants

- [ ] **Step 1: For each surviving mutant, add assertion to catch the mutation**

Example: if a mutant survives like `>` changed to `<` in a comparison, add a test case that exercises both sides of that comparison.

For each surviving mutant:
1. Read the mutant location from the report (file + line)
2. Understand what mutation was applied (e.g., `>` → `<`, `true` → `false`, `+` → `-`)
3. Add/update the relevant test to assert the correct behavior

- [ ] **Step 2: Re-run mutation test**

```bash
make mutation-test
```

- [ ] **Step 3: Repeat until score >= 80%**

Iterate Steps 1-2 until the quality gate passes.

- [ ] **Step 4: Commit all test fixes**

```bash
git add test/...
git commit -m "test: strengthen tests to pass mutation score >= 80%"
```
