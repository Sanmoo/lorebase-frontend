# Fix: Minhas Listas — erro `type 'Null' is not a subtype of type 'String'` ao carregar séries

**Data:** 2026-05-16
**Status:** Approved

## Problema

A página de Minhas Listas (`/tracking`) não carrega séries. O erro ocorre durante a deserialização
JSON do campo `media` (embed do `TrackedMediaModel`), com a exceção:

```
type 'Null' is not a subtype of type 'String' in type cast
```

## Causa raiz

O `TrackedMediaSummaryModel` (modelo do campo `media`) tem um **descasamento com o contrato
real da API**. A API retorna um objeto com nomes e tipos de campo diferentes dos esperados
pelo modelo.

### API response real (campo `media`)

```json
{
    "tmdbId": 101918,
    "title": "Valéria",
    "overview": "...",
    "posterPath": "...",
    "backdropPath": "...",
    "genres": ["Other"],
    "seasonCount": 4,
    "status": "Ended"
}
```

### O que o modelo esperava

| Campo no modelo | Tipo | JSON key esperada | Presente na API? |
|----------------|------|-------------------|-------------------|
| `mediaId` | `String` (required) | `mediaId` | ❌ API retorna `tmdbId` (int) |
| `title` | `String` (required) | `title` | ✅ |
| `mediaType` | `MediaType` (required) | `mediaType` | ❌ Ausente |
| `overview` | `String?` | `overview` | ✅ |
| `posterPath` | `String?` | `posterPath` | ✅ |
| `status` | `String?` | `status` | ✅ |
| `seasonCount` | `int?` | `seasonCount` | ✅ |
| `trackingRating` | `int?` | `trackingRating` | ❌ Ausente |
| `addedAt` | `DateTime?` | `addedAt` | ❌ Ausente |

O cast `json['mediaId'] as String` falha porque `json['mediaId']` é `null` (a chave não existe).
Isso produz o erro `type 'Null' is not a subtype of type 'String'`.

O mesmo aconteceria com `json['mediaType'] as String` se o `mediaId` não falhasse primeiro.

## Design da solução

### 1. Mapear `mediaId` ← `tmdbId` (int → String)

Adicionar ao `json_converters.dart`:

```dart
String flexibleStringFromJson(dynamic value) {
  if (value is String) return value;
  if (value is int) return value.toString();
  throw FormatException('Cannot convert $value (${value.runtimeType}) to String');
}
String flexibleStringToJson(String value) => value;
```

No modelo:
```dart
@JsonKey(name: 'tmdbId', fromJson: flexibleStringFromJson, toJson: flexibleStringToJson)
required String mediaId,
```

O converter aceita tanto `int` (API) quanto `String` (cache round-trip), mantendo
`mediaId` como `String` para uso em navegação (`/series/${media.mediaId}`).

### 2. Tornar `mediaType` nullable

API não retorna `mediaType` dentro do objeto `media`. O código que consome este campo
usa `tracking.mediaType` (do modelo pai), não `media.mediaType`.

```dart
MediaType? nullableMediaTypeFromJson(dynamic value) {
  if (value == null) return null;
  if (value is String) return mediaTypeFromJson(value);
  throw FormatException('Cannot convert $value to MediaType');
}
dynamic? nullableMediaTypeToJson(MediaType? value) => value?.apiValue;
```

No modelo:
```dart
@JsonKey(fromJson: nullableMediaTypeFromJson, toJson: nullableMediaTypeToJson)
MediaType? mediaType,
```

### 3. Campos já opcionais

`trackingRating` (int?), `seasonCount` (int?), `addedAt` (DateTime?) já são nullable.
Campos extras da API (`backdropPath`, `genres`) são ignorados automaticamente pelo
`json_serializable` com `ignoreUnknownKeys` (comportamento default).

## Arquivos alterados

| Arquivo | Ação |
|---------|------|
| `lib/core/utils/json_converters.dart` | Adicionar `flexibleStringFromJson`, `flexibleStringToJson`, `nullableMediaTypeFromJson`, `nullableMediaTypeToJson` |
| `lib/features/tracking/data/models/tracked_media_summary_model.dart` | Atualizar annotations de `mediaId` e `mediaType` |
| `*.g.dart` / `*.freezed.dart` | Regenerar via `dart run build_runner build` |
| `test/features/tracking/data/models/tracked_media_model_test.dart` | Corrigir fixture JSON: chave `'mediaId'` → `'tmdbId'` com valor `int` |
| `test/features/tracking/data/models/tracked_media_summary_model_test.dart` | Ajustar se necessário |

## O que NÃO quebra

- **Cache round-trip**: `toJson` → `fromJson` — `flexibleStringFromJson` aceita `String` (cache) e `int` (API)
- **Construção direta**: `TrackedMediaSummaryModel(mediaId: '42', title: '...')` continua funcionando
- **Navegação**: `'/series/${media.mediaId}'` — `mediaId` permanece `String`
- **Poster widget**: usa apenas `media.title` e `media.posterPath`

## Verificação

Após a implementação:
1. `dart run build_runner build --delete-conflicting-outputs` — sem erros
2. `dart analyze --fatal-infos` — sem warnings/errors
3. `flutter test` — todos os testes passam
4. `make check` — coverage gate a 100%
