# Design: Suporte a Jogos no Lorebase Frontend

**Data:** 2026-06-23  
**Status:** Aprovado para implementação  
**Escopo:** Adicionar jogos como terceiro tipo de mídia no app Flutter, integrando com os novos endpoints do backend.

## Resumo

O backend adicionou suporte a jogos (`/games`, tracking com `mediaType=game`, dashboard e feed social). Este design descreve como incorporar jogos ao frontend Flutter mantendo a arquitetura atual: feature isolada (`features/games/`), `MediaType` expandido para 3 valores, toggle unificado de mídia nas telas existentes e reaproveitamento seletivo de widgets.

## Contexto

- Hoje o app suporta **séries** e **filmes**.
- Cada mídia vive em sua feature isolada: `features/series/` e `features/movies/`.
- O `MediaType` enum tem `series` e `movie`.
- O `TrackingStatus` enum é único: `wantToWatch`, `watching`, `completed`, `dropped`.
- A busca, dashboard e listas de acompanhamento usam `MediaTypeToggle` para alternar entre séries e filmes.
- O backend expõe:
  - `GET /games?q=&page=&limit=` (busca)
  - `GET /games/:gameId` (detalhe)
  - Tracking com `mediaType=game` e campos `selectedPlatform` / `hoursPlayed`
  - Dashboard com `mediaType=game`
  - Feed social com `mediaType=GAME` e `activityType=STARTED_PLAYING`

## Objetivos

1. Adicionar `MediaType.game` ao app.
2. Criar feature `features/games/` completa (model, repository, viewmodels, pages, widgets).
3. Permitir busca, detalhe, tracking, dashboard e listas de acompanhamento de jogos.
4. Suportar campos específicos de jogos: plataforma selecionada e horas jogadas.
5. Manter consistência visual e comportamental com séries/filmes.
6. Garantir 100% de cobertura de testes (line + branch) para o novo código.

## Não-objetivos

- Refatorar séries/filmes para uma abstração genérica compartilhada.
- Implementar recomendações para jogos (a feature `recommendation/` ainda não está pronta para nenhuma mídia).
- Testes e2e contra o backend real.
- Suporte a múltiplas plataformas por tracking (apenas uma `selectedPlatform`).

## Arquitetura

### Domínio

- **`MediaType`** ganha o valor `game('GAME')`.
- **`GameTrackingStatus`** (novo enum separado):
  - `wantToPlay` → `WANT_TO_PLAY`
  - `playing` → `PLAYING`
  - `completed` → `COMPLETED`
  - `dropped` → `DROPPED`
- **`GamePlatform`** (novo enum):
  - Valores fixos: `pc`, `switch`, `switch2`, `ps1`, `ps2`, `ps3`, `ps4`, `ps5`, `xbox`, `xbox360`, `xboxOne`, `snes`, `nes`, `megaDrive`, `gba`, `xboxSeriesXS`, `mobile`, `vr`, `other`.
  - Cada valor mapeia para uma string enviada ao backend (`apiValue`) e um label traduzível.
  - O valor `other` abre um campo de texto livre para plataforma customizada.

### Feature `features/games/`

```
lib/features/games/
  data/
    models/game_model.dart
    repositories/game_repository.dart
  pages/
    game_detail_page.dart
  viewmodels/
    game_detail_state.dart
    game_detail_viewmodel.dart
    game_search_viewmodel.dart
  widgets/
    game_card.dart
    game_platform_selector.dart
    game_hours_field.dart
```

### Adaptações em features existentes

- **`TrackingRepository`**: adicionar `selectedPlatform` e `hoursPlayed` aos payloads de create/update.
- **`TrackingEditorSheet`**: modo para jogos com seletor de plataforma e campo de horas.
- **`TrackingStatusChip`**: usar `GameTrackingStatus` quando `mediaType == MediaType.game`.
- **`SeriesSearchPage`**: adicionar branch de jogos, delegando para `GameSearchViewModel`.
- **`TrackingListPage`**: reconhecer `MediaType.game` na navegação e empty states.
- **`DashboardPage`**: reconhecer `MediaType.game` na navegação e empty states.
- **`social_activity_verb.dart`**: adicionar tradução para `STARTED_PLAYING`.
- **`router.dart`**: adicionar rota `/games/:gameId`.

### Roteamento

- `/games/:gameId` (parâmetro string), análogo a `/series/:tmdbId` e `/movies/:tmdbId`.
- Navegação a partir de dashboard, listas e social verifica `mediaType` e direciona para `/games/:mediaId`.

