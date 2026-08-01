# Bug Report — Catálogo de games vazio no QA (detalhe 404 + tracking GAME falha)

| Campo | Valor |
|---|---|
| **Repositório** | `lorebase-backend` |
| **Ambiente** | QA (workspace Terraform `qa`) |
| **Endpoints afetados** | `GET /games/{id}` (BFF `experience-bff`) e `POST /tracking` com `mediaType=game` |
| **Severidade** | Alta — página de detalhe de jogo e tracking de games quebrados no app QA; bloqueia suíte E2E de games do frontend |
| **Data do report** | 2026-08-01 |
| **Reportado por** | Time de frontend (suíte E2E) |
| **Hipótese principal** | Tabela do catálogo de games vazia no QA (rows de detalhe ausentes; busca usa outro índice/fonte e funciona) |

---

## Resumo executivo

No ambiente QA, a **busca de games funciona** (`GET /games?q=...` → 200 com itens completos), mas **qualquer detalhe por ID falha** (`GET /games/{id}` → 404 para TODOS os IDs testados) e **criar tracking de game falha** (`POST /tracking` com `mediaType=game` → 404 com `LAMBDA_ERROR: Resource not found`). Comportamento consistente com catálogo de games **sem rows de detalhe** no QA: a busca serve de índice (provável fonte externa/outro path) e o detalhe/tracking dependem de lookup na tabela do catálogo.

## Impacto

- App web (frontend) no QA: buscar jogos funciona; **clicar em um jogo → página de detalhe falha**; **adicionar jogo ao acompanhamento falha**.
- Suíte de aceitação E2E do frontend (`lorebase-frontend`, `e2e/` — Playwright + Gherkin pt-BR): cenários de games (busca OK; detalhe e tracking bloqueados).
- Tracking de séries/filmes NÃO é afetado (SERIES 201 OK — verificado).

## Reprodução

Pré-requisito: token Cognito válido do usuário de teste QA.

```bash
TOKEN=<access_token_cognito_qa>
API=https://i3kmbru0dh.execute-api.us-east-1.amazonaws.com/   # api_gateway_endpoint do workspace qa

# ✅ Funciona — busca
curl -i "$API/games?q=Hades&limit=5" -H "Authorization: Bearer $TOKEN"
# → 200 {"items":[{"gameId":"113112","title":"Hades",...}]}

# ❌ Falha — detalhe (404 para TODOS os IDs testados: 113112, 1022, 1234, 5678, 9012)
curl -i "$API/games/113112" -H "Authorization: Bearer $TOKEN"
# → 404 {"error":{"code":"NOT_FOUND","message":"..."}}

# ❌ Falha — tracking de game
curl -i -X POST "$API/tracking" -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"mediaId":"113112","mediaType":"game","status":"WANT_TO_PLAY","selectedPlatform":"PC"}'
# → 404 {"error":{"code":"LAMBDA_ERROR","message":"Resource not found"}}

# ✅ Controle — tracking de série funciona
curl -i -X POST "$API/tracking" -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"mediaId":"1396","mediaType":"SERIES","status":"WANT_TO_WATCH"}'
# → 201
```

## Evidências coletadas

| Request | Status | Interpretação |
|---|---|---|
| `GET /games?q=Hades` | 200 | Busca funciona (índice/fonte externa) |
| `GET /games?q=Zelda` | 200 | Idem; retorna gameId "1022" etc. |
| `GET /games/113112` (Hades da busca) | **404** | Detalhe por ID falha |
| `GET /games/1022` (Zelda da busca) | **404** | Idem |
| `GET /games/1234` (ID seedado pelo e2e backend) | **404** | Idem — tabela não tem nem os rows seedados (e2e backend não rodou/seed foi limpo) |
| `GET /games/5678`, `GET /games/9012` | **404** | Idem |
| `POST /tracking` mediaType=game | **404** `LAMBDA_ERROR: Resource not found` | user-tracking não consegue enriquecer via catálogo |
| `POST /tracking` mediaType=SERIES | 201 | Controle OK — bug é específico de games |

## Análise (cadeia de código)

1. **Busca**: BFF `experience-bff/cmd/api/main.go` → `gameHandler.HandleSearch` → `GameCatalogClient.Search` → lambda `GAME_CATALOG_URL` (`GET /search`) → **funciona no QA** (lambda existe e responde).
2. **Detalhe**: `gameHandler.HandleGet` → `GameCatalogClient.Get` → lambda (`GET /{id}`) → **404** — o serviço game-catalog não encontra a row na tabela (IDs de busca vs. rows ausentes).
3. **Tracking GAME**: BFF `TrackingHandler.HandleCreate` → `UserTrackingClient.StartTracking` (mesmo lambda user-tracking usado por SERIES — que funciona) → o serviço user-tracking, ao criar tracking de game, consulta o catálogo de games (`user-tracking/internal/infrastructure/game_catalog_client.go`) → row não existe → erro "Resource not found" → BFF devolve `LAMBDA_ERROR`.
4. O e2e do backend (godog) **semeia o catálogo** ao rodar (`e2e/steps/common_steps.go` — `gameCatalogSeedOnce`: `ClearGameCatalog` + `SeedGame` com IDs 1234/5678/9012) e **limpa no teardown** (`state.TrackCleanup`). Commits recentes ("fix(e2e): stop QA runs from skipping tests and wiping catalog tables", "fix: resolve E2E suite failures in QA environment") sugerem fluxo recente de wipe/seed no QA.

## Como investigar (sugestões)

- Confirmar estado da tabela: `aws dynamodb scan --table-name game-catalog-qa` (com credenciais do workspace qa) — verificar se há rows e quais IDs.
- Rodar o e2e de games do backend contra QA (`make test-e2e-qa` no `lorebase-backend/e2e`, features `games_search.feature`/`games_tracking.feature`) — isso semeia o catálogo; re-testar `GET /games/5678` depois.
- Verificar se o wipe/clear do catálogo está sendo executado fora do seed (teardown global? job de manutenção?).

## Sugestão de correção

- **Curto prazo**: semear o catálogo de games no QA (rodar o e2e backend de games, ou job de seed dedicado com os games de teste estáveis: "Hades" 5678, "The Legend of Zelda: Breath of the Wild" 1234, "Stardew Valley" 9012) e **não limpar** após.
- **Médio prazo**: investigar por que o QA perdeu as rows (teardown do e2e? deploy com tabela nova?); alinhar IDs entre catálogo e busca (os IDs da busca — 113112, 1022 — não existem como rows: a busca vem de fonte externa com IDs diferentes dos seedados, o que também quebra o fluxo do app real: o app navega para `/games/{gameId}` usando o ID da busca e recebe 404).

## Contexto

- Descoberto ao planejar a fase 2 da suíte E2E do frontend (`lorebase-frontend`, branch/`main` — pasta `e2e/`, Playwright + Gherkin pt-BR): cenários de games (busca, detalhe, tracking com plataforma, minha lista).
- Antecedente: bug semelhante de busca de séries no QA (cache sem locale → 500) foi reportado em `BUG-REPORT-qa-series-search-500.md` e corrigido pelo time de backend.
- Tracking de séries e busca de séries continuam saudáveis no QA (verificados 200/201 hoje).
