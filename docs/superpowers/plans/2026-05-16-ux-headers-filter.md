# UX/UI: Remoção de Headers Redundantes e Consistência do Filtro — Plano de Implementação

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remover AppBars redundantes das páginas TrackingListPage e RecommendationPage, e corrigir alinhamento do MediaTypeToggle para largura total consistente com o Dashboard.

**Architecture:** Remove nested Scaffolds das 2 páginas — o `ScaffoldWithNavBar` já provê o Scaffold externo. Corrigir `CrossAxisAlignment` da Column no TrackingListPage para `stretch`. Limpar chaves i18n órfãs.

**Tech Stack:** Flutter 3.27, Dart, Riverpod, GoRouter

---

### Task 1: Remover testes de AppBar que vão falhar

**Files:**
- Modify: `test/features/recommendation/pages/recommendation_page_test.dart`
- Modify: `test/features/tracking/pages/tracking_list_page_test.dart`

- [ ] **Step 1: Remover teste `'has AppBar with title'` do recommendation_page_test.dart**

```dart
// Remover este bloco inteiro (linhas ~22-28):
    testWidgets('has AppBar with title', (tester) async {
      await tester.pumpWidget(
        TranslationProvider(
          child: const MaterialApp(home: RecommendationPage()),
        ),
      );
      expect(find.text('Recommendation'), findsOneWidget);
    });
```

- [ ] **Step 2: Remover teste `'shows AppBar with title'` do tracking_list_page_test.dart**

```dart
// Remover este bloco inteiro (linhas ~93-98):
    testWidgets('shows AppBar with title', (tester) async {
      final container = createContainer(FakeTrackingListVM());
      addTearDown(container.dispose);
      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      expect(find.text('My Lists'), findsOneWidget);
    });
```

- [ ] **Step 3: Rodar testes — os testes restantes devem continuar passando (apenas removemos verificações de AppBar, código fonte ainda inalterado)**

```bash
flutter test test/features/recommendation/pages/recommendation_page_test.dart test/features/tracking/pages/tracking_list_page_test.dart
```

Expected: 15/15 passam (2 do recommendation, 13 do tracking).

- [ ] **Step 4: Commit**

```bash
git add test/features/recommendation/pages/recommendation_page_test.dart test/features/tracking/pages/tracking_list_page_test.dart
git commit -m "test: remove AppBar title tests for Recommendation and Tracking pages"
```

---

### Task 2: Remover Scaffold + AppBar da RecommendationPage

**Files:**
- Modify: `lib/features/recommendation/pages/recommendation_page.dart`

- [ ] **Step 1: Substituir o `build()` da RecommendationPage**

Trocar de:

```dart
class RecommendationPage extends ConsumerWidget {
  const RecommendationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.recommend_title),
      ),
      body: Center(
        child: Text(t.recommend_coming_soon),
      ),
    );
  }
}
```

Para:

```dart
class RecommendationPage extends ConsumerWidget {
  const RecommendationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    return Center(
      child: Text(t.recommend_coming_soon),
    );
  }
}
```

Remove-se também o import implícito de `Material` se não for mais necessário (verificar se restam referências — `Center` e `Text` são de `widgets.dart`, que é re-exportado por `material.dart`. O arquivo já importa `package:flutter/material.dart` — manter o import).

- [ ] **Step 2: Rodar testes da RecommendationPage**

```bash
flutter test test/features/recommendation/pages/recommendation_page_test.dart
```

Expected: 2/2 passam (`shows coming soon message`, `recommendation page uses non-const constructor`). O teste `has AppBar with title` foi removido no Task 1.

- [ ] **Step 3: Commit**

```bash
git add lib/features/recommendation/pages/recommendation_page.dart
git commit -m "feat: remove redundant AppBar from RecommendationPage"
```

---

### Task 3: Remover Scaffold + AppBar da TrackingListPage e corrigir alinhamento do filtro

**Files:**
- Modify: `lib/features/tracking/pages/tracking_list_page.dart`

- [ ] **Step 1: Substituir o Scaffold interno pela Column com `CrossAxisAlignment.stretch`**

