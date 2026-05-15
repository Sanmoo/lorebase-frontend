# Dashboard Section Spacing Reduction — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reduzir o espaçamento entre seções do Dashboard de 24px para 12px.

**Architecture:** Alteração pontual de 3 constantes de padding em `dashboard_page.dart`. Nenhum novo arquivo, nenhuma mudança de lógica ou API.

**Tech Stack:** Flutter 3.27, Dart, Material 3

---

### Task 1: Apply spacing change and verify

**Files:**
- Modify: `lib/features/dashboard/pages/dashboard_page.dart` (3 linhas)

- [ ] **Step 1: Trocar `24.0` por `12.0` nas 3 seções**

No arquivo `lib/features/dashboard/pages/dashboard_page.dart`, localizar e substituir as 3 ocorrências de `EdgeInsets.only(top: 24.0)` por `EdgeInsets.only(top: 12.0)`.

As 3 ocorrências estão nas seções:

1. **Want to Watch** — dentro do bloco `if (dashboard.wantToWatch.items.isNotEmpty)`:
```dart
// Antes
padding: const EdgeInsets.only(top: 24.0),
// Depois
padding: const EdgeInsets.only(top: 12.0),
```

2. **Completed** — dentro do bloco `if (dashboard.completed.items.isNotEmpty)`:
```dart
// Antes
padding: const EdgeInsets.only(top: 24.0),
// Depois
padding: const EdgeInsets.only(top: 12.0),
```

3. **Dropped** — dentro do bloco `if (dashboard.dropped.items.isNotEmpty)`:
```dart
// Antes
padding: const EdgeInsets.only(top: 24.0),
// Depois
padding: const EdgeInsets.only(top: 12.0),
```

- [ ] **Step 2: Rodar `make check` para verificar análise + cobertura**

```bash
make check
```

Expected: `dart analyze` sem erros, `flutter test --coverage --branch-coverage` com 100% line + branch coverage.

- [ ] **Step 3: Commit**

```bash
git add lib/features/dashboard/pages/dashboard_page.dart
git commit -m "fix: reduce dashboard section spacing from 24px to 12px"
```
