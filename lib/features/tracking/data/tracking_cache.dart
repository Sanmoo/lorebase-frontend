/// Ponto único do prefixo das chaves de cache de acompanhamento.
///
/// A versão faz parte da identidade do payload da lista: quando o formato ou a
/// ordenação devolvida pelo servidor muda, [trackingCacheVersion] sobe e caches
/// gravados antes da mudança deixam de ser usados. Montagem da chave
/// ([trackingCachePrefix]) e invalidação ([trackingCacheInvalidationPrefix])
/// derivam deste arquivo para não divergirem.
const String trackingCacheRoot = 'tracking';

/// Versão do payload da lista. `v5` introduz a ordenação por avaliação
/// (`sortBy=rating`), então caches `v4` não podem mais ser exibidos.
const String trackingCacheVersion = 'v5';

/// Prefixo que cobre toda entrada de acompanhamento, usado depois de mutações
/// no detalhe para invalidar as abas da lista.
const String trackingCacheInvalidationPrefix = '$trackingCacheRoot:';

/// Prefixo versionado das chaves da lista de acompanhamento.
const String trackingCachePrefix =
    '$trackingCacheInvalidationPrefix$trackingCacheVersion:';
