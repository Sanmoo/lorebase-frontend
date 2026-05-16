# Visual Regression Testing — Design Spec

**Date:** 2026-05-16
**Status:** Approved
**Tool:** Alchemist (`alchemist` package)

## 1. Goal

Add visual regression testing to the Lorebase Flutter app, capturing full-page golden screenshots for all primary pages. Tests must be part of the quality gate (`make check`) and target mobile rendering.

## 2. Architecture

### 2.1 Directory Structure

```
test/
├── visual/                          # new root for golden tests
│   ├── flutter_test_config.dart      # Alchemist global config
│   ├── helpers/
│   │   ├── golden_helpers.dart       # pumpApp(), mockOverrides
│   │   └── test_scenarios.dart       # scenario definitions (light, dark)
│   ├── golden_files/                 # reference PNGs (git-tracked)
│   │   ├── dashboard/
│   │   ├── auth/
│   │   ├── series/
│   │   ├── movies/
│   │   ├── tracking/
│   │   └── recommendation/
│   └── pages/                        # golden test files
│       ├── dashboard_page_golden_test.dart
│       ├── login_page_golden_test.dart
│       ├── register_page_golden_test.dart
│       ├── series_detail_page_golden_test.dart
│       ├── series_search_page_golden_test.dart
│       ├── movie_detail_page_golden_test.dart
│       ├── tracking_list_page_golden_test.dart
│       └── recommendation_page_golden_test.dart
```

The golden PNG files live under `test/visual/golden_files/` organized by feature. They are git-tracked binaries. `.gitattributes` must include:

```
test/visual/golden_files/** binary
```

### 2.2 Pages Covered (8 screens)

| Feature | Page | Rationale |
|---|---|---|
| Auth | Login, Register | Entry screens, critical first impression |
| Dashboard | Dashboard | Main screen, complex layout with cards + lists |
| Series | Detail, Search | Cards, posters, grid layout |
| Movies | Detail | Poster rendering, similar to series |
| Tracking | List | Chips, posters, ratings |
| Recommendation | Recommendation | Distinct layout, dense information |

**Excluded:** ForgotPassword (too simple — single TextField + button). Trivial to add later.

### 2.3 Scenarios Per Page

Each page generates **2 golden files**:

| Scenario | What it tests |
|---|---|
| `light_default` | Light theme, mobile screen size 390×844 logical pixels (iPhone 13/14) |
| `dark_default` | Dark theme, same screen size |

No font scale, locale, or tablet variations in v1. Additional scenarios can be added by including more `GoldenTestScenario` entries.

### 2.4 Screen Size

Fixed at **390×844 logical pixels** via Alchemist configuration. Mobile only.

## 3. Test Structure

### 3.1 Golden Test File Example

```dart
// test/visual/pages/dashboard_page_golden_test.dart
import 'package:alchemist/alchemist.dart';

import '../../helpers/golden_helpers.dart';

void main() {
  goldenTest(
    'Dashboard page renders correctly',
    fileName: 'dashboard_page',
    builder: () => GoldenTestGroup(
      scenarios: [
        GoldenTestScenario(
          name: 'light_default',
          child: ProviderScope(
            overrides: mockDashboardOverrides(),
            child: const DashboardPage(),
          ),
        ),
        GoldenTestScenario(
          name: 'dark_default',
          child: ProviderScope(
            overrides: mockDashboardOverrides(),
            child: const DashboardPage(),
          ),
        ),
      ],
    ),
  );
}
```

### 3.2 Mocking Strategy

Each feature provides a `mock*Overrides()` helper that returns `List<Override>` using the existing project pattern (fake ViewModels extending real ViewModels):

```dart
// test/visual/helpers/golden_helpers.dart
List<Override> mockDashboardOverrides() {
  final fakeVM = FakeDashboardViewModel();
  return [
    dashboardViewModelProvider.overrideWith((ref) => fakeVM),
  ];
}
```

Fake ViewModels reuse or adapt the same `Fake*` classes already defined in existing widget/page tests. No new mocking library needed.

## 4. Dependencies

### 4.1 pubspec.yaml

```yaml
dev_dependencies:
  alchemist: ^1.3.0
```

`alchemist` is the only new dependency. It already depends on `flutter_test`, ensuring compatibility.

### 4.2 Alchemist Global Config

```dart
// test/visual/flutter_test_config.dart
import 'dart:io';
import 'package:alchemist/alchemist.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await AlchemistConfig.runWithConfig(
    config: AlchemistConfig(
      platformGoldensConfig: PlatformGoldensConfig(
        enabled: true,
        platform: Platform.operatingSystem,
      ),
      theme: ThemeData.light(),
      ciGoldensConfig: CiGoldensConfig(enabled: true),
    ),
    run: testMain,
  );
}
```

## 5. Quality Gate Integration

### 5.1 Makefile Targets

```makefile
# Run golden tests (compare against reference PNGs)
golden-test:
	flutter test test/visual/

# Update golden files (when UI changes are intentional)
golden-update:
	flutter test test/visual/ --update-goldens

# Extended quality gate
check: analyze test-coverage golden-test
```

### 5.2 Workflow

1. Dev makes a UI change
2. `make check` runs: analyze → coverage → golden tests
3. Golden test fails → dev runs `make golden-update` to regenerate PNGs
4. Dev reviews the new PNGs (`git diff`) — if the change is intentional, commits the updated golden files
5. PR passes gate

### 5.3 Coverage Exclusion

Golden tests live under `test/visual/` which is under `test/`. The coverage script (`scripts/check_coverage.dart`) already excludes files containing `/test/` in the path. No changes needed to the coverage gate.

However, since golden tests import production code, they do contribute to coverage. This is acceptable — the pages themselves should already be covered by existing widget tests. If any additional coverage is needed, it's a bonus.

## 6. Implementation Plan (High-Level)

| Step | Action |
|---|---|
| 1 | Add `alchemist` to `pubspec.yaml`, run `flutter pub get` |
| 2 | Create `test/visual/flutter_test_config.dart` with global Alchemist config |
| 3 | Create helpers: `golden_helpers.dart` with mock override functions |
| 4 | Create/adapt Fake ViewModels where needed (reuse from existing tests) |
| 5 | Implement 8 golden test files (one per page) |
| 6 | Generate initial golden files with `--update-goldens` |
| 7 | Update `Makefile` with `golden-test` and `golden-update` targets |
| 8 | Integrate `golden-test` into `make check` |
| 9 | Run full `make check` to validate the complete gate |
| 10 | Add `.gitattributes` entry for golden PNGs |
