# Bug Report — Tracking de game: POST descarta hoursPlayed + PUT 404 (mediaType só na query)

| Campo | Valor |
|---|---|
| **Repositório** | `lorebase-backend` |
| **Ambiente** | QA (workspace Terraform `qa`) |

> **STATUS: RESOLVIDO** — validado no QA em 02/08: POST /tracking persiste `hoursPlayed` (201 + GET confirma) e PUT `/tracking/{mediaId}` com `mediaType` no body responde 200 e atualiza status/plataforma/horas. Contrato: `PUT` usa `mediaId` no path (não `trackingId`).
| **Endpoints afetados** | `POST /tracking` e `PUT /tracking/{id}` (BFF `experience-bff` → lambda `user-tracking`) |
| **Severidade** | Média — app envia horas no create, backend descarta; PUT do app (editar tracking) falha 404 no QA para QUALQUER mídia |
| **Data do report** | 2026-08-02 |
| **Reportado por** | Time de frontend (suíte E2E de games) |

## Resumo executivo

Dois gaps no fluxo de tracking contra o QA:

1. **`POST /tracking` ignora `hoursPlayed`**: o create só aceita `mediaId`/`mediaType`/`status`/`selectedPlatform` — horas enviadas pelo app são descartadas silenciosamente (não persistem nem voltam na resposta).
2. **`PUT /tracking/{id}` → 404 quando `mediaType` vai no BODY** (como o app faz): o lambda deployado no QA só lê `mediaType` da **query string**. Com a query (`?mediaType=GAME`) o PUT funciona e persiste horas. O código do repo (branch atual) já lê `mediaType` do body no `handleUpdateProgress` — o deploy do QA está atrás do código.

## Reprodução

```bash
TOKEN=<access_token_cognito_qa>
API=https://i3kmbru0dh.execute-api.us-east-1.amazonaws.com/

# 1) POST com hoursPlayed → 201, resposta SEM hoursPlayed (descartado)
curl -s -X POST "$API/tracking" -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"mediaId":"5678","mediaType":"GAME","status":"WANT_TO_PLAY","selectedPlatform":"Switch","hoursPlayed":10}'
# → {"trackingId":"...","status":"WANT_TO_PLAY","selectedPlatform":"Switch",...}  (sem hoursPlayed)

# 2) PUT como o app faz (mediaType no body, sem query) → 404
curl -s -X PUT "$API/tracking/5678" -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"mediaType":"GAME","status":"WANT_TO_PLAY","selectedPlatform":"Switch","hoursPlayed":10}'
# → 404 {"error":{"code":"LAMBDA_ERROR","message":"Resource not found"}}

# 3) PUT com mediaType na QUERY → 200, persiste e retorna hoursPlayed
curl -s -X PUT "$API/tracking/5678?mediaType=GAME" -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"status":"WANT_TO_PLAY","selectedPlatform":"Switch","hoursPlayed":10}'
# → 200 com "hoursPlayed":10
```

## Análise (cadeia de código)

1. BFF `experience-bff/internal/handlers/tracking.go` — handler de create chama `UserTrackingClient.StartTracking(ctx, ..., status, selectedPlatform, ...)` — **sem parâmetro de horas**; `UpdateTrackingRequest` tem `HoursPlayed` (ok no update).
2. Lambda `user-tracking/cmd/api/main.go` — `handleStartTracking` faz unmarshal em struct com apenas `MediaId, MediaType, Status, SelectedPlatform` — **`hoursPlayed` (e rating/review) não são lidos no create**.
3. `handleUpdateProgress` (PUT) no código atual lê `body.MediaType` — mas o **deploy do QA** aparenta ser anterior a isso: só aceita `mediaType` na query (com body → lookup sem tipo → `Resource not found`).
4. BFF `experience-bff/internal/clients/user_tracking_client.go` — `UpdateProgress` invoca o lambda SEM query params — nunca envia `mediaType` na query.

## Sugestão de correção

- **PUT**: alinhar o deploy do QA com o código atual (body `mediaType`) OU fazer o BFF propagar `mediaType` na query do `UpdateProgress` (mesmo padrão de `DeleteTracking`/`GetTracking`).
- **POST**: aceitar `hoursPlayed` (e idealmente `rating`/`review`) no body do `handleStartTracking` e repassar ao `StartTrackingInput`/use case, persistindo no create (mesmo padrão do PUT).

## Contexto

- Descoberto ao reativar os cenários E2E de games do frontend (`lorebase-frontend`, `e2e/`). O cenário "Adicionar jogo com status, plataforma e horas" foi ajustado para o que funciona hoje (preenche horas, mas só asserta status/plataforma); este report fica para o time de backend.
- Precedente: `BUG-REPORT-qa-games-catalog.md` (mesmo padrão de report de backend pela suíte E2E do frontend).
