# Lint & Code Quality Setup

## Problem

The project lacks strict lint enforcement and Riverpod-specific linting. `dart analyze` returns 92 info-level issues (all `prefer_const_constructors` in tests) but they are not blocking because the Makefile ignores exit code 2 (info-only findings). `riverpod_lint` is installed as a dependency but never configured or executed.

## Scope

- Enable `--fatal-infos` on `dart analyze` so infos become blocking
- Fix the 92 existing `prefer_const_constructors` issues in test files
- Configure `custom_lint` + `riverpod_lint` for Riverpod-specific rules
- Validation stays as `make check` only (no CI, no pre-commit hooks)
- Keep the existing coverage quality gate (100% line + branch)

## Design

### Dependencies

Add `custom_lint` to `pubspec.yaml` dev_dependencies — required by `riverpod_lint` plugin:

```yaml
dev_dependencies:
  custom_lint: ^0.7.0
```

### `analysis_options.yaml`

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  plugins:
    - custom_lint
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
  errors:
    invalid_annotation_target: ignore

linter:
  rules:
    prefer_single_quotes: true
    prefer_const_constructors: true
    prefer_final_locals: true
    avoid_print: true
```

The `custom_lint` plugin enables `riverpod_lint` rules automatically at analyze time.

### Makefile

```makefile
analyze:
	dart analyze --fatal-infos; s=$$?; if [ $$s -ne 0 ] && [ $$s -ne 2 ]; then exit $$s; fi
```

Note: exit code 2 handling is retained for compatibility but becomes unnecessary once all infos are fixed.

### Fixing existing issues

Run `dart fix --apply` to apply `const` to the 92 constructors in test files, or apply them manually. Pure mechanical change, zero behavioral impact.

### Verification

`make check` will validate:

1. `dart analyze --fatal-infos` — zero errors, zero infos
2. Custom lint + riverpod rules via `custom_lint` plugin
3. Coverage gate via `scripts/check_coverage.dart` — 100% line + branch

## Out of scope

- CI pipeline (GitHub Actions)
- Pre-commit hooks (lefthook, husky)
- Additional lint rules beyond current flutter_lints defaults plus the 4 custom rules
- `dart format` enforcement