Trocar de:

```dart
    return Scaffold(
      appBar: AppBar(
        title: Text(t.tracking_list_title),
      ),
      body: Column(
        children: [
```

Para:

```dart
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
```

E substituir o fechamento do Scaffold — o `],),` que fecha `children`, `Column`, `body` e `Scaffold` vira apenas `],` que fecha `children` e `Column`:

De:
```dart
          ),
        ],
      ),
    );
```

Para:
```dart
          ),
        ],
    );
```

O código final do método `build()` (parte relevante) deve ser:

```dart
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: MediaTypeToggle(
            selectedType: _selectedType,
            onChanged: _onMediaTypeChanged,
          ),
        ),
        Container(
          color: Theme.of(context).appBarTheme.backgroundColor ??
              Theme.of(context).primaryColor,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            tabs: TrackingStatus.values
                .map((s) => Tab(text: s.label(t)))
                .toList(),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: List.generate(4, (index) {
              // ... existing TabBarView content unchanged ...
            }),
          ),
        ),
      ],
    );
```

- [ ] **Step 2: Rodar testes da TrackingListPage**

```bash
flutter test test/features/tracking/pages/tracking_list_page_test.dart
```

Expected: Todos os testes restantes passam (13 testes, pois o `'shows AppBar with title'` foi removido no Task 1).

- [ ] **Step 3: Commit**

```bash
git add lib/features/tracking/pages/tracking_list_page.dart
git commit -m "feat: remove redundant AppBar from TrackingListPage and fix MediaTypeToggle to full width"
```

---

### Task 4: Remover chaves i18n órfãs

**Files:**
- Modify: `lib/l10n/pt_BR.i18n.json`
- Modify: `lib/l10n/en_US.i18n.json`
- Modify: `lib/l10n/es.i18n.json`
- Modify: `lib/l10n/en.i18n.json`

- [ ] **Step 1: Remover `tracking_list_title` e `recommend_title` do `pt_BR.i18n.json`**

Remover estas 2 linhas:
```json
  "tracking_list_title": "Minhas Listas",
  "recommend_title": "Recomendação",
```

- [ ] **Step 2: Remover `tracking_list_title` e `recommend_title` do `en_US.i18n.json`**

Remover estas 2 linhas:
```json
  "tracking_list_title": "My Lists",
  "recommend_title": "Recommendation",
```

- [ ] **Step 3: Remover `tracking_list_title` e `recommend_title` do `es.i18n.json`**

Remover estas 2 linhas:
```json
  "tracking_list_title": "Mis Listas",
  "recommend_title": "Recomendación",
```

- [ ] **Step 4: Remover `tracking_list_title` e `recommend_title` do `en.i18n.json`**

Remover estas 2 linhas:
```json
  "tracking_list_title": "My Lists",
  "recommend_title": "Recommendation",
```

- [ ] **Step 5: Commit**

```bash
git add lib/l10n/pt_BR.i18n.json lib/l10n/en_US.i18n.json lib/l10n/es.i18n.json lib/l10n/en.i18n.json
git commit -m "chore: remove orphan i18n keys tracking_list_title and recommend_title"
```

---

### Task 5: Regenerar codegen e verificação final

**Files:**
- Regenerate: `lib/l10n/strings_en.g.dart` (via build_runner)
- Regenerate: todos os `*.g.dart` que dependem de i18n

- [ ] **Step 1: Rodar build_runner para regenerar codegen**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: Sucesso, sem erros. O `strings_en.g.dart` será regenerado sem as chaves removidas.

- [ ] **Step 2: Rodar dart analyze**

```bash
dart analyze --fatal-infos
```

Expected: Nenhum erro ou warning.

- [ ] **Step 3: Rodar todos os testes**

```bash
flutter test
```

Expected: Todos os testes passam.

- [ ] **Step 4: Rodar cobertura**

```bash
make test-coverage
```

Expected: 100% line + branch coverage.

- [ ] **Step 5: Commit final**

```bash
git add lib/l10n/strings_en.g.dart
git commit -m "chore: regenerate i18n codegen after key removal"
```
