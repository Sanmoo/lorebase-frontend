> **RESOLVIDO 2026-08-01** — bug já corrigido pelo time de backend
> (verificado: busca com termo em cache retorna 200). Report mantido como
> registro do incidente descoberto pela suíte E2E.

# Bug Report — Busca de séries retorna 500 no ambiente QA

| Campo | Valor |
|---|---|
| **Repositório** | `lorebase-backend` |
| **Ambiente** | QA (workspace Terraform `qa`) |
| **Endpoint** | `GET /series?q={termo}` (BFF `experience-bff`) |
| **Severidade** | Alta — quebra a busca do app no QA e a suíte de aceitação E2E do frontend |
| **Data do report** | 2026-08-01 |
| **Reportado por** | Time de frontend (suíte E2E) |
| **Regressão suspeita** | Commit `f49169c` ("fix: avoid QA locale regressions in cached search and tracking") |

---

## Resumo executivo

A busca de séries no ambiente QA retorna **HTTP 500 persistente** quando o termo pesquisado já existe no cache local (DynamoDB) mas **sem dados localizados no idioma atual (pt-BR)**. Nesse caso o fluxo tenta enriquecer o locale via TMDB (`GetSeriesDetails`) e, se essa chamada falhar, o endpoint inteiro responde `INTERNAL_ERROR` — sem fallback.

Termos **não cacheados** funcionam (vão direto ao TMDB search e populam o cache com locale resolvido). Endpoints de detalhe (`GET /series/1396`) e tracking (`GET/POST/DELETE /tracking`) estão saudáveis.

## Impacto

- App web (frontend) no ambiente quality: buscar "Breaking Bad" ou qualquer série já cacheada sem locale pt-BR → tela sem resultados / erro.
- Suíte de aceitação E2E do frontend (Playwright + Gherkin, `lorebase-frontend`): cenário "Buscar série pelo título" bloqueado (cenário usa "Breaking Bad", que está em cache no QA).
- Não afeta produção nem dev (até onde sabemos) — caracterizado apenas no QA.

## Reprodução

Pré-requisito: token Cognito válido do usuário de teste QA (mesmo usado pelo e2e do backend: `E2E_COGNITO_USERNAME`/`E2E_COGNITO_PASSWORD`).

```bash
TOKEN=<access_token_cognito_qa>
API=https://i3kmbru0dh.execute-api.us-east-1.amazonaws.com/   # api_gateway_endpoint do workspace qa

# ❌ Falha (termo em cache sem locale pt-BR)
curl -i "$API/series?q=Breaking%20Bad&limit=5" -H "Authorization: Bearer $TOKEN"
# → HTTP 500 {"error":{"code":"INTERNAL_ERROR","message":"Internal server error"}}

curl -i "$API/series?q=breaking&limit=5" -H "Authorization: Bearer $TOKEN"
# → HTTP 500 (idem)

# ✅ Funciona (termo não cacheado → TMDB search → cache com locale)
curl -i "$API/series?q=The%20Office&limit=5" -H "Authorization: Bearer $TOKEN"
# → HTTP 200

# ✅ Funciona (detalhe por ID)
curl -i "$API/series/1396" -H "Authorization: Bearer $TOKEN"
# → HTTP 200
```

Observação: "The Office" retorna 200 mesmo na 2ª chamada (após a 1ª, fica em cache **com** locale pt-BR — não passa pelo caminho de enriquecimento).

## Evidências coletadas

| Request | Status | Interpretação |
|---|---|---|
| `GET /series?q=Breaking%20Bad` | **500** | Cache hit (tmdbId 1396) sem locale pt-BR → falha no enriquecimento |
| `GET /series?q=breaking` | **500** | Idem (prefixo casa com "Breaking Bad" no GSI de título) |
| `GET /series?q=game` | 200 | Sem cache hit relevante |
| `GET /series?q=The%20Office` (1ª) | 200 | TMDB search direto; salva com locale |
| `GET /series?q=The%20Office` (2ª) | 200 | Cache hit **com** locale → não entra no caminho de erro |
| `GET /series/1396` | 200 | Detalhe OK |
| `GET /tracking?includeMedia=true` | 200 | Tracking OK |
| `DELETE /tracking/1396?mediaType=SERIES` | 404 | Tracking OK (404 = não existe, esperado) |
| `GET /series` (sem `q`) | 400 | Esperado (validação) |
| `GET /series/1396` sem token | 401 | Auth OK |

## Análise de causa raiz (cadeia de código)

1. **Frontend → BFF**: `GET /series?q=` → `experience-bff/cmd/api/main.go:212` → `seriesHandler.HandleSearch` (`experience-bff/internal/handlers/series.go:25`) → `client.Search` → chama series-catalog com `GET /search?q=` (`experience-bff/internal/clients/series_catalog_client.go:95-113`).
2. **series-catalog**: `cmd/api/main.go:137` `handleSearch` → `SearchSeriesUseCase.Execute` (`internal/application/search_series.go`).
3. **Fluxo do use case** (`search_series.go`):
   - `repository.SearchByTitle` (cache, GSI `title-index`) → itens com dados localizados no locale → entram direto em `results`.
   - Itens **sem** o locale atual entram em `unresolved` (linha ~48).
   - Para cada item `unresolved` (linha ~57): tenta `strconv.Atoi(tmdbIdStr)` (linha ~63) e depois `tmdbClient.GetSeriesDetails(ctx, tmdbId, locale)` (linha ~70).
   - **Se qualquer um desses falhar → `return nil, error` → HTTP 500** (linhas ~66-76). Não há fallback.