## Componentes

### Models

```dart
@freezed
abstract class GameModel with _$GameModel {
  const factory GameModel({
    required String gameId,
    required String title,
    String? summary,
    String? genre,
    String? coverUrl,
    String? backdropUrl,
    String? releaseDate,
    @Default([]) List<String> platforms,
    String? developer,
    String? publisher,
    String? franchise,
    @Default([]) List<String> gameModes,
  }) = _GameModel;

  factory GameModel.fromJson(Map<String, dynamic> json) =>
      _$GameModelFromJson(json);
}
```

### Status e plataformas

- `GameTrackingStatus` encapsula os valores de status e seus labels traduzidos.
- `GamePlatform` encapsula valores fixos + `other`. Quando `other` é selecionado, o usuário preenche texto livre; esse texto é enviado ao backend como `selectedPlatform`.

### Repositories

- `GameRepository`:
  - `searchGames(String query, {int page = 1, int limit = 20, CancelToken? cancelToken})` → `GET /games?q=&page=&limit=`
  - `getGameById(String gameId)` → `GET /games/:gameId`

### ViewModels

- `GameSearchViewModel`: busca com cancelamento de requisições anteriores.
- `GameDetailViewModel`:
  - Carrega `GameModel` + `TrackedMediaModel?` de forma paralela.
  - `addTracking(status, {required selectedPlatform, rating, review})` — `selectedPlatform` é obrigatório no create; `hoursPlayed` normalmente é preenchido posteriormente, mas pode ser enviado se o usuário já tiver jogado.
  - `updateTracking({status, selectedPlatform, hoursPlayed, rating, review})`
  - `removeTracking()`

### Widgets

- `GameCard`: card de resultado de busca.
- `GameDetailPage`: layout similar a `MovieDetailPage`, exibindo capa/backdrop, gênero, plataformas, overview, desenvolvedora, publicadora, modos de jogo e data de lançamento.
- `GamePlatformSelector`: seletor de plataforma fixa com opção "Outro" + texto livre.
- `GameHoursField`: campo numérico para horas jogadas (`double`, `>= 0`).

### Widgets compartilhados adaptados

- `TrackingEditorSheet`: recebe parâmetros opcionais para plataforma/horas e renderiza os widgets de jogo quando necessário.
- `MediaTypeToggle`: continua iterando sobre `MediaType.values`, exibindo automaticamente "Jogos".
- `TrackingStatusChip`: delega para `GameTrackingStatus` quando aplicável.

## Data Flow

### Busca

1. Usuário seleciona "Jogos" no `MediaTypeToggle` de `/search`.
2. `SeriesSearchPage` limpa viewmodels de séries/filmes e delega para `gameSearchViewModelProvider`.
3. `GameSearchViewModel` chama `GameRepository.searchGames(query)`.
4. Repositório faz `GET /games?q=...&page=1&limit=20`.
5. Resultados são exibidos via `GameCard`.

### Detalhe do jogo

1. Toque em `GameCard` navega para `/games/:gameId`.
2. `GameDetailViewModel` dispara duas chamadas paralelas:
   - `GameRepository.getGameById(gameId)` → `GameModel`
   - `TrackingRepository.getTrackingByMedia(gameId, MediaType.game)` → `TrackedMediaModel?`
3. Estado é montado como `GameDetailState(game, tracking)`.
4. Toque no botão de tracking abre `TrackingEditorSheet` no modo jogo.
5. Ao salvar:
   - Novo tracking: `POST /tracking` com `mediaId`, `mediaType=GAME`, `status`, `selectedPlatform`. Opcionalmente `hoursPlayed` se o usuário já tiver horas registradas.
   - Edição: `PUT /tracking/:mediaId?mediaType=game` com `status`, `rating`, `review`, `selectedPlatform`, `hoursPlayed`.
6. Após sucesso, limpa cache de dashboard/tracking e invalida o viewmodel.

### Dashboard / Minhas Listas

1. Toggle em "Jogos" atualiza `selectedMediaTypeProvider`.
2. `DashboardViewModel`/`TrackingListViewModel` reagem e chamam `/dashboard?mediaType=GAME` ou `/tracking?mediaType=game`.
3. A resposta usa os mesmos models (`DashboardModel`, `TrackedMediaModel`).
4. Navegação de itens verifica `mediaType` e direciona para `/games/:mediaId`.

### Social

