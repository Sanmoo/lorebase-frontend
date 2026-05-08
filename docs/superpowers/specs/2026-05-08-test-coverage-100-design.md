# 100% Test Coverage — Design

## Problem

Incrementar a cobertura de testes de 69.79% para 100%, de forma que o quality gate (`make check`) passe.

## Current State

| Métrica  | %      | Coberto/Total |
| -------- | ------ | ------------- |
| Lines    | 69.79% | 954 / 1367    |
| Branches | 56.58% | 172 / 304     |

54 arquivos analisados (excluindo `*.g.dart`, `*.freezed.dart`, `test/`).

## Excluded Files (Infra/Config)

Quatro arquivos adicionados permanentemente à exclusion list do quality gate (sem lógica de negócio testável):

| File                                  | Lines | Rationale                                                |
| ------------------------------------- | ----- | -------------------------------------------------------- |
| `lib/core/constants/api_constants.dart` | 2     | Static constants (env, timeouts, page size)              |
| `lib/core/providers/core_providers.dart` | 3     | Provider registration — pure DI glue                  |
| `lib/core/theme/app_theme.dart`         | 10    | Declarative Material Theme configuration (light + dark)  |
| `lib/core/network/dio_client.dart`      | 9     | Factory method without branches — only assembles Dio     |

These exclusions go into `_isExcluded()` in `scripts/check_coverage.dart`.

**24 lines excluded from 413 uncovered → net ~389 uncovered to address.**

**Note:** `lib/router.dart` is kept — its redirect callback (lines 20-28) contains auth guard logic worth testing.

## Phase Plan

Bottom-up approach: 0% first, then < 80%, then < 100%.

### Phase 1 — 0% files

| File                                                 | Uncovered | Type       |
| ---------------------------------------------------- | --------- | ---------- |
| `lib/features/series/viewmodels/series_detail_viewmodel.dart` | 0/32      | ViewModel  |
| `lib/router.dart`                                      | 0/29      | Router     |
| `lib/core/network/auth_interceptor.dart`                | 0/6       | Core logic |

**Target: ~67 lines, 3 files.**

### Phase 2 — < 80% files

| File                                                   | Coverage  | Uncovered | Type       |
| ------------------------------------------------------ | --------- | --------- | ---------- |
| `lib/features/auth/data/repositories/auth_repository.dart`  | 3.8%      | 25        | Repository |
| `lib/features/auth/viewmodels/auth_viewmodel.dart`          | 5.6%      | 17        | ViewModel  |
| `lib/app.dart`                                              | 8.3%      | 11        | App entry  |
| `lib/core/widgets/scaffold_with_nav_bar.dart`               | 50.0%     | 13        | Widget     |
| `lib/features/series/pages/series_detail_page.dart`         | 56.2%     | 99        | Page       |
| `lib/features/dashboard/pages/dashboard_page.dart`          | 56.5%     | 30        | Page       |
| `lib/features/auth/pages/register_page.dart`                | 60.2%     | 43        | Page       |
| `lib/features/series/pages/series_search_page.dart`         | 65.3%     | 17        | Page       |
| `lib/features/series/widgets/series_poster.dart`            | 69.2%     | 8         | Widget     |
| `lib/features/tracking/pages/tracking_list_page.dart`       | 71.4%     | 16        | Page       |
| `lib/features/auth/pages/forgot_password_page.dart`         | 76.5%     | 16        | Page       |
| `lib/features/auth/pages/login_page.dart`                   | 82.5%     | 10        | Page       |
| `lib/core/responsive/breakpoints.dart`                      | 80.0%     | 1         | Core       |
| `lib/features/auth/viewmodels/auth_state.dart`              | 83.3%     | 2         | State      |
| `lib/features/series/widgets/series_card.dart`              | 83.3%     | 5         | Widget     |

**Target: ~313 lines, 15 files.**

### Phase 3 — < 100% files

| File                                                          | Coverage  | Uncovered | Type       |
| ------------------------------------------------------------- | --------- | --------- | ---------- |
| `lib/features/dashboard/data/repositories/dashboard_repository.dart` | 92.0%     | 2         | Repository |
| `lib/features/auth/viewmodels/register_viewmodel.dart`               | 94.2%     | 4         | ViewModel  |
| `lib/features/series/data/repositories/series_repository.dart`       | 94.7%     | 1         | Repository |
| `lib/features/tracking/data/repositories/tracking_repository.dart`   | 95.2%     | 2         | Repository |

**Target: ~9 lines, 4 files.**

## Testing Strategy

Follow existing project patterns. Each test file mirrors the source file location under `test/`.

| Source type     | Test approach                                                 | Existing reference               |
| --------------- | ------------------------------------------------------------- | -------------------------------- |
| **ViewModel**      | `mockito` mocks + `ProviderContainer` to drive the provider        | `login_viewmodel_test.dart`        |
| **Repository**     | `mockito` for `Dio`, verify HTTP calls + error paths               | `series_repository_test.dart`      |
| **Core logic**     | Pure Dart unit tests (no Flutter dependency)                   | `error_interceptor_test.dart`      |
| **Widget (simple)** | `pumpWidget` + `find.text` / `find.byType` + `tap`               | `auth_button_test.dart`            |
| **Page (Consumer)** | `pumpWidget` + `ProviderScope` with overridden providers         | `login_page_test.dart`             |
| **Router**            | Pure Dart: GoRouter with mock auth state, test redirect logic  | pattern from this plan              |
| **State classes**   | Pure Dart tests for constructors, equality, defaults         | `auth_state_test.dart`             |

## Script Changes

Update `scripts/check_coverage.dart` `_isExcluded()` to include the 4 infra files via path matching (`endsWith` or `contains`).

## Success Criteria

After all three phases: `make check` prints `Quality gate PASSED` and exits 0.