4. **TMDB details** (`internal/infrastructure/tmdb_client.go:173-185`): `GET /tv/{id}` com `language` do locale; qualquer status ≠ 200 → `fmt.Errorf("TMDB API returned status %d", ...)` → propaga para o 500.

### Regressão

O commit **`f49169c`** (2026-05-12, "fix: avoid QA locale regressions in cached search and tracking") reescreveu esse trecho: antes, falha de TMDB no caminho de locale resolvia **silenciosamente** (resultado sem enriquecimento, sem erro); depois, virou **hard error** (ver diff abaixo). O commit anterior `7b2f10a` ("fix(search): apply locale to cached results and enrich missing locale from TMDB") introduziu o enriquecimento de locale com detalhes do TMDB.

Trecho do diff de `f49169c` (`search_series.go`):

```diff
+	for key, series := range unresolved {
+		tmdbIdStr := series.TmdbId
+		if tmdbIdStr == "" {
+			tmdbIdStr = key
+		}
+
+		tmdbId, convErr := strconv.Atoi(tmdbIdStr)
+		if convErr != nil {
+			return nil, fmt.Errorf("locale %s could not be resolved for cached series: %v", locale, []string{key})
+		}
+
+		details, detailsErr := uc.tmdbClient.GetSeriesDetails(ctx, tmdbId, locale)
+		if detailsErr != nil {
+			return nil, fmt.Errorf("failed to resolve locale for cached results: %w", detailsErr)
+		}
```

## Hipóteses para investigar (em ordem de probabilidade)

1. **TMDB `GET /tv/{id}` falhando no QA** (quota/rate-limit da API key, 401/429/403): `SearchSeries` (busca) funciona, mas `GetSeriesDetails` (detalhe) falha → confirmar com os logs do lambda e/ou chamada manual usando a key do QA. Se for quota, o 500 é intermitente conforme uso; nos testes de hoje foi 100% repro.
2. **Item cacheado com `tmdbId` malformado/vazio** no QA (ex.: linhas gravadas por seed antigo/wipe do catálogo): `strconv.Atoi` falha → 500 sem nem chamar TMDB. Verificar com scan na tabela (ver abaixo).
3. **Locale mismatch**: itens cacheados só com outro locale (ex.: en-US) e enriquecimento pt-BR sempre falhando.

## Como investigar (sugestões)

- **Logs do lambda**: CloudWatch — grupo `series-catalog-api-qa` (nome do grupo definido em `series-catalog/terraform/main.tf:145`; padrão `/aws/lambda/series-catalog-api-${workspace}`). O código já loga `[search_series] TMDB details failed for cached seriesId=... locale=...` e `SearchByTitle error` via `fmt.Printf` — se o grupo estiver em Infrequent Access, `filter-log-events` não funciona; usar `tail` da stream ou mudar para Standard durante a investigação.
- **Dados do cache**: `aws dynamodb scan --table-name series-catalog-qa` — verificar `tmdbId` e o mapa `localized` das séries que casam com "breaking" (Breaking Bad, tmdbId 1396). *Nota: a partir da conta AWS usada aqui, `list-tables` só expõe `lorebase-development` — pode ser questão de permissão/role da sessão; validar com as credenciais do workspace qa.*
- **TMDB direto**: chamar `GET https://api.themoviedb.org/3/tv/1396?language=pt-BR` com a key do QA (`TMDB_API_KEY` — ver como é injetada no lambda/terraform do series-catalog) e comparar com `GET /search/tv?query=Breaking%20Bad&language=pt-BR`.

## Sugestão de correção

No mínimo, **não derrubar a busca inteira por falha de enriquecimento de locale**: no loop de `unresolved`, tratar erro de `GetSeriesDetails` (e do `Atoi`) como item sem enriquecimento — logar, manter o resultado em cache com título do cache e seguir para os demais itens / TMDB search (comportamento pré-`f49169c`). Idealmente, também tornar a busca resiliente a um único item quebrado (um `unresolved` ruim não deve derrubar 10 resultados bons).

Adicionalmente, investigar a causa da falha do TMDB details no QA (hipótese 1) — mesmo com fallback, a busca volta a funcionar, mas o app fica sem descrição/título localizados para itens em cache.

## Contexto

- Descoberto pela suíte de aceitação E2E do frontend (`lorebase-frontend`, branch `feat/acceptance-tests-e2e`, pasta `e2e/` — Playwright + Gherkin pt-BR), Task 5 (cenários de busca e detalhe de série).
- Suíte rodou contra `https://i3kmbru0dh.execute-api.us-east-1.amazonaws.com/` (output do terraform `experience-bff`, workspace `qa`), com usuário de teste Cognito do QA.
- Caminhos alternativos já verificados saudáveis: detalhe por ID (`/series/1396`), tracking (create/list/delete), auth (401 sem token, 200 com token).
