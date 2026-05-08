# Coverage Quality Gate Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a local quality gate that fails the build if line, function, or branch coverage is below 100%.

**Architecture:** Makefile targets orchestrate a custom Dart script (`scripts/check_coverage.dart`) that launches `flutter test` with VM service enabled, uses the `coverage` package's `collect()` with function+branch coverage flags, parses the hitmap, and exits with code 1 if any metric < 100%.

**Tech Stack:** Dart, `coverage: ^1.15.0`, Makefile

---

## File Structure

| File | Action | Responsibility |
|---|---|---|
| `pubspec.yaml` | Modify | Add `coverage` dev_dependency |
| `scripts/check_coverage.dart` | Create | Orchestrate coverage collection, parse hitmap, check thresholds, exit with gate result |
| `Makefile` | Create | Define `test-coverage`, `analyze`, `check` targets |
| `.gitignore` | Modify | Ensure `coverage/` is ignored |
| `AGENTS.md` | Modify | Document new commands |

---

### Task 1: Add `coverage` dev_dependency

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Add coverage dependency**

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  mockito: ^5.4.0
  build_runner: ^2.4.0
  freezed: ^2.4.0
  json_serializable: ^6.7.0
  riverpod_generator: ^2.3.0
  riverpod_lint: ^2.3.0
  coverage: ^1.15.0
```

Insert `coverage: ^1.15.0` after the existing dev_dependencies, maintaining alphabetical order.

- [ ] **Step 2: Install dependencies**

Run: `flutter pub get`
Expected: Resolves `coverage` and its transitive dependencies successfully.

- [ ] **Step 3: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "deps: add coverage package for quality gate"
```

---

### Task 2: Ensure `coverage/` is in `.gitignore`

**Files:**
- Modify: `.gitignore`

- [ ] **Step 1: Check if coverage/ is already ignored**

Run: `grep -n 'coverage' .gitignore`
Expected: If `coverage/` appears, skip to commit. If not, continue.

- [ ] **Step 2: Add coverage/ to .gitignore**

Add `coverage/` before the `# Environment files` section:

```
# Coverage output
coverage/
```

- [ ] **Step 3: Commit**

```bash
git add .gitignore
git commit -m "chore: ignore coverage output directory"
```

---

### Task 3: Create `scripts/check_coverage.dart`

**Files:**
- Create: `scripts/check_coverage.dart`

This script orchestrates the full coverage quality gate. It:

1. Starts `flutter test` with VM service enabled
2. Connects to the VM service and collects coverage with function + branch data
3. Parses the hitmap to calculate line, function, and branch coverage percentages
4. Applies exclusion filters (generated code, test files)
5. Exits with code 1 if any metric < 100%

- [ ] **Step 1: Write the script with the full orchestration logic**

```dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:coverage/coverage.dart';

const double _threshold = 100.0;

Future<void> main(List<String> args) async {
  final packageDir = Directory.current.path;

  // 1. Start flutter test with VM service
  final serviceUriCompleter = Completer<Uri>();

  final testProcess = await Process.start(
    'flutter',
    ['test', '--enable-vm-service=0'],
    runInShell: true,
  );

  // Forward stdout/stderr to console
  testProcess.stdout.transform(utf8.decoder).forEach(stdout.write);
  testProcess.stderr.transform(utf8.decoder).forEach((line) {
    if (!serviceUriCompleter.isCompleted) {
      final uri = _extractVmServiceUri(line);
      if (uri != null) {
        serviceUriCompleter.complete(uri);
      }
    }
    stderr.write(line);
  });

  // 2. Wait for VM service URI (timeout if not found)
  final serviceUri = await serviceUriCompleter.future.timeout(
    const Duration(seconds: 60),
    onTimeout: () {
      testProcess.kill();
      stderr.writeln('ERROR: Could not find VM service URI from flutter test output');
      exit(1);
    },
  );

  // 3. Collect coverage with function + branch data
  final coverageJson = await collect(
    serviceUri,
    true,  // resume isolates after collection
    true,  // wait for isolates to pause
    false, // don't include Dart SDK
    {packageDir}, // scope output to package directory
    functionCoverage: true,
    branchCoverage: true,
  );

  // 4. Wait for test process to complete
  final testExitCode = await testProcess.exitCode;
  if (testExitCode != 0) {
    stderr.writeln('ERROR: flutter test failed with exit code $testExitCode');
    exit(testExitCode);
  }

  // 5. Create hitmap from collected JSON
  final hitmap = await createHitmap(
    [coverageJson],
    checkIgnoredLines: true,
    packagePath: packageDir,
  );

  // 6. Calculate percentages
  final totalFiles = <String>{};
  var totalLines = 0;
  var hitLines = 0;
  var totalFunctions = 0;
  var hitFunctions = 0;
  var totalBranches = 0;
  var hitBranches = 0;

  for (final entry in hitmap.entries) {
    if (_isExcluded(entry.key)) continue;
    totalFiles.add(entry.key);
    for (final lineEntry in entry.value.entries) {
      totalLines++;
      if (lineEntry.value > 0) hitLines++;
    }
  }

  // Extract function and branch data from raw JSON
  // (these are stored separately in the coverage JSON from collect())
  final rawFunctions = coverageJson['functionHits'] as Map<String, dynamic>?;
  if (rawFunctions != null) {
    for (final entry in rawFunctions.entries) {
      if (_isExcluded(entry.key)) continue;
      final data = entry.value as Map<String, dynamic>;
      totalFunctions += data['total'] as int? ?? 0;
      hitFunctions += data['hit'] as int? ?? 0;
    }
  }

  final rawBranches = coverageJson['branchHits'] as Map<String, dynamic>?;
  if (rawBranches != null) {
    for (final entry in rawBranches.entries) {
      if (_isExcluded(entry.key)) continue;
      final data = entry.value as Map<String, dynamic>;
      totalBranches += data['total'] as int? ?? 0;
      hitBranches += data['hit'] as int? ?? 0;
    }
  }

  // 7. Calculate percentages
  final linePct = totalLines > 0 ? (hitLines / totalLines) * 100 : 100.0;
  final funcPct = totalFunctions > 0 ? (hitFunctions / totalFunctions) * 100 : 100.0;
  final branchPct = totalBranches > 0 ? (hitBranches / totalBranches) * 100 : 100.0;

  // 8. Print report
  print('Coverage Report:');
  print('  Files: ${totalFiles.length}');
  print('');
  print('  Lines:     ${linePct.toStringAsFixed(2)}% ($hitLines/$totalLines)');
  print('  Functions: ${funcPct.toStringAsFixed(2)}% ($hitFunctions/$totalFunctions)');
  print('  Branches:  ${branchPct.toStringAsFixed(2)}% ($hitBranches/$totalBranches)');
  print('');
  print('Threshold: ${_threshold.toStringAsFixed(0)}%');

  // 9. Check threshold
  var failed = false;
  if (linePct < _threshold) {
    stderr.writeln('FAIL: Line coverage $linePct% < $_threshold%');
    failed = true;
  }
  if (funcPct < _threshold) {
    stderr.writeln('FAIL: Function coverage $funcPct% < $_threshold%');
    failed = true;
  }
  if (branchPct < _threshold) {
    stderr.writeln('FAIL: Branch coverage $branchPct% < $_threshold%');
    failed = true;
  }

  if (failed) {
    stderr.writeln('\nQuality gate FAILED');
    exit(1);
  }

  print('\nQuality gate PASSED');
  exit(0);
}

Uri? _extractVmServiceUri(String line) {
  final match = RegExp(r'http://127\.0\.0\.1:\d+/[A-Za-z0-9_/-]*').firstMatch(line);
  if (match != null) {
    final uri = Uri.tryParse(match.group(0)!);
    if (uri != null && uri.port > 0) return uri;
  }
  return null;
}

bool _isExcluded(String filePath) {
  if (filePath.endsWith('.g.dart') || filePath.endsWith('.freezed.dart')) return true;
  if (filePath.contains('/test/') || filePath.contains('\\test\\')) return true;
  return false;
}
```

- [ ] **Step 2: Run the script to check for compilation errors**

Run: `dart analyze scripts/check_coverage.dart`
Expected: No errors (may have warnings about unused imports — fix if any).

- [ ] **Step 3: Commit**

```bash
git add scripts/check_coverage.dart
git commit -m "feat: add coverage quality gate script"
```

---

### Task 4: Create Makefile

**Files:**
- Create: `Makefile`

- [ ] **Step 1: Write Makefile with targets**

```makefile
.PHONY: test test-coverage analyze check

test:
	flutter test

test-coverage:
	dart run scripts/check_coverage.dart

analyze:
	dart analyze

check: analyze test-coverage
```

- [ ] **Step 2: Commit**

```bash
git add Makefile
git commit -m "chore: add Makefile with coverage quality gate targets"
```

---

### Task 5: Update AGENTS.md

**Files:**
- Modify: `AGENTS.md`

- [ ] **Step 1: Add new commands to the Common Commands section**

Insert after the `dart analyze` line:

```bash
# Coverage quality gate (line + function + branch at 100%)
make test-coverage

# Run all checks: analyze + coverage gate
make check
```

- [ ] **Step 2: Commit**

```bash
git add AGENTS.md
git commit -m "docs: update AGENTS.md with coverage commands"
```

---

### Task 6: Verify end-to-end

- [ ] **Step 1: Run the coverage gate**

Run: `make test-coverage`
Expected: The script starts, runs tests, collects coverage, prints report, and either passes or fails the gate. If it fails, the output shows which metric(s) are below 100%.

- [ ] **Step 2: Run the full check pipeline**

Run: `make check`
Expected: Runs `dart analyze` first, then the coverage gate. Both should report success.

- [ ] **Step 3: Inspect coverage output**

Run: `ls coverage/`
Expected: `coverage.json` and `lcov.info` exist (artifacts from collection).

- [ ] **Step 4: Clean up coverage artifacts (if not already gitignored)**

Run: `rm -rf coverage/`

---

### Task 7: Final commit of remaining changes

- [ ] **Step 1: Check for any unstaged changes**

Run: `git status`
Expected: No remaining dirty files (coverage/ is gitignored, all code changes committed).

- [ ] **Step 2: View the full commit log**

Run: `git log --oneline -10`
Expected: Shows the 6 commits in order.
