# Tracking List: Substituir Status Chip por Rating Stars

## Contexto

A aba My Lists exibe séries em um grid de 3 colunas. Cada card mostra o poster da série e, abaixo dele, um `TrackingStatusChip` com o label do status (ex: "Watching", "Completed").

Como cada tab filtra por um status específico (ex: tab "Completed" só mostra séries completadas), o chip é redundante — o usuário já sabe o status pelo nome da aba.

O modelo `TrackedSeriesModel` já inclui `seriesRating` (int? de 1 a 10), populado quando o usuário avaliou a série.

## Mudança

### tracking_list_page.dart:117-118

Substituir:

```dart
const SizedBox(height: 4),
TrackingStatusChip(status: tracking.status),
```

por:

```dart
const SizedBox(height: 4),
RatingStars(
  rating: tracking.seriesRating,
  size: 12,
),
```

### Comportamento

| Cenário | Antes | Depois |
|---------|-------|--------|
| Série avaliada (rating 1-10) | Chip "Completed" | Estrelas preenchidas |
| Série não avaliada (rating null) | Chip "Watching" | Estrelas vazias (layout consistente) |

### Testes

- `shows TrackingStatusChip per item` → atualizar para verificar que `RatingStars` (ou `Icons.star`/`Icons.star_border`) está presente
- Os demais testes permanecem inalterados

### Arquivos afetados

- **Modificar:** `lib/features/tracking/pages/tracking_list_page.dart` (2 linhas)
- **Modificar:** `test/features/tracking/pages/tracking_list_page_test.dart` (atualizar asserção)
