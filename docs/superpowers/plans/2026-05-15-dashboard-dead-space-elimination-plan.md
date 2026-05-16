# Dashboard Dead Space Elimination Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Elimina ~8px de espaço morto abaixo dos posters na horizontal list, reduzindo o `SizedBox(height: 240)` para `SizedBox(height: 232)` — altura exata do conteúdo real (poster 180px + gap 4px + título ~48px no test runner).

**Architecture:** Correção única no `TrackedMediaHorizontalList` widget. O `DashboardSection` e o top padding de 12px entre seções permanecem inalterados.

**Tech Stack:** Flutter 3.27, Material 3, Riverpod

---

### Task 1: Ajustar `SizedBox(height:)` no `TrackedMediaHorizontalList`

**Files:**

- Modify: `lib/features/dashboard/widgets/tracked_media_horizontal_list.dart` (1 linha)

- [ ] **Step 1: Trocar `height: 240` por `height: 232`**

No arquivo `lib/features/dashboard/widgets/tracked_media_horizontal_list.dart`, linha ~24:

```dart
// Antes
return SizedBox(
  height: 240,
// Depois
// Altura do TrackedMediaPoster default: (120 * 1.5) + 4 + texto(~48)
return SizedBox(
  height: 232,
```

Nota: O valor `232` foi determinado empiricamente — `204` causava overflow de 28px nos testes (`RenderFlex overflowed by 28 pixels`). O conteúdo real do poster + texto é ~232px.

- [ ] **Step 2: Rodar `make check` para verificar análise + cobertura**

```bash
make check
```

Expected: `dart analyze` sem erros, `flutter test --coverage --branch-coverage` com 100% line + branch coverage. O arquivo tem `// coverage:ignore-file` — não afeta cobertura.

- [ ] **Step 3: Commit**

```bash
git add lib/features/dashboard/widgets/tracked_media_horizontal_list.dart
git commit -m "fix: eliminate dead space in tracked media horizontal list (240→232)"
```
