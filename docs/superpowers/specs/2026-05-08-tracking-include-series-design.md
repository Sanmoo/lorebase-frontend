# Tracking: Incluir Dados da Série no Endpoint (includeSeries)

## Contexto

A aba My Lists exibe todos os tracking items retornados pelo endpoint `GET /tracking`. O frontend mostra um grid de posters das séries. Porém, o frontend **não envia** `includeSeries=true` na requisição, então o backend retorna apenas metadados do tracking (`trackingId`, `seriesId`, `status`, etc.) sem incluir os dados da série.

Isso faz com que o campo `series` no `TrackedSeriesModel` seja `null`, e o frontend exiba um ícone de TV desligada (`Icons.tv_off`) em vez do poster e título de cada série.

O backend **já implementou** o suporte a `includeSeries=true` no endpoint `GET /tracking` (ver `e2e/features/tracking.feature:123-173`). A única mudança necessária é no frontend.

## Contrato da API

### Endpoint: `GET /tracking`

Query parameter:

| Parâmetro | Tipo | Obrigatório | Padrão | Descrição |
|-----------|------|-------------|--------|-----------|
| `includeSeries` | boolean | não | `false` | Quando `true`, cada item inclui o objeto `series` populado |

### Objeto `series` retornado (fonte: tracking.feature)

```json
{
  "series": {
    "tmdbId": 46260,
    "title": "O Ensaio",
    "overview": "Brazilian comedy sketch series.",
    "posterPath": "https://image.tmdb.org/t/p/w500/8gP1g7fGysWfQqHZFQjBg8F6ys.jpg",
    "genres": ["Comedy"],
    "seasonCount": 4,
    "status": "Ended"
  }
}
```

O backend **não** retorna `backdropPath`, `firstAirDate` ou `networks`. Isso não quebra o parsing porque `SeriesModel.fromJson` (Freezed) trata esses campos como nullable/String? ou com `@Default([])`.

## Mudança no Frontend

### `TrackingRepositoryImpl.getTracking()`

Adicionar `'includeSeries': true` aos query parameters:

```dart
final response = await _dio.get(
  '/tracking',
  queryParameters: {
    if (status != null) 'status': status,
    'page': page,
    'pageSize': pageSize,
    'includeSeries': true,
  },
);
```

### Demais camadas

Nenhuma mudança necessária:
- `TrackedSeriesModel` — o `@freezed` `fromJson` já faz o parsing do objeto `series` quando presente
- `SeriesModel` — aceita campos ausentes sem quebrar
- ViewModel — não precisa de alteração
- UI — não precisa de alteração

## Testes

### Atualizar teste do repositório

No `test/features/tracking/data/repositories/tracking_repository_test.dart`, o teste que verifica query params de `getTracking()` precisa incluir `'includeSeries': true`.

### Feature do backend (já existe)

O cenário `Listar tracking com enriquecimento de séries` em `tracking.feature` cobre o contrato do backend — nenhum cenário novo necessário no backend.
