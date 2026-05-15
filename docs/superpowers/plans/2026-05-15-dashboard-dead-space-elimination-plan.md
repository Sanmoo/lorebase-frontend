# Dashboard Dead Space Elimination Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Eliminate os ~36-40px de espaço morto abaixo dos posters na horizontal list, reduzindo o `SizedBox(height: 240)` para `SizedBox(height: 204)` — altura exata do conteúdo real (poster 180px + gap 4px + título ~20px).

**Architecture:** Correção única no `TrackedMediaHorizontalList` widget. O `DashboardSection` e o top padding de 12px entre seções permanecem inalterados.

**Tech Stack:** Flutter 3.27, Material 3, Riverpod

---

### Task 1: Ajustar `SizedBox(height:)` no `TrackedMediaHorizontalList`

**Files:**
- Modify: `lib/features/dashboard/widgets/tracked_media_horizontal_list.dart` (1 linha)

- [ ] **Step 1: Trocar `height: 240` por `height: 204`**

No arquivo `lib/features/dashboard/widgets/tracked_media_horizontal_list.dart`, linha ~24:

```dart
// Antes
return SizedBox(
  height: 240,
// Depois
return SizedBox(
  height: 204,
```

- [ ] **Step 2: Rodar `make check` para verificar análise + cobertura**

```bash
make check
```

Expected: `dart analyze` sem erros, `flutter test --coverage --branch-coverage` com 100% line + branch coverage. O arquivo tem `// coverage:ignore-file` — não afeta cobertura.

- [ ] **Step 3: Commit**

```bash
git add lib/features/dashboard/widgets/tracked_media_horizontal_list.dart
git commit -m "fix: eliminate dead space in tracked media horizontal list (240→204)"
```
