Não foi possível gravar devido ao limite de ferramentas. Achados para persistir:

- **Alta:** `CONTEXT.md`, `CONTEXT-MAP.md` e `docs/adr/` não existem, embora `AGENTS.md` espere essa documentação.
- **Alta:** não há código de domínio Book/Livro; busca em `lib` encontrou apenas `Icons.bookmark_border` em `lib/features/dashboard/pages/dashboard_page.dart:107`.
- `lib/router.dart:59-101` possui `/search`, `/series/:tmdbId`, `/movies/:tmdbId`, `/games/:gameId`; nenhuma rota de livro.
- `lib/features/tracking/data/models/media_type.dart:3-31` limita tipos a `SERIES`, `MOVIE`, `GAME`; `fromApiValue` lança para `BOOK`.
- `lib/core/widgets/media_type_toggle.dart:17-27` deriva UI de `MediaType.values`; incluir livro requer chave de tradução e revisão de switches.
- Pontos de extensão: `lib/features/series/pages/series_search_page.dart:53-90`, dashboard (`:149-230`), tracking e VMs de detalhe.
- Padrão de implementação: `lib/features/series/data/models/series_model.dart:5-55` (Freezed/JSON), `lib/features/series/data/repositories/series_repository.dart:7-56` (interface, Dio, provider), e feature completa em `lib/features/games/`.
- Riscos: API, identificador (ISBN/fornecedor), esquema de metadados/capa e requisitos de tracking de leitura não estão definidos.