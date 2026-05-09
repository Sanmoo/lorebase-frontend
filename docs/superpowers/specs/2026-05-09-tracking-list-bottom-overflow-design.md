# Tracking List: Corrigir Bottom Overflow nos Cards

## Contexto

Após o fix do `includeSeries=true`, a aba My Lists passou a exibir os posters das séries. Cada card é um `SeriesPoster` com `width: 120` hardcoded (padrão do construtor). O grid de 3 colunas cria células de ~101px (viewport 360dp) a ~119px (viewport 412dp).

O `SeriesPoster` usa `width * 1.5` para altura, resultando em ~180px de imagem + ~14px de título ≈ 198px totais. O grid aloca ~184px por célula (101/0.55). Isso causa "bottom overflowed by xx pixels" em todos os cards.

## Mudança

### tracking_list_page.dart:109-115

Envolver `SeriesPoster` em um `LayoutBuilder` para usar a largura real da célula:

```dart
Expanded(
  child: LayoutBuilder(
    builder: (context, constraints) => SeriesPoster(
      series: series,
      width: constraints.maxWidth,
      onTap: series.tmdbId != 0
          ? () => context.push('/series/${series.tmdbId}')
          : null,
    ),
  ),
),
```

### Comportamento

| Cenário | Antes | Depois |
|---------|-------|--------|
| Viewport 360dp (célula ~101px) | Bottom overflow ~14px | Card cabe perfeitamente |
| Viewport 412dp (célula ~119px) | Bottom overflow ~2px | Card cabe perfeitamente |

### Arquivos afetados

- **Modificar:** `lib/features/tracking/pages/tracking_list_page.dart` (2 linhas adicionadas)
