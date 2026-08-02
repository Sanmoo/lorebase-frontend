# Change Request — Create atômico de tracking: enviar rating/review no POST /tracking

| Campo | Valor |
|---|---|
| **Repositório** | `lorebase-frontend` |
| **Ambiente** | QA (deploy de 2026-08-02) |
| **Endpoint** | `POST /tracking` (BFF `experience-bff` → lambda `user-tracking`) |
| **Status** | Backend pronto e validado — aguarda adoção do app |

## Resumo

O backend agora aceita `rating`/`review` (e os aliases legados `seriesRating`/`seriesReview`) no `POST /tracking`, criando o tracking completo em UMA requisição atômica. O app hoje contorna a limitação com um `PUT /tracking/{id}` de follow-up (games, series e movies) — o workaround deve ser removido.

## Contrato novo (POST /tracking)

```json
{
  "mediaId": "5678",
  "mediaType": "GAME",
  "status": "WANT_TO_PLAY",
  "selectedPlatform": "Switch",
  "hoursPlayed": 10,
  "rating": 9,
  "review": "muito bom"
}
```

- `rating`: inteiro 1–10; `review`: texto livre.
- Aliases legados `seriesRating`/`seriesReview` também aceitos (nome moderno vence se ambos enviados).
- Resposta 201 inclui `rating`/`review` persistidos.
- `rating` fora de 1–10 → `400 VALIDATION_ERROR`.

## Mudanças esperadas no app

1. `TrackingRepository.startTracking` (interface + impl) aceitar `rating`/`review` e enviá-los no body do POST.
2. `GameDetailViewModel.addTracking`, `SeriesDetailViewModel.addTracking`, `MovieDetailViewModel.addTracking`: remover o `updateTracking` de follow-up (o `hasExtra`/`if (hasExtra)`).
3. Enviar os nomes modernos (`rating`/`review`) no create.

## Testes a atualizar

- `test/features/tracking/data/repositories/tracking_repository_test.dart`
- `test/features/games/viewmodels/game_detail_viewmodel_test.dart`
- `test/features/series/viewmodels/series_detail_viewmodel_test.dart`
- `test/features/movies/viewmodels/movie_detail_viewmodel_test.dart`

## Benefício

- 1 requisição em vez de 2; sem janela de falha entre POST e PUT (estado parcial).
- Feed de atividades inalterado (mesmos eventos `RATED`/`REVIEWED`).
- E2E de referência: cenários "Adicionar jogo com nota, review e horas em uma única requisição" e "Adicionar série com nota e review em uma única requisição" no `e2e` do backend.
