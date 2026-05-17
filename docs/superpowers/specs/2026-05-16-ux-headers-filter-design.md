# UX/UI: Remoção de Headers Redundantes e Consistência do Filtro

**Data:** 2026-05-16
**Status:** Aprovado para implementação

## Problema

1. **Headers redundantes:** As páginas "Minhas Listas" (`TrackingListPage`) e "Recomendar" (`RecommendationPage`) possuem `Scaffold` interno com `AppBar` contendo títulos que repetem informação já presente no `BottomNavigationBar`. O `ScaffoldWithNavBar` (shell) já fornece o `Scaffold` externo com `AppBar` ("Lorebase") e `BottomNavigationBar` com as abas "Minhas Listas" e "Recomendar".

2. **Filtro inconsistente:** O `MediaTypeToggle` (Séries/Filmes) renderiza com largura total no Dashboard, mas no TrackingListPage aparece com largura reduzida (apenas o necessário para os labels), centralizado. A causa: no Dashboard o toggle está dentro de `CustomScrollView` → `SliverToBoxAdapter` (força largura total), enquanto no TrackingListPage está em uma `Column` comum com `CrossAxisAlignment.center` (padrão).

## Solução

### Abordagem: Remover Scaffolds internos + `CrossAxisAlignment.stretch`

#### `lib/features/tracking/pages/tracking_list_page.dart`

- Remover o `Scaffold` interno e seu `AppBar`
- `build()` retorna diretamente a `Column` com `crossAxisAlignment: CrossAxisAlignment.stretch`
- O `ScaffoldWithNavBar` externo provê o `Scaffold` e `AppBar` ("Lorebase")
- O `MediaTypeToggle` agora expande para largura total, igual ao Dashboard

**Antes:**
```dart
return Scaffold(
  appBar: AppBar(title: Text(t.tracking_list_title)),
  body: Column(children: [...]),
);
```

**Depois:**
```dart
return Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [...],
);
```

#### `lib/features/recommendation/pages/recommendation_page.dart`

- Remover o `Scaffold` interno e seu `AppBar`
- `build()` retorna diretamente `Center(child: Text(t.recommend_coming_soon))`
- Mantém o placeholder "Em breve"

**Antes:**
```dart
return Scaffold(
  appBar: AppBar(title: Text(t.recommend_title)),
  body: Center(child: Text(t.recommend_coming_soon)),
);
```

**Depois:**
```dart
return Center(
  child: Text(t.recommend_coming_soon),
);
```

### Remoção de chaves i18n órfãs

As chaves `tracking_list_title` e `recommend_title` só eram usadas nos AppBars removidos. Removê-las dos 4 arquivos de tradução:

- `lib/l10n/pt_BR.i18n.json`
- `lib/l10n/en_US.i18n.json`
- `lib/l10n/es.i18n.json`
- `lib/l10n/en.i18n.json`

Após a remoção, rodar `dart run build_runner build --delete-conflicting-outputs` para regenerar `strings_en.g.dart`.

### Testes

- `test/features/tracking/pages/tracking_list_page_test.dart`: Remover teste `'shows AppBar with title'` — verifica `find.text('My Lists')` que não existirá mais
- `test/features/recommendation/pages/recommendation_page_test.dart`: Remover teste `'has AppBar with title'` — verifica `find.text('Recommendation')` que não existirá mais
- Golden tests em `test/visual/pages/`: Regenerar screenshots com `--update-goldens`

### Verificação pós-implementação

1. `dart run build_runner build --delete-conflicting-outputs` — regenerar `*.g.dart`
2. `dart analyze --fatal-infos` — sem erros de lint
3. `flutter test` — todos os testes passam
4. `make test-coverage` — 100% line + branch coverage

## Arquivos alterados

| Arquivo | Mudança |
|--------|---------|
| `lib/features/tracking/pages/tracking_list_page.dart` | Remover `Scaffold` + `AppBar`; `Column` com `CrossAxisAlignment.stretch` |
| `lib/features/recommendation/pages/recommendation_page.dart` | Remover `Scaffold` + `AppBar`; retornar `Center` diretamente |
| `lib/l10n/pt_BR.i18n.json` | Remover `tracking_list_title`, `recommend_title` |
| `lib/l10n/en_US.i18n.json` | Remover `tracking_list_title`, `recommend_title` |
| `lib/l10n/es.i18n.json` | Remover `tracking_list_title`, `recommend_title` |
| `lib/l10n/en.i18n.json` | Remover `tracking_list_title`, `recommend_title` |
| `lib/l10n/strings_en.g.dart` | Regenerado pelo build_runner |
| `test/features/tracking/pages/tracking_list_page_test.dart` | Remover teste `'shows AppBar with title'` |
| `test/features/recommendation/pages/recommendation_page_test.dart` | Remover teste `'has AppBar with title'` |
