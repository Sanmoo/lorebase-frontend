# Design: Redução de espaçamento entre seções do Dashboard

**Data:** 2026-05-15
**Status:** Aprovado

## Contexto

O usuário reportou espaçamento exagerado entre as seções de conteúdo da página Início (Dashboard):
Watching → Want to Watch → Completed → Dropped. O valor atual de `EdgeInsets.only(top: 24.0)`
foi considerado excessivo.

## Decisão

Substituir `24.0` por `12.0` no `EdgeInsets.only(top: ...)` das 3 seções que possuem top padding explícito.

## Mudanças

**Arquivo:** `lib/features/dashboard/pages/dashboard_page.dart`

Três ocorrências de `EdgeInsets.only(top: 24.0)` → `EdgeInsets.only(top: 12.0)`:

1. Seção **Want to Watch**
2. Seção **Completed**
3. Seção **Dropped**

A seção **Watching** (primeira) não possui top padding e permanece inalterada.

## Escopo

- **Afetados:** 1 arquivo, 3 linhas
- **Não afetados:** modelos, viewmodels, widgets filhos, testes existentes
- **Não escopo:** ajustes nos stats cards, toggle, ou outros espaçamentos

## Verificação

```bash
make check   # analyze + coverage gate (100% line+branch)
```

## Abordagens consideradas

| Abordagem | Descrição | Decisão |
|-----------|-----------|---------|
| A (escolhida) | Trocar 24→12 nas 3 seções | Mínimo risco, resolve o problema |
| B (rejeitada) | Consistência total — também ajustar 1ª seção e stats rows | Overkill, toca em áreas não problemáticas |
