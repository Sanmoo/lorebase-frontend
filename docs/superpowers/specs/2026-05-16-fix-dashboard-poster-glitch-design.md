# Fix: Regressão do glitch de imagem nos posters do Dashboard

**Data:** 2026-05-16
**Status:** Approved

## Problema

Os posters exibidos na página Início (Dashboard) apresentam novamente o glitch de renderização
no topo da imagem — pixels corrompidos no canto superior esquerdo. Este bug já havia sido
resolvido anteriormente (commit `49adb46`), mas um widget criado posteriormente não recebeu
o workaround.

## Causa raiz

O widget `TrackedMediaPoster` foi criado após o commit do fix original (`49adb46`, 2026-05-08),
no commit `0e2550f` (2026-05-13), e por isso **não possui o `OverflowBox` workaround** que
empurra os pixels corrompidos para fora da área visível.

O `TrackedMediaPoster` é usado no Dashboard via:
`DashboardPage` → `DashboardSection` → `TrackedMediaHorizontalList` → `TrackedMediaPoster`

E também na aba Minhas Listas (`TrackingListPage` → `TrackedMediaPoster`).

## Workaround existente (commit `49adb46`)

O bug é um glitch conhecido do Flutter/Skia no Android, onde imagens renderizadas podem
apresentar pixels corrompidos no canto superior esquerdo. A solução usa `OverflowBox` com
**12px de altura extra** e `alignment: Alignment.bottomCenter`:

- A imagem é renderizada com 12px a mais de altura que o container visível
- O alinhamento ao fundo (`bottomCenter`) posiciona o excesso para cima
- O `ClipRRect` do container corta a região excedente (onde estão os pixels corrompidos)

## Design da solução

### Única mudança: `TrackedMediaPoster`

**Arquivo:** `lib/features/tracking/widgets/tracked_media_poster.dart`

**Antes:**

```dart
ClipRRect(
  borderRadius: BorderRadius.circular(8),
  child: Container(
    width: width,
    height: width * 1.5,
    color: Colors.grey[300],
    child: media.posterPath != null && media.posterPath!.isNotEmpty
        ? CachedNetworkImage(
            imageUrl: media.posterPath!,
            imageRenderMethodForWeb: ImageRenderMethodForWeb.HttpGet,
            fit: BoxFit.cover,
            errorWidget: (context, url, error) =>
                const Icon(Icons.broken_image),
          )
        : const Icon(Icons.broken_image),
  ),
),
```

**Depois:**

```dart
ClipRRect(
  borderRadius: BorderRadius.circular(8),
  child: Container(
    width: width,
    height: width * 1.5,
    color: Colors.grey[300],
    child: media.posterPath != null && media.posterPath!.isNotEmpty
        ? OverflowBox(
            minWidth: width,
            maxWidth: width,
            minHeight: width * 1.5 + 12,
            maxHeight: width * 1.5 + 12,
            alignment: Alignment.bottomCenter,
            child: CachedNetworkImage(
              imageUrl: media.posterPath!,
              imageRenderMethodForWeb: ImageRenderMethodForWeb.HttpGet,
              width: width,
              height: width * 1.5 + 12,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) =>
                  const Icon(Icons.broken_image),
            ),
          )
        : const Icon(Icons.broken_image),
  ),
),
```

### O que permanece inalterado

- Altura visível do poster: `width * 1.5` (ex: 180px p/ width=120)
- Altura da `TrackedMediaHorizontalList`: 232px
- Largura do poster: `width` (120px default)
- Placeholder (container cinza) enquanto carrega
- `imageRenderMethodForWeb: HttpGet` para compatibilidade CanvasKit

## Arquivos alterados

| Arquivo                                                   | Ação                                                      |
| --------------------------------------------------------- | --------------------------------------------------------- |
| `lib/features/tracking/widgets/tracked_media_poster.dart` | Adicionar `OverflowBox` envolvendo o `CachedNetworkImage` |

Nenhum `.g.dart` ou `.freezed.dart` precisa ser regenerado.

## Verificação

1. `dart analyze --fatal-infos` — sem warnings/errors
2. `flutter test` — todos os testes passam
3. `make check` — coverage gate a 100%
4. Teste visual: abrir Dashboard e verificar que os posters não apresentam pixels corrompidos no topo