1. Feed social recebe eventos com `mediaType: "GAME"` e `activityType: "STARTED_PLAYING"`, `"COMPLETED"` ou `"ADDED_TO_LIST"`.
2. `social_activity_verb.dart` traduz `STARTED_PLAYING` para "começou a jogar".
3. Clique no título do jogo no feed navega para `/games/:mediaId`.

## Error Handling

### Erros de rede/servidor

- `GameRepository` converte `DioException` em `ServerException`, igual a séries/filmes.
- `GameDetailPage` e `GameSearchPage` exibem `AppErrorWidget` com retry.
- `GameDetailViewModel` trata 404 de tracking como `null` (não acompanha), não como erro.

### Validação no frontend

- **Busca vazia:** não dispara busca com menos de 2 caracteres (evita o 400 do backend).
- **Plataforma obrigatória:** botão de salvar desabilitado até `selectedPlatform` estar preenchido.
- **Horas jogadas:** `GameHoursField` aceita apenas `double >= 0`; salvar bloqueado enquanto inválido.
- **Status inválido:** impossível com `GameTrackingStatus` no frontend.

### Validação do backend

- 400 do backend (plataforma inválida, horas negativas) resulta em `SnackBar` com mensagem do `ServerException.message` ou fallback `error_server`.
- `TrackingEditorSheet` mantém o modal aberto em caso de erro, permitindo correção.

### Cache

- Mesma estratégia das outras mídias: cache de 6h para dashboard/tracking, com chaves `dashboard:v2:GAME` e `tracking:v2:GAME:...`.
- Após create/update/delete de tracking de jogo, remove a chave de dashboard atual (`dashboard:v2:GAME`) e o prefixo `tracking:v2:`.

## Testing

O projeto exige 100% de line + branch coverage (`make test-coverage`).

### Unit tests

- `test/features/games/data/repositories/game_repository_test.dart` — mock Dio para `searchGames` e `getGameById`.
- `test/features/games/data/models/game_model_test.dart` — serialização JSON.
- `test/features/games/viewmodels/game_search_viewmodel_test.dart` — busca, cancelamento, clear.
- `test/features/games/viewmodels/game_detail_viewmodel_test.dart` — build, add/update/remove tracking.
- `test/features/tracking/data/models/game_tracking_status_test.dart` — labels e fromString.
- `test/features/tracking/data/models/game_platform_test.dart` — enum ↔ string.

### Widget tests

- `test/features/games/widgets/game_card_test.dart`
- `test/features/games/widgets/game_platform_selector_test.dart`
- `test/features/games/widgets/game_hours_field_test.dart`
- `test/features/tracking/widgets/tracking_editor_sheet_test.dart` — estender para modo jogo.
- `test/features/tracking/widgets/tracking_status_chip_test.dart` — status de jogos.

### Router / integração leve

- `test/router_test.dart` — adicionar caso para `/games/:gameId`.

### Golden tests

- `test/visual/pages/game_detail_page_golden_test.dart`
- `test/visual/pages/game_search_page_golden_test.dart`

## Riscos e considerações

1. **IDs de jogos são strings:** diferente de séries/filmes (int `tmdbId`). A rota `/games/:gameId` e o `GameModel` tratam isso de forma isolada.
2. **Plataformas fixas:** a lista de plataformas é configurada no frontend. Mudanças futuras exigem alterar `GamePlatform` e as traduções.
3. **Status separado:** `GameTrackingStatus` evita enviar status inválidos, mas duplica lógica de labels/cores em relação a `TrackingStatus`.
4. **Payload de tracking:** o backend aceita `selectedPlatform` e `hoursPlayed` apenas para jogos. O repositório deve incluí-los apenas quando relevante.
5. **Cache:** o prefixo `tracking:v2:` e a chave `dashboard` devem ser invalidados corretamente após mutações de jogos.

## Decisões

| Decisão | Escolha | Motivo |
|---|---|---|
| Arquitetura | Feature isolada `features/games/` | Segue o padrão existente; baixo risco. |
| IDs de jogos | `String` | Backend tem autonomia sobre o formato. |
| Status de tracking | Enum separado `GameTrackingStatus` | Permite labels específicos e futura evolução independente. |
| Plataformas | Enum fixo + "Outro" | Facilita configuração futura e mantém validação no frontend. |
| Toggle de mídia | 3 opções no `MediaTypeToggle` existente | Consistente com dashboard/search/tracking atuais. |
| Recomendações | Fora do escopo | Feature ainda não pronta para nenhuma mídia. |

## Próximos passos

Após aprovação deste design, invocar o skill `writing-plans` para criar o plano de implementação detalhado.
